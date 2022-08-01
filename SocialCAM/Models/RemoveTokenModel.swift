//
//  RemoveTokenModel.swift
//  SocialCAM
//
//  Created by Testing on 17/09/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation
import ObjectMapper

class RemoveTokenModel: Mappable {
    
    var isDeleted: Bool?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        isDeleted <- map["isDeleted"]
    }
    
}

