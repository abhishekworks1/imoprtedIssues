//
//  User.swift
//  Kjorebok
//
//  Created by Jatin Kathrotiya on 23/11/16.
//  Copyright © 2016 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import ObjectMapper

class User: Codable, Mappable {
    var id: String?
    var salt: String?
    var username: String?
    var displayName: String?
    var channelId: String?
    var country: String?
    var email: String?
    var isBusiness: Bool?
    var channelName: String?
    var roles: [String]?
    var provider: String?
    var hashTags: [String]?
    var tweetText: String?
    var categories: [String]?
    var isWaiting: Bool?
    var referrerChannel: String?
    var shortUrl: String?
    var age: String?
    var gender: String?
    var twitterProfileLink: String?
    var about: String?
    var bannerImageURL: String?
    var profileImageURL: String?
    var emailVerification: Bool?
    var lastName: String?
    var oauthId: String?
    var firstName: String?
    var isFollowing: Bool?
    var following: Int?
    var follower: Int?
    var storyCounts: Int?
    var favoriteStoryCount: Int?
    var business: String?
    var phone: String?
    var title: String?
    var other: String?
    var socialId: String?
    var articleCounts: Int?
    var isTyping: Bool = false
    var isAdmin: Bool = false
    var unreadCount: Int = 0
    var profileType: Int = 1
    var isVerified: Int = 0
    var isFirstLogin: Int = 0
    var profileThumbnail: String?
    var isAllowForward: Bool = true
    var parentId: String?
    // OtherProfile
    var businessName: String?
    var created: String?
    var deviceToken: String?
    var isBlocked: Bool?
    var isDefault: Bool?
    var password: String?
    var refferingChannel: String?
    var updated: String?
    var dateObj = Date()
    var timestamp: TimeInterval?
    var fcmToken = [String]()
    var voipToken = [String]()
    var isBenefactor: Bool?
    var remainingOtherUserPackageCount: Int?
    var remainingPackageCount: Int?
    var isVipUser: Bool?
    var vipUserCount: Int?
    var deepLinkUrl: String?
    var advanceGameMode: Bool?
    var viralcamReferralLink: String?
    var referralCode: String?
    var subscriptionStatus: String?
    var dob: String?
    var freeTrialExpiry: String?
    var isTempSubscription: Bool?
    var isAllowAffiliate: Bool?
    var refferedBy : RefferedBy?
    
    required init?(map: Map) {
        
    }
    
    // MARK: - - Mappable Protocol
    
    func mapping(map: Map) {
        phone = ""
        id <- map["_id"]
        salt <- map["salt"]
        username <- map["username"]
        displayName <- map["displayName"]
        channelId <- map["channelId"]
        country <- map["country"]
        email <- map["email"]
        isBusiness <- map["isBusiness"]
        channelName <- map["channelName"]
        roles <- map["roles"]
        provider <- map["provider"]
        hashTags <- map["hashTags"]
        tweetText <- map["tweetText"]
        categories <- map["categories"]
        isWaiting <- map["isWaiting"]
        referrerChannel <- map["referrerChannel"]
        shortUrl <- map["shortUrl"]
        age <- map["age"]
        gender <- map["gender"]
        twitterProfileLink <- map["twitterProfileLink"]
        about <- map["about"]
        bannerImageURL <- map["bannerImageURL"]
        profileImageURL <- map["profileImageURL"]
        emailVerification <- map["emailVerification"]
        lastName <- map["lastName"]
        oauthId <- map["OauthId"]
        firstName <- map["firstName"]
        isFollowing <- map["isFollowing"]
        following <- map["following"]
        follower <- map["follower"]
        storyCounts <- map["storyCounts"]
        favoriteStoryCount <- map["favoriteStoryCount"]
        business <- map["business"]
        phone <- map["phone"]
        title <- map["title"]
        other <- map["other"]
        socialId <- map["socialId"]
        profileType <- map["profileType"]
        isFirstLogin <- map["isFirstLogin"]
        isVerified <- map["isVerified"]
        profileThumbnail <- map["profileThumbnail"]
        parentId <- map["parentId"]
        isBenefactor <- map["isBenefactor"]
        remainingOtherUserPackageCount <- map["remainingOtherUserPackageCount"]
        remainingPackageCount <- map["remainingPackageCount"]
        
        // OtherProfile
        businessName <- map["businessName"]
        created <- map["created"]
        deviceToken <- map["deviceToken"]
        isBlocked <- map["isBlocked"]
        isDefault <- map["isDefault"]
        password <- map["password"]
        refferingChannel <- map["refferingChannel"]
        updated <- map["updated"]
        articleCounts <- map["articleCounts"]
        // Chat
        isTyping <- map["is_typing"]
        isAdmin <- map["is_admin"]
        subscriptionStatus <- map["subscriptionStatus"]
        if id == nil {
            id <- map["id"]
        }
        if profileImageURL == nil {
            profileImageURL <- map["profileimageURL"]
        }
        if displayName == nil {
            displayName <- map["displayname"]
        }
        unreadCount <- map["unreadcount"]
        timestamp <- map["timestamp"]
        if timestamp != nil {
            dateObj =  Date(timeIntervalSince1970: TimeInterval(timestamp!)/1000)
        } else {
            
        }
        isVipUser <- map["isVipUser"]
        vipUserCount <- map["vipUserCount"]
        deepLinkUrl <- map["deepLinkUrl"]
        advanceGameMode <- map["advanceGameMode"]
        viralcamReferralLink <- map["viralcamReferralLink"]
        referralCode <- map["referralCode"]
        dob <- map["dob"]
        freeTrialExpiry <- map["freeTrialExpiry"]
        isTempSubscription <- map["isTempSubscription"]
        isAllowAffiliate <- map["isAllowAffiliate"]
        refferedBy <- map["refferedBy"]
    }
    
}

class SocialUserConnect: Codable, Mappable {
    var id: String?
    var message: String?
    
    required init?(map: Map) {
        
    }
    
    // MARK: - - Mappable Protocol
    
    func mapping(map: Map) {
        id <- map["_id"]
        message <- map["message"]
    }
    
}
