//
//  TiktokClass.swift
//  SocialCAM
//
//  Created by Viraj Patel on 13/11/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import TikTokOpenPlatformSDK
import Photos

open class TiktokShare: NSObject, TikTokOpenPlatformLogDelegate {
    
    static let shared: TiktokShare = TiktokShare()
    
    weak var delegate: ShareStoriesDelegate?
    
    var isTiktokInstalled: Bool {
        return TiktokOpenPlatformApplicationDelegate.sharedInstance().isAppInstalled(with: TikTokOpenPlatformAppType.I18N)
    }
    
    public override init() {
        super.init()
        
    }
    
    func application(_ app: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return TiktokOpenPlatformApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func setupTiktok(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    
        TiktokOpenPlatformApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        TiktokOpenPlatformApplicationDelegate.sharedInstance().logDelegate = self
    }
    
    public func tiktok(onLog logInfo: String) {
        debugPrint(logInfo)
    }
    
    func uploadImageOrVideoOnTiktok(withText text: String = Constant.Application.displayName, phAsset: PHAsset, isImage: Bool) {
        let shareRequest = TikTokOpenPlatformShareRequest.init(appType: .I18N)
        shareRequest.mediaType = isImage ? .image : .video
        shareRequest.localIdentifiers = [phAsset.localIdentifier]
        shareRequest.state = text
        shareRequest.send { (tikTokOpenPlatformShareResponse) in
            if tikTokOpenPlatformShareResponse.isSucceed {
                Utils.appDelegate?.window?.makeToast(R.string.localizable.postSuccess())
            } else {
                
            }
        }
    }
}
