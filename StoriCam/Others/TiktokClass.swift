//
//  TiktokClass.swift
//  StoriCam
//
//  Created by Viraj Patel on 13/11/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import TikTokOpenPlatformSDK

open class TiktokShare: NSObject, TikTokOpenPlatformLogDelegate {
    
    static let shared: TiktokShare = TiktokShare()
    
    var delegate: ShareStoriesDelegate?
    
    var isTiktokInstalled: Bool {
        return TiktokOpenPlatformApplicationDelegate.sharedInstance().isAppInstalled(with: TikTokOpenPlatformAppType.I18N)
    }
    
    public override init() {
        super.init()
        
    }

    func setupTiktok(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    
        TiktokOpenPlatformApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        TiktokOpenPlatformApplicationDelegate.sharedInstance().logDelegate = self
    }
    
    public func tiktok(onLog logInfo: String) {
        debugPrint(logInfo)
    }
}
