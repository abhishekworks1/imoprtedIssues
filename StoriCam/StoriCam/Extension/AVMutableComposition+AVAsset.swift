//
//  AVMutableComposition.swift
//  ProManager
//
//  Created by Viraj Patel on 17/09/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

extension AVMutableComposition {
    convenience init(asset: AVAsset) {
        self.init()
        
        for track in asset.tracks {
            addMutableTrack(withMediaType: track.mediaType, preferredTrackID: track.trackID)
        }
    }
    
    func trim(timeOffStart: Double) {
        let duration = CMTime(seconds: timeOffStart, preferredTimescale: 1)
        let timeRange = CMTimeRange(start: CMTime.zero, duration: duration)
        
        for track in tracks {
            track.removeTimeRange(timeRange)
        }
        
        removeTimeRange(timeRange)
    }
}

extension AVAsset {
    func assetByTrimming(timeOffStart: Double) throws -> AVAsset {
        let duration = CMTime(seconds: timeOffStart, preferredTimescale: 1)
        let timeRange = CMTimeRange(start: CMTime.zero, duration: duration)
        
        let composition = AVMutableComposition()
        
        do {
            for track in tracks {
                let compositionTrack = composition.addMutableTrack(withMediaType: track.mediaType, preferredTrackID: track.trackID)
                try compositionTrack?.insertTimeRange(timeRange, of: track, at: CMTime.zero)
            }
        } catch let error {
            throw TrimError("error during composition", underlyingError: error)
        }
        
        return composition
    }
    
    func assetByTrimming(startTime: CMTime, endTime: CMTime) throws -> AVAsset {
        let timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
        let composition = AVMutableComposition()
        
        do {
            for track in tracks {
                let compositionTrack = composition.addMutableTrack(withMediaType: track.mediaType, preferredTrackID: track.trackID)
                try compositionTrack?.insertTimeRange(timeRange, of: track, at: CMTime.zero)
                let videoTrack = self.tracks(withMediaType: AVMediaType.video).first
                
                let transform = videoTrack!.preferredTransform
                let assetInfo = orientationFromTransform(transform)
                
                let scaleToFitRatio = UIScreen.main.bounds.width / videoTrack!.naturalSize.width
                
                if assetInfo.isPortrait {
                    compositionTrack?.preferredTransform = videoTrack!.preferredTransform
                } else {
                    let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
                    var concat = videoTrack!.preferredTransform.concatenating(scaleFactor).concatenating(CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.width / 2))
                    if assetInfo.orientation == .down {
                        let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                        let windowBounds = UIScreen.main.bounds
                        let yFix = videoTrack!.naturalSize.height + windowBounds.height
                        let centerFix = CGAffineTransform(translationX: videoTrack!.naturalSize.width, y: yFix)
                        concat = fixUpsideDown.concatenating(centerFix).concatenating(scaleFactor)
                    }
                    compositionTrack?.preferredTransform = concat
                }
            }
        } catch let error {
            throw TrimError("error during composition", underlyingError: error)
        }
        return composition
    }
    
    // helper methods
    internal func videoCompositionInstructionForTrack(_ track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        
        let assetTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform)
        
        var scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.width
        
        if assetInfo.isPortrait {
            scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.height
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor),
                                     at: CMTime.zero)
        } else {
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            var concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.width / 2))
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
    
    internal func orientationFromTransform(_ transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
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
    
    func export(to destination: URL) throws {
        guard let exportSession = AVAssetExportSession(asset: self, presetName: AVAssetExportPresetPassthrough) else {
            throw TrimError("Could not create an export session")
        }
        
        exportSession.outputURL = destination
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
        let group = DispatchGroup()
        
        group.enter()
        
        try FileManager.default.removeFileIfNecessary(at: destination)
        
        exportSession.exportAsynchronously {
            group.leave()
        }
        
        group.wait()
        
        if let error = exportSession.error {
            throw TrimError("error during export", underlyingError: error)
        }
    }
}
