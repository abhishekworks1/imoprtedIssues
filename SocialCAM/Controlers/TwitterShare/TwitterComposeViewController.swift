//
//  TwitterComposeViewController.swift
//  SocialCAM
//
//  Created by Viraj Patel on 03/01/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation

class TwitterComposeViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var inputTextView: UITextView?
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint?
    @IBOutlet weak var attachImageView: UIImageView?
    @IBOutlet weak var attachButtonConstraint: NSLayoutConstraint?
    @IBOutlet weak var counterLabel: UILabel?
    let PLACEHOLDER = R.string.localizable.whatWouldYouLikeToShare()
    let textLimit = 280
    var postCounter = 0
    var preselectedImage: UIImage?
    var preselectedVideoUrl: URL?
    var presetText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = R.string.localizable.newPost()
        let leftBarButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(self.closeAction))
        leftBarButton.title = R.string.localizable.cancel()
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        let rightBarButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(self.sendAction))
        rightBarButton.title = R.string.localizable.tweet()
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        self.inputTextView?.text = PLACEHOLDER
        self.inputTextView?.textColor = UIColor.lightGray
        self.inputTextView?.selectedTextRange = self.inputTextView?.textRange(from: self.inputTextView!.beginningOfDocument, to: self.inputTextView!.beginningOfDocument)
        
        counterLabel?.text = "0/\(textLimit)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShowNotification(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHideNotification(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        inputTextView?.becomeFirstResponder()
        
        var thumbimage = UIImage()
        if let image = self.preselectedImage {
            thumbimage = image
        } else if let videoURL = self.preselectedVideoUrl {
            thumbimage = UIImage.getThumbnailFrom(videoUrl: videoURL) ?? UIImage()
        }
        attachImageView?.image = thumbimage
        self.attachButtonConstraint?.constant = 0
        self.view.layoutIfNeeded()
        
        if self.presetText != nil {
            self.inputTextView?.text = self.presetText
            self.inputTextView?.textColor = UIColor.black
            counterLabel?.text = "\(self.presetText!.count)/\(textLimit)"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        print("Deinit \(self.description)")
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func sendAction() {
        if inputTextView!.text.count == 0 {
            self.showAlert(alertMessage: R.string.localizable.pleaseWriteSomeTextToBeShared())
        } else {
            if let image = self.preselectedImage, let text = inputTextView?.text {
                twitterVideoShare(image: image, text: text)
            } else if let url = self.preselectedVideoUrl, let text = inputTextView?.text {
                twitterVideoShare(url, text: text)
            } else if let text = inputTextView?.text {
                twitterVideoShare(text: text)
            }
        }
    }
    
    func showSuccessAlert() {
        let alertController = UIAlertController(title: R.string.localizable.success(), message: R.string.localizable.tweetWasPosted(), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: R.string.localizable.continue(), style: .default, handler: { [weak self] (_ ) -> Void in
            guard let `self` = self else {
                return
            }
            self.clear()
            self.closeAction()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showFailureAlert() {
        self.showAlert(alertMessage: R.string.localizable.tweetWasNotPosted())
    }
    
    func clear() {
        attachImageView?.image = nil
        inputTextView?.text = ""
        self.attachButtonConstraint?.constant = 90
        self.view.layoutIfNeeded()
    }
    
    @objc func closeAction() {
        dismiss(animated: true) { () -> Void in}
    }
    
    // MARK: - Notifications
    @objc func keyboardWillShowNotification(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification: notification)
    }
    
    @objc func keyboardWillHideNotification(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification: notification)
    }
    
    // MARK: - Private
    func updateBottomLayoutConstraintWithNotification(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        let animationDuration = ((userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue) ?? 0.0
        let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        bottomConstraint!.constant = view.bounds.maxY - convertedKeyboardEndFrame.minY
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func twitterVideoShare(_ url: URL? = nil, image: UIImage? = nil, text: String = Constant.Application.displayName) {
        if TwitterManger.shared.isUserLogin {
            shareTwitteWithHandler(url, image: image, text: text)
        } else {
            TwitterManger.shared.login { [weak self] (isLogin, _) in
                guard let `self` = self else {
                    return
                }
                if isLogin {
                    self.shareTwitteWithHandler(url, image: image, text: text)
                } else {
                    Utils.appDelegate?.window?.makeToast(R.string.localizable.pleaseFirstLoginOnTwitter())
                }
            }
        }
    }
    
    func shareTwitteWithHandler(_ url: URL? = nil, image: UIImage? = nil, text: String = Constant.Application.displayName) {
        let loadingView = LoadingView.instanceFromNib()
        loadingView.loadingViewShow = true
        loadingView.shouldCancelShow = true
        loadingView.show(on: self.view)
        if let image = image {
            TwitterManger.shared.uploadImageOnTwitter(withText: text, image: image) { [weak self] (isSuccess, _) in
                guard let `self` = self else {
                    return
                }
                loadingView.hide()
                if isSuccess {
                    self.showSuccessAlert()
                } else {
                    self.showFailureAlert()
                }
            }
        } else if let videoUrl = url {
            TwitterManger.shared.uploadVideoOnTwitter(withText: text, videoUrl: videoUrl) { [weak self] (isSuccess, _) in
                guard let `self` = self else {
                    return
                }
                if isSuccess {
                    self.showSuccessAlert()
                } else {
                    self.showFailureAlert()
                }
            }
        } else {
            TwitterManger.shared.uploadTextOnTwitter(withText: text) { [weak self] (isSuccess, _) in
                guard let `self` = self else {
                    return
                }
                if isSuccess {
                    self.showSuccessAlert()
                } else {
                    self.showFailureAlert()
                }
            }
        }
    }
}

extension TwitterComposeViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText: NSString = textView.text! as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: text)
        
        if updatedText.length>textLimit {
            //textView.text = updatedText.substring(to: updatedText.startIndex.advancedBy(textLimit))
            
            counterLabel?.text = "\(textView.text.count)/\(textLimit)"
            return false
        }
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty || updatedText == PLACEHOLDER {
            textView.text = PLACEHOLDER
            textView.textColor = UIColor.lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            counterLabel?.text = "0/\(textLimit)"
            return false
        } else if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
            counterLabel?.text = "\(text.count)/\(textLimit)"
        } else {
            counterLabel?.text = "\(updatedText.count)/\(textLimit)"
        }
        
        return true
    }
}
