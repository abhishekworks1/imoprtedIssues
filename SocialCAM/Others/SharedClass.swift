//
//  SharedClass.swift
//  ProManager
//
//  Created by Viraj Patel on 16/09/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

/// Prints the filename, function name, line number and textual representation of `object` and a newline character into the standard output if the build setting for "Active Complilation Conditions" (SWIFT_ACTIVE_COMPILATION_CONDITIONS) defines `DEBUG`.
///
/// The current thread is a prefix on the output. <UI> for the main thread, <BG> for anything else.
///
/// Only the first parameter needs to be passed to this funtion.
///
/// The textual representation is obtained from the `object` using `String(reflecting:)` which works for _any_ type. To provide a custom format for the output make your object conform to `CustomDebugStringConvertible` and provide your format in the `debugDescription` parameter.
/// - Parameters:
///   - object: The object whose textual representation will be printed. If this is an expression, it is lazily evaluated.
///   - file: The name of the file, defaults to the current file without the ".swift" extension.
///   - function: The name of the function, defaults to the function within which the call is made.
///   - line: The line number, defaults to the line number within the file that the call is made.
public func dLog<T>(_ object: @autoclosure () -> T, filename: String = #file, _ function: String = #function, _ line: Int = #line) {
    if isDebug {
        let value = object()
        let fileURL = filename.lastPathComponent.stringByDeletingPathExtension
        let queue = Thread.isMainThread ? "UI" : "BG"
        print("<\(queue)> \(fileURL) \(function)[\(line)] :-> " + String(reflecting: value))
    }
}

/// Outputs a `dump` of the passed in value along with an optional label, the filename, function name, and line number to the standard output if the build setting for "Active Complilation Conditions" (SWIFT_ACTIVE_COMPILATION_CONDITIONS) defines `DEBUG`.
///
/// The current thread is a prefix on the output. <UI> for the main thread, <BG> for anything else.
///
/// Only the first parameter needs to be passed in to this function. If a label is required to describe what is being dumped, the `label` parameter can be used. If `nil` (the default), no label is output.
/// - Parameters:
///   - object: The object to be `dump`ed. If it is obtained by evaluating an expression, this is lazily evaluated.
///   - label: An optional label that may be used to describe what is being dumped.
///   - file: he name of the file, defaults to the current file without the ".swift" extension.
///   - function: The name of the function, defaults to the function within which the call is made.
///   - line: The line number, defaults to the line number within the file that the call is made.
public func dLogDump<T>(_ object: @autoclosure () -> T, label: String? = nil, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    if isDebug {
        let value = object()
        let fileURL = NSURL(string: file)?.lastPathComponent ?? "Unknown file"
        let queue = Thread.isMainThread ? "UI" : "BG"
        print("--------")
        print("<\(queue)> \(fileURL) \(function):[\(line)] ")
        label.flatMap { print($0) }
        dump(value)
        print("--------")
    }
}

protocol AppMode_Enum {
    var description: String { get }
}

public var termsAndConditionsUrl: String {
    var baseUrlString = ""
    switch Defaults.shared.releaseType {
    case .debug, .alpha:
        if isFastCamApp || isFastCamLiteApp {
            baseUrlString = "https://alpha.fastcam.app/terms-and-condition"
        } else if isSnapCamApp || isSnapCamLiteApp {
            baseUrlString = "https://alpha.snapcam.app/terms-and-condition"
        } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
            baseUrlString = "https://alpha.quickcam.app/terms-and-condition"
        } else if isSpeedCamApp || isSpeedCamLiteApp {
            baseUrlString = "https://alpha.speedcam.net/terms-and-condition"
        } else {
            baseUrlString = "https://alpha.snapcam.app/terms-and-condition"
        }
    case .beta:
        if isFastCamApp || isFastCamLiteApp {
            baseUrlString = "https://beta.fastcam.app/terms-and-condition"
        } else if isSnapCamApp || isSnapCamLiteApp {
            baseUrlString = "https://beta.snapcam.app/terms-and-condition"
        } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
            baseUrlString = "https://beta.quickcam.app/terms-and-condition"
        } else if isSpeedCamApp || isSpeedCamLiteApp {
            baseUrlString = "https://beta.speedcam.net/terms-and-condition"
        } else {
            baseUrlString = "https://beta.snapcam.app/terms-and-condition"
        }
    case .store:
        if isFastCamApp || isFastCamLiteApp {
            baseUrlString = "https://fastcam.app/terms-and-condition"
        } else if isSnapCamApp || isSnapCamLiteApp {
            baseUrlString = "https://snapcam.app/terms-and-condition"
        } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
            baseUrlString = "https://quickcam.app/terms-and-condition"
        } else if isSpeedCamApp || isSpeedCamLiteApp {
            baseUrlString = "https://speedcam.net/terms-and-condition"
        } else {
            baseUrlString = "https://snapcam.app/terms-and-condition"
        }
    }
    return baseUrlString
}

public var privacyPolicyUrl: String {
    var baseUrlString = ""
    switch Defaults.shared.releaseType {
    case .debug, .alpha:
        if isFastCamApp || isFastCamLiteApp {
            baseUrlString = "https://alpha.fastcam.app/privacy-policy"
        } else if isSnapCamApp || isSnapCamLiteApp {
            baseUrlString = "https://alpha.snapcam.app/privacy-policy"
        } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
            baseUrlString = "https://alpha.quickcam.app/privacy-policy"
        } else if isSpeedCamApp || isSpeedCamLiteApp {
            baseUrlString = "https://alpha.speedcam.net/privacy-policy"
        } else {
            baseUrlString = "https://alpha.snapcam.app/privacy-policy"
        }
    case .beta:
        if isFastCamApp || isFastCamLiteApp {
            baseUrlString = "https://beta.fastcam.app/privacy-policy"
        } else if isSnapCamApp || isSnapCamLiteApp {
            baseUrlString = "https://beta.snapcam.app/privacy-policy"
        } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
            baseUrlString = "https://beta.quickcam.app/privacy-policy"
        } else if isSpeedCamApp || isSpeedCamLiteApp {
            baseUrlString = "https://beta.speedcam.net/privacy-policy"
        } else {
            baseUrlString = "https://beta.snapcam.app/privacy-policy"
        }
    case .store:
        if isFastCamApp || isFastCamLiteApp {
            baseUrlString = "https://fastcam.app/privacy-policy"
        } else if isSnapCamApp || isSnapCamLiteApp {
            baseUrlString = "https://snapcam.app/privacy-policy"
        } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
            baseUrlString = "https://quickcam.app/privacy-policy"
        } else if isSpeedCamApp || isSpeedCamLiteApp {
            baseUrlString = "https://speedcam.net/privacy-policy"
        } else {
            baseUrlString = "https://snapcam.app/privacy-policy"
        }
    }
    return baseUrlString
}

public var websiteUrl: String {
    var baseUrlString = ""
    switch Defaults.shared.releaseType {
    case .debug, .alpha:
        if isFastCamApp || isFastCamLiteApp {
            baseUrlString = "https://alpha.fastcam.app"
        } else if isSnapCamApp || isSnapCamLiteApp {
            baseUrlString = "https://alpha.snapcam.app"
        } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
            baseUrlString = "https://alpha.quickcam.app"
        } else if isSpeedCamApp || isSpeedCamLiteApp {
            baseUrlString = "https://alpha.speedcam.net"
        } else {
            baseUrlString = "https://alpha.snapcam.app"
        }
    case .beta:
        if isFastCamApp || isFastCamLiteApp {
            baseUrlString = "https://beta.fastcam.app"
        } else if isSnapCamApp || isSnapCamLiteApp {
            baseUrlString = "https://beta.snapcam.app"
        } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
            baseUrlString = "https://beta.quickcam.app"
        } else if isSpeedCamApp || isSpeedCamLiteApp {
            baseUrlString = "https://beta.speedcam.net"
        } else {
            baseUrlString = "https://beta.snapcam.app"
        }
    case .store:
        if isFastCamApp || isFastCamLiteApp {
            baseUrlString = "https://fastcam.app"
        } else if isSnapCamApp || isSnapCamLiteApp {
            baseUrlString = "https://snapcam.app"
        } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
            baseUrlString = "https://quickcam.app"
        } else if isSpeedCamApp || isSpeedCamLiteApp {
            baseUrlString = "https://speedcam.net"
        } else {
            baseUrlString = "https://snapcam.app"
        }
    }
    return baseUrlString
}

public var userDashboardUrl: String {
    var baseUrlString = ""
    switch Defaults.shared.releaseType {
    case .debug, .alpha:
        if isFastCamApp || isFastCamLiteApp {
            baseUrlString = "https://alpha.react.fastcam.app"
        } else if isSnapCamApp || isSnapCamLiteApp {
            baseUrlString = "https://alpha.react.snapcam.app"
        } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
            baseUrlString = "https://alpha.react.quickcam.app"
        } else if isSpeedCamApp || isSpeedCamLiteApp {
            baseUrlString = "https://alpha.react.speedcam.net"
        } else {
            baseUrlString = "https://alpha.react.snapcam.app"
        }
    case .beta:
        if isFastCamApp || isFastCamLiteApp {
            baseUrlString = "https://beta.react.fastcam.app"
        } else if isSnapCamApp || isSnapCamLiteApp {
            baseUrlString = "https://beta.react.snapcam.app"
        } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
            baseUrlString = "https://beta.react.quickcam.app"
        } else if isSpeedCamApp || isSpeedCamLiteApp {
            baseUrlString = "https://beta.react.speedcam.net"
        } else {
            baseUrlString = "https://beta.react.snapcam.app"
        }
    case .store:
        if isFastCamApp || isFastCamLiteApp {
            baseUrlString = "https://react.fastcam.app"
        } else if isSnapCamApp || isSnapCamLiteApp {
            baseUrlString = "https://react.snapcam.app"
        } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
            baseUrlString = "https://react.quickcam.app"
        } else if isSpeedCamApp || isSpeedCamLiteApp {
            baseUrlString = "https://react.speedcam.net"
        } else {
            baseUrlString = "https://react.snapcam.app"
        }
    }
    return baseUrlString
}

public var businessCenterWebsiteUrl: String {
    var baseUrlString = ""
    switch Defaults.shared.releaseType {
    case .debug, .alpha:
        baseUrlString = "https://alpha.mybusinesscenter.app/"
    case .beta:
        baseUrlString = "https://alpha.mybusinesscenter.app/"
    case .store:
        baseUrlString = "https://mybusinesscenter.app/"
    }
    return baseUrlString
}

public var vidplayWebsiteUrl: String {
    var baseUrlString = ""
    switch Defaults.shared.releaseType {
    case .debug, .alpha:
        baseUrlString = "https://alpha.vidplay.cafe/"
    case .beta:
        baseUrlString = "https://alpha.vidplay.cafe/"
    case .store:
        baseUrlString = "https://vidplay.cafe/"
    }
    return baseUrlString
}

public var keycloakClientId: String {
    let baseUrl = "auth/realms/main/protocol/openid-connect/auth?client_id="
    let endUrl = "&response_mode=fragment&response_type=code&login=true&redirect_uri="
    var clientId = ""
    switch Defaults.shared.releaseType {
    case .debug, .alpha:
        if isFastCamApp || isFastCamLiteApp {
            clientId = "fastcam-alpha"
        } else if isSnapCamApp || isSnapCamLiteApp {
            clientId = "snapcam-alpha"
        } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
            clientId = "quickcam-alpha"
        } else if isSpeedCamApp || isSpeedCamLiteApp {
            clientId = "speedcam-alpha"
        } else {
            clientId = "snapcam-alpha"
        }
    case .beta:
        if isFastCamApp || isFastCamLiteApp {
            clientId = "fastcam-beta"
        } else if isSnapCamApp || isSnapCamLiteApp {
            clientId = "snapcam-beta"
        } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
            clientId = "quickcam-beta"
        } else if isSpeedCamApp || isSpeedCamLiteApp {
            clientId = "speedcam-beta"
        } else {
            clientId = "snapcam-beta"
        }
    case .store:
        if isFastCamApp || isFastCamLiteApp {
            clientId = "fastcam-prod"
        } else if isSnapCamApp || isSnapCamLiteApp {
            clientId = "snapcam-prod"
        } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
            clientId = "quickcam-prod"
        } else if isSpeedCamApp || isSpeedCamLiteApp {
            clientId = "speedcam-prod"
        } else {
            clientId = "snapcam-prod"
        }
    }
    return baseUrl + clientId + endUrl
}

public var keycloakRegistrationClientId: String {
    let baseUrl = "auth/realms/main/protocol/openid-connect/registrations?client_id="
    let endUrl = "&response_mode=fragment&response_type=code&redirect_uri="
    var clientId = ""
    switch Defaults.shared.releaseType {
    case .debug, .alpha:
        if isFastCamApp || isFastCamLiteApp {
            clientId = "fastcam-alpha"
        } else if isSnapCamApp || isSnapCamLiteApp {
            clientId = "snapcam-alpha"
        } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
            clientId = "quickcam-alpha"
        } else if isSpeedCamApp || isSpeedCamLiteApp {
            clientId = "speedcam-alpha"
        } else {
            clientId = "snapcam-alpha"
        }
    case .beta:
        if isFastCamApp || isFastCamLiteApp {
            clientId = "fastcam-beta"
        } else if isSnapCamApp || isSnapCamLiteApp {
            clientId = "snapcam-beta"
        } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
            clientId = "quickcam-beta"
        } else if isSpeedCamApp || isSpeedCamLiteApp {
            clientId = "speedcam-beta"
        } else {
            clientId = "snapcam-beta"
        }
    case .store:
        if isFastCamApp || isFastCamLiteApp {
            clientId = "fastcam-prod"
        } else if isSnapCamApp || isSnapCamLiteApp {
            clientId = "snapcam-prod"
        } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
            clientId = "quickcam-prod"
        } else if isSpeedCamApp || isSpeedCamLiteApp {
            clientId = "speedcam-prod"
        } else {
            clientId = "snapcam-prod"
        }
    }
    return baseUrl + clientId + endUrl
}

public var keycloakForogtPasswordClientId: String {
    let baseUrl = "auth/realms/main/protocol/openid-connect/forgot-credentials?client_id="
    let endUrl = "&response_mode=fragment&response_type=code&redirect_uri="
    var clientId = ""
    switch Defaults.shared.releaseType {
    case .debug, .alpha:
        if isFastCamApp || isFastCamLiteApp {
            clientId = "fastcam-alpha"
        } else if isSnapCamApp || isSnapCamLiteApp {
            clientId = "snapcam-alpha"
        } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
            clientId = "quickcam-alpha"
        } else if isSpeedCamApp || isSpeedCamLiteApp {
            clientId = "speedcam-alpha"
        } else {
            clientId = "snapcam-alpha"
        }
    case .beta:
        if isFastCamApp || isFastCamLiteApp {
            clientId = "fastcam-beta"
        } else if isSnapCamApp || isSnapCamLiteApp {
            clientId = "snapcam-beta"
        } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
            clientId = "quickcam-beta"
        } else if isSpeedCamApp || isSpeedCamLiteApp {
            clientId = "speedcam-beta"
        } else {
            clientId = "snapcam-beta"
        }
    case .store:
        if isFastCamApp || isFastCamLiteApp {
            clientId = "fastcam-prod"
        } else if isSnapCamApp || isSnapCamLiteApp {
            clientId = "snapcam-prod"
        } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
            clientId = "quickcam-prod"
        } else if isSpeedCamApp || isSpeedCamLiteApp {
            clientId = "speedcam-prod"
        } else {
            clientId = "snapcam-prod"
        }
    }
    return baseUrl + clientId + endUrl
}

public var keycloakUrl: String {
    var baseUrlString = ""
    switch Defaults.shared.releaseType {
    case .debug, .alpha:
        baseUrlString = "https://accounts.alpha.promanager.online/"
    case .beta:
        baseUrlString = "https://accounts.beta.promanager.online/"
    case .store:
        baseUrlString = "https://accounts.promanager.online/"
    }
    return baseUrlString
}

public var inAppConfig: String {
    var appSpecificSecretKey = ""
    switch Defaults.shared.releaseType {
    case .debug, .alpha, .beta:
        appSpecificSecretKey = "f95f3e130bd34017b82898245abea599"
    case .store:
        appSpecificSecretKey = "f95f3e130bd34017b82898245abea599"
    }
    return appSpecificSecretKey
}

public var redirectUri: String {
    let redirectUri = "quickcamrefer://app"
    return redirectUri
}

enum ReleaseType: String, AppMode_Enum {
    case debug
    case alpha
    case beta
    case store

    static func currentConfiguration() -> ReleaseType {
        if isDebug {
            return .debug
        } else if isAlpha {
            return .alpha
        } else if isBeta {
            return .beta
        } else if isStore {
            return .store
        } else {
            return .store
        }
    }
    
    var description: String {
        switch self {
        case .debug:
            return "debug"
        case .alpha:
            return "alpha"
        case .beta:
            return "beta"
        case .store:
            return "store"
        }
    }
}

enum GuidelineActiveColors: Int {
    case active1 = 1
    case active2
    case active3
    case active4
    case active5
    case active6
    case active7
    case active8
    
    func getTypeFromHexString(type: String) -> GuidelineActiveColors {
        switch type {
        case "#FFFFFF":
            return .active1
        case "#000000":
            return .active2
        case "#5E0000":
            return .active3
        case "#04C106":
            return .active4
        case "#4A90E2":
            return .active5
        case "#F7B500":
            return .active6
        case "#6F4AF5":
            return .active7
        case "#FF1BE3":
            return .active8
        default:
            return .active6
        }
    }
    
    var getColor: UIColor {
        switch self {
        case .active1:
            return R.color.active1()!
        case .active2:
            return R.color.active2()!
        case .active3:
            return R.color.active3()!
        case .active4:
            return R.color.active4()!
        case .active5:
            return R.color.active5()!
        case .active6:
            return R.color.active6()!
        case .active7:
            return R.color.active7()!
        case .active8:
            return R.color.active8()!
        }
    }
    
}

enum GuidelineInActiveColors: Int {
    case inActive1 = 1
    case inActive2
    case inActive3
    case inActive4
    case inActive5
    case inActive6
    case inActive7
    case inActive8
    
    func getTypeFromHexString(type: String) -> GuidelineInActiveColors {
        switch type {
        case "#FFFFFF":
            return .inActive1
        case "#000000":
            return .inActive2
        case "#5E0000":
            return .inActive3
        case "#04C106":
            return .inActive4
        case "#4A90E2":
            return .inActive5
        case "#F7B500":
            return .inActive6
        case "#6F4AF5":
            return .inActive7
        case "#FF1BE3":
            return .inActive8
        default:
            return .inActive6
        }
    }
    
    var getColor: UIColor {
        switch self {
        case .inActive1:
            return R.color.inActive1()!
        case .inActive2:
            return R.color.inActive2()!
        case .inActive3:
            return R.color.inActive3()!
        case .inActive4:
            return R.color.inActive4()!
        case .inActive5:
            return R.color.inActive5()!
        case .inActive6:
            return R.color.inActive6()!
        case .inActive7:
            return R.color.inActive7()!
        case .inActive8:
            return R.color.inActive8()!
        }
    }
    
}

enum AppMode: Int, AppMode_Enum {
    case free = 0
    case basic
    case advanced
    case professional
    
    func getTypeFromString(type: String) -> AppMode {
        switch type {
        case "pro":
            return .professional
        case "basic":
            return .basic
        case "advance":
            return .advanced
        default:
            return .free
        }
    }
    
    var getType: String {
        switch self {
        case .free:
            return "free"
        case .basic:
            return "basic"
        case .advanced:
            return "advance"
        case .professional:
            return "pro"
        }
    }
    
    var description: String {
        switch self {
        case .free:
            return "Free"
        case .basic:
            if isLiteApp {
                return "Basic"
            } else {
                return "Basic"
            }
        case .advanced:
            return "Advanced"
        case .professional:
            return "Pro"
        }
    }
    
    var price: String {
        switch self {
        case .free:
            return "$0/Month"
        case .basic:
            return "$1.99/Month"
        case .advanced:
            return "$99.99/Month"
        case .professional:
            return "$120.99/Month"
        }
    }
    
    var features: [String] {
        switch self {
        case .free:
            return ["Recording upto 3x speed",
                    "Segment length: Up to 15 seconds",
                    "Face detection",
                    "Flash on/off/auto"]
        case .basic:
            return ["Segment length customisation: Upto 30 seconds",
                    "Video countdown timer: Upto 60 seconds",
                    "Slow motion recording upto -3x speed",
                    "Fast motion recording upto 3x speed",
                    "Face detection",
                    "Flash on/off/auto"]
        case .advanced:
            return ["Features to be decided"]
        case .professional:
            return ["Features to be decided"]
        }
    }
}

enum ShapeType: Int {
    case heart
    case hexa
    case star
}

enum SocialShare: Int {
    case facebook = 0
    case twitter
    case instagram
    case snapchat
    case youtube
    case tiktok
    case storiCam
    case storiCamPost
}

enum SocialLogin: Int, CaseIterable {
    case facebook = 0
    case twitter
    case instagram
    case snapchat
    case youtube
    case storiCam
    case apple
    static let allValues = [facebook, twitter, instagram, snapchat, youtube, storiCam, apple]
}

public enum CameraMode: Int {
    case normal = 0
    case basicCamera
    case boomerang
    case slideshow
    case collage
    case handsfree
    case custom
    case capture
    case fastMotion
    case fastSlowMotion
    case timer
    case photoTimer
    case quizImage
    case quizVideo
    case multiplePhotos
    case promo
    case pic2Art
}

public enum RecordingType {
    case boom
    case video
    case image
    case rewind
    case handFree
    case timer
    case photoTimer
    case stopMotion
    case custom
    case slideShow
    case collage
    case quizImage
    case quizVideo
    case multiplePhotos
    case customImageVideoSave
}

enum SearchListType: Int {
    case hashSearch
    case locationSeacrh
}

enum BrowserType: Int {
    case following = 1
    case trending = 2
    case featured = 7
    case media = 4
    case family = 5
    case custom = 6
    case favourite = 3
}

enum ChannelsType: Int {
    case channels = 1
    case packages = 2
}

enum RequestStatus: Int {
    case pending = 0
    case accept = 1
    case reject = 2
}

enum PostTypes: String {
    case text = "text"
    case image = "image"
    case video = "video"
    case postwall = "postwall"
    case shared = "Shared"
    case youtube = "youtube"
    case location = "Location"
}

enum FileExtension: String {
    case jpg = ".jpg"
    case png = ".png"
    case mov = ".mov"
    case mp4 = ".mp4"
}

enum OpeningScreen: Int {
    case camera = 0
    case dashboard
    case chat
}

enum GuidelineTypes: Int {
    case solidLine = 1
    case dottedLine
    case dashedLine
}

enum GuidelineThickness: Int {
    case small = 1
    case medium = 3
    case thick = 5
}

enum FastestEverWatermarkSetting: Int {
    case show = 1
    case hide
}

enum AppIdentifierWatermarkSetting: Int {
    case show = 1
    case hide
}

enum MadeWithGifSetting: Int {
    case show = 1
    case hide
}

enum VideoResolution: Int {
    case low = 1
    case high
}

enum NewSignupsNotificationType: Int {
    case forAllUsers = 1
    case forLimitedUsers
}

enum NewSubscriptionNotificationType: Int {
    case forAllUsers = 1
    case forLimitedUsers
}

public enum ImageFormat {
    case PNG
    case JPEG(Float)
}

enum ProfilePicType: Int {
    case imageType = 1
    case videoType = 2
}

/// IAP modes
enum IAPMode: String {
    case production
    case sandbox
    
    func getStringValue() -> String {
        return self.rawValue
    }
}

public struct ResponseType {
    static let success = "success"
}

public struct Messages {
    static let kOK = "OK"
    static let kEmptyAlbumName = "Please enter gallery name."
    static let kundefineError = "Something went wrong! Please try again later"
    static let kSelectFrnd = "Please select atleast one friend."
    static let kNotLoginMsg = "User is not login. Please login to SocialCam and try again later."
}

public struct FetchDataBefore {
    static let bottomMargin: CGFloat = 900.0
}

public struct Reactions {
    static let reactionLIKE = "like"
    static let reactionLOVE = "love"
    static let reactionLAUGH = "laugh"
    static let reactionWOW = "wow"
    static let reactionSAD = "sad"
    static let reactionANGRY = "angry"
}

struct DeepLinkData {
    static let vidplayDeepLinkUrlString = "vidplay://splash/"
    static let deepLinkUrlString = "businesscenter://splash/"
    static var appDeeplinkName: String {
        if isTimeSpeedApp {
            return "TimeSpeed"
        } else if isSoccerCamApp {
            return "SoccerCam"
        } else if isSnapCamApp || isSnapCamLiteApp {
            return "SnapCam"
        } else if isFutbolCamApp {
            return "FutbolCam"
        } else if isBoomiCamApp {
            return "BoomiCam"
        } else if isPic2ArtApp {
            return "Pic2Art"
        } else if isViralCamApp || isViralCamLiteApp {
            return "ViralCam"
        } else if isSpeedCamApp || isSpeedCamLiteApp {
            return "SpeedCam"
        } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
            return "QuickCam"
        } else if isFastCamApp || isFastCamLiteApp {
            return "FastCam"
        } else {
            return "SocialCam"
        }
    }
}

struct KeycloakRedirectLink {
    static let endUrl = "://app"
    static var keycloakRedirectLinkName: String {
        if isTimeSpeedApp {
            return "TimeSpeed"
        } else if isSoccerCamApp {
            return "SoccerCam"
        } else if isSnapCamApp {
            return "SnapCam"
        } else if  isSnapCamLiteApp {
            return "SnapCamLite"
        } else if isFutbolCamApp {
            return "FutbolCam"
        } else if isBoomiCamApp {
            return "BoomiCam"
        } else if isPic2ArtApp {
            return "Pic2Art"
        } else if isViralCamApp {
            return "ViralCam"
        } else if isViralCamLiteApp {
            return "ViralCamLite"
        }   else if isSpeedCamApp {
            return "SpeedCam"
        } else if isSpeedCamLiteApp {
            return "SpeedCamLite"
        } else if isQuickCamApp {
            return "QuickCam"
        } else if isQuickCamLiteApp || isQuickApp {
            return "QuickCamLite"
        } else if isFastCamApp {
            return "FastCam"
        } else if isFastCamLiteApp {
            return "FastCamLite"
        } else {
            return "SocialCam"
        }
    }
}

struct TrimError: Error {
    let description: String
    let underlyingError: Error?
    
    init(_ description: String, underlyingError: Error? = nil) {
        self.description = "TrimVideo: " + description
        self.underlyingError = underlyingError
    }
}

public struct Paths {
    static let getViralvids = "viralvids"
    static let getSplashImages = "getSplashImages"
    static let login = "auth/signin"
    static let verifyChannel = "auth/verifyField"
    static let signUp = "auth/signupEmail"
    static let search = "auth/searchChannels"
    static let getCategories = "auth/getCategories"
    static let updateProfile = "users/updateProfile"
    static let connectSocial = "users/addSocialConnection"
    static let removeSocialConnection = "users/removeSocialConnection"
    static let searchUser = "users/searchChannel"
    static let topSearch = "users/topSearch"
    static let socailLogin = "auth/signup"
    static let getProfile = "users/getProfile"
    static let getProfileByName = "users/getProfileByChannel"
    static let getPlaceHolder = "auth/getPlaceHolder"
    static let newUserAdded = "new-user-added"
    static let setChannel = "set-channel"
    static let confirmEmail = "confirm-email"
    static let socialPost = "social-post"
    static let doLogin = "do-login"
    static let getuser = "get-user"
    static let followChannel = "follow/followChannel"
    static let unfollowChannel = "follow/unfollowChannel"
    static let getDashboardPosts = "articles/getPosts"
    static let getPostComments = "articles/getComments"
    static let getPostComment = "articles/getCommentDetail"
    static let getCommentReplies = "articles/getReplies"
    static let addReply = "articles/addReply"
    static let writePost = "articles/write"
    static let addComment = "articles/addComment"
    static let likePost = "articles/likePost"
    static let disLikePost = "articles/disLikePost"
    static let getConfiguration = "admin/getConfigurations"
    static let likeComment = "articles/likeComment"
    static let disLikeComment = "articles/disLikeComment"
    static let likeReply = "articles/likeReply"
    static let disLikeReply = "articles/disLikeReply"
    static let getAlbums = "albums/getAlbums"
    static let createAlbum = "albums/createAlbum"
    static let getMyPost = "articles/getWritten"
    static let getMyYoutubePost = "articles/getMyYoutubePost"
    static let blockUser = "users/blockUser"
    static let getBlockedUser = "users/blockedUsers"
    static let repotPost = "articles/blockPost"
    static let deletePost = "articles/"
    static let getFriends = "users/getFriends"
    static let updateAlbum = "albums/"
    static let tagUserSearch = "users/searchChannelIds"
    static let getFollowers = "follow/getFollowers"
    static let getFollowings = "follow/getFollowing"
    static let searchHash = "users/searchTags"
    static let getHashPost = "articles/searchTags"
    static let getLocationPost = "articles/searchLocations"
    static let getHashStories = "stories/searchTags"
    static let getLocationStories = "stories/searchStoryLocation"
    static let shreInAppPost = "articles/share/"
    static let youTubeKeyWordSerch = "search"
    static let youTubeDetail = "videos"
    static let youTubechannels = "channels"
    static let youTubeChannelSearch = "search"
    static let youTubeRatting = "videos/rate"
    static let getStories = "stories/getStories"
    static let getOwnStory = "storyByUser"
    static let getEmojis = "getFeelings"
    static let createStory = "stories/createStory"
    static let getFollowingNotification = "users/getFollowerNotifications"
    static let getYouNotification = "users/getNotifications"
    static let getMediaStories = "stories/getMediaStories"
    static let verifyUserAccount = "users/verifyUserAccount"
    static let resendVerificationLink = "auth/resendVerificationLink"
    static let storyByUser = "/api/storyByUser"
    static let deleteComment = "articles/deleteComment"
    static let deleteReply = "articles/deleteReply"
    static let getPostDetail = "articles/"
    static let logOut = "users/logout"
    static let updatePost = "articles/"
    static let getStoryFavoriteList = "stories/favoriteList"
    static let getChannelSuggestion = "channelSuggestion"
    static let addToCart = "users/addToCart"
    static let getCart = "users/getCart"
    static let deleteFromCart = "users/deleteFromCart"
    static let getChannelList = "users/getChannelLists"
    static let addPayment = "users/addPayment"
    static let checkChannelExists = "users/checkChannelExists"
    static let addAsFavorite = "articles/addAsFavorite"
    static let getFavoriteList = "articles/favoriteList"
    static let addHashTag = "hashtags"
    static let increaseHashtagCount = "hashtags/increaseHashtagCount"
    static let getPackage = "users/getPackage"
    static let addPackage = "users/addPackage"
    static let getStoryByID = "stories"
    static let createPlaylist = "playlists"
    static let getPlaylist = "playlists"
    static let addToPlaylist = "addToPlaylist"
    static let getHashTagDetail = "articles/getHashTagDetail"
    static let followHashTag = "articles/followHashtag"
    static let getPlaylistStory = "getPlaylist"
    static let deletePlaylist = "playlists/"
    static let deletePlaylistItem = "deletePlaylistItem"
    static let getFollowedHashPostStory = "hashtags/getFollowedPostStory"
    static let copyPlayList = "copyPlayList"
    static let getPlayListInfo = "playlists/"
    static let followPlaylist = "followPlaylist"
    static let likePlaylist = "likeplaylist"
    static let getPlayListComments = "playlists/getComments"
    static let addPlayListComment = "playlists/addComment"
    static let deletePlaylistComment = "playlists/deleteComment"
    static let likePlayListComment = "playlists/likeComment"
    static let reArrangePlaylist = "reArrangePlaylist"
    static let deleteStories = "stories/deleteStories"
    static let getTaggedStories = "tags/getStories"
    static let getTaggedFeed = "tags/getPosts"
    static let getRelationsData = "families/getMasterRelationData"
    static let addFamilyMember = "families"
    static let getFamilyMember = "getFamilyMemberList"
    static let acceptRejectFamilyRequest = "updateFamilyRequest"
    static let getFamilyStories = "families/getStories"
    static let getFamilyFeed = "families/getPosts"
    static let addAsVip = "users/addAsVip"
    static let getVipList = "users/getVipList"
    static let getVipUserPostList = "users/getVipUserPostList"
    static let getVipUserStoryList = "users/getVipUserStoryList"
    static let youtubeChannelSubscribe = "subscriptions?part=snippet"
    static let getyoutubeSubscribedChannel = "subscriptions?part=snippet"
    static let unsubscribeYoutubeChannel = "subscriptions"
    static let reportUser = "users/reportUser"
    static let createQuiz = "quizzes"
    static let updateQuiz = "quizzes/"
    static let addQuizQuestionAnswer = "quizzes/addQuestionAnswer"
    static let getQuizAnswerList = "quizzes/getAnswerList"
    static let getQuizList = "quizzes/getQuizList"
    static let getQuizQuestionList = "quizzes/getAnswerList"
    static let addQuizAnswer = "quizzes/addQuizAnswer"
    static let getYoutubeCategoty = "videoCategories"
    static let uploadYoutubeVideo = "videos?part=snippet&status"
    static let deleteQuiz = "quizzes/"
    static let addAnswers = "quizzes/addAnswer"
    static let moveStoryIntoChannel = "stories/addToOtherChannel"
    static let pushOnDownload = "stories/pushOnDownload"
    static let storieLike = "stories/like"
    static let getCommentsStory = "getComments"
    static let getCalculatorConfig = "calcConfig"
    static let getWebsiteData = "faq/website"
    static let setSubsctiption = "users/buySubscription"
    static let forgotPassword = "user/forgetPassword"
    static let getUserProfile = "user/profile"
    static let userSettings = "user/settings"
    static let loginWithKeycloak = "user/login"
    static let logoutWithKeycloak = "user/logout"
    static let addReferral = "user/addReferral"
    static let buySubscription = "subscription/buySubscription"
    static let subsciptionList = "subscriptions"
    static let userSync = "user/userSync"
    static let downgradeSubscription = "subscription/downgrade"
    static let getToken = "user/getToken"
    static let createUser = "user/createUser"
    static let userDelete = "user/deactive"
    static let updateUserProfile = "user/updateProfile"
    static let getReferredUsersList = "user/referees"
    static let setAffiliate = "user/setAffiliate"
    static let doNotShowAgain = "user/setFlag"
    static let addSocialPlatforms = "user/addSocialPlatforms"
    static let setToken = "device/setToken"
    static let removeToken = "device/removeToken"
    static let getReferralNotification = "user/getReferralNotification"
    static let setReferralNotification = "user/setReferralNotification"
    static let setUserStateFlag = "user/setUserStateFlag"
    static let setUserStates = "user/setUserStates"
}

struct WebsiteData {
    static var websiteName: String {
        if isTimeSpeedApp {
            return "TimeSpeed"
        } else if isSoccerCamApp {
            return "SoccerCam"
        } else if isSnapCamApp || isSnapCamLiteApp {
            return "SnapCam"
        } else if isFutbolCamApp {
            return "FutbolCam"
        } else if isBoomiCamApp {
            return "BoomiCam"
        } else if isPic2ArtApp {
            return "Pic2Art"
        } else if isViralCamApp || isViralCamLiteApp {
            return "ViralCam"
        } else if isSpeedCamApp || isSpeedCamLiteApp {
            return "SpeedCam"
        } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
            return "QuickCam"
        } else if isFastCamApp || isFastCamLiteApp {
            return "FastCam"
        } else {
            return "SocialCam"
        }
    }
}

public struct APIHeaders {
    
    let headerWithToken =  ["Content-Type": "application/json",
                                   "userid": Defaults.shared.currentUser?.id ?? "",
                                   "deviceType": "1",
                                   "x-access-token": Defaults.shared.sessionToken ?? "" ]
    let headerWithoutAccessToken = ["Content-Type": "application/json",
                                           "deviceType": "1"]
}

class API {
    static let shared = API()
    var baseUrl: String {
        get {
            var baseUrlString = ""
            switch Defaults.shared.releaseType {
            case .debug, .alpha:
                if isFastCamApp || isFastCamLiteApp {
                    baseUrlString = "https://api.alpha.fastcam.app/api/"
                } else if isSnapCamApp || isSnapCamLiteApp {
                    baseUrlString = "https://api.alpha.snapcam.app/api/"
                } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
                    baseUrlString = "https://api.alpha.quickcam.app/api/"
                } else if isSpeedCamApp || isSpeedCamLiteApp {
                    baseUrlString = "https://api.alpha.speedcam.net/api/"
                } else {
                    baseUrlString = "https://demo-api.austinconversionoptimization.com/api/"
                }
            case .beta:
                if isFastCamApp || isFastCamLiteApp {
                    baseUrlString = "https://api.beta.fastcam.app/api/"
                } else if isSnapCamApp || isSnapCamLiteApp {
                    baseUrlString = "https://api.beta.snapcam.app/api/"
                } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
                    baseUrlString = "https://api.beta.quickcam.app/api/"
                } else if isSpeedCamApp || isSpeedCamLiteApp {
                    baseUrlString = "https://api.beta.speedcam.net/api/"
                } else {
                    baseUrlString = "https://demo-api.austinconversionoptimization.com/api/"
                }
            case .store:
                if isFastCamApp || isFastCamLiteApp {
                    baseUrlString = "https://api.fastcam.app/api/"
                } else if isSnapCamApp || isSnapCamLiteApp {
                    baseUrlString = "https://api.snapcam.app/api/"
                } else if isQuickCamApp || isQuickCamLiteApp || isQuickApp {
                    baseUrlString = "https://api.quickcam.app/api/"
                } else if isSpeedCamApp || isSpeedCamLiteApp {
                    baseUrlString = "https://api.speedcam.net/api/"
                } else {
                    baseUrlString = "https://demo-api.austinconversionoptimization.com/api/"
                }
            }
            return baseUrlString
        } set { }
    }
}

class StoryTagGradientLayer: CAGradientLayer { }
#if !IS_SHAREPOST && !IS_MEDIASHARE && !IS_VIRALVIDS && !IS_SOCIALVIDS && !IS_PIC2ARTSHARE
class BaseQuestionTagView: BaseStoryTagView { }
#endif

// MARK: - Control
public enum Control {
    case crop
    case sticker
    case draw
    case text
    case save
    case share
    case clear
}

enum SlideShowExportType {
    case outtakes
    case notes
    case chat
    case feed
    case story
    case sendChat
}

#if !IS_SHAREPOST && !IS_MEDIASHARE && !IS_VIRALVIDS  && !IS_SOCIALVIDS && !IS_PIC2ARTSHARE
enum StoriCamType: Equatable {
    case story
    case chat
    case feed
    case shareYoutube(postData: CreatePostData)
    case shareFeed(postID: String)
    case shareStory(storyID: String)
    case sharePlaylist(playlist: GetPlaylist)
    
    case replyStory(question: String, answer: String)
    
    static func == (lhs: StoriCamType, rhs: StoriCamType) -> Bool {
        switch (lhs, rhs) {
        case (.story, .story), (.chat, .chat), (.feed, .feed):
            return true
        case (.shareYoutube, .shareYoutube):
            return true
        case (let .shareFeed(lhsPostID), let .shareFeed(rhsPostID)):
            return (lhsPostID == rhsPostID)
        case (let .shareStory(lhsStoryID), let .shareStory(rhsStoryID)):
            return (lhsStoryID == rhsStoryID)
        case (let .sharePlaylist(lhsPlaylist), let .sharePlaylist(rhsPlaylist)):
            if let lhsPlayListId = lhsPlaylist.id,
                let rhsPlayListId = rhsPlaylist.id {
                return lhsPlayListId == rhsPlayListId
            } else {
                return false
            }
        case (.replyStory, .replyStory):
            return true
        default:
            return false
        }
    }
}
#endif

enum StorySelectionType {
    case image(image: UIImage)
    case video(fileURL: URL)
    case error(error: Error)
}

enum CalculatorType: String {
    case potentialFollowers = "potential_followers"
    case incomeOne = "potential_income_1"
    case incomeTwo = "potential_income_2"
    case incomeThree = "potential_income_3"
    case incomeFour = "potential_income_4"
    case liteIncomeOne = "lite_income_1"
    case liteIncomeTwo = "lite_income_2"
    case liteIncomeThree = "lite_income_3"
    case liteIncomeFour = "lite_income_4"
    
    func getNavigationTitle() -> String {
        switch self {
        case .potentialFollowers:
            return "Potential Followers"
        case .incomeOne:
            return "Potential Income Calculator 1"
        case .incomeTwo:
            return "Potential Income Calculator 2"
        case .incomeThree:
            return "Potential Income Calculator 3"
        case .incomeFour:
            return "Potential Income Calculator 4"
        case .liteIncomeOne:
            return "Lite Potential Income Calculator 1"
        case .liteIncomeTwo:
            return "Lite Potential Income Calculator 2"
        case .liteIncomeThree:
            return "Lite Potential Income Calculator 3"
        case .liteIncomeFour:
            return "Lite Potential Income Calculator 4"
        }
    }
}

enum VideoSpeedType: Equatable {
    
    static func ==(lhs: VideoSpeedType, rhs: VideoSpeedType) -> Bool {
        switch (lhs, rhs) {
        case (VideoSpeedType.normal, VideoSpeedType.normal):
            return true
        case (VideoSpeedType.slow(let scaleFactor), VideoSpeedType.slow(let scaleFactor2)):
            if scaleFactor == scaleFactor2 {
                return true
            }
            return false
        case (VideoSpeedType.fast(let scaleFactor), VideoSpeedType.fast(let scaleFactor2)):
            if scaleFactor == scaleFactor2 {
                return true
            }
            return false
        default: return false
        }
    }
    
    case normal
    case slow(scaleFactor: Float)
    case fast(scaleFactor: Float)
}

enum StoryType: String {
    case image = "image"
    case video = "video"
}

enum StoriType: Int {
    case `default` = 0
    case collage
    case slideShow
    case review
    case gif
    case meme
    case shared
}

enum PublishMode: Int {
    case publish = 1
    case unPublish = 0
}

enum TimerType: Int {
    case timer = 1
    case segmentLength
    case pauseTimer
    case photoTimer
}

enum StoryTagState: Int {
    case white = 0
    case blur
    case whiteAlpha
}

enum StoryTagType: Int {
    case hashtag = 0
    case mension
    case location
    case youtube
    case feed
    case story
    case playlist
    case link
    case slider
    case poll
    case askQuestion
}

enum CollectionMode {
    case effect
    case style
}

enum ProMediaType {
    case image
    case video
    case images
}

enum CurrentMode: Int {
    case frames
    case photos
    case border
    case space
    case background
}

protocol CollageMakerVCDelegate: class {
    func didSelectImage(image: UIImage)
}

class EffectData {
    var name: String
    var image: UIImage
    var path: String

    init(name: String, image: UIImage, path: String) {
        self.name = name
        self.image = image
        self.path = path
    }
}

class SelectedTimer: Codable, SaveUserDefaultsProtocol {
    
    var value: String = ""
    var selectedRow: Int = 0
    
    init(value: String, selectedRow: Int) {
        self.value = value
        self.selectedRow = selectedRow
    }
    
}

class StyleData {
    var name: String
    var image: UIImage
    var styleImage: UIImage?
    var isSelected = false
    
    init(name: String, image: UIImage, styleImage: UIImage?) {
        self.name = name
        self.image = image
        self.styleImage = styleImage
    }
    
    static var data: [StyleData] {
        var styleData: [StyleData] = []
        for index in 0...43 {
            styleData.append(StyleData(name: "", image: UIImage(named: "styletransfer_\(index)")!, styleImage: nil))
        }
        return styleData
    }
    
}

protocol OuttakesTakenDelegate: class {
    func didTakeOuttakes(_ message: String)
}

protocol StorySelectionDelegate: class {
    func didSelectStoryWith(_ type: StorySelectionType)
    func didSelectFeedMedia(medias: [FilterImage])
}

extension StorySelectionDelegate {
    func didSelectFeedMedia(medias: [FilterImage]) { }
    func didSelectStoryWith(_ type: StorySelectionType) { }
}

protocol ShowReactionAlert: class {
    func showAlert()
}

class TrasparentTagView: UIView { }
