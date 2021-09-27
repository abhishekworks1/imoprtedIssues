//
//  NotificationTypeCell.swift
//  SocialCAM
//
//  Created by Testing on 16/09/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation

enum NotificationType: Int {
    case newSignups = 0
    case newSubscriptions
}

class NotificationTypeCell: UITableViewCell {
    
    // MARK: - Outlets declaration
    @IBOutlet weak var lblNotificationType: UILabel!
    @IBOutlet weak var lblTitleForAllUsers: UILabel!
    @IBOutlet weak var btnForAllUsers: UIButton!
    @IBOutlet weak var txtDropDown: DropDown!
    @IBOutlet weak var btnForLimitedUsers: UIButton!
    
    // MARK: - Variables declaration
    var notificationType: NotificationType = .newSignups {
        didSet {
            if notificationType == .newSignups {
                self.lblNotificationType.text = R.string.localizable.newSignups()
                self.lblTitleForAllUsers.text = R.string.localizable.everyone()
                self.setSelection(newSignupsNotificationType: Defaults.shared.newSignupsNotificationType)
            } else if notificationType == . newSubscriptions {
                self.lblNotificationType.text = R.string.localizable.newSubscriptions()
                self.lblTitleForAllUsers.text = R.string.localizable.everytime()
                self.setSelection(newSubscriptionNotificationType: Defaults.shared.newSubscriptionNotificationType)
            }
        }
    }
    
    // MARK: - Life cycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setup()
    }
    
    // MARK: - Setup methods
    func setup() {
        
    }
    
    func setSelection(newSignupsNotificationType: NewSignupsNotificationType) {
        switch newSignupsNotificationType {
        case .forAllUsers:
            btnForAllUsers.isSelected = true
            btnForLimitedUsers.isSelected = false
        case .forLimitedUsers:
            btnForAllUsers.isSelected = false
            btnForLimitedUsers.isSelected = true
        }
    }
    
    func setSelection(newSubscriptionNotificationType: NewSubscriptionNotificationType) {
        switch newSubscriptionNotificationType {
        case .forAllUsers:
            btnForAllUsers.isSelected = true
            btnForLimitedUsers.isSelected = false
        case .forLimitedUsers:
            btnForAllUsers.isSelected = false
            btnForLimitedUsers.isSelected = true
        }
    }
    
    // MARK: - Action methods
    @IBAction func btnForAllUsersClicked(_ sender: UIButton) {
        if notificationType == .newSignups {
            Defaults.shared.newSignupsNotificationType = .forAllUsers
            self.setSelection(newSignupsNotificationType: Defaults.shared.newSignupsNotificationType)
        } else if notificationType == . newSubscriptions {
            Defaults.shared.newSubscriptionNotificationType = .forAllUsers
            self.setSelection(newSubscriptionNotificationType: Defaults.shared.newSubscriptionNotificationType)
        }
    }
    
    @IBAction func btnForSelectedUserClicked(_ sender: UIButton) {
        if notificationType == .newSignups {
            Defaults.shared.newSignupsNotificationType = .forLimitedUsers
            self.setSelection(newSignupsNotificationType: Defaults.shared.newSignupsNotificationType)
        } else if notificationType == . newSubscriptions {
            Defaults.shared.newSubscriptionNotificationType = .forLimitedUsers
            self.setSelection(newSubscriptionNotificationType: Defaults.shared.newSubscriptionNotificationType)
        }
    }
    
}
