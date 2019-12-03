//
//  Hash.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 05/09/17.
//  Copyright © 2017 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import ObjectMapper

class HashTag: Mappable {
    var  id: String?
    var count: Int?
    var tag: String?
    var isFollow: Bool?
    var mediaUrl: String?

    required init?(map: Map) {
        
    }
    
    // MARK: - - Mappable Protocol
    
    func mapping(map: Map) {
        id <- map["_id"]
        count <- map["count"]
        tag <- map["tag"]
        isFollow <- map["isFollow"]
        mediaUrl <- map["mediaUrl"]
    }
    
}

class HashTagSetList: Mappable {
    
    var _id: String?
    var categoryName: String?
    var userHashTagData: UserHashTagData?
    var __v: Int?
    var created: String?
    var usedCount: Int?
    var hashTags: [String]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        _id <- map["_id"]
        categoryName <- map["categoryName"]
        userHashTagData <- map["user"]
        __v <- map["__v"]
        created <- map["created"]
        usedCount <- map["usedCount"]
        hashTags <- map["hashTags"]
    }
}

class UserHashTagData: Mappable {
    
    var _id: String?
    var channelId: String?
    var channelName: String?
    var profileType: Int?
    var profileThumbnail: String?
    var profileImageURL: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        _id <- map["_id"]
        channelId <- map["channelId"]
        channelName <- map["channelName"]
        profileType <- map["profileType"]
        profileThumbnail <- map["profileThumbnail"]
        profileImageURL <- map["profileImageURL"]
    }

}
