//
//  TiktokClass.swift
//  SocialCAM
//
//  Created by Viraj Patel on 13/11/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import TikTokOpenSDK
import Photos

open class TiktokShare: TikTokOpenSDKApplicationDelegate, TikTokOpenSDKLogDelegate {
   
    static let shared: TiktokShare = TiktokShare()
    
    weak var delegate: ShareStoriesDelegate?
    
    var isTiktokInstalled: Bool {
        return TikTokOpenSDKApplicationDelegate.sharedInstance().isAppInstalled()
    }
    
    public override init() {
        super.init()
        
    }
    
    func application(_ app: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return TikTokOpenSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func setupTiktok(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    
        TikTokOpenSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        TikTokOpenSDKApplicationDelegate.sharedInstance().logDelegate = self
    }
    
    public func onLog(_ logInfo: String) {
        debugPrint(logInfo)
    }
    
    func uploadImageOrVideoOnTiktok(withText text: String = Constant.Application.displayName, phAsset: PHAsset, isImage: Bool) {
        let shareRequest = TikTokOpenSDKShareRequest()
        shareRequest.mediaType = isImage ? .image : .video
        shareRequest.localIdentifiers = [phAsset.localIdentifier]
        shareRequest.state = text
        shareRequest.send(complete: { (tikTokOpenPlatformShareResponse) in
            if tikTokOpenPlatformShareResponse.isSucceed {
                Utils.appDelegate?.window?.makeToast(R.string.localizable.postSuccess())
            } else {
                
            }
        })
    }
}
