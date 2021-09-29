//
//  NotificationTableViewCell.swift
//  SocialCAM
//
//  Created by Viraj Patel on 23/09/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation

class NotificationTableViewCell: UITableViewCell {
    @IBOutlet var lblTime: UILabel?
    @IBOutlet var lblName: UILabel?
    @IBOutlet var profileImgView: UIImageView?
    var indexPath: IndexPath?
    var notification: UserNotification? {
        didSet {
            if let notification = self.notification {
                self.lblName?.text = notification.title
                if let date = notification.createdAt {
                    self.lblTime?.text = date.utcDateFromString().timeAgoSinceDate(numericDates: true)
                }
                if let sender = notification.refereeUserId {
                    if let url = sender.profileImageURL {
                        self.profileImgView?.sd_setImage(with: URL.init(string: url), placeholderImage: ApplicationSettings.userPlaceHolder)
                    } else {
                        self.profileImgView?.image = ApplicationSettings.userPlaceHolder
                    }
                } else {
                     self.profileImgView?.image = ApplicationSettings.userPlaceHolder
                }
                if let isRead = notification.isRead {
                    self.backgroundColor = isRead ? UIColor.white : R.color.notificationBgColor()
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImgView?.backgroundColor = ApplicationSettings.appWhiteColor
        // Initialization code
    }

}
