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
    
    init(firstBoomerangRange: CMTimeRange, secondBoomerangRange: CMTimeRange?, boomerangSpeedScale: Int, boomerangLoopCount: Int, needToReverse: Bool) {
        self.firstBoomerangRange = firstBoomerangRange
        self.secondBoomerangRange = secondBoomerangRange
        self.boomerangSpeedScale = boomerangSpeedScale
        self.boomerangLoopCount = boomerangLoopCount
        self.needToReverse = needToReverse
    }

}

class SpecificBoomerangExportSession {
    
    private var firstPartReader: AVAssetReader?
    private var boomerangReader: AVAssetReader?
    private var secondPartReader: AVAssetReader?
    private var secondBoomerangReader: AVAssetReader?
    private var thirdPartReader: AVAssetReader?

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
    
    private func reader(for asset: AVAsset?) -> AVAssetReader? {
        guard let asset = asset else {
            return nil
        }
        do {
            return try AVAssetReader(asset: asset)
        } catch {
            print("Reader initialization failed with error : \(error.localizedDescription)")
        }
        return nil
    }
    
    public func export(for asset: AVAsset, progress: ((Float) -> Void)? = nil, completion: @escaping (URL?) -> Void) {
        cancelled = false
        var audioFinished = false
        var videoFinished = false
        
        var firstPartAsset: AVAsset?
        var boomerangAsset: AVAsset?
        var secondPartAsset: AVAsset?
        var secondBoomerangAsset: AVAsset?
        var thirdPartAsset: AVAsset?

        firstPartAsset = try? asset.assetByTrimming(startTime: .zero, endTime: config.firstBoomerangRange.start)
        boomerangAsset = try? asset.assetByTrimming(startTime: config.firstBoomerangRange.start, endTime: config.firstBoomerangRange.end)
        if let secondBoomerangRange = config.secondBoomerangRange {
            secondPartAsset = try? asset.assetByTrimming(startTime: config.firstBoomerangRange.end, endTime: secondBoomerangRange.start)
            secondBoomerangAsset = try? asset.assetByTrimming(startTime: secondBoomerangRange.start, endTime: secondBoomerangRange.end)
            thirdPartAsset = try? asset.assetByTrimming(startTime: secondBoomerangRange.end, endTime: asset.duration)
        } else {
            secondPartAsset = try? asset.assetByTrimming(startTime: config.firstBoomerangRange.end, endTime: asset.duration)
        }

        firstPartReader = reader(for: firstPartAsset)
        
        boomerangReader = reader(for: boomerangAsset)
        
        secondPartReader = reader(for: secondPartAsset)
        
        secondBoomerangReader = reader(for: secondBoomerangAsset)
        
        thirdPartReader = reader(for: thirdPartAsset)

        var nextBufferTime = CMTime(value: 1, timescale: 24)
        var videoBitRate: NSNumber = 2000000
        var trackWidth: CGFloat = 720
        var trackHeight: CGFloat = 1280
        var trackTransform: CGAffineTransform = .identity
        
        func videoAssetReaderTrackOutput(for asset: AVAsset?, reader: AVAssetReader?, videoSetup: Bool = false) -> AVAssetReaderTrackOutput? {
            guard let videoTrack = asset?.tracks(withMediaType: .video).first else {
                return nil
            }
            if videoSetup {
                nextBufferTime = CMTime(value: 100000, timescale: CMTimeScale(videoTrack.nominalFrameRate)*100000)
                videoBitRate = NSNumber(value: videoTrack.estimatedDataRate)
                trackWidth = videoTrack.naturalSize.width
                trackHeight = videoTrack.naturalSize.height
                trackTransform = videoTrack.preferredTransform
            }
            let videoReaderSettings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB]
            let assetReaderTrackOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
            if reader?.canAdd(assetReaderTrackOutput) ?? false {
                reader?.add(assetReaderTrackOutput)
            }
            return assetReaderTrackOutput
        }
        
        let firstPartReaderVideoOutput = videoAssetReaderTrackOutput(for: firstPartAsset,
                                                                     reader: firstPartReader)
        
        let boomerangReaderVideoOutput = videoAssetReaderTrackOutput(for: boomerangAsset,
                                                                     reader: boomerangReader,
                                                                     videoSetup: true)
        
        let secondPartReaderVideoOutput = videoAssetReaderTrackOutput(for: secondPartAsset,
                                                                      reader: secondPartReader)
        
        let secondBoomerangReaderVideoOutput = videoAssetReaderTrackOutput(for: secondBoomerangAsset,
                                                                           reader: secondBoomerangReader)
        let thirdPartReaderVideoOutput = videoAssetReaderTrackOutput(for: thirdPartAsset,
                                                                     reader: thirdPartReader)
        
        var audioSampleRate: Float64 = 44100
        var audioNumberOfChannels: UInt32 = 2
        var audioNumberOfFrame: Int = 43
        
        func audioAssetReaderTrackOutput(for asset: AVAsset?, reader: AVAssetReader?, audioSetup: Bool = false) -> AVAssetReaderTrackOutput? {
            guard let audioTrack = asset?.tracks(withMediaType: .audio).first else {
                return nil
            }
            audioNumberOfFrame = Int(audioTrack.nominalFrameRate)
            let assetReaderTrackOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
            if reader?.canAdd(assetReaderTrackOutput) ?? false {
                reader?.add(assetReaderTrackOutput)
            }
            return assetReaderTrackOutput
        }
        
        let firstPartReaderAudioOutput = audioAssetReaderTrackOutput(for: firstPartAsset,
                                                                     reader: firstPartReader)
        let secondPartReaderAudioOutput = audioAssetReaderTrackOutput(for: secondPartAsset,
                                                                      reader: secondPartReader)
        let thirdPartReaderAudioOutput = audioAssetReaderTrackOutput(for: thirdPartAsset,
                                                                     reader: thirdPartReader)

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
        videoInput.expectsMediaDataInRealTime = true
        
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
        var isSecondBoomerangReading = false
        var isThirdPartReading = false

        var boomerangBuffers = [CVPixelBuffer]()
        var isReverseBuffersAdded = false
        var boomerangBufferCount = 0

        var secondBoomerangBuffers = [CVPixelBuffer]()
        var isSecondReverseBuffersAdded = false
        var secondBoomerangBufferCount = 0

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
        var boomerangSeconds = ((boomerangAsset?.duration.seconds ?? 0)/Double(config.boomerangSpeedScale))*Double(config.boomerangLoopCount)
        if !config.needToReverse {
            boomerangSeconds = ((boomerangAsset?.duration.seconds ?? 0)/Double(config.boomerangSpeedScale))*Double((config.boomerangLoopCount+1)/2)
        }
        let secondPartSeconds = secondPartAsset?.duration.seconds ?? 0
        var secondBoomerangSeconds = ((secondBoomerangAsset?.duration.seconds ?? 0)/Double(config.boomerangSpeedScale))*Double(config.boomerangLoopCount)
        if !config.needToReverse {
            secondBoomerangSeconds = ((secondBoomerangAsset?.duration.seconds ?? 0)/Double(config.boomerangSpeedScale))*Double((config.boomerangLoopCount+1)/2)
        }
        let thirdPartSeconds = thirdPartAsset?.duration.seconds ?? 0

        let totalSeconds = firstPartSeconds + boomerangSeconds + secondPartSeconds + secondBoomerangSeconds + thirdPartSeconds
        var presentationTime = CMTime.zero

        func writeAudio(for assetReaderTrackOutput: AVAssetReaderTrackOutput?) -> Bool {
            guard var sample = assetReaderTrackOutput?.copyNextSampleBuffer() else {
                return false
            }
            if !isAudioSetup {
                if let formatDescription = CMSampleBufferGetFormatDescription(sample),
                    let streamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription) {
                    audioSampleRate = streamBasicDescription.pointee.mSampleRate
                    audioNumberOfChannels = streamBasicDescription.pointee.mChannelsPerFrame
                    isAudioSetup = true
                    print("audio setup..")
                }
            }
            if isThirdPartReading || isSecondPartReading {
                sample = sample.setPresentationTimeStamp(presentationTime)!
            }
            return audioInput.append(sample)
        }
        
        func writeSilentAudio() -> Bool {
            guard let sample = CMSampleBuffer.silentAudioBuffer(at: presentationTime, nFrames: audioNumberOfFrame, sampleRate: audioSampleRate, numChannels: audioNumberOfChannels) else {
                return false
            }
            return audioInput.append(sample)
        }
        
        audioInput.requestMediaDataWhenReady(on: audioInputQueue) {
            while audioInput.isReadyForMoreMediaData {
                if writeAudio(for: firstPartReaderAudioOutput) {
                    print("audio first part writing..")
                } else {
                    if isThirdPartReading {
                        if writeAudio(for: thirdPartReaderAudioOutput) {
                            print("third part audio writing..")
                        } else {
                            print("finish audio writing..")
                            audioInput.markAsFinished()
                            DispatchQueue.main.async {
                                audioFinished = true
                                closeWriter()
                            }
                            break
                        }
                    } else if isSecondBoomerangReading {
                        if writeSilentAudio() {
                            print("audio boomerang writing..")
                        }
                    } else if isSecondPartReading {
                        if writeAudio(for: secondPartReaderAudioOutput) {
                            print("second part writing..")
                        }
                    } else if isBoomerangReading {
                        if writeSilentAudio() {
                            print("audio boomerang writing..")
                        }
                    }
                }
            }
        }
        
        func writeVideo(for assetReaderTrackOutput: AVAssetReaderTrackOutput?) -> Bool {
            guard let sample = assetReaderTrackOutput?.copyNextSampleBuffer() else {
                return false
            }
            return autoreleasepool { () -> Bool in
                let buffer = CMSampleBufferGetImageBuffer(sample)!
                if isBoomerangReading {
                    presentationTime = CMTimeAdd(presentationTime, nextBufferTime)
                } else {
                    presentationTime = CMSampleBufferGetPresentationTimeStamp(sample)
                }
                let currentProgress = presentationTime.seconds / totalSeconds
                progress?(Float(currentProgress))
                return pixelBufferAdaptor.append(buffer,
                                                 withPresentationTime: presentationTime)
            }

        }
        
        func writeBoomerang(isSecondBoomerang: Bool) -> Bool {
            let isEmpty = isSecondBoomerang ? secondBoomerangBuffers.isEmpty : boomerangBuffers.isEmpty
            guard !isEmpty else {
                return false
            }
            return autoreleasepool { () -> Bool in
                let buffer = isSecondBoomerang ? secondBoomerangBuffers.remove(at: 0) : boomerangBuffers.remove(at: 0)
                presentationTime = CMTimeAdd(presentationTime, nextBufferTime)
                let currentProgress = presentationTime.seconds / totalSeconds
                progress?(Float(currentProgress))
                return pixelBufferAdaptor.append(buffer,
                                          withPresentationTime: presentationTime)
            }
        }
        
        func addBoomerangBuffer(for assetReaderTrackOutput: AVAssetReaderTrackOutput?, isSecondBoomerang: Bool) -> Bool {
            guard let sample = assetReaderTrackOutput?.copyNextSampleBuffer() else {
                return false
            }
            return autoreleasepool { () -> Bool in
                let buffer = CMSampleBufferGetImageBuffer(sample)!
                if isSecondBoomerang {
                    let buffer = CMSampleBufferGetImageBuffer(sample)!
                    secondBoomerangBufferCount += 1
                    if secondBoomerangBufferCount % self.config.boomerangSpeedScale == 0 {
                        secondBoomerangBuffers.append(buffer)
                    }
                } else {
                    boomerangBufferCount += 1
                    if boomerangBufferCount % self.config.boomerangSpeedScale == 0 {
                        boomerangBuffers.append(buffer)
                    }
                }
                return true
            }
        }
        
        func addReverseBuffers(_ buffers: [CVPixelBuffer]) -> [CVPixelBuffer] {
            var reversedBuffers = buffers
            let originBuffers = reversedBuffers
            for _ in 0..<((self.config.boomerangLoopCount - 1)/2) {
                if self.config.needToReverse {
                    reversedBuffers.append(contentsOf: originBuffers.reversed())
                }
                reversedBuffers.append(contentsOf: originBuffers)
            }
            return reversedBuffers
        }
        
        videoInput.requestMediaDataWhenReady(on: videoInputQueue) {
            while videoInput.isReadyForMoreMediaData {
                if writeVideo(for: firstPartReaderVideoOutput) {
                    print("first part writing..")
                } else if !isBoomerangReading {
                    print("start boomerang reading.")
                    self.boomerangReader?.startReading()
                    isBoomerangReading = true
                } else {
                    if addBoomerangBuffer(for: boomerangReaderVideoOutput,
                                          isSecondBoomerang: false) {
                        print("boomerang buffers append..")
                    } else {
                        if !isReverseBuffersAdded {
                            boomerangBuffers = addReverseBuffers(boomerangBuffers)
                            isReverseBuffersAdded = true
                            print("reverse boomerang buffers append..")
                        }
                        if writeBoomerang(isSecondBoomerang: false) {
                            print("boomerang writing..")
                        } else {
                            if !isSecondPartReading {
                                print("start second part reading.")
                                self.secondPartReader?.startReading()
                                isSecondPartReading = true
                            } else {
                                if writeVideo(for: secondPartReaderVideoOutput) {
                                    print("second part writing..")
                                } else {
                                    if !isSecondBoomerangReading {
                                        print("start second boomerang reading.")
                                        self.secondBoomerangReader?.startReading()
                                        isSecondBoomerangReading = true
                                    } else {
                                        if addBoomerangBuffer(for: secondBoomerangReaderVideoOutput,
                                                              isSecondBoomerang: true) {
                                            print("second boomerang buffers append..")
                                        } else {
                                            if !isSecondReverseBuffersAdded {
                                                secondBoomerangBuffers = addReverseBuffers(secondBoomerangBuffers)
                                                isSecondReverseBuffersAdded = true
                                                print("reverse second boomerang buffers append..")
                                            }
                                            if writeBoomerang(isSecondBoomerang: true) {
                                                print("second boomerang writing..")
                                            } else {
                                                if !isThirdPartReading {
                                                    print("start third part reading.")
                                                    self.thirdPartReader?.startReading()
                                                    isThirdPartReading = true
                                                } else {
                                                    if writeVideo(for: thirdPartReaderVideoOutput) {
                                                        print("third part writing..")
                                                    } else {
                                                        print("finish video writing..")
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
