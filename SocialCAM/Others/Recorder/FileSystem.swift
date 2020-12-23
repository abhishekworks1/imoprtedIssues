//
//  FileSystem.swift
//  SocialScreenRecorder
//
//  Created by Viraj Patel on 11/12/20.
//

import Foundation

class FileSystemUtil {
    
    var groupIdentifier = Constant.Application.recordeGroupIdentifier
    
    class func getAllFiles() -> [[String : Any]] {
        guard let sharedContainerURL: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constant.Application.recordeGroupIdentifier) else {
            return []
        }
        let directoryContents = try? FileManager.default.contentsOfDirectory(at: sharedContainerURL, includingPropertiesForKeys: [.contentModificationDateKey], options: [])
        let sortedContents = directoryContents?.sorted { (a, b) -> Bool in
            let adate = (try? a.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
            let bdate = (try? b.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
            return adate > bdate
        }
        let finalData = sortedContents?.map { (URL) -> Dictionary<String, Any> in
            return [
                "absolutePath": URL.absoluteString,
                "relativePath": URL.relativePath
            ]
        } ?? []
        return finalData
    }
    
    class func clearAllFile() {
        let fileManager = FileManager.default
        guard let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        do {
            try fileManager.removeItem(at: myDocuments)
        } catch {
            return
        }
    }
    
    class func removeAllFiles() {
        guard let sharedContainerURL: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constant.Application.recordeGroupIdentifier) else {
            return
        }
        let fileManager = FileManager.default
        let directoryContents = try? FileManager.default.contentsOfDirectory(at: sharedContainerURL, includingPropertiesForKeys: [.contentModificationDateKey], options: [])
        
        let sortedContents = directoryContents?.sorted { (a, b) -> Bool in
            let adate = (try? a.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
            let bdate = (try? b.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
            return adate > bdate
        }
        guard let sortedContent = sortedContents else {
            return
        }
        for url in sortedContent {
            do {
                try fileManager.removeItem(at: url)
            } catch {
                return
            }
        }
    }
    
    internal class func createReplaysFolder() {
        // path to documents directory
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        if let documentDirectoryPath = documentDirectoryPath {
            // create the custom folder path
            let replayDirectoryPath = documentDirectoryPath.appending("/Replays")
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: replayDirectoryPath) {
                do {
                    try fileManager.createDirectory(atPath: replayDirectoryPath,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
                } catch {
                    print("Error creating Replays folder in documents dir: \(error)")
                }
            }
        }
    }
    
    internal class func filePath(_ fileName: String) -> String {
        createReplaysFolder()
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as String
        let filePath : String = "\(documentsDirectory)/Replays/\(fileName).mp4"
        return filePath
    }
}

