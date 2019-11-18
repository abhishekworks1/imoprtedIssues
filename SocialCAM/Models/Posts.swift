//
//  Posts.swift
//  ProManager
//
//  Created by Chetan Dodiya on 08/06/17.
//  Copyright © 2017 Jatin Kathrotiya. All rights reserved.
//
import Foundation
import ObjectMapper

class Posts: Mappable, Likeable {
    var v : Int?
    var id : String?
    var myLike: ReactionType?
    var likes: [PostLikes]?
    var IschekedIn : Bool?
    var checkedIn : CheckedIn?
    var commentCounts : Int?
    var created : String?
    var hasTags : [String]?
    var isDeleted : Bool?
    var isLiked : Bool?
    var isShared : Bool?
    var likeCounts : Int?
    var sharedCount: Int?
    var media : [Media]?
    var privacy : String?
    var privacyUsersExcept : [String] = []
    var privacyUsersOnly : [String] = []
    var text : String?
    var type : PostTypes?
    var updated : String?
    var linkPreviewData: LinkPreviewData?
    var wallTheme : WallTheme?
    var sharedPost : Posts?
    var youTubeData :  YouTubeData?
    var albumId : String?
    var isPostFavorite :Bool?
    var bookmark : Bookmark?
    var paylist: Playlist?
    var addPlayListId: String?
    var feelingType : String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        v <- map["__v"]
        id <- map["_id"]
        likes <- map["likes"]
        myLike <- map["myLike"]
        commentCounts <- map["commentCounts"]
        created <- map["created"]
        hasTags <- map["hashTags"]
        isDeleted <- map["isDeleted"]
        isLiked <- map["isLiked"]
        isShared <- map["isShared"]
        likeCounts <- map["likeCounts"]
        sharedCount <- map["shareCount"]
        media <- map["media"]
        privacy <- map["privacy"]
        privacyUsersExcept <- map["privacyUsersExcept"]
        privacyUsersOnly <- map["privacyUsersOnly"]
        text <- map["text"]
        text = text?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        type <- map["type"]
        updated <- map["updated"]
        IschekedIn <- map["IschekedIn"]
        checkedIn <- map["checkedIn"]
        wallTheme <- map["wallTheme"]
        sharedPost <- map["sharedFrom"]
        feelingType <- map["feelingType"]
        youTubeData <- map["youTubeData"]
        bookmark <- map["bookmark"]
        linkPreviewData <- map["linkPreviewData"]
        albumId <- map["albumId"]
        isPostFavorite <- map["isPostFavorite"]
        paylist <- map["paylist"]
        addPlayListId <- map["addPlayListId"]
        if let youtubeData = self.youTubeData  , let videoUrl = youtubeData.videoUrl , videoUrl.count > 0 && type == .text {
            type  = .youtube
        } else if type == .text &&  IschekedIn == true {
            type = .location
        }
    }
}

class YouTubeData: Mappable {
    var previewThumb:String?
    var title: String?
    var videoId :String?
    var videoUrl : String?
    var channelId : String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        previewThumb <- map["previewThumb"]
        title <- map["title"]
        videoId <- map["videoId"]
        videoUrl <- map["videoUrl"]
        channelId <- map["channelId"]
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

class LinkPreviewData: Mappable {
    var previewThumb:String?
    var title: String?
    var previewUri :String?
    var previewDescription: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        previewThumb <- map["previewThumb"]
        title <- map["title"]
        previewUri <- map["previewUri"]
        previewDescription <- map["previewDescription"]
    }
    
}

class  WallTheme:Mappable {
    var text:String?
    var stringType : String?
    var type: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        text <- map["text"]
        // stringType <- map["type"]
        type <- (map["type"] , TransformOf<Int, String>(fromJSON: { Int($0!) }, toJSON: { $0.map { String($0) } }))
    }
    
}

class Media : Mappable {
    var id:String?
    var mediaType: String?
    var thumbNail :String?
    var url : String?
    var duration: String?
    var thumb : [ThumbType:Thumb]?
    required init?(map: Map){}
    
    func mapping(map: Map) {
        id <- map["_id"]
        mediaType <- map["mediaType"]
        thumbNail <- map["thumbNail"]
        url <- map["url"]
        duration <- map["duration"]
        thumb <- (map["thumbs"] , DictionaryTransform<ThumbType,Thumb>())
    }
    
}

class Thumb : Mappable {
    var width : Double?
    var height : Double?
    var url : String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        height <- map["_id"]
        width <- map["mediaType"]
        url <- map["url"]
    }
    
}

enum ThumbType: String {
    case large = "large"
    case medium = "medium"
    case small = "small"
}

class StoryComment: Mappable {
    var id, story: String?
    var user: User?
    var isDeleted: Bool?
    var replyCounts: Int?
    var replies: [CommentReply]?
    var likes: [LikeStory]?
    var type, text, updated, created: String?
    var likeCounts: Int?
    var isLiked: Bool?
    var myLike: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        created <- map["created"]
        isDeleted <- map["isDeleted"]
        isLiked <- map["isLiked"]
        likeCounts <- map["likeCounts"]
        likes <- map["likes"]
        myLike <- map["myLike"]
        replyCounts <- map["replyCounts"]
        text <- map["text"]
        type <- map["type"]
        updated <- map["updated"]
        user <- map["user"]
        replies <- map["replies"]
    }
    
}

class PostComment: Mappable {
    var v : Int?
    var id : String?
    var created : String?
    var isDeleted : Bool?
    var isLiked : Bool?
    var likeCounts : Int?
    var likes : [PostLikes]?
    #if IS_PROMANAGER
    var myLike : ReactionType?
    #endif
    var picture : String?
    var post : String?
    var replyCounts : Int?
    var text : String?
    var type : String?
    var updated : String?
    var user : PostUser?
    var replies: [CommentReply] = []
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        v <- map["__v"]
        id <- map["_id"]
        created <- map["created"]
        isDeleted <- map["isDeleted"]
        isLiked <- map["isLiked"]
        likeCounts <- map["likeCounts"]
        likes <- map["likes"]
        #if IS_PROMANAGER
        myLike <- map["myLike"]
        #endif
        picture <- map["picture"]
        post <- map["post"]
        replyCounts <- map["replyCounts"]
        text <- map["text"]
        type <- map["type"]
        updated <- map["updated"]
        user <- map["user"]
        replies <- map["replies"]
    }
    
}

class CommentReply: Mappable {
    var v : Int?
    var id : String?
    var comment : String?
    var created : String?
    var isDeleted : Bool?
    var isLiked : Bool?
    var likeCounts : Int?
    var likes : [PostLikes]?
    #if IS_PROMANAGER
    var myLike : ReactionType?
    #endif
    var picture : String?
    var post : String?
    var text : String?
    var type : String?
    var updated : String?
    var user : PostUser?
    var video : String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        v <- map["__v"]
        id <- map["_id"]
        comment <- map["comment"]
        created <- map["created"]
        isDeleted <- map["isDeleted"]
        isLiked <- map["isLiked"]
        likeCounts <- map["likeCounts"]
        likes <- map["likes"]
        #if IS_PROMANAGER
        myLike <- map["myLike"]
        #endif
        picture <- map["picture"]
        post <- map["post"]
        text <- map["text"]
        type <- map["type"]
        updated <- map["updated"]
        user <- map["user"]
        video <- map["video"]
    }
}

class CheckedIn: Mappable {
    var latitude : String?
    var locationUrl : String?
    var longitude : String?
    var placeString : String?
   
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        latitude <- map["latitude"]
        locationUrl <- map["locationUrl"]
        longitude <- map["longitude"]
        placeString <- map["placeString"]
    }

}
