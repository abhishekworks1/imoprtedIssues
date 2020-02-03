//
//  MeResponse.swift
//  SimpleInstagram
//
//  Created on 23/01/2020.
//  Copyright © 2020 clementozemoya. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

class MeResponse: Mappable {
    var accountType: String?
    var id: String?
    var media: Int?
    var username: String?
    
    required init(map: Map) {
        
    }
    
    func mapping(map: Map) {
        accountType <- map["account_type"]
        id <- map["id"]
        media <- map["media"]
        username <- map["username"]
    }
}
