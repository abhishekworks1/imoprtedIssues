//
//  NotificationDetailsViewCell.swift
//  SocialCAM
//
//  Created by Viraj Patel on 08/10/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation

class NotificationDetailsViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgUserPlaceholder: UIImageView!
    @IBOutlet weak var imgUserImage: UIImageView!
    @IBOutlet weak var btnFollow: PButton!
    @IBOutlet weak var lblChannelName: UILabel!
    @IBOutlet weak var lblDisplayName: UILabel!
    @IBOutlet weak var lblJoiningDate: UILabel!
    @IBOutlet weak var verifiedStackView: UIStackView!
    @IBOutlet weak var facebookVerifiedView: UIView!
    @IBOutlet weak var twitterVerifiedView: UIView!
    @IBOutlet weak var snapchatVerifiedView: UIView!
    @IBOutlet weak var youtubeVerifiedView: UIView!
    @IBOutlet weak var socialMediaVerifiedBadgeView: UIView!
    @IBOutlet weak var flagStackView: UIStackView!
    @IBOutlet var countryView: [UIView]!
    @IBOutlet var lblCountrys: [UILabel]!
    @IBOutlet var imgCountrys: [UIImageView]!
    @IBOutlet weak var verifiedStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var flagStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblNotificationDate: UILabel!
    
    //Badges
    @IBOutlet weak var preLaunchBadgeImageView: UIImageView!
    @IBOutlet weak var foundingMemberBadgeImageView: UIImageView!
    @IBOutlet weak var socialBadgeImageView: UIImageView!
    
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
    
    
    var notification: UserNotification? {
        didSet {
            self.setup()
            self.setUpSubscriptionBadges()
        }
    }
    var followButtonHandler : ((_ notification: UserNotification?) -> Void)?
    var badgeTapHandler : ((_ sender: UITapGestureRecognizer?)  -> Void)?
    
    func setBtnFollow(isFollowing: Bool) {
        btnFollow.backgroundColor = ApplicationSettings.appPrimaryColor
        btnFollow.setTitleColor(ApplicationSettings.appWhiteColor, for: .normal)
        btnFollow.setTitle(isFollowing ? R.string.localizable.following() : R.string.localizable.follow(), for: .normal)
    }
    
    func setup() {
        if let notification = notification {
            self.lblUserName.text = notification.iosTitle ?? notification.title
        }
        self.imgUserImage.layer.cornerRadius = imgUserImage.bounds.width / 2
        self.imgUserImage.contentMode = .scaleAspectFill
        if let userImageURL = notification?.refereeUserId?.profileImageURL {
            self.imgUserImage.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: R.image.user_placeholder())
        } else {
            if Defaults.shared.currentUser?.id == Defaults.shared.currentUser?.refferedBy?.id {
                if let userImageUrl = Defaults.shared.currentUser?.refferedBy?.id {
                    self.imgUserImage.sd_setImage(with: URL.init(string: userImageUrl), placeholderImage: R.image.user_placeholder())
                }
            }
        }
        
        if let isFollowing = notification?.isFollowing {
            setBtnFollow(isFollowing: isFollowing)
        } else {
            setBtnFollow(isFollowing: false)
        }
        if let channelId = notification?.refereeUserId?.channelId {
            self.lblChannelName.text = "@\(channelId)"
        }
        if let user = Defaults.shared.currentUser,
           let channelId = user.channelId{
            if channelId == notification?.refereeUserId?.channelId ?? ""{
                self.btnFollow.isHidden = true
            }else{
                self.btnFollow.isHidden = false
            }
        }
        self.getVerifiedSocialPlatforms()
        if let createdDate = notification?.refereeUserId?.created {
            self.lblJoiningDate.text = R.string.localizable.sinceJoined(convertDate(createdDate))
        }
        if let notification = notification {
            if let isShowFlags = notification.refereeUserId?.isShowFlags,
               isShowFlags, let flages = notification.refereeUserId?.userStateFlags,
               flages.count > 0 {
                flagStackView.isHidden = false
                flagStackViewHeightConstraint.constant = 70
                for (index, item) in flages.enumerated() {
                    self.countryView[index].isHidden = false
                    let country: Country = Country(name: (item.state != nil && item.state != "") ? (item.state ?? "") : (item.country ?? ""), code: (item.state != nil && item.state != "") ? (item.stateCode ?? "") : (item.countryCode ?? ""), phoneCode: "", isState: (item.state != nil && item.state != ""))
                    self.lblCountrys[index].text = country.isState ? item.state : item.country
                    self.imgCountrys[index].image = country.flag
                }
            } else {
                flagStackView.isHidden = true
                flagStackViewHeightConstraint.constant = 0
            }
            if let displayName = notification.publicDisplayName,
               !displayName.isEmpty {
                self.lblDisplayName.isHidden = false
                self.lblDisplayName.text = displayName
            } else {
                self.lblDisplayName.isHidden = true
            }
        }
        if let date = notification?.createdAt {
            self.lblNotificationDate.text = "   \(convertDate(date))"
        }
    }
    
    func getVerifiedSocialPlatforms() {
        if let notification = notification {
            if let socialPlatforms = notification.refereeUserId?.socialPlatforms as? [String],
               socialPlatforms.count > 0 {
                socialPlatFormSettings(socialPlatforms)
                verifiedStackView.isHidden = false
                verifiedStackViewHeightConstraint.constant = 37
            } else {
                verifiedStackView.isHidden = true
                verifiedStackViewHeightConstraint.constant = 0
            }
        }
    }
    
    func socialPlatFormSettings(_ socialPlatfroms: [String]) {
        for socialPlatform in socialPlatfroms {
            if socialPlatform == R.string.localizable.facebook().lowercased() {
                self.facebookVerifiedView.isHidden = false
            } else if socialPlatform == R.string.localizable.twitter().lowercased() {
                self.twitterVerifiedView.isHidden = false
            } else if socialPlatform == R.string.localizable.snapchat().lowercased() {
                self.snapchatVerifiedView.isHidden = false
            } else if socialPlatform == R.string.localizable.youtube().lowercased() {
                // self.youtubeVerifiedView.isHidden = false
               // Hide Youtube Temporary
            }
        }
        self.imgUserPlaceholder.image = (socialPlatfroms.count == 4) ? R.image.shareScreenRibbonProfileBadge() : R.image.shareScreenProfileBadge()
//        self.socialMediaVerifiedBadgeView.isHidden = socialPlatfroms.count != 4
    }
    
    func convertDate(_ date: String) -> String {
        let convertedDate = CommonFunctions.getDateInSpecificFormat(dateInput: date, dateOutput: "h:mm a \(R.string.localizable.mmmdYyyy())")
        return convertedDate
    }
    
    @IBAction func followButtonTapped(_ sender: UIButton) {
        if let handler = self.followButtonHandler {
            handler(self.notification)
        }
    }
    func setUpSubscriptionBadges() {
        preLaunchBadgeImageView.isHidden = true
        socialBadgeImageView.isHidden = true
        foundingMemberBadgeImageView.isHidden = true
        iosBadgeView.isHidden = true
        androidBadgeView.isHidden = true
        webBadgeView.isHidden = true
        
//        dayBadgeAndroidImageView.tag = 1
//        dayBadgeIosImageView.tag = 2
//        dayBadgeWebImageView.tag = 3
        preLaunchBadgeImageView.tag = 4
        foundingMemberBadgeImageView.tag = 5
        socialBadgeImageView.tag = 6
        androidBadgeView.tag = 7
        iosBadgeView.tag = 8
        webBadgeView.tag = 9

        preLaunchBadgeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBadgeTap(_:))))
        foundingMemberBadgeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBadgeTap(_:))))
        socialBadgeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBadgeTap(_:))))
//        dayBadgeIosImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBadgeTap(_:))))
//        dayBadgeAndroidImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBadgeTap(_:))))
//        dayBadgeWebImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBadgeTap(_:))))
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
                switch badgeCode {
                case Badges.PRELAUNCH.rawValue:
                    preLaunchBadgeImageView.isHidden = false
                    preLaunchBadgeImageView.image = R.image.prelaunchBadge()
                case Badges.FOUNDING_MEMBER.rawValue:
                    foundingMemberBadgeImageView.isHidden = false
                    foundingMemberBadgeImageView.image = R.image.foundingMemberBadge()
                case Badges.SOCIAL_MEDIA_CONNECTION.rawValue:
                    socialBadgeImageView.isHidden = false
                    socialBadgeImageView.image = R.image.socialBadge()
                default:
                    break
                }
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
        if let handler = self.badgeTapHandler {
            handler(sender)
        }
    }
    
}
