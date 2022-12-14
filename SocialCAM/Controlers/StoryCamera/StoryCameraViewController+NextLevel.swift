//
//  StoryCameraViewController+NextLevel.swift
//  SocialCAM
//
//  Created by Viraj Patel on 05/11/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit

extension StoryCameraViewController: NextLevelDeviceDelegate {
    
    func saveFrameRates() {
        var supportedFrameRates: [String]
        if Defaults.shared.videoResolution == .high {
            supportedFrameRates = NextLevel.shared.getAllSupportedFrameRate(dimensions: CMVideoDimensions(width: 1920, height: 1080))
        } else {
            supportedFrameRates = NextLevel.shared.getAllSupportedFrameRate(dimensions: CMVideoDimensions(width: 1280, height: 720))
        }
        Defaults.shared.supportedFrameRates = supportedFrameRates
        print(Defaults.shared.supportedFrameRates ?? "")
    }
    
    func cameraFrameRatesSave() {
        Defaults.shared.selectedFrameRates = "\(Int(NextLevel.shared.frameRate))"
    }
    
    func nextLevel(_ nextLevel: NextLevel, frameRate: CMTimeScale) {
        self.selectedFPS = Float(frameRate)
        cameraFrameRatesSave()
    }
    
    func nextLevelDevicePositionWillChange(_ nextLevel: NextLevel) {
        
    }
    
    func nextLevelDevicePositionDidChange(_ nextLevel: NextLevel) {
        cameraFrameRatesSave()
    }
    
    func nextLevel(_ nextLevel: NextLevel, didChangeDeviceOrientation deviceOrientation: NextLevelDeviceOrientation) {
        saveFrameRates()
    }
    
    func nextLevel(_ nextLevel: NextLevel, didChangeDeviceFormat deviceFormat: AVCaptureDevice.Format) {
        
    }
    
    func nextLevel(_ nextLevel: NextLevel, didChangeCleanAperture cleanAperture: CGRect) {
        
    }
    
    func nextLevel(_ nextLevel: NextLevel, didChangeLensPosition lensPosition: Float) {
        
    }
    
    func nextLevelWillStartFocus(_ nextLevel: NextLevel) {
        
    }
    
    func nextLevelWillChangeExposure(_ nextLevel: NextLevel) {
        
    }
    
    func nextLevelWillChangeWhiteBalance(_ nextLevel: NextLevel) {
        
    }
    
    func nextLevelDidChangeWhiteBalance(_ nextLevel: NextLevel) {
        
    }
    
    func nextLevelDidStopFocus(_  nextLevel: NextLevel) {
        if let focusView = self.focusView {
            if focusView.superview != nil {
                focusView.stopAnimation()
            }
        }
    }
    
    func nextLevelDidChangeExposure(_ nextLevel: NextLevel) {
        if let focusView = self.focusView {
            if focusView.superview != nil {
                focusView.stopAnimation()
            }
        }
    }
}

extension StoryCameraViewController: NextLevelVideoDelegate {
    
    // video zoom
    func nextLevel(_ nextLevel: NextLevel, didUpdateVideoZoomFactor videoZoomFactor: Float) {
    }
    
    // video frame processing
    func nextLevel(_ nextLevel: NextLevel, willProcessRawVideoSampleBuffer sampleBuffer: CMSampleBuffer, onQueue queue: DispatchQueue) {
    }
    
    @available(iOS 11.0, *)
    func nextLevel(_ nextLevel: NextLevel, willProcessFrame frame: AnyObject, timestamp: TimeInterval, onQueue queue: DispatchQueue) {
    }
    
    // enabled by isCustomContextVideoRenderingEnabled
    func nextLevel(_ nextLevel: NextLevel, renderToCustomContextWithImageBuffer imageBuffer: CVPixelBuffer, onQueue queue: DispatchQueue) {
    }
    
    // video recording session
    func nextLevel(_ nextLevel: NextLevel, didSetupVideoInSession session: NextLevelSession) {
        saveFrameRates()
    }
    
    func nextLevel(_ nextLevel: NextLevel, didSetupAudioInSession session: NextLevelSession) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didStartClipInSession session: NextLevelSession) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didCompleteClip clip: NextLevelClip, inSession session: NextLevelSession) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didAppendVideoSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didAppendAudioSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didAppendVideoPixelBuffer pixelBuffer: CVPixelBuffer, timestamp: TimeInterval, inSession session: NextLevelSession) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didSkipVideoPixelBuffer pixelBuffer: CVPixelBuffer, timestamp: TimeInterval, inSession session: NextLevelSession) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didSkipVideoSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didSkipAudioSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didCompleteSession session: NextLevelSession) {
        // called when a configuration time limit is specified
        
    }
    
    // video frame photo
    func nextLevel(_ nextLevel: NextLevel, didCompletePhotoCaptureFromVideoFrame photoDict: [String: Any]?) {
        self.photoTapGestureRecognizer?.isEnabled = true
        self.removeFlashView()
        nextLevel.torchMode = .off
        if let dictionary = photoDict,
            let data = dictionary[NextLevelPhotoJPEGKey] as? Data,
            let image = UIImage(data: data) {
            if isForceCaptureImageWithVolumeKey {
                DispatchQueue.main.async {
                    self.isForceCaptureImageWithVolumeKey = false
                    self.openStoryEditor(images: [image])
                }
            } else if self.recordingType == .pic2Art {
                DispatchQueue.main.async {
                    self.openStyleTransferVC(images: [image], isFromGallery: false)
                }
            } else if self.recordingType == .slideshow || self.recordingType == .collage {
                self.takenSlideShowImages.append(SegmentVideos(urlStr: URL(string: Constant.Application.imageIdentifier)!, thumbimage: image, latitued: nil, longitued: nil, placeAddress: nil, numberOfSegement: String(self.takenSlideShowImages.count + 1), videoduration: nil, combineOneVideo: false))
                
                DispatchQueue.main.async {
                    self.stopMotionCollectionView.reloadData()
                    let layout = self.stopMotionCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
                    let pageSide = (layout?.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
                    self.stopMotionCollectionView?.contentOffset.x = (self.stopMotionCollectionView?.contentSize.width)! + pageSide
                    
                    if self.takenSlideShowImages.count == 20 {
                        self.btnDoneClick(sender: UIButton())
                    }
                }
            } else if self.recordingType != .capture {
                DispatchQueue.main.async {
                    self.openStoryEditor(images: [image])
                }
            } else if self.recordingType == .capture {
                SCAlbum.shared.save(image: image) { (isSuccess) in
                    if isSuccess {
                        DispatchQueue.main.async {
                            self.view.makeToast(R.string.localizable.photoSaved(), duration: 2.0, position: .top)
                        }
                    } else {
                        self.view.makeToast(R.string.localizable.pleaseGivePhotosAccessFromSettingsToSaveShareImageOrVideo())
                    }
                }
            }
        }
    }
}

extension StoryCameraViewController: NextLevelMetadataOutputObjectsDelegate {
    
    func metadataOutputObjects(_ nextLevel: NextLevel, didOutput metadataObjects: [AVMetadataObject]) {
        guard let previewView = self.previewView else {
            return
        }
        
        if let metadataObjectViews = metadataObjectViews {
            for view in metadataObjectViews {
                view.removeFromSuperview()
            }
            self.metadataObjectViews = nil
        }
        
        self.metadataObjectViews = metadataObjects.map { metadataObject in
            let view = UIView(frame: metadataObject.bounds)
            view.backgroundColor = UIColor.clear
            view.layer.borderColor = UIColor.yellow.cgColor
            view.layer.borderWidth = 1
            return view
        }
        
        if let metadataObjectViews = self.metadataObjectViews {
            for view in metadataObjectViews {
                previewView.addSubview(view)
            }
        }
    }
}
