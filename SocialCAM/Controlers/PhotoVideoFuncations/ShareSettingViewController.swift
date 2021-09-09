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
    @IBOutlet weak var txtViewLinkWithCheckOut: UITextView!
    @IBOutlet weak var lblReferralLink: UILabel!
    
    // MARK: - Variable Declarations
    var myMutableString = NSMutableAttributedString()
    
    // MARK: - View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Setup Methods
    func setup() {
        if let channelId = Defaults.shared.currentUser?.channelId {
            self.lblHyperLink.text = "\(websiteUrl)/\(channelId)"
            self.txtViewLinkWithCheckOut.text = "\(R.string.localizable.checkOutThisCoolNewAppQuickCam()) \(websiteUrl)/\(channelId)"
            self.lblReferralLink.text = "\(websiteUrl)/\(channelId)"
        }
    }
    
    func presentSafariBrowser(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
    
    func setAttributedString() {
        if let channelId = Defaults.shared.currentUser?.channelId {
            let channelCount = "\(websiteUrl)/\(channelId)".count
            let myString = "\(R.string.localizable.yourReferralLink()): \(websiteUrl)/\(channelId)"
            myMutableString = NSMutableAttributedString(string: myString)
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: R.color.appPrimaryColor() ?? UIColor.systemBlue, range: NSRange(location: 20, length: channelCount))
            lblHyperLink.attributedText = myMutableString
        }
    }
    
    // MARK: - Action Methods
    @IBAction func btnBackClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCheckOutCopyClicked(_ sender: UIButton) {
        if let urlString = self.txtViewLinkWithCheckOut.text {
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
    
    @IBAction func btnFacebookShareClicked(_ sender: UIButton) {
        self.shareTextOnFaceBook()
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
    
}

// MARK: - Social share methods
extension ShareSettingViewController {
    
    func twitterShareCompose(text: String = Constant.Application.displayName) {
        let displayMessage = self.txtViewLinkWithCheckOut.text
        if let twitterComposeViewController = R.storyboard.twitterCompose.twitterComposeViewController() {
            twitterComposeViewController.presetText = displayMessage
            let navController = UINavigationController(rootViewController: twitterComposeViewController)
            if let visibleViewController = Utils.appDelegate?.window?.visibleViewController() {
                visibleViewController.present(navController, animated: true, completion: nil)
            }
        }
    }
    
    func shareTextOnFaceBook() {
        let shareContent = ShareLinkContent()
        if let channelId = Defaults.shared.currentUser?.channelId {
            let text = "\(websiteUrl)/\(channelId)"
            if let url = URL(string: text) {
                shareContent.contentURL = url
                shareContent.quote = "\(self.txtViewLinkWithCheckOut.text ?? R.string.localizable.checkOutThisCoolNewAppQuickCam())"
                SocialShareVideo.shared.showShareDialog(shareContent)
            }
        }
    }
    
    func shareTextWithMail(emailType: EmailType) {
        // Modify following variables with your text / recipient
        let recipientEmail = ""
        let subject = ""
        let body = self.txtViewLinkWithCheckOut.text ?? ""
        switch emailType {
        case .gmail:
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients([recipientEmail])
                mail.setSubject(subject)
                mail.setMessageBody(body, isHTML: false)
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
