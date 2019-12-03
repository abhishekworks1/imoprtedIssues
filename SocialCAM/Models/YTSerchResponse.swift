//
//  YTSerchResponse.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 19/09/17.
//  Copyright © 2017 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import ObjectMapper
import RxCocoa
import RxSwift
import NSObject_Rx

class YTSerchResponse <T: Mappable> : Mappable {
    var pageInfo: PageInfo?
    var result: [T]?
    var nextPageToken: String?
    var message: String?
    var pageFlag: String?
    var resultCount: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        result <- map["items"]
        pageInfo <- map["pageInfo"]
        nextPageToken <- map["nextPageToken"]
        message <- map["message"]
        pageFlag <- map["page_flag"]
        resultCount <- map["result_count"]
    }
    
}

class PageInfo: Mappable {
    var totalResults: Int?
    var resultsPerPage: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        totalResults <- map["totalResults"]
        resultsPerPage <- map["resultsPerPage"]
    }
    
}

class Item: Mappable {
    var kind: String?
    var etag: String?
    var id: ItemId?
    var ids: String?
    var snippet: Snippet?
    var statistics: Statistics?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        kind <- map["kind"]
        etag <- map["etag"]
        id <- map["id"]
        ids <- map["id"]
        snippet <- map["snippet"]
        statistics <- map["statistics"]
    }

}

class ItemId: Mappable {
    var kind: String?
    var videoId: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        kind <- map["kind"]
        videoId <- map["videoId"]
    }
    
}

class Snippet: Mappable {
    var title: String?
    var description: String?
    var tags: [String]?
    var thumbnail: String?
    var publishedAt: String?
    var channelTitle: String?
    var channelId: String?
    var resourcechannelId: String?

    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        title <- map["title"]
        description <- map["description"]
        tags <- map["tags"]
        thumbnail <- map["thumbnails.high.url"]
        publishedAt <- map["publishedAt"]
        channelTitle <- map["channelTitle"]
        channelId <- map["channelId"]
        resourcechannelId <- map["resourceId.channelId"]
        
    }
    
}

class Statistics: Mappable {
    var viewCount: String?
    var likeCount: String?
    var dislikeCount: String?
    var favoriteCount: String?
    var commentCount: String?
     var viewInt: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        viewCount <- map["viewCount"]
        if let longValue: Int = Int(viewCount ?? "") {
            viewInt =  longValue
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            viewCount = numberFormatter.string(from: NSNumber(value: longValue)) ?? ""
        }
        likeCount <- map["likeCount"]
        
        if let longValue: Int = Int(likeCount ?? "") {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            likeCount = numberFormatter.string(from: NSNumber(value: longValue)) ?? ""
        }
        dislikeCount <- map["dislikeCount"]
       
        if let longValue: Int = Int(dislikeCount ?? "") {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            dislikeCount = numberFormatter.string(from: NSNumber(value: longValue)) ?? ""
        }
        
        favoriteCount <- map["favoriteCount"]
        commentCount <- map["commentCount"]
    }
    
}
