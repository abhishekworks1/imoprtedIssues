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
            self.lblUserName.text = notification.title
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
    }
    
    @IBAction func followButtonTapped(_ sender: UIButton) {
        if let handler = self.followButtonHandler {
            handler(self.notification)
        }
    }
}
