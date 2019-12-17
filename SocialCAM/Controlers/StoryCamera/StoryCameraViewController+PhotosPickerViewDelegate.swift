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
                    self.takenSlideShowImages.append(SegmentVideos(urlStr: URL.init(string: Constant.Application.imageIdentifier)!, thumbimage: image.fullResolutionImage!, latitued: nil, longitued: nil, placeAddress: nil, numberOfSegement: String(self.takenSlideShowImages.count + 1), videoduration: nil, combineOneVideo: false))
                }
                DispatchQueue.main.async {
                    self.stopMotionCollectionView.reloadData()
                    
                    if self.takenSlideShowImages.count == 20 {
                        self.btnDoneClick(sender: UIButton())
                    }
                }
            } else {
                if withTLPHAssets.count == 1 {
                    if withTLPHAssets[0].assetType == .video {
                        if let videoUrl = withTLPHAssets[0].videoUrl {
                            do {
                                let videodata = try Data(contentsOf: videoUrl)
                                let videoName = String.fileName + FileExtension.mp4.rawValue
                                let data = videodata
                                let url = Utils.getLocalPath(videoName)
                                try? data.write(to: url)
                                if self.recordingType == .custom {
                                    self.takenVideoUrls.append(SegmentVideos(urlStr: url, thumbimage: withTLPHAssets[0].thumbImage, latitued: nil, longitued: nil, placeAddress: nil, numberOfSegement: String(self.takenSlideShowImages.count + 1), videoduration: nil, combineOneVideo: false))
                                    self.stopMotionCollectionView.reloadData()
                                } else {
                                    DispatchQueue.main.async {
                                        self.openSpeedViewControllerForVideo(videoURLs: [SegmentVideos.init(urlStr: url, thumbimage: withTLPHAssets[0].thumbImage, latitued: nil, longitued: nil, placeAddress: nil, numberOfSegement: "\(self.takenVideoUrls.count + 1)", videoduration: nil)])
                                    }
                                }
                            } catch {
                                
                            }
                            
                        } else if let asset = withTLPHAssets[0].asset {
                            let manager = PHImageManager.default()
                            manager.requestAVAsset(forVideo: asset, options: nil) { (avasset, _, _) in
                                if let avassetURL = avasset as? AVURLAsset {
                                    if self.recordingType == .custom {
                                        self.takenVideoUrls.append(SegmentVideos(urlStr: avassetURL.url, thumbimage: withTLPHAssets[0].thumbImage, latitued: nil, longitued: nil, placeAddress: nil, numberOfSegement: String(self.takenSlideShowImages.count + 1), videoduration: nil, combineOneVideo: false))
                                        self.stopMotionCollectionView.reloadData()
                                    } else {
                                        DispatchQueue.main.async {
                                            self.openPhotoEditorForVideo(videoURLs: [SegmentVideos.init(urlStr: avassetURL.url, thumbimage: withTLPHAssets[0].thumbImage, latitued: nil, longitued: nil, placeAddress: nil, numberOfSegement: "\(self.takenVideoUrls.count + 1)", videoduration: nil)],
                                                                         images: [withTLPHAssets[0].thumbImage])
                                        }
                                    }
                                } else {
                                    self.showAlert(alertMessage: R.string.localizable.selectedVideoIsnTSupported())
                                }
                            }
                        }
                    } else {
                        self.recordingType = .normal
                        self.openPhotoEditorForImage(withTLPHAssets[0].fullResolutionImage!)
                    }
                } else {
                    let exportGroup = DispatchGroup()
                    let exportQueue = DispatchQueue(label: Constant.Application.groupIdentifier)
                    let dispatchSemaphore = DispatchSemaphore(value: 0)
                    
                    for video in withTLPHAssets {
                        exportGroup.enter()
                        if let videoUrl = video.videoUrl {
                            do {
                                let videodata = try Data(contentsOf: videoUrl)
                                let videoName = String.fileName + FileExtension.mov.rawValue
                                let data = videodata
                                let url = Utils.getLocalPath(videoName)
                                try? data.write(to: url)
                                self.takenVideoUrls.append(SegmentVideos(urlStr: url, thumbimage: video.thumbImage, latitued: nil, longitued: nil, placeAddress: nil, numberOfSegement: String(self.takenSlideShowImages.count + 1), videoduration: nil, combineOneVideo: false))
                                
                                dispatchSemaphore.signal()
                                exportGroup.leave()
                            } catch {
                                
                            }
                        } else if let asset = video.asset, video.assetType == .video {
                            let manager = PHImageManager.default()
                            manager.requestAVAsset(forVideo: asset, options: nil) { (avasset, _, _) in
                                if let avassetURL = avasset as? AVURLAsset {
                                    DispatchQueue.main.async {
                                        self.takenVideoUrls.append(SegmentVideos(urlStr: avassetURL.url, thumbimage: video.thumbImage, latitued: nil, longitued: nil, placeAddress: nil, numberOfSegement: String(self.takenSlideShowImages.count + 1), videoduration: nil, combineOneVideo: false))
                                    }
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
                            self.takenSlideShowImages.append(SegmentVideos(urlStr: URL.init(string: Constant.Application.imageIdentifier)!, thumbimage: video.fullResolutionImage, latitued: nil, longitued: nil, placeAddress: nil, numberOfSegement: String(self.takenSlideShowImages.count + 1), videoduration: nil, combineOneVideo: false))
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
                            var internalStoryData = [InternalStoryData]()
                            
                            for url in self.takenSlideShowImages {
                                if url.url == URL.init(string: Constant.Application.imageIdentifier) {
                                    let image = url.image!
                                    let storyTime = "3.0"
                                    let fileName = String.fileName + FileExtension.jpg.rawValue
                                    let data = image.jpegData(compressionQuality: 1.0)
                                    let url = Utils.getLocalPath(fileName)
                                    try? data?.write(to: url)
                                    
                                    let storyData = InternalStoryData(address: "", duration: storyTime, lat: "", long: "", thumbTime: 0.0, type: "image", url: url.absoluteString, userId: Defaults.shared.currentUser?.id ?? "", watermarkURL: "", isMute: false, filterName: nil, exportedUrls: [""], hiddenHashtags: nil, tags: nil)
                                    storyData.publish = Defaults.shared.isPublish ? 1 : 0
                                    internalStoryData.append(storyData)
                                } else {
                                    var urls = [String]()
                                    for segementModel in url.videos {
                                        urls.append(segementModel.url?.absoluteString ?? "")
                                    }
                                    let fileName = String.fileName + FileExtension.png.rawValue
                                    let data = url.image!.pngData()
                                    let watermarkURL = Utils.getLocalPath(fileName)
                                    try? data?.write(to: watermarkURL)
                                    
                                    let storyData = InternalStoryData(address: "", duration: "", lat: "", long: "", thumbTime: url.thumbTime!.seconds, type: "video", url: "", userId: Defaults.shared.currentUser?.id ?? "", watermarkURL: watermarkURL.absoluteString, isMute: false, filterName: nil, exportedUrls: urls, hiddenHashtags: nil, tags: nil)
                                    storyData.publish = Defaults.shared.isPublish ? 1 : 0
                                    internalStoryData.append(storyData)
                                }
                            }
                            if Defaults.shared.isPro {
                                _ = StoryDataManager.shared.createStoryUploadData(internalStoryData)
                                StoryDataManager.shared.startUpload()
                                self.takenSlideShowImages.removeAll()
                            } else {
                                if !self.takenSlideShowImages.isEmpty {
                                    self.takenVideoUrls.removeAll()
                                    var tempTakenImagesURLs: [SegmentVideos] = []
                                    for item in self.takenSlideShowImages {
                                        tempTakenImagesURLs.append(item)
                                    }
                                    self.recordingType = .slideshow
                                    self.cameraSliderView.selectCell = self.recordingType.rawValue
                                    
                                    self.takenSlideShowImages = tempTakenImagesURLs
                                } else {
                                    self.takenSlideShowImages.removeAll()
                                    if self.recordingType != .custom {
                                        var tempTakenVideoURLs: [SegmentVideos] = []
                                        for item in self.takenVideoUrls {
                                            tempTakenVideoURLs.append(item)
                                        }
                                        self.recordingType = .custom
                                        self.cameraSliderView.selectCell = self.recordingType.rawValue
                                        self.takenVideoUrls = tempTakenVideoURLs
                                    }
                                }
                                
                                self.stopMotionCollectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
}
