//
//  StoryCameraViewController+PhotosPickerViewDelegate.swift
//  SocialCAM
//
//  Created by Viraj Patel on 17/12/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit
import Photos
import PhotosUI

extension StoryCameraViewController: PhotosPickerViewControllerDelegate {
    
    func dismissPhotoPicker(withTLPHAssets: [ImageAsset]) {
        if !withTLPHAssets.isEmpty {
            if self.recordingType == .slideshow || self.recordingType == .collage {
                for image in withTLPHAssets {
                    self.takenSlideShowImages.append(SegmentVideos(urlStr: URL.init(string: Constant.Application.imageIdentifier)!, thumbimage: image.fullResolutionImage!, numberOfSegement: String(self.takenSlideShowImages.count + 1)))
                }
                DispatchQueue.main.async {
                    self.stopMotionCollectionView.reloadData()
                    if self.takenSlideShowImages.count == 20 {
                        self.btnDoneClick(sender: UIButton())
                    }
                }
            } else {
                let exportGroup = DispatchGroup()
                let exportQueue = DispatchQueue(label: Constant.Application.groupIdentifier)
                let dispatchSemaphore = DispatchSemaphore(value: 0)
                var imageVideoSegments: [SegmentVideos] = []
                
                for video in withTLPHAssets {
                    exportGroup.enter()
                    if let asset = video.asset, video.assetType == .video {
                        if Defaults.shared.appMode == .basic && self.recordingType == .promo && asset.duration >= 31.0 {
                            self.showAlert(alertMessage: R.string.localizable.videoMoreThan30SecondsError())
                            return
                        }
                        if Defaults.shared.appMode == .free && self.recordingType == .promo && asset.duration >= 15.0 {
                            self.showAlert(alertMessage: R.string.localizable.videoMoreThan15SecondsError())
                            return
                        } else if self.recordingType == .normal && asset.duration > 240.0 && isLiteApp {
                            self.showAlert(alertMessage: R.string.localizable.videoMoreThan240SecondsError())
                            return
                        }
                        let options = PHVideoRequestOptions()
                        options.isNetworkAccessAllowed = true  //iCloud video can play
                        options.deliveryMode = .automatic
                        // iCloud download progress
                        options.progressHandler = { (progress, error, stop, info) in

                        }
                        let manager = PHImageManager.default()
                        manager.requestAVAsset(forVideo: asset, options: options) { (avasset, _, _) in
                            if let avassetURL = avasset as? AVURLAsset {
                                let currentAsset = AVAsset(url: avassetURL.url)
                                let assetSize = currentAsset.tracks(withMediaType: .video)[0].naturalSize
                                if assetSize.height >= 2160 { // 3840 × 2160
                                    VideoMediaHelper.shared.compressMovie(asset: currentAsset, filename: String.fileName + ".mp4", quality: .high, deleteSource: true, progressCallback: { _ in
                                        
                                    }) { [weak self] url in
                                        guard let `self` = self else {
                                            return
                                        }
                                        guard let videoUrl = url else {
                                            return
                                        }
                                        imageVideoSegments.append(SegmentVideos(urlStr: videoUrl, thumbimage: video.thumbImage, numberOfSegement: String(self.takenSlideShowImages.count + 1)))
                                        dispatchSemaphore.signal()
                                        exportGroup.leave()
                                    }
                                } else {
                                    imageVideoSegments.append(SegmentVideos(urlStr: avassetURL.url, thumbimage: video.thumbImage, numberOfSegement: String(self.takenSlideShowImages.count + 1)))
                                    dispatchSemaphore.signal()
                                    exportGroup.leave()
                                }
                            } else {
                                self.showAlert(alertMessage: R.string.localizable.selectedVideoIsnTSupported())
                                dispatchSemaphore.signal()
                                exportGroup.leave()
                            }
                        }
                        dispatchSemaphore.wait()
                    } else if video.assetType == .image {
                        imageVideoSegments.append(SegmentVideos(urlStr: URL.init(string: Constant.Application.imageIdentifier)!, thumbimage: video.fullResolutionImage, numberOfSegement: String(self.takenSlideShowImages.count + 1)))
                        dispatchSemaphore.signal()
                        exportGroup.leave()
                    } else {
                        dispatchSemaphore.signal()
                        exportGroup.leave()
                    }
                }
                exportGroup.notify(queue: exportQueue) {
                    print("finished......")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    //DispatchQueue.main.async {
                        if self.recordingType == .custom {
                            self.takenVideoUrls.append(contentsOf: imageVideoSegments)
                            self.settingsButton.isSelected = true
                            self.stopMotionCollectionView.reloadData()
                        } else if self.recordingType == .pic2Art {
                            var images: [UIImage] = []
                            imageVideoSegments.forEach { (segment) in
                                images.append(segment.image ?? UIImage())
                            }
                            self.openStyleTransferVC(images: images)
                        } else {
                            self.openStoryEditor(segementedVideos: imageVideoSegments, photosSelection: true)
                        }
                    }
                }
            }
        }
    }
}
