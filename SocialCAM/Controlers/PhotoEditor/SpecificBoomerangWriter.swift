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
    
    private var firstPartReader: AVAssetReader?
    private var boomerangReader: AVAssetReader?
    private var secondPartReader: AVAssetReader?

    private var writer: AVAssetWriter?
    private var cancelled = false

    private var config: SpecificBoomerangExportConfig
    
    init(config: SpecificBoomerangExportConfig) {
        self.config = config
    }
    
    private func fileURL() -> URL {
        let fileName = "\(UUID().uuidString).mov"
        var documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                        .userDomainMask, true)[0]
        documentDirectoryPath = documentDirectoryPath.appending("/\(fileName)")
        return URL(fileURLWithPath: documentDirectoryPath)
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

        if let asset = firstPartAsset {
            do {
                firstPartReader = try AVAssetReader(asset: asset)
            } catch {
                print("FirstPartReader initialization failed with error : \(error)")
            }
        }
        
        if let asset = boomerangAsset {
            do {
                boomerangReader = try AVAssetReader(asset: asset)
            } catch {
                print("BoomerangReader initialization failed with error : \(error)")
            }
        }
        
        if let asset = secondPartAsset {
            do {
                secondPartReader = try AVAssetReader(asset: asset)
            } catch {
                print("SecondPartReader initialization failed with error : \(error)")
            }
        }

        var nextBufferTime = CMTime(value: 1, timescale: 24)
        var videoBitRate: NSNumber = 2000000
        var trackWidth: CGFloat = 720
        var trackHeight: CGFloat = 1280
        var trackTransform: CGAffineTransform = .identity
        
        let videoReaderSettings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB]
        var firstPartReaderVideoOutput: AVAssetReaderTrackOutput?
        if let videoTrack = firstPartAsset?.tracks(withMediaType: .video).first {
            firstPartReaderVideoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
            if firstPartReader?.canAdd(firstPartReaderVideoOutput!) ?? false {
                firstPartReader?.add(firstPartReaderVideoOutput!)
            }
        }
        var boomerangReaderVideoOutput: AVAssetReaderTrackOutput?
        if let videoTrack = boomerangAsset?.tracks(withMediaType: .video).first {
            nextBufferTime = CMTime(value: 100000, timescale: CMTimeScale(videoTrack.nominalFrameRate)*100000)
            videoBitRate = NSNumber(value: videoTrack.estimatedDataRate)
            trackWidth = videoTrack.naturalSize.width
            trackHeight = videoTrack.naturalSize.height
            trackTransform = videoTrack.preferredTransform
            
            boomerangReaderVideoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
            if boomerangReader?.canAdd(boomerangReaderVideoOutput!) ?? false {
                boomerangReader?.add(boomerangReaderVideoOutput!)
            }
        }
        var secondPartReaderVideoOutput: AVAssetReaderTrackOutput?
        if let videoTrack = secondPartAsset?.tracks(withMediaType: .video).first {
            secondPartReaderVideoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
            if secondPartReader?.canAdd(secondPartReaderVideoOutput!) ?? false {
                secondPartReader?.add(secondPartReaderVideoOutput!)
            }
        }
        
        var audioSampleRate: Float64 = 44100
        var audioNumberOfChannels: UInt32 = 2
        var audioNumberOfFrame: Int = 43
        
        var firstPartReaderAudioOutput: AVAssetReaderTrackOutput?
        if let audioTrack = firstPartAsset?.tracks(withMediaType: .audio).first {
            audioNumberOfFrame = Int(audioTrack.nominalFrameRate)

            firstPartReaderAudioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
            if firstPartReader?.canAdd(firstPartReaderAudioOutput!) ?? false {
                firstPartReader?.add(firstPartReaderAudioOutput!)
            }
        }
        var secondPartReaderAudioOutput: AVAssetReaderTrackOutput?
        if let audioTrack = secondPartAsset?.tracks(withMediaType: .audio).first {
            audioNumberOfFrame = Int(audioTrack.nominalFrameRate)

            secondPartReaderAudioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
            if secondPartReader?.canAdd(secondPartReaderAudioOutput!) ?? false {
                secondPartReader?.add(secondPartReaderAudioOutput!)
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
        
        firstPartReader?.startReading()
        
        let videoInputQueue = DispatchQueue(label: "videoQueue")
        let audioInputQueue = DispatchQueue(label: "audioQueue")
        
        var isAudioSetup = false
        var isBoomerangReading = false
        var isSecondPartReading = false
        var boomerangBuffers = [CVPixelBuffer]()
        var isReverseBuffersAdded = false
        var boomerangBufferCount = 0

        func closeWriter() {
            if audioFinished && videoFinished && !self.cancelled {
                writer.finishWriting {
                    completion(self.writer?.outputURL)
                }
            } else if self.cancelled {
                completion(nil)
            }
        }
        
        let firstPartSeconds = firstPartAsset?.duration.seconds ?? 0
        let boomerangSeconds = ((boomerangAsset?.duration.seconds ?? 0)/Double(config.boomerangSpeedScale))*Double(config.boomerangLoopCount)
        let secondPartSeconds = secondPartAsset?.duration.seconds ?? 0
        let totalSeconds = firstPartSeconds + boomerangSeconds + secondPartSeconds
        var presentationTime = CMTime.zero

        audioInput.requestMediaDataWhenReady(on: audioInputQueue) {
            while audioInput.isReadyForMoreMediaData {
                if let sample = firstPartReaderAudioOutput?.copyNextSampleBuffer() {
                    if !isAudioSetup {
                        if let formatDescription = CMSampleBufferGetFormatDescription(sample),
                            let streamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription) {
                            audioSampleRate = streamBasicDescription.pointee.mSampleRate
                            audioNumberOfChannels = streamBasicDescription.pointee.mChannelsPerFrame
                            isAudioSetup = true
                        }
                    }
                    audioInput.append(sample)
                } else {
                    if isSecondPartReading {
                        if let sample = secondPartReaderAudioOutput?.copyNextSampleBuffer()?.setPresentationTimeStamp(presentationTime) {
                            if !isAudioSetup {
                                if let formatDescription = CMSampleBufferGetFormatDescription(sample),
                                    let streamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription) {
                                    audioSampleRate = streamBasicDescription.pointee.mSampleRate
                                    audioNumberOfChannels = streamBasicDescription.pointee.mChannelsPerFrame
                                    isAudioSetup = true
                                }
                            }
                            audioInput.append(sample)
                        } else {
                            audioInput.markAsFinished()
                            DispatchQueue.main.async {
                                audioFinished = true
                                closeWriter()
                            }
                            break
                        }
                    } else if isBoomerangReading {
                        if let sample = CMSampleBuffer.silentAudioBuffer(at: presentationTime, nFrames: audioNumberOfFrame, sampleRate: audioSampleRate, numChannels: audioNumberOfChannels) {
                            audioInput.append(sample)
                        }
                    }
                }
            }
        }
        
        videoInput.requestMediaDataWhenReady(on: videoInputQueue) {
            while videoInput.isReadyForMoreMediaData {
                if let sample = firstPartReaderVideoOutput?.copyNextSampleBuffer() {
                    autoreleasepool {
                        let buffer = CMSampleBufferGetImageBuffer(sample)!
                        presentationTime = CMSampleBufferGetPresentationTimeStamp(sample)
                        pixelBufferAdaptor.append(buffer,
                                                  withPresentationTime: presentationTime)
                        
                        let currentProgress = presentationTime.seconds / totalSeconds
                        progress?(Float(currentProgress))
                    }
                } else if !isBoomerangReading {
                    self.boomerangReader?.startReading()
                    isBoomerangReading = true
                } else {
                    if let sample = boomerangReaderVideoOutput?.copyNextSampleBuffer() {
                        autoreleasepool {
                            let buffer = CMSampleBufferGetImageBuffer(sample)!
                            boomerangBufferCount += 1
                            if boomerangBufferCount % self.config.boomerangSpeedScale == 0 {
                                boomerangBuffers.append(buffer)
                            }
                        }
                    } else {
                        if !isReverseBuffersAdded {
                            let originBuffers = boomerangBuffers
                            for _ in 0..<((self.config.boomerangLoopCount - 1)/2) {
                                if self.config.needToReverse {
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
                                pixelBufferAdaptor.append(buffer,
                                                          withPresentationTime: presentationTime)
                                
                                let currentProgress = presentationTime.seconds / totalSeconds
                                progress?(Float(currentProgress))
                            }
                        } else {
                            if !isSecondPartReading {
                                self.secondPartReader?.startReading()
                                isSecondPartReading = true
                            } else {
                                if let sample = secondPartReaderVideoOutput?.copyNextSampleBuffer() {
                                    autoreleasepool {
                                        let buffer = CMSampleBufferGetImageBuffer(sample)!
                                        presentationTime = CMTimeAdd(presentationTime, nextBufferTime)
                                        pixelBufferAdaptor.append(buffer,
                                                                  withPresentationTime: presentationTime)
                                        
                                        let currentProgress = presentationTime.seconds / totalSeconds
                                        progress?(Float(currentProgress))
                                    }
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
            }
        }
    }
    
    public func cancelExporting() {
        cancelled = true
        firstPartReader?.cancelReading()
        boomerangReader?.cancelReading()
        secondPartReader?.cancelReading()
        writer?.cancelWriting()
    }
    
}
