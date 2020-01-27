//
//  BitmojiStickerPickerViewController.swift
//  SocialCAM
//
//  Created by Viraj Patel on 09/01/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit

private let externalIdQuery = "{me{displayName, bitmoji{avatar}, externalId}}"
typealias CompletionImagePickClosure = (String, UIImage?) -> Void

class BitmojiStickerPickerViewController: UIViewController {
    
    @IBOutlet weak var stickerView: UIView!
    var completionBlock: CompletionImagePickClosure?
    var arrImage: [UIImage] = []
    let stickerVC = SnapKitManager.shared.stickerVC
    
    var bottomConstraint: NSLayoutConstraint!
    
    var stickerPickerTopConstraint: NSLayoutConstraint!
    var stickerViewHeight: CGFloat {
        if !bitmojiSearchHasFocus {
            return 250
        }
        var availableHeight = view.frame.height
        if #available(iOS 11.0, *) {
            availableHeight -= view.safeAreaInsets.top
        } else {
            availableHeight -= topLayoutGuide.length
        }

        return availableHeight * 0.9
    }
    
    var isStickerViewVisible = false {
        didSet {
            guard isStickerViewVisible != oldValue else {
                return
            }
            stickerVC.view.isHidden = !isStickerViewVisible
            stickerPickerTopConstraint.constant = isStickerViewVisible ? -stickerViewHeight : 0
        }
    }
    
    var bitmojiSearchHasFocus = false {
        didSet {
            guard bitmojiSearchHasFocus != oldValue else {
                return
            }
            updateAndAnimateLayoutContstraints(duration: 0.3, options: [.beginFromCurrentState])
        }
    }
    
    deinit {
        print("Deinit \(self.description)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        stickerVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(stickerVC)
        stickerView.addSubview(stickerVC.view)
        stickerVC.didMove(toParent: self)
       
        bottomConstraint = stickerVC.view.bottomAnchor.constraint(equalTo: stickerView.bottomAnchor)
        stickerPickerTopConstraint = stickerVC.view.topAnchor.constraint(equalTo: stickerView.topAnchor)
        NSLayoutConstraint.activate([
            stickerVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stickerVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint,
            stickerPickerTopConstraint
        ])
        
        SnapKitManager.shared.delegate = self
    }
    
    @objc func toggleStickerViewVisible() {
        isStickerViewVisible = !isStickerViewVisible
    }
    
    func updateAndAnimateLayoutContstraints(duration: TimeInterval, options: UIView.AnimationOptions) {
        bottomConstraint.constant = 0
        stickerPickerTopConstraint.constant = (isStickerViewVisible ? stickerViewHeight : 0)
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension BitmojiStickerPickerViewController {
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension BitmojiStickerPickerViewController: SnapKitManagerDelegate {
    func bitmojiStickerPicker(didSelectBitmojiWithURL bitmojiURL: String, image: UIImage?) {
        completionBlock?(bitmojiURL, image)
        doneButtonClicked(UIButton())
    }
    
    func searchFieldFocusDidChange(hasFocus: Bool) {
        bitmojiSearchHasFocus = hasFocus
    }
}
