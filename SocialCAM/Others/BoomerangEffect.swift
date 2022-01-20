//
//  BoomerangEffect.swift
//  ProManager
//
//  Created by Viraj Patel on 05/04/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import AVKit
import UIKit
import MobileCoreServices

struct VideoOrigin {
    var mediaType: Any?
    var mediaUrl: Any?
    var referenceURL: Any?
}

public enum VideoProcessType {
    case boom
    case speed
    case normal
    case reverse
}

class VideoFactory: NSObject {
    var buffertoVideo: BufferToVideo?
    var videoorigin: VideoOrigin?
    var cvimgbuffer: [CVImageBuffer] = [CVImageBuffer]()
    var fps: Int = 30
    var type: VideoProcessType!
    var videoAsset: AVAsset?

    override init() {
        super.init()
    }

    init(type: VideoProcessType, video: VideoOrigin) {
        super.init()
        self.type = type
        self.videoorigin = video
    }

    init(type: VideoProcessType, video: AVAsset) {
        super.init()
        self.type = type
        self.videoAsset = video
    }

    func assetTOcvimgbuffer(_ sucess: @escaping ((URL) -> Void), _ progress: @escaping ((Progress) -> Void), failure: ((NSError) -> Void)) {
        if videoAsset == nil {
            guard let videoUrl = videoorigin?.mediaUrl! as? URL else {
                return
            }
            videoAsset = AVAsset(url: videoUrl)
        }
        var trackreader: AVAssetReader?
        
        do {
            trackreader = try AVAssetReader(asset: videoAsset!)
        } catch {
            trackreader = nil
        }
        guard let reader = trackreader else {
            print("Could not initalize asset reader probably failed its try catch")
            return
        }
        
        let videoTracks = videoAsset?.tracks(withMediaType: AVMediaType.video)

        for track in videoTracks! {
            let trackoutput: AVAssetReaderTrackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: [
                String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            ])
            fps = Int(track.nominalFrameRate)
            if reader.canAdd(trackoutput) {
                reader.add(trackoutput)
                var buffer: CMSampleBuffer?
                if reader.startReading() {
                    buffer = trackoutput.copyNextSampleBuffer()
                    while buffer != nil {
                        guard let cvimgabuffer = CMSampleBufferGetImageBuffer(buffer!) else {
                            fatalError("cvimgabuffer is nil")
                        }
                        cvimgbuffer.append(cvimgabuffer)
                        buffer = trackoutput.copyNextSampleBuffer()
                    }
                }
            }
        }

        bufferToVideo(videoorigin: self.videoorigin, { (url) in
            sucess(url)
        }, { (currentProgress) in
            progress(currentProgress)
        }, failure: { (error) in
            failure(error)
        })
    }

    func bufferToVideo(videoorigin: VideoOrigin?, _ sucess: @escaping ((URL) -> Void), _ progress: @escaping ((Progress) -> Void), failure: ((NSError) -> Void)) {
        if self.type == .reverse {
            cvimgbuffer.reverse()
        }
        let duration = Int(videoAsset?.duration.seconds ?? 2 - 1.0)
        if self.type == .boom {
            if(cvimgbuffer.count > self.fps * duration) {
                let slice = cvimgbuffer.dropLast(cvimgbuffer.count - self.fps * duration)
                cvimgbuffer = Array(slice)
            }
            
            let reverse = cvimgbuffer.reversed()
            let origin = cvimgbuffer
            
            cvimgbuffer.removeAll()
            cvimgbuffer.append(contentsOf: reverse)
            cvimgbuffer.append(contentsOf: origin)
            cvimgbuffer.append(contentsOf: reverse)
            cvimgbuffer.append(contentsOf: origin)
        }

        let buffer = BufferToVideo(buffer: cvimgbuffer, fps: Int32(fps))
        if self.type == .boom || self.type == .speed {
            buffer.filename = "BoomVideo.mp4"
            buffer.fps *= 2
        }

        buffer.build(videoorigin: videoorigin, { (url) in
            sucess(url)
        }, { (currentprogress) in
            progress(currentprogress)
        }, failure: { (error) in
            failure(error)
        })
    }

}

class BufferToVideo: NSObject {
    let buffer: [CVPixelBuffer]
    var fps: Int32 = 30
    let kErrorDomain = "TimeLapseBuilder"
    let kFailedToStartAssetWriterError = 0
    let kFailedToAppendPixelBufferError = 1
    var filename: String = "MergedVideo.mp4"

    // Capture Real time
    init(buffer: [CVPixelBuffer], fps: Int32) {
        self.buffer = buffer
        self.fps = fps
    }

    func build(videoorigin: VideoOrigin?, _ sucess: @escaping ((URL) -> Void), _ progress: @escaping ((Progress) -> Void), failure: ((NSError) -> Void)) {
        /// Get Basic Setting
        var error: NSError?

        let firstPixelBuffer = buffer.first!
        let width = CVPixelBufferGetWidth(firstPixelBuffer)
        let height = CVPixelBufferGetHeight(firstPixelBuffer)
        guard let attr: [String: Any] = CVBufferGetAttachments(firstPixelBuffer, .shouldPropagate) as? [String: Any] else {
            return
        }

        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height
        ]

        /// Now in order to glue all the data we grabbed so far, we need to use magic AVAssetWriter. It’s a powerful class in AVFoundation which allow to write a video into output directory, encode the video file format into .mov or .mp4 and manage the metadata of the frames while recording it.
        var videoWriter: AVAssetWriter?
        _ = FileManager.documentsDir() as NSString

        let videoOutputURL = Utils.getLocalPath(filename)
        do {
            try FileManager.default.removeItem(at: videoOutputURL)
        } catch { }
        do {
            try videoWriter = AVAssetWriter(outputURL: videoOutputURL, fileType: AVFileType.mov)
        } catch let writerError as NSError {
            error = writerError
            videoWriter = nil
        }
        
        guard let videoUrl = videoorigin?.mediaUrl! as? URL else {
            return
        }
        let asset: AVAsset = AVAsset.init(url: videoUrl)

        let videoTrack: AVAssetTrack = asset.tracks(withMediaType: AVMediaType.video).last!

        ///
        if let videoWriter = videoWriter {
            /// Add Input to Writer , AVAssetWriterInput use CVSampleBuffer , AVAssetWriterInputPixelBufferAdaptor use CVPixelBuffer
            let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
            let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: attr)
            guard videoWriter.canAdd(videoWriterInput) else {
                fatalError("VideoWriter Can't Add")
            }
            videoWriterInput.transform = videoTrack.preferredTransform
            videoWriterInput.expectsMediaDataInRealTime = false
            videoWriter.add(videoWriterInput)

            if videoWriter.startWriting() {
                // start session pixel buffer != nil
                videoWriter.startSession(atSourceTime: CMTime.zero)
                if pixelBufferAdaptor.pixelBufferPool == nil {
                    fatalError("pixelBufferPool is nil")
                }
                
                let mediaQueue = DispatchQueue(label: Constant.Application.simformIdentifier)
                videoWriterInput.requestMediaDataWhenReady(on: mediaQueue) {
                    let welf = self
                    let currentProgress = Progress(totalUnitCount: Int64(welf.buffer.count))
                    var frameCount: Int64 = 0
                    let frameDuration = CMTimeMake(value: 1, timescale: welf.fps)
                    var remainingPhotoURLs = welf.buffer
                    
                    while !remainingPhotoURLs.isEmpty {
                        autoreleasepool {
                            let nextPhotoURL: CVPixelBuffer? = remainingPhotoURLs.remove(at: 0)
                            let newPixelBufferoutputs: CVPixelBuffer = nextPhotoURL!
                            let lastFrameTime = CMTimeMake(value: frameCount, timescale: welf.fps)
                            let presentationTime = frameCount == 0 ? lastFrameTime : CMTimeAdd(lastFrameTime, frameDuration)
                            while !videoWriterInput.isReadyForMoreMediaData {
                                Thread.sleep(forTimeInterval: 0.1)
                            }
                            
                            if pixelBufferAdaptor.append(newPixelBufferoutputs, withPresentationTime: presentationTime) {
                                frameCount += 1
                                currentProgress.completedUnitCount = frameCount
                                progress(currentProgress)
                            }
                        }
                    }
                    
                    videoWriterInput.markAsFinished()
                    videoWriter.finishWriting {
                        if error == nil {
                            sucess(videoOutputURL)
                            return
                        }
                    }
                }
            } else {
                error = NSError(
                    domain: kErrorDomain,
                    code: kFailedToStartAssetWriterError,
                    userInfo: ["description": "AVAssetWriter failed to start writing"]
                )
            }
        }

        if let error = error {
            failure(error)
        }
        
    }
}
