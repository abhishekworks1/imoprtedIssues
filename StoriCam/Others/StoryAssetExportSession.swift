//
//  StoryAssetExportSession.swift
//  RecordVideoScreen
//
//  Created by Jasmin Patel on 19/06/19.
//  Copyright © 2019 Simform. All rights reserved.
//

import Foundation
import AVKit
class InputImageTransformation {
    
    var tx: CGFloat = 0
    var ty: CGFloat = 0
    var scaleX: CGFloat = 0
    var scaleY: CGFloat = 0
    var rotation: CGFloat = 0
    
}
class StoryAssetExportSession {
    
    private var reader: AVAssetReader?
    private var writer: AVAssetWriter?
    private var preferredTransform: CGAffineTransform?
    private var cancelled = false
    private var ciContext = CIContext()

    public var overlayImage: UIImage?
    public var filter: CIFilter?
    public var isMute = false
    public var inputTransformation: InputImageTransformation?
    
    private func fileURL() -> URL {
        let fileName = String.fileName + FileExtension.mov.rawValue
        return Utils.getLocalPath(fileName)
    }
    
    public func export(for asset: AVAsset, progress: ((Float) -> ())? = nil, completion: @escaping (URL?) -> Void) {
        cancelled = false
        var audioFinished = false
        var videoFinished = false
        
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
        if let audioTrack = audioTrack, !isMute {
            assetReaderAudioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
            if reader.canAdd(assetReaderAudioOutput!) {
                reader.add(assetReaderAudioOutput!)
            }
        }
        
        
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
            AVVideoHeightKey : 1280,
            AVVideoWidthKey : 720,
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
        writer.startSession(atSourceTime: CMTime.zero)
        
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
                        let buffer = self.renderWithTransformation(sampleBuffer: sample)
                        pixelBufferAdaptor.append(buffer,
                                                  withPresentationTime: CMSampleBufferGetPresentationTimeStamp(sample))
                        
                        let currentProgress = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sample)) / CMTimeGetSeconds(asset.duration)
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
        guard let backgroundImageBuffer = UIImage.init(named: "videoBackground")?.buffer(),
            let videoBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
            let transformation = self.inputTransformation else {
                let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
                var ciImage = CIImage(cvPixelBuffer: imageBuffer)
                if let filteredCIImage = filteredCIImage(ciImage) {
                    ciImage = filteredCIImage
                }
                if let overlaidCIImage = overlaidCIImage(ciImage) {
                    ciImage = overlaidCIImage
                }
                self.ciContext.render(ciImage, to: imageBuffer, bounds: ciImage.extent, colorSpace: CGColorSpaceCreateDeviceRGB())
                return imageBuffer
        }
        
        let backgroundCIImage = CIImage(cvImageBuffer: backgroundImageBuffer)
        let backgroundCIImageWidth = backgroundCIImage.extent.width
        let backgroundCIImageHeight = backgroundCIImage.extent.height
        
        var overlayCIImage = CIImage(cvImageBuffer: videoBuffer)
        if let preferredTransform = self.preferredTransform {
            overlayCIImage = overlayCIImage.transformed(by: CGAffineTransform(rotationAngle: -preferredTransform.rotationValue))
        }
        let overlayCIImageWidth = overlayCIImage.extent.width
        let overlayCIImageHeight = overlayCIImage.extent.height
        
        
        var xscale = backgroundCIImageWidth.scaleValueFrom(transformation.scaleX)
        var yscale = backgroundCIImageHeight.scaleValueFrom(transformation.scaleY)
        
        if overlayCIImageWidth > overlayCIImageHeight {
            xscale = backgroundCIImageHeight.scaleValueFrom(transformation.scaleX)*overlayCIImageWidth/overlayCIImageHeight
            yscale = backgroundCIImageWidth.scaleValueFrom(transformation.scaleY)*overlayCIImageWidth/overlayCIImageHeight
        }
        
        overlayCIImage = overlayCIImage.transformed(by: CGAffineTransform(scaleX: xscale, y: yscale))
        
        overlayCIImage = overlayCIImage.transformed(by: CGAffineTransform(rotationAngle: -transformation.rotation))
        
        let txValue = backgroundCIImageWidth.scaleValueFrom(transformation.tx) - overlayCIImage.extent.origin.x
        
        let tyValue = backgroundCIImageHeight - backgroundCIImageHeight.scaleValueFrom(transformation.ty) - (overlayCIImage.extent.height) - overlayCIImage.extent.origin.y
        
        overlayCIImage = overlayCIImage.transformed(by: CGAffineTransform(translationX: txValue, y: tyValue))
        
        var finalCIImage = overlayCIImage.composited(over: backgroundCIImage)
        
        if let overlaidCIImage = overlaidCIImage(finalCIImage) {
            finalCIImage = overlaidCIImage
        }
        
        if let filteredCIImage = self.filteredCIImage(finalCIImage) {
            finalCIImage = filteredCIImage
        }
        
        self.ciContext.render(finalCIImage, to: backgroundImageBuffer, bounds: finalCIImage.extent, colorSpace: CGColorSpaceCreateDeviceRGB())
        
        return backgroundImageBuffer
    }
    
    func filteredCIImage(_ image: CIImage) -> CIImage? {
        if let filter = self.filter {
            filter.setValue(image, forKey: kCIInputImageKey)
            if let outputImage = filter.value(forKey: kCIOutputImageKey) as? CIImage {
                return outputImage
            }
        }
        return nil
    }
    
    func overlaidCIImage(_ image: CIImage) -> CIImage? {
        if let overlayImage = self.overlayImage,
            let overlayCGImage = overlayImage.cgImage {
            var ciOverlay = CIImage(cgImage: overlayCGImage)
            ciOverlay = ciOverlay.transformed(by: CGAffineTransform(scaleX: image.extent.width/overlayImage.size.width, y: image.extent.height/overlayImage.size.height))
            return ciOverlay.composited(over: image)
        }
        return nil
    }
    
}
