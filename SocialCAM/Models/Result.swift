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

class EmptyModel: Mappable {
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
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

class LoginResult: Mappable{
    
    var isRegistered: Bool?
    var user: User?
    var diffDays: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        isRegistered <- map["isRegistered"]
        user <- map["user"]
        diffDays <- map["diffDays"]
    }
    
}

class SubscriptionList: Mappable {
    
    var subscriptions: [Subscription]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        subscriptions <- map["subscriptions"]
    }
    
}

class Subscription: Mappable {
    
    var v: Int?
    var id: String?
    var createdAt: String?
    var cycle: String?
    var descriptionField: String?
    var name: String?
    var price: Int?
    var productId: String?
    var updatedAt: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        v <- map["__v"]
        id <- map["_id"]
        createdAt <- map["createdAt"]
        cycle <- map["cycle"]
        descriptionField <- map["description"]
        name <- map["name"]
        price <- map["price"]
        productId <- map["productId"]
        updatedAt <- map["updatedAt"]
    }
    
}

class BuySubscriptionResponseModel: Mappable {
    
    var userSubscriptionId: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        userSubscriptionId <- map["userSubscriptionId"]
    }
    
}

class UserSyncModel: Mappable{
    
    var diffDays: Int?
    var user: User?
    var userSubscription: UserSubscription?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        diffDays <- map["diffDays"]
        user <- map["user"]
        userSubscription <- map["userSubscription"]
    }
    
}

class UserSubscription: Mappable{
    
    var v: Int?
    var id: String?
    var amount: Int?
    var createdAt: String?
    var endDate: String?
    var inAppMode: String?
    var inAppResponse: String?
    var isDowngraded: Bool?
    var isRenewable: Bool?
    var platformType: String?
    var startDate: String?
    var subscription: Subscription?
    var subscriptionId: String?
    var updatedAt: String?
    var userId: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        v <- map["__v"]
        id <- map["_id"]
        amount <- map["amount"]
        createdAt <- map["createdAt"]
        endDate <- map["endDate"]
        inAppMode <- map["inAppMode"]
        inAppResponse <- map["inAppResponse"]
        isDowngraded <- map["isDowngraded"]
        isRenewable <- map["isRenewable"]
        platformType <- map["platformType"]
        startDate <- map["startDate"]
        subscription <- map["subscription"]
        subscriptionId <- map["subscriptionId"]
        updatedAt <- map["updatedAt"]
        userId <- map["userId"]
    }
    
}
