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
    var profileImgHandler : ((_ notification: UserNotification?) -> Void)?
    var profileDeatilsHandler : ((_ notification: UserNotification?) -> Void)?
    
    var notification: UserNotification? {
        didSet {
            if let notification = self.notification {
                self.lblName?.text = notification.iosTitle ?? notification.title
                if let date = notification.createdAt {
                    self.lblTime?.text = date.fromUTCToLocalDateTime().timeAgoSinceDate(numericDates: true)
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
    
    @objc func profileImgViewTapped(sender: Any) {
        if let handler = self.profileImgHandler {
            handler(self.notification)
        }
    }
    
    @objc func lblNameTapped(sender: Any) {
        if let handler = self.profileDeatilsHandler {
            handler(self.notification)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImgView?.backgroundColor = ApplicationSettings.appWhiteColor
        // Initialization code
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.profileImgViewTapped(sender:)))
        tap.numberOfTapsRequired = 1
        profileImgView?.addGestureRecognizer(tap)
        profileImgView?.isUserInteractionEnabled = true
        
        let tapLblName = UITapGestureRecognizer(target: self, action: #selector(self.lblNameTapped(sender:)))
        tapLblName.numberOfTapsRequired = 1
        lblName?.addGestureRecognizer(tapLblName)
        lblName?.isUserInteractionEnabled = true
    }

}
