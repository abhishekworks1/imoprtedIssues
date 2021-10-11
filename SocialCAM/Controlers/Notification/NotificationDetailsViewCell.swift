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
        
        btnFollow.backgroundColor = ApplicationSettings.appClearColor
        btnFollow.setTitleColor(ApplicationSettings.appPrimaryColor, for: .normal)
        btnFollow.setTitle(R.string.localizable.follow(), for: .normal)
    }
}
