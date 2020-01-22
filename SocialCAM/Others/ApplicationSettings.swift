//
//  ApplicationSettings.swift
//  BOATR
//
//  Created by Jasmin Patel on 10/05/17.
//  Copyright © 2017 Simform. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import Photos
import SafariServices

class ApplicationSettings {
    
    static let shared = ApplicationSettings()
     
    static let appPrimaryColor: UIColor = R.color.appPrimaryColor() ?? UIColor.blue
    
    static let appWhiteColor: UIColor = R.color.appWhiteColor() ?? UIColor.white
    
    static let appBlackColor: UIColor = R.color.appBlackColor() ?? UIColor.black
   
    static let appTabBarColor: UIColor = R.color.appTabBarColor() ?? UIColor.blue
    
    static let appSkyBlueColor: UIColor = R.color.appSkyBlueColor() ?? UIColor.blue
    
    static let appBackgroundColor: UIColor = R.color.appBackgroundColor() ?? UIColor.blue
    
    static let appOrangeColor: UIColor = R.color.appOrangeColor() ?? UIColor.orange
    
    static let appLightWhiteColor: UIColor = R.color.appLightWhiteColor() ?? UIColor.black

    static let appLightBlackColor: UIColor = R.color.lightBlackColor() ?? UIColor.black
    
    static let appClearColor: UIColor = R.color.appClearColor() ?? UIColor.clear
    
    static let appLightGrayColor: UIColor = UIColor.lightGray
    
    static var isCameraEnabled: Bool {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        return status == .authorized
    }
    
    static var isMicrophoneEnabled: Bool {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        return status == .authorized
    }
    static var isAlbumEnabled: Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        return status == .authorized
    }
    
    static func openWebBrowser(from viewController: UIViewController, URL: URL) {
        let browser = SFSafariViewController(url: URL)
        viewController.present(browser, animated: true, completion: nil)
    }
    
    static func openAppSettingsUrl() {
        let settingsUrl = URL(string: UIApplication.openSettingsURLString)
        if let url = settingsUrl, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    var socialId: String?
    
    var postURl: String?
    
    var coverUrl: String?
    
    var isAllowForward: Bool = false

    var videos: [Item] = []
    
    static let userPlaceHolder: UIImage = R.image.userProfilePlaceholder()?.sd_tintedImage(with: ApplicationSettings.appPrimaryColor) ?? UIImage()
   
    var needtoRefresh: Bool = false
    
    var shouldRotate: Bool = false
    
}
