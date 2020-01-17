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
    
    var firstBoomerangRange: CMTimeRange
    var secondBoomerangRange: CMTimeRange?
    var boomerangSpeedScale: Int
    var boomerangLoopCount: Int
    var needToReverse: Bool

    init(firstBoomerangRange: CMTimeRange, secondBoomerangRange: CMTimeRange? = nil, boomerangSpeedScale: Int, boomerangLoopCount: Int, needToReverse: Bool) {
        self.firstBoomerangRange = firstBoomerangRange
        self.secondBoomerangRange = secondBoomerangRange
        self.boomerangSpeedScale = boomerangSpeedScale
        self.boomerangLoopCount = boomerangLoopCount
        self.needToReverse = needToReverse
    }
}

class SpecificBoomerangExportSession {
    
    private var firstReader: AVAssetReader?
    private var firstBoomerangReader: AVAssetReader?
    private var secondReader: AVAssetReader?
    private var secondBoomerangReader: AVAssetReader?
    private var thirdReader: AVAssetReader?

    private var writer: AVAssetWriter?
    private var cancelled = false

    private var config: SpecificBoomerangExportConfig
    
    private let videoInputQueue = DispatchQueue(label: "videoQueue")
    private let audioInputQueue = DispatchQueue(label: "audioQueue")
    
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
                
        var firstAsset: AVAsset?
        var firstBoomerangAsset: AVAsset?
        var secondAsset: AVAsset?
        var secondBoomerangAsset: AVAsset?
        var thirdAsset: AVAsset?

        firstAsset = try? asset.assetByTrimming(startTime: .zero, endTime: config.firstBoomerangRange.start)
        firstBoomerangAsset = try? asset.assetByTrimming(startTime: config.firstBoomerangRange.start, endTime: config.firstBoomerangRange.end)
        if let secondBoomerangRange = config.secondBoomerangRange {
            secondAsset = try? asset.assetByTrimming(startTime: config.firstBoomerangRange.end, endTime: secondBoomerangRange.start)
            secondBoomerangAsset = try? asset.assetByTrimming(startTime: secondBoomerangRange.start, endTime: secondBoomerangRange.end)
            thirdAsset = try? asset.assetByTrimming(startTime: secondBoomerangRange.end, endTime: asset.duration)
        } else {
            secondAsset = try? asset.assetByTrimming(startTime: config.firstBoomerangRange.end, endTime: asset.duration)
        }
        
        if let firstAsset = firstAsset {
            // Setup Reader
            do {
                firstReader = try AVAssetReader(asset: firstAsset)
            } catch {
                print("AVAssetReader initialization failed with error : \(error)")
            }
        }
        if let firstBoomerangAsset = firstBoomerangAsset {
            // Setup Reader
            do {
                firstBoomerangReader = try AVAssetReader(asset: firstBoomerangAsset)
            } catch {
                print("AVAssetReader initialization failed with error : \(error)")
            }
        }
        if let secondAsset = secondAsset {
            // Setup Reader
            do {
                secondReader = try AVAssetReader(asset: secondAsset)
            } catch {
                print("AVAssetReader initialization failed with error : \(error)")
            }
        }
        if let secondBoomerangAsset = secondBoomerangAsset {
            // Setup Reader
            do {
                secondBoomerangReader = try AVAssetReader(asset: secondBoomerangAsset)
            } catch {
                print("AVAssetReader initialization failed with error : \(error)")
            }
        }
        if let thirdAsset = thirdAsset {
            // Setup Reader
            do {
                thirdReader = try AVAssetReader(asset: thirdAsset)
            } catch {
                print("AVAssetReader initialization failed with error : \(error)")
            }
        }
        
        var nextBufferTime = CMTime(value: 1, timescale: 24)
        var videoBitRate: NSNumber = 2000000
        var trackWidth: CGFloat = 720
        var trackHeight: CGFloat = 1280
        var trackTransform: CGAffineTransform = .identity

        var audioSampleRate: Float64 = 44100
        var audioNumberOfChannels: UInt32 = 2
        var audioNumberOfFrame: Int = 43
        
        func assetReaderTrackOutput(for avAsset: AVAsset?, type: AVMediaType, outputSettings: [String: Any]?,  reader: AVAssetReader?) -> AVAssetReaderTrackOutput? {
            guard let avAssetTrack = avAsset?.tracks(withMediaType: type).first else {
                return nil
            }
            if type == .video {
                nextBufferTime = CMTime(value: 1, timescale: CMTimeScale(avAssetTrack.nominalFrameRate))
                videoBitRate = NSNumber(value: avAssetTrack.estimatedDataRate)
                trackWidth = avAssetTrack.naturalSize.width
                trackHeight = avAssetTrack.naturalSize.height
                trackTransform = avAssetTrack.preferredTransform
            } else if type == .audio {
                audioNumberOfFrame = Int(avAssetTrack.nominalFrameRate)
            }
            let assetReaderTrackOutput = AVAssetReaderTrackOutput(track: avAssetTrack, outputSettings: outputSettings)
            if reader?.canAdd(assetReaderTrackOutput) ?? false {
                reader?.add(assetReaderTrackOutput)
            }
            return assetReaderTrackOutput
        }

        let videoReaderSettings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB]
        
        let firstVideoOutput = assetReaderTrackOutput(for: firstAsset,
                                                      type: .video,
                                                      outputSettings: videoReaderSettings,
                                                      reader: firstReader)
        
        let firstBoomerangVideoOutput = assetReaderTrackOutput(for: firstBoomerangAsset,
                                                               type: .video,
                                                               outputSettings: videoReaderSettings,
                                                               reader: firstBoomerangReader)
        
        let secondVideoOutput = assetReaderTrackOutput(for: secondAsset,
                                                       type: .video,
                                                       outputSettings: videoReaderSettings,
                                                       reader: secondReader)
        
        let secondBoomerangVideoOutput = assetReaderTrackOutput(for: secondBoomerangAsset,
                                                                type: .video,
                                                                outputSettings: videoReaderSettings,
                                                                reader: secondBoomerangReader)

        let thirdVideoOutput = assetReaderTrackOutput(for: thirdAsset,
                                                      type: .video,
                                                      outputSettings: videoReaderSettings,
                                                      reader: thirdReader)
        
        let firstAudioOutput = assetReaderTrackOutput(for: firstAsset,
                                                      type: .audio,
                                                      outputSettings: nil,
                                                      reader: firstReader)
                
        let secondAudioOutput = assetReaderTrackOutput(for: secondAsset,
                                                       type: .audio,
                                                       outputSettings: nil,
                                                       reader: secondReader)
        
        let thirdAudioOutput = assetReaderTrackOutput(for: thirdAsset,
                                                      type: .audio,
                                                      outputSettings: nil,
                                                      reader: thirdReader)
        
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
        
        firstReader?.startReading()
                
        let closeWriter: (() -> Void) = {
            if audioFinished && videoFinished && !self.cancelled {
                writer.finishWriting {
                    completion(self.writer?.outputURL)
                }
            } else if self.cancelled {
                completion(nil)
            }
        }
        
        var isFirstBoomerangReading = false
        var isSecondPartReading = false
        var isSecondBoomerangReading = false
        var isThirdPartReading = false

        var presentationTime: CMTime = .zero
        
        var boomerangBuffers = [CVPixelBuffer]()
        var isReverseBuffersAdded = false
        var secondBoomerangBuffers = [CVPixelBuffer]()
        var isSecondReverseBuffersAdded = false
        var boomerangBufferCount = 0
        
        let firstPartSeconds = firstAsset?.duration.seconds ?? 0
        
        var firstBoomerangPartSeconds = ((firstBoomerangAsset?.duration.seconds ?? 0)/Double(config.boomerangSpeedScale))*Double(config.boomerangLoopCount)
        if !config.needToReverse {
            firstBoomerangPartSeconds = ((firstBoomerangAsset?.duration.seconds ?? 0)/Double(config.boomerangSpeedScale))*Double((config.boomerangLoopCount+1)/2)
        }
        
        let secondPartSeconds = secondAsset?.duration.seconds ?? 0
        
        var secondBoomerangPartSeconds = ((secondBoomerangAsset?.duration.seconds ?? 0)/Double(config.boomerangSpeedScale))*Double(config.boomerangLoopCount)
        if !config.needToReverse {
            secondBoomerangPartSeconds = ((secondBoomerangAsset?.duration.seconds ?? 0)/Double(config.boomerangSpeedScale))*Double((config.boomerangLoopCount+1)/2)
        }
        let thirdPartSeconds = thirdAsset?.duration.seconds ?? 0
        
        let totalSeconds = firstPartSeconds + firstBoomerangPartSeconds + secondPartSeconds + secondBoomerangPartSeconds + thirdPartSeconds
        
        var audioSetup = false
        
        func setAudioSettingsIfNeeded(_ sampleBuffer: CMSampleBuffer) {
            guard !audioSetup else {
                return
            }
            if let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer),
                let streamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription) {
                audioSampleRate = streamBasicDescription.pointee.mSampleRate
                audioNumberOfChannels = streamBasicDescription.pointee.mChannelsPerFrame
                audioSetup = true
            }
        }
        
        audioInput.requestMediaDataWhenReady(on: audioInputQueue) {
            while audioInput.isReadyForMoreMediaData {
                if let sample = firstAudioOutput?.copyNextSampleBuffer() {
                    setAudioSettingsIfNeeded(sample)
                    audioInput.append(sample)
                }
                else {
                    if isThirdPartReading {
                        if let sample = thirdAudioOutput?.copyNextSampleBuffer() {
                            setAudioSettingsIfNeeded(sample)
                            if let buffer = sample.setPresentationTimeStamp(presentationTime) {
                                audioInput.append(buffer)
                            }
                        } else {
                            finishAudioWriting()
                            break
                        }
                    } else if isSecondBoomerangReading {
                        if let buffer = CMSampleBuffer.silentAudioBuffer(at: presentationTime, nFrames: audioNumberOfFrame, sampleRate: audioSampleRate, numChannels: audioNumberOfChannels) {
                            audioInput.append(buffer)
                        }
                    } else if isSecondPartReading {
                        if let sample = secondAudioOutput?.copyNextSampleBuffer() {
                            setAudioSettingsIfNeeded(sample)
                            if let buffer = sample.setPresentationTimeStamp(presentationTime) {
                                audioInput.append(buffer)
                            }
                        }
                    } else if isFirstBoomerangReading {
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
                if let sample = firstVideoOutput?.copyNextSampleBuffer() {
                    autoreleasepool {
                        presentationTime = CMSampleBufferGetPresentationTimeStamp(sample)
                        let buffer = CMSampleBufferGetImageBuffer(sample)!
                        appendPixelBuffer(buffer)
                    }
                } else {
                    if !isFirstBoomerangReading {
                        isFirstBoomerangReading = true
                        self.firstBoomerangReader?.startReading()
                    } else {
                        if !writeFirstBoomerang() {
                            if !isSecondPartReading {
                                isSecondPartReading = true
                                self.secondReader?.startReading()
                            } else {
                                if !writeSecondPart(for: secondVideoOutput) {
                                    if !isSecondBoomerangReading {
                                        isSecondBoomerangReading = true
                                        self.secondBoomerangReader?.startReading()
                                    } else {
                                        if !writeSecondBoomerang() {
                                            if !isThirdPartReading {
                                                isThirdPartReading = true
                                                self.thirdReader?.startReading()
                                            } else {
                                                if !writeSecondPart(for: thirdVideoOutput) {
                                                    finishVideoWriting()
                                                    break
                                                }
                                                
                                            }
                                        }
                                    }
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
        
        func writeSecondPart(for readerVideoOutput: AVAssetReaderTrackOutput?) -> Bool {
            if let sample = readerVideoOutput?.copyNextSampleBuffer() {
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
        
        func writeFirstBoomerang() -> Bool {
            guard let readerVideoOutput = firstBoomerangVideoOutput else {
                return false
            }
            if let sample = readerVideoOutput.copyNextSampleBuffer() {
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
        
        func writeSecondBoomerang() -> Bool {
            guard let readerVideoOutput = secondBoomerangVideoOutput else {
                return false
            }
            if let sample = readerVideoOutput.copyNextSampleBuffer() {
                autoreleasepool {
                    let buffer = CMSampleBufferGetImageBuffer(sample)!
                    boomerangBufferCount += 1
                    if boomerangBufferCount % config.boomerangSpeedScale == 0 {
                        secondBoomerangBuffers.append(buffer)
                    }
                }
            } else {
                if !isSecondReverseBuffersAdded {
                    let originBuffers = secondBoomerangBuffers
                    for _ in 0..<((config.boomerangLoopCount - 1)/2) {
                        if config.needToReverse {
                            secondBoomerangBuffers.append(contentsOf: originBuffers.reversed())
                        }
                        secondBoomerangBuffers.append(contentsOf: originBuffers)
                    }
                    isSecondReverseBuffersAdded = true
                }
                if !secondBoomerangBuffers.isEmpty {
                    autoreleasepool {
                        let buffer = secondBoomerangBuffers.remove(at: 0)
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
        videoInputQueue.async {
            self.firstReader?.cancelReading()
            self.firstBoomerangReader?.cancelReading()
            self.secondReader?.cancelReading()
            self.secondBoomerangReader?.cancelReading()
            self.thirdReader?.cancelReading()
            self.writer?.cancelWriting()
        }
    }
    
}
