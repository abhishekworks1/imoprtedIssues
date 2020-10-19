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
    
    var exportSession: AVAssetExportSession?
    
    static let shared: VideoMediaHelper = VideoMediaHelper()
    
    func compressMovie(asset: AVAsset, filename: String, quality: VideoQuality, deleteSource: Bool, progressCallback: @escaping (Float) -> Void, completionHandler: @escaping (_ url: URL?) -> Void) {
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: quality.preset) else {
            completionHandler(nil)
            return
        }
        self.exportSession = exportSession
        self.exportSession?.shouldOptimizeForNetworkUse = true
        self.exportSession?.outputFileType = .mp4
        let fileUrl = FileManager.default.temporaryDirectory.appendingPathComponent(filename + ".mp4", isDirectory: false)
        if deleteSource {
            try? FileManager.default.removeItem(at: fileUrl)
        }
        self.exportSession?.outputURL = fileUrl
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
            progressCallback(self.exportSession?.progress ?? 0)
        })
        self.exportSession?.exportAsynchronously(completionHandler: {
            timer.invalidate()
            switch exportSession.status {
            case AVAssetExportSessionStatus.completed:
                completionHandler(fileUrl)
            default:
                completionHandler(nil)
            }
        })
    }
    
    func cancelExporting() {
        exportSession?.cancelExport()
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
            return AVAssetExportPresetHEVC1920x1080
        case .medium:
            return AVAssetExportPresetMediumQuality
        case .low:
            return AVAssetExportPresetLowQuality
        }
    }
}
