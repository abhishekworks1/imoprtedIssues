//
//  BitmojiStickerPickerViewController.swift
//  SocialCAM
//
//  Created by Viraj Patel on 09/01/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit
import SCSDKLoginKit
import SCSDKBitmojiKit

private let externalIdQuery = "{me{displayName, bitmoji{avatar}, externalId}}"
typealias CompletionImagePickClosure = (String, UIImage?) -> Void

class BitmojiStickerPickerViewController: UIViewController {
    
    @IBOutlet weak var stickerView: UIView!
    var completionBlock: CompletionImagePickClosure?
    var arrImage: [UIImage] = []
    let stickerVC: SCSDKBitmojiStickerPickerViewController =
        SCSDKBitmojiStickerPickerViewController(config: SCSDKBitmojiStickerPickerConfigBuilder()
            .withShowSearchBar(true)
            .withShowSearchPills(true)
            .withTheme(.dark)
            .build())
    
    var bottomConstraint: NSLayoutConstraint!
    
    private(set) lazy var unlinkButton: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "Unlink", style: .plain, target: self, action: #selector(unlink))
        item.tintColor = .red
        
        return item
    }()
    
    var externalId: String? {
        didSet {
            navigationItem.rightBarButtonItems =
                externalId == nil ? [unlinkButton] : [unlinkButton]
        }
    }
    
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
      
        SCSDKLoginClient.addLoginStatusObserver(self)
        if SCSDKLoginClient.isUserLoggedIn {
            loadExternalId()
        }
        navigationItem.rightBarButtonItems = [unlinkButton]
        stickerVC.view.translatesAutoresizingMaskIntoConstraints = false
        stickerVC.delegate = self
        self.addChild(stickerVC)
        stickerView.addSubview(stickerVC.view)
        stickerVC.didMove(toParent: self)
       
        let bitmojiIcon = SCSDKBitmojiIconView()
        bitmojiIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleStickerViewVisible)))
        bitmojiIcon.translatesAutoresizingMaskIntoConstraints = false
        stickerVC.attachBitmojiIcon(bitmojiIcon)
        stickerView.addSubview(bitmojiIcon)
     
        bottomConstraint = stickerVC.view.bottomAnchor.constraint(equalTo: stickerView.bottomAnchor)
        stickerPickerTopConstraint = stickerVC.view.topAnchor.constraint(equalTo: stickerView.topAnchor)
        NSLayoutConstraint.activate([
            stickerVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stickerVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint,
            stickerPickerTopConstraint
        ])
    }
    
    private func loadExternalId() {
        SCSDKLoginClient.fetchUserData(
            withQuery: externalIdQuery,
            variables: ["page": "bitmoji"],
            success: { resp in
                guard let resources = resp as? [String : Any],
                               let data = resources["data"] as? [String: Any],
                               let me = data["me"] as?  [String: Any] else { return }
                if let displayName = me["displayName"] as? String {
                    print((String(describing: displayName)))
                }
                if let bitmoji = me["bitmoji"] as? [String: Any] {
                    let bitmojiAvatarUrl = bitmoji["avatar"] as? String
                    print((String(describing: bitmojiAvatarUrl)))
                }
                if let externalId = me["externalId"] as? String {
                    print((String(describing: externalId)))
                    DispatchQueue.main.async {
                        self.externalId = externalId
                    }
                }
        }, failure: { _, _ in
            // handle error
        })
    }
    
    @objc func unlink() {
        SCSDKLoginClient.unlinkCurrentSession(completion: nil)
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

extension BitmojiStickerPickerViewController: SCSDKLoginStatusObserver {

    func scsdkLoginLinkDidSucceed() {
        loadExternalId()
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

extension BitmojiStickerPickerViewController: SCSDKBitmojiStickerPickerViewControllerDelegate {
    func bitmojiStickerPickerViewController(_ stickerPickerViewController: SCSDKBitmojiStickerPickerViewController,
                                            didSelectBitmojiWithURL bitmojiURL: String,
                                            image: UIImage?) {
        completionBlock?(bitmojiURL, image)
    }
    
    func bitmojiStickerPickerViewController(_ stickerPickerViewController: SCSDKBitmojiStickerPickerViewController, searchFieldFocusDidChangeWithFocus hasFocus: Bool) {
        bitmojiSearchHasFocus = hasFocus
    }
}
