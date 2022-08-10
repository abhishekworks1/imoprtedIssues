//
//  ProfilePicHelper.swift
//  SocialCAM
//
//  Created by Sanjaysinh Chauhan on 10/08/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

class ProfilePicHelper: NSObject {
    
    var viewController: UIViewController?
    var navigationController: UINavigationController?
    
    var imagePicker: ImagePickerController?
    var socialPlatforms: [String] = []
    var imageSource = ""
    
    init(parentVC: UIViewController, navVC: UINavigationController) {
        self.viewController = parentVC
        self.navigationController = navVC
    }
    
    func openSheet(socialType: ProfileSocialShare) {
        
        switch socialType {
        case .gallery:
            print(socialType)
            self.getImage(fromSourceType: .photoLibrary)
            self.imageSource = ""
        case .camera:
            print(socialType)
            self.getImage(fromSourceType: .camera)
            self.imageSource = ""
        case .instagram:
            print(socialType)
            self.setSocialMediaPicture(socialShareType: .instagram)
        case .snapchat:
//            self.dismissHUD()
            print(socialType)
            self.setSocialMediaPicture(socialShareType: .snapchat)
        case .youTube:
            print(socialType)
            self.setSocialMediaPicture(socialShareType: .youtube)
        case .twitter:
            print(socialType)
            self.setSocialMediaPicture(socialShareType: .twitter)
        case .facebook:
            print(socialType)
            self.setSocialMediaPicture(socialShareType: .facebook)
        }
    }
    
    /// get image from source type
    private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        /// Check is source type available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            
            self.imagePicker = ImagePickerController(parentVC: self.viewController ?? UIViewController(), navVC: self.navigationController!, sourceType: sourceType)
            self.imagePicker?.openImagePicker()
            
        }
    }

}

extension ProfilePicHelper {
    
    func setSocialMediaPicture(socialShareType: SocialConnectionType) {
        self.imageSource = socialShareType.stringValue
        self.socialLogin(socialLogin: socialShareType) { (isLogin) in
            if isLogin {
                self.socialLoadProfile(socialLogin: socialShareType) { socialUserData in
                    if let userData = socialUserData {
                        self.addProfile(userData: userData, completion: {
                        })
                    }
                }
            }
//            self.dismissHUD()
        }
    }
    
    func socialLogin(socialLogin: SocialConnectionType, completion: @escaping (Bool) -> ()) {
        switch socialLogin {
        case .facebook:
            if !FaceBookManager.shared.isUserLogin {
                FaceBookManager.shared.login(controller: self.viewController!, loginCompletion: { (_, _) in
                    completion(true)
                }) { (_, _) in
                    completion(false)
                }
            } else {
                self.socialLoadProfile(socialLogin: socialLogin) { socialUserData in
                    if let userData = socialUserData {
                        self.addProfile(userData: userData, completion: {
                            FaceBookManager.shared.logout()
                        })
                        completion(false)
                    }
                }
            }
        case .twitter:
            if !TwitterManger.shared.isUserLogin {
//                self.dismissHUD()
                TwitterManger.shared.login { (_, _) in
                    completion(true)
                }
            } else {
                self.socialLoadProfile(socialLogin: socialLogin) { socialUserData in
                    if let userData = socialUserData {
                        self.addProfile(userData: userData, completion: {
                        })
                        completion(false)
                    }
                }
            }
        case .instagram:
            if !InstagramManager.shared.isUserLogin {
                let loginViewController: WebViewController = WebViewController()
                loginViewController.delegate = self.viewController! as! InstagramLoginViewControllerDelegate
                
                self.viewController!.present(loginViewController, animated: true) {
                    completion(true)
                }
            } else {
                self.socialLoadProfile(socialLogin: socialLogin) { socialUserData in
                    if let userData = socialUserData {
                        self.addProfile(userData: userData, completion: {
                        })
                        completion(false)
                    }
                }
            }
        case .snapchat:
            if !SnapKitManager.shared.isUserLogin {
                SnapKitManager.shared.login(viewController: self.viewController!) { (isLogin, error) in
                    if !isLogin {
                        DispatchQueue.main.async {
                            self.viewController!.showAlert(alertMessage: error ?? "")
                        }
                    }
                    completion(isLogin)
                }
            } else {
                self.socialLoadProfile(socialLogin: socialLogin) { socialUserData in
                    if let userData = socialUserData {
                        self.addProfile(userData: userData, completion: {
                        })
                    }
                }
            }
        case .youtube:
            if !GoogleManager.shared.isUserLogin {
                GoogleManager.shared.login(controller: self.viewController!, complitionBlock: { (_, _) in
                    completion(true)
                }) { (_, _) in
                    completion(false)
                }
            } else {
                self.socialLoadProfile(socialLogin: socialLogin) { socialUserData in
                    if let userData = socialUserData {
                        self.addProfile(userData: userData, completion: {
                        })
                        completion(false)
                    }
                }
            }
        default:
            break
        }
    }
    
    func socialLoadProfile(socialLogin: SocialConnectionType, completion: @escaping (SocialUserData?) -> ()) {
        switch socialLogin {
        case .facebook:
            if FaceBookManager.shared.isUserLogin {
                FaceBookManager.shared.loadUserData { (userModel) in
                    guard let userData = userModel else {
                        completion(nil)
                        return
                    }
                    completion(SocialUserData(socialId: userModel?.userId ?? "", name: userData.userName, profileURL: userData.photoUrl, type: .facebook))
                }
            } else {
                completion(nil)
            }
        case .twitter:
            if TwitterManger.shared.isUserLogin {
                TwitterManger.shared.loadUserData { (userModel) in
                    guard let userData = userModel else {
                        completion(nil)
                        return
                    }
                    completion(SocialUserData(socialId: userModel?.userId ?? "", name: userData.userName, profileURL: userData.photoUrl, type: .twitter))
                }
            } else {
                completion(nil)
            }
        case .instagram:
            if InstagramManager.shared.isUserLogin {
                if let userModel = InstagramManager.shared.profileDetails {
                    completion(SocialUserData(socialId: userModel.id ?? "", name: userModel.username, profileURL: userModel.profilePicUrl, type: .instagram))
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        case .snapchat:
            if SnapKitManager.shared.isUserLogin {
                SnapKitManager.shared.loadUserData { (userModel) in
                    guard let userData = userModel else {
                        completion(nil)
                        return
                    }
                    completion(SocialUserData(socialId: userModel?.userId ?? "", name: userData.userName, profileURL: userData.photoUrl, type: .snapchat))
                }
            } else {
                completion(nil)
            }
        case .youtube:
            if GoogleManager.shared.isUserLogin {
                GoogleManager.shared.loadUserData { (userModel) in
                    guard let userData = userModel else {
                        completion(nil)
                        return
                    }
                    completion(SocialUserData(socialId: userModel?.userId ?? "", name: userData.userName, profileURL: userData.photoUrl, type: .youtube))
                }
            } else {
                completion(nil)
            }
        default:
            break
        }
    }
    
    func addProfile(userData: SocialUserData, completion: @escaping () -> ()) {
        let userData = userData
        if let url = URL(string: userData.profileURL ?? ""),
           let data = try? Data(contentsOf: url) {
            DispatchQueue.main.async {
//                self.dismissHUD()
                if let img = UIImage(data: data) {
//                    self.isCroppedImage = false
//                    self.uncroppedImg = img
                    self.pushCropVC(img: img)
                }
            }
            completion()
        }
    }
    
    func settingSocialPlatforms() {
        if imageSource != "" {
            self.socialPlatforms.append(self.imageSource.lowercased())
        } else {
            self.socialPlatforms.removeAll(where: {$0 == ""})
        }
        self.addSocialPlatform()
    }
    
    func addSocialPlatform() {
        let previousSocialPlatformCount = Defaults.shared.socialPlatforms?.uniq().count
        self.socialPlatforms = socialPlatforms.uniq()
        if !socialPlatforms.contains("") &&  !(Defaults.shared.socialPlatforms?.contains("") ?? false) {
            Defaults.shared.socialPlatforms?.append(contentsOf: self.socialPlatforms)
        } else {
            Defaults.shared.socialPlatforms?.removeAll(where: {$0 == ""})
        }
        let currentSocialPlatformCount = Defaults.shared.socialPlatforms?.uniq().count
        if currentSocialPlatformCount == 4 && previousSocialPlatformCount == 3 {
//            self.lblSocialBadgeReceived.text = R.string.localizable.congratulationsYouReceivedTheSocialMediaBadge("@\(Defaults.shared.currentUser?.channelId ?? "")")
//            self.showHideSocialBadgePopupView(isHide: false)
        }
        ProManagerApi.addSocialPlatforms(socialPlatforms: Defaults.shared.socialPlatforms?.uniq() ?? []).request(Result<EmptyModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
//            self.storyCameraVC.syncUserModel { (isComplete) in
//                self.getVerifiedSocialPlatforms()
//            }
        }, onError: { error in
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
    
    func pushCropVC(img: UIImage) {
        if let editProfileCropVC = R.storyboard.editProfileViewController.editProfileCropViewController() {
            editProfileCropVC.inputImage = img
            editProfileCropVC.delegate = (self.viewController! as! SharingSocialTypeDelegate)
            self.navigationController?.pushViewController(editProfileCropVC, animated: true)
        }
    }
    
}

class ImagePickerController: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var placeholder: UIImageView?
    var viewController: UIViewController?
    var navigationController: UINavigationController?
    var sourceType = UIImagePickerController.SourceType.photoLibrary
    
    private var imagePicker = UIImagePickerController()
    
    init(parentVC: UIViewController, navVC: UINavigationController, sourceType: UIImagePickerController.SourceType) {
        super.init()
        self.viewController = parentVC
        self.navigationController = navVC
        self.sourceType = sourceType
    }
    
    func openImagePicker() {
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = self.sourceType
        self.viewController!.present(self.imagePicker, animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let localImageUrl = info[.imageURL] as? URL
        if let img = info[.originalImage] as? UIImage,
           let compressedImg = img.jpegData(compressionQuality: 1) {
            var image = img
            let imageSize: Int = compressedImg.count
            let imgSizeInKb = Double(imageSize) / 1000.0
            if imgSizeInKb > 8000.0 {
                if let resizeImage = image.resizeWithWidth(width: 2000) {
                    image = resizeImage
                }
            }
            
            picker.dismiss(animated: true, completion: {
                self.pushCropVC(img: image)
            })
        }
    }
    
    func pushCropVC(img: UIImage) {
        if let editProfileCropVC = R.storyboard.editProfileViewController.editProfileCropViewController() {
            editProfileCropVC.inputImage = img
            editProfileCropVC.delegate = (self.viewController! as! SharingSocialTypeDelegate)
            self.navigationController?.pushViewController(editProfileCropVC, animated: true)
        }
    }
}

// MARK: - InstagramLoginViewControllerDelegate, ProfileDelegate
extension ProfilePicHelper: InstagramLoginViewControllerDelegate, ProfileDelegate {
   
    func profileDidLoad(profile: ProfileDetailsResponse) {
        let optionType = SocialConnectionType.instagram
        self.socialLoadProfile(socialLogin: optionType) { socialUserData in
            if let userData = socialUserData {
                
            }
        }
    }
    
    func profileLoadFailed(error: Error) {
        
    }
   
    func instagramLoginDidFinish(accessToken: String?, error: Error?) {
        if accessToken != nil {
            InstagramManager.shared.delegate = self
            InstagramManager.shared.loadProfile()
        }
    }
}
