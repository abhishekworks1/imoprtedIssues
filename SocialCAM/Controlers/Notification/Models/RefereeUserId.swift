//
//  RefereeUserId.swift
//  SocialCAM
//
//  Created by Viraj Patel on 01/10/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation
import ObjectMapper

class RefereeUserId: Mappable{

    var id: String?
    var channelId: String?
    var created: String?
    var profileImageURL: String?
    var socialPlatforms: [AnyObject]?
    var isShowFlags: Bool?
    var userStateFlags: [UserCountry]?
    
    required init?(map: Map){}

    func mapping(map: Map) {
        id <- map["_id"]
        channelId <- map["channelId"]
        created <- map["created"]
        profileImageURL <- map["profileImageURL"]
        socialPlatforms <- map["socialPlatforms"]
        isShowFlags <- map["isShowFlags"]
        userStateFlags <- map["userStateFlags"]
    }
}
