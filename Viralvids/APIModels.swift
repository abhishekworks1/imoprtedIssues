//
//  APIModels.swift
//  Viralvids
//
//  Created by Viraj Patel on 21/04/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import ObjectMapper

class CreatePostViralCam: Codable, Mappable {
    var id: String?
    var title: String?
    var referenceLink: String?
    var description: String?
    var hashtags: [String]?
    var image: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        title <- map["title"]
        referenceLink <- map["referenceLink"]
        description <- map["description"]
        hashtags <- map["hashtags"]
        image <- map["image"]
    }
    
}
