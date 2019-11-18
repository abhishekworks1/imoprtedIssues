//
//  YouTubeSubscription.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 19/02/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import ObjectMapper

class YouTubeSubscription: Mappable {
    var id : String?
    var kind : Bool?
    var etag : String?
    var snippet : Snippet?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.id <- map["id"]
        self.etag <- map["etag"]
        self.snippet <- map["snippet"]
        self.kind <- map["kind"]
    }
    
}

class YouTubeItmeListResponse<T:Mappable>: Mappable {
    var kind : Bool?
    var etag :String?
    var item:[T] = []
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.etag <- map["etag"]
        self.kind <- map["kind"]
        self.item <- map["items"]
    }
}

class YouCategory: Mappable {
    var id : String?
    var kind: String?
    var etag: String?
    var snippet : Snippet?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.id <- map["id"]
        self.kind <- map["kind"]
        self.etag <- map["etag"]
        self.snippet <- map["snippet"]
    }
}
