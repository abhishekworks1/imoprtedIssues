//
//  ShareSettingViewController.swift
//  SocialCAM
//
//  Created by Nilisha Gupta on 31/08/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit
import SafariServices
import FBSDKShareKit
import MessageUI
import SDWebImage

enum EmailType {
    case gmail
    case outlook
}

class ShareSettingViewController: UIViewController {
    
    // MARK: - Outlets Declaration
    @IBOutlet weak var preLunchBadgeImageView: UIImageView!
    
    @IBOutlet weak var foundingMergeBadgeImageView: UIImageView!
    
    @IBOutlet weak var socialBadgeiconImageView: UIImageView!
    @IBOutlet weak var subscriptionBadgeiconImageView: UIImageView!
    @IBOutlet weak var lblHyperLink: UILabel!
    @IBOutlet weak var txtLinkWithCheckOut: UITextView!
    @IBOutlet weak var lblReferralLink: UILabel!
    @IBOutlet weak var profileView: UIView!
    
    @IBOutlet weak var imgProfileBadge: UIImageView!
    @IBOutlet weak var imageQrCode: UIImageView!
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var verifiedView: UIView!
    @IBOutlet weak var facebookVerifiedView: UIView!
    @IBOutlet weak var twitterVerifiedView: UIView!
    @IBOutlet weak var snapchatVerifiedView: UIView!
    @IBOutlet weak var youtubeVerifiedView: UIView!
    @IBOutlet weak var btnIncludeProfileImg: UIButton!
    @IBOutlet weak var btnIncludeQrImg: UIButton!
    @IBOutlet weak var instagramView: UIView!
    @IBOutlet weak var lblSinceDate: UILabel!
    @IBOutlet var countryView: [UIView]!
    @IBOutlet var lblCountrys: [UILabel]!
    @IBOutlet var imgCountrys: [UIImageView]!
    @IBOutlet weak var flagStackviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var shareTooltipPopupView: UIView!
    @IBOutlet weak var btnDoNotShowAgain: UIButton!
    
    @IBOutlet weak var dayBadgeAndroidImageView: UIImageView!
      @IBOutlet weak var dayBadgeIosImageView: UIImageView!
      @IBOutlet weak var dayBadgeWebImageView: UIImageView!
    
    @IBOutlet weak var foundingMergeBadge: UIView!
    @IBOutlet weak var preLunchBadge: UIView!
    @IBOutlet weak var socialBadgeicon: UIView!
    @IBOutlet weak var socialBadgeStackView: UIStackView!
    @IBOutlet weak var lblDisplayName: UILabel!
    @IBOutlet weak var showFlagsView: UIStackView!
    
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
    
    // MARK: - Variable Declarations
    var myMutableString = NSMutableAttributedString()
    var isIncludeProfileImg = Defaults.shared.includeProfileImgForShare
    var isIncludeQrImg = Defaults.shared.includeQRImgForShare

    let themeBlueColor = UIColor(hexString:"4F2AD8")
    let logoImage = UIImage(named:"qr_applogo")
    // MARK: - View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Setup Methods
    func setup() {
        setUpbadges()
        setUpSubscriptionBadges()
        if let channelId = Defaults.shared.currentUser?.channelId {
            self.setAttributedString()
            self.txtLinkWithCheckOut.text = "\(R.string.localizable.checkOutThisCoolNewAppQuickCam())"
            self.lblReferralLink.text = "\(websiteUrl)/\(channelId)"
            self.lblUserName.text = "@\(channelId)"
        }
        if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
//            self.imgProfilePic.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: R.image.user_placeholder())
            self.imgProfilePic.layer.cornerRadius = imgProfilePic.bounds.width / 2
            self.imgProfilePic.contentMode = .scaleAspectFill
            imgProfilePic.loadImageWithSDwebImage(imageUrlString: userImageURL)
            
        }
//        if let qrImageURL = Defaults.shared.currentUser?.qrcode {
//            self.imageQrCode.sd_setImage(with: URL.init(string: qrImageURL), placeholderImage: nil)
//        }
        if let referralPage = Defaults.shared.currentUser?.referralPage {
            let image =  URL(string: referralPage)?.qrImage(using: themeBlueColor, logo: logoImage)
            self.imageQrCode.image = image?.convert()
        }
        self.btnIncludeProfileImg.isSelected = Defaults.shared.includeProfileImgForShare == true
        self.btnIncludeQrImg.isSelected = Defaults.shared.includeQRImgForShare == true
        self.getVerifiedSocialPlatforms()
        self.instagramView.isHidden = Defaults.shared.includeProfileImgForShare != true
        if let createdDate = Defaults.shared.currentUser?.created {
            let date = CommonFunctions.getDateInSpecificFormat(dateInput: createdDate, dateOutput: R.string.localizable.mmmdYyyy())
            self.lblSinceDate.text = R.string.localizable.sinceJoined(date)
        }
        DispatchQueue.main.async {
            if let flages = Defaults.shared.currentUser?.userStateFlags, flages.count > 0,
               let isShowFlags = Defaults.shared.currentUser?.isShowFlags,
               isShowFlags {
                self.flagStackviewHeightConstraint.constant = 70
                for (index, item) in flages.enumerated() {
                    self.countryView[index].isHidden = false
                    let country: Country = Country(name: item.country ?? "", code: (item.state == "") ? (item.countryCode ?? "") : (item.stateCode ?? ""), phoneCode: "", isState: (item.state != ""))
                    self.lblCountrys[index].text = country.isState ? item.state : item.country
                    self.imgCountrys[index].image = country.flag
                }
            } else {
                self.flagStackviewHeightConstraint.constant = 0
            }
        }
        if let displayName =  Defaults.shared.publicDisplayName,
           !displayName.isEmpty {
            self.lblDisplayName.isHidden = false
            self.lblDisplayName.text = displayName
        } else {
            self.lblDisplayName.isHidden = true
        }
        if isQuickApp || isQuickCamApp {
           self.showFlagsView.isHidden = true
        }
    }
    
    func presentSafariBrowser(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
    
    func setUpbadges() {
        preLunchBadge.isHidden = true
        foundingMergeBadge.isHidden = true
        socialBadgeicon.isHidden = true
        
        if let badgearray = Defaults.shared.currentUser?.badges {
            for parentbadge in badgearray {
                let badgeCode = parentbadge.badge?.code ?? ""
                switch badgeCode {
                case Badges.PRELAUNCH.rawValue:
                    preLunchBadge.isHidden = false
                    preLunchBadgeImageView.image = R.image.prelaunchBadge()
                case Badges.FOUNDING_MEMBER.rawValue:
                    foundingMergeBadge.isHidden = false
                    foundingMergeBadgeImageView.image = R.image.foundingMemberBadge()
                case Badges.SOCIAL_MEDIA_CONNECTION.rawValue:
                    socialBadgeicon.isHidden = false
                    socialBadgeiconImageView.image = R.image.socialBadge()
                default:
                    break
                }
            }
        }
    }
    func setUpSubscriptionBadges() {
        androidIconImageview.isHidden = true
        //        badgeView.isHidden = false
        iosBadgeView.isHidden = true
        androidBadgeView.isHidden = true
        webBadgeView.isHidden = true
        /*dayBadgeAndroidImageView.tag = 1
        dayBadgeIosImageView.tag = 2
        dayBadgeWebImageView.tag = 3*/
        preLunchBadge.tag = 4
        foundingMergeBadge.tag = 5
        socialBadgeiconImageView.tag = 6
        androidBadgeView.tag = 7
        iosBadgeView.tag = 8
        webBadgeView.tag = 9
        
        preLunchBadge.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBadgeTap(_:))))
        foundingMergeBadge.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBadgeTap(_:))))
        socialBadgeiconImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBadgeTap(_:))))
        /*dayBadgeIosImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBadgeTap(_:))))
        dayBadgeAndroidImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBadgeTap(_:))))
        dayBadgeWebImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBadgeTap(_:))))*/
        iosBadgeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBadgeTap(_:))))
        androidBadgeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBadgeTap(_:))))
        webBadgeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBadgeTap(_:))))
        
        if let badgearray = Defaults.shared.currentUser?.badges {
            for parentbadge in badgearray {
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
                        androidBadgeView.isHidden = false
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
    @objc func handleBadgeTap(_ sender: UITapGestureRecognizer? = nil) {
        let vc = BadgesPopUpViewController(nibName: R.nib.badgesPopUpViewController.name, bundle: nil)
        vc.selectedBadgeTag = sender?.view?.tag ?? 0
        vc.badgeType = .allBadges
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
    }

    func setAttributedString() {
        if let channelId = Defaults.shared.currentUser?.channelId {
            let myString = "\(Defaults.shared.currentUser?.referralPage ?? "")"
            let channelCount = myString.count
//            let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
            myMutableString = NSMutableAttributedString(string: myString, attributes: [NSAttributedString.Key.foregroundColor : R.color.appPrimaryColor() ?? UIColor.systemBlue])
            lblHyperLink.attributedText = myMutableString
        }
    }
    
    func getVerifiedSocialPlatforms() {
        if let socialPlatforms = Defaults.shared.socialPlatforms, socialPlatforms.count > 0 {
            verifiedView.isHidden = false
            for socialPlatform in socialPlatforms {
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
            self.imgProfileBadge.image = (socialPlatforms.count == 4) ? R.image.shareScreenRibbonProfileBadge() : R.image.shareScreenProfileBadge()
//            self.socialBadgeicon.isHidden = socialPlatforms.count != 4
        } else {
            self.verifiedView.isHidden = true
//            self.socialBadgeicon.isHidden = true
        }
    }
    
    // MARK: - Action Methods
    @IBAction func btnBackClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCheckOutCopyClicked(_ sender: UIButton) {
        if let urlString = self.txtLinkWithCheckOut.text {
            UIPasteboard.general.string = urlString
            showAlert(alertMessage: R.string.localizable.linkIsCopiedToClipboard())
        }
    }
    
    @IBAction func btnLinkCopyClicked(_ sender: UIButton) {
        if let urlString = self.lblReferralLink.text {
            UIPasteboard.general.string = urlString
            showAlert(alertMessage: R.string.localizable.linkIsCopiedToClipboard())
        }
    }
    
    @IBAction func btnShareClicked(_ sender: UIButton) {
        if Defaults.shared.isShowAllPopUpChecked || Defaults.shared.isShareScreenDiscardPopupChecked {
            shareTooltipPopupView.isHidden = false
        } else {
            shareOkButtonClicked(sender)
        }
    }
    
    @IBAction func shareOkButtonClicked(_ sender: UIButton) {
        if let urlString = self.txtLinkWithCheckOut.text {
            let channelId = Defaults.shared.currentUser?.channelId ?? ""
            let urlwithString = urlString + "\n" + "\n" + " \(websiteUrl)/\(channelId)"
            UIPasteboard.general.string = urlwithString
            shareTooltipPopupView.isHidden = true
            var shareItems: [Any] = [urlwithString]
            if isIncludeProfileImg {
                let image = self.profileView.toImage()
                shareItems.append(image)
            }
            if isIncludeQrImg {
                let image = self.imageQrCode.toImage()
                shareItems.append(image)
            }
            print(shareItems)
            let shareVC: UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            self.present(shareVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func downloadButtonClicked(_ sender: UIButton) {
            let image = self.profileView.toImage()
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            Utils.customaizeToastMessage(title: R.string.localizable.profileCardSaved(), toastView: (Utils.appDelegate?.window)!)
    }
    @IBAction func doNotShowAgainClicked(_ sender: UIButton) {
        btnDoNotShowAgain.isSelected = !btnDoNotShowAgain.isSelected
        Defaults.shared.isShowAllPopUpChecked = !btnDoNotShowAgain.isSelected
        Defaults.shared.isShareScreenDiscardPopupChecked = !btnDoNotShowAgain.isSelected
    }
    
    @IBAction func btnFacebookShareClicked(_ sender: UIButton) {
        if isIncludeProfileImg {
            let image = self.profileView.toImage()
            self.fbShareImage(image)
        } else {
            self.shareTextOnFaceBook()
        }
    }
    
    @IBAction func btnTwitterShareClicked(_ sender: UIButton) {
        self.twitterShareCompose()
    }
    
    @IBAction func btnGmailShareClicked(_ sender: UIButton) {
        self.shareTextWithMail(emailType: .gmail)
    }
    
    @IBAction func btnOutlookShareClicked(_ sender: UIButton) {
        self.shareTextWithMail(emailType: .outlook)
    }
    
    @IBAction func btnHyperLinkClicked(_ sender: UIButton) {
        if let urlString = self.lblReferralLink.text {
            guard let url = URL(string: urlString) else {
                return
            }
            presentSafariBrowser(url: url)
        }
    }
    
    @IBAction func btnInclueProfileImgClicked(_ sender: UIButton) {
        self.isIncludeProfileImg = !isIncludeProfileImg
        self.btnIncludeProfileImg.isSelected = isIncludeProfileImg
        Defaults.shared.includeProfileImgForShare = isIncludeProfileImg
        self.instagramView.isHidden = !isIncludeProfileImg
    }
    @IBAction func btnIncludeQRCodeClicked(_ sender: UIButton) {
        self.isIncludeQrImg = !isIncludeQrImg
        self.btnIncludeQrImg.isSelected = isIncludeQrImg
        Defaults.shared.includeQRImgForShare = isIncludeQrImg
        self.imageQrCode.isHidden = !isIncludeQrImg
    }

    @IBAction func btnInstagramClicked(_ sender: UIButton) {
        if isIncludeProfileImg {
            let image = self.profileView.toImage()
            self.shareImageWithInsta(image)
        }
    }
    
}

// MARK: - Social share methods
extension ShareSettingViewController {
    
    func twitterShareCompose(text: String = Constant.Application.displayName) {
        let displayMessage = self.txtLinkWithCheckOut.text
        if let twitterComposeViewController = R.storyboard.twitterCompose.twitterComposeViewController() {
            twitterComposeViewController.presetText = displayMessage
            if isIncludeProfileImg {
                let image = self.profileView.toImage()
                twitterComposeViewController.preselectedImage = image
            }
            let navController = UINavigationController(rootViewController: twitterComposeViewController)
            if let visibleViewController = Utils.appDelegate?.window?.visibleViewController() {
                visibleViewController.present(navController, animated: true, completion: nil)
            }
        }
    }
    
    func fbShareImage(_ image: UIImage) {
        let photo = SharePhoto(image: image, userGenerated: true)
        photo.caption = "\(R.string.localizable.checkOutThisCoolNewAppQuickCam())"
        let content = SharePhotoContent()
        content.photos = [photo]
        SocialShareVideo.shared.showShareDialog(content)
    }
    
    func shareTextOnFaceBook() {
        let shareContent = ShareLinkContent()
        if let channelId = Defaults.shared.currentUser?.channelId {
            let text = "\(websiteUrl)/\(channelId)"
            if let url = URL(string: text) {
                shareContent.contentURL = url
                shareContent.quote = "\(R.string.localizable.checkOutThisCoolNewAppQuickCam())"
                SocialShareVideo.shared.showShareDialog(shareContent)
            }
        }
    }
    
    func shareImageWithInsta(_ image: UIImage) {
        SocialShareVideo.shared.saveImageToCameraRoll(image: image, completion: { (_, phAsset) in
            DispatchQueue.runOnMainThread {
                if let asset = phAsset {
                    SocialShareVideo.shared.instaImageVideoShare(asset)
                }
            }
        })
    }
    
    func shareTextWithMail(emailType: EmailType) {
        // Modify following variables with your text / recipient
        let recipientEmail = ""
        let subject = ""
        let channelId = Defaults.shared.currentUser?.channelId ?? ""
        let body = (self.txtLinkWithCheckOut.text ?? "") + "\n" + "\n" + " \(websiteUrl)/\(channelId)"
        switch emailType {
        case .gmail:
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients([recipientEmail])
                mail.setSubject(subject)
                mail.setMessageBody(body, isHTML: false)
                if isIncludeProfileImg {
                    guard let imageData = self.profileView.toImage().pngData() else {
                        return
                    }
                    mail.addAttachmentData(imageData, mimeType: "image/png", fileName: "quickcam.png")
                }
                present(mail, animated: true)
                // Show third party email composer if default Mail app is not present
            } else if let emailUrl = createEmailUrl(to: recipientEmail, subject: subject, body: body, emailType: .gmail) {
                UIApplication.shared.open(emailUrl)
            }
        case .outlook:
            if let emailUrl = createEmailUrl(to: recipientEmail, subject: subject, body: body, emailType: .outlook) {
                UIApplication.shared.open(emailUrl)
            }
        }
    }
    
}

// MARK: - MFMail Compose View Controller Delegate
extension ShareSettingViewController: MFMailComposeViewControllerDelegate {
    
    private func createEmailUrl(to: String, subject: String, body: String, emailType: EmailType) -> URL? {
        if let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if isIncludeProfileImg {
                guard let imageData = self.profileView.toImage().pngData() else {
                    return URL(string: "")
                }
            }
            switch emailType {
            case .gmail:
                let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
                let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
                let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
                
                if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
                    return gmailUrl
                } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
                    return yahooMail
                } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
                    return sparkUrl
                }
            case .outlook:
                let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
                if let outlookUrl = outlookUrl,
                   UIApplication.shared.canOpenURL(outlookUrl) {
                    return outlookUrl
                }
            }
            let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")
            return defaultUrl
        }
        return URL(string: "")
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}
