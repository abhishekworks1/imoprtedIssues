//
//  SplashImages.swift
//  SocialCAM
//
//  Created by Viraj Patel on 08/01/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import ObjectMapper

enum SplashImagesType: String {
    case background = "background"
}

class SplashImages: Mappable {
    var id: String?
    var type: SplashImagesType?
    var imageArray: [String]?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    // MARK: - - Mappable Protocol
    func mapping(map: Map) {
        id <- map["_id"]
        type <- (map["type"], EnumTransform<SplashImagesType>())
        imageArray <- map["imageArray"]
    }
}
