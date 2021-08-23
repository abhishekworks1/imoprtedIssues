//
//  ReferredUserModel.swift
//  SocialCAM
//
//  Created by Meet Mistry on 18/08/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation
import ObjectMapper

class ReferredUserModel : Mappable {
    
    var count : Int?
    var referees : [Referee]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        count <- map["count"]
        referees <- map["referees"]
    }
}
