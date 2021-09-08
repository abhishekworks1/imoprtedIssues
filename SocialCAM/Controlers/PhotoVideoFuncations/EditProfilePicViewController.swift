//
//  EditProfilePicViewController.swift
//  SocialCAM
//
//  Created by Nilisha Gupta on 07/07/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit
import AVKit

protocol SharingSocialTypeDelegate {
    func shareSocialType(socialType: ProfileSocialShare)
    func setCroppedImage(croppedImg: UIImage)
}

class EditProfilePicViewController: UIViewController {
    
    // MARK: - Outlets declaration
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var btnProfilePic: UIButton!
    @IBOutlet weak var btnPlusButton: UIButton!
    @IBOutlet weak var lblSocialSharePopup: UILabel!
    @IBOutlet weak var socialSharePopupView: UIView!
    
    // MARK: - Variables declaration
    private var localImageUrl: URL?
    private var imagePicker = UIImagePickerController()
    var storyCameraVCInstance = StoryCameraViewController()
    var isSignUpFlow: Bool = false
    var isImageSelected = false
    var imageSource = ""
    var socialPlatforms: [String] = []
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
            if userImageURL.isEmpty {
                imgProfilePic.image = R.image.userIconWithPlus()
                return
            }
            imgProfilePic.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: R.image.user_placeholder())
            imgProfilePic.layer.cornerRadius = imgProfilePic.bounds.width / 2
            imgProfilePic.contentMode = .scaleAspectFill
            btnProfilePic.layer.cornerRadius = btnProfilePic.bounds.width / 2
        } else {
            imgProfilePic.image = R.image.userIconWithPlus()
        }
        self.view.isUserInteractionEnabled = true
    }
    
    func showHidePopupView(isHide: Bool) {
        self.socialSharePopupView.isHidden = isHide
    }
    
    // MARK: - Action Methods
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.setupMethod()
    }
    
    @IBAction func btnUpdateTapped(_ sender: UIButton) {
        self.openSocialShareVC()
    }
    
    @IBAction func btnOKTapped(_ sender: UIButton) {
        if isImageSelected {
            showHidePopupView(isHide: false)
        }
    }
    
    @IBAction func btnYesTapped(_ sender: UIButton) {
        showHidePopupView(isHide: true)
        if let img = imgProfilePic.image {
            self.showHUD()
            self.view.isUserInteractionEnabled = false
            self.updateProfilePic(image: img)
        }
    }
    
    @IBAction func btnNoTapped(_ sender: UIButton) {
        showHidePopupView(isHide: true)
    }
    
}

// MARK: - Camera and Photo gallery methods
extension EditProfilePicViewController {
    
    /// get image from source type
    private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        /// Check is source type available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    /// Delete Image
    private func deleteImage() {
        self.imgProfilePic.image = UIImage()
    }
    
    func openSheet(socialType: ProfileSocialShare) {
        self.isImageSelected = true
        switch socialType {
        case .gallery:
            self.lblSocialSharePopup.text = R.string.localizable.wouldYouLikeToSaveProfilePictureFromGallery()
            self.getImage(fromSourceType: .photoLibrary)
        case .camera:
            self.lblSocialSharePopup.text = R.string.localizable.wouldYouLikeToSaveProfilePictureFromCamera()
            self.getImage(fromSourceType: .camera)
        case .instagram:
            self.lblSocialSharePopup.text = R.string.localizable.wouldYouLikeToSaveProfilePictureFromInstagram()
            self.setSocialMediaPicture(socialShareType: .instagram)
        case .snapchat:
            self.lblSocialSharePopup.text = R.string.localizable.wouldYouLikeToSaveProfilePictureFromSnapchat()
            self.setSocialMediaPicture(socialShareType: .snapchat)
        case .youTube:
            self.lblSocialSharePopup.text = R.string.localizable.wouldYouLikeToSaveProfilePictureFromYoutube()
            self.setSocialMediaPicture(socialShareType: .youtube)
        case .twitter:
            self.lblSocialSharePopup.text = R.string.localizable.wouldYouLikeToSaveProfilePictureFromTwitter()
            self.setSocialMediaPicture(socialShareType: .twitter)
        case .facebook:
            self.lblSocialSharePopup.text = R.string.localizable.wouldYouLikeToSaveProfilePictureFromFacebook()
            self.setSocialMediaPicture(socialShareType: .facebook)
        }
    }
    
    func setSocialMediaPicture(socialShareType: SocialConnectionType) {
        self.imageSource = socialShareType.stringValue
        self.socialLogin(socialLogin: socialShareType) { (isLogin) in
            if isLogin {
                self.socialLoadProfile(socialLogin: socialShareType) { socialUserData in
                    if let userData = socialUserData {
                        self.addProfile(userData: userData, completion: {
                            self.socialPlatforms.append(self.imageSource.lowercased())
                            self.addSocialPlatform()
                        })
                    }
                }
            }
        }
    }
    
    func openSocialShareVC() {
        if let editProfileSocialShareVC = R.storyboard.editProfileViewController.editProfileSocialShareViewController() {
            editProfileSocialShareVC.modalPresentationStyle = .overFullScreen
            editProfileSocialShareVC.delegate = self
            navigationController?.present(editProfileSocialShareVC, animated: true, completion: {
                editProfileSocialShareVC.backgroundUpperView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backgroundTapped)))
            })
        }
    }
    
    @objc func backgroundTapped() {
        self.dismiss(animated: true)
    }
    
    func pushCropVC(img: UIImage) {
        if let editProfileCropVC = R.storyboard.editProfileViewController.editProfileCropViewController() {
            editProfileCropVC.inputImage = img
            editProfileCropVC.delegate = self
            navigationController?.pushViewController(editProfileCropVC, animated: true)
        }
    }
    
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension EditProfilePicViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// Get selected image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        self.localImageUrl = info[.imageURL] as? URL
        if let img = info[.originalImage] as? UIImage,
           let compressedImg = img.jpegData(compressionQuality: 1) {
            let imageSize: Int = compressedImg.count
            let imgSizeInKb = Double(imageSize) / 1000.0
            if imgSizeInKb > 8000.0 {
                imgProfilePic.image = img.resizeWithWidth(width: 2000)
            }
            picker.dismiss(animated: true, completion: {
                self.pushCropVC(img: img)
            })
            imgProfilePic.layer.cornerRadius = imgProfilePic.bounds.width / 2
            imgProfilePic.contentMode = .scaleAspectFill
            btnProfilePic.layer.cornerRadius = btnProfilePic.bounds.width / 2
        }
    }
    
}

// MARK: - API Methods
extension EditProfilePicViewController {
    
    func updateProfilePic(image: UIImage) {
        ProManagerApi.uploadPicture(image: image, imageSource: imageSource).request(Result<EmptyModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            self.dismissHUD()
            if response.status == ResponseType.success {
                self.storyCameraVCInstance.syncUserModel { (isComplete) in
                    self.setupMethod()
                }
            } else {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
    
    func addSocialPlatform() {
        self.view.isUserInteractionEnabled = false
        self.socialPlatforms = socialPlatforms.uniq()
        Defaults.shared.socialPlatforms?.append(contentsOf: self.socialPlatforms)
        ProManagerApi.addSocialPlatforms(socialPlatforms: Defaults.shared.socialPlatforms?.uniq() ?? []).request(Result<EmptyModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            if response.status == ResponseType.success {
                self.storyCameraVCInstance.syncUserModel { (isComplete) in
                    self.view.isUserInteractionEnabled = true
                }
            } else {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
    
    func setupMethod() {
        if isSignUpFlow {
            self.dismiss(animated: false) {
                if let isRegistered = Defaults.shared.isRegistered, isRegistered {
                    let tooltipViewController = R.storyboard.loginViewController.tooltipViewController()
                    Utils.appDelegate?.window?.rootViewController = tooltipViewController
                    tooltipViewController?.blurView.isHidden = false
                    tooltipViewController?.blurView.alpha = 0.7
                    tooltipViewController?.signupTooltipView.isHidden = false
                } else {
                    let rootViewController: UIViewController? = R.storyboard.pageViewController.pageViewController()
                    Utils.appDelegate?.window?.rootViewController = rootViewController
                }
            }
        } else {
            navigationController?.popViewController(animated: true)
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
    
    func socialLogin(socialLogin: SocialConnectionType, completion: @escaping (Bool) -> ()) {
        switch socialLogin {
        case .facebook:
            if !FaceBookManager.shared.isUserLogin {
                FaceBookManager.shared.login(controller: self, loginCompletion: { (_, _) in
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
                loginViewController.delegate = self
                self.present(loginViewController, animated: true) {
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
                SnapKitManager.shared.login(viewController: self) { (isLogin, error) in
                    if !isLogin {
                        DispatchQueue.main.async {
                            self.showAlert(alertMessage: error ?? "")
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
                GoogleManager.shared.login(controller: self, complitionBlock: { (_, _) in
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
    
    func addProfile(userData: SocialUserData, completion: @escaping () -> ()) {
        let userData = userData
        if let url = URL(string: userData.profileURL ?? ""),
           let data = try? Data(contentsOf: url) {
            DispatchQueue.main.async {
                if let img = UIImage(data: data) {
                    self.pushCropVC(img: img)
                }
                self.imgProfilePic.layer.cornerRadius = self.imgProfilePic.bounds.width / 2
                self.imgProfilePic.contentMode = .scaleAspectFill
                self.btnProfilePic.layer.cornerRadius = self.btnProfilePic.bounds.width / 2
            }
            completion()
        }
    }
    
}

// MARK: - InstagramLoginViewControllerDelegate, ProfileDelegate
extension EditProfilePicViewController: InstagramLoginViewControllerDelegate, ProfileDelegate {
   
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

// MARK: - SharingSocialTypeDelegate
extension EditProfilePicViewController: SharingSocialTypeDelegate {
    
    func setCroppedImage(croppedImg: UIImage) {
        imgProfilePic.image = croppedImg
    }
    
    func shareSocialType(socialType: ProfileSocialShare) {
        self.openSheet(socialType: socialType)
    }
    
}
