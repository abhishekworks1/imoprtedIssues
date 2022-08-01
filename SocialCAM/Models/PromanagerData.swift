//
//  PromanagerData.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 30/05/17.
//  Copyright © 2017 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import ObjectMapper

class PromanagerData: Mappable {
    var id: String?
    var created: String?
    var name: String?
    var userData: UserData?
    var channelData: [ChannelData]?
    
    required init?(map: Map) {
        
    }
    
    // MARK: - - Mappable Protocol
    
    func mapping(map: Map) {
        id <- map["_id"]
        name <- map["name"]
        userData <- map["user"]
        channelData <- map["channels"]
    }
    
}

class UserData: Mappable {
    var userId: String?
    var recommendedCount: String?
    
    required init?(map: Map) {
        
    }
    
    // MARK: - - Mappable Protocol
    
    func mapping(map: Map) {
        userId <- map["_id"]
        recommendedCount <- map["name"]
    }
    
}

class ChannelData: Mappable {
    var channelId: String?
    var points: Int?
    var tokens: Int?
    var badges: [String] = []
    var coins: Int?
    
    required init?(map: Map) {
        
    }
    
    // MARK: - - Mappable Protocol
    
    func mapping(map: Map) {
        channelId <- map["channelId"]
        points <- map["points"]
        tokens <- map["tokens"]
        badges <- map["badges"]
        coins <- map["coins"]
    }
    
}
