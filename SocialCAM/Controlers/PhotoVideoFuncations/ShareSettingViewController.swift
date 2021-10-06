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

enum EmailType {
    case gmail
    case outlook
}

class ShareSettingViewController: UIViewController {
    
    // MARK: - Outlets Declaration
    @IBOutlet weak var lblHyperLink: UILabel!
    @IBOutlet weak var lblLinkWithCheckOut: UILabel!
    @IBOutlet weak var lblReferralLink: UILabel!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var imgProfileBadge: UIImageView!
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var verifiedStackView: UIStackView!
    @IBOutlet weak var facebookVerifiedView: UIView!
    @IBOutlet weak var twitterVerifiedView: UIView!
    @IBOutlet weak var snapchatVerifiedView: UIView!
    @IBOutlet weak var youtubeVerifiedView: UIView!
    @IBOutlet weak var btnIncludeProfileImg: UIButton!
    @IBOutlet weak var instagramView: UIView!
    @IBOutlet weak var lblSinceDate: UILabel!
    @IBOutlet var countryView: [UIView]!
    @IBOutlet var lblCountrys: [UILabel]!
    @IBOutlet var imgCountrys: [UIImageView]!
    @IBOutlet weak var flagStackviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var shareTooltipPopupView: UIView!
    @IBOutlet weak var btnDoNotShowAgain: UIButton!
    @IBOutlet weak var socialPlatformsVerifiedBadgeView: UIView!
    @IBOutlet weak var socialBadgeStackView: UIStackView!
    
    // MARK: - Variable Declarations
    var myMutableString = NSMutableAttributedString()
    var isIncludeProfileImg = Defaults.shared.includeProfileImgForShare
    
    // MARK: - View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Setup Methods
    func setup() {
        if let channelId = Defaults.shared.currentUser?.channelId {
            self.setAttributedString()
            self.lblLinkWithCheckOut.text = "\(R.string.localizable.checkOutThisCoolNewAppQuickCam()) \(websiteUrl)/\(channelId)"
            self.lblReferralLink.text = "\(websiteUrl)/\(channelId)"
            self.lblUserName.text = "@\(channelId)"
        }
        if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
            self.imgProfilePic.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: R.image.user_placeholder())
            self.imgProfilePic.layer.cornerRadius = imgProfilePic.bounds.width / 2
            self.imgProfilePic.contentMode = .scaleAspectFill
        }
        self.btnIncludeProfileImg.isSelected = Defaults.shared.includeProfileImgForShare == true
        self.getVerifiedSocialPlatforms()
        self.instagramView.isHidden = Defaults.shared.includeProfileImgForShare != true
        if let createdDate = Defaults.shared.currentUser?.created {
            let date = CommonFunctions.getDateInSpecificFormat(dateInput: createdDate, dateOutput: R.string.localizable.mmmdYyyy())
            self.lblSinceDate.text = R.string.localizable.sinceJoined(date)
        }
        DispatchQueue.main.async {
            if let flages = Defaults.shared.currentUser?.userStateFlags, flages.count > 0 {
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
    }
    
    func presentSafariBrowser(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
    
    func setAttributedString() {
        if let channelId = Defaults.shared.currentUser?.channelId {
            let channelCount = "\(websiteUrl)/\(channelId)".count
            let myString = "\(websiteUrl)/\(channelId)"
            let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
            myMutableString = NSMutableAttributedString(string: myString, attributes: underlineAttribute)
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: R.color.appPrimaryColor() ?? UIColor.systemBlue, range: NSRange(location: 0, length: channelCount))
            lblHyperLink.attributedText = myMutableString
        }
    }
    
    func getVerifiedSocialPlatforms() {
        if let socialPlatforms = Defaults.shared.socialPlatforms, socialPlatforms.count > 0 {
            verifiedStackView.isHidden = false
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
            self.socialBadgeStackView.isHidden = socialPlatforms.count != 4
            self.socialPlatformsVerifiedBadgeView.isHidden = socialPlatforms.count != 4
        } else {
            self.verifiedStackView.isHidden = true
            self.socialBadgeStackView.isHidden = true
            self.socialPlatformsVerifiedBadgeView.isHidden = true
        }
    }
    
    // MARK: - Action Methods
    @IBAction func btnBackClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCheckOutCopyClicked(_ sender: UIButton) {
        if let urlString = self.lblLinkWithCheckOut.text {
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
        if Defaults.shared.isShowAllPopUpChecked {
            shareTooltipPopupView.isHidden = false
        } else {
            shareOkButtonClicked(sender)
        }
    }
    
    @IBAction func shareOkButtonClicked(_ sender: UIButton) {
        if let urlString = self.lblLinkWithCheckOut.text {
            UIPasteboard.general.string = urlString
            shareTooltipPopupView.isHidden = true
            var shareItems: [Any] = [urlString]
            if isIncludeProfileImg {
                let image = self.profileView.toImage()
                shareItems.append(image)
            }
            let shareVC: UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            self.present(shareVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func doNotShowAgainClicked(_ sender: UIButton) {
        btnDoNotShowAgain.isSelected = !btnDoNotShowAgain.isSelected
        Defaults.shared.isShowAllPopUpChecked = btnDoNotShowAgain.isSelected
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
        let displayMessage = self.lblLinkWithCheckOut.text
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
        let body = self.lblLinkWithCheckOut.text ?? ""
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
