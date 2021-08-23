//
//  ReferredUser.swift
//  SocialCAM
//
//  Created by Meet Mistry on 24/08/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation
import ObjectMapper

class ReferredUser: Mappable {
    
    var id: String?
    var channelId: String?
    var channelName: String?
    var displayName: String?
    var dob: String?
    var email: String?
    var firstName: String?
    var gender: String?
    var lastName: String?
    var profileImageURL: String?
    var refferingChannel: String?
    var username: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        channelId <- map["channelId"]
        channelName <- map["channelName"]
        displayName <- map["displayName"]
        dob <- map["dob"]
        email <- map["email"]
        firstName <- map["firstName"]
        gender <- map["gender"]
        lastName <- map["lastName"]
        profileImageURL <- map["profileImageURL"]
        refferingChannel <- map["refferingChannel"]
        username <- map["username"]
    }
}
