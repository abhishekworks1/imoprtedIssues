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
    
    func copyLink(referType: ReferType = .none) {
        var attachmentUrl: String = ""
        switch referType {
        case .viralCam:
            attachmentUrl = Defaults.shared.currentUser?.viralcamReferralLink ?? websiteUrl
            UIPasteboard.general.string = attachmentUrl
        case .socialCam:
            attachmentUrl = Constant.URLs.socialCamWebsiteURL
            UIPasteboard.general.string = attachmentUrl
        case .tiktokShare:
            attachmentUrl = Defaults.shared.postViralCamModel?.referLink ?? ""
            UIPasteboard.general.string = attachmentUrl
        case .pic2art:
            attachmentUrl = "\(Constant.URLs.pic2ArtWebsiteURL)/referral/\(Defaults.shared.currentUser?.referralCode ?? "")"
            UIPasteboard.general.string = attachmentUrl
        case .soccercam:
            attachmentUrl = "\(Constant.URLs.soccercamWebsiteURL)/referral/\(Defaults.shared.currentUser?.referralCode ?? "")"
            UIPasteboard.general.string = attachmentUrl
        case .futbolcam:
            attachmentUrl = "\(Constant.URLs.futbolWebsiteURL)/referral/\(Defaults.shared.currentUser?.referralCode ?? "")"
            UIPasteboard.general.string = attachmentUrl
        default:
            break
        }
    }
    
    func sharePhoto(image: UIImage, socialType: SocialShare, referType: ReferType = .none) {
        self.copyLink(referType: referType)
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
            self.snapChatShareImage(image: image, referType: referType)
        case .tiktok:
            if !TiktokShare.shared.isTiktokInstalled {
                Utils.customaizeToastMessage(title: R.string.localizable.youNeedToInstallTikTokToShareThisPhotoVideo(), toastView: (Utils.appDelegate?.window)!)
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
        case .storiCam, .storiCamPost:
            storiCamShareImage(image, socialType: socialType)
        default:
            break
        }
    }
    
    func shareVideo(url: URL?, socialType: SocialShare, referType: ReferType = .none) {
        guard let url = url else { return }
        self.copyLink(referType: referType)
        switch socialType {
        case .facebook, .instagram, .fbMessanger:
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
                        case .fbMessanger:
                            self.fbMessangerShareVideo(phAsset)
                        default:
                            break
                        }
                    }
                }
            })
        case .snapchat:
            snapChatShareVideo(url, referType: referType)
        case .twitter:
            twitterShareCompose(url: url)
        case .youtube:
            youTubeUpload(url)
        case .tiktok:
            if !TiktokShare.shared.isTiktokInstalled {
                Utils.customaizeToastMessage(title: R.string.localizable.youNeedToInstallTikTokToShareThisPhotoVideo(), toastView: (Utils.appDelegate?.window)!)
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
        case .storiCam, .storiCamPost:
            storiCamShareVideo(url, socialType: socialType)
        case .whatsApp:
            self.whatsAppShareVideo(url)
        case .more:
            print(url)
        }
    }
    
    func twitterShareCompose(image: UIImage? = nil, url: URL? = nil, text: String = Constant.Application.displayName) {
    
        var displayMessage = text
        if isSocialCamApp {
            displayMessage = R.string.localizable.checkOutThisCoolNewAppSocialCam()
        } else if isViralCamApp {
            displayMessage = R.string.localizable.checkOutThisCoolNewAppViralCam()
        } else if isSoccerCamApp {
            displayMessage = R.string.localizable.checkOutThisCoolNewAppSoccerCam()
        } else if isFutbolCamApp {
            displayMessage = R.string.localizable.checkOutThisCoolNewAppFutbolCam()
        } else if isSnapCamApp {
            displayMessage = R.string.localizable.checkOutThisCoolNewAppSnapCam()
        } else if isSpeedCamApp {
            displayMessage = R.string.localizable.speedCam()
        } else if isTimeSpeedApp {
            displayMessage = R.string.localizable.checkOutThisCoolNewAppTimeSpeed()
        } else if isFastCamApp {
            displayMessage = R.string.localizable.checkOutThisCoolNewAppFastCam()
        } else if isBoomiCamApp {
            displayMessage = R.string.localizable.checkOutThisCoolNewAppBoomiCam()
        } else if isPic2ArtApp {
            displayMessage = R.string.localizable.checkOutThisCoolNewAppPic2Art()
        } else if isQuickCamApp {
            displayMessage = R.string.localizable.checkOutThisCoolNewAppQuickCam()
        }
        displayMessage.append(" ")
        displayMessage.append("\(websiteUrl)/\(Defaults.shared.currentUser?.channelName ?? "")")
        if let twitterComposeViewController = R.storyboard.twitterCompose.twitterComposeViewController() {
            twitterComposeViewController.presetText = displayMessage
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
    
    func showFBMessangeShareDialog<C: SharingContent>(_ content: C, mode: ShareDialog.Mode = .automatic) {
        
        let dialog = MessageDialog(content: content, delegate: self)
        
        dialog.show()
    }
    
    public func sharer(_ sharer: Sharing, didCompleteWithResults results: [String: Any]) {
        
    }
    
    public func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        Utils.customaizeToastMessage(title: R.string.localizable.youNeedToInstallFacebookToShareThisPhotoVideo(), toastView: (Utils.appDelegate?.window)!)
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
    
    func fbMessangerShareVideo(_ phAsset: PHAsset?) {
        guard let phAsset = phAsset else { return }
        let content = ShareVideoContent()
        content.video = ShareVideo(videoAsset: phAsset)
        showFBMessangeShareDialog(content)
    }
    
    func whatsAppShareVideo(_ videoUrl: URL) {

        let documentInteractionController = UIDocumentInteractionController()
        documentInteractionController.url = URL(fileURLWithPath: videoUrl.absoluteString)
        documentInteractionController.uti = "public.movie"
//        Utils.appDelegate?.window?.visibleViewController()!.present(documentInteractionController, animated: true, completion: nil)
        documentInteractionController.presentOpenInMenu(from: .zero, in: Utils.appDelegate!.window!.visibleViewController()!.view, animated: true)
        
        
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
                Utils.customaizeToastMessage(title: R.string.localizable.youNeedToInstallInstagramToShareThisPhotoVideo(), toastView: (Utils.appDelegate?.window)!)
            }
        }
    }
    
    func tikTokImageVideoShare(_ phAsset: PHAsset?, isImage: Bool = false) {
        guard let phAsset = phAsset else { return }
        TiktokShare.shared.uploadImageOrVideoOnTiktok(phAsset: phAsset, isImage: isImage)
    }
    
    func snapChatShareImage(image: UIImage, referType: ReferType) {
        let photo = SCSDKSnapPhoto(image: image)
        let snapPhoto = SCSDKPhotoSnapContent(snapPhoto: photo)
        switch referType {
        case .viralCam:
            snapPhoto.attachmentUrl = websiteUrl
        case .socialCam:
            snapPhoto.attachmentUrl = Constant.URLs.socialCamWebsiteURL
        case .tiktokShare:
            snapPhoto.attachmentUrl = Defaults.shared.postViralCamModel?.referLink
        case .pic2art:
            snapPhoto.attachmentUrl = "\(Constant.URLs.pic2ArtWebsiteURL)/referral/\(Defaults.shared.currentUser?.referralCode ?? "")"
        case .soccercam:
            snapPhoto.attachmentUrl = "\(Constant.URLs.soccercamWebsiteURL)/referral/\(Defaults.shared.currentUser?.referralCode ?? "")"
        case .futbolcam:
            snapPhoto.attachmentUrl = "\(Constant.URLs.futbolWebsiteURL)/referral/\(Defaults.shared.currentUser?.referralCode ?? "")"
        default:
            break
        }
        snapChatShare(snapContent: snapPhoto)
    }
    
    func snapChatShareVideo(_ videoUrl: URL, referType: ReferType) {
        let video = SCSDKSnapVideo(videoUrl: videoUrl)
        let snapVideo = SCSDKVideoSnapContent(snapVideo: video)
        switch referType {
        case .viralCam:
            snapVideo.attachmentUrl = Defaults.shared.currentUser?.viralcamReferralLink ?? websiteUrl
        case .socialCam:
            snapVideo.attachmentUrl = Constant.URLs.socialCamWebsiteURL
        case .tiktokShare:
            snapVideo.attachmentUrl = Defaults.shared.postViralCamModel?.referLink
        case .pic2art:
            snapVideo.attachmentUrl = "\(Constant.URLs.pic2ArtWebsiteURL)/referral/\(Defaults.shared.currentUser?.referralCode ?? "")"
        case .soccercam:
            snapVideo.attachmentUrl = "\(Constant.URLs.soccercamWebsiteURL)/referral/\(Defaults.shared.currentUser?.referralCode ?? "")"
        case .futbolcam:
            snapVideo.attachmentUrl = "\(Constant.URLs.futbolWebsiteURL)/referral/\(Defaults.shared.currentUser?.referralCode ?? "")"
        case .quickCamLite:
            snapVideo.attachmentUrl = "\(websiteUrl)/\(Defaults.shared.currentUser?.channelId ?? "")"
        case .quickApp:
            snapVideo.attachmentUrl = "\(websiteUrl)/\(Defaults.shared.currentUser?.channelId ?? "")"
        case .vidPlay:
            snapVideo.attachmentUrl = "\(vidplayWebsiteUrl)/\(Defaults.shared.currentUser?.channelId ?? "")"
        case .businessCenter:
            snapVideo.attachmentUrl = "\(businessCenterWebsiteUrl)/\(Defaults.shared.currentUser?.channelId ?? "")"
        case .enterLink:
            snapVideo.attachmentUrl = "\(Defaults.shared.enterLinkValue)"
        case .noLink:
            snapVideo.attachmentUrl = ""
        default:
            break
        }
        snapChatShare(snapContent: snapVideo)
    }
    
    func snapChatShare(snapContent: SCSDKSnapContent) {
        snapContent.attachmentUrl = "\(websiteUrl)"
        if let channelId = Defaults.shared.currentUser?.channelId {
            snapContent.attachmentUrl = "\(websiteUrl)/\(channelId)"
        }
        
        let api = SCSDKSnapAPI.init(content: snapContent)
        api.startSnapping { _ in
           
        }
    }
    
    func storiCamShareImage(_ image: UIImage, socialType: SocialShare) {
        StoriCamManager.shared.uploadImage(image: image, socialType: socialType)
    }
    
    func storiCamShareVideo(_ videoUrl: URL, socialType: SocialShare) {
        StoriCamManager.shared.uploadVideo(videoUrl: videoUrl, socialType: socialType)
    }
    
}
