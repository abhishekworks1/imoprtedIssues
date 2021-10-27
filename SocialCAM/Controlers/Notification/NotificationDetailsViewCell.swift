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
    
    var notification: UserNotification? {
        didSet {
            self.setup()
        }
    }
    var followButtonHandler : ((_ notification: UserNotification?) -> Void)?
    
    func setBtnFollow(isFollowing: Bool) {
        if isFollowing {
            btnFollow.backgroundColor = ApplicationSettings.appPrimaryColor
            btnFollow.setTitleColor(ApplicationSettings.appWhiteColor, for: .normal)
            btnFollow.setTitle(R.string.localizable.following(), for: .normal)
        } else {
            btnFollow.backgroundColor = ApplicationSettings.appPrimaryColor
            btnFollow.setTitleColor(ApplicationSettings.appWhiteColor, for: .normal)
            btnFollow.setTitle(R.string.localizable.follow(), for: .normal)
        }
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
            if let userImageUrl = Defaults.shared.currentUser?.refferedBy?.profileImageURL {
                self.imgUserImage.sd_setImage(with: URL.init(string: userImageUrl), placeholderImage: R.image.user_placeholder())
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
            self.lblNotificationDate.text = convertDate(date)
        }
    }
    
    func getVerifiedSocialPlatforms() {
        if let notification = notification {
            if let socialPlatforms = notification.refereeUserId?.socialPlatforms,
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
                self.youtubeVerifiedView.isHidden = false
            }
        }
        self.imgUserPlaceholder.image = (socialPlatfroms.count == 4) ? R.image.shareScreenRibbonProfileBadge() : R.image.shareScreenProfileBadge()
        self.socialMediaVerifiedBadgeView.isHidden = socialPlatfroms.count != 4
    }
    
    func convertDate(_ date: String) -> String {
        let convertedDate = CommonFunctions.getDateInSpecificFormat(dateInput: date, dateOutput: R.string.localizable.mmmdYyyy())
        return convertedDate
    }
    
    @IBAction func followButtonTapped(_ sender: UIButton) {
        if let handler = self.followButtonHandler {
            handler(self.notification)
        }
    }
}
