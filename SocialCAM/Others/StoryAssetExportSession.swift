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
    private var gifWaterMarkURL: URL?
    private var gifFrames = [CGImage]()
    private var gifCount = 0

    public var overlayImage: UIImage?
    public var filter: CIFilter?
    public var isMute = false
    public var inputTransformation: StoryImageView.ImageTransformation?
    public var imageContentMode: StoryImageView.ImageContentMode = .scaleAspectFit
    public var watermarkType: WatermarkType = .image
    public var socialShareType: SocialShare = .facebook
    public var outroImgArray = [UIImage]()
    
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
                    guard let url = Bundle.main.url(forResource: "9", withExtension: ".mp4") else {
                        return
                    }
                    let assetgif = AVURLAsset(url: url, options: nil)
                    guard let outputUrl = self.writer?.outputURL else {
                        return
                    }
                    let asset = AVURLAsset(url: outputUrl, options: nil)
                    guard let backgroundImage = self.overlayImage else {
                        return
                    }
                    self.mergeVideos(firstVideo: asset, secondVideo: assetgif, withImage: backgroundImage) { (result) in
                        print("merge complete")
                        completion(result)
                    }
                    
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
                    
//                    self.gifFrames = [CGImage]()
//                    let ciImage = self.addOutro()
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
    
    func addWatermarkGifUrl(urlString: String) {
        gifWaterMarkURL = Bundle.main.url(forResource: urlString, withExtension: "gif")
    }
    
    func overlaidCIImage(_ image: CIImage) -> CIImage? {
        if Defaults.shared.madeWithGifSetting == .show {
            watermarkType = .gif
        }
        if isQuickApp || isQuickCamLiteApp {
            addWatermarkGifUrl(urlString: R.string.localizable.quickCamLiteWatermarkGIF())
        }
        if overlayWatermarkImage == nil {
            overlayWatermarkImage = overlayImage
        }
        if watermarkType == .gif {
            if gifFrames.count == 0,
               let watermarkURL = self.gifWaterMarkURL,
               let imageData = try? Data(contentsOf: watermarkURL) {
                gifFrames = imageData.gifFrames()
                if gifFrames.count > 0 {
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else {
                            return
                        }
                        if (Defaults.shared.appIdentifierWatermarkSetting == .show || Defaults.shared.madeWithGifSetting == .show) && self.socialShareType != .tiktok {
                            self.addWaterMarkImageIfNeeded(isGIF: true)
                        }
                        if Defaults.shared.fastestEverWatermarkSetting == .show && self.socialShareType != .tiktok {
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
                        if (Defaults.shared.appIdentifierWatermarkSetting == .show || Defaults.shared.madeWithGifSetting == .show) && self.socialShareType != .tiktok {
                            self.addWaterMarkImageIfNeeded(isGIF: true)
                        }
                        if Defaults.shared.fastestEverWatermarkSetting == .show && self.socialShareType != .tiktok {
                            self.addFastestEverWaterMarkImage()
                        }
                    }
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {
                    return
                }
                if Defaults.shared.appIdentifierWatermarkSetting == .show && self.socialShareType != .tiktok {
                    self.addWaterMarkImageIfNeeded(isGIF: false)
                }
                if Defaults.shared.fastestEverWatermarkSetting == .show && self.socialShareType != .tiktok {
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
        
        guard let backgroundImage = self.overlayImage,
            let watermarkImage = Defaults.shared.appIdentifierWatermarkSetting == .show ? image : UIImage() else {
                return
        }
        var watermarkGIFImage = UIImage()
        if gifFrames.count != 0 {
            watermarkGIFImage = isGIF ? UIImage(cgImage: gifFrames.remove(at: 0)) : UIImage()
        }
        
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
        
        let watermarkImageSize = CGSize(width: image.size.width * 1.2, height: image.size.height * 1.2)
        let watermarkOrigin = CGPoint(x: 8, y: backgroundImageSize.height - watermarkImageSize.height - 70)
        let watermarkImageRect = CGRect(origin: watermarkOrigin, size: watermarkImageSize)
        image.draw(in: watermarkImageRect, blendMode: .normal, alpha: 1.0)
        
        if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
            self.overlayWatermarkImage = newImage
        }
        UIGraphicsEndImageContext()
    }
    
//    func merge(video videoPath: String, withForegroundImage foregroundImage: UIImage, completion: @escaping (URL?) -> Void) -> () {
//
//        let videoUrl = URL(fileURLWithPath: videoPath)
//        let videoUrlAsset = AVURLAsset(url: videoUrl, options: nil)
//
//        // Setup `mutableComposition` from the existing video
//        let mutableComposition = AVMutableComposition()
//        let videoAssetTrack = videoUrlAsset.tracks(withMediaType: AVMediaType.video).first!
//        let videoCompositionTrack = mutableComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
//        videoCompositionTrack?.preferredTransform = videoAssetTrack.preferredTransform
//        try! videoCompositionTrack?.insertTimeRange(CMTimeRange(start:CMTime.zero, duration:videoAssetTrack.timeRange.duration), of: videoAssetTrack, at: CMTime.zero)
//
//        addAudioTrack(composition: mutableComposition, videoUrl: videoUrl)
//
//        let videoSize: CGSize = (videoCompositionTrack?.naturalSize)!
//        let frame = CGRect(x: 0.0, y: 0.0, width: videoSize.width, height: videoSize.height)
//        let imageLayer = CALayer()
//        imageLayer.contents = foregroundImage.cgImage
//        imageLayer.frame = CGRect(x: 0.0, y: 0.0, width:50, height:50)
//
//        let videoLayer = CALayer()
//        videoLayer.frame = frame
//        let animationLayer = CALayer()
//        animationLayer.frame = frame
//        animationLayer.addSublayer(videoLayer)
//        animationLayer.addSublayer(imageLayer)
//
//        let videoComposition = AVMutableVideoComposition(propertiesOf: (videoCompositionTrack?.asset!)!)
//        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: animationLayer)
//
//        let documentDirectory = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
//        let documentDirectoryUrl = URL(fileURLWithPath: documentDirectory)
//        let destinationFilePath = documentDirectoryUrl.appendingPathComponent("result.mp4")
//        do {
//            if FileManager.default.fileExists(atPath: destinationFilePath.path) {
//
//                try FileManager.default.removeItem(at: destinationFilePath)
//
//                print("removed")
//            }
//        } catch {
//            print(error)
//        }
//        let exportSession = AVAssetExportSession( asset: mutableComposition, presetName: AVAssetExportPresetHighestQuality)!
//        exportSession.videoComposition = videoComposition
//        exportSession.outputURL = destinationFilePath
//        exportSession.outputFileType = AVFileType.mp4
//        exportSession.exportAsynchronously { [weak exportSession] in
//            if let strongExportSession = exportSession {
//                completion(strongExportSession.outputURL!)
//                //self.play(strongExportSession.outputURL!)
//            }
//        }
//    }
    
    func addOutro() -> [UIImage] {
        var overlayImage: UIImage?
        if isQuickApp || isQuickCamLiteApp {
            addWatermarkGifUrl(urlString: "QuickCamOutro")
        }
        if overlayWatermarkImage == nil {
            overlayWatermarkImage = overlayImage
        }
        if gifFrames.count == 0,
           let watermarkURL = self.gifWaterMarkURL,
           let imageData = try? Data(contentsOf: watermarkURL) {
            gifFrames = imageData.gifFrames()
            if gifFrames.count > 0 {
                for frameIndex in 0..<gifFrames.count {
                    overlayImage = self.renderImageOutro(frameIndex: frameIndex)
                    self.outroImgArray.append(overlayImage ?? UIImage())
                }
            }
        }
        gifCount += 1
        return outroImgArray
//        if let overlayImage = overlayImage,
//            let overlayCGImage = overlayImage.cgImage {
//            var ciOverlay = CIImage(cgImage: overlayCGImage)
//            ciOverlay = ciOverlay.transformed(by: CGAffineTransform(scaleX: ciImage.extent.width/overlayImage.size.width, y: ciImage.extent.height/overlayImage.size.height))
//            return ciOverlay.composited(over: ciImage)
//        }
    }

    func renderImageOutro(frameIndex: Int) -> UIImage? {
        guard let backgroundImage = R.image.videoBackground() else {
            return nil
        }
        var watermarkGIFImage = UIImage()
        if gifFrames.count != 0 {
            watermarkGIFImage = UIImage(cgImage: gifFrames[frameIndex])
        }
        let newWatermarkGIFImage = watermarkGIFImage
        
        let backgroundImageSize = backgroundImage.size
        UIGraphicsBeginImageContext(backgroundImageSize)

        let backgroundImageRect = CGRect(origin: .zero, size: backgroundImageSize)
        backgroundImage.draw(in: backgroundImageRect)

        let watermarkGIFImageSize = CGSize(width: backgroundImageSize.width, height: backgroundImageSize.height)
        
        let watermarkGIFOrigin = CGPoint(x: 0, y: 0)

        var watermarkImageRect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 0, height: 0))
        watermarkImageRect = CGRect(origin: watermarkGIFOrigin, size: watermarkGIFImageSize)
        newWatermarkGIFImage.draw(in: watermarkImageRect, blendMode: .normal, alpha: 1.0)
        if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
           return newImage
        }
        UIGraphicsEndImageContext()
        return nil
    }
    
    func mergeVideos(firstVideo: AVAsset, secondVideo: AVAsset, withImage: UIImage, completion: @escaping (_ url: URL) -> ()) -> Void {
        
        let mainComposition = AVMutableComposition()
        let soundtrackTrack = mainComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        var insertTime = CMTime.zero
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTimeAdd(firstVideo.duration, secondVideo.duration))
        
        guard let firstTrack = mainComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else { return }
        do {
            try firstTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: firstVideo.duration), of: firstVideo.tracks(withMediaType: AVMediaType.video)[0], at: insertTime)
            try soundtrackTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: firstVideo.duration), of: firstVideo.tracks(withMediaType: .audio)[0], at: insertTime)
            insertTime = CMTimeAdd(insertTime, firstVideo.duration)
        } catch {
            print("Failed to load track")
            return
        }
        let firstInstruction = videoCompositionInstruction(firstTrack, asset: firstVideo)
//        firstInstruction.setOpacity(0.0, at: firstVideo.duration)
        guard let secondTrack = mainComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else { return }
        do {
            try secondTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: secondVideo.duration), of: secondVideo.tracks(withMediaType: .video)[0], at: insertTime)
        } catch {
            print("Failed to load track")
            return
        }
        let secondInstruction = videoCompositionInstruction(secondTrack, asset: secondVideo)
        
        mainInstruction.layerInstructions = [firstInstruction, secondInstruction]
        let videoComposition = AVMutableVideoComposition()
        videoComposition.instructions = [mainInstruction]
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        videoComposition.renderSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        let videoSize: CGSize = (firstTrack.naturalSize)
        let frame = CGRect(x: 0.0, y: 0.0, width: videoSize.width, height: videoSize.height)
        let imageLayer = CALayer()
        imageLayer.contents = withImage.cgImage
        imageLayer.frame = CGRect(x: 5.0, y: 5.0, width:100, height:100)
        imageLayer.opacity = 1

        let videoLayer = CALayer()
        videoLayer.frame = frame
        let animationLayer = CALayer()
        animationLayer.frame = frame
        animationLayer.addSublayer(videoLayer)
        animationLayer.addSublayer(imageLayer)
        
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: animationLayer)
        
        let outputFileURL = URL(fileURLWithPath: NSHomeDirectory() + "result.mp4")
        
        let fileManager = FileManager()
        do {
            try fileManager.removeItem(at: outputFileURL)
        } catch {
            print(error.localizedDescription)
        }
        if let exporter = AVAssetExportSession(asset: mainComposition, presetName: AVAssetExportPresetPassthrough) {
            exporter.outputURL = outputFileURL
            exporter.videoComposition = videoComposition
            exporter.outputFileType = AVFileType.mp4
            exporter.shouldOptimizeForNetworkUse = true
            exporter.exportAsynchronously {
                DispatchQueue.main.async {
                    completion(outputFileURL)
                }
            }
        }
    }
    
    func orientationFromTransform(_ transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }
    
    func videoCompositionInstruction(_ track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {
      let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
      let assetTrack = asset.tracks(withMediaType: .video)[0]

      let transform = assetTrack.preferredTransform
      let assetInfo = orientationFromTransform(transform)

      var scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.width
      if assetInfo.isPortrait && assetTrack.naturalSize == CGSize(width: 1080, height: 1920) {
        scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.height
        let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
        instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor), at: CMTime.zero)
      } else {
        let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
        var concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.width / 2))
        if assetInfo.orientation == .down {
          let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
          let windowBounds = UIScreen.main.bounds
          let yFix = assetTrack.naturalSize.height + windowBounds.height
          let centerFix = CGAffineTransform(translationX: assetTrack.naturalSize.width, y: yFix)
          concat = fixUpsideDown.concatenating(centerFix).concatenating(scaleFactor)
        }
        instruction.setTransform(concat, at: CMTime.zero)
      }
      return instruction
    }
    
}
