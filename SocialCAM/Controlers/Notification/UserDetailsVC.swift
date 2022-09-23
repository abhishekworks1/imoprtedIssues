//
//  UserDetailsVC.swift
//  SocialCAM
//
//  Created by Viraj Patel on 24/09/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation
import Toast_Swift


class UserDetailsVC: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var popupContentContainerView: UIView!
    @IBOutlet weak var popupMainView: UIView! {
        didSet {
            popupMainView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblJoiningDate: UILabel!
    @IBOutlet weak var imgUserPlaceholder: UIImageView!
    @IBOutlet weak var imgUserImage: UIImageView!
    @IBOutlet weak var verifiedStackView: UIStackView!
    @IBOutlet weak var flagStackView: UIStackView!
    @IBOutlet weak var facebookVerifiedView: UIView!
    @IBOutlet weak var twitterVerifiedView: UIView!
    @IBOutlet weak var snapchatVerifiedView: UIView!
    @IBOutlet weak var youtubeVerifiedView: UIView!
    @IBOutlet weak var btnFollow: PButton!
    @IBOutlet var countryView: [UIView]!
    @IBOutlet var lblCountrys: [UILabel]!
    @IBOutlet var imgCountrys: [UIImageView]!
    @IBOutlet weak var lblDisplayName: UILabel!
    @IBOutlet weak var socialBadgeViewHeightConstraint: NSLayoutConstraint!
   // @IBOutlet weak var socialMediaVerifiedBadgeView: UIView!
    
    @IBOutlet weak var preLunchBadge: UIImageView!
     @IBOutlet weak var foundingMergeBadge: UIImageView!
     @IBOutlet weak var socialBadgeicon: UIImageView!
    
    var notificationUpdateHandler: ((_ notification: UserNotification?) -> Void)?
    var notification: UserNotification?
    
    var customBlurEffectStyle: UIBlurEffect.Style = .dark
    var customInitialScaleAmmount: CGFloat = CGFloat(Double(0.1))
    var customAnimationDuration: TimeInterval = TimeInterval(0.5)
    
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        customBlurEffectStyle == .dark ? .lightContent : .default
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        modalPresentationCapturesStatusBarAppearance = true
        self.setUpbadges()
        self.setUpSubscriptionBadges()
    }
    
    // MARK: - IBActions
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    func setBtnFollow(isFollowing: Bool) {
        btnFollow.backgroundColor = ApplicationSettings.appPrimaryColor
        btnFollow.setTitleColor(ApplicationSettings.appWhiteColor, for: .normal)
        btnFollow.setTitle(isFollowing ? R.string.localizable.following() : R.string.localizable.follow(), for: .normal)
    }
    
    func userFollowing(_ userId: String) {
        ProManagerApi.setFollow(userId: userId).request(Result<NotificationResult>.self).subscribe(onNext: { [weak self] response in
            guard let `self` = self else {
                return
            }
            self.setBtnFollow(isFollowing: true)
            self.dismissHUD()
            if response.status == ResponseType.success {
                if let _ = self.notification {
                    self.notification?.isFollowing = true
                    if let handler = self.notificationUpdateHandler {
                        handler(self.notification)
                    }
                } else {
                    let currentUser = Defaults.shared.currentUser
                    currentUser?.refferedBy?.isFollowing = true
                    Defaults.shared.currentUser = currentUser
                }
            } else {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { [weak self] error in
            guard let `self` = self else { return }
            self.showAlert(alertMessage: error.localizedDescription)
            self.dismissHUD()
        }, onCompleted: {
        }).disposed(by: rx.disposeBag)
    }
    
    func userUnFollowing(_ userId: String) {
        ProManagerApi.setUnFollow(userId: userId).request(Result<NotificationResult>.self).subscribe(onNext: { [weak self] response in
            guard let `self` = self else {
                return
            }
            self.setBtnFollow(isFollowing: false)
            self.dismissHUD()
            if response.status == ResponseType.success {
                if let _ = self.notification {
                    self.notification?.isFollowing = false
                    if let handler = self.notificationUpdateHandler {
                        handler(self.notification)
                    }
                } else {
                    let currentUser = Defaults.shared.currentUser
                    currentUser?.refferedBy?.isFollowing = false
                    Defaults.shared.currentUser = currentUser
                }
            } else {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { [weak self] error in
            guard let `self` = self else { return }
            self.showAlert(alertMessage: error.localizedDescription)
            self.dismissHUD()
        }, onCompleted: {
        }).disposed(by: rx.disposeBag)
    }
    
    @IBAction func followButtonTapped(_ sender: UIButton) {
        if let notification = self.notification, let userId = notification.refereeUserId?.id {
            self.showHUD()
            if let following = notification.isFollowing, !following {
                self.userFollowing(userId)
            } else {
                self.userUnFollowing(userId)
            }
        } else {
            if let userId = Defaults.shared.currentUser?.refferedBy?.id {
                self.showHUD()
                if let isFollowing = Defaults.shared.currentUser?.refferedBy?.isFollowing, !isFollowing {
                    self.userFollowing(userId)
                } else {
                    self.userUnFollowing(userId)
                }
            }
        }
    }

    func setup() {
        if let channelId = notification?.refereeUserId?.channelId {
            self.lblUserName.text = "@\(channelId)"
            if let user = Defaults.shared.currentUser,
               let cid = user.channelId{
                if cid == notification?.refereeUserId?.channelId ?? ""{
                    self.btnFollow.isHidden = true
                }else{
                    self.btnFollow.isHidden = false
                }
            }
        } else {
            if let name = Defaults.shared.currentUser?.refferingChannel {
                self.lblUserName.text = "@\(name)"
            }
        }
        self.imgUserImage.layer.cornerRadius = imgUserImage.bounds.width / 2
        self.imgUserImage.contentMode = .scaleAspectFill
        if let userImageURL = notification?.refereeUserId?.profileImageURL {
            self.imgUserImage.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: R.image.user_placeholder())
        } else {
            if let userImageUrl = Defaults.shared.currentUser?.refferedBy?.profileImageURL {
                self.imgUserImage.sd_setImage(with: URL.init(string: userImageUrl), placeholderImage: R.image.user_placeholder())
            }
        }
        self.getVerifiedSocialPlatforms()
        if let createdDate = notification?.refereeUserId?.created {
            self.lblJoiningDate.text = R.string.localizable.sinceJoined(convertDate(createdDate))
        } else {
            if let referredUserCreatedDate = Defaults.shared.referredUserCreatedDate {
                self.lblJoiningDate.text = R.string.localizable.sinceJoined(convertDate(referredUserCreatedDate))
            }
        }
    
        if let notification = notification {
            if let isFollowing = notification.isFollowing {
                setBtnFollow(isFollowing: isFollowing)
            }
            if let isShowFlags = notification.refereeUserId?.isShowFlags, isShowFlags, let flages = notification.refereeUserId?.userStateFlags,
               flages.count > 0 {
                for (index, item) in flages.enumerated() {
                    self.countryView[index].isHidden = false
                    let country: Country = Country(name: (item.state != nil && item.state != "") ? (item.state ?? "") : (item.country ?? ""), code: (item.state != nil && item.state != "") ? (item.stateCode ?? "") : (item.countryCode ?? ""), phoneCode: "", isState: (item.state != nil && item.state != ""))
                    self.lblCountrys[index].text = country.isState ? item.state : item.country
                    self.imgCountrys[index].image = country.flag
                }
            } else {
                flagStackView.isHidden = true
            }
            if let displayName = notification.publicDisplayName,
               !displayName.isEmpty {
                self.lblDisplayName.isHidden = false
                self.lblDisplayName.text = displayName
            } else {
                self.lblDisplayName.isHidden = true
            }
        } else {
            if let isFollowing = Defaults.shared.currentUser?.refferedBy?.isFollowing {
                setBtnFollow(isFollowing: isFollowing)
            }
            if let isShowFlags = Defaults.shared.currentUser?.refferedBy?.isShowFlags, isShowFlags, let flages = Defaults.shared.currentUser?.refferedBy?.userStateFlags,
               flages.count > 0 {
                for (index, item) in flages.enumerated() {
                    self.countryView[index].isHidden = false
                    let country: Country = Country(name: (item.state != nil && item.state != "") ? (item.state ?? "") : (item.country ?? ""), code: (item.state != nil && item.state != "") ? (item.stateCode ?? "") : (item.countryCode ?? ""), phoneCode: "", isState: (item.state != nil && item.state != ""))
                    self.lblCountrys[index].text = country.isState ? item.state : item.country
                    self.imgCountrys[index].image = country.flag
                }
            } else {
                flagStackView.isHidden = true
            }
            if let displayName =  Defaults.shared.currentUser?.refferedBy?.publicDisplayName,
               !displayName.isEmpty {
                self.lblDisplayName.isHidden = false
                self.lblDisplayName.text = displayName
            } else {
                self.lblDisplayName.isHidden = true
            }
        }
    }
    
    func getVerifiedSocialPlatforms() {
        if let notification = notification {
            if let socialPlatforms: [String] = notification.refereeUserId?.socialPlatforms as? [String], socialPlatforms.count > 0 {
                socialPlatFormSettings(socialPlatforms)
            } else {
                verifiedStackView.isHidden = true
            }
        } else {
            if let socialPlatforms = Defaults.shared.referredByData?.socialPlatforms, socialPlatforms.count > 0 {
                socialPlatFormSettings(socialPlatforms)
            }
        }
    }
    
    func socialPlatFormSettings(_ socialPlatfroms: [String]) {
        verifiedStackView.isHidden = false
        for socialPlatform in socialPlatfroms {
            if socialPlatform == R.string.localizable.facebook().lowercased() {
                self.facebookVerifiedView.isHidden = false
            } else if socialPlatform == R.string.localizable.twitter().lowercased() {
                self.twitterVerifiedView.isHidden = false
            } else if socialPlatform == R.string.localizable.snapchat().lowercased() {
                self.snapchatVerifiedView.isHidden = false
            } else if socialPlatform == R.string.localizable.youtube().lowercased() {
              //  self.youtubeVerifiedView.isHidden = false
                // Hide Youtube Temporary
            }
        }
        self.imgUserPlaceholder.image = (socialPlatfroms.count == 4) ? R.image.shareScreenRibbonProfileBadge() : R.image.shareScreenProfileBadge()
       // self.socialMediaVerifiedBadgeView.isHidden = socialPlatfroms.count != 4
    }
    
    func convertDate(_ date: String) -> String {
        let convertedDate = CommonFunctions.getDateInSpecificFormat(dateInput: date, dateOutput: R.string.localizable.mmmdYyyy())
        return convertedDate
    }
    
    func setUpbadges() {
        preLunchBadge.isHidden = true
        foundingMergeBadge.isHidden = true
        socialBadgeicon.isHidden = true
        if let badgearray = Defaults.shared.currentUser?.badges {
            for parentbadge in badgearray {
                let badgeCode = parentbadge.badge?.code ?? ""
                switch badgeCode {
                case Badges.PRELAUNCH.rawValue:
                    preLunchBadge.isHidden = false
                    preLunchBadge.image = R.image.prelaunchBadge()
                case Badges.FOUNDING_MEMBER.rawValue:
                    foundingMergeBadge.isHidden = false
                    foundingMergeBadge.image = R.image.foundingMemberBadge()
                case Badges.SOCIAL_MEDIA_CONNECTION.rawValue:
                    socialBadgeicon.isHidden = false
                    socialBadgeicon.image = R.image.socialBadge()
                default:
                    break
                }
            }
        }
    }
    func setUpSubscriptionBadges() {
        iosBadgeView.isHidden = true
        androidBadgeView.isHidden = true
        webBadgeView.isHidden = true
        preLunchBadge.tag = 4
        foundingMergeBadge.tag = 5
        socialBadgeicon.tag = 6
        androidBadgeView.tag = 7
        iosBadgeView.tag = 8
        webBadgeView.tag = 9
        preLunchBadge.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBadgeTap(_:))))
        foundingMergeBadge.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBadgeTap(_:))))
        socialBadgeicon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBadgeTap(_:))))
        iosBadgeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBadgeTap(_:))))
        androidBadgeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBadgeTap(_:))))
        webBadgeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBadgeTap(_:))))
        
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
    @objc func handleBadgeTap(_ sender: UITapGestureRecognizer? = nil) {
            let vc = BadgesPopUpViewController(nibName: R.nib.badgesPopUpViewController.name, bundle: nil)
            vc.badgeType = .allBadges
            vc.selectedBadgeTag = sender?.view?.tag ?? 0
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true, completion: nil)
        }
}

// MARK: - MIBlurPopupDelegate

extension UserDetailsVC: MIBlurPopupDelegate {
    
    var popupView: UIView {
        popupContentContainerView ?? UIView()
    }
    
    var blurEffectStyle: UIBlurEffect.Style? {
        customBlurEffectStyle
    }
    
    var initialScaleAmmount: CGFloat {
        customInitialScaleAmmount
    }
    
    var animationDuration: TimeInterval {
        customAnimationDuration
    }
    
}
