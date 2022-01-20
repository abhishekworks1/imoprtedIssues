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
import SCSDKCreativeKit

private let externalIdQuery = "{me{displayName, bitmoji{avatar}, externalId}}"

public protocol SnapKitManagerDelegate: class {
    func bitmojiStickerPicker(didSelectBitmojiWithURL bitmojiURL: String, image: UIImage?)
    func searchFieldFocusDidChange(hasFocus: Bool)
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
  
    var userData: LoginUserData? = nil
    
    func login(viewController: UIViewController, completion: @escaping (Bool, String?) -> Void) {
        SCSDKLoginClient.login(from: viewController) { (success: Bool, error: Error?) in
            if success {
                completion(true, "")
            } else {
                let message = error?.localizedDescription
                completion(false, message)
                print("error: " + (message ?? ""))
            }
        }
        
    }
    
    func logout(completion: @escaping (Bool) -> Void) {
        SCSDKLoginClient.clearToken()
        Defaults.shared.snapchatProfileURL = nil
        completion(true)
        userData = nil
    }
    
    public override init() {
        super.init()
        SCSDKLoginClient.addLoginStatusObserver(self)
        SCSDKLoginClient.removeLoginStatusObserver(self)
        if isUserLogin {
            loadUserData { _ in
                
            }
        }
        stickerVC.delegate = self
    }
    
    var isUserLogin: Bool {
        return SCSDKLoginClient.isUserLoggedIn
    }
    
    func loadUserData(completion: @escaping (_ userData: LoginUserData?) -> ()) {
        if isUserLogin {
            if let existUserData = userData {
                completion(existUserData)
                return
            }
            SCSDKLoginClient.fetchUserData(
                withQuery: externalIdQuery,
                variables: ["page": "bitmoji"],
                success: { resp in
                    guard let resources = resp as? [String: Any],
                        let data = resources["data"] as? [String: Any],
                        let me = data["me"] as? [String: Any] else { return }
                    var userName: String? = ""
                    var bitmojiAvatarUrl: String? = ""
                    var userId: String? = ""
                    if let displayName = me["displayName"] as? String {
                        print((String(describing: displayName)))
                        userName = displayName
                    }
                    if let bitmoji = me["bitmoji"] as? [String: Any] {
                        bitmojiAvatarUrl = bitmoji["avatar"] as? String
                        print((String(describing: bitmojiAvatarUrl)))
                    }
                    if let externalId = me["externalId"] as? String {
                        print((String(describing: externalId)))
                        userId = externalId
                    }
                    let responseData = LoginUserData(userId: userId, userName: userName, email: "", gender: 0, photoUrl: bitmojiAvatarUrl)
                    self.userData = responseData
                    Defaults.shared.snapchatProfileURL = self.userData?.photoUrl
                    completion(responseData)
            }, failure: { _, _ in
                
            })
        } else {
            completion(nil)
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return SCSDKLoginClient.application(app, open: url, options: options)
    }
    
    public func scsdkLoginLinkDidSucceed() {
        loadUserData { _ in
            
        }
    }
    
    public func scsdkLoginDidUnlink() {
        userData = nil
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
