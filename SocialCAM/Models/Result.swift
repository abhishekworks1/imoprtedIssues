//
//  LoginResponse.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 17/05/17.
//  Copyright © 2017 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import ObjectMapper

class Result<T: Mappable>: Mappable {
    var sessionToken: String?
    var result: T?
    var status: String?
    var message: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        result <- map["result"]
        sessionToken <- map["token"]
        status <- map["status"]
        message <- map["message"]
    }
}

class ResultArray<T: Mappable>: Mappable {
    var sessionToken: String?
    var result: [T]?
    var status: String?
    var message: String?
    var pageFlag: String?
    var resultCount: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        result <- map["result"]
        sessionToken <- map["token"]
        status <- map["status"]
        message <- map["message"]
        pageFlag <- map["page_flag"]
        resultCount <- map["result_count"]
        if resultCount == nil {
             resultCount <- map["resultCounts"]
        }
        if resultCount == nil {
             resultCount <- map["count"]
        }
    }
}

class ChannelSuggestionResult: Mappable {
    var status : String?
    var message : String?
    var suggestionList : [String]?
    var existsChannel : [String]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        message <- map["message"]
        status <- map["status"]
        suggestionList <- map["suggestionList"]
        existsChannel <- map["existsChannel"]
    }
}

class UserSettingsResult: Mappable {
    
    var userSettings: UserSettings?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        userSettings <- map["userSettings"]
    }
    
}

class UserSettings: Mappable {
    
    var appWatermark: Int?
    var faceDetection: Bool?
    var fastesteverWatermark: Int?
    var guidelineActiveColor: String?
    var guidelineInActiveColor: String?
    var guidelineThickness: Int?
    var guidelineTypes: Int?
    var guidelinesShow: Bool?
    var iconPosition: Bool?
    var supportedFrameRates: [String]?
    var videoResolution: Int?
    var watermarkOpacity: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        appWatermark <- map["appWatermark"]
        faceDetection <- map["faceDetection"]
        fastesteverWatermark <- map["fastesteverWatermark"]
        guidelineActiveColor <- map["guidelineActiveColor"]
        guidelineInActiveColor <- map["guidelineInActiveColor"]
        guidelineThickness <- map["guidelineThickness"]
        guidelineTypes <- map["guidelineTypes"]
        guidelinesShow <- map["guidelinesShow"]
        iconPosition <- map["iconPosition"]
        supportedFrameRates <- map["supportedFrameRates"]
        videoResolution <- map["videoResolution"]
        watermarkOpacity <- map["watermarkOpacity"]
    }
    
}
