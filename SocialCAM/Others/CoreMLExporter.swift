//
//  CoreMLExporter.swift
//  StyleTrasfer
//
//  Created by Jasmin Patel on 28/05/19.
//  Copyright © 2019 Simform. All rights reserved.
//

import Foundation
import CoreML
import AVKit

class CoreMLExporter {
    
    var assetReader: AVAssetReader?
    var assetWriter: AVAssetWriter?
    var isCancel = false
    
    func cancelExporting() {
        isCancel = true
        assetWriter?.cancelWriting()
        assetReader?.cancelReading()
    }
    
    func exportVideo(for asset: AVAsset, and index: Int, progress: ((Float) -> Void)? = nil, completion: @escaping (URL?) -> Void) {
        isCancel = false
        let fileName = String.fileName
        let outputURL = Utils.getLocalPath(fileName)
        
        var audioFinished = false
        var videoFinished = false
        
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
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor.init(assetWriterInput: videoInput, sourcePixelBufferAttributes: nil)
        let videoInputQueue = DispatchQueue(label: "videoQueue")
        let audioInputQueue = DispatchQueue(label: "audioQueue")
        
        var assetWriter: AVAssetWriter?
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
            if audioFinished && videoFinished && !self.isCancel {
                assetWriter?.finishWriting(completionHandler: {
                    completion(assetWriter?.outputURL)
                })
                self.assetReader?.cancelReading()
            } else {
                completion(nil)
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
                    var mlBuffer: CVPixelBuffer?
                    if #available(iOS 12.0, *) {
                        if index == -1 {
                            mlBuffer = CMSampleBufferGetImageBuffer(sample!)!
                        } else {
                            let model = StyleTransferModel43()
                            do {
                                let styles = try MLMultiArray(shape: [43],
                                                              dataType: .double)
                                for indexStyle in 0..<styles.count {
                                    styles[indexStyle] = 0.0
                                }
                                styles[index] = 1.0
                                do {
                                    
                                    let mlPredicationOptions = MLPredictionOptions.init()
                                    mlPredicationOptions.usesCPUOnly = false
                                    let input = StyleTransferModel43Input.init(image: CMSampleBufferGetImageBuffer(sample!)!.mlPixelFormatBuffer(scale: 0.3)!, index: styles)
                                    let predictionOutput = try model.prediction(input: input,
                                                                                options: mlPredicationOptions)
                                    mlBuffer = predictionOutput.stylizedImage
                                } catch let error as NSError {
                                    print("CoreML Model Error: \(error)")
                                }
                            } catch let error {
                                print(error)
                            }
                        }
                    } else {
                        mlBuffer = CMSampleBufferGetImageBuffer(sample!)!
                    }
                    
                    let dProgress = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sample!)) / CMTimeGetSeconds(asset.duration)
                    print("progress = \(dProgress) at \(Date())")
                    progress?(Float(dProgress))
                    
                    pixelBufferAdaptor.append(mlBuffer!,
                                               withPresentationTime: CMSampleBufferGetPresentationTimeStamp(sample!))
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
