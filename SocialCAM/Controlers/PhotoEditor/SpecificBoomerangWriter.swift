//
//  SpecificBoomerangWriter.swift
//  VideoEditor
//
//  Created by Jasmin Patel on 02/01/20.
//  Copyright © 2020 Jasmin Patel. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class SpecificBoomerangExportConfig {
    
    var boomerangTimeRange: CMTimeRange
    var boomerangSpeedScale: Int
    var boomerangLoopCount: Int
    var needToReverse: Bool
    
    init(boomerangTimeRange: CMTimeRange, boomerangSpeedScale: Int, boomerangLoopCount: Int, needToReverse: Bool) {
        self.boomerangTimeRange = boomerangTimeRange
        self.boomerangSpeedScale = boomerangSpeedScale
        self.boomerangLoopCount = boomerangLoopCount
        self.needToReverse = needToReverse
    }
    
}

class SpecificBoomerangExportSession {
    
    private var reader: AVAssetReader?
    private var boomerangReader: AVAssetReader?
    private var secondPartReader: AVAssetReader?

    private var writer: AVAssetWriter?
    private var cancelled = false
    private var ciContext = CIContext()

    private var config: SpecificBoomerangExportConfig
    
    private func fileURL() -> URL {
        let fileName = "\(UUID().uuidString).mov"
        var documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                        .userDomainMask, true)[0]
        documentDirectoryPath = documentDirectoryPath.appending("/\(fileName)")
        return URL(fileURLWithPath: documentDirectoryPath)
    }
    
    init(config: SpecificBoomerangExportConfig) {
        self.config = config
    }
    
    public func export(for asset: AVAsset, progress: ((Float) -> Void)? = nil, completion: @escaping (URL?) -> Void) {
        cancelled = false
        var audioFinished = false
        var videoFinished = false
                
        var firstPartAsset: AVAsset?
        var boomerangAsset: AVAsset?
        var secondPartAsset: AVAsset?
    
        firstPartAsset = try? asset.assetByTrimming(startTime: .zero, endTime: config.boomerangTimeRange.start)
        boomerangAsset = try? asset.assetByTrimming(startTime: config.boomerangTimeRange.start, endTime: config.boomerangTimeRange.end)
        secondPartAsset = try? asset.assetByTrimming(startTime: config.boomerangTimeRange.end, endTime: asset.duration)
        
        if let firstAsset = firstPartAsset {
            // Setup Reader
            do {
                reader = try AVAssetReader(asset: firstAsset)
            } catch {
                print("AVAssetReader initialization failed with error : \(error)")
            }
        }
        if let boomerangAsset = boomerangAsset {
            // Setup Reader
            do {
                boomerangReader = try AVAssetReader(asset: boomerangAsset)
            } catch {
                print("AVAssetReader initialization failed with error : \(error)")
            }
        }
        if let secondAsset = secondPartAsset {
            // Setup Reader
            do {
                secondPartReader = try AVAssetReader(asset: secondAsset)
            } catch {
                print("AVAssetReader initialization failed with error : \(error)")
            }
        }
        
        var nextBufferTime = CMTime(value: 1, timescale: 24)
        var videoBitRate: NSNumber = 2000000
        var trackWidth: CGFloat = 720
        var trackHeight: CGFloat = 1280
        var trackTransform: CGAffineTransform = .identity


        let videoReaderSettings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB ]
        var assetReaderVideoOutput: AVAssetReaderTrackOutput?
        if let videoTrack = firstPartAsset?.tracks(withMediaType: AVMediaType.video).first {
            
            nextBufferTime = CMTime(value: 1, timescale: CMTimeScale(videoTrack.nominalFrameRate))
            videoBitRate = NSNumber(value: videoTrack.estimatedDataRate)
            trackWidth = videoTrack.naturalSize.width
            trackHeight = videoTrack.naturalSize.height
            trackTransform = videoTrack.preferredTransform
            
            assetReaderVideoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
            if reader?.canAdd(assetReaderVideoOutput!) ?? false {
                reader?.add(assetReaderVideoOutput!)
            }
        }
        
        var boomerangReaderVideoOutput: AVAssetReaderTrackOutput?
        if let videoTrack = boomerangAsset?.tracks(withMediaType: .video).first {
            boomerangReaderVideoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
            if boomerangReader?.canAdd(boomerangReaderVideoOutput!) ?? false {
                boomerangReader?.add(boomerangReaderVideoOutput!)
            }
        }
        var secondReaderVideoOutput: AVAssetReaderTrackOutput?
        if let videoTrack = secondPartAsset?.tracks(withMediaType: .video).first {
            
            nextBufferTime = CMTime(value: 1, timescale: CMTimeScale(videoTrack.nominalFrameRate))
            videoBitRate = NSNumber(value: videoTrack.estimatedDataRate)
            trackWidth = videoTrack.naturalSize.width
            trackHeight = videoTrack.naturalSize.height
            trackTransform = videoTrack.preferredTransform

            secondReaderVideoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
            if secondPartReader?.canAdd(secondReaderVideoOutput!) ?? false {
                secondPartReader?.add(secondReaderVideoOutput!)
            }
        }
        
        var audioSampleRate: Float64 = 44100
        var audioNumberOfChannels: UInt32 = 2
        var audioNumberOfFrame: Int = 43

        var assetReaderAudioOutput: AVAssetReaderTrackOutput?
        if let audioTrack = firstPartAsset?.tracks(withMediaType: .audio).first {
            audioNumberOfFrame = Int(audioTrack.nominalFrameRate)
            assetReaderAudioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
            if reader?.canAdd(assetReaderAudioOutput!) ?? false {
                reader?.add(assetReaderAudioOutput!)
            }
        }
        var secondReaderAudioOutput: AVAssetReaderTrackOutput?
        if let audioTrack = secondPartAsset?.tracks(withMediaType: .audio).first {
            secondReaderAudioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
            if secondPartReader?.canAdd(secondReaderAudioOutput!) ?? false {
                secondPartReader?.add(secondReaderAudioOutput!)
            }
        }
        
        // Setup Writer
        do {
            writer = try AVAssetWriter(outputURL: fileURL(), fileType: .mov)
        } catch {
            print("AVAssetWriter initialization failed with error : \(error)")
        }
        
        guard let writer = writer else {
            return
        }
        
        let videoSettings: [String: Any] = [
            AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: videoBitRate],
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoHeightKey: trackHeight,
            AVVideoWidthKey: floor(trackWidth / 16) * 16,
            AVVideoScalingModeKey: AVVideoScalingModeResizeAspect
        ]
        let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        videoInput.transform = trackTransform
        if writer.canAdd(videoInput) {
            writer.add(videoInput)
        }
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoInput, sourcePixelBufferAttributes: nil)
        
        let audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: nil)
        if writer.canAdd(audioInput) {
            writer.add(audioInput)
        }
        
        writer.shouldOptimizeForNetworkUse = true
        
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)
        
        reader?.startReading()
        
        let videoInputQueue = DispatchQueue(label: "videoQueue")
        let audioInputQueue = DispatchQueue(label: "audioQueue")
        
        let closeWriter: (() -> Void) = {
            if audioFinished && videoFinished && !self.cancelled {
                writer.finishWriting {
                    completion(self.writer?.outputURL)
                }
            } else if self.cancelled {
                completion(nil)
            }
        }
        
        var isBoomerangReading = false
        var isSecondPartReading = false

        var presentationTime: CMTime = .zero
        
        var boomerangBuffers = [CVPixelBuffer]()
        var isReverseBuffersAdded = false
        var boomerangBufferCount = 0
        
        let firstPartSeconds = firstPartAsset?.duration.seconds ?? 0
        let boomerangSeconds = ((boomerangAsset?.duration.seconds ?? 0)/Double(config.boomerangSpeedScale))*Double(config.boomerangLoopCount)
        let secondPartSeconds = secondPartAsset?.duration.seconds ?? 0
        let totalSeconds = firstPartSeconds + boomerangSeconds + secondPartSeconds
        
        var audioSetup = false
        
        audioInput.requestMediaDataWhenReady(on: audioInputQueue) {
            while audioInput.isReadyForMoreMediaData {
                if let sample = assetReaderAudioOutput?.copyNextSampleBuffer() {
                    if !audioSetup {
                        if let formatDescription = CMSampleBufferGetFormatDescription(sample),
                            let streamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription) {
                            audioSampleRate = streamBasicDescription.pointee.mSampleRate
                            audioNumberOfChannels = streamBasicDescription.pointee.mChannelsPerFrame
                        }
                        audioSetup = true
                    }
                    audioInput.append(sample)
                }
                else {
                    if isSecondPartReading {
                        if let sample = secondReaderAudioOutput?.copyNextSampleBuffer() {
                            if let buffer = sample.setPresentationTimeStamp(presentationTime) {
                                audioInput.append(buffer)
                            }
                        } else {
                            finishAudioWriting()
                            break
                        }
                    } else if isBoomerangReading {
                        if let buffer = CMSampleBuffer.silentAudioBuffer(at: presentationTime, nFrames: audioNumberOfFrame, sampleRate: audioSampleRate, numChannels: audioNumberOfChannels) {
                            audioInput.append(buffer)
                        }
                    }
                }
                
            }
        }
        
        func finishAudioWriting() {
            audioInput.markAsFinished()
            DispatchQueue.main.async {
                audioFinished = true
                closeWriter()
            }
        }
        
        videoInput.requestMediaDataWhenReady(on: videoInputQueue) {
            while videoInput.isReadyForMoreMediaData {
                if let sample = assetReaderVideoOutput?.copyNextSampleBuffer() {
                    autoreleasepool {
                        presentationTime = CMSampleBufferGetPresentationTimeStamp(sample)
                        let buffer = CMSampleBufferGetImageBuffer(sample)!
                        appendPixelBuffer(buffer)
                    }
                } else {
                    if !isBoomerangReading {
                        isBoomerangReading = true
                        self.boomerangReader?.startReading()
                    } else {
                        if !writeBoomerang() {
                            if !isSecondPartReading {
                                isSecondPartReading = true
                                self.secondPartReader?.startReading()
                            } else {
                                if !writeSecondPart() {
                                    finishVideoWriting()
                                    break
                                }
                                
                            }
                        }
                    }
                }
            }
        }
        
        func finishVideoWriting() {
            videoInput.markAsFinished()
            DispatchQueue.main.async {
                videoFinished = true
                closeWriter()
            }
        }
        
        func writeSecondPart() -> Bool {
            if let sample = secondReaderVideoOutput?.copyNextSampleBuffer() {
                autoreleasepool {
                    if let buffer = CMSampleBufferGetImageBuffer(sample) {
                        presentationTime = CMTimeAdd(presentationTime, nextBufferTime)
                        appendPixelBuffer(buffer)
                    }
                }
            } else {
                return false
            }
            return true
        }
        
        func writeBoomerang() -> Bool {
            if let sample = boomerangReaderVideoOutput?.copyNextSampleBuffer() {
                autoreleasepool {
                    let buffer = CMSampleBufferGetImageBuffer(sample)!
                    boomerangBufferCount += 1
                    if boomerangBufferCount % config.boomerangSpeedScale == 0 {
                        boomerangBuffers.append(buffer)
                    }
                }
            } else {
                if !isReverseBuffersAdded {
                    let originBuffers = boomerangBuffers
                    for _ in 0..<((config.boomerangLoopCount - 1)/2) {
                        if config.needToReverse {
                            boomerangBuffers.append(contentsOf: originBuffers.reversed())
                        }
                        boomerangBuffers.append(contentsOf: originBuffers)
                    }
                    isReverseBuffersAdded = true
                }
                if !boomerangBuffers.isEmpty {
                    autoreleasepool {
                        let buffer = boomerangBuffers.remove(at: 0)
                        presentationTime = CMTimeAdd(presentationTime, nextBufferTime)
                        appendPixelBuffer(buffer)
                    }
                } else {
                    return false
                }
            }
            return true
        }
        
        func appendPixelBuffer(_ buffer: CVPixelBuffer) {
            pixelBufferAdaptor.append(buffer,
                                      withPresentationTime: presentationTime)
            let currentProgress = presentationTime.seconds / totalSeconds
            progress?(Float(currentProgress))
        }
        
    }
    
    public func cancelExporting() {
        cancelled = true
        reader?.cancelReading()
        boomerangReader?.cancelReading()
        secondPartReader?.cancelReading()
        writer?.cancelWriting()
    }
    
}
