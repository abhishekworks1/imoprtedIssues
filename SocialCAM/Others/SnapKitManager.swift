//
//  SnapKitManager.swift
//  SocialCAM
//
//  Created by Viraj Patel on 27/01/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import SCSDKLoginKit
import SCSDKBitmojiKit

private let externalIdQuery = "{me{displayName, bitmoji{avatar}, externalId}}"

@objc public protocol SnapKitManagerDelegate: class {
    func bitmojiStickerPicker(didSelectBitmojiWithURL bitmojiURL: String, image: UIImage?)
    func searchFieldFocusDidChange(hasFocus: Bool)
    @objc optional func loginUserDetails(externalId: String)
}

open class SnapKitManager: NSObject, SCSDKLoginStatusObserver, SCSDKBitmojiStickerPickerViewControllerDelegate {
    
    static let shared: SnapKitManager = SnapKitManager()
    
    let stickerVC: SCSDKBitmojiStickerPickerViewController =
        SCSDKBitmojiStickerPickerViewController(config: SCSDKBitmojiStickerPickerConfigBuilder()
            .withShowSearchBar(true)
            .withShowSearchPills(true)
            .withTheme(.dark)
            .build())
    
    weak var delegate: SnapKitManagerDelegate?
    
    var externalId: String? = nil {
        didSet {
            if let loginUserDetailsDelegate = delegate?.loginUserDetails {
                loginUserDetailsDelegate(externalId ?? "")
            }
            
        }
    }
    
    func unlink() {
        SCSDKLoginClient.unlinkAllSessions { _ in
            
        }
    }
    
    public override init() {
        super.init()
        SCSDKLoginClient.addLoginStatusObserver(self)
        if isLogin {
            loadExternalId()
        }
        stickerVC.delegate = self
    }
    
    var isLogin: Bool {
        return SCSDKLoginClient.isUserLoggedIn
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
            
        })
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return SCSDKLoginClient.application(app, open: url, options: options)
    }
    
    public func scsdkLoginLinkDidSucceed() {
        loadExternalId()
    }
    
    public func bitmojiStickerPickerViewController(_ stickerPickerViewController: SCSDKBitmojiStickerPickerViewController,
                                                   didSelectBitmojiWithURL bitmojiURL: String,
                                                   image: UIImage?) {
        delegate?.bitmojiStickerPicker(didSelectBitmojiWithURL: bitmojiURL, image: image)
    }
    
    public func bitmojiStickerPickerViewController(_ stickerPickerViewController: SCSDKBitmojiStickerPickerViewController, searchFieldFocusDidChangeWithFocus hasFocus: Bool) {
        delegate?.searchFieldFocusDidChange(hasFocus: hasFocus)
    }
}
