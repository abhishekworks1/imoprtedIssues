//
//  SwipeUpStoryView.swift
//  SocialCAM
//
//  Created by Jasmin Patel on 07/05/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

class SwipeUpStoryView: UIView {
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var userBitEmoji: UIImageView!
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.delegate = self
            textView.textContainer.maximumNumberOfLines = 2
        }
    }
    
    var imagePicker = UIImagePickerController()

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
        openActionSheet()
    }
    
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            
            guard let superView = self.superview else {
                return
            }
            superView.parentViewController?.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openActionSheet() {
        let actionSheet = UIAlertController(title: R.string.localizable.chooseImage(), message: nil, preferredStyle: .actionSheet)
        let bitmojiAction = UIAlertAction(title: R.string.localizable.bitmoji(), style: .default) { [unowned self] _ in
            self.bitEmojiChange()
        }
        actionSheet.addAction(bitmojiAction)
        let galleryAction = UIAlertAction(title: R.string.localizable.gallery(), style: .default) { [unowned self] _ in
            self.openGallery()
        }
        actionSheet.addAction(galleryAction)
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
}

extension SwipeUpStoryView {
    
    @objc func onPan(_ gesture: UIPanGestureRecognizer) {
        guard let superView = self.superview else {
            return
        }
        center = CGPoint(x: center.x + gesture.translation(in: superView).x,
                         y: center.y + gesture.translation(in: superView).y)
        gesture.setTranslation(.zero, in: self)
    }
    
}

extension SwipeUpStoryView: UITextViewDelegate {
    
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

extension SwipeUpStoryView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return
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

