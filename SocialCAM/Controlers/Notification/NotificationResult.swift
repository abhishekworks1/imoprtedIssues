//
//  Notification.swift
//  SocialCAM
//
//  Created by Viraj Patel on 23/09/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation
import ObjectMapper

class NotificationResult: Mappable{

    var count : Int?
    var notifications : [UserNotification]?

    required init?(map: Map){}

    func mapping(map: Map) {
        count <- map["count"]
        notifications <- map["notifications"]
    }

}

class UserNotification: Mappable{

    var id: String?
    var createdAt: String?
    var isRead: Bool?
    var isSendEmail: Bool?
    var isSendPush: Bool?
    var isSendSms: Bool?
    var message: String?
    var metaData: MetaData?
    var notificationType : Int?
    var platformType : String?
    var refereeUserId : RefereeUserId?
    var title : String?
    var updatedAt : String?
    var publicDisplayName: String?
    var privateDisplayName: String?
    var isFollowing: Bool?
    var iosTitle: String?
    var iosBody: String?
    
    class func newInstance(map: Map) -> Mappable?{
        return UserNotification(map: map)
    }
    required init?(map: Map){}

    func mapping(map: Map)
    {
        id <- map["_id"]
        createdAt <- map["createdAt"]
        isRead <- map["isRead"]
        isSendEmail <- map["isSendEmail"]
        isSendPush <- map["isSendPush"]
        isSendSms <- map["isSendSms"]
        message <- map["message"]
        metaData <- map["metaData"]
        notificationType <- map["notification_type"]
        platformType <- map["platform_type"]
        refereeUserId <- map["refereeUserId"]
        title <- map["title"]
        updatedAt <- map["updatedAt"]
        publicDisplayName <- map["publicDisplayName"]
        privateDisplayName <- map["privateDisplayName"]
        isFollowing <- map["isFollowing"]
        iosTitle <- map["ios_title"]
        iosBody <- map["ios_body"]
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
    {
         id = aDecoder.decodeObject(forKey: "_id") as? String
         createdAt = aDecoder.decodeObject(forKey: "createdAt") as? String
         isRead = aDecoder.decodeObject(forKey: "isRead") as? Bool
         isSendEmail = aDecoder.decodeObject(forKey: "isSendEmail") as? Bool
         isSendPush = aDecoder.decodeObject(forKey: "isSendPush") as? Bool
         isSendSms = aDecoder.decodeObject(forKey: "isSendSms") as? Bool
         message = aDecoder.decodeObject(forKey: "message") as? String
        metaData = aDecoder.decodeObject(forKey: "metaData") as? MetaData
         notificationType = aDecoder.decodeObject(forKey: "notification_type") as? Int
         platformType = aDecoder.decodeObject(forKey: "platform_type") as? String
        refereeUserId = aDecoder.decodeObject(forKey: "refereeUserId") as? RefereeUserId
         title = aDecoder.decodeObject(forKey: "title") as? String
         updatedAt = aDecoder.decodeObject(forKey: "updatedAt") as? String
        iosTitle = aDecoder.decodeObject(forKey: "ios_title") as? String
        iosBody = aDecoder.decodeObject(forKey: "ios_body") as? String

    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
    {
        if id != nil{
            aCoder.encodeConditionalObject(id, forKey: "_id")
        }
        if createdAt != nil{
            aCoder.encodeConditionalObject(createdAt, forKey: "createdAt")
        }
        if isRead != nil{
            aCoder.encodeConditionalObject(isRead, forKey: "isRead")
        }
        if isSendEmail != nil{
            aCoder.encodeConditionalObject(isSendEmail, forKey: "isSendEmail")
        }
        if isSendPush != nil{
            aCoder.encodeConditionalObject(isSendPush, forKey: "isSendPush")
        }
        if isSendSms != nil{
            aCoder.encodeConditionalObject(isSendSms, forKey: "isSendSms")
        }
        if message != nil{
            aCoder.encodeConditionalObject(message, forKey: "message")
        }
        if metaData != nil{
            aCoder.encode(metaData, forKey: "metaData")
        }
        if notificationType != nil{
            aCoder.encodeConditionalObject(notificationType, forKey: "notification_type")
        }
        if platformType != nil{
            aCoder.encodeConditionalObject(platformType, forKey: "platform_type")
        }
        if refereeUserId != nil{
            aCoder.encode(refereeUserId, forKey: "refereeUserId")
        }
        if title != nil{
            aCoder.encodeConditionalObject(title, forKey: "title")
        }
        if updatedAt != nil{
            aCoder.encodeConditionalObject(updatedAt, forKey: "updatedAt")
        }
        if  iosTitle  != nil{
            aCoder.encodeConditionalObject(updatedAt, forKey: "ios_title")
        }
        if  iosBody  != nil{
            aCoder.encodeConditionalObject(updatedAt, forKey: "ios_body")
        }
    }

}

class RefereeUserId : NSObject, NSCoding, Mappable{

    var id : String?
    var channelId : String?
    var created : String?
    var profileImageURL : String?
    var socialPlatforms : [String]?
    var isShowFlags: Bool?
    var userStateFlags: [UserCountry]?

    class func newInstance(map: Map) -> Mappable?{
        return RefereeUserId(map: map)
    }
    required init?(map: Map){}

    func mapping(map: Map)
    {
        id <- map["_id"]
        channelId <- map["channelId"]
        created <- map["created"]
        profileImageURL <- map["profileImageURL"]
        socialPlatforms <- map["socialPlatforms"]
        isShowFlags <- map["isShowFlags"]
        userStateFlags <- map["userStateFlags"]
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
    {
         id = aDecoder.decodeObject(forKey: "_id") as? String
         channelId = aDecoder.decodeObject(forKey: "channelId") as? String
         created = aDecoder.decodeObject(forKey: "created") as? String
         profileImageURL = aDecoder.decodeObject(forKey: "profileImageURL") as? String
        socialPlatforms = aDecoder.decodeObject(forKey: "socialPlatforms") as? [String]

    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
    {
        if id != nil{
            aCoder.encodeConditionalObject(id, forKey: "_id")
        }
        if channelId != nil{
            aCoder.encodeConditionalObject(channelId, forKey: "channelId")
        }
        if created != nil{
            aCoder.encodeConditionalObject(created, forKey: "created")
        }
        if profileImageURL != nil{
            aCoder.encodeConditionalObject(profileImageURL, forKey: "profileImageURL")
        }
        if socialPlatforms != nil{
            aCoder.encodeConditionalObject(socialPlatforms, forKey: "socialPlatforms")
        }

    }

}

class MetaData : NSObject, NSCoding, Mappable{

    var uSERNAME : String?
    var deviceToken : String?
    var deviceType : String?
    var notificationType : Int?
    var referee : String?
    var refereeUserId : String?
    var referral : String?


    class func newInstance(map: Map) -> Mappable?{
        return MetaData(map: map)
    }
    required init?(map: Map){}

    func mapping(map: Map)
    {
        uSERNAME <- map["USERNAME"]
        deviceToken <- map["deviceToken"]
        deviceType <- map["deviceType"]
        notificationType <- map["notificationType"]
        referee <- map["referee"]
        refereeUserId <- map["refereeUserId"]
        referral <- map["referral"]
        
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
    {
         uSERNAME = aDecoder.decodeObject(forKey: "USERNAME") as? String
         deviceToken = aDecoder.decodeObject(forKey: "deviceToken") as? String
         deviceType = aDecoder.decodeObject(forKey: "deviceType") as? String
         notificationType = aDecoder.decodeObject(forKey: "notificationType") as? Int
         referee = aDecoder.decodeObject(forKey: "referee") as? String
         refereeUserId = aDecoder.decodeObject(forKey: "refereeUserId") as? String
         referral = aDecoder.decodeObject(forKey: "referral") as? String

    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
    {
        if uSERNAME != nil{
            aCoder.encodeConditionalObject(uSERNAME, forKey: "USERNAME")
        }
        if deviceToken != nil{
            aCoder.encodeConditionalObject(deviceToken, forKey: "deviceToken")
        }
        if deviceType != nil{
            aCoder.encodeConditionalObject(deviceType, forKey: "deviceType")
        }
        if notificationType != nil{
            aCoder.encodeConditionalObject(notificationType, forKey: "notificationType")
        }
        if referee != nil{
            aCoder.encodeConditionalObject(referee, forKey: "referee")
        }
        if refereeUserId != nil{
            aCoder.encodeConditionalObject(refereeUserId, forKey: "refereeUserId")
        }
        if referral != nil{
            aCoder.encodeConditionalObject(referral, forKey: "referral")
        }

    }

}
