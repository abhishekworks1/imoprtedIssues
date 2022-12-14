//
//  FllowMeStoryView.swift
//  ViralCam
//
//  Created by Jasmin Patel on 04/03/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

class FollowMeStoryView: UIView {
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var userBitEmoji: UIImageView!
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.delegate = self
            textView.textContainer.maximumNumberOfLines = 2
        }
    }
    
    var imagePicker = UIImagePickerController()
    public let releaseType = Defaults.shared.releaseType

    var didChangeEditing: ((Bool) -> ())?

    class func instanceFromNib() -> UIView {
        return R.nib.followMeStoryView(owner: nil) ?? UIView()
    }
    
    public var pannable: Bool = false {
        didSet {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
            self.addGestureRecognizer(panGesture)
        }
    }
    
    public var hideDeleteButton: Bool = false {
        didSet {
            deleteButton.isHidden = hideDeleteButton
        }
    }
    
    @IBAction func onDelete(_ sender: UIButton) {
        removeFromSuperview()
    }
    
    @IBAction func onBitEmojiChange(_ sender: UIButton) {
        let vc = ReferalActionSheetViewController(nibName: R.nib.referalActionSheetViewController.name, bundle: nil)
//        vc.view.backgroundColor = .clear
//        vc.modalPresentationStyle = .fullScreen
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        vc.delegate = self
        guard let superView = self.superview else {
            return
        }
//        superView.backgroundColor = .clear
//        superView.parentViewController?.view.backgroundColor = .clear
        superView.parentViewController?.present(vc, animated: true, completion: nil)
//        openActionSheet()
    }
    
    func openGallery(fromSourceType sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            imagePicker.allowsEditing = true
            
            guard let superView = self.superview else {
                return
            }
            superView.parentViewController?.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openActionSheet() {
        let actionSheet = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        let bitmojiAction = UIAlertAction(title: "Bitmoji", style: .default) { [unowned self] _ in
            self.bitEmojiChange()
        }
        actionSheet.addAction(bitmojiAction)
        let galleryAction = UIAlertAction(title: R.string.localizable.gallery(), style: .default) { [unowned self] _ in
            self.openGallery(fromSourceType: .photoLibrary)
        }
        actionSheet.addAction(galleryAction)
        let cameraAction = UIAlertAction(title: R.string.localizable.camera(), style: .default) { [unowned self] _ in
            self.openGallery(fromSourceType: .camera)
        }
        actionSheet.addAction(cameraAction)
        let yourProfilePictureAction = UIAlertAction(title: "Your Profile Pic", style: .default) { [unowned self] _ in
            self.setFromUserProfilePic()
        }
        actionSheet.addAction(yourProfilePictureAction)
        let appLogo = UIAlertAction(title: R.string.localizable.appLogo(), style: .default) { [unowned self] _ in
            self.userBitEmoji.image = (releaseType == .store) ? R.image.ssuQuickCam() : R.image.ssuQuickCamLite()
        }
        actionSheet.addAction(appLogo)
        let cancel = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel) { [unowned self] _ in
            guard let superView = self.superview else {
                return
            }
            superView.parentViewController?.dismiss(animated: true, completion: nil)
        }
        actionSheet.addAction(cancel)
        guard let superView = self.superview else {
            return
        }
        
        superView.parentViewController?.present(actionSheet, animated: true, completion: nil)
    }

    func bitEmojiChange() {
        guard let bitmojiStickerPickerViewController = R.storyboard.storyEditor.bitmojiStickerPickerViewController() else {
            return
        }
        bitmojiStickerPickerViewController.completionBlock = { [weak self] (string, image) in
            guard let `self` = self else { return }
            guard let stickerImage = image else {
                return
            }
            self.userBitEmoji.image = stickerImage
        }
        guard let superView = self.superview else {
            return
        }
        superView.parentViewController?.present(bitmojiStickerPickerViewController, animated: true, completion: nil)
    }
    
    func setFromUserProfilePic() {
        if let userImageUrl = Defaults.shared.currentUser?.profileImageURL {
            userBitEmoji.sd_setImage(with: URL.init(string: userImageUrl), placeholderImage: ApplicationSettings.userPlaceHolder)
        }
    }
}

extension FollowMeStoryView: ReferalActionSheetViewDelegate {
    func referralImageSelectedType(selectedType: ReferralImageType) {
        switch selectedType {
        case .camera:
            self.openGallery(fromSourceType: .camera)
        case .bitmoji:
            self.bitEmojiChange()
        case .gallery:
            self.openGallery(fromSourceType: .photoLibrary)
        case .profilePic:
            self.setFromUserProfilePic()
        case .appLogo:
            self.userBitEmoji.image = (releaseType == .store) ? R.image.ssuQuickCam() : R.image.ssuQuickCamLite()
        }
    }
}

extension FollowMeStoryView {
    
    @objc func onPan(_ gesture: UIPanGestureRecognizer) {
        guard let superView = self.superview else {
            return
        }
        center = CGPoint(x: center.x + gesture.translation(in: superView).x,
                         y: center.y + gesture.translation(in: superView).y)
        gesture.setTranslation(.zero, in: self)
    }
    
}

extension FollowMeStoryView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        didChangeEditing?(true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        didChangeEditing?(false)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let char = text.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        if !(isBackSpace == -92),
            textView.textContainer.maximumNumberOfLines == textView.layoutManager.numberOfLines {
            if text == "\n" {
                return false
            }
            return !textView.isLastPoint
        }
        return true
    }
    
}

extension FollowMeStoryView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        self.userBitEmoji.image = image
        guard let superView = self.superview else {
            return
        }
        superView.parentViewController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        guard let superView = self.superview else {
            return
        }
        superView.parentViewController?.dismiss(animated: true, completion: nil)
    }

}
