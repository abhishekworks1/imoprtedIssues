//
//  Utility.swift
//  ProManager
//
//  Created by Viraj Patel on 12/04/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import Photos
import UIKit
import RxSwift
import AWSCore
import AWSS3
import Alamofire

public struct Utils {
   
    static var appDelegate: AppDelegate? {
        if let delegate = UIApplication.shared.delegate
        {
            return delegate as? AppDelegate
        } else {
            return nil
        }
    }
    
    static func getLocalPath(_ fileName: String) -> URL {
        var path = FileManager.documentsDir()
        path = (path as NSString).appendingPathComponent(fileName)
        let filePath = URL(fileURLWithPath: path)
        return filePath
    }
    
    static func deleteFileFromLocal(_ fileNameToDelete: String) {
        var filePath = ""
        
        // Fine documents directory on device
        let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        
        if dirs.count > 0 {
            let dir = dirs[0] //documents directory
            filePath = dir.appendingFormat("/" + fileNameToDelete)
            print("Local path = \(filePath)")
        } else {
            print("Could not find local directory to store file")
            return
        }
        
        do {
            let fileManager = FileManager.default
            // Check if file exists
            if fileManager.fileExists(atPath: filePath) {
                // Delete file
                try fileManager.removeItem(atPath: filePath)
                print("Remove File From Local")
            } else {
                print("File does not exist")
            }
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
    }
   
    static func uploadFile(fileName: String, fileURL: URL, contentType: String, progressBlock: @escaping (Float) -> () = { _ in }, otherProgressBlock: ((Float, Float, Float) -> ())? = { _,_,_  in }, callBack: @escaping (_ url: String) -> Void?, failedBlock: @escaping (Swift.Error?) -> () = { _ in })
    {
        AWSManager.shareInstance().uploadImageToAmazon(currentFileName: fileName, soundFileURL: fileURL, contentType: contentType, nil, progressBlock: progressBlock, otherProgressBlock: otherProgressBlock, callBack: callBack)
    }
    
    static func uploadSingleUrlStop(_ itemUrl : String?) {
        guard let itemUrlString = itemUrl else {
            return
        }
        for (_, uploadRequestCancle) in AWSManager.shareInstance().uploadRequests.enumerated() {
            if uploadRequestCancle?.body.absoluteString == itemUrlString {
                uploadRequestCancle?.cancel()?.continueWith(block: { (task) -> Any? in
                    if let error = task.error {
                        debugPrint("cancel() failed: [\(error)]")
                    }
                    return ""
                })
                
            }
        }
    }
    
    static func uploadStopAll() {
        for (_, uploadRequestCancle) in AWSManager.shareInstance().uploadRequests.enumerated() {
            uploadRequestCancle?.cancel().continueWith(block: { (task) -> Any? in
                if let error = task.error {
                    debugPrint("cancel() failed: [\(error)]")
                }
                return ""
            })
        }
    }
    
    static func uploadImage(imgName: String, img: UIImage, progressBlock: @escaping (Float) -> () = { _ in }, callBack: @escaping (_ url: String) -> Void?) {
        let width = 400.0
        let image = img.resizeImage(newWidth: CGFloat(width))
        let data = image.jpegData(compressionQuality: 0.6)
        let url = Utils.getLocalPath(imgName)
        try? data?.write(to: url)
        DispatchQueue.main.async {
            AWSManager.shareInstance().uploadImageToAmazon(currentFileName: imgName, soundFileURL: url, nil, progressBlock: progressBlock, callBack: callBack)
        }
    }
    
    static func uploadVideo(videoName: String, videoData: Data, progressBlock: @escaping (Float) -> () = { _ in }, callBack: @escaping (String) -> ()) {
        let data = videoData
        let url = Utils.getLocalPath(videoName)
        try?data.write(to: url)
        DispatchQueue.main.async {
            AWSManager.shareInstance().uploadImageToAmazon(currentFileName: videoName, soundFileURL: url, nil, progressBlock: progressBlock, callBack: callBack)
        }
    }
    
    static func uploadVideo(videoData: Data, progressBlock: @escaping (Float) -> () = { _ in }, callBack: @escaping (String) -> (), failedBlock: @escaping (Swift.Error?) -> () = { _ in }) {
        let videoName = String.fileName + FileExtension.mov.rawValue
        let data = videoData
        let url = Utils.getLocalPath(videoName)
        try? data.write(to: url)
        DispatchQueue.main.async {
            AWSManager.shareInstance().uploadImageToAmazon(currentFileName: videoName, soundFileURL: url, nil, progressBlock: progressBlock, callBack: callBack, failedBlock: failedBlock)
        }
    }
    
    static func uploadAudio(audioName: String, audioData: Data, callBack: @escaping (_ url: String) -> Void?) {
        let data = audioData
        let url = Utils.getLocalPath(audioName)
        try? data.write(to: url)
        DispatchQueue.main.async {
            AWSManager.shareInstance().uploadAudioToAmazon(currentFileName: audioName, soundFileURL: url, callBack: callBack)
        }
    }
    
    static func uploadImage(img: UIImage, progressBlock: @escaping (Float) -> () = { _ in }, callBack: @escaping (_ url: String) -> Void?, failedBlock: @escaping (Swift.Error?) -> () = { _ in }) {
        let fileName = String.fileName + FileExtension.jpg.rawValue
        
        let width = 400.0
        let image = img.resizeImage(newWidth: CGFloat(width))
        let data = image.jpegData(compressionQuality: 0.6)
        let url = Utils.getLocalPath(fileName)
        try? data?.write(to: url)
        DispatchQueue.main.async {
            AWSManager.shareInstance().uploadImageToAmazon(currentFileName: fileName, soundFileURL: url, nil, progressBlock: progressBlock, callBack: callBack, failedBlock: failedBlock)
        }
    }
    
    static func uploadVideo(videoData: Data, callBack: @escaping (_ url: String) -> Void?) {
        let fileName = String.fileName + FileExtension.mov.rawValue
        let data = videoData
        let url = Utils.getLocalPath(fileName)
        try? data.write(to: url)
        DispatchQueue.main.async {
            AWSManager.shareInstance().uploadImageToAmazon(currentFileName: fileName, soundFileURL: url, nil, callBack: callBack)
        }
    }
    
    static func uploadProfileVideo(videoData: Data, callBack: @escaping (_ url: String) -> Void?) {
        let fileName = String.fileName + FileExtension.mov.rawValue
        let data = videoData
        let url = Utils.getLocalPath(fileName)
        try?data.write(to: url)
        DispatchQueue.main.async {
            AWSManager.shareInstance().uploadImageToAmazon(currentFileName: fileName, soundFileURL: url, Constant.AWS.PROFILE_VIDEO_BUCKET_NAME, callBack: callBack)
        }
    }
    
    static func clearAllFilesFromTestFolder() {
        do {
            guard let allFiles = try? FileSystem().documentFolder?.subfolder(named: "StoryCacheVideo").files else {
                return
            }
            
            for file in allFiles {
                let date = getfileCreatedDate(theFile: file.path)
                var calendar = NSCalendar.current
                calendar.timeZone = NSTimeZone.local
                let dateAtMidnight = calendar.startOfDay(for: Date())
                
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: dateAtMidnight)!
                let range = dateAtMidnight...tomorrow
                if range.contains(date) {
                    debugPrint("The date is inside the range")
                } else {
                    try file.delete()
                    debugPrint("The date is outside the range")
                }
            }
        } catch let theError {
            debugPrint("StoryCacheVideo Folder NotFound Error \(theError)")
        }
    }
    
    static func getfileCreatedDate(theFile: String) -> Date {
        var theCreationDate = Date()
        do {
            let aFileAttributes = try FileManager.default.attributesOfItem(atPath: theFile) as [FileAttributeKey:Any]
            theCreationDate = aFileAttributes[FileAttributeKey.creationDate] as! Date
            
        } catch let theError {
            debugPrint("file not found \(theError)")
        }
        return theCreationDate
    }
    
    static func time(_ operation: () throws -> ()) rethrows {
        let start = Date()
        try operation()
        let end = Date().timeIntervalSince(start)
    }
    
    static func hmsString(from seconds: Double) -> String {
        let roundedSeconds = Int(seconds.rounded())
        let hours = (roundedSeconds / 3600)
        let minutes = (roundedSeconds % 3600) / 60
        let seconds = (roundedSeconds % 3600) % 60
        func timeString(_ time: Int) -> String {
            return time < 10 ? "0\(time)" : "\(time)"
        }
        if hours > 0 {
            return "\(timeString(hours)):\(timeString(minutes)):\(timeString(seconds))"
        }
        return "\(timeString(minutes)):\(timeString(seconds))"
    }
    
    static func rotationTransform() -> CGAffineTransform {
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            return CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        case .landscapeRight:
            return CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        case .portraitUpsideDown:
            return CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        default:
            return CGAffineTransform.identity
        }
    }

    static func videoOrientation() -> AVCaptureVideoOrientation {
        switch UIDevice.current.orientation {
        case .portrait:
            return .portrait
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }

    static func fetchOptions() -> PHFetchOptions {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return options
    }
}
