//
//  StorySettingsCell.swift
//  ProManager
//
//  Created by Jasmin Patel on 21/06/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit

class StorySettingsCell: UITableViewCell {

    @IBOutlet weak var badgesCountLabel: ColorBGLabel!
    @IBOutlet weak var roundedView: RoundedView!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var onOffButton: UIButton!
    @IBOutlet weak var settingsName: UILabel!
    @IBOutlet weak var socialImageView: UIImageView?
    @IBOutlet weak var lblPremiumVersionOnly: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imgSettingsIcon: UIImageView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var imgSubscribeBadge: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       // shadowView.dropShadowNew()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class StorySettingsListCell: UITableViewCell {

    static let identifier = "StorySettingsListCell"
    @IBOutlet weak var badgesCountLabel: ColorBGLabel!
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var onOffButton: UIButton!
    @IBOutlet weak var settingsName: UILabel!
    @IBOutlet weak var socialImageView: UIImageView?
    @IBOutlet weak var lblPremiumVersionOnly: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imgSettingsIcon: UIImageView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var badgeView: UIView!
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
    
    @IBOutlet weak var newBadgesImageView: UIImageView!
    @IBOutlet weak var notificationCountView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
      //  shadowView.dropShadow(color: .gray, opacity: 1.5, offSet: CGSize(width: 1, height: 1), radius: 3, scale: false)
        roundedView.layer.cornerRadius = roundedView.frame.size.width / 2
        shadowView.layer.cornerRadius = 7
        shadowView.dropShadowNew()
//        addShadow(cornerRadius: 5.0, borderWidth: 0.0, shadowOpacity: 0.5, shadowRadius: 3.0)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func setUpSubscriptionBadges() {
        badgeView.isHidden = false
        iosBadgeView.isHidden = true
        androidBadgeView.isHidden = true
        webBadgeView.isHidden = true
        
        if let badgearray = Defaults.shared.currentUser?.badges {
            for parentbadge in badgearray {
                let badgeCode = parentbadge.badge?.code ?? ""
                let freeTrialDay = parentbadge.meta?.freeTrialDay ?? 0
                let subscriptionType = parentbadge.meta?.subscriptionType ?? ""
                let finalDay = Defaults.shared.getCountFromBadge(parentbadge: parentbadge)
                
                // Setup For iOS Badge
                if badgeCode == Badges.SUBSCRIBER_IOS.rawValue
                {
                    if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                        iosBadgeView.isHidden = false
                        lbliosDaysRemains.text = finalDay
                        iosSheildImageview.image = R.image.freeBadge()
                        iosIconImageview.image = R.image.freeAppleIcon()
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
                            iosSheildImageview.image = R.image.squareBadge()
                            iosIconImageview.image = R.image.freeAppleIcon()
//                        }
                    }
                    
                    if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
                        iosBadgeView.isHidden = false
                        lbliosDaysRemains.text = finalDay
                        iosSheildImageview.image = R.image.basicBadge()
                        iosIconImageview.image = R.image.basicAppleIcon()
                    }
                    if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
                        iosBadgeView.isHidden = false
                        lbliosDaysRemains.text = finalDay
                        iosSheildImageview.image = R.image.advancedBadge()
                        iosIconImageview.image = R.image.advancedAppleIcon()
                    }
                    if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue {
                        iosBadgeView.isHidden = false
                        lbliosDaysRemains.text = finalDay
                        iosSheildImageview.image = R.image.proBadge()
                        iosIconImageview.image = R.image.preAppleIcon()
                    }
                }
                // Setup For Android Badge
                if badgeCode == Badges.SUBSCRIBER_ANDROID.rawValue
                {
                    if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                        androidBadgeView.isHidden = false
                        lblandroidDaysRemains.text = finalDay
                        androidSheildImageview.image = R.image.freeBadge()
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
                        androidBadgeView.isHidden = false
                        if freeTrialDay > 0 {
                            lblandroidDaysRemains.text = finalDay
                            androidSheildImageview.image = R.image.freeBadge()
                        } else {
                            lblandroidDaysRemains.text = ""
                            androidSheildImageview.image = R.image.squareBadge()
                        }
                    }
                    if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
                        androidBadgeView.isHidden = false
                        lblandroidDaysRemains.text = finalDay
                        androidSheildImageview.image = R.image.basicBadge()
                    }
                    if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
                        androidBadgeView.isHidden = false
                        lblandroidDaysRemains.text = finalDay
                        androidSheildImageview.image = R.image.advancedBadge()
                    }
                    if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue {
                        androidBadgeView.isHidden = false
                        lblandroidDaysRemains.text = finalDay
                        androidSheildImageview.image = R.image.proBadge()
                    }
                }
                
                if badgeCode == Badges.SUBSCRIBER_WEB.rawValue
                {
                    if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                        webBadgeView.isHidden = false
                        lblwebDaysRemains.text = finalDay
                        webSheildImageview.image = R.image.freeBadge()
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
                        webBadgeView.isHidden = false
                        if freeTrialDay > 0 {
                            lblwebDaysRemains.text = finalDay
                            webSheildImageview.image = R.image.freeBadge()
                        } else {
                            lblwebDaysRemains.text = ""
                            webSheildImageview.image = R.image.squareBadge()
                        }
                    }
                    
                    if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
                        webBadgeView.isHidden = false
                        lblwebDaysRemains.text = finalDay
                        webSheildImageview.image = R.image.basicBadge()
                    }
                    if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
                        webBadgeView.isHidden = false
                        lblwebDaysRemains.text = finalDay
                        webSheildImageview.image = R.image.advancedBadge()
                    }
                    if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue {
                        webBadgeView.isHidden = false
                        lblwebDaysRemains.text = finalDay
                        webSheildImageview.image = R.image.proBadge()
                    }
                }
            }
        }
    }
}
class AppOpenSettingsCell: UITableViewCell {
    
    @IBOutlet var dashBoardView: ScreenSelectionView!
    @IBOutlet var chatView: ScreenSelectionView!
    @IBOutlet var cameraView: ScreenSelectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let x = Defaults.shared.openingScreen.rawValue
        self.setOpenScreen(x: x)
        dashBoardView.selectionHandler = { [unowned self] in
            self.setOpenScreen(x: 1)
            Defaults.shared.openingScreen = .dashboard
        }
        chatView.selectionHandler = { [unowned self] in
            self.setOpenScreen(x: 2)
            Defaults.shared.openingScreen = .chat
        }
        cameraView.selectionHandler = { [unowned self] in
            self.setOpenScreen(x: 0)
            Defaults.shared.openingScreen = .camera
        }
    }
    
    func setOpenScreen(x: Int) {
        switch x {
        case 0:
            self.cameraView.isSelected = true
            self.dashBoardView.isSelected = false
            self.chatView.isSelected = false
        case 1:
            self.cameraView.isSelected = false
            self.dashBoardView.isSelected = true
            self.chatView.isSelected = false
        case 2:
            self.cameraView.isSelected = false
            self.dashBoardView.isSelected = false
            self.chatView.isSelected = true
        default:
            self.cameraView.isSelected = true
            self.dashBoardView.isSelected = false
            self.chatView.isSelected = false
        }
    }
    
}

extension UIView{
    func addShadow(cornerRadius:CGFloat = 0.0 , borderWidth:CGFloat = 0.0 , shadowOpacity:Float = 0.0 , shadowRadius:CGFloat = 0.0){
        // border radius
        self.layer.cornerRadius = cornerRadius
        
        // border
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = borderWidth
        
        // drop shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
    }
}
