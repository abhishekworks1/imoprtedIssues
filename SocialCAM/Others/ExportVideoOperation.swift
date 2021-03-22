//
//  ExportVideoOperation.swift
//  SocialCAM
//
//  Created by Viraj Patel on 28/11/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit
import SCRecorder

class ExportVideoOpration: AsynchronousOperation {
    
    var itemProvider: SegmentVideos?
    var url: URL?
    var completionURLBlock: ((_ image: URL) -> Void)?
    
    override func execute() {
        self.completionBlock = {
            if let block = self.completionURLBlock {
                block(self.url!)
            }
        }
        
        let mergeSession = SCRecordSession.init()
        for segementModel in itemProvider!.videos {
            let segment = SCRecordSessionSegment(url: segementModel.url!, info: nil)
            mergeSession.addSegment(segment)
        }
        
        self.exportViewWithURL(mergeSession.assetRepresentingSegments()) { [weak self] url in
            guard let `self` = self else { return }
            if let exportURL = url {
                let album = SCAlbum.shared
                album.saveMovieToLibrary(movieURL: exportURL)
                self.url = exportURL
                self.isFinished = true
            }
        }
    }
    
    func exportViewWithURL(_ asset: AVAsset, completionHandler: @escaping (_ url: URL?) -> Void) {
        let exportSession = StoryAssetExportSession()
        exportSession.export(for: asset, progress: { progress in
            print("New progress \(progress)")
            
        }, completion: { exportedURL in
            if let url = exportedURL {
                completionHandler(url)
            }
        })
    }
    
    private func filePath() -> URL {
        let fileData = "\(Constant.Application.displayName.replacingOccurrences(of: " ", with: "").lowercased())_\(Defaults.shared.releaseType.description)_v\(Constant.Application.appBuildNumber)_\(String.fileName)" + FileExtension.mp4.rawValue
        let filename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileData)
        return filename
    }
    
}
