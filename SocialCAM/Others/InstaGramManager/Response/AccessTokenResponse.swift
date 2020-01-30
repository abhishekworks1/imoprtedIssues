//
//  AccessCodeResponse.swift
//  SimpleInstagram
//
//  Created on 23/01/2020.
//  Copyright © 2020 clementozemoya. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

class AccessTokenResponse: NSObject, Mappable {
    var accessToken: String?
    var userId: Float?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        accessToken  <- map["access_token"]
        userId <- map["user_id"]
    }
}
