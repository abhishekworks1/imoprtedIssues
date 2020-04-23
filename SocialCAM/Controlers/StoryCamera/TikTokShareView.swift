//
//  TikTokShareView.swift
//  SocialCAM
//
//  Created by Jasmin Patel on 23/04/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

class TikTokShareView: UIView {
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var userBitEmoji: UIImageView!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hashtagsLabel: UILabel!
    @IBOutlet weak var swipeUpView: UIView!
    @IBOutlet weak var swipeUpHeight: NSLayoutConstraint!
    @IBOutlet weak var bitMojiView: UIView!
    @IBOutlet weak var bitMojiViewTop: NSLayoutConstraint!

    class func instanceFromNib() -> TikTokShareView? {
        return R.nib.tikTokShareView(owner: nil)
    }
    
    public var pannable: Bool = false {
        didSet {
            if pannable {
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
                self.addGestureRecognizer(panGesture)
            }
        }
    }
    
    func hideSwipeUpView(hide: Bool) {
        self.bitMojiViewTop.constant = hide ? 0 : -80
        self.swipeUpHeight.constant = hide ? 0 : 41
        self.bitMojiView.isHidden = hide
    }
    
    func configureView() {
        guard let data = Defaults.shared.postViralCamModel else {
            return
        }
        self.titleLabel.text = data.title
        self.hashtagsLabel.text = data.hashtagString
        userBitEmoji.setImageFromURL(Defaults.shared.snapchatProfileURL,
                                     placeholderImage: R.image.userBitmoji())
        self.thumbImageView.setImageFromURL(data.image, placeholderImage: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
        hideSwipeUpView(hide: true)
    }
    
    public var hideDeleteButton: Bool = false {
        didSet {
            deleteButton.isHidden = hideDeleteButton
        }
    }
    
    @IBAction func onDelete(_ sender: UIButton) {
        Defaults.shared.postViralCamModel = nil
        removeFromSuperview()
    }
    
    @IBAction func onBitEmojiChange(_ sender: UIButton) {
        bitEmojiChange()
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

extension TikTokShareView {
    
    @objc func onPan(_ gesture: UIPanGestureRecognizer) {
        guard let superView = self.superview else {
            return
        }
        center = CGPoint(x: center.x + gesture.translation(in: superView).x,
                         y: center.y + gesture.translation(in: superView).y)
        gesture.setTranslation(.zero, in: self)
    }
    
}
