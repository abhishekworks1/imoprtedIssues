//
//  SettingsCollectionCell.swift
//  SocialCAM
//
//  Created by ideveloper5 on 25/04/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class SettingsCollectionCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var settingsName: UILabel!
    @IBOutlet weak var socialImageView: UIImageView?
    @IBOutlet weak var imgSubscribeBadge: UIImageView!
    
    @IBOutlet weak var countLabel: ColorBGLabel!
    @IBOutlet weak var roundedView: RoundedView!
    
    
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
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        containerView.addShadow(cornerRadius: 5.0, borderWidth: 0.0, shadowOpacity: 0.5, shadowRadius: 3.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.dropShadowNew()
       
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
                
                // Setup For iOS Badge
                if badgeCode == Badges.SUBSCRIBER_IOS.rawValue
                {
                    iosBadgeView.isHidden = false
                    if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                        lbliosDaysRemains.text = freeTrialDay > 0 ? "\(freeTrialDay)" : ""
                        iosSheildImageview.image = R.image.freeBadge()
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
                        if freeTrialDay > 0 {
                            lbliosDaysRemains.text = "\(freeTrialDay)"
                            iosSheildImageview.image = R.image.freeBadge()
                        } else {
                            //iOS shield hide
                            //square badge show
                            lbliosDaysRemains.text = ""
                            iosSheildImageview.image = R.image.squareBadge()
                        }
                    }
                    
                    if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
                        lbliosDaysRemains.text = freeTrialDay == 0 ? "" : "\(freeTrialDay)"
                        iosSheildImageview.image = R.image.basicBadge()
                    }
                    if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
                        lbliosDaysRemains.text = freeTrialDay == 0 ? "" : "\(freeTrialDay)"
                        iosSheildImageview.image = R.image.advancedBadge()
                    }
                    if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue {
                        lbliosDaysRemains.text = freeTrialDay == 0 ? "" : "\(freeTrialDay)"
                        iosSheildImageview.image = R.image.proBadge()
                    }
                }
                
                if badgeCode == Badges.SUBSCRIBER_ANDROID.rawValue
                {
                    androidBadgeView.isHidden = false
                    if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                        lblandroidDaysRemains.text = freeTrialDay > 0 ? "\(freeTrialDay)" : ""
                        androidSheildImageview.image = R.image.freeBadge()
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
                        if freeTrialDay > 0 {
                            lblandroidDaysRemains.text = "\(freeTrialDay)"
                            androidSheildImageview.image = R.image.freeBadge()
                        } else {
                            lblandroidDaysRemains.text = ""
                            androidSheildImageview.image = R.image.squareBadge()
                        }
                    }
                    if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
                        lblandroidDaysRemains.text = freeTrialDay == 0 ? "" : "\(freeTrialDay)"
                        androidSheildImageview.image = R.image.basicBadge()
                    }
                    if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
                        lblandroidDaysRemains.text = freeTrialDay == 0 ? "" : "\(freeTrialDay)"
                        androidSheildImageview.image = R.image.advancedBadge()
                    }
                    if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue {
                        lblandroidDaysRemains.text = freeTrialDay == 0 ? "" : "\(freeTrialDay)"
                        androidSheildImageview.image = R.image.proBadge()
                    }
                }
                
                if badgeCode == Badges.SUBSCRIBER_WEB.rawValue
                {
                    webBadgeView.isHidden = false
                    if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                        lblwebDaysRemains.text = freeTrialDay > 0 ? "\(freeTrialDay)" : ""
                        webSheildImageview.image = R.image.freeBadge()
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
                        if freeTrialDay > 0 {
                            lblwebDaysRemains.text = "\(freeTrialDay)"
                            webSheildImageview.image = R.image.freeBadge()
                        } else {
                            lblwebDaysRemains.text = ""
                            webSheildImageview.image = R.image.squareBadge()
                        }
                    }
                    
                    if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
                        lblwebDaysRemains.text = freeTrialDay == 0 ? "" : "\(freeTrialDay)"
                        webSheildImageview.image = R.image.basicBadge()
                    }
                    if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
                        lblwebDaysRemains.text = freeTrialDay == 0 ? "" : "\(freeTrialDay)"
                        webSheildImageview.image = R.image.advancedBadge()
                    }
                    if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue {
                        lblwebDaysRemains.text = freeTrialDay == 0 ? "" : "\(freeTrialDay)"
                        webSheildImageview.image = R.image.proBadge()
                    }
                }
                
            }
        }
    }
}
