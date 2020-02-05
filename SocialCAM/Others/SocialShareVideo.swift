//
//  SocialShareVideo.swift
//  SocialCAM
//
//  Created by Viraj Patel on 11/11/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import Photos
import AVKit
import FBSDKShareKit
import SCSDKCreativeKit

public protocol ShareStoriesDelegate: class {
    func error(message: String)
    func success()
}

open class SocialShareVideo: NSObject, SharingDelegate {
       
    static let shared: SocialShareVideo = SocialShareVideo()
  
    weak var delegate: ShareStoriesDelegate?
    
    func sharePhoto(image: UIImage, socialType: SocialShare) {
        switch socialType {
        case .facebook:
            self.fbShareImage(image)
        case .instagram:
            self.saveImageToCameraRoll(image: image, completion: { [weak self] (_, phAsset) in
                guard let `self` = self else {
                    return
                }
                DispatchQueue.runOnMainThread {
                    if let asset = phAsset {
                        self.instaImageVideoShare(asset)
                    }
                }
            })
        case .twitter:
            twitterShareCompose(image: image)
        case .snapchat:
            self.snapChatShareImage(image: image)
        case .tiktok:
            if !TiktokShare.shared.isTiktokInstalled {
                Utils.appDelegate?.window?.makeToast(R.string.localizable.youNeedToInstallTikTokToShareThisPhotoVideo())
                return
            }
            self.saveImageToCameraRoll(image: image, completion: { [weak self] (_, phAsset) in
                guard let `self` = self else {
                    return
                }
                DispatchQueue.runOnMainThread {
                    if let asset = phAsset {
                        self.tikTokImageVideoShare(asset, isImage: true)
                    }
                }
            })
        case .storiCam:
            storiCamShareImage(image)
        default:
            break
        }
    }
    
    func shareVideo(url: URL?, socialType: SocialShare) {
        guard let url = url else { return }
        switch socialType {
        case .facebook, .instagram:
            self.saveVideoToCameraRoll(url: url, completion: { [weak self] (isSuccess, phAsset) in
                guard let `self` = self else {
                    return
                }
                if isSuccess {
                    DispatchQueue.runOnMainThread {
                        switch socialType {
                        case .facebook:
                            self.fbShareVideo(phAsset)
                        case .instagram:
                            self.instaImageVideoShare(phAsset)
                        default:
                            break
                        }
                    }
                }
            })
        case .snapchat:
            snapChatShareVideo(url)
        case .twitter:
            twitterShareCompose(url: url)
        case .youtube:
            youTubeUpload(url)
        case .tiktok:
            if !TiktokShare.shared.isTiktokInstalled {
                Utils.appDelegate?.window?.makeToast(R.string.localizable.youNeedToInstallTikTokToShareThisPhotoVideo())
                return
            }
            self.saveVideoToCameraRoll(url: url) { [weak self] (isSuccess, phAsset) in
                guard let `self` = self else {
                    return
                }
                if isSuccess {
                    DispatchQueue.runOnMainThread {
                        if let asset = phAsset {
                            self.tikTokImageVideoShare(asset)
                        }
                    }
                }
            }
        case .storiCam:
            storiCamShareVideo(url)
            break
        }
    }
    
    func twitterShareCompose(image: UIImage? = nil, url: URL? = nil, text: String = Constant.Application.displayName) {
    
        if let twitterComposeViewController = R.storyboard.twitterCompose.twitterComposeViewController() {
            twitterComposeViewController.presetText = text
            if let image = image {
                twitterComposeViewController.preselectedImage = image
            } else if let url = url {
                twitterComposeViewController.preselectedVideoUrl = url
            }
           let navController = UINavigationController(rootViewController: twitterComposeViewController)
            Utils.appDelegate?.window?.visibleViewController()!.present(navController, animated: true, completion: nil)
        }
    }
    
    func youTubeUpload(_ url: URL) {
        DispatchQueue.main.async {
            if let youTubeUploadVC = R.storyboard.youTubeUpload.youTubeUploadViewController() {
                youTubeUploadVC.videoUrl = url
                let navYouTubeUpload = UINavigationController(rootViewController: youTubeUploadVC)
                navYouTubeUpload.navigationBar.isHidden = true
                Utils.appDelegate?.window?.visibleViewController()!.present(navYouTubeUpload, animated: true)
            }
        }
    }
    
    func showShareDialog<C: SharingContent>(_ content: C, mode: ShareDialog.Mode = .automatic) {
        let dialog = ShareDialog(fromViewController: Utils.appDelegate?.window?.visibleViewController()!, content: content, delegate: self)
        dialog.mode = mode
        dialog.show()
    }
    
    public func sharer(_ sharer: Sharing, didCompleteWithResults results: [String: Any]) {
        
    }
    
    public func sharer(_ sharer: Sharing, didFailWithError error: Error) {

        Utils.appDelegate?.window?.makeToast(R.string.localizable.youNeedToInstallFacebookToShareThisPhotoVideo())
    }
    
    public func sharerDidCancel(_ sharer: Sharing) {
        
    }
    
    func saveVideoToCameraRoll(url: URL, completion:@escaping (Bool, PHAsset?) -> Void) {
        PHPhotoLibrary.requestAuthorization({ newStatus in
            if newStatus ==  PHAuthorizationStatus.authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                }, completionHandler: { (saved, _) in
                    if saved {
                        let fetchOptions = PHFetchOptions()
                        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                        fetchOptions.fetchLimit = 1
                        let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).firstObject
                        completion(true, fetchResult)
                    } else {
                        completion(false, nil)
                    }
                })
            } else {
                completion(false, nil)
            }
        })
    }
    
    func saveImageToCameraRoll(image: UIImage, completion:@escaping (Bool, PHAsset?) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: { saved, _ in
            if saved {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.fetchLimit = 1
                let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions).firstObject
                completion(true, fetchResult)
            } else {
                completion(false, nil)
            }
        })
    }
    
    func fbShareImage(_ image: UIImage) {
        let photo = SharePhoto(image: image, userGenerated: true)
        photo.caption = Constant.Application.displayName
        let content = SharePhotoContent()
        content.photos = [photo]
        showShareDialog(content)
    }
    
    func fbShareVideo(_ phAsset: PHAsset?) {
        guard let phAsset = phAsset else { return }
        let content = ShareVideoContent()
        content.video = ShareVideo(videoAsset: phAsset)
        showShareDialog(content)
    }
    
    func instaImageVideoShare(_ phAsset: PHAsset?) {
        guard let phAsset = phAsset else { return }
        let localIdentifier = phAsset.localIdentifier
        let urlFeed = Constant.Instagram.link + localIdentifier
        guard let url = URL(string: urlFeed) else {
            self.delegate?.error(message: R.string.localizable.youNeedToInstallInstagramToShareThisPhotoVideo())
            return
        }
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                    self.delegate?.success()
                })
            } else {
                Utils.appDelegate?.window?.makeToast(R.string.localizable.youNeedToInstallInstagramToShareThisPhotoVideo())
            }
        }
    }
    
    func tikTokImageVideoShare(_ phAsset: PHAsset?, isImage: Bool = false) {
        guard let phAsset = phAsset else { return }
        TiktokShare.shared.uploadImageOrVideoOnTiktok(phAsset: phAsset, isImage: isImage)
    }
    
    func snapChatShareImage(image: UIImage) {
        let photo = SCSDKSnapPhoto(image: image)
        let snapPhoto = SCSDKPhotoSnapContent(snapPhoto: photo)
        snapChatShare(snapContent: snapPhoto)
    }
    
    func snapChatShareVideo(_ videoUrl: URL) {
        let video = SCSDKSnapVideo(videoUrl: videoUrl)
        let snapVideo = SCSDKVideoSnapContent(snapVideo: video)
        snapChatShare(snapContent: snapVideo)
    }
    
    func snapChatShare(snapContent: SCSDKSnapContent) {
        snapContent.caption = Constant.Application.displayName
        let api = SCSDKSnapAPI.init(content: snapContent)
        api.startSnapping { _ in
           
        }
    }
    
    func storiCamShareImage(_ image: UIImage) {
        StoriCamManager.shared.uploadImage(image: image)
    }
    
    func storiCamShareVideo(_ videoUrl: URL) {
        StoriCamManager.shared.uploadVideo(videoUrl: videoUrl)
    }
    
}
