//
//  NotificationResult.swift
//  SocialCAM
//
//  Created by Viraj Patel on 01/10/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation
import ObjectMapper

class NotificationResult: Mappable{

    var count: Int?
    var notifications: [UserNotification]?

    required init?(map: Map){}

    func mapping(map: Map) {
        count <- map["count"]
        notifications <- map["notifications"]
    }
}
