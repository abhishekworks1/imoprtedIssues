//
//  StorySegmmentAsset.swift
//  SocialCAM
//
//  Created by Viraj Patel on 23/12/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation

class StoryAsset {
    var asset: AVAsset
    
    init(asset: AVAsset) {
        self.asset = asset
    }
}

class StorySegment {
    
    private var storyAssets: [StoryAsset] = []
    
    public func addAsset(_ storyAsset: StoryAsset) {
        self.storyAssets.append(storyAsset)
    }
    
    public func assetRepresentingSegments() -> AVAsset {
        return self.mergedAssetComposition()
    }
    public func playerItemRepresentingSegments() -> AVPlayerItem {
        return AVPlayerItem(asset: self.mergedAssetComposition())
    }
    private func mergedAssetComposition() -> AVMutableComposition {
        let composition = AVMutableComposition()
        var audioTrack: AVMutableCompositionTrack? = nil
        var videoTrack: AVMutableCompositionTrack? = nil
        
        var currentSegment = 0
        var currentTime = composition.duration
        for recordSegment in storyAssets {
            let asset = recordSegment.asset
            
            let audioAssetTracks = asset.tracks(withMediaType: .audio)
            let videoAssetTracks = asset.tracks(withMediaType: .video)
            
            var maxBounds: CMTime = .invalid
            
            var videoTime = currentTime
            for videoAssetTrack in videoAssetTracks {
                if videoTrack == nil {
                    let videoTracks = composition.tracks(withMediaType: .video)
                    
                    if videoTracks.count > 0 {
                        videoTrack = videoTracks.first
                    } else {
                        videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
                    }
                    videoTrack?.preferredTransform = videoAssetTrack.preferredTransform
                }
                
                if let track = videoTrack {
                    videoTime = self.append(videoAssetTrack, to: track, at: videoTime, withBounds: maxBounds)
                    maxBounds = videoTime
                }
            }
            
            var audioTime = currentTime
            for audioAssetTrack in audioAssetTracks {
                if audioTrack == nil {
                    let audioTracks = composition.tracks(withMediaType: .audio)
                    
                    if audioTracks.count > 0 {
                        audioTrack = audioTracks.first
                    } else {
                        audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
                    }
                }
                
                if let track = audioTrack {
                    audioTime = self.append(audioAssetTrack, to: track, at: audioTime, withBounds: maxBounds)
                }
            }
            
            currentTime = composition.duration
            
            currentSegment += 1
        }
        return composition
    }
    
    private func append(_ track: AVAssetTrack, to compositionTrack: AVMutableCompositionTrack, at time: CMTime, withBounds bounds: CMTime) -> CMTime {
        var time = time
        var timeRange = track.timeRange
        time = CMTimeAdd(time, timeRange.start)
        if CMTIME_IS_VALID(bounds) {
            let currentBounds = CMTimeAdd(time, timeRange.duration)
            if currentBounds > bounds {
                timeRange = CMTimeRange(start: timeRange.start, duration: CMTimeSubtract(timeRange.duration, CMTimeSubtract(currentBounds, bounds)))
            }
        }
        if timeRange.duration > .zero {
            do {
                try compositionTrack.insertTimeRange(timeRange, of: track, at: time)
            } catch let error {
                print("Failed to insert append \(compositionTrack.mediaType) track: \(error)")
            }
            return CMTimeAdd(time, timeRange.duration)
        }
        return time
    }
}
