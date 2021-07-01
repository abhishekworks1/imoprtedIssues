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
            appMode = self.appMode.getTypeFromString(type: newValue?.subscriptionStatus ?? "free")
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
            return ReleaseType(rawValue: (appDefaults?.string(forKey: "releaseType") ?? "debug")) ?? .debug
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
                if appMode == .advanced || appMode == .professional {
                    return .basic
                } else {
                    return appMode
                }
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
            return FastestEverWatermarkSetting(rawValue: (appDefaults?.integer(forKey: "FastestEverWatermarkSetting") ?? 1)) ?? .show
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
            return MadeWithGifSetting(rawValue: (appDefaults?.integer(forKey: "madeWithGifSetting") ?? 1)) ?? .show
        }
        set {
            appDefaults?.set(newValue.rawValue, forKey: "madeWithGifSetting")
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
            return appDefaults?.getColor(forKey: "cameraGuidelineActiveColor") ?? R.color.active5()!
        }
        set {
            appDefaults?.setColor(newValue, forKey: "cameraGuidelineActiveColor")
        }
    }
    
    var cameraGuidelineInActiveColor: UIColor {
        get {
            return appDefaults?.getColor(forKey: "cameraGuidelineInActiveColor") ?? R.color.inActive6()!
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
    
    func clearData() {
        if let appDefaultsDictionary = appDefaults?.dictionaryRepresentation() {
            appDefaultsDictionary.keys.forEach { key in
                if key != "isLoginTooltipShow", key != "isSurveyAlertShowed" {
                    appDefaults?.removeObject(forKey: key)
                }
            }
        }
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
