//
//  ExtensionStory.swift
//  SocialCamMediaShare
//
//  Created by Viraj Patel on 03/03/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

class ExtensionStory: Mappable {
    var id: String?
    var url : String?
    var duration : String?
    var type : String?
    var created : String?
    var thumb : String?
    var isViewed: Int?
    var isFavorite: Bool?
    
    required init?(map: Map) {
        
    }
    
    init(id: String?,url: String,duration: String,type: String,created: String) {
        self.id = id
        self.url = url
        self.duration = duration
        self.type = type
        self.created = created
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        url <- map["url"]
        duration <- map["duration"]
        type <- map["type"]
        created <- map["created"]
       
        thumb <- map["thumb"]
        isViewed <- map["isViewed"]
        isFavorite <- map["isFavorite"]
    }
}
