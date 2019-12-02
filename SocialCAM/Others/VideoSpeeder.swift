//
//  VideoSpeeder.swift
//  VideoSpeeder
//
//  Created by Jasmin Patel on 29/01/19.
//  Copyright © 2019 Simform. All rights reserved.
//

import Foundation
import AVKit

class VideoScalerPart: CustomStringConvertible {
    var description: String {
        return "startTime: \(startTime)\nrate: \(rate)"
    }
    var startTime: Double
    var rate: Int
    init(startTime: Double, rate: Int) {
        self.startTime = startTime
        self.rate = rate
    }
}

class VideoScalerValue: CustomStringConvertible {
    var description: String {
        return "range: \(range)\n\nduration: \(duration)"
    }
    
    var range: CMTimeRange
    var duration: CMTime
    var rate: Int
    init(range: CMTimeRange, duration: CMTime, rate: Int) {
        self.range = range
        self.duration = duration
        self.rate = rate
    }
}

class VideoScaler {
    
    static let shared: VideoScaler = VideoScaler()
    
    var assetWriter: AVAssetWriter?
    var assetReader: AVAssetReader?
    
    private func scaleCompositionTrack(with compositionTrack: AVMutableCompositionTrack, and scalerValues: [VideoScalerValue]) -> [VideoScalerPart] {
        var videoScalerParts = [VideoScalerPart]()
        var lastStartSeconds: Double = 0
        for (index, scalerValue) in scalerValues.enumerated() {
            var timeRange = scalerValue.range
            if index > 0 {
                timeRange.start = CMTime(seconds: lastStartSeconds,
                                         preferredTimescale: timeRange.start.timescale)
            }
            videoScalerParts.append(VideoScalerPart.init(startTime: timeRange.start.seconds, rate: scalerValue.rate))
            compositionTrack.scaleTimeRange(timeRange, toDuration: scalerValue.duration)
            lastStartSeconds = timeRange.start.seconds + scalerValue.duration.seconds
        }
        return videoScalerParts
    }
    
    func scaleVideo(asset: AVAsset, scalerValues: [VideoScalerValue]) -> (AVMutableComposition?, [VideoScalerPart]) {
        let videoTracks = asset.tracks(withMediaType: AVMediaType.video)
        guard !videoTracks.isEmpty else {
            return (nil, [])
        }
        let totalTimeRange = CMTimeRange(start: CMTime.zero,
                                         duration: CMTime(seconds: asset.duration.seconds,
                                                          preferredTimescale: asset.duration.timescale))
        
        let scaleComposition = AVMutableComposition()
        
        let videoTrack = videoTracks.first!
        let videoCompositionTrack = scaleComposition.addMutableTrack(withMediaType: AVMediaType.video,
                                                                     preferredTrackID: kCMPersistentTrackID_Invalid)
        do {
            try videoCompositionTrack?.insertTimeRange(totalTimeRange, of: videoTrack, at: CMTime.zero)
        } catch let error {
            print(error)
            return (nil, [])
        }
        let scalerParts = self.scaleCompositionTrack(with: videoCompositionTrack!, and: scalerValues)
        videoCompositionTrack?.preferredTransform = videoTrack.preferredTransform
        
        let audioTracks = asset.tracks(withMediaType: AVMediaType.audio)
        if !audioTracks.isEmpty {
            let audioTrack = audioTracks.first!
            let audioCompositionTrack = scaleComposition.addMutableTrack(withMediaType: AVMediaType.audio,
                                                                         preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try audioCompositionTrack?.insertTimeRange(totalTimeRange, of: audioTrack, at: CMTime.zero)
            } catch let error {
                print(error)
            }
            _ = self.scaleCompositionTrack(with: audioCompositionTrack!, and: scalerValues)
        }
        
        return (scaleComposition, scalerParts)
    }
    
    func exportVideo(scaleComposition: AVMutableComposition, completion: @escaping (_ outputURL: URL) -> Void) {
        compressFile(scaleComposition: scaleComposition) { (outputURL) in
            completion(outputURL)
        }
    }
    
    func compressFile(scaleComposition: AVMutableComposition, completion:@escaping (URL) -> Void) {
        let fileName = String.fileName + FileExtension.mov.rawValue
        let outputURL = Utils.getLocalPath(fileName)
        
        // video file to make the asset
        var audioFinished = false
        var videoFinished = false
        
        let asset = scaleComposition
        
        // create asset reader
        do {
            assetReader = try AVAssetReader(asset: asset)
        } catch {
            assetReader = nil
        }
        
        guard let reader = assetReader else {
            print("Could not initalize asset reader probably failed its try catch")
            return
        }
        
        guard let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first else {
            return
        }
        
        let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first
        
        let videoReaderSettings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB ]
        
        let videoSettings: [String: Any] = [
            AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: NSNumber.init(value: videoTrack.estimatedDataRate)],
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoHeightKey: videoTrack.naturalSize.height,
            AVVideoWidthKey: videoTrack.naturalSize.width
        ]
        
        let assetReaderVideoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
        var assetReaderAudioOutput: AVAssetReaderTrackOutput?
        if let audioTrack = audioTrack {
            assetReaderAudioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
        }
        
        if reader.canAdd(assetReaderVideoOutput) {
            reader.add(assetReaderVideoOutput)
        } else {
            print("Couldn't add video output reader")
        }
        
        if let assetReaderAudioOutput = assetReaderAudioOutput,
            reader.canAdd(assetReaderAudioOutput) {
            reader.add(assetReaderAudioOutput)
        }
        
        let audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: nil)
        let videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
        videoInput.transform = videoTrack.preferredTransform
        
        let videoInputQueue = DispatchQueue(label: "videoQueue")
        let audioInputQueue = DispatchQueue(label: "audioQueue")
        
        do {
            assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mov)
        } catch {
            assetWriter = nil
        }
        
        guard let writer = assetWriter else {
            print("assetWriter was nil")
            return
        }
        
        writer.shouldOptimizeForNetworkUse = true
        writer.add(videoInput)
        writer.add(audioInput)
        
        writer.startWriting()
        reader.startReading()
        writer.startSession(atSourceTime: CMTime.zero)
        
        let closeWriter: (() -> Void) = {
            if audioFinished && videoFinished {
                self.assetWriter?.finishWriting(completionHandler: {
                    completion((self.assetWriter?.outputURL)!)
                })
                self.assetReader?.cancelReading()
            }
        }
        
        audioInput.requestMediaDataWhenReady(on: audioInputQueue) {
            while audioInput.isReadyForMoreMediaData {
                let sample = assetReaderAudioOutput?.copyNextSampleBuffer()
                if sample != nil {
                    audioInput.append(sample!)
                } else {
                    audioInput.markAsFinished()
                    DispatchQueue.main.async {
                        audioFinished = true
                        closeWriter()
                    }
                    break
                }
            }
        }
        
        videoInput.requestMediaDataWhenReady(on: videoInputQueue) {
            while videoInput.isReadyForMoreMediaData {
                let sample = assetReaderVideoOutput.copyNextSampleBuffer()
                if (sample != nil) {
                    videoInput.append(sample!)
                } else {
                    videoInput.markAsFinished()
                    DispatchQueue.main.async {
                        videoFinished = true
                        closeWriter()
                    }
                    break
                }
            }
        }
    }
}

extension AVPlayer {
    var isPlayingPlayer: Bool {
        return rate != 0 && error == nil
    }
}
