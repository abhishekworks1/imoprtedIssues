//
//  contactTableViewCell.swift


import UIKit


protocol contactCelldelegate : AnyObject {
    func didPressButton(_ contact: PhoneContact ,mobileContact:ContactResponse?,reInvite:Bool)
}

class contactTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblDisplayName: UILabel!
    @IBOutlet weak var lblNumberEmail: UILabel!
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var inviteBtn: UIButton!

    @IBOutlet weak var contactStatusView: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    
    @IBOutlet weak var imgSocialMediaBadge: UIImageView!
    @IBOutlet weak var imgprelaunch: UIImageView!
    @IBOutlet weak var imgfoundingMember: UIImageView!
    @IBOutlet weak var imgSubscribeBadge: UIImageView!
    
    @IBOutlet weak var inviteButtonView: UIView!
    @IBOutlet weak var lblInviteButtonTitle: UILabel!
    @IBOutlet weak var buttonImageview: UIImageView!
    @IBOutlet weak var buttonInvite: UIButton!
    
    @IBOutlet weak var refferalView: UIView!
    @IBOutlet weak var lblReferralCount: UILabel!
    @IBOutlet weak var lblSubscriberCount: UILabel!
    var cellDelegate: contactCelldelegate?
    var phoneContactObj : PhoneContact?
    var mobileContactObj : ContactResponse?
    var badges = [ParentBadges]()
    
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
        let view = UIView()
        view.backgroundColor = .white
        
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        var reInvite = false
        if mobileContactObj?.status == ContactStatus.invited{
            reInvite = true
        }
        cellDelegate?.didPressButton(phoneContactObj ?? PhoneContact(), mobileContact: mobileContactObj, reInvite: reInvite)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    func setBadges() {
        var badgearry = self.getbadgesArray()
        badgearry = badgearry.filter { $0 != "iosbadge" && $0 != "androidbadge"}
        imgprelaunch.isHidden = true
        imgfoundingMember.isHidden = true
        imgSocialMediaBadge.isHidden = true
        imgSubscribeBadge.isHidden = true
        
        if  badgearry.count >  0 {
            imgprelaunch.isHidden = false
            imgprelaunch.image = UIImage.init(named: badgearry[0])
        }
        if  badgearry.count >  1 {
            imgfoundingMember.isHidden = false
            imgfoundingMember.image = UIImage.init(named: badgearry[1])
        }
        if  badgearry.count >  2 {
            imgSocialMediaBadge.isHidden = false
            imgSocialMediaBadge.image = UIImage.init(named: badgearry[2])
        }
        if  badgearry.count >  3 {
            imgSubscribeBadge.isHidden = false
            imgSubscribeBadge.image = UIImage.init(named: badgearry[3])
        }
        setUpSubscriptionBadges()
    }
    
    func setUpSubscriptionBadges() {
        androidIconImageview.isHidden = true
//        badgeView.isHidden = false
        iosBadgeView.isHidden = true
        androidBadgeView.isHidden = true
        webBadgeView.isHidden = true
        iosIconImageview.isHidden = true
        webIconImageview.isHidden = true
        androidIconImageview.isHidden = true
       
        
        if badges.count > 0 {
            for parentbadge in badges {
                let badgeCode = parentbadge.badge?.code ?? ""
                let freeTrialDay = parentbadge.meta?.freeTrialDay ?? 0
                let subscriptionType = parentbadge.meta?.subscriptionType ?? ""
                let finalDay = Defaults.shared.getCountFromBadge(parentbadge: parentbadge)
                iosIconImageview.isHidden = true
                androidIconImageview.isHidden = true
                webIconImageview.isHidden = true
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
                      //  androidBadgeView.isHidden = false
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
    
   func getbadgesArray() -> [String] {
       var imageArray = [String]()
       if badges.count > 0 {
           let badgesArray = badges
           print("badgesArray \(imageArray)")
           for i in 0 ..< (badgesArray.count){
               let badge = badgesArray[i] as ParentBadges
               let badImgname = self.imageNameBasedOnCode(code : badge.badge?.code ?? "")
               if badImgname.count > 0 {
                   imageArray.append(badImgname)
               }
           }
       }
       print("Badges imageArray \(imageArray)")
       return imageArray
   }
    func imageNameBasedOnCode(code:String) -> String{
        var imageName = ""
        switch code {
        case Badges.PRELAUNCH.rawValue:
            imageName = "prelaunchBadge"
        case Badges.FOUNDING_MEMBER.rawValue:
            imageName = "foundingMemberBadge"
        case Badges.SOCIAL_MEDIA_CONNECTION.rawValue:
            imageName = "socialBadge"
            //As subscription badges have to removed from header and other places
            //Now subscription badges are added in Settings List and Grid
      /*  case Badges.SUBSCRIBER_IOS.rawValue:
            imageName = "iosbadge"
        case Badges.SUBSCRIBER_ANDROID.rawValue:
            imageName = "androidbadge"
        case Badges.SUBSCRIBER_WEB.rawValue:
            imageName = "webbadge" */
        default:
            imageName = ""
        }
        return imageName
    }
}
