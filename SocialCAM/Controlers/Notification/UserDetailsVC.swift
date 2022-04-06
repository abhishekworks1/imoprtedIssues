//
//  UserDetailsVC.swift
//  SocialCAM
//
//  Created by Viraj Patel on 24/09/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation

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
     @IBOutlet weak var subscriptionBadgeicon: UIImageView!
    
    var notificationUpdateHandler: ((_ notification: UserNotification?) -> Void)?
    var notification: UserNotification?
    
    var customBlurEffectStyle: UIBlurEffect.Style = .dark
    var customInitialScaleAmmount: CGFloat = CGFloat(Double(0.1))
    var customAnimationDuration: TimeInterval = TimeInterval(0.5)
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        customBlurEffectStyle == .dark ? .lightContent : .default
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        modalPresentationCapturesStatusBarAppearance = true
        self.setUpbadges()
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
                self.youtubeVerifiedView.isHidden = false
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