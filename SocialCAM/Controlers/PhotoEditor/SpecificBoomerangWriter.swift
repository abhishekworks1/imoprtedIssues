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

class SpecificBoomerangValue {
    var timeRange: CMTimeRange
    var maxTime: Double
    var speedScale: Int
    var currentLoopCount: Int
    var maxLoopCount: Int
    var needToReverse: Bool
    var needToChangeScale = false
    var isSelected = false {
        didSet {
            let borderColor = isSelected ? R.color.quetag_darkPastelGreen() : R.color.storytag_fadedRed()
            boomerangView.layer.borderColor = borderColor?.cgColor
        }
    }
    var boomerangView: UIView
    var isRunning = false
    
    init(timeRange: CMTimeRange, maxTime: Double, speedScale: Int, currentLoopCount: Int, maxLoopCount: Int, needToReverse: Bool, boomerangView: UIView) {
        self.timeRange = timeRange
        self.maxTime = maxTime
        self.speedScale = speedScale
        self.currentLoopCount = currentLoopCount
        self.maxLoopCount = maxLoopCount
        self.needToReverse = needToReverse
        self.boomerangView = boomerangView
    }
    
    func reset() {
        currentLoopCount = maxLoopCount
        needToChangeScale = false
        isRunning = false
    }
    
    func updateTimeRange(for avAsset: AVAsset, boundsWidth: CGFloat) {
        let frame = boomerangView.frame
        guard frame.width > 0 else {
            timeRange = .zero
            return
        }
        let totalSeconds = avAsset.duration.seconds
        
        let startSeconds = Double(frame.origin.x)*totalSeconds/Double(boundsWidth)
        let startTime = CMTime(value: CMTimeValue(startSeconds*100000), timescale: 100000)

        let endSeconds = startSeconds + maxTime
        let endTime = CMTime(value: CMTimeValue(endSeconds*100000), timescale: 100000)
        
        timeRange = CMTimeRange(start: startTime, end: endTime)
    }
    
    func updateBoomerangViewSize(duration: Double, durationSize: CGFloat) {
        boomerangView.frame.size.width = CGFloat(maxTime)*durationSize / CGFloat(duration)
    }
    
    class func defaultInit() -> SpecificBoomerangValue {
        return SpecificBoomerangValue(timeRange: .zero,
                                      maxTime: 3.0,
                                      speedScale: 2,
                                      currentLoopCount: 7,
                                      maxLoopCount: 7,
                                      needToReverse: true,
                                      boomerangView: boomerangView())
    }
    
    class func boomerangView() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 3
        view.layer.borderColor = R.color.quetag_darkPastelGreen()?.cgColor
        return view
    }
    
}

class MediaTrackData {
    var nextBufferTime: CMTime = CMTime(value: 1, timescale: 24)
    var bitRate: NSNumber = 20000
    var width: CGFloat = 720
    var height: CGFloat = 1080
    var preferredTransform: CGAffineTransform = .identity
    var audioNumberOfFrame: Int = 43
}

class SpecificBoomerangData {
    
    var maxTime: Double
    var speedScale: Int
    var maxLoopCount: Int
    var needToReverse: Bool
    
    init(maxTime: Double, speedScale: Int, maxLoopCount: Int, needToReverse: Bool) {
        self.maxTime = maxTime
        self.speedScale = speedScale
        self.maxLoopCount = maxLoopCount
        self.needToReverse = needToReverse
    }
}

class SpecificBoomerangAsset {
    
    var asset: AVAsset
    var reader: AVAssetReader
    var isBoomerang: Bool = false
    var boomerangData: SpecificBoomerangData?
    var boomerangBuffers = [CVPixelBuffer]()
    var isReverseBuffersAdded = false
    var boomerangBufferCount = 0
    var endTime: CMTime = .zero
    var videoAssetReaderTrackOutput: AVAssetReaderTrackOutput?
    var audioAssetReaderTrackOutput: AVAssetReaderTrackOutput?
    var mediaTrackData: MediaTrackData?
    var isReading: Bool = false
    var canAddAudioBuffers: Bool = true
    var canAddVideoBuffers: Bool = true
    var seconds: Double {
        if let boomerangData = self.boomerangData, isBoomerang {
            var boomerangSeconds = (asset.duration.seconds/Double(boomerangData.speedScale))*Double(boomerangData.maxLoopCount)
            if !boomerangData.needToReverse {
                boomerangSeconds = (asset.duration.seconds/Double(boomerangData.speedScale))*Double((boomerangData.maxLoopCount+1)/2)
            }
            return boomerangSeconds
        }
        return asset.duration.seconds
    }
    
    init(asset: AVAsset, reader: AVAssetReader) {
        self.asset = asset
        self.reader = reader
        setupAssetReaderTrackOutput()
    }
    
    func setupAssetReaderTrackOutput() {
        if let videoTrack = asset.tracks(withMediaType: .video).first {
            if mediaTrackData == nil {
                mediaTrackData = MediaTrackData()
                mediaTrackData?.nextBufferTime = CMTime(value: 100000, timescale: CMTimeScale(videoTrack.nominalFrameRate)*100000)
                mediaTrackData?.bitRate = NSNumber(value: videoTrack.estimatedDataRate)
                mediaTrackData?.width = videoTrack.naturalSize.width
                mediaTrackData?.height = videoTrack.naturalSize.height
                mediaTrackData?.preferredTransform = videoTrack.preferredTransform
            }
            let videoReaderSettings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB]
            videoAssetReaderTrackOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
            if reader.canAdd(videoAssetReaderTrackOutput!) {
                reader.add(videoAssetReaderTrackOutput!)
            }
        }
        if let audioTrack = asset.tracks(withMediaType: .audio).first {
            mediaTrackData?.audioNumberOfFrame = Int(audioTrack.nominalFrameRate)
            audioAssetReaderTrackOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
            if reader.canAdd(audioAssetReaderTrackOutput!) {
                reader.add(audioAssetReaderTrackOutput!)
            }
        }
    }
    
    class func createSpecificBoomerangAsset(asset: AVAsset, timeRange: CMTimeRange, isBoomerang: Bool) -> SpecificBoomerangAsset? {
        guard let asset = try? asset.assetByTrimming(startTime: timeRange.start, endTime: timeRange.end), let reader = try? AVAssetReader(asset: asset) else {
            return nil
        }
        let specificBoomerangAsset = SpecificBoomerangAsset(asset: asset, reader: reader)
        specificBoomerangAsset.isBoomerang = isBoomerang
        specificBoomerangAsset.endTime = timeRange.end
        return specificBoomerangAsset
    }
}

class SpecificBoomerangExportConfig {
    
    var boomerangValues: [SpecificBoomerangValue]
    
    init?(boomerangValues: [SpecificBoomerangValue]) {
        guard boomerangValues.count > 0 else {
            return nil
        }
        self.boomerangValues = boomerangValues
    }
    
    func adjustBoomerangValues() {
        for (index, boomerangValue) in boomerangValues.enumerated() {
            if let previousBoomerangValue = boomerangValues[safe: index - 1] {
                let previousEndTime = previousBoomerangValue.timeRange.end
                let currentStartTime = boomerangValue.timeRange.start
                if (currentStartTime.seconds - previousEndTime.seconds) < 0 {
                    let newEndTime = CMTimeAdd(previousEndTime, CMTime(seconds: boomerangValue.maxTime, preferredTimescale: 100000))
                    boomerangValue.timeRange = CMTimeRange(start: previousEndTime,
                                                           end: newEndTime)
                }
            }
        }
    }

}

class SpecificBoomerangExportSession {
    
    private var specificBoomerangAssets: [SpecificBoomerangAsset] = []
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
    
    private func specificBoomerangAssetFor(asset: AVAsset, boomerangValues: [SpecificBoomerangValue]) -> [SpecificBoomerangAsset] {
        let sortedBoomerangValues = boomerangValues.sorted { (boomerangValue, nextBoomerangValue) -> Bool in
            return boomerangValue.timeRange.start.seconds < nextBoomerangValue.timeRange.start.seconds
        }
        var specificBoomerangAssets: [SpecificBoomerangAsset] = []
        for (index, boomerangValue) in sortedBoomerangValues.enumerated() {
            let startTime = specificBoomerangAssets[safe: specificBoomerangAssets.count - 1]?.endTime ?? .zero
            if let specificBoomerangAsset = SpecificBoomerangAsset.createSpecificBoomerangAsset(asset: asset, timeRange: CMTimeRange(start: startTime, end: boomerangValue.timeRange.start), isBoomerang: false) {
                specificBoomerangAssets.append(specificBoomerangAsset)
            }
            if let specificBoomerangAsset = SpecificBoomerangAsset.createSpecificBoomerangAsset(asset: asset, timeRange: CMTimeRange(start: boomerangValue.timeRange.start, end: boomerangValue.timeRange.end), isBoomerang: true) {
                specificBoomerangAsset.boomerangData = SpecificBoomerangData(maxTime: boomerangValue.maxTime, speedScale: boomerangValue.speedScale, maxLoopCount: boomerangValue.maxLoopCount, needToReverse: boomerangValue.needToReverse)
                specificBoomerangAssets.append(specificBoomerangAsset)
            }
            if index == sortedBoomerangValues.count - 1 {
                if let specificBoomerangAsset = SpecificBoomerangAsset.createSpecificBoomerangAsset(asset: asset, timeRange: CMTimeRange(start: boomerangValue.timeRange.end, end: asset.duration), isBoomerang: false) {
                    specificBoomerangAssets.append(specificBoomerangAsset)
                }
            }
        }
        return specificBoomerangAssets
    }
    
    public func export(for asset: AVAsset, progress: ((Float) -> Void)? = nil, completion: @escaping (URL?) -> Void) {
        cancelled = false
        var audioFinished = false
        var videoFinished = false

        specificBoomerangAssets = specificBoomerangAssetFor(asset: asset, boomerangValues: config.boomerangValues)

        var nextBufferTime = CMTime(value: 1, timescale: 24)
        var videoBitRate: NSNumber = 2000000
        var trackWidth: CGFloat = 720
        var trackHeight: CGFloat = 1280
        var trackTransform: CGAffineTransform = .identity
                
        var audioSampleRate: Float64 = 44100
        var audioNumberOfChannels: UInt32 = 2
        var audioNumberOfFrame: Int = 43
        
        for specificBoomerangAsset in specificBoomerangAssets {
            if let mediaTrackData = specificBoomerangAsset.mediaTrackData {
                nextBufferTime = mediaTrackData.nextBufferTime
                videoBitRate = mediaTrackData.bitRate
                trackWidth = mediaTrackData.width
                trackHeight = mediaTrackData.height
                trackTransform = mediaTrackData.preferredTransform
                audioNumberOfFrame = mediaTrackData.audioNumberOfFrame
                break
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
        
        specificBoomerangAssets[safe: 0]?.reader.startReading()
        specificBoomerangAssets[safe: 0]?.isReading = true
        
        let videoInputQueue = DispatchQueue(label: "videoQueue")
        let audioInputQueue = DispatchQueue(label: "audioQueue")
        
        var isAudioSetup = false

        func closeWriter() {
            if audioFinished && videoFinished && !self.cancelled {
                writer.finishWriting {
                    completion(self.writer?.outputURL)
                }
            } else if self.cancelled {
                completion(nil)
            }
        }
        
        var totalSeconds: Double = 0
        for specificBoomerangAsset in specificBoomerangAssets {
            totalSeconds += specificBoomerangAsset.seconds
        }
        
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
            sample = sample.setPresentationTimeStamp(presentationTime)!
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
                for specificBoomerangAsset in self.specificBoomerangAssets {
                    if specificBoomerangAsset.isBoomerang {
                        if specificBoomerangAsset.isReading,
                            specificBoomerangAsset.canAddAudioBuffers {
                            if writeSilentAudio() {
                                print("audio boomerang writing..")
                                break
                            }
                        }
                    } else if specificBoomerangAsset.canAddAudioBuffers,
                    specificBoomerangAsset.isReading {
                        if writeAudio(for: specificBoomerangAsset.audioAssetReaderTrackOutput) {
                            print("audio first part writing..")
                            break
                        } else {
                            specificBoomerangAsset.canAddAudioBuffers = false
                        }
                    }
                }
                print(self.specificBoomerangAssets.filter({ return !$0.canAddAudioBuffers}))
                if self.specificBoomerangAssets.filter({ return !$0.canAddAudioBuffers}).count == self.specificBoomerangAssets.count {
                    print("finish audio writing..")
                    audioInput.markAsFinished()
                    DispatchQueue.main.async {
                        audioFinished = true
                        closeWriter()
                    }
                    break
                }
            }
        }
        
        func writeVideo(for assetReaderTrackOutput: AVAssetReaderTrackOutput?) -> Bool {
            guard let sample = assetReaderTrackOutput?.copyNextSampleBuffer() else {
                return false
            }
            return autoreleasepool { () -> Bool in
                let buffer = CMSampleBufferGetImageBuffer(sample)!
                presentationTime = CMTimeAdd(presentationTime, nextBufferTime)
                let currentProgress = presentationTime.seconds / totalSeconds
                progress?(Float(currentProgress))
                return pixelBufferAdaptor.append(buffer,
                                                 withPresentationTime: presentationTime)
            }

        }
        
        func writeBoomerang(specificBoomerangAsset: SpecificBoomerangAsset) -> Bool {
            guard !specificBoomerangAsset.boomerangBuffers.isEmpty else {
                return false
            }
            return autoreleasepool { () -> Bool in
                let buffer = specificBoomerangAsset.boomerangBuffers.remove(at: 0)
                presentationTime = CMTimeAdd(presentationTime, nextBufferTime)
                let currentProgress = presentationTime.seconds / totalSeconds
                progress?(Float(currentProgress))
                pixelBufferAdaptor.append(buffer,
                                          withPresentationTime: presentationTime)
                return true
            }
        }
        
        func addBoomerangBuffer(for assetReaderTrackOutput: AVAssetReaderTrackOutput?, specificBoomerangAsset: SpecificBoomerangAsset) -> Bool {
            guard let sample = assetReaderTrackOutput?.copyNextSampleBuffer() else {
                return false
            }
            return autoreleasepool { () -> Bool in
                let buffer = CMSampleBufferGetImageBuffer(sample)!
                let boomerangSpeedScale = specificBoomerangAsset.boomerangData?.speedScale ?? 2
                specificBoomerangAsset.boomerangBufferCount += 1
                if specificBoomerangAsset.boomerangBufferCount % boomerangSpeedScale == 0 {
                    specificBoomerangAsset.boomerangBuffers.append(buffer)
                }
                return true
            }
        }
        
        func addReverseBuffers(_ buffers: [CVPixelBuffer], specificBoomerangAsset: SpecificBoomerangAsset) -> [CVPixelBuffer] {
            var reversedBuffers = buffers
            let originBuffers = reversedBuffers
            let boomerangLoopCount = specificBoomerangAsset.boomerangData?.maxLoopCount ?? 7
            let needToReverse = specificBoomerangAsset.boomerangData?.needToReverse ?? true
            for _ in 0..<((boomerangLoopCount - 1)/2) {
                if needToReverse {
                    reversedBuffers.append(contentsOf: originBuffers.reversed())
                }
                reversedBuffers.append(contentsOf: originBuffers)
            }
            return reversedBuffers
        }
        
        videoInput.requestMediaDataWhenReady(on: videoInputQueue) {
            while videoInput.isReadyForMoreMediaData {
                for specificBoomerangAsset in self.specificBoomerangAssets {
                    if specificBoomerangAsset.isBoomerang {
                        if !specificBoomerangAsset.isReading {
                            print("boomerang reading..")
                            specificBoomerangAsset.reader.startReading()
                            specificBoomerangAsset.isReading = true
                            break
                        } else {
                            if addBoomerangBuffer(for: specificBoomerangAsset.videoAssetReaderTrackOutput, specificBoomerangAsset: specificBoomerangAsset) {
                                print("boomerang buffers append..")
                                break
                            } else {
                                if !specificBoomerangAsset.isReverseBuffersAdded {
                                    specificBoomerangAsset.boomerangBuffers = addReverseBuffers(specificBoomerangAsset.boomerangBuffers, specificBoomerangAsset: specificBoomerangAsset)
                                    specificBoomerangAsset.isReverseBuffersAdded = true
                                    print("reverse boomerang buffers append..")
                                }
                                if writeBoomerang(specificBoomerangAsset: specificBoomerangAsset) {
                                    print("boomerang writing.. \(specificBoomerangAsset.boomerangBuffers.count)")
                                    break
                                } else {
                                    specificBoomerangAsset.canAddVideoBuffers = false
                                    specificBoomerangAsset.canAddAudioBuffers = false
                                }
                            }
                        }
                    } else if specificBoomerangAsset.canAddVideoBuffers {
                        if !specificBoomerangAsset.isReading {
                            specificBoomerangAsset.reader.startReading()
                            specificBoomerangAsset.isReading = true
                            print("video reading..")
                            break
                        } else if writeVideo(for: specificBoomerangAsset.videoAssetReaderTrackOutput) {
                            print("video writing..")
                            break
                        } else {
                            specificBoomerangAsset.canAddVideoBuffers = false
                        }
                    }
                }
                if self.specificBoomerangAssets.filter({ return !$0.canAddVideoBuffers }).count == self.specificBoomerangAssets.count {
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
    
    public func cancelExporting() {
        cancelled = true
        for specificBoomerangAsset in specificBoomerangAssets {
            specificBoomerangAsset.reader.cancelReading()
        }
        writer?.cancelWriting()
    }
    
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
