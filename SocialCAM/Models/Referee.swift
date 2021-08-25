//
//  Referee.swift
//  SocialCAM
//
//  Created by Meet Mistry on 24/08/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation
import ObjectMapper

class Referee: Mappable {
    
    var id: String?
    var created: String?
    var points: Int?
    var referUser: String?
    var type: String?
    var user: ReferredUser?
    var userId: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        created <- map["created"]
        points <- map["points"]
        referUser <- map["referUser"]
        type <- map["type"]
        user <- map["user"]
        userId <- map["userId"]
    }
}
