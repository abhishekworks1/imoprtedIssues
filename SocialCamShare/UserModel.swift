//
//  User.swift
//  Bookmarks
//
//  Created by Steffi Pravasi on 02/10/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import ObjectMapper

class SharedPost: Mappable {
    var id: String?
    var type: String?
    var privacy: String?
    var bookmark: Bookmark?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        type <- map["type"]
        privacy <- map["privacy"]
        bookmark <- map["bookmark"]
    }
    
}

class Bookmark: Mappable {
    var bookmarkUrl: String?
    var description: String?
    var shortLink: String?
    var thumb: String?
    var title: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        bookmarkUrl <- map["bookmarkUrl"]
        description <- map["description"]
        shortLink <- map["shortLink"]
        thumb <- map["thumb"]
        title <- map["title"]
    }
}

class Result<T: Mappable>: Mappable {
    var sessionToken: String?
    var result: T?
    var status: String?
    var message: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        result <- map["result"]
        sessionToken <- map["token"]
        status <- map["status"]
        message <- map["message"]
    }
}
