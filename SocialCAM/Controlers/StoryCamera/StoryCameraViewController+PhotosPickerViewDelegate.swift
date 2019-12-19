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
                    if let videoUrl = video.videoUrl {
                        do {
                            let videodata = try Data(contentsOf: videoUrl)
                            let videoName = String.fileName + FileExtension.mov.rawValue
                            let data = videodata
                            let url = Utils.getLocalPath(videoName)
                            try? data.write(to: url)
                            imageVideoSegments.append(SegmentVideos(urlStr: url, thumbimage: video.thumbImage, numberOfSegement: String(self.takenSlideShowImages.count + 1)))
                            dispatchSemaphore.signal()
                            exportGroup.leave()
                        } catch {
                            
                        }
                    } else if let asset = video.asset, video.assetType == .video {
                        let manager = PHImageManager.default()
                        manager.requestAVAsset(forVideo: asset, options: nil) { (avasset, _, _) in
                            if let avassetURL = avasset as? AVURLAsset {
                                imageVideoSegments.append(SegmentVideos(urlStr: avassetURL.url, thumbimage: video.thumbImage, numberOfSegement: String(self.takenSlideShowImages.count + 1)))
                                dispatchSemaphore.signal()
                                exportGroup.leave()
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
                    DispatchQueue.main.async {
                        if self.recordingType == .custom {
                            self.takenVideoUrls.append(contentsOf: imageVideoSegments)
                            self.stopMotionCollectionView.reloadData()
                        } else {
                            self.openStoryEditor(segementedVideos: imageVideoSegments)
                        }
                    }
                }
            }
        }
    }
}
