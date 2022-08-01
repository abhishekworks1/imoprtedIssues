//
//  GetPlayList.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 03/01/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import ObjectMapper

protocol Likeable {
    var myLike: ReactionType? {get set}
    var likeCounts: Int? {get set}
    var likes: [PostLikes]? {get set}
    var commentCounts: Int? {get set}
    var isLiked: Bool? {get set}
}

class PostUser: Mappable {
    var id: String?
    var channelName: String?
    var profileImageURL: String?
    var channelId: String?
    var profileType: Int = 1
    var profileThumbnail: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        channelName <- map["channelName"]
        profileImageURL <- map["profileImageURL"]
        channelId <- map["channelId"]
        profileThumbnail <- map["profileThumbnail"]
        profileType <- map["profileType"]
    }
}

class PostLikes: Mappable {
    var id: String?
    var created: String?
    var user: PostUser?
    var type: ReactionType?
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        created <- map["created"]
        type <- map["type"]
        user <- map["user"]
    }
}

class GetPlaylist: Mappable, Likeable {
    var likeCounts: Int?
    var likes: [PostLikes]?
    var commentCounts: Int?
    var id: String?
    var name: String?
    var user: User?
    var created: String?
    var imageUrl: String?
    var storyCount: Int?
    var postCount: Int?
    var type: Int?
    var followers: Int?
    var viewCount: Int?
    var isLiked: Bool?
    var myLike: ReactionType?
    var hashTags: [String]?
    var followUser: [String]?
    var followUserEmail: [String]?
    var follow: Bool?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        name <- map["name"]
        user <- map["user"]
        created <- map["created"]
        imageUrl <- map["imageUrl"]
        storyCount <- map["playlistStoryCount"]
        postCount <- map["playlistYoutubeCount"]
        type <- map["type"]
        likes <- map["likeByUser"]
        followers <- map["followers"]
        viewCount <- map["viewCount"]
        isLiked <- map["isLiked"]
        myLike <- map["myLike"]
        hashTags <- map["hashTags"]
        followUser <- map["followUser"]
        followUserEmail <- map["followUserEmail"]
        follow <- map["follow"]
        commentCounts <- map["commentCount"]
        likeCounts = likes?.count ?? 0
        followers = followUser?.count ?? 0
    }
}
