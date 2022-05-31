//
//  CustomPhotoAlbum.swift
//  ProManager
//
//  Created by Jasmin Patel on 30/04/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import Photos
import UIKit

class SCAlbum: NSObject {
    public var albumName = "\(Constant.Application.displayName)"
    static let shared = SCAlbum()
    
    private var assetCollection: PHAssetCollection!
    
    private override init() {
        super.init()
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
    }
    
    private func checkAuthorizationWithHandler(completion: @escaping ((_ success: Bool) -> Void)) {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (_) in
                self.checkAuthorizationWithHandler(completion: completion)
            })
        } else if PHPhotoLibrary.authorizationStatus() == .authorized {
            self.createAlbumIfNeeded { (success) in
                completion(success)
            }
        } else {
            if #available(iOS 14, *) {
                if PHPhotoLibrary.authorizationStatus() == .limited {
                    self.createAlbumIfNeeded { (success) in
                        completion(success)
                    }
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
    
    private func createAlbumIfNeeded(completion: @escaping ((_ success: Bool) -> Void)) {
        if let assetCollection = fetchAssetCollectionForAlbum() {
            // Album already exists
            self.assetCollection = assetCollection
            completion(true)
        } else {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)   // create an asset collection with the album name
            }, completionHandler: { success, _ in
                if success {
                    self.assetCollection = self.fetchAssetCollectionForAlbum()
                    completion(true)
                } else {
                    // Unable to create album
                    completion(false)
                }
            })
        }
    }
    
    private func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", self.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
    func save(image: UIImage, completion: ((_ success: Bool) -> Void)? = nil) {
        self.checkAuthorizationWithHandler { (success) in
            if success, self.assetCollection != nil {
                PHPhotoLibrary.shared().performChanges({
                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
                    if let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection) {
                        let enumeration: NSArray = [assetPlaceHolder!]
                        albumChangeRequest.addAssets(enumeration)
                    }
                    
                }, completionHandler: { (success, error) in
                    if success {
                        print("Successfully saved image to Camera Roll.")
                    } else {
                        print("Error writing to image library: \(error!.localizedDescription)")
                    }
                })
                
            }
            completion?(success)
        }
    }

    func saveVideo(at fileURL: URL) throws -> PHObjectPlaceholder {
        var blockPlaceholder: PHObjectPlaceholder?
        
        try PHPhotoLibrary.shared().performChangesAndWait {
            let changeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
            changeRequest?.creationDate = Date()
            blockPlaceholder = changeRequest?.placeholderForCreatedAsset
        }
        
        return blockPlaceholder!
    }
    
    func saveMovieToLibrary(movieURL: URL, completion: ((_ success: Bool) -> Void)? = nil) {
        self.checkAuthorizationWithHandler(completion: { (isSuccess) in
            if isSuccess, self.assetCollection != nil {
                do {
                    let placeholder = try self.saveVideo(at: movieURL)
                    try PHPhotoLibrary.shared().performChangesAndWait {
                        let request = PHAssetCollectionChangeRequest(for: self.assetCollection)
                        request?.addAssets([placeholder] as NSArray)
                    }
                } catch {
                    
                }
            }
            completion?(isSuccess)
        })
    }
    
    func saveAssetToLibrary(asset: AVAsset) {
        let exportURL = Utils.getLocalPath("\(String.fileName).mov")
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputFileType = AVFileType.mov
        exporter?.outputURL = exportURL
        exporter?.exportAsynchronously(completionHandler: {
            self.saveMovieToLibrary(movieURL: exportURL)
        })
    }
}

class MeargeVide {
    
    static func orientationFromTransform(_ transform: CGAffineTransform)
    -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }
    
    static  func videoCompositionInstruction(_ track: AVCompositionTrack, asset: AVAsset)
    -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracks(withMediaType: .video)[0]
        
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform)
        
        var scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.width
        if assetInfo.isPortrait {
            scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.height
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor), at: CMTime.zero)
        } else {
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            var concat = assetTrack.preferredTransform.concatenating(scaleFactor)
                .concatenating(CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.width / 2))
            if assetInfo.orientation == .down {
                let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                let windowBounds = UIScreen.main.bounds
                let yFix = assetTrack.naturalSize.height + windowBounds.height
                let centerFix = CGAffineTransform(translationX: assetTrack.naturalSize.width, y: yFix)
                concat = fixUpsideDown.concatenating(centerFix).concatenating(scaleFactor)
            }
            instruction.setTransform(concat, at: CMTime.zero)
        }
        
        return instruction
    }
    
    class func mergeVideoArray(arrayVideos:[AVAsset], callBack:@escaping (_ urlGet:URL?,_ errorGet:Error?) -> Void){
        
        var atTimeM: CMTime = CMTimeMake(value: 0, timescale: 0)
        var lastAsset: AVAsset!
        var layerInstructionsArray = [AVVideoCompositionLayerInstruction]()
        var completeTrackDuration: CMTime = CMTimeMake(value: 0, timescale: 1)
        var videoSize: CGSize = CGSize(width: 0.0, height: 0.0)
        var totalTime : CMTime = CMTimeMake(value: 0, timescale: 0)
        
        let mixComposition = AVMutableComposition.init()
        for videoAsset in arrayVideos{
            
            let videoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            do {
                if videoAsset == arrayVideos.first {
                    atTimeM = CMTime.zero
                } else {
                    atTimeM = totalTime // <-- Use the total time for all the videos seen so far.
                }
                try videoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration),
                                                of: videoAsset.tracks(withMediaType: AVMediaType.video)[0],
                                                at: completeTrackDuration)
                videoSize = (videoTrack?.naturalSize)!
                
                
                
            } catch let error as NSError {
                print("error: \(error)")
            }
            
            totalTime = CMTimeAdd(totalTime, videoAsset.duration)
            
            
            
            completeTrackDuration = CMTimeAdd(completeTrackDuration, videoAsset.duration)
            
            let firstInstruction = self.videoCompositionInstruction(videoTrack!, asset: videoAsset)
            firstInstruction.setOpacity(0.0, at: videoAsset.duration)
            
            layerInstructionsArray.append(firstInstruction)
            lastAsset = videoAsset
        }
        
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.layerInstructions = layerInstructionsArray
        mainInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: completeTrackDuration)
        
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mainComposition.renderSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: NSDate() as Date)
        let savePath = (documentDirectory as NSString).appendingPathComponent("mergeVideo-\(date).mov")
        let url = NSURL(fileURLWithPath: savePath)
        
        let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
        exporter!.outputURL = url as URL
        exporter!.outputFileType = AVFileType.mp4
        exporter!.shouldOptimizeForNetworkUse = true
        exporter!.videoComposition = mainComposition
        exporter!.exportAsynchronously {
            DispatchQueue.main.async {
                callBack(exporter?.outputURL, exporter?.error)
            }
            
        }
    }
}
