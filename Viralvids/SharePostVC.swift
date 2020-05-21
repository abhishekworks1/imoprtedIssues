//
//  SharePostVC.swift
//  SocialCamMediaShare
//
//  Created by Viraj Patel on 21/04/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import Social
import MobileCoreServices
import SDWebImage
import AVKit
import UIKit
import AVFoundation
import RxSwift
import Moya
import URLEmbeddedView
import SSSpinnerButton

class SharePostVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var imgPost: UIImageView!
 
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imgSocialIcon: UIImageView!
    
    @IBOutlet weak var hashTagView: RKTagsView!
    
    @IBOutlet weak var txtHashtags: UITextField!
   
    @IBOutlet weak var txtDesc: UITextView!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var btnSendPost: SSSpinnerButton!
    
    @IBOutlet weak var btnClose: UIButton!
    
    // MARK: - Variables
    private var urlString: String?
    private var textString: String?
    var host: String?
    fileprivate var disposeBag = DisposeBag()
    var linkData: OpenGraph.Data?
    var socialPlatform: String = R.string.localizable.facebook().lowercased()
    
    var mainScrollView: UIScrollView?
    
    // MARK: - View Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        txtDesc.layer.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0).cgColor
        txtDesc.layer.borderWidth = 1.0
        txtDesc.layer.cornerRadius = 5
        txtDesc.delegate = self
        
        self.hashTagView.isMerge = true
        self.hashTagView.textField.placeholder = "#Hashtags"
        self.hashTagView.textField.returnKeyType = .done
        self.hashTagView.textField.delegate = self
        self.hashTagView.interitemSpacing =  4.0
        self.hashTagView.lineSpacing = 4.0
        self.hashTagView.isHasTag = true
        self.hashTagView.font = UIFont.systemFont(ofSize: 13)
        self.hashTagView.layoutIfNeeded()
       
        self.mainScrollView = self.scrollView
        self.mainScrollView?.isScrollEnabled = true
        self.registerKeyboardNotifications()
    }
    
    deinit {
       self.unregisterKeyboardNotifications()
    }
    
    func fetchData() {
        if Defaults.shared.currentUser != nil {
            if let item = extensionContext?.inputItems.first as? NSExtensionItem,
                let itemProvider = item.attachments?.first {
                if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
                    itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { (url, _) in
                        if let shareURL = url as? URL {
                            self.host = shareURL.host
                            self.urlString = String(describing: shareURL)
                            DispatchQueue.main.async {
                                self.setData()
                                print(shareURL)
                            }
                            
                        }
                    }
                } else if itemProvider.hasItemConformingToTypeIdentifier("public.plain-text") {
                    itemProvider.loadItem(forTypeIdentifier: "public.plain-text", options: nil) { (urlString, error) in
                        if let shareURLString = urlString as? String,
                            let shareURL = URL(string: shareURLString) {
                            self.host = shareURL.host
                            self.urlString = String(describing: shareURL)
                            DispatchQueue.main.async {
                                self.setData()
                                print(shareURL)
                            }
                            
                        }
                    }
                }
            }
        } else {
            displayUIAlertController(title: R.string.localizable.loginError(), message: R.string.localizable.pleaseLoginFirstOnApp(), viewController: self)
        }
    }
    
    func setData() {
        OGDataProvider.shared.fetchOGData(urlString: self.urlString!) { (data: OpenGraph.Data, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.linkData = data
                DispatchQueue.main.async {
                    var json: [String: Any] = ["bookmarkUrl": self.urlString ?? ""]
                    if data.siteName?.lowercased() == R.string.localizable.tikTok().lowercased() {
                        self.imgSocialIcon.image = R.image.shareTikTok()
                        self.socialPlatform = R.string.localizable.tikTok().lowercased()
                    } else if data.siteName?.lowercased() == R.string.localizable.youtube().lowercased() {
                        self.imgSocialIcon.image = R.image.shareYoutube()
                        self.socialPlatform = R.string.localizable.google().lowercased()
                    } else if data.siteName?.lowercased() == R.string.localizable.twitter().lowercased() {
                        self.socialPlatform = R.string.localizable.twitter().lowercased()
                        self.imgSocialIcon.isHidden = true
                    } else if data.siteName?.lowercased() == R.string.localizable.instagram().lowercased() {
                        self.socialPlatform = R.string.localizable.instagram().lowercased()
                        self.imgSocialIcon.isHidden = true
                    } else if data.siteName?.lowercased() == R.string.localizable.snapchat().lowercased() {
                        self.socialPlatform = R.string.localizable.snapchat().lowercased()
                        self.imgSocialIcon.isHidden = true
                    } else {
                        self.socialPlatform = R.string.localizable.other().lowercased()
                        self.imgSocialIcon.isHidden = true
                    }
                    
                    if let title = data.pageTitle {
                        json["title"] = title
                        self.lblTitle.text = title
                    } else {
                        if let host = self.host {
                            json["title"] = host
                        }
                    }
                    if let imgUrl = data.imageUrl?.absoluteString {
                        json["thumb"] = imgUrl
                        self.imgPost.sd_setImage(with: URL.init(string: imgUrl), placeholderImage: nil)
                    }
                    
                    // ToDo - Temp Disable
//                    if let desc = data.pageDescription {
//                        json["description"] = desc
//                        self.txtDesc.text = desc
//                    }
        
                    if let siteName = data.siteName {
                        json["shortLink"] = siteName
                    } else {
                        if let host = self.host {
                            json["shortLink"] = host
                        }
                    }
                }
            }
        }
    }
    
    // MARK:- IBAction events
    @IBAction func closeBtnTapped(_ sender: Any) {
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    @IBAction func sendStoryTapped(_ sender: Any) {
        btnSendPost.startAnimate(spinnerType: SpinnerType.ballClipRotate, spinnercolor: UIColor.white, spinnerSize: 20, complete: {
            
        })
        ProManagerApi.createViralvids(title: self.linkData?.pageTitle ?? "", image: self.linkData?.imageUrl?.absoluteString, description: self.txtDesc.text, referenceLink: self.linkData?.url?.absoluteString, hashtags: hashTagView.tags, socialPlatform: socialPlatform).request(Result<CreatePostViralCam>.self).subscribe(onNext: { (response) in
            
            Defaults.shared.postViralCamModel = response.result
            
            let alert = UIAlertController.Style
                .alert
                .controller(title: "",
                            message: "Open ViralCam",
                            actions: [UIAlertAction(title: "OK", style: .default, handler: { _ in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                    _ = self.openURL(URL(string: "viralCam://com.simform.viralcam")!)
                                    self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                                })
                            }), UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
                                let errMsg = NSError(domain: "domain", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Localised details here"])
                                self.extensionContext!.cancelRequest(withError: errMsg)
                            })])
            self.present(alert, animated: true, completion: nil)
            
        }, onError: { _ in
            self.displayUIAlertController(title: "", message: "Error", viewController: self)
        }, onCompleted: {
            
        }).disposed(by: disposeBag)
                        
    }
    
    @objc func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }
    
    func displayUIAlertController(title: String, message: String, viewController: UIViewController) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
            let errMsg = NSError(domain: "domain", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Localised details here"])
            viewController.extensionContext!.cancelRequest(withError: errMsg)
        }))
        
        viewController.present(alert, animated: true, completion: nil)
    }
}

extension UITextView {
    
    func makeOutLine(oulineColor: UIColor, foregroundColor: UIColor) {
        let strokeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: oulineColor,
            NSAttributedString.Key.foregroundColor: foregroundColor,
            NSAttributedString.Key.strokeWidth: -4.0,
            NSAttributedString.Key.font: self.font as Any
            ]
        self.attributedText = NSMutableAttributedString(string: self.text ?? "", attributes: strokeTextAttributes as [NSAttributedString.Key: Any])
    }
    
    func attributedStringSet(underline: Bool = false) {
        if let textString = self.text {
            let style = NSMutableParagraphStyle()
            style.alignment = NSTextAlignment.center
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: self.textColor!, range: NSRange(location: 0, length: attributedString.length))
            attributedString.addAttribute(NSAttributedString.Key.font, value: self.font!, range: NSRange(location: 0, length: attributedString.length))
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: attributedString.length))
            if underline {
                attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
            }
            attributedText = attributedString
        }
    }
    
}

extension SharePostVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SharePostVC: ScrollViewKeyboardDelegate {
    
}

extension SharePostVC: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

protocol ScrollViewKeyboardDelegate: class {
    var mainScrollView: UIScrollView? { get set }

    func registerKeyboardNotifications()
    func unregisterKeyboardNotifications()
}

extension ScrollViewKeyboardDelegate where Self: UIViewController {
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: nil) { [weak self] notification in
                self?.keyboardWillBeShown(notification)
        }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: nil) { [weak self] notification in
                self?.keyboardWillBeHidden(notification)
        }
    }

    func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    func keyboardWillBeShown(_ notification: Notification) {
        let info = notification.userInfo
        let key = (info?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)
        let aKeyboardSize = key?.cgRectValue

        guard let keyboardSize = aKeyboardSize,
            let scrollView = self.mainScrollView else {
                return
        }

        let bottomInset = keyboardSize.height
        scrollView.contentInset.bottom = bottomInset
        scrollView.scrollIndicatorInsets.bottom = bottomInset
        if let activeField = self.view.firstResponder {
            let yPosition = activeField.frame.origin.y + 100
            if yPosition > 0 {
                let scrollPoint = CGPoint(x: 0, y: yPosition)
                scrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
    }

    func keyboardWillBeHidden(_ notification: Notification) {
        self.mainScrollView?.contentInset = .zero
        self.mainScrollView?.scrollIndicatorInsets = .zero
    }
}

extension UIView {
    var firstResponder: UIView? {
        guard !isFirstResponder else { return self }
        return subviews.first(where: {$0.firstResponder != nil })
    }
}
