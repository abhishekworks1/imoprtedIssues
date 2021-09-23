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
    func setSocialPlatforms()
}

class EditProfilePicViewController: UIViewController {
    
    // MARK: - Outlets declaration
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var btnProfilePic: UIButton!
    @IBOutlet weak var btnPlusButton: UIButton!
    @IBOutlet weak var lblSocialSharePopup: UILabel!
    @IBOutlet weak var socialSharePopupView: UIView!
    @IBOutlet weak var facebookVerifiedView: UIView!
    @IBOutlet weak var twitterVerifiedView: UIView!
    @IBOutlet weak var snapchatVerifiedView: UIView!
    @IBOutlet weak var youtubeVerifiedView: UIView!
    @IBOutlet weak var lblSinceDate: UILabel!
    @IBOutlet weak var btnSelectCountry: UIButton!
    @IBOutlet var countryView: [UIView]!
    @IBOutlet var lblCountrys: [UILabel]!
    @IBOutlet var imgCountrys: [UIImageView]!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var flagsStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var socialPlatformStackViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Variables declaration
    private var localImageUrl: URL?
    private var imagePicker = UIImagePickerController()
    var isSignUpFlow: Bool = false
    var isImageSelected = false
    var imageSource = ""
    var socialPlatforms: [String] = []
    private lazy var storyCameraVC = StoryCameraViewController()
    var croppedImg: UIImage?
    var uncroppedImg: UIImage?
    var isCroppedImage = false
    var isCountryFlagSelected = false
    var countrySelected: [Country] = []
    var isFlagSelected = false
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isUserInteractionEnabled = true
        self.lblUserName.text = "@\(Defaults.shared.currentUser?.channelId ?? "")"
        if let createdDate = Defaults.shared.currentUser?.created {
            let date = CommonFunctions.getDateInSpecificFormat(dateInput: createdDate, dateOutput: R.string.localizable.mmmdYyyy())
            self.lblSinceDate.text = R.string.localizable.sinceJoined(date)
        }
        
        btnSelectCountry.isSelected = Defaults.shared.currentUser?.isShowFlags ?? false
        
        DispatchQueue.main.async {
            if let flages = Defaults.shared.currentUser?.userStateFlags,
               flages.count > 0 {
                self.flagsStackViewHeightConstraint.constant = self.btnSelectCountry.isSelected ? 70 : 0
                for (index, item) in flages.enumerated() {
                    self.countryView[index].isHidden = false
                    let country: Country = Country(name: item.country ?? "", code: (item.state == "") ? (item.countryCode ?? "") : (item.stateCode ?? ""), phoneCode: "", isState: (item.state != ""))
                    self.lblCountrys[index].text = country.isState ? item.state : item.country
                    self.imgCountrys[index].image = country.flag
                }
            }
        }
        self.getVerifiedSocialPlatforms()
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
    }
    
    func showHidePopupView(isHide: Bool) {
        socialSharePopupView.bringSubviewToFront(self.view)
        self.socialSharePopupView.isHidden = isHide
        if isCroppedImage {
            self.socialPlatforms.append(self.imageSource.lowercased())
            self.addSocialPlatform()
        }
    }
    
    // MARK: - Action Methods
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.setupMethod()
    }
    
    @IBAction func btnUpdateTapped(_ sender: UIButton) {
        self.openSocialShareVC()
    }
    
    @IBAction func btnOKTapped(_ sender: UIButton) {
        if isImageSelected || isCountryFlagSelected || isFlagSelected {
            self.showHUD()
            self.view.isUserInteractionEnabled = false
        }
        if isImageSelected {
            if let img = imgProfilePic.image {
                self.updateProfilePic(image: img)
            }
        }
        if isCountryFlagSelected {
            self.setCountrys(self.countrySelected)
        }
        if isFlagSelected {
            self.setUserStateFlag(btnSelectCountry.isSelected)
        }
    }
    
    @IBAction func btnShowCountryTapped(_ sender: UIButton) {
        self.isFlagSelected = true
        btnSelectCountry.isSelected.toggle()
        if let flages = Defaults.shared.currentUser?.userStateFlags,
           flages.count > 0 {
            self.flagsStackViewHeightConstraint.constant = self.btnSelectCountry.isSelected ? 70 : 0
        }
        if isCountryFlagSelected {
            self.flagsStackViewHeightConstraint.constant = (self.btnSelectCountry.isSelected && countrySelected.count > 0) ? 70 : 0
        }
    }
    
    @IBAction func btnYesTapped(_ sender: UIButton) {
        showHidePopupView(isHide: true)
        self.imgProfilePic.image = isCroppedImage ? self.croppedImg : self.uncroppedImg
    }
    
    @IBAction func btnNoTapped(_ sender: UIButton) {
        showHidePopupView(isHide: true)
    }
    
    @IBAction func btnSetFlagTapped(_ sender: UIButton) {
        if let countryVc = R.storyboard.countryPicker.countryPickerViewController() {
            countryVc.delegate = self
            self.navigationController?.pushViewController(countryVc, animated: true)
        }
    }
    
}

extension EditProfilePicViewController: CountryPickerViewDelegate {
    func countryPickerView(_ didSelectCountry : [Country]) {
        var countryAry = didSelectCountry
        if let index = countryAry.firstIndex(where: { $0.code == StaticKeys.countryCodeUS }) {
            let element = countryAry[index]
            if countryAry.count >= 2 {
                countryAry.remove(at: index)
                countryAry.insert(element, at: 1)
            }
        }
        DispatchQueue.main.async {
            for (index, _) in self.countryView.enumerated() {
                self.countryView[index].isHidden = true
                self.lblCountrys[index].text = nil
                self.imgCountrys[index].image = nil
            }
            if countryAry.count > 0 {
                for (index, item) in countryAry.enumerated() {
                    self.countryView[index].isHidden = false
                    self.lblCountrys[index].text = item.name
                    self.imgCountrys[index].image = item.flag
                }
            }
            self.isCountryFlagSelected = true
        }
        self.countrySelected = countryAry
        self.flagsStackViewHeightConstraint.constant = (self.btnSelectCountry.isSelected && !countryAry.isEmpty) ? 70 : 0
    }
}

extension EditProfilePicViewController: StatePickerViewDelegate {
    
    func statePickerView(_ didSelectCountry: [Country], isSelectionDone: Bool) {
        var countryAry = didSelectCountry
        if let index = countryAry.firstIndex(where: { $0.code == StaticKeys.countryCodeUS }) {
            let element = countryAry[index]
            if countryAry.count >= 2 {
                countryAry.remove(at: index)
                countryAry.insert(element, at: 1)
            }
        }
        DispatchQueue.main.async {
            for (index, _) in self.countryView.enumerated() {
                self.countryView[index].isHidden = true
                self.lblCountrys[index].text = nil
                self.imgCountrys[index].image = nil
            }
            if countryAry.count > 0 {
                self.isCountryFlagSelected = true
                for (index, item) in countryAry.enumerated() {
                    self.countryView[index].isHidden = false
                    self.lblCountrys[index].text = item.name
                    self.imgCountrys[index].image = item.flag
                }
                self.btnSelectCountry.isSelected = !self.btnSelectCountry.isSelected
            }
        }
        self.countrySelected = didSelectCountry
        self.flagsStackViewHeightConstraint.constant = (self.btnSelectCountry.isSelected && !countryAry.isEmpty) ? 70 : 0
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
            btnProfilePic.layer.cornerRadius = btnProfilePic.bounds.width / 2
        }
    }
    
}

// MARK: - API Methods
extension EditProfilePicViewController {
    
    func setCountrys(_ countrys: [Country]) {
        var arrayCountry: [[String: Any]] = []
        for country in countrys {
            let material: [String: Any] = [
                "state": country.isState ? country.name : "",
                "stateCode": country.isState ? country.code : "",
                "country": country.isState ? StaticKeys.countryNameUS : country.name,
                "countryCode": country.isState ? StaticKeys.countryCodeUS: country.code
            ]
            arrayCountry.append(material)
        }
        ProManagerApi.setCountrys(arrayCountry: arrayCountry).request(Result<EmptyModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            self.dismissHUD()
            self.storyCameraVC.syncUserModel { _ in
                if !self.isImageSelected {
                    self.setupMethod()
                }
            }
        }, onError: { error in
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
    
    func setUserStateFlag(_ isUserStateFlag: Bool) {
        self.dismissHUD()
        ProManagerApi.setUserStateFlag(isUserStateFlag: isUserStateFlag).request(Result<EmptyModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            if !self.isCountryFlagSelected || !self.isImageSelected {
                self.setupMethod()
            }
        }, onError: { error in
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
    
    func updateProfilePic(image: UIImage) {
        ProManagerApi.uploadPicture(image: image, imageSource: imageSource).request(Result<EmptyModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            self.dismissHUD()
            self.storyCameraVC.syncUserModel { (isComplete) in
                self.setupMethod()
            }
        }, onError: { error in
            self.dismissHUD()
            self.view.isUserInteractionEnabled = true
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
    
    func addSocialPlatform() {
        self.socialPlatforms = socialPlatforms.uniq()
        Defaults.shared.socialPlatforms?.append(contentsOf: self.socialPlatforms)
        ProManagerApi.addSocialPlatforms(socialPlatforms: Defaults.shared.socialPlatforms?.uniq() ?? []).request(Result<EmptyModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            self.storyCameraVC.syncUserModel { (isComplete) in
                self.getVerifiedSocialPlatforms()
            }
        }, onError: { error in
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
    
    func getVerifiedSocialPlatforms() {
        if let socialPlatforms = Defaults.shared.socialPlatforms {
            self.socialPlatformStackViewHeightConstraint.constant = 37
            for socialPlatform in socialPlatforms {
                if socialPlatform == R.string.localizable.facebook().lowercased() {
                    self.facebookVerifiedView.isHidden = false
                } else if socialPlatform == R.string.localizable.twitter().lowercased() {
                    self.twitterVerifiedView.isHidden = false
                } else if socialPlatform == R.string.localizable.snapchat().lowercased() {
                    self.snapchatVerifiedView.isHidden = false
                } else if socialPlatform == R.string.localizable.youtube().lowercased() {
                    self.youtubeVerifiedView.isHidden = false
                }
            }
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
                    self.isCroppedImage = false
                    self.uncroppedImg = img
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
    
    func setSocialPlatforms() {
        showHidePopupView(isHide: false)
        self.isCroppedImage = false
    }
    
    func setCroppedImage(croppedImg: UIImage) {
        showHidePopupView(isHide: false)
        self.isCroppedImage = true
        self.croppedImg = croppedImg
    }
    
    func shareSocialType(socialType: ProfileSocialShare) {
        self.openSheet(socialType: socialType)
    }
    
}
