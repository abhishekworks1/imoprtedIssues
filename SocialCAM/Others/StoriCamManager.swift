//
//  StoriCamManager.swift
//  SocialCAM
//
//  Created by Viraj Patel on 05/02/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation

protocol StoriCamManagerDelegate: class {
    func loginDidFinish(user: User?, error: Error?)
}

open class StoriCamManager: NSObject {
    
    static let shared: StoriCamManager = StoriCamManager()
    
    var userData: LoginUserData? = nil
    var isShareImageVideo: Bool = false
    
    var image: UIImage?
    var videoURL: URL?
    var socialType: SocialShare = .storiCam
    
    weak var delegate: StoriCamManagerDelegate?
    
    var isUserLogin: Bool {
        return Defaults.shared.currentUser != nil ? true : false
    }
    
    func loadUserData(completion: @escaping (_ userModel: LoginUserData?) -> ()) {
        if isUserLogin {
            if let existUserData = userData {
                completion(existUserData)
                return
            }
            if let currentUser = Defaults.shared.currentUser {
                let userData = LoginUserData(userId: "\(currentUser.id!))", userName: currentUser.username, email: currentUser.email, gender: 0, photoUrl: currentUser.profileImageURL)
                completion(userData)
                return
            }
        } else {
            completion(nil)
        }
    }
        
    public override init() {
        super.init()
        
    }
    
    func login(controller: UIViewController, completion: @escaping (Bool, String?) -> Void) {
        guard let loginViewController = R.storyboard.loginViewController.loginViewController() else {
            return
        }
        loginViewController.delegate = self
        controller.present(loginViewController, animated: true) {
            completion(false, nil)
        }
    }
    
    func uploadImage(withText text: String = Constant.Application.displayName, image: UIImage, socialType: SocialShare) {
        isShareImageVideo = !isUserLogin
        self.socialType = socialType
        self.image = image
        self.videoURL = nil
        if isUserLogin {
            self.uploadStoryCam()
        } else {
            self.login()
        }
    }
    
    func uploadVideo(withText text: String = Constant.Application.displayName, videoUrl: URL, socialType: SocialShare) {
        isShareImageVideo = !isUserLogin
        self.socialType = socialType
        self.image = nil
        self.videoURL = videoUrl
        if isUserLogin {
            self.uploadStoryCam()
        } else {
            self.login()
        }
    }
    
    func login() {
        login(controller: Utils.appDelegate!.window!.rootViewController!) { (_, _) in
            
        }
    }
    
    func uploadStoryCam() {
        if let image = self.image {
            let fileName = String.fileName + FileExtension.jpg.rawValue
            let data = image.jpegData(compressionQuality: 1.0)
            let url = Utils.getLocalPath(fileName)
            try? data?.write(to: url)
            
            if socialType == .storiCam {
                let storyData = InternalStoryData(thumbTime: 0.0, type: "image", url: url.absoluteString, userId: Defaults.shared.currentUser?.id ?? "", watermarkURL: "", exportedUrls: [], tags: nil)
                _ = StoryDataManager.shared.createStoryUploadData([storyData])
            } else {
                let mediaUrls: [String] = [url.absoluteString]
                let postData = InternalPostData(postType: "image", mediaUrls: mediaUrls, privacy: "Public", userID: Defaults.shared.currentUser?.id ?? "", thumbTime: 0, actionType: "create")
                _ = PostDataManager.shared.createPostUploadData(postData)
            }
        } else if let videoUrl = videoURL {
            let mediaUrls: [String] = [videoUrl.absoluteString]
            let fileName = String.fileName + FileExtension.png.rawValue
            guard let thumb = UIImage.getThumbnailFrom(videoUrl: videoUrl) else {
                return
            }
            let data = thumb.pngData()
            let watermarkURL = Utils.getLocalPath(fileName)
            try? data?.write(to: watermarkURL)
            
            if socialType == .storiCam {
                let storyData = InternalStoryData(thumbTime: 0.0, type: "video", url: videoUrl.absoluteString, userId: Defaults.shared.currentUser?.id ?? "", watermarkURL: watermarkURL.absoluteString, exportedUrls: mediaUrls, tags: nil)
                _ = StoryDataManager.shared.createStoryUploadData([storyData])
            } else {
                let postData = InternalPostData(postType: "video", mediaUrls: mediaUrls, privacy: "Public", userID: Defaults.shared.currentUser?.id ?? "", thumbTime: 0, actionType: "create")
                _ = PostDataManager.shared.createPostUploadData(postData)
            }
        }
        StoryDataManager.shared.startUpload()
        PostDataManager.shared.startUpload()
        Utils.appDelegate?.window?.makeToast(R.string.localizable.postSuccess())
    }
    
    func logout() {
        self.userData = nil
        Defaults.shared.currentUser = nil
        CurrentUser.shared.setActiveUser(nil)
    }
}

extension StoriCamManager: LoginViewControllerDelegate {
    
    func loginDidFinish(user: User?, error: Error?, fromSignup: Bool) {
        if !isShareImageVideo {
            delegate?.loginDidFinish(user: user, error: error)
        } else {
            if user != nil {
                uploadStoryCam()
            }
        }
    }
    
}
