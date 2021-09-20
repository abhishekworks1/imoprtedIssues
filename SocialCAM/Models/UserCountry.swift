//
//  UserCountry.swift
//  SocialCAM
//
//  Created by Viraj Patel on 17/09/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit
import ObjectMapper

class UserCountry: Codable, Mappable {
    
    var id: String?
    var country: String?
    var countryCode: String?
    var state: String?
    var countryFlag: String?
    var stateFlag: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        country <- map["country"]
        countryCode <- map["countryCode"]
        state <- map["state"]
        countryFlag <- map["countryFlag"]
        stateFlag <- map["stateFlag"]
    }
    
}
