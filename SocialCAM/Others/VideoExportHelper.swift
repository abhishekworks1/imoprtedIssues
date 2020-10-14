//
//  VideoExportHelper.swift
//  SocialCAM
//
//  Created by Viraj Patel on 15/10/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit

class VideoMediaHelper {
    
    static func compressMovie(asset: AVAsset, filename: String, quality: VideoQuality, deleteSource: Bool, progressCallback: @escaping (Float) -> Void, completionHandler: @escaping (_ url: URL?) -> Void) {
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: quality.preset) else {
            completionHandler(nil)
            return
        }
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.outputFileType = .mp4
        let fileUrl = FileManager.default.temporaryDirectory.appendingPathComponent(filename + ".mp4", isDirectory: false)
        if deleteSource {
            try? FileManager.default.removeItem(at: fileUrl)
        }
        exportSession.outputURL = fileUrl
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
            progressCallback(exportSession.progress)
        })
        exportSession.exportAsynchronously(completionHandler: {
            timer.invalidate()
            completionHandler(fileUrl)
        })
    }
    
}

enum VideoQuality: String {
    case original
    case high
    case medium
    case low
    
    var preset: String {
        switch self {
        case .original:
            return AVAssetExportPresetPassthrough
        case .high:
            return AVAssetExportPresetHighestQuality
        case .medium:
            return AVAssetExportPresetMediumQuality
        case .low:
            return AVAssetExportPresetLowQuality
        }
    }
}
