//
//  LoginResponse.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 17/05/17.
//  Copyright © 2017 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import ObjectMapper

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

class ResultArray<T: Mappable>: Mappable {
    var sessionToken: String?
    var result: [T]?
    var status: String?
    var message: String?
    var pageFlag: String?
    var resultCount: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        result <- map["result"]
        sessionToken <- map["token"]
        status <- map["status"]
        message <- map["message"]
        pageFlag <- map["page_flag"]
        resultCount <- map["result_count"]
        if resultCount == nil {
             resultCount <- map["resultCounts"]
        }
    }
}
