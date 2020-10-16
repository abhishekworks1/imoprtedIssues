//
//  FileManager.swift
//  ProManager
//
//  Created by Viraj Patel on 17/09/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Locations
/// Enum describing various kinds of locations that can be found on a file system.
public enum LocationKind {
    /// A file can be found at the location.
    case file
    /// A folder can be found at the location.
    case folder
}

extension FileManager {
    
    class func uniqueURL(for fileName: String) -> URL {
        return URL(fileURLWithPath: documentsDir().appending("/\(fileName)"))
    }
    
    class func documentsDir() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
    
    class func cachesDir() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
    
    func clearTempDirectory() {
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let tempDirectory = try? contentsOfDirectory(atPath: tempDirectoryURL.path)
        try? tempDirectory?.forEach { file in
            let fileUrl = tempDirectoryURL.appendingPathComponent(file)
            try? removeItem(atPath: fileUrl.path)
        }
    }
    
    func removeFileIfNecessary(at url: URL) throws {
        guard fileExists(atPath: url.path) else {
            return
        }
        
        do {
            try removeItem(at: url)
        } catch let error {
            throw TrimError("Couldn't remove existing destination file: \(error)")
        }
    }
    
    func locationExists(at path: String, kind: LocationKind) -> Bool {
        var isFolder: ObjCBool = false
        
        guard fileExists(atPath: path, isDirectory: &isFolder) else {
            return false
        }
        
        switch kind {
        case .file: return !isFolder.boolValue
        case .folder: return isFolder.boolValue
        }
    }
    
    static func getFreeDiskspace() -> NSNumber? {
        let documentDirectoryPath = documentsDir()
        let systemAttributes: AnyObject?
        do {
            systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: documentDirectoryPath) as AnyObject?
            let freeSize = systemAttributes?[FileAttributeKey.systemFreeSize] as? NSNumber
            return freeSize
        } catch let error as NSError {
            print("Error Obtaining System Memory Info: Domain = \(error.domain), Code = \(error.code)")
            return nil
        }
    }
    
    static func getUniqueFileNameWithPath(_ filePath: NSString) -> NSString {
        let fullFileName: NSString = filePath.lastPathComponent as NSString
        let fileName: NSString = fullFileName.deletingPathExtension as NSString
        let fileExtension: NSString = fullFileName.pathExtension as NSString
        var suggestedFileName: NSString = fileName
        
        var isUnique: Bool = false
        var fileNumber: Int = 0
        
        let fileManger: FileManager = FileManager.default
        
        repeat {
            var fileDocDirectoryPath: NSString?
            
            if fileExtension.length > 0 {
                fileDocDirectoryPath = "\(filePath.deletingLastPathComponent)/\(suggestedFileName).\(fileExtension)" as NSString?
            } else {
                fileDocDirectoryPath = "\(filePath.deletingLastPathComponent)/\(suggestedFileName)" as NSString?
            }
            
            let isFileAlreadyExists: Bool = fileManger.fileExists(atPath: fileDocDirectoryPath! as String)
            
            if isFileAlreadyExists {
                fileNumber += 1
                suggestedFileName = "\(fileName)(\(fileNumber))" as NSString
            } else {
                isUnique = true
                if fileExtension.length > 0 {
                    suggestedFileName = "\(suggestedFileName).\(fileExtension)" as NSString
                }
            }
            
        } while isUnique == false
        
        return suggestedFileName
    }
    
    static func format(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        
        if duration >= 3600 {
            formatter.allowedUnits = [.hour, .minute, .second]
        } else {
            formatter.allowedUnits = [.minute, .second]
        }
        
        return formatter.string(from: duration) ?? ""
    }
    
    static func calculateFileSizeInUnit(_ contentLength: Int64) -> Float {
        let dataLength: Float64 = Float64(contentLength)
        if dataLength >= (1024.0 * 1024.0 * 1024.0) {
            return Float(dataLength / (1024.0 * 1024.0 * 1024.0))
        } else if dataLength >= 1024.0 * 1024.0 {
            return Float(dataLength / (1024.0 * 1024.0))
        } else if dataLength >= 1024.0 {
            return Float(dataLength / 1024.0)
        } else {
            return Float(dataLength)
        }
    }
    
    static func calculateUnit(_ contentLength: Int64) -> NSString {
        if(contentLength >= (1024 * 1024 * 1024)) {
            return "GB"
        } else if contentLength >= (1024 * 1024) {
            return "MB"
        } else if contentLength >= 1024 {
            return "KB"
        } else {
            return "Bytes"
        }
    }
    
    static func addSkipBackupAttributeToItemAtURL(_ docDirectoryPath: NSString) -> Bool {
        let url: URL = URL(fileURLWithPath: docDirectoryPath as String)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url.path) {
            do {
                try (url as NSURL).setResourceValue(NSNumber(value: true as Bool), forKey: URLResourceKey.isExcludedFromBackupKey)
                return true
            } catch let error as NSError {
                print("Error excluding \(url.lastPathComponent) from backup \(error)")
                return false
            }
            
        } else {
            return false
        }
    }
    
}
