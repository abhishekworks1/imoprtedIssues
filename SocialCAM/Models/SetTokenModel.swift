//
//  SetTokenModel.swift
//  SocialCAM
//
//  Created by Nilisha Gupta on 16/09/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation
import ObjectMapper

class SetTokenModel: Mappable {
    
    var id: String?
    var createdAt: String?
    var deviceToken: String?
    var deviceType: String?
    var notificationPref: Bool?
    var updatedAt: String?
    var userId: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        createdAt <- map["createdAt"]
        deviceToken <- map["deviceToken"]
        deviceType <- map["deviceType"]
        notificationPref <- map["notificationPref"]
        updatedAt <- map["updatedAt"]
        userId <- map["userId"]
    }
    
}
