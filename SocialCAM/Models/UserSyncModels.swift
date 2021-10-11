//
//  UserSyncModels.swift
//  SocialCAM
//
//  Created by Nilisha Gupta on 26/08/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation
import ObjectMapper

class RefferedBy: Codable, Mappable {
    
    var id: String?
    var channelId: String?
    var displayName: String?
    var email: String?
    var firstName: String?
    var lastName: String?
    var profileImageURL: String?
    var socialPlatforms: [String]?
    var isShowFlags: Bool?
    var userStateFlags: [UserCountry]?
    var created: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        channelId <- map["channelId"]
        displayName <- map["displayName"]
        email <- map["email"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        profileImageURL <- map["profileImageURL"]
        socialPlatforms <- map["socialPlatforms"]
        userStateFlags <- map["userStateFlags"]
        isShowFlags <- map["isShowFlags"]
        created <- map["created"]
    }
    
}
