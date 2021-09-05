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

class ShareSettingViewController: UIViewController {
    
    // MARK: - Outlets Declaration
    @IBOutlet weak var lblHyperLink: UILabel!
    @IBOutlet weak var lblLinkWithCheckOut: UILabel!
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
            self.lblHyperLink.text = "\(websiteUrl)/ref/\(channelId)"
            self.lblLinkWithCheckOut.text = "\(R.string.localizable.checkOutThisCoolNewAppQuickCam()) \(websiteUrl)/ref/\(channelId)"
            self.lblReferralLink.text = "\(websiteUrl)/ref/\(channelId)"
        }
    }
    
    func presentSafariBrowser(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
    
    func setAttributedString() {
        if let channelId = Defaults.shared.currentUser?.channelId {
            let channelCount = "\(websiteUrl)/ref/\(channelId)".count
            let myString = "\(R.string.localizable.yourReferralLink()): \(websiteUrl)/ref/\(channelId)"
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
    
    @IBAction func btnFacebookShareClicked(_ sender: UIButton) {
        self.shareTextOnFaceBook()
    }
    
    @IBAction func btnTwitterShareClicked(_ sender: UIButton) {
        self.twitterShareCompose()
    }
    
    @IBAction func btnGmailShareClicked(_ sender: UIButton) {
        self.shareTextOnGmail()
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
        let displayMessage = self.lblLinkWithCheckOut.text
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
            let text = "\(websiteUrl)/ref/\(channelId)"
            if let url = URL(string: text) {
                shareContent.contentURL = url
                shareContent.quote = "\(R.string.localizable.checkOutThisCoolNewAppQuickCam())"
                SocialShareVideo.shared.showShareDialog(shareContent)
            }
        }
    }
    
    func shareTextOnGmail() {
        // Modify following variables with your text / recipient
        let recipientEmail = ""
        let subject = ""
        let body = self.lblLinkWithCheckOut.text ?? ""
        // Show default mail composer
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([recipientEmail])
            mail.setSubject(subject)
            mail.setMessageBody(body, isHTML: false)
            present(mail, animated: true)
            // Show third party email composer if default Mail app is not present
        } else if let emailUrl = createEmailUrl(to: recipientEmail, subject: subject, body: body) {
            UIApplication.shared.open(emailUrl)
        }
    }
    
}

// MARK: - MFMail Compose View Controller Delegate
extension ShareSettingViewController: MFMailComposeViewControllerDelegate {
    
    private func createEmailUrl(to: String, subject: String, body: String) -> URL? {
        if let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
            let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)")
            let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
            let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
            let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")
            
            if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
                return gmailUrl
            } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
                return outlookUrl
            } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
                return yahooMail
            } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
                return sparkUrl
            }
            return defaultUrl
        }
        return URL(string: "")
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}
