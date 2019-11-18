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

public protocol ShareStoriesDelegate {
    func error(message: String)
    func success()
}

open class SocialShareVideo: NSObject, SharingDelegate {
       
    static let shared: SocialShareVideo = SocialShareVideo()
  
    var delegate: ShareStoriesDelegate?
    
    func sharePhoto(image : UIImage, socialType: SocialShare) {
        switch socialType {
        case .facebook:
            self.fbShareImage(image)
        case .instagram:
            self.saveImageToCameraRoll(image: image, completion: { (result, phAsset) in
                DispatchQueue.runOnMainThread {
                    self.instaImageVideoShare(phAsset!)
                }
            })
        case .snapchat:
            self.snapChatShareImage(image: image)
        default:
            break
        }
    }
    
    func shareVideo(url: URL?, socialType: SocialShare) {
        guard let url = url else { return }
        switch socialType {
        case .facebook, .instagram:
            PHPhotoLibrary.requestAuthorization({ [weak self]
                (newStatus) in
                guard let strongSelf = self else {
                    return
                }
                if newStatus ==  PHAuthorizationStatus.authorized {
                    strongSelf.saveVideoToCameraRoll(url: url, completion: { [weak self] (result, phAsset) in
                        guard let strongSelf = self else {
                            return
                        }
                        DispatchQueue.runOnMainThread {
                            switch socialType {
                            case .facebook:
                                strongSelf.fbShareVideo(phAsset)
                            case .instagram:
                                strongSelf.instaImageVideoShare(phAsset)
                            default:
                                break
                            }
                        }
                    })
                }
            })
        case .snapchat:
            snapChatShareVideo(url)
            break
        case .youtube:
            youTubeUpload(url)
            break
        default:
            break
        }
    }
    
    func youTubeUpload(_ url: URL) {
        DispatchQueue.main.async {
            if let youTubeUploadVC = R.storyboard.youTubeUpload.youTubeUploadViewController() {
                youTubeUploadVC.videoUrl = url
                Utils.appDelegate?.window?.visibleViewController()!.navigationController?.pushViewController(youTubeUploadVC, animated: true)
            }
        }
    }
    
    func showShareDialog<C: SharingContent>(_ content: C, mode: ShareDialog.Mode = .automatic) {
        let dialog = ShareDialog(fromViewController: Utils.appDelegate?.window?.visibleViewController()!, content: content, delegate: self)
        dialog.mode = mode
        dialog.show()
    }
    
    public func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        
    }
    
    public func sharer(_ sharer: Sharing, didFailWithError error: Error) {

        Utils.appDelegate?.window?.makeToast(R.string.localizable.youNeedToInstallFacebookToShareThisPhotoVideo())
    }
    
    public func sharerDidCancel(_ sharer: Sharing) {
        
    }
    
    func saveVideoToCameraRoll(url: URL, completion:@escaping (Bool, PHAsset?) -> ()) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { saved, error in
            if saved {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.fetchLimit = 1
                let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).firstObject
                completion(true, fetchResult)
            } else {
                completion(false, nil)
            }
        }
    }
    
    func saveImageToCameraRoll(image: UIImage, completion:@escaping (Bool, PHAsset?) -> ()) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { saved, error in
            if saved {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.fetchLimit = 1
                let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions).firstObject
                completion(true, fetchResult)
            } else {
                completion(false, nil)
            }
        }
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
    
}
