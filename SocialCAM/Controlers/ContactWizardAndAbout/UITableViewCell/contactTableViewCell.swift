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
