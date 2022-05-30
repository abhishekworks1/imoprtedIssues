//
//  Defaults.swift
//  ProManager
//
//  Created by Jasmin Patel on 21/08/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import CoreLocation
import AVKit
import PostHog

var isDebug: Bool {
    #if DEBUG
    return true
    #else
    return false
    #endif
}

var isAlpha: Bool {
    #if ALPHA
    return true
    #else
    return false
    #endif
}

var isBeta: Bool {
    #if BETA
    return true
    #else
    return false
    #endif
}

var isStore: Bool {
    #if STORE
    return true
    #else
    return false
    #endif
}

var isSocialCamApp: Bool {
    #if SOCIALCAMAPP
    return true
    #else
    return false
    #endif
}

var isViralCamApp: Bool {
    #if VIRALCAMAPP
    return true
    #else
    return false
    #endif
}

var isRecorderApp: Bool {
    #if RECORDERAPP
    return true
    #else
    return false
    #endif
}

var isSoccerCamApp: Bool {
    #if SOCCERCAMAPP
    return true
    #else
    return false
    #endif
}

var isFutbolCamApp: Bool {
    #if FUTBOLCAMAPP
    return true
    #else
    return false
    #endif
}
   
var isQuickCamApp: Bool {
    #if QUICKCAMAPP
    return true
    #else
    return false
    #endif
}

var isPic2ArtApp: Bool {
    #if PIC2ARTAPP
    return true
    #else
    return false
    #endif
}

var isTimeSpeedApp: Bool {
    #if TIMESPEEDAPP
    return true
    #else
    return false
    #endif
}

var isSnapCamApp: Bool {
    #if SNAPCAMAPP
    return true
    #else
    return false
    #endif
}

var isSpeedCamApp: Bool {
    #if SPEEDCAMAPP
    return true
    #else
    return false
    #endif
}

var isSpeedCamLiteApp: Bool {
    #if SPEEDCAMLITEAPP
    return true
    #else
    return false
    #endif
}

var isBoomiCamApp: Bool {
    #if BOOMICAMAPP
    return true
    #else
    return false
    #endif
}

var isFastCamApp: Bool {
    #if FASTCAMAPP
    return true
    #else
    return false
    #endif
}

var isFastCamLiteApp: Bool {
    #if FASTCAMLITEAPP
    return true
    #else
    return false
    #endif
}

/// Clone app of SnapCamLite
var isQuickApp: Bool {
    #if QUICKAPP
    return true
    #else
    return false
    #endif
}

var isQuickCamLiteApp: Bool {
    #if QUICKCAMLITEAPP
    return true
    #else
    return false
    #endif
}

var isViralCamLiteApp: Bool {
    #if VIRALCAMLITEAPP
    return true
    #else
    return false
    #endif
}

var isSnapCamLiteApp: Bool {
    #if SNAPCAMLITEAPP
    return true
    #else
    return false
    #endif
}

var isLiteApp: Bool {
    return isViralCamLiteApp || isQuickCamLiteApp || isFastCamLiteApp || isSpeedCamLiteApp || isSnapCamLiteApp || isQuickApp
}

class Defaults {
    
    static let shared = Defaults()
    
    let appDefaults = UserDefaults(suiteName: Constant.Application.groupIdentifier)
    let userDefaults = UserDefaults()
    
    var calculatorConfig: [CalculatorConfigurationData]? {
        get {
            if let calculatorConfig = userDefaults.object(forKey: "calculatorConfig") as? Data {
                let decoder = JSONDecoder()
                return try? decoder.decode([CalculatorConfigurationData].self, from: calculatorConfig)
            }
            return nil
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                userDefaults.set(encoded, forKey: "calculatorConfig")
                userDefaults.synchronize()
            } else {
                userDefaults.set(nil, forKey: "calculatorConfig")
                userDefaults.synchronize()
            }
        }
    }
    
    var waterarkOpacity: Int {
        get {
            return appDefaults?.integer(forKey: "opacity") ?? 30
        }
        set {
            appDefaults?.setValue(newValue, forKey: "opacity")
            userDefaults.synchronize()
        }
    }
    
    var allowHaptic: Int {
        get {
            return appDefaults?.integer(forKey: "allowHaptic") ?? 0
        }
        set {
            appDefaults?.setValue(newValue, forKey: "allowHaptic")
            userDefaults.synchronize()
        }
    }
    
    var postViralCamModel: CreatePostViralCam? {
        get {
            if let loggedUser = appDefaults?.object(forKey: "createPostViralCam") as? Data {
                let decoder = JSONDecoder()
                return try? decoder.decode(CreatePostViralCam.self, from: loggedUser)
            }
            return nil
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                appDefaults?.set(encoded, forKey: "createPostViralCam")
                appDefaults?.synchronize()
            } else {
                appDefaults?.set(nil, forKey: "createPostViralCam")
                appDefaults?.synchronize()
            }
        }
    }
    
    var isMultiPhotoLayout: Bool? {
        get {
            return appDefaults?.bool(forKey: "isMultiPhotoLayout")
        }
        set {
            appDefaults?.set(newValue, forKey: "isMultiPhotoLayout")
        }
    }
    
    var isSubscriptionApiCalled: Bool? {
        get {
            return appDefaults?.bool(forKey: "isSubscriptionApiCalled") ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isSubscriptionApiCalled")
        }
    }
    
    var isPro: Bool {
        get {
            return appDefaults?.bool(forKey: "isPro") ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isPro")
        }
    }
    
    var isFirstLaunch: Bool? {
        get {
            return appDefaults?.bool(forKey: "isFirstLaunch")
        }
        set {
            appDefaults?.set(newValue, forKey: "isFirstLaunch")
        }
    }
    
    var bannerImageURLs: [String]? {
        get {
            return appDefaults?.value(forKey: "bannerImageURLs") as? [String]
        }
        set {
            appDefaults?.set(newValue, forKey: "bannerImageURLs")
        }
    }
    
    var supportedFrameRates: [String]? {
        get {
            return appDefaults?.value(forKey: "supportedFrameRates") as? [String]
        }
        set {
            appDefaults?.set(newValue, forKey: "supportedFrameRates")
        }
    }
    
    var selectedFrameRates: String? {
        get {
            return appDefaults?.value(forKey: "selectedFrameRates") as? String
        }
        set {
            appDefaults?.set(newValue, forKey: "selectedFrameRates")
        }
    }
    
    var currentUser: User? {
        get {
            if let loggedUser = appDefaults?.object(forKey: "loggedUser") as? Data {
                let decoder = JSONDecoder()
                return try? decoder.decode(User.self, from: loggedUser)
            }
            return nil
        }
        set {
            appMode = self.appMode.getTypeFromString(type: newValue?.subscriptions?.ios?.currentStatus ?? "free")
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                appDefaults?.set(encoded, forKey: "loggedUser")
                appDefaults?.synchronize()
            } else {
                appDefaults?.set(nil, forKey: "loggedUser")
                appDefaults?.synchronize()
            }
        }
    }
    
    var appleLoginUserData: LoginUserData? {
        get {
            if let loggedUser = appDefaults?.object(forKey: "appleLoginUserData") as? Data {
                let decoder = JSONDecoder()
                return try? decoder.decode(LoginUserData.self, from: loggedUser)
            }
            return nil
        } set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                appDefaults?.set(encoded, forKey: "appleLoginUserData")
                appDefaults?.synchronize()
            } else {
                appDefaults?.set(nil, forKey: "appleLoginUserData")
                appDefaults?.synchronize()
            }
        }
    }
    
    var instagramToken: String? {
        get {
            return appDefaults?.string(forKey: "instagramToken")
        }
        set {
            appDefaults?.set(newValue, forKey: "instagramToken")
        }
    }
    
    var instagramProfile: ProfileDetailsResponse? {
        get {
            if let loggedUser = appDefaults?.object(forKey: "profileDetailsResponse") as? Data {
                let decoder = JSONDecoder()
                return try? decoder.decode(ProfileDetailsResponse.self, from: loggedUser)
            }
            return nil
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                appDefaults?.set(encoded, forKey: "profileDetailsResponse")
                appDefaults?.synchronize()
            }
        }
    }
    
    var parentID: String? {
        get {
            return appDefaults?.string(forKey: "parentId")
        }
        set {
            appDefaults?.set(newValue, forKey: "parentId")
        }
    }
    
    var releaseType: ReleaseType {
        get {
            return ReleaseType(rawValue: (appDefaults?.string(forKey: "releaseType") ?? "store")) ?? .store
        }
        set {
            appDefaults?.set(newValue.description, forKey: "releaseType")
        }
    }
    
    var sessionToken: String? {
        get {
            return appDefaults?.string(forKey: "sessionToken")
        }
        set {
            appDefaults?.set(newValue, forKey: "sessionToken")
        }
    }
    
    var videoCallToken: String? {
        get {
            return appDefaults?.string(forKey: "sharedSessionToken")
        }
        set {
            appDefaults?.set(newValue, forKey: "sharedSessionToken")
        }
    }
    
    var shareRoomID: String? {
        get {
            return appDefaults?.string(forKey: "shareRoomID")
        }
        set {
            appDefaults?.set(newValue, forKey: "shareRoomID")
        }
    }
    
    func removeShareRoomID() {
        appDefaults?.removeObject(forKey: "shareRoomID")
    }
    
    var isHandsfreeRecord: Bool? {
        get {
            return appDefaults?.bool(forKey: "isHandsfreeRecord")
        }
        set {
            appDefaults?.set(newValue, forKey: "isHandsfreeRecord")
        }
    }
    
    var flashMode: Int? {
        get {
            return appDefaults?.value(forKey: "flashMode") as? Int
        }
        set {
            appDefaults?.set(newValue, forKey: "flashMode")
        }
    }
    
    var cameraPosition: Int? {
        get {
            return appDefaults?.value(forKey: "cameraPosition") as? Int
        }
        set {
            appDefaults?.set(newValue, forKey: "cameraPosition")
        }
    }
    
    var isMicOn: Bool? {
        get {
            return appDefaults?.bool(forKey: "isMicOn")
        }
        set {
            appDefaults?.set(newValue, forKey: "isMicOn")
        }
    }
    
    var currentLocation: CLLocation? {
        get {
            let decodedValue = appDefaults?.object(forKey: "currentLocation") as? Data
            if let value = decodedValue {
                do {
                    return try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self, from: value)
                } catch let error {
                    print("color error \(error.localizedDescription)")
                    return nil
                }
            }
            return nil
        }
        set {
            do {
                let encodedData = try NSKeyedArchiver.archivedData(withRootObject: newValue as Any, requiringSecureCoding: false)
                appDefaults?.set(encodedData, forKey: "currentLocation")
            } catch let error {
                print("error color key data not saved \(error.localizedDescription)")
            }
        }
    }
    
    var isTagGrid: Bool {
        get {
            return appDefaults?.bool(forKey: "isTagGrid") ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isTagGrid")
        }
    }
    
    var isGrid: Bool {
        get {
            return appDefaults?.bool(forKey: "isGrid") ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isGrid")
        }
    }
    
    var isListStory: Bool {
        get {
            return appDefaults?.bool(forKey: "isListStory") ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isListStory")
        }
    }
    
    var currentTemperature: String? {
        get {
            return appDefaults?.string(forKey: "currentTemperature")
        }
        set {
            appDefaults?.set(newValue, forKey: "currentTemperature")
        }
    }
    
    var openingScreen: OpeningScreen {
        get {
            return OpeningScreen(rawValue: (appDefaults?.integer(forKey: "openingScreen") ?? 0)) ?? .camera
        }
        set {
            appDefaults?.set(newValue.rawValue, forKey: "openingScreen")
        }
    }
    
    var cameraMode: CameraMode {
        get {
            return CameraMode(rawValue: (appDefaults?.integer(forKey: "recordingType") ?? 2)) ?? .normal
        }
        set {
            appDefaults?.set(newValue.rawValue, forKey: "recordingType")
        }
    }
    
    var appMode: AppMode {
        get {
            if isLiteApp {
                let appMode = AppMode(rawValue: (appDefaults?.integer(forKey: "appMode") ?? 1)) ?? .basic
                    return appMode
            } else {
                return AppMode(rawValue: (appDefaults?.integer(forKey: "appMode") ?? 0)) ?? .free
            }
        }
        set {
            appDefaults?.set(newValue.rawValue, forKey: "appMode")
        }
    }
    
    var swapeContols: Bool {
        get {
            return (appDefaults?.value(forKey: "swapeContols") as? Bool) ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "swapeContols")
        }
    }
    
    var fastestEverWatermarkSetting: FastestEverWatermarkSetting {
        get {
            return FastestEverWatermarkSetting(rawValue: (appDefaults?.integer(forKey: "FastestEverWatermarkSetting") ?? 2)) ?? .hide
        }
        set {
            appDefaults?.set(newValue.rawValue, forKey: "FastestEverWatermarkSetting")
        }
    }
    
    var appIdentifierWatermarkSetting: AppIdentifierWatermarkSetting {
        get {
            return AppIdentifierWatermarkSetting(rawValue: (appDefaults?.integer(forKey: "AppIdentifierWatermarkSetting") ?? 1)) ?? .show
        }
        set {
            appDefaults?.set(newValue.rawValue, forKey: "AppIdentifierWatermarkSetting")
        }
    }
    
    var madeWithGifSetting: MadeWithGifSetting {
        get {
            return MadeWithGifSetting(rawValue: (appDefaults?.integer(forKey: "madeWithGifSetting") ?? 2)) ?? .hide
        }
        set {
            appDefaults?.set(newValue.rawValue, forKey: "madeWithGifSetting")
        }
    }
    
    var publicDisplaynameWatermarkSetting: PublicDisplaynameWatermarkSetting {
        get {
            return PublicDisplaynameWatermarkSetting(rawValue: (appDefaults?.integer(forKey: "publicDisplaynameWatermarkSetting") ?? 2)) ?? .hide
        }
        set {
            appDefaults?.set(newValue.rawValue, forKey: "publicDisplaynameWatermarkSetting")
        }
    }
    
    var videoResolution: VideoResolution {
        get {
            return VideoResolution(rawValue: (appDefaults?.integer(forKey: "VideoResolution") ?? 1)) ?? .low
        }
        set {
            appDefaults?.set(newValue.rawValue, forKey: "VideoResolution")
        }
    }
    
    var enableGuildlines: Bool {
        get {
            return (appDefaults?.value(forKey: "enableGuildlines") as? Bool) ?? true
        }
        set {
            appDefaults?.set(newValue, forKey: "enableGuildlines")
        }
    }
    
    var enableBlurVideoBackgroud: Bool {
        get {
            return (appDefaults?.value(forKey: "enableBlurVideoBackgroud") as? Bool) ?? true
        }
        set {
            appDefaults?.set(newValue, forKey: "enableBlurVideoBackgroud")
        }
    }
    
    var enableFaceDetection: Bool {
        get {
            return (appDefaults?.value(forKey: "enableFaceDetection") as? Bool) ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "enableFaceDetection")
        }
    }
    
    var isCombineSegments: Bool {
        get {
            return appDefaults?.bool(forKey: "isCombineSegments") ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isCombineSegments")
        }
    }
    
    var playGIF: Bool {
        get {
            return appDefaults?.bool(forKey: "playGIF") ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "playGIF")
        }
    }
    
    var isPublish: Bool {
        get {
            return appDefaults?.value(forKey: "isPublish") as? Bool ?? true
        }
        set {
            appDefaults?.set(newValue, forKey: "isPublish")
        }
    }
    
    var snapchatProfileURL: String? {
        get {
            return appDefaults?.value(forKey: "snapchatProfileURL") as? String
        }
        set {
            appDefaults?.set(newValue, forKey: "snapchatProfileURL")
        }
    }
    
    var cameraGuidelineTypes: GuidelineTypes {
        get {
            return GuidelineTypes(rawValue: (appDefaults?.integer(forKey: "cameraGuidelineTypes") ?? 3)) ?? .dashedLine
        }
        set {
            appDefaults?.set(newValue.rawValue, forKey: "cameraGuidelineTypes")
        }
    }
    
    var cameraGuidelineThickness: GuidelineThickness {
        get {
            return GuidelineThickness(rawValue: (appDefaults?.integer(forKey: "cameraGuidelineThickness") ?? 3)) ?? .medium
        }
        set {
            appDefaults?.set(newValue.rawValue, forKey: "cameraGuidelineThickness")
        }
    }
    
    var cameraGuidelineActiveColor: UIColor {
        get {
            return appDefaults?.getColor(forKey: "cameraGuidelineActiveColor") ?? R.color.active1()!
        }
        set {
            appDefaults?.setColor(newValue, forKey: "cameraGuidelineActiveColor")
        }
    }
    
    var cameraGuidelineInActiveColor: UIColor {
        get {
            return appDefaults?.getColor(forKey: "cameraGuidelineInActiveColor") ?? R.color.inActive7()!
        }
        set {
            appDefaults?.setColor(newValue, forKey: "cameraGuidelineInActiveColor")
        }
    }
    
    var isCameraSettingChanged: Bool {
        get {
            return (appDefaults?.value(forKey: "isCameraSettingChanged") as? Bool) ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isCameraSettingChanged")
        }
    }
    
    var settingsPreference: Int {
        //0 for list , 1 for grid
        get {
            return appDefaults?.integer(forKey: "settingsPreference") ?? 0
        }
        set {
            appDefaults?.setValue(newValue, forKey: "settingsPreference")
            userDefaults.synchronize()
        }
    }
    
    var isRegistered: Bool? {
        get {
            return appDefaults?.value(forKey: "isRegistered") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isRegistered")
        }
    }
    
    var userCreatedDate: String? {
        get {
            return appDefaults?.value(forKey: "userCreatedDate") as? String
        }
        set {
            appDefaults?.set(newValue, forKey: "userCreatedDate")
        }
    }
    
    var isSubscriptionExpired: Bool {
        get {
            return appDefaults?.value(forKey: "isSubscriptionExpired") as? Bool ?? true
        }
        set {
            appDefaults?.set(newValue, forKey: "isSubscriptionExpired")
        }
    }
    
    var isLoginTooltipHide: Bool {
        get {
            return appDefaults?.value(forKey: "isLoginTooltipShow") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isLoginTooltipShow")
        }
    }
    
    var isDoNotShowAgainBusinessCenterClicked: Bool {
        get {
            return appDefaults?.value(forKey: "isDoNotShowAgainBusinessCenterClicked") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isDoNotShowAgainBusinessCenterClicked")
        }
    }
    
    var isDoNotShowAgainVidPlayClicked: Bool {
        get {
            return appDefaults?.value(forKey: "isDoNotShowAgainVidPlayClicked") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isDoNotShowAgainVidPlayClicked")
        }
    }
    
    var isDoNotShowAgainOpenBusinessCenterPopup: Bool {
        get {
            return appDefaults?.value(forKey: "isDoNotShowAgainOpenBusinessCenterPopup") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isDoNotShowAgainOpenBusinessCenterPopup")
        }
    }
    
    var isDoNotShowAgainDeleteContactPopup: Bool {
        get {
            return appDefaults?.value(forKey: "isDoNotShowAgainDeleteContactPopup") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isDoNotShowAgainDeleteContactPopup")
        }
    }
    var isFirstTimePic2ArtRegistered: Bool? {
        get {
            return appDefaults?.value(forKey: "isFirstTimePic2ArtRegistered") as? Bool ?? true
        }
        set {
            appDefaults?.set(newValue, forKey: "isFirstTimePic2ArtRegistered")
        }
    }
    
    var isFirstVideoRegistered: Bool? {
        get {
            return appDefaults?.value(forKey: "isFirstVideoRegistered") as? Bool ?? true
        }
        set {
            appDefaults?.set(newValue, forKey: "isFirstVideoRegistered")
        }
    }
    
    var isSurveyAlertShowed: Bool {
        get {
            return appDefaults?.value(forKey: "isSurveyAlertShowed") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isSurveyAlertShowed")
        }
    }
    
    var isPic2ArtShowed: Bool? {
        get {
            return appDefaults?.value(forKey: "isPic2ArtShowed") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isPic2ArtShowed")
        }
    }
    
    var isFromSignup: Bool? {
        get {
            return appDefaults?.value(forKey: "isFromSignup") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isFromSignup")
        }
    }
    
    var isSignupLoginFlow: Bool? {
        get {
            return appDefaults?.value(forKey: "isSignupLoginFlow") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isSignupLoginFlow")
        }
    }
    
    var numberOfFreeTrialDays: Int? {
        get {
            return appDefaults?.value(forKey: "numberOfFreeTrialDays") as? Int
        }
        set {
            appDefaults?.set(newValue, forKey: "numberOfFreeTrialDays")
        }
    }
    
    var subscriptionId: String? {
        get {
            return appDefaults?.value(forKey: "subscriptionId") as? String
        }
        set {
            appDefaults?.set(newValue, forKey: "subscriptionId")
        }
    }
    
    var isDowngradeSubscription: Bool? {
        get {
            return appDefaults?.value(forKey: "isDowngradeSubscription") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isDowngradeSubscription")
        }
    }
    
    var isFreeTrial: Bool? {
        get {
            return appDefaults?.value(forKey: "isFreeTrial") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isFreeTrial")
        }
    }
    
    var isQuickLinkShowed: Bool? {
        get {
            return appDefaults?.value(forKey: "isQuickLinkShowed") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isQuickLinkShowed")
        }
    }
    
    var isAffiliateLinkActivated: Bool {
        get {
            return appDefaults?.value(forKey: "isAffiliateLinkActivated") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isAffiliateLinkActivated")
        }
    }
    
    var isAffiliatePopupShowed: Bool {
        get {
            return appDefaults?.value(forKey: "isAffiliatePopupShowed") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isAffiliatePopupShowed")
        }
    }
    
    var enterLinkValue: String {
        get {
            return appDefaults?.value(forKey: "enterLinkValue") as? String ?? ""
        }
        set {
            appDefaults?.set(newValue, forKey: "enterLinkValue")
        }
    }
    
    var isDiscardVideoPopupHide: Bool {
        get {
            return appDefaults?.value(forKey: "isDiscardVideoPopupHide") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isDiscardVideoPopupHide")
        }
    }
    
    var channelId: String? {
        get {
            return appDefaults?.value(forKey: "channelId") as? String
        }
        set {
            appDefaults?.set(newValue, forKey: "channelId")
        }
    }
    
    var isContactConfirmPopUpChecked: Bool {
        get {
            return appDefaults?.value(forKey: "isContactConfirmPopUpChecked") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isContactConfirmPopUpChecked")
        }
    }
    
    var isShowAllPopUpChecked: Bool {
        get {
            return appDefaults?.value(forKey: "isShowAllPopUpChecked") as? Bool ?? true
        }
        set {
            appDefaults?.set(newValue, forKey: "isShowAllPopUpChecked")
        }
    }
    
    var isToolTipHide: Bool {
        get {
            return appDefaults?.value(forKey: "isToolTipHide") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isToolTipHide")
        }
    }
    
    var allowFullAccess: Bool? {
        get {
            return appDefaults?.value(forKey: "allowFullAccess") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "allowFullAccess")
        }
    }
    var subscriptionType: String? {
        get {
            return appDefaults?.value(forKey: "subscriptionType") as? String
        }
        set {
            appDefaults?.set(newValue, forKey: "subscriptionType")
        }
    }
    var isSkipYoutubeLogin: Bool {
        get {
            return appDefaults?.value(forKey: "isSkipYoutubeLogin") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isSkipYoutubeLogin")
        }
    }
    
    var isMutehapticFeedbackOnSpeedSelection: Bool {
        get {
            return appDefaults?.value(forKey: "isMutehapticFeedbackOnSpeedSelection") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isMutehapticFeedbackOnSpeedSelection")
        }
    }
    
    var isVideoSavedAfterRecordingFirstTime: Bool {
        get {
            return appDefaults?.value(forKey: "isVideoSavedAfterRecordingFirstTime") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isVideoSavedAfterRecordingFirstTime")
        }
    }
    
    var isVideoSavedAfterRecording: Bool {
        get {
            return appDefaults?.value(forKey: "isVideoSavedAfterRecording") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isVideoSavedAfterRecording")
        }
    }
    
    var isVideoSavedAfterEditing: Bool {
        get {
            return appDefaults?.value(forKey: "isVideoSavedAfterEditing") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isVideoSavedAfterEditing")
        }
    }
    
    var isAutoSavePic2Art: Bool {
        get {
            return appDefaults?.value(forKey: "isAutoSavePic2Art") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isAutoSavePic2Art")
        }
    }
    
    var isProfileTooltipHide: Bool {
        get {
            return appDefaults?.value(forKey: "isProfileTooltipShow") as? Bool ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isProfileTooltipShow")
        }
    }
    
    var muteOnSlowMotion: Bool {
        get {
            return (appDefaults?.value(forKey: "muteOnSlowMotion") as? Bool) ?? true
        }
        set {
            appDefaults?.set(newValue, forKey: "muteOnSlowMotion")
        }
    }
    
    var muteOnFastMotion: Bool {
        get {
            return (appDefaults?.value(forKey: "muteOnFastMotion") as? Bool) ?? true
        }
        set {
            appDefaults?.set(newValue, forKey: "muteOnFastMotion")
        }
    }
    
    var socialPlatforms: [String]? {
        get {
            return appDefaults?.value(forKey: StaticKeys.socialPlatforms) as? [String]
        }
        set {
            appDefaults?.set(newValue, forKey: StaticKeys.socialPlatforms)
        }
    }
    
    var includeProfileImgForShare: Bool {
        get {
            return (appDefaults?.value(forKey: StaticKeys.includeImg) as? Bool) ?? true
        }
        set {
            appDefaults?.set(newValue, forKey: StaticKeys.includeImg)
        }
    }
    
    var includeQRImgForShare: Bool {
        get {
            return (appDefaults?.value(forKey: StaticKeys.includeQrImg) as? Bool) ?? true
        }
        set {
            appDefaults?.set(newValue, forKey: StaticKeys.includeQrImg)
        }
    }
        
    var ytChannelName: String {
        get {
            return appDefaults?.value(forKey: StaticKeys.ytChannelName) as? String ?? ""
        }
        set {
            appDefaults?.set(newValue, forKey: StaticKeys.ytChannelName)
        }
    }
    
    var channelThumbNail: String {
        get {
            return appDefaults?.value(forKey: StaticKeys.channelThumbNail) as? String ?? ""
        }
        set {
            appDefaults?.set(newValue, forKey: StaticKeys.channelThumbNail)
        }
    }
    
    var newSignupsNotificationType: NewSignupsNotificationType {
        get {
            return NewSignupsNotificationType(rawValue: (appDefaults?.integer(forKey: StaticKeys.newSignupsNotificationType) ?? 1)) ?? .forAllUsers
        }
        set {
            appDefaults?.set(newValue.rawValue, forKey: StaticKeys.newSignupsNotificationType)
        }
    }
    
    var newSubscriptionNotificationType: NewSubscriptionNotificationType {
        get {
            return NewSubscriptionNotificationType(rawValue: (appDefaults?.integer(forKey: StaticKeys.newSubscriptionNotificationType) ?? 1)) ?? .forAllUsers
        }
        set {
            appDefaults?.set(newValue.rawValue, forKey: StaticKeys.newSubscriptionNotificationType)
        }
    }
    
    var milestonesReached: Bool {
        get {
            return (appDefaults?.value(forKey: StaticKeys.milestonesReached) as? Bool) ?? true
        }
        set {
            appDefaults?.set(newValue, forKey: StaticKeys.milestonesReached)
        }
    }
    
    var deviceToken: String? {
        get {
            return appDefaults?.value(forKey: StaticKeys.deviceToken) as? String
        }
        set {
            appDefaults?.set(newValue, forKey: StaticKeys.deviceToken)
        }
    }
    
    var referredUserCreatedDate: String? {
        get {
            return appDefaults?.value(forKey: StaticKeys.referredUserCreatedDate) as? String
        }
        set {
            appDefaults?.set(newValue, forKey: StaticKeys.referredUserCreatedDate)
        }
    }
    
    var referredByData: RefferedBy? {
        get {
            if let referredUser = appDefaults?.object(forKey: StaticKeys.referredByData) as? Data {
                let decoder = JSONDecoder()
                return try? decoder.decode(RefferedBy.self, from: referredUser)
            }
            return nil
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                appDefaults?.set(encoded, forKey: StaticKeys.referredByData)
                appDefaults?.synchronize()
            }
        }
    }
    
    var publicDisplayName: String? {
        get {
            return appDefaults?.value(forKey: StaticKeys.publicDisplayName) as? String
        }
        set {
            appDefaults?.set(newValue, forKey: StaticKeys.publicDisplayName)
        }
    }
    
    var privateDisplayName: String? {
        get {
            return appDefaults?.value(forKey: StaticKeys.privateDisplayName) as? String
        }
        set {
            appDefaults?.set(newValue, forKey: StaticKeys.privateDisplayName)
        }
    }
    
    var emailAddress: String? {
        get {
            return appDefaults?.value(forKey: StaticKeys.emailAddress) as? String
        }
        set {
            appDefaults?.set(newValue, forKey: StaticKeys.emailAddress)
        }
    }
    
    var isEditProfileDiscardPopupChecked: Bool {
        get {
            return appDefaults?.value(forKey: StaticKeys.isEditProfileDiscardPopupChecked) as? Bool ?? true
        }
        set {
            appDefaults?.set(newValue, forKey: StaticKeys.isEditProfileDiscardPopupChecked)
        }
    }
    
    var isStateFlagDiscardPopupChecked: Bool {
        get {
            return appDefaults?.value(forKey: StaticKeys.isStateFlagDiscardPopupChecked) as? Bool ?? true
        }
        set {
            appDefaults?.set(newValue, forKey: StaticKeys.isStateFlagDiscardPopupChecked)
        }
    }
    
    var isShareScreenDiscardPopupChecked: Bool {
        get {
            return appDefaults?.value(forKey: StaticKeys.isShareScreenDiscardPopupChecked) as? Bool ?? true
        }
        set {
            appDefaults?.set(newValue, forKey: StaticKeys.isShareScreenDiscardPopupChecked)
        }
    }
    var defaultEmailApp: String? {
        get {
            return appDefaults?.string(forKey: "defaultEmailApp")
        }
        set {
            appDefaults?.set(newValue, forKey: "defaultEmailApp")
        }
    }
    var isEditSoundOff: Bool {
        get {
            return appDefaults?.bool(forKey: "isEditSoundOff") ?? false
        }
        set {
            appDefaults?.set(newValue, forKey: "isEditSoundOff")
        }
    }
    
    func clearData(isDeleteAccount: Bool = false) {
        if let appDefaultsDictionary = appDefaults?.dictionaryRepresentation() {
            appDefaultsDictionary.keys.forEach { key in
                if isDeleteAccount {
                    appDefaults?.removeObject(forKey: key)
                } else {
                    if key != "isLoginTooltipShow", key != "isSurveyAlertShowed" {
                        appDefaults?.removeObject(forKey: key)
                    }
                }
            }
        }
    }
    func addEventWithName(eventName:String){
        let posthog = PHGPostHog.shared()
        //print("**************eventName**********")
        //print(eventName)
        //print("**************eventName**********")
        var userName = ""
        var userEmail = ""
        if let user = Defaults.shared.currentUser{
            userName = user.username ?? ""
            userEmail = user.email ?? ""
        }
        posthog?.capture(eventName, properties: ["$set": ["userName": userName,"userEmail": userEmail] ])
        posthog?.identify(userEmail,
                  properties: ["name": userName, "email": userEmail])


    }
    
    func callHapticFeedback(isHeavy:Bool, isImportant:Bool = true){
        switch  Defaults.shared.allowHaptic{
        case HapticSetting.none.rawValue:
            return
        case HapticSetting.some.rawValue:
            if !isImportant{
                return
            }
        default: break
        }
        if Defaults.shared.isMutehapticFeedbackOnSpeedSelection == false {
            do {
                if #available(iOS 13.0, *) {
                    try AVAudioSession.sharedInstance().setAllowHapticsAndSystemSoundsDuringRecording(true)
                } else {
                    // Fallback on earlier versions
                }
            } catch {
                print(error)
            }
            DispatchQueue.main.async  {
                // your code here
                let generator = UIImpactFeedbackGenerator(style: isHeavy ?  .heavy : .medium)
                generator.impactOccurred()
            }
        }
    }
 
    func getbadgesArray() -> [String] {
        
        var imageArray = [String]()
//        print("Defaults.shared.currentUser \(String(describing: Defaults.shared.currentUser?.badges?[0].toJSON()))")
      //  print("Defaults.shared.currentUser \(String(describing: Defaults.shared.currentUser?.badges?[0].toJSON()))")
        //Defaults.shared.currentUser?.badges?[0].followingUser?.badges?[0].badge?.code
        if Defaults.shared.currentUser?.badges?.count ?? 0 > 0 {
            let badgesArray = Defaults.shared.currentUser?.badges
            print("badgesArray \(imageArray)")
            for i in 0 ..< (badgesArray?.count ?? 0){
                let badge = badgesArray![i] as ParentBadges
                let badImgname = self.imageNameBasedOnCode(code : badge.badge?.code ?? "")
                if badImgname.count > 0 {
                    imageArray.append(badImgname)
                }
            }
        }
        print("Badges imageArray \(imageArray)")
        return imageArray
    }
    
    func imageNameBasedOnCode(code:String) -> String{
        var imageName = ""
        switch code {
        case Badges.PRELAUNCH.rawValue:
            imageName = "prelaunchBadge"
        case Badges.FOUNDING_MEMBER.rawValue:
            imageName = "foundingMemberBadge"
        case Badges.SOCIAL_MEDIA_CONNECTION.rawValue:
            imageName = "socialBadge"
            //As subscription badges have to removed from header and other places
            //Now subscription badges are added in Settings List and Grid
      /*  case Badges.SUBSCRIBER_IOS.rawValue:
            imageName = "iosbadge"
        case Badges.SUBSCRIBER_ANDROID.rawValue:
            imageName = "androidbadge"
        case Badges.SUBSCRIBER_WEB.rawValue:
            imageName = "webbadge" */
        default:
            imageName = ""
        }
        return imageName
    }
    
}

extension UserDefaults {

    func getColor(forKey key: String) -> UIColor? {
        guard let colorData = data(forKey: key) else { return nil }
        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
        } catch let error {
            print("color error \(error.localizedDescription)")
            return nil
        }
    }

    func setColor(_ value: UIColor?, forKey key: String) {
        guard let color = value else { return }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
            set(data, forKey: key)
        } catch let error {
            print("error color key data not saved \(error.localizedDescription)")
        }
    }

}
