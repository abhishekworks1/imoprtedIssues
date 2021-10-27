//
//  UserNotification.swift
//  SocialCAM
//
//  Created by Viraj Patel on 01/10/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation
import ObjectMapper

class UserNotification: Mappable {

    var id: String?
    var createdAt: String?
    var isRead: Bool?
    var isSendEmail: Bool?
    var isSendPush: Bool?
    var isSendSms: Bool?
    var message: String?
    var notificationType: Int?
    var platformType: String?
    var refereeUserId: RefereeUserId?
    var title: String?
    var updatedAt: String?
    var publicDisplayName: String?
    var privateDisplayName: String?
    var isFollowing: Bool?
    var iosTitle: String?
    var iosBody: String?
    
    required init?(map: Map){}

    func mapping(map: Map) {
        id <- map["_id"]
        createdAt <- map["createdAt"]
        isRead <- map["isRead"]
        isSendEmail <- map["isSendEmail"]
        isSendPush <- map["isSendPush"]
        isSendSms <- map["isSendSms"]
        message <- map["message"]
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
}
