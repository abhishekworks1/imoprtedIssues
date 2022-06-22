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
    var price: Double?
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
    var allowFullAccess: Bool?
    var subscriptionType : String?
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
        allowFullAccess <- map["allowFullAccess"]
        subscriptionType <- map["subscriptionType"]
    }
    
}

class GetTokenModel: Mappable {
    
    var data: UserTokenData?
    var hasAnyError: Bool?
    var isAccountFound: Bool?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        data <- map["data"]
        hasAnyError <- map["hasAnyError"]
        isAccountFound <- map["isAccountFound"]
    }
    
}

class ForceUpdateModel: Mappable {

    var forceUpdate: Bool?
    var updateApp: Bool?

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        forceUpdate <- map["forceUpdate"]
        updateApp <- map["updateApp"]
    }

}
class msgTitleList: Codable {
    var message: String?
    var success: Bool?
    var list : [Titletext]
    private enum CodingKeys: String, CodingKey
    {
        case message
        case success
        case list = "data"
    }
}
public struct Titletext: Codable {
    var id: String?
    var content: String?
    var subject: String?
    var type: String?
   private enum CodingKeys: String, CodingKey
    {
        case id = "_id"
        case content = "content"
        case subject = "subject"
        case type = "type"
    }
}

class UserTokenData: Mappable {
    
    var token: String?
    var user: UserTokenModel?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        token <- map["token"]
        user <- map["user"]
    }
    
}

class UserTokenModel: Mappable{

    var id: String?
    var bannerImageURL: String?
    var channelId: String?
    var channelName: String?
    var displayName: String?
    var email: String?
    var firstName: String?
    var lastName: String?
    var profileImageURL: String?
    var profileThumbnail: String?
    var provider: String?
    var referralCode: String?
    var subscriptionStatus: String?
    var username: String?

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        id <- map["_id"]
        bannerImageURL <- map["bannerImageURL"]
        channelId <- map["channelId"]
        channelName <- map["channelName"]
        displayName <- map["displayName"]
        email <- map["email"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        profileImageURL <- map["profileImageURL"]
        profileThumbnail <- map["profileThumbnail"]
        provider <- map["provider"]
        referralCode <- map["referralCode"]
        subscriptionStatus <- map["subscriptionStatus"]
        username <- map["username"]
    }

}

class SetAffiliateModel: Mappable {
    
    var isAllowAffiliate: Bool?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        isAllowAffiliate <- map["isAllowAffiliate"]
    }
}
class ContactResponse: Mappable {

    var Id: String?
    var mobile: String?
    var name: String?
    var email: String?
    var emailLink: String?
    var emailCount: NSNumber?
    var textLink: String?
    var textCount: NSNumber?
    var trackReferral: Bool?
    var status: String?
    var emailOptedOut: Bool?
    var hide: Bool?
    var profileImage: String?
    var registeredUserDetails: RegisteredUserDetails?
    var subscriptionStatus: String?
    var registeredUser: String?

    required init?(map: Map){
    }

    func mapping(map: Map) {
        Id <- map["_id"]
        mobile <- map["mobile"]
        email <- map["email"]
        name <- map["name"]
        profileImage <- map["profileImage"]
        emailLink <- map["emailLink"]
        emailCount <- map["emailCount"]
        textLink <- map["textLink"]
        textCount <- map["textCount"]
        trackReferral <- map["trackReferral"]
        status <- map["status"]
        emailOptedOut <- map["emailOptedOut"]
        hide <- map["hide"]
        registeredUserDetails <- map["registeredUserDetails"]
        subscriptionStatus <- map["subscriptionStatus"]
        registeredUser <- map["registeredUser"]
       
        
    }
}
class RegisteredUserDetails: Mappable {

    var firstName: String?
    var lastName: String?
    var publicDisplayName: String?
    var channelName: String?
    var username: String?
    var channelId: String?
    var displayName: String?
    var refferal: Int?
    var susbscribers: Int?
    var badges: [ParentBadges]?

    required init?(map: Map){
    }

    func mapping(map: Map) {
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        publicDisplayName <- map["publicDisplayName"]
        channelName <- map["channelName"]
        username <- map["username"]
        channelId <- map["channelId"]
        displayName <- map["displayName"]
        refferal <- map["refferal"]
        susbscribers <- map["susbscribers"]
        badges <- map["badges"]
    }
}


class NotificationCountResult: Codable {
    var message: String?
    var success: Bool?
    var data : NotificationCountData?
    private enum CodingKeys: String, CodingKey
    {
        case message
        case success
        case data
    }
}

class NotificationCountData: Codable {
    var count: Int = 0
    
    private enum CodingKeys: String, CodingKey {
        case count
    }
    
}
