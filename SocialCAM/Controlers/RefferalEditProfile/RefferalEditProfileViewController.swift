//
//  RefferalEditProfileViewController.swift
//  SocialCAM
//
//  Created by Siddharth on 11/04/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class RefferalEditProfileViewController: UIViewController {
    
    @IBOutlet weak var popupImgView: UIImageView!
    @IBOutlet weak var lblUseThisPicture: UILabel!
    @IBOutlet weak var socialSharePopupView: UIView!
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var popupImgHeightConstraint: NSLayoutConstraint!
    
    var isCroppedImage = false
    var imageSource = ""
    var socialPlatforms: [String] = []
    var croppedImg: UIImage?
    var uncroppedImg: UIImage?
    var isImageSelected = false
    var isShareButtonSelected = false
    private var localImageUrl: URL?
    private lazy var storyCameraVC = StoryCameraViewController()
    private var imagePicker = UIImagePickerController()
    var isSignUpFlow: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapChangeProfilePicButton(_ sender: UIButton) {
        openSocialShareVC()
    }
    
    @IBAction func btnYesTapped(_ sender: UIButton) {
        showHidePopupView(isHide: true)
        if isShareButtonSelected {
//            btnOKTapped(sender)
        }
        if isImageSelected {
            self.imgProfilePic.image = isCroppedImage ? self.croppedImg : self.uncroppedImg
        }
    }
    
    @IBAction func btnNoTapped(_ sender: UIButton) {
        showHidePopupView(isHide: true)
        if isShareButtonSelected {
            isShareButtonSelected = false
            self.goToShareScreen()
        }
    }
    
    @IBAction func didTapNextButtonClick(_ sender: UIButton) {
        if isImageSelected {
            if let img = imgProfilePic.image {
                self.updateProfilePic(image: img)
            }
        }
    }
    
    func updateProfilePic(image: UIImage) {
        ProManagerApi.uploadPicture(image: image, imageSource: imageSource).request(Result<EmptyModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            self.dismissHUD()
            self.storyCameraVC.syncUserModel { (isComplete) in
//                self.setRedirection()
                self.isImageSelected = false
                if let contactWizardController = R.storyboard.contactWizardwithAboutUs.contactImportVC() {
                    self.navigationController?.pushViewController(contactWizardController, animated: true)
                }
            }
        }, onError: { error in
            self.dismissHUD()
            self.view.isUserInteractionEnabled = true
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
    
    func goToShareScreen() {
        if let shareSettingVC = R.storyboard.editProfileViewController.shareSettingViewController() {
            self.navigationController?.pushViewController(shareSettingVC, animated: true)
        }
    }
    
    func setRedirection() {
        if self.isShareButtonSelected {
            self.isShareButtonSelected = false
            self.goToShareScreen()
        } else {
            self.setupMethod()
        }
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
}

extension RefferalEditProfileViewController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// get image from source type
    private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        /// Check is source type available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    /// Get selected image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        self.localImageUrl = info[.imageURL] as? URL
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
            self.isCroppedImage = false
            self.uncroppedImg = image
            picker.dismiss(animated: true, completion: {
                self.pushCropVC(img: image)
            })
            imgProfilePic.layer.cornerRadius = imgProfilePic.bounds.width / 2
            imgProfilePic.contentMode = .scaleAspectFill
//            imgProfilePic.image = image
//            btnProfilePic.layer.cornerRadius = btnProfilePic.bounds.width / 2
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
            self.storyCameraVC.syncUserModel { (isComplete) in
//                self.getVerifiedSocialPlatforms()
            }
        }, onError: { error in
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
    
    func openSheet(socialType: ProfileSocialShare) {
        self.isImageSelected = true
//        self.showHideSharePopupLabel(socialType: socialType)
        switch socialType {
        case .gallery:
            self.getImage(fromSourceType: .photoLibrary)
            self.imageSource = ""
        case .camera:
            self.getImage(fromSourceType: .camera)
            self.imageSource = ""
        case .instagram:
//            self.lblSocialSharePopup.text = R.string.localizable.loginSuccess(SocialConnectionType.instagram.stringValue)
            self.setSocialMediaPicture(socialShareType: .instagram)
        case .snapchat:
//            self.lblSocialSharePopup.text = R.string.localizable.loginSuccess(SocialConnectionType.snapchat.stringValue)
            self.dismissHUD()
            self.setSocialMediaPicture(socialShareType: .snapchat)
        case .youTube:
//            self.lblSocialSharePopup.text = R.string.localizable.loginSuccess(SocialConnectionType.youtube.stringValue)
            self.setSocialMediaPicture(socialShareType: .youtube)
        case .twitter:
//            self.lblSocialSharePopup.text = R.string.localizable.loginSuccess(SocialConnectionType.twitter.stringValue)
            self.setSocialMediaPicture(socialShareType: .twitter)
        case .facebook:
//            self.lblSocialSharePopup.text = R.string.localizable.loginSuccess(SocialConnectionType.facebook.stringValue)
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
                        })
                    }
                }
            }
            self.dismissHUD()
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
                self.dismissHUD()
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
                self.dismissHUD()
                if let img = UIImage(data: data) {
                    self.isCroppedImage = false
                    self.uncroppedImg = img
                    self.pushCropVC(img: img)
                }
                self.imgProfilePic.layer.cornerRadius = self.imgProfilePic.bounds.width / 2
                self.imgProfilePic.contentMode = .scaleAspectFill
//                self.btnProfilePic.layer.cornerRadius = self.btnProfilePic.bounds.width / 2
            }
            completion()
        }
    }
    
    func pushCropVC(img: UIImage) {
        if let editProfileCropVC = R.storyboard.editProfileViewController.editProfileCropViewController() {
            editProfileCropVC.inputImage = img
            editProfileCropVC.delegate = self
            navigationController?.pushViewController(editProfileCropVC, animated: true)
        }
    }
    
    func showHidePopupView(isHide: Bool) {
        socialSharePopupView.bringSubviewToFront(self.view)
        self.socialSharePopupView.isHidden = isHide
        self.lblUseThisPicture.isHidden = isShareButtonSelected
        self.popupImgHeightConstraint.constant = isShareButtonSelected ? 0 : 100
        self.popupImgView.image = isCroppedImage ? self.croppedImg : self.uncroppedImg
    }
    
}

// MARK: - SharingSocialTypeDelegate
extension RefferalEditProfileViewController: SharingSocialTypeDelegate {
    func shareSocialType(socialType: ProfileSocialShare) {
//        self.showHUD()
        self.openSheet(socialType: socialType)
    }
    
    func setCroppedImage(croppedImg: UIImage) {
        self.isCroppedImage = true
        self.croppedImg = croppedImg
        showHidePopupView(isHide: false)
        self.settingSocialPlatforms()
    }
    
    func setSocialPlatforms() {
        self.settingSocialPlatforms()
        self.isCroppedImage = false
    }
    
}

// MARK: - InstagramLoginViewControllerDelegate, ProfileDelegate
extension RefferalEditProfileViewController: InstagramLoginViewControllerDelegate, ProfileDelegate {
   
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
