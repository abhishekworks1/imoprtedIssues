//
//  Channel.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 19/05/17.
//  Copyright © 2017 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import ObjectMapper

class Channel: Mappable {
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
    var OauthId: String?
    var firstName: String?
    var isFollowing: Bool?
    var following: Int?
    var follower: Int?
    var articleCounts: Int?
    var profileThumbnail: String?
    var profileType: Int = 1

    required init?(map: Map) {
        
    }
    
    // MARK: - - Mappable Protocol
    
    func mapping(map: Map) {
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
        OauthId <- map["OauthId"]
        firstName <- map["firstName"]
        isFollowing <- map["isFollowing"]
        following <- map["following"]
        follower <- map["follower"]
        articleCounts <- map["articleCounts"]
        profileThumbnail  <- map["profileThumbnail"]
        profileType <- map["profileType"]
  }
    
}

class CartResult: NSObject, Mappable {
    var is_admin: Bool?
    var unreadcount: Int?
    var _id: String?
    var created: String?
    var phone: String?
    var __v: Int?
    var is_typing: Bool?
    var isVerified: Int?
    var profileType: Int?
    var packageChannels: [String]?
    var individualChannels: [String]?
    var packageName: Int?
    var userId: String?
    var existsChannel: [String]?
    
    override init() {}
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        is_admin <- map["is_admin"]
        unreadcount <- map["unreadcount"]
        _id <- map["_id"]
        created <- map["created"]
        phone <- map["phone"]
        __v <- map["__v"]
        is_typing <- map["is_typing"]
        isVerified <- map["isVerified"]
        profileType <- map["profileType"]
        packageChannels <- map["packageChannels"]
        individualChannels <- map["individualChannels"]
        packageName <- map["packageName"]
        userId <- map["userId"]
        existsChannel <- map["existsChannel"]
    }
}

class GetPackage: Mappable {
    var _id: String?
    var remainingPackageCount: Int?
    var remainingOtherUserPackageCount: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        _id <- map["_id"]
        remainingPackageCount <- map["remainingPackageCount"]
        remainingOtherUserPackageCount <- map["remainingOtherUserPackageCount"]
    }
}
