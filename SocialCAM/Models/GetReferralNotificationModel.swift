//
//  GetReferralNotificationModel.swift
//  SocialCAM
//
//  Created by Testing on 17/09/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation
import ObjectMapper

class GetReferralNotificationModel: Mappable {
    
    var isForEveryone: Bool?
    var customSignupNumber: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        isForEveryone <- map["isForEveryone"]
        customSignupNumber <- map["customSignupNumber"]
    }
    
}
