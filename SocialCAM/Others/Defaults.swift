//
//  Defaults.swift
//  ProManager
//
//  Created by Jasmin Patel on 21/08/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import CoreLocation

class Defaults {
    
    static let shared = Defaults()
    
    let appDefaults = UserDefaults(suiteName: Constant.Application.groupIdentifier)
    
    var isMultiPhotoLayout: Bool? {
        get {
            return appDefaults?.bool(forKey: "isMultiPhotoLayout")
        }
        set {
            appDefaults?.set(newValue, forKey: "isMultiPhotoLayout")
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
    
    var currentUser: User? {
        get {
            if let loggedUser = appDefaults?.object(forKey: "loggedUser") as? Data {
                let decoder = JSONDecoder()
                return try? decoder.decode(User.self, from: loggedUser)
            }
            return nil
        }
        set {
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
            return appDefaults?.integer(forKey: "flashMode")
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
            return appDefaults?.bool(forKey: "isMicOn") as? Bool
        }
        set {
            appDefaults?.set(newValue, forKey: "isMicOn")
        }
    }
    
    var currentLocation: CLLocation? {
        get {
            let decodedValue = appDefaults?.object(forKey: "currentLocation") as? Data
            if let value = decodedValue {
                let decodedCurrentLocation = NSKeyedUnarchiver.unarchiveObject(with: value) as? CLLocation
                return decodedCurrentLocation
            }
            return nil
        }
        set {
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: newValue as Any)
            appDefaults?.set(encodedData, forKey: "currentLocation")
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
            return AppMode(rawValue: (appDefaults?.integer(forKey: "appMode") ?? 0)) ?? .free
        }
        set {
            appDefaults?.set(newValue.rawValue, forKey: "appMode")
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
    
    func clearData() {
        if let appDefaultsDictionary = appDefaults?.dictionaryRepresentation() {
            appDefaultsDictionary.keys.forEach { key in
                appDefaults?.removeObject(forKey: key)
            }
        }
        if let appDefaultsDictionary = appDefaults?.dictionaryRepresentation() {
            appDefaultsDictionary.keys.forEach { key in
                appDefaults?.removeObject(forKey: key)
            }
        }
    }
    
}
