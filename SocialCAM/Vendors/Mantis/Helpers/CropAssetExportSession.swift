//
//  CropAssetExportSession.swift
//  VideoEditor
//
//  Created by Jasmin Patel on 14/11/19.
//  Copyright © 2019 Jasmin Patel. All rights reserved.
//

import Foundation
import AVKit

class CropAssetExportSession {
    
    private var reader: AVAssetReader?
    private var writer: AVAssetWriter?
    private var preferredTransform: CGAffineTransform?
    private var cancelled = false
    private var ciContext = CIContext()

    private var config: CropAssetExportConfig
    
    private func fileURL() -> URL {
        let fileName = "\(UUID().uuidString).mov"
        var documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                        .userDomainMask, true)[0]
        documentDirectoryPath = documentDirectoryPath.appending("/\(fileName)")
        return URL(fileURLWithPath: documentDirectoryPath)
    }
    
    init(config: CropAssetExportConfig) {
        self.config = config
    }
    
    public func export(for asset: AVAsset, progress: ((Float) -> ())? = nil, completion: @escaping (URL?) -> Void) {
        cancelled = false
        var audioFinished = false
        var videoFinished = false
        // Setup Reader
        do {
            reader = try AVAssetReader(asset: asset)
        } catch {
            print("AVAssetReader initialization failed with error : \(error)")
        }
        
        guard let reader = reader else{
            return
        }
        
        guard let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first else {
            print("asset does not have video track")
            return
        }
        preferredTransform = videoTrack.preferredTransform
        
        let videoReaderSettings: [String : Any] = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32ARGB ]
        let assetReaderVideoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
        if reader.canAdd(assetReaderVideoOutput) {
            reader.add(assetReaderVideoOutput)
        }
        
        let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first
        var assetReaderAudioOutput: AVAssetReaderTrackOutput?
        if let audioTrack = audioTrack {
            assetReaderAudioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
            if reader.canAdd(assetReaderAudioOutput!) {
                reader.add(assetReaderAudioOutput!)
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
        
        let videoSettings: [String:Any] = [
            AVVideoCompressionPropertiesKey : [AVVideoAverageBitRateKey : NSNumber.init(value: videoTrack.estimatedDataRate)],
            AVVideoCodecKey : AVVideoCodecType.h264,
            AVVideoHeightKey : floor(config.expectedSize.height),
            AVVideoWidthKey : floor(config.expectedSize.width / 16) * 16,
            AVVideoScalingModeKey : AVVideoScalingModeResizeAspect
        ]
        let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
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
        
        reader.startReading()
        
        let videoInputQueue = DispatchQueue(label: "videoQueue")
        let audioInputQueue = DispatchQueue(label: "audioQueue")
        
        
        let closeWriter: (() -> ()) = {
            if audioFinished && videoFinished && !self.cancelled {
                writer.finishWriting {
                    completion(self.writer?.outputURL)
                }
            } else if self.cancelled {
                completion(nil)
            }
        }
        
        audioInput.requestMediaDataWhenReady(on: audioInputQueue) {
            while audioInput.isReadyForMoreMediaData {
                if let sample = assetReaderAudioOutput?.copyNextSampleBuffer() {
                    audioInput.append(sample)
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
                if let sample = assetReaderVideoOutput.copyNextSampleBuffer() {
                    autoreleasepool {
                        let currentTime = CMSampleBufferGetPresentationTimeStamp(sample)
                        let buffer = self.renderWithTransformation(sampleBuffer: sample)
                        pixelBufferAdaptor.append(buffer,
                                                  withPresentationTime: currentTime)
                        let currentProgress = currentTime.seconds / asset.duration.seconds
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
    
    public func cancelExporting() {
        cancelled = true
        reader?.cancelReading()
        writer?.cancelWriting()
    }
    
    private func renderWithTransformation(sampleBuffer: CMSampleBuffer) -> CVPixelBuffer {
        let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        var ciImage = CIImage(cvImageBuffer: cvBuffer)
        if let preferredTransform = self.preferredTransform {
            ciImage = ciImage.transformed(by: CGAffineTransform(rotationAngle: -(atan2(preferredTransform.b, preferredTransform.a))))
        }
        let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent)
        guard let trasformedCGImage = cgImage?.transformedImage(config.transform,
                                                                zoomScale: config.zoomScale,
                                                                isFlipped: config.isFlipped,
                                                                sourceSize: config.sourceSize,
                                                                cropSize: config.cropSize,
                                                                imageViewSize: config.imageViewSize),
            let buffer = trasformedCGImage.pixelBuffer() else {
                return cvBuffer
        }
        return buffer
    }
    
}

class CropAssetExportConfig {
    var transform: CGAffineTransform
    var zoomScale: CGFloat
    var isFlipped: Bool
    var sourceSize: CGSize
    var cropSize: CGSize
    var imageViewSize: CGSize
    var expectedSize: CGSize {
        let expectedWidth = (sourceSize.width / imageViewSize.width * cropSize.width) / zoomScale
        let expectedHeight = (sourceSize.height / imageViewSize.height * cropSize.height) / zoomScale
        return CGSize(width: expectedWidth, height: expectedHeight)
    }
    
    init(transform: CGAffineTransform, zoomScale: CGFloat, isFlipped: Bool, sourceSize: CGSize, cropSize: CGSize, imageViewSize: CGSize) {
        self.transform = transform
        self.zoomScale = zoomScale
        self.isFlipped = isFlipped
        self.sourceSize = sourceSize
        self.cropSize = cropSize
        self.imageViewSize = imageViewSize
    }
}
