//
//  StoryAssetExportSession.swift
//  RecordVideoScreen
//
//  Created by Jasmin Patel on 19/06/19.
//  Copyright © 2019 Simform. All rights reserved.
//

import Foundation
import AVKit
import MobileCoreServices

class InputImageTransformation {
    
    var tx: CGFloat = 0
    var ty: CGFloat = 0
    var scaleX: CGFloat = 0
    var scaleY: CGFloat = 0
    var rotation: CGFloat = 0
    
}
class StoryAssetExportSession {
    
    enum WatermarkPosition {
        case topLeft
        case bottomRight
        case bottomLeft
    }
    
    enum WatermarkType {
        case image
        case gif
        case imageText
    }
    
    private var reader: AVAssetReader?
    private var writer: AVAssetWriter?
    private var preferredTransform: CGAffineTransform?
    private var cancelled = false
    private var ciContext = CIContext()
    private var watermarkAdded: Bool = false
    private var overlayWatermarkImage: UIImage?
    private var watermarkPosition: WatermarkPosition = .topLeft
    private var gifWaterMarkURL = Bundle.main.url(forResource: "QuickCamLiteWatermarkGIF", withExtension: "gif")
    private var gifFrames = [CGImage]()
    private var gifCount = 0

    public var overlayImage: UIImage?
    public var filter: CIFilter?
    public var isMute = false
    public var inputTransformation: StoryImageView.ImageTransformation?
    public var imageContentMode: StoryImageView.ImageContentMode = .scaleAspectFit
    public var watermarkType: WatermarkType = .image
    
    private func fileURL() -> URL {
        let fileName = "\(Constant.Application.displayName.replacingOccurrences(of: " ", with: "").lowercased())_\(Defaults.shared.releaseType.description)_v\(Constant.Application.appBuildNumber)_\(String.fileName)" + FileExtension.mp4.rawValue
        return Utils.getLocalPath(fileName)
    }
    
    public func export(for asset: AVAsset, progress: ((Float) -> Void)? = nil, completion: @escaping (URL?) -> Void) {
        cancelled = false
        var audioFinished = false
        var videoFinished = false
        
        // Setup Reader
        do {
            reader = try AVAssetReader(asset: asset)
        } catch {
            print("AVAssetReader initialization failed with error : \(error)")
        }
        
        guard let reader = reader else {
            return
        }
        
        guard let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first else {
            print("asset does not have video track")
            return
        }
        preferredTransform = videoTrack.preferredTransform
        
        let videoReaderSettings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB ]
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
        
        // Setup Writer
        do {
            writer = try AVAssetWriter(outputURL: fileURL(), fileType: .mov)
        } catch {
            print("AVAssetWriter initialization failed with error : \(error)")
        }
        
        guard let writer = writer else {
            return
        }
        
        var videoSettings: [String: Any] = [
            AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: NSNumber.init(value: videoTrack.estimatedDataRate)],
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoHeightKey: 1280,
            AVVideoWidthKey: 720,
            AVVideoScalingModeKey: AVVideoScalingModeResizeAspect
        ]
        if imageContentMode == .scaleAspectFill {
            videoSettings[AVVideoHeightKey] = videoTrack.naturalSize.height
            videoSettings[AVVideoWidthKey] = videoTrack.naturalSize.width
            videoSettings[AVVideoScalingModeKey] = AVVideoScalingModeResizeAspectFill
        }
        
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
        
        let closeWriter: (() -> Void) = {
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
        var isFirstFrame = true
        videoInput.requestMediaDataWhenReady(on: videoInputQueue) {
            while videoInput.isReadyForMoreMediaData {
                if let sample = assetReaderVideoOutput.copyNextSampleBuffer() {
                    autoreleasepool {
                        if isFirstFrame {
                            isFirstFrame = false
                        } else {
                            let buffer = self.renderWithTransformation(sampleBuffer: sample)
                            pixelBufferAdaptor.append(buffer,
                                                      withPresentationTime: CMSampleBufferGetPresentationTimeStamp(sample))
                            let currentTime = CMSampleBufferGetPresentationTimeStamp(sample)
                            if currentTime.seconds > 5.0 {
                                self.watermarkAdded = false
                                self.watermarkPosition = .bottomRight
                            }
                            let currentProgress = currentTime.seconds / asset.duration.seconds
                            progress?(Float(currentProgress))
                        }
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
    
    func scaleAndResizeTransform(_ image: CIImage, for rect: CGRect) -> CGAffineTransform {
        let imageSize = image.extent.size
        
        var horizontalScale: CGFloat = rect.size.width / imageSize.width
        var verticalScale: CGFloat = rect.size.height / imageSize.height
        
        if imageContentMode == .scaleAspectFill {
            horizontalScale = max(horizontalScale, verticalScale)
            verticalScale = horizontalScale
        } else if imageContentMode == .scaleAspectFit {
            horizontalScale = min(horizontalScale, verticalScale)
            verticalScale = horizontalScale
        }
        return CGAffineTransform(scaleX: horizontalScale, y: verticalScale)
    }
    
    private func renderWithTransformation(sampleBuffer: CMSampleBuffer) -> CVPixelBuffer {
        guard var backgroundImageBuffer = R.image.videoBackground()?.buffer(),
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
        var overlayCIImage = CIImage(cvImageBuffer: videoBuffer)
        if imageContentMode == .scaleAspectFill {
            do {
                let backgroundImage = try R.image.videoBackground()!.resized(to: overlayCIImage.extent.size, with: .accelerate)
                backgroundImageBuffer = backgroundImage.buffer()!
            } catch {
                
            }
        }
        
        let backgroundCIImage = CIImage(cvImageBuffer: backgroundImageBuffer)
        let backgroundCIImageWidth = backgroundCIImage.extent.width
        let backgroundCIImageHeight = backgroundCIImage.extent.height
        
        if let preferredTransform = self.preferredTransform {
            overlayCIImage = overlayCIImage.transformed(by: CGAffineTransform(rotationAngle: -(atan2(preferredTransform.b, preferredTransform.a))))
        }
        
        let scaleTransform = scaleAndResizeTransform(overlayCIImage, for: backgroundCIImage.extent)
        overlayCIImage = overlayCIImage.transformed(by: scaleTransform)
        
        overlayCIImage = overlayCIImage.transformed(by: CGAffineTransform(scaleX: transformation.scaleX, y: transformation.scaleY))
        
        overlayCIImage = overlayCIImage.transformed(by: CGAffineTransform(translationX: 0, y: backgroundCIImageHeight/2 - overlayCIImage.extent.height/2))
                
        overlayCIImage = overlayCIImage.transformed(by: CGAffineTransform(rotationAngle: -transformation.rotation))
        
        let txValue = (backgroundCIImageWidth*transformation.tx/100) - overlayCIImage.extent.origin.x
        let tyValue = backgroundCIImageHeight - (backgroundCIImageHeight*transformation.ty/100) - overlayCIImage.extent.height - overlayCIImage.extent.origin.y
        if imageContentMode != .scaleAspectFill {
            overlayCIImage = overlayCIImage.transformed(by: CGAffineTransform(translationX: txValue, y: tyValue))
        }
        var combinedCIImage = overlayCIImage.composited(over: backgroundCIImage)
        combinedCIImage = combinedCIImage.cropped(to: backgroundCIImage.extent)
           
        if let filteredCIImage = self.filteredCIImage(combinedCIImage) {
            combinedCIImage = filteredCIImage
        }
        
        if let overlaidCIImage = overlaidCIImage(combinedCIImage) {
            combinedCIImage = overlaidCIImage
        }
        
        self.ciContext.render(combinedCIImage, to: backgroundImageBuffer, bounds: combinedCIImage.extent, colorSpace: CGColorSpaceCreateDeviceRGB())
        
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
        if Defaults.shared.madeWithGifSetting == .show {
            watermarkType = .gif
        }
        if overlayWatermarkImage == nil {
            overlayWatermarkImage = overlayImage
        }
        if watermarkType == .gif {
            if gifCount % 3 == 0 {
                if gifFrames.count == 0,
                    let watermarkURL = self.gifWaterMarkURL,
                    let imageData = try? Data(contentsOf: watermarkURL) {
                    gifFrames = imageData.gifFrames()
                    if gifFrames.count > 0 {
                        DispatchQueue.main.async { [weak self] in
                            guard let `self` = self else {
                                return
                            }
                            if Defaults.shared.appIdentifierWatermarkSetting == .show || Defaults.shared.madeWithGifSetting == .show {
                                self.addWaterMarkImageIfNeeded(isGIF: true)
                            }
                            if Defaults.shared.fastestEverWatermarkSetting == .show {
                                self.addFastestEverWaterMarkImage()
                            }
                        }
                    }
                } else {
                    if gifFrames.count > 0 {
                        DispatchQueue.main.async { [weak self] in
                            guard let `self` = self else {
                                return
                            }
                            if Defaults.shared.appIdentifierWatermarkSetting == .show || Defaults.shared.madeWithGifSetting == .show {
                                self.addWaterMarkImageIfNeeded(isGIF: true)
                            }
                            if Defaults.shared.fastestEverWatermarkSetting == .show {
                                self.addFastestEverWaterMarkImage()
                            }
                        }
                    }
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {
                    return
                }
                if Defaults.shared.appIdentifierWatermarkSetting == .show {
                    self.addWaterMarkImageIfNeeded(isGIF: false)
                }
                if Defaults.shared.fastestEverWatermarkSetting == .show {
                    self.addFastestEverWaterMarkImage()
                }
            }
        }
        gifCount += 1
        if let overlayImage = self.overlayWatermarkImage,
            let overlayCGImage = overlayImage.cgImage {
            var ciOverlay = CIImage(cgImage: overlayCGImage)
            ciOverlay = ciOverlay.transformed(by: CGAffineTransform(scaleX: image.extent.width/overlayImage.size.width, y: image.extent.height/overlayImage.size.height))
            return ciOverlay.composited(over: image)
        }
        return nil
    }
    
    func addWaterMarkImageIfNeeded(isGIF: Bool = false) {
        var image = R.image.socialCamWaterMark()
        let userName = Defaults.shared.currentUser?.username ?? ""
        if isViralCamApp {
            image = R.image.wmViralCamLogo()
            if watermarkPosition == .topLeft {
                image = R.image.wmViralCamLogo()
            }
        } else if isSoccerCamApp || isFutbolCamApp {
            image = R.image.soccercamWatermarkLogo()
            if watermarkPosition == .topLeft {
                image = R.image.soccercamWatermarkLogo()
            }
        } else if isQuickCamApp || isQuickCamLiteApp {
            image = R.image.quickcamWatermarkLogo()
            if watermarkPosition == .topLeft {
                image = R.image.quickcamWatermarkLogo()
            }
        } else if isSnapCamApp || isSnapCamLiteApp {
            switch Defaults.shared.waterarkOpacity {
            case 30:
                image = R.image.snapCamNewWaterMark()
            case 50:
                image = R.image.snapCamNewWaterMark()
            default:
                image = R.image.snapCamNewWaterMark()
            }
        } else if isSpeedCamApp || isSpeedCamLiteApp {
            image = R.image.wmSpeedCamLogo()
            if watermarkPosition == .topLeft {
                image = R.image.wmSpeedCamLogo()
            }
        } else if isPic2ArtApp {
            image = R.image.pic2artWatermarkLogo()
            if watermarkPosition == .topLeft {
                image = R.image.pic2artWatermarkLogo()
            }
        } else if isBoomiCamApp {
            image = R.image.boomicamWatermarkLogo()
            if watermarkPosition == .topLeft {
                image = R.image.boomicamWatermarkLogo()
            }
        } else if isTimeSpeedApp {
            image = R.image.wmTimespeedLogo()
            if watermarkPosition == .topLeft {
                image = R.image.wmTimespeedLogo()
            }
        } else if isFastCamApp || isFastCamLiteApp {
            switch Defaults.shared.waterarkOpacity {
            case 30:
                image = R.image.fastCamWatermark0()
            case 50:
                image = R.image.fastCamWatermark50()
            default:
                image = R.image.fastCamWatermark80()
            }
        } else if isQuickCamLiteApp {
            image = R.image.quickCamLiteWatermarkText()
            if watermarkPosition == .topLeft {
                image = R.image.quickCamLiteWatermarkText()
            }
        } else if isViralCamLiteApp {
            image = R.image.viralCamLiteWatermarkText()
            if watermarkPosition == .topLeft {
                image = R.image.viralCamLiteWatermarkText()
            }
        } else if isQuickApp {
            image = R.image.quickCamLiteWatermark()
            if watermarkPosition == .topLeft {
                image = R.image.quickCamLiteWatermark()
            }
        }

        let newTextimage: UIImage? = LetterImageGenerator.imageWith(name: "@\(userName)")
        guard let watermarkTextImage = newTextimage else {
            return
        }
        
        guard !watermarkAdded,
            let backgroundImage = self.overlayImage,
            let watermarkImage = Defaults.shared.appIdentifierWatermarkSetting == .show ? image : UIImage() else {
                return
        }
        
        let watermarkGIFImage = isGIF ? UIImage(cgImage: gifFrames.remove(at: 0)) : UIImage()
        
        var newWatermarkImage = watermarkImage
        if Defaults.shared.appIdentifierWatermarkSetting == .show {
            newWatermarkImage = watermarkImage.combineWith(image: watermarkTextImage)
        }
        
        let newWatermarkGIFImage = watermarkGIFImage
        
        let backgroundImageSize = backgroundImage.size
        UIGraphicsBeginImageContext(backgroundImageSize)

        let backgroundImageRect = CGRect(origin: .zero, size: backgroundImageSize)
        backgroundImage.draw(in: backgroundImageRect)

        let watermarkImageSize = CGSize(width: newWatermarkImage.size.width * 1.3, height: newWatermarkImage.size.height * 1.3)
        let watermarkGIFImageSize = CGSize(width: newWatermarkGIFImage.size.width * 1.5, height: newWatermarkGIFImage.size.height * 2)
        
        var watermarkOrigin = CGPoint(x: backgroundImageSize.width - watermarkImageSize.width - 20, y: backgroundImageSize.height - watermarkImageSize.height - 50)
        if watermarkPosition == .topLeft && Defaults.shared.appIdentifierWatermarkSetting == .show {
            watermarkOrigin = CGPoint(x: 8, y: 8)
        }
        let watermarkGIFOrigin = CGPoint(x: backgroundImageSize.width - watermarkGIFImageSize.width + 10, y: 0)
        
        var watermarkImageRect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 0, height: 0))
        if Defaults.shared.appIdentifierWatermarkSetting == .show && Defaults.shared.madeWithGifSetting == .show {
            watermarkImageRect = CGRect(origin: watermarkOrigin, size: watermarkImageSize)
            newWatermarkImage.draw(in: watermarkImageRect, blendMode: .normal, alpha: 1.0)
            watermarkImageRect = CGRect(origin: watermarkGIFOrigin, size: watermarkGIFImageSize)
            newWatermarkGIFImage.draw(in: watermarkImageRect, blendMode: .normal, alpha: 1.0)
        } else if Defaults.shared.appIdentifierWatermarkSetting == .show {
            watermarkImageRect = CGRect(origin: watermarkOrigin, size: watermarkImageSize)
            newWatermarkImage.draw(in: watermarkImageRect, blendMode: .normal, alpha: 1.0)
        } else if Defaults.shared.madeWithGifSetting == .show {
            watermarkImageRect = CGRect(origin: watermarkGIFOrigin, size: watermarkGIFImageSize)
            newWatermarkGIFImage.draw(in: watermarkImageRect, blendMode: .normal, alpha: 1.0)
        }
        if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
            self.overlayWatermarkImage = newImage
            self.watermarkAdded = true
        }
        UIGraphicsEndImageContext()
    }
    
    func addFastestEverWaterMarkImage() {
        guard let image = R.image.fastestever() else { return }
        guard let backgroundImage = self.overlayWatermarkImage else { return }
        let backgroundImageSize = backgroundImage.size
        UIGraphicsBeginImageContext(backgroundImageSize)
        
        let backgroundImageRect = CGRect(origin: .zero, size: backgroundImageSize)
        backgroundImage.draw(in: backgroundImageRect)
        
        let watermarkImageSize = CGSize(width: image.size.width * 1, height: image.size.height * 1)
        let watermarkOrigin = CGPoint(x: 8, y: backgroundImageSize.height - watermarkImageSize.height - 70)
        let watermarkImageRect = CGRect(origin: watermarkOrigin, size: watermarkImageSize)
        image.draw(in: watermarkImageRect, blendMode: .normal, alpha: 1.0)
        
        if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
            self.overlayWatermarkImage = newImage
        }
        UIGraphicsEndImageContext()
    }
    
}
