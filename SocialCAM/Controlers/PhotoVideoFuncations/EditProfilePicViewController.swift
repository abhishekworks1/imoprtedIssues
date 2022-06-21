//
//  EditProfilePicViewController.swift
//  SocialCAM
//
//  Created by Nilisha Gupta on 07/07/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit
import AVKit
import SkyFloatingLabelTextField

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
    @IBOutlet weak var imgProfileBadge: UIImageView!
    @IBOutlet weak var socialBadgeStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var socialBadgeReceivedPopupView: UIView!
    @IBOutlet weak var lblSocialBadgeReceived: UILabel!
    @IBOutlet weak var popupImgView: UIImageView!
    @IBOutlet weak var setDisplayNamePopupView: UIView!
    @IBOutlet weak var txtDisplayName: UITextField!
    @IBOutlet weak var lblDisplayName: UILabel!
    @IBOutlet weak var displayNameViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnSetPublicDisplayName: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var lblUseThisPicture: UILabel!
    @IBOutlet weak var popupImgHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dicardPopupView: UIView!
    @IBOutlet weak var publicDisplayNameTooltipView: UIView!
    @IBOutlet weak var btnPublicDisplayNameTooltip: UIButton!
    @IBOutlet weak var publicDisplayNameView: UIView!
    @IBOutlet weak var showFlagsView: UIView!
    @IBOutlet weak var btnSetFlags: UIButton!
    @IBOutlet weak var btnSelectDiscardPopupView: UIButton!
    
    @IBOutlet weak var preLunchBadge: UIImageView!
     @IBOutlet weak var foundingMergeBadge: UIImageView!
     @IBOutlet weak var socialBadgeicon: UIImageView!
     @IBOutlet weak var subscriptionBadgeicon: UIImageView!


    @IBOutlet weak var iosBadgeView: UIView!
    @IBOutlet weak var iosSheildImageview: UIImageView!
    @IBOutlet weak var iosIconImageview: UIImageView!
    @IBOutlet weak var lbliosDaysRemains: UILabel!
    
    @IBOutlet weak var androidBadgeView: UIView!
    @IBOutlet weak var androidSheildImageview: UIImageView!
    @IBOutlet weak var androidIconImageview: UIImageView!
    @IBOutlet weak var lblandroidDaysRemains: UILabel!
    
    @IBOutlet weak var webBadgeView: UIView!
    @IBOutlet weak var webSheildImageview: UIImageView!
    @IBOutlet weak var webIconImageview: UIImageView!
    @IBOutlet weak var lblwebDaysRemains: UILabel!
    
    
    // MARK: - Variables declaration
    private var localImageUrl: URL?
    private var imagePicker = UIImagePickerController()
    var isSignUpFlow: Bool = false
    var isImageSelected = false
    var isImageChanged = false
    var imageSource = ""
    var socialPlatforms: [String] = []
    private lazy var storyCameraVC = StoryCameraViewController()
    var croppedImg: UIImage?
    var uncroppedImg: UIImage?
    var isCroppedImage = false
    var isCountryFlagSelected = false
    var countrySelected: [Country] = []
    var isFlagSelected = false
    var isShareButtonSelected = false
    var isPublicNameEdit = false
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isUserInteractionEnabled = true
        self.scrollView.delegate = self
        
        self.lblUserName.text = "@\(Defaults.shared.currentUser?.channelId ?? "")"
        if let createdDate = Defaults.shared.currentUser?.created {
            let date = CommonFunctions.getDateInSpecificFormat(dateInput: createdDate, dateOutput: R.string.localizable.mmmdYyyy())
            self.lblSinceDate.text = R.string.localizable.sinceJoined(date)
        }
        self.setPublicDisplayName()
        btnSelectCountry.isSelected = Defaults.shared.currentUser?.isShowFlags ?? false
        
        
        DispatchQueue.main.async {
            if let flages = Defaults.shared.currentUser?.userStateFlags,
               flages.count > 0 {
                self.btnSetFlags.isHidden = true
                self.flagsStackViewHeightConstraint.constant = self.btnSelectCountry.isSelected ? 74 : 0
                for (index, item) in flages.enumerated() {
                    self.countryView[index].isHidden = false
                    let country: Country = Country(name: (item.state == "") ? (item.country ?? "") : (item.state ?? ""), code: (item.state == "") ? (item.countryCode ?? "") : (item.stateCode ?? ""), phoneCode: "", isState: (item.state != ""))
                    self.countrySelected.append(country)
                    self.lblCountrys[index].text = country.isState ? item.state : item.country
                    self.imgCountrys[index].image = country.flag
                }
            } else {
                self.btnSetFlags.isHidden = false
                self.flagsStackViewHeightConstraint.constant = 0
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
        popupImgView.layer.cornerRadius = popupImgView.bounds.width / 2
        popupImgView.contentMode = .scaleAspectFill
        if isQuickApp || isQuickCamApp {
            self.showFlagsView.isHidden = true
        }
        
        self.setUpbadges()
        self.setUpSubscriptionBadges()
    }
    
    func settingSocialPlatforms() {
        if imageSource != "" {
            self.socialPlatforms.append(self.imageSource.lowercased())
        } else {
            self.socialPlatforms.removeAll(where: {$0 == ""})
        }
        self.addSocialPlatform()
    }
    
    func showHidePopupView(isHide: Bool) {
        socialSharePopupView.bringSubviewToFront(self.view)
        self.socialSharePopupView.isHidden = isHide
        self.lblUseThisPicture.isHidden = isShareButtonSelected
        self.popupImgHeightConstraint.constant = isShareButtonSelected ? 0 : 100
        self.popupImgView.image = isCroppedImage ? self.croppedImg : self.uncroppedImg
    }
    
    func showHideSocialBadgePopupView(isHide: Bool) {
        self.socialBadgeReceivedPopupView.isHidden = isHide
    }
    
    func goToShareScreen() {
        if let shareSettingVC = R.storyboard.editProfileViewController.shareSettingViewController() {
            self.navigationController?.pushViewController(shareSettingVC, animated: true)
        }
    }
    
    func setPublicDisplayName() {
        if let displayName =  Defaults.shared.publicDisplayName,
           !displayName.isEmpty {
            self.publicDisplayNameView.isHidden = false
            self.displayNameViewTopConstraint.constant = 34
            self.lblDisplayName.text = displayName
            self.btnSetPublicDisplayName.isHidden = true
            self.btnPublicDisplayNameTooltip.isHidden = true
        } else {
            self.displayNameViewTopConstraint.constant = 0
            self.publicDisplayNameView.isHidden = true
            self.btnSetPublicDisplayName.isHidden = false
            self.btnPublicDisplayNameTooltip.isHidden = false
        }
        self.setDisplayNamePopupView.isHidden = true
    }
    
    // MARK: - Action Methods
    @IBAction func btnBackTapped(_ sender: UIButton) {
        print("btnBackTapped")
        if (isImageSelected || isCountryFlagSelected || isFlagSelected) && (Defaults.shared.isShowAllPopUpChecked || Defaults.shared.isEditProfileDiscardPopupChecked) && isImageChanged {
            self.dicardPopupView.isHidden = false
        } else {
            self.setupMethod()
        }
    }
    
    @IBAction func btnUpdateTapped(_ sender: UIButton) {
        self.openSocialShareVC()
    }
    
    @IBAction func btnOKTapped(_ sender: UIButton) {
        if isImageSelected || isCountryFlagSelected || isFlagSelected {
            self.showHUD()
            self.view.isUserInteractionEnabled = false
        } else {
            if !isPublicNameEdit {
                self.view.makeToast(R.string.localizable.noChangesMade())
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
        if isImageSelected {
            if let img = imgProfilePic.image {
                self.updateProfilePic(image: img)
                self.updateProfileDetails(image: img)
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
            self.flagsStackViewHeightConstraint.constant = self.btnSelectCountry.isSelected ? 74 : 0
        }
        if isCountryFlagSelected {
            self.flagsStackViewHeightConstraint.constant = (self.btnSelectCountry.isSelected && countrySelected.count > 0) ? 74 : 0
        }
    }
    
    @IBAction func btnYesTapped(_ sender: UIButton) {
        showHidePopupView(isHide: true)
        if isShareButtonSelected {
            btnOKTapped(sender)
        }
        if isImageSelected {
            self.imgProfilePic.image = isCroppedImage ? self.croppedImg : self.uncroppedImg
            self.isImageChanged = true
        }
    }
    
    @IBAction func btnNoTapped(_ sender: UIButton) {
        showHidePopupView(isHide: true)
        if isShareButtonSelected {
            isShareButtonSelected = false
            self.goToShareScreen()
        }
    }
    
    @IBAction func btnSetFlagTapped(_ sender: UIButton) {
        if let countryVc = R.storyboard.countryPicker.countryPickerViewController() {
            countryVc.selectedCountries = countrySelected
            countryVc.delegate = self
            self.navigationController?.pushViewController(countryVc, animated: true)
        }
    }
    
    @IBAction func btnShareTapped(_ sender: UIButton) {
        if isImageSelected || isFlagSelected || isCountryFlagSelected {
            self.isShareButtonSelected = true
            self.lblSocialSharePopup.isHidden = false
            self.lblSocialSharePopup.text = R.string.localizable.doYouWantToSaveTheChanges()
            self.showHidePopupView(isHide: false)
        } else {
            self.goToShareScreen()
        }
    }
    
    @IBAction func btnOKPopupTapped(_ sender: UIButton) {
        self.showHideSocialBadgePopupView(isHide: true)
    }
    
    @IBAction func btnSetPublicDisplayNameTapped(_ sender: UIButton) {
        self.setDisplayNamePopupView.isHidden = false
    }
    
    @IBAction func btnSetDisplayYesTapped(_ sender: UIButton) {
        self.setDisplayNamePopupView.isHidden = true
        self.showHUD()
        self.editDisplayName()
    }
    
    @IBAction func btnSetDisplayNoTapped(_ sender: UIButton) {
        self.setDisplayNamePopupView.isHidden = true
    }
    
    @IBAction func btnDiscardPopupOkTapped(_ sender: UIButton) {
        self.setupMethod()
    }
    
    @IBAction func btnDiscardPopupCancelTapped(_ sender: UIButton) {
        self.dicardPopupView.isHidden = true
    }
    
    @IBAction func btnTooltipOkTapped(_ sender: UIButton) {
        self.publicDisplayNameTooltipView.isHidden = true
    }
    
    @IBAction func btnPublicDisplayNameTooltipTapped(_ sender: UIButton) {
        self.publicDisplayNameTooltipView.isHidden = false
    }
    
    @IBAction func editPublicDisplayNameTapped(_ sender: UIButton) {
        self.txtDisplayName.text = Defaults.shared.publicDisplayName
        self.setDisplayNamePopupView.isHidden = false
    }
    
    @IBAction func btnFlagSelectionsTapped(_ sender: UIButton) {
        if let countryVc = R.storyboard.countryPicker.countryPickerViewController() {
            countryVc.selectedCountries = countrySelected
            countryVc.delegate = self
            self.navigationController?.pushViewController(countryVc, animated: true)
        }
    }
    
    @IBAction func btnDoNotShowDiscardPopupTapped(_ sender: UIButton) {
        btnSelectDiscardPopupView.isSelected = !btnSelectDiscardPopupView.isSelected
        Defaults.shared.isShowAllPopUpChecked = !btnSelectDiscardPopupView.isSelected
        Defaults.shared.isEditProfileDiscardPopupChecked = !btnSelectDiscardPopupView.isSelected
    }
    
    
    func setUpbadges() {
        let badgearry = Defaults.shared.getbadgesArray()
        preLunchBadge.isHidden = true
        foundingMergeBadge.isHidden = true
        socialBadgeicon.isHidden = true
        subscriptionBadgeicon.isHidden = true
        
        if  badgearry.count >  0 {
            preLunchBadge.isHidden = false
            preLunchBadge.image = UIImage.init(named: badgearry[0])
        }
        if  badgearry.count >  1 {
            foundingMergeBadge.isHidden = false
            foundingMergeBadge.image = UIImage.init(named: badgearry[1])
        }
        if  badgearry.count >  2 {
            socialBadgeicon.isHidden = false
            socialBadgeicon.image = UIImage.init(named: badgearry[2])
        }
        if  badgearry.count >  3 {
            subscriptionBadgeicon.isHidden = false
            subscriptionBadgeicon.image = UIImage.init(named: badgearry[3])
        }
    }
    
    func setUpSubscriptionBadges() {
        androidIconImageview.isHidden = true
//        badgeView.isHidden = false
        iosBadgeView.isHidden = true
        androidBadgeView.isHidden = true
        webBadgeView.isHidden = true
        
        if let badgearray = Defaults.shared.currentUser?.badges {
            for parentbadge in badgearray {
                let badgeCode = parentbadge.badge?.code ?? ""
                let freeTrialDay = parentbadge.meta?.freeTrialDay ?? 0
                let subscriptionType = parentbadge.meta?.subscriptionType ?? ""
                let finalDay = Defaults.shared.getCountFromBadge(parentbadge: parentbadge)
                iosIconImageview.isHidden = true
                androidIconImageview.isHidden = true
                webIconImageview.isHidden = true
                // Setup For iOS Badge
                if badgeCode == Badges.SUBSCRIBER_IOS.rawValue
                {
                    if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                        iosBadgeView.isHidden = false
                        lbliosDaysRemains.text = finalDay
                        iosSheildImageview.image = R.image.badgeIphoneTrial()
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
                        iosBadgeView.isHidden = false
                       /* if freeTrialDay > 0 {
                            lbliosDaysRemains.text = finalDay
                            iosSheildImageview.image = R.image.freeBadge()
                        } else {*/
                            //iOS shield hide
                            //square badge show
                            lbliosDaysRemains.text = ""
                            iosSheildImageview.image = R.image.badgeIphoneFree()
//                        }
                    }
                    
                    if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
                        iosBadgeView.isHidden = false
                        lbliosDaysRemains.text = finalDay
                        iosSheildImageview.image = R.image.badgeIphoneBasic()
                    }
                    if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
                        iosBadgeView.isHidden = false
                        lbliosDaysRemains.text = finalDay
                        iosSheildImageview.image = R.image.badgeIphoneAdvance()
                    }
                    if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue {
                        iosBadgeView.isHidden = false
                        lbliosDaysRemains.text = finalDay
                        iosSheildImageview.image = R.image.badgeIphonePre()
                    }
                }
                // Setup For Android Badge
                if badgeCode == Badges.SUBSCRIBER_ANDROID.rawValue
                {
                    if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                        androidBadgeView.isHidden = false
                        lblandroidDaysRemains.text = finalDay
                        androidSheildImageview.image = R.image.badgeAndroidTrial()
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
                        androidBadgeView.isHidden = false
                        if freeTrialDay > 0 {
                            lblandroidDaysRemains.text = finalDay
                            androidSheildImageview.image = R.image.badgeAndroidTrial()
                        } else {
                            lblandroidDaysRemains.text = ""
                            androidSheildImageview.image = R.image.badgeAndroidFree()
                        }
                    }
                    if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
                        androidBadgeView.isHidden = false
                        lblandroidDaysRemains.text = finalDay
                        androidSheildImageview.image = R.image.badgeAndroidBasic()
                    }
                    if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
                        androidBadgeView.isHidden = false
                        lblandroidDaysRemains.text = finalDay
                        androidSheildImageview.image = R.image.badgeAndroidAdvance()
                    }
                    if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue {
                        androidBadgeView.isHidden = false
                        lblandroidDaysRemains.text = finalDay
                        androidSheildImageview.image = R.image.badgeAndroidPre()
                    }
                }
                
                if badgeCode == Badges.SUBSCRIBER_WEB.rawValue
                {
                    if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                        webBadgeView.isHidden = false
                        lblwebDaysRemains.text = finalDay
                        webSheildImageview.image = R.image.badgeWebTrial()
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
                        webBadgeView.isHidden = false
                        if freeTrialDay > 0 {
                            lblwebDaysRemains.text = finalDay
                            webSheildImageview.image = R.image.badgeWebTrial()
                        } else {
                            lblwebDaysRemains.text = ""
                            webSheildImageview.image = R.image.badgeWebFree()
                        }
                    }
                    
                    if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
                        webBadgeView.isHidden = false
                        lblwebDaysRemains.text = finalDay
                        webSheildImageview.image = R.image.badgeWebBasic()
                    }
                    if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
                        webBadgeView.isHidden = false
                        lblwebDaysRemains.text = finalDay
                        webSheildImageview.image = R.image.badgeWebAdvance()
                    }
                    if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue {
                        webBadgeView.isHidden = false
                        lblwebDaysRemains.text = finalDay
                        webSheildImageview.image = R.image.badgeWebPre()
                    }
                }
            }
        }
    }
}

extension EditProfilePicViewController: CountryPickerViewDelegate {
    func countryPickerView(_ didSelectCountry : [Country]) {
        let countryAry = rearrangeFlags(flagsArray: didSelectCountry)
        DispatchQueue.main.async {
            for (index, _) in self.countryView.enumerated() {
                self.countryView[index].isHidden = true
                self.lblCountrys[index].text = nil
                self.imgCountrys[index].image = nil
            }
            if countryAry.count > 0 {
                for (index, item) in countryAry.enumerated() {
                    if self.countryView.count > index {
                        self.countryView[index].isHidden = false
                        self.lblCountrys[index].text = item.name
                        self.imgCountrys[index].image = item.flag
                    }
                }
            }
            self.isCountryFlagSelected = true
        }
        self.btnSetFlags.isHidden = countryAry.count > 0
        self.countrySelected = countryAry
        self.flagsStackViewHeightConstraint.constant = (self.btnSelectCountry.isSelected && !countryAry.isEmpty) ? 74 : 0
    }
}

extension EditProfilePicViewController: StatePickerViewDelegate {
    
    func getSelectStates(_ selectedStates: [Country], isSelectionDone: Bool) {
        let countryAry = rearrangeFlags(flagsArray: selectedStates)
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
        self.btnSetFlags.isHidden = countryAry.count > 0
        self.countrySelected = selectedStates
        self.flagsStackViewHeightConstraint.constant = (self.btnSelectCountry.isSelected && !countryAry.isEmpty) ? 74 : 0
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
        self.showHideSharePopupLabel(socialType: socialType)
        switch socialType {
        case .gallery:
            self.getImage(fromSourceType: .photoLibrary)
            self.imageSource = ""
        case .camera:
            self.getImage(fromSourceType: .camera)
            self.imageSource = ""
        case .instagram:
            self.lblSocialSharePopup.text = R.string.localizable.loginSuccess(SocialConnectionType.instagram.stringValue)
            self.setSocialMediaPicture(socialShareType: .instagram)
        case .snapchat:
            self.lblSocialSharePopup.text = R.string.localizable.loginSuccess(SocialConnectionType.snapchat.stringValue)
            self.dismissHUD()
            self.setSocialMediaPicture(socialShareType: .snapchat)
        case .youTube:
            self.lblSocialSharePopup.text = R.string.localizable.loginSuccess(SocialConnectionType.youtube.stringValue)
            self.setSocialMediaPicture(socialShareType: .youtube)
        case .twitter:
            self.lblSocialSharePopup.text = R.string.localizable.loginSuccess(SocialConnectionType.twitter.stringValue)
            self.setSocialMediaPicture(socialShareType: .twitter)
        case .facebook:
            self.lblSocialSharePopup.text = R.string.localizable.loginSuccess(SocialConnectionType.facebook.stringValue)
            self.setSocialMediaPicture(socialShareType: .facebook)
        }
    }
    
    func showHideSharePopupLabel(socialType: ProfileSocialShare) {
        switch socialType {
        case .gallery, .camera:
            self.dismissHUD()
            self.lblSocialSharePopup.isHidden = true
        default:
            self.lblSocialSharePopup.isHidden = false
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
    
    func rearrangeFlags(flagsArray: [Country]) -> [Country] {
        var flagsArray = flagsArray
        if let index = flagsArray.firstIndex(where: { $0.code == StaticKeys.countryCodeUS }) {
            let element = flagsArray[index]
            if let stateIndex = flagsArray.firstIndex(where: { $0.isState == true }) {
                let stateElement = flagsArray[stateIndex]
                if flagsArray.count == 3 {
                    flagsArray.remove(at: stateIndex)
                    flagsArray.insert(stateElement, at: 2)
                    flagsArray.remove(at: index)
                    flagsArray.insert(element, at: 1)
                } else if flagsArray.count == 2 {
                    flagsArray.remove(at: index)
                    flagsArray.insert(element, at: 0)
                }
            } else {
                if flagsArray.count == 2 {
                    flagsArray.remove(at: index)
                    flagsArray.insert(element, at: 1)
                }
            }
        }
        return flagsArray
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
    
    fileprivate func setRedirection() {
        if self.isShareButtonSelected {
            self.isShareButtonSelected = false
            self.goToShareScreen()
        } else {
            self.setupMethod()
        }
    }
    
    func editDisplayName() {
        let displayName = self.txtDisplayName.text
        ProManagerApi.editDisplayName(publicDisplayName: displayName?.isEmpty ?? true ? "" : displayName, privateDisplayName: nil).request(Result<EmptyModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            self.dismissHUD()
            self.isPublicNameEdit = true
            if response.status == ResponseType.success {
                self.storyCameraVC.syncUserModel { _ in
                    self.setPublicDisplayName()
                }
            }
        }, onError: { error in
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
    
    func setCountrys(_ countrys: [Country]) {
        var arrayCountry: [[String: Any]] = []
        for country in countrys {
            let material: [String: Any] = [
                StaticKeys.state: country.isState ? country.name : "",
                StaticKeys.stateCode: country.isState ? country.code : "",
                StaticKeys.country: country.isState ? StaticKeys.countryNameUS : country.name,
                StaticKeys.countryCode: country.isState ? StaticKeys.countryCodeUS: country.code
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
                    self.setRedirection()
                }
                self.isCountryFlagSelected = false
            }
        }, onError: { error in
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
    
    func setUserStateFlag(_ isUserStateFlag: Bool) {
        ProManagerApi.setUserStateFlag(isUserStateFlag: isUserStateFlag).request(Result<EmptyModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            self.dismissHUD()
            self.storyCameraVC.syncUserModel { _ in
                if !self.isCountryFlagSelected || !self.isImageSelected {
                    if self.isShareButtonSelected {
                        self.isShareButtonSelected = false
                        self.goToShareScreen()
                    } else {
                        self.setupMethod()
                    }
                }
                self.isFlagSelected = false
            }
        }, onError: { error in
            self.dismissHUD()
            self.view.isUserInteractionEnabled = true
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
                self.setRedirection()
                self.isImageSelected = false
            }
        }, onError: { error in
            self.dismissHUD()
            self.view.isUserInteractionEnabled = true
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
    func updateProfileDetails(image: UIImage) {
        ProManagerApi.updateProfileDetails(image: image, imageSource: imageSource).request(Result<EmptyModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            self.dismissHUD()
          
        }, onError: { error in
            self.dismissHUD()
            self.view.isUserInteractionEnabled = true
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
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
            self.lblSocialBadgeReceived.text = R.string.localizable.congratulationsYouReceivedTheSocialMediaBadge("@\(Defaults.shared.currentUser?.channelId ?? "")")
            self.showHideSocialBadgePopupView(isHide: false)
        }
        ProManagerApi.addSocialPlatforms(socialPlatforms: Defaults.shared.socialPlatforms?.uniq() ?? []).request(Result<EmptyModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            self.storyCameraVC.syncUserModel { (isComplete) in
                self.getVerifiedSocialPlatforms()
            }
        }, onError: { error in
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
    
    func getVerifiedSocialPlatforms() {
        self.facebookVerifiedView.isHidden = true
        self.twitterVerifiedView.isHidden = true
        self.snapchatVerifiedView.isHidden = true
        self.youtubeVerifiedView.isHidden = true
        if let socialPlatforms = Defaults.shared.socialPlatforms {
            self.socialPlatformStackViewHeightConstraint.constant = 32
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
            self.imgProfileBadge.image = (socialPlatforms.count == 4) ? R.image.shareScreenRibbonProfileBadge() : R.image.shareScreenProfileBadge()
//            self.socialBadgeicon.isHidden = (socialPlatforms.count == 4) ? false : true
        } else {
            self.socialPlatformStackViewHeightConstraint.constant = 0
//            self.socialBadgeicon.isHidden = true
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
        self.settingSocialPlatforms()
        self.isCroppedImage = false
    }
    
    func setCroppedImage(croppedImg: UIImage) {
        showHidePopupView(isHide: false)
        self.settingSocialPlatforms()
        self.isCroppedImage = true
        self.croppedImg = croppedImg
    }
    
    func shareSocialType(socialType: ProfileSocialShare) {
        self.showHUD()
        self.openSheet(socialType: socialType)
    }
    
}

// MARK: - UIScrollView Delegate
extension EditProfilePicViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x>0 {
            scrollView.contentOffset.x = 0
        }
    }
}
