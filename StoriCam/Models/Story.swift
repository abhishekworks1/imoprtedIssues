//
//  Story.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 07/10/17.
//  Copyright © 2017 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import ObjectMapper

class UpdatedStories: Mappable {
   
    var stories: [Story]?
   
    required init?(map: Map) {
        
    }
    
    init(stories: [OwnStory]) {
        self.stories = getStories(ownstories: stories)
    }
    
    func getStories(ownstories: [OwnStory]) -> [Story] {
        var stories: [Story] = []
        for story in ownstories {
            stories.append(Story(id: story.id ?? "",url: story.url ?? "", duration: story.duration ?? "", type: story.type ?? "", created: story.created ?? ""))
        }
        return stories
    }
    
    func mapping(map: Map) {
        stories <- map["stories"]
    }
}

class Playlist: Mappable {
    var id: String?
    var name: String?
    var imageUrl: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        name <- map["name"]
        imageUrl <- map["imageUrl"]
    }
}

class Stories: Mappable {
    var id: String?
    var user: StoryUser?
    var stories: [Story]?
    var isSeen: Bool?
    var dateString : String?
    var location : String?
    var paylist: Playlist?
    var addPlayListId: String?
    var indexArrange : Int?
    
    required init?(map: Map) {
        
    }
    
    init(user: StoryOwnUser?, stories: [OwnStory]) {
        self.id = user?.id
        _ = user?.profileType == ProfilePicType.videoType.rawValue ? user?.profileThumbnail : user?.profileImageURL
        self.user = StoryUser(id: user?.id ?? "",channelId: user?.displayName ?? "", profileImageURL: (user?.profileImageURL ?? ""), profileType: user?.profileType ?? 0, profileThumbnail: user?.profileThumbnail ?? "")
        self.stories = getStories(ownstories: stories)
    }
    
    func getStories(ownstories: [OwnStory]) -> [Story] {
        var stories: [Story] = []
        for story in ownstories {
            stories.append(Story(id: story.id ?? "",url: story.url ?? "", duration: story.duration ?? "", type: story.type ?? "", created: story.created ?? ""))
        }
        return stories
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        user <- map["user"]
        stories <- map["stories"]
        paylist <- map["paylist"]
        addPlayListId <- map["addPlayListId"]
        var  date : Date?
        date <- (map["date"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSz"))
        if let date = date {
            let df = DateFormatter()
            df.dateFormat = "dd MMM yyyy"
            dateString = df.string(from: date)
        }
    }
}

class StoryUser: Mappable {
    var id: String?
    var channelId: String?
    var profileImageURL: String?
    var profileType: Int?
    var profileThumbnail : String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init(id: String,channelId: String, profileImageURL: String, profileType:Int, profileThumbnail:String) {
        self.id = id
        self.channelId = channelId
        self.profileImageURL = profileImageURL
        self.profileThumbnail = profileThumbnail
        self.profileType = profileType
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        channelId <- map["channelId"]
        profileImageURL <- map["profileImageURL"]
        profileType <- map["profileType"]
        profileThumbnail <- map["profileThumbnail"]
        
    }
    
}

class BaseStoryAnswerList: Mappable {
    
    var averageAns: Float?
    var emoji: String?
    var option1Count: Int?
    var option2Count: Int?
    var option1Text: String?
    var option2Text: String?
    var question: String?
    var tagType: StoryTagType?
    var answerList: [StoryAnswerList]?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        averageAns <- map["averageAns"]
        if averageAns == nil,
            let aAns = map["averageAns"].currentValue as? NSNumber {
            averageAns = Float(truncating: aAns)
        }
        emoji <- map["emoji"]
        option1Count <- map["option1Count"]
        option2Count <- map["option2Count"]
        option2Text <- map["option2Text"]
        option1Text <- map["option1Text"]
        question <- map["question"]
        tagType <- (map["tagType"],EnumTransform<StoryTagType>())
        answerList <- map["answerList"]
    }
}

class StoryAnswerList: Mappable {
    
    var id: String?
    var answer: String?
    var answerUser: StoryUser?
    var created: String?
    var story: Story?
    var tagId: String?
    var tagType: StoryTagType?
    var user: StoryUser?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        answer <- map["answer"]
        answerUser <- map["answerUser"]
        tagId <- map["tagId"]
        story <- map["story"]
        created <- map["created"]
        tagType <- (map["tagType"],EnumTransform<StoryTagType>())
        user <- map["user"]
    }
    
}

class StoryAnswer: Mappable {
    
    var story: Story?
    var averageAns: Float?
    var totalCount: Int?
    var answer: String?
    var created: String?
    var isAnswer: Bool?
    var answerUser: StoryUser?
    var tagId: String?
    var id: String?
    var tagType: StoryTagType?
    var user: StoryUser?
    var averageOption1: String?
    var averageOption2: String?
    var option1Count: Int?
    var option2Count: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        totalCount <- map["totalCount"]
        averageAns <- map["averageAns"]
        if averageAns == nil,
            let aAns = map["averageAns"].currentValue as? String {
            averageAns = Float(aAns)
        }
        story <- map["story"]
        id <- map["_id"]
        created <- map["created"]
        tagType <- (map["tagType"],EnumTransform<StoryTagType>())
        user <- map["user"]
        answer <- map["answer"]
        isAnswer <- map["isAnswer"]
        answerUser <- map["answerUser"]
        tagId <- map["tagId"]
        averageOption1 <- map["averageOption1"]
        averageOption2 <- map["averageOption2"]
        option1Count <- map["option1Count"]
        option2Count <- map["option2Count"]
    }
}

class LikeStory: Mappable {
    var user: User?
    var type, id, created: String?
    
    required init?(map: Map) {
        
    }
    
    init(id: String?,type: String,created: String,user: User?) {
        self.id = id
        self.type = type
        self.created = created
        self.user = user
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        type <- map["type"]
        created <- map["created"]
        user <- map["user"]
    }
}

class Story: Mappable {
    var id: String?
    var url : String?
    var duration : String?
    var type : String?
    var created : String?
    var user : StoryUser?
    var thumb : String?
    var isViewed: Bool?
    var isFavorite: Bool?
    var viewByUser: [StoryUser]?
    var storyTags: [StoryTags]?
    var publish: Int?
    var updated : String?
    var isShared : Bool?
    var likes: [LikeStory]?
    var commentCount: Int?
    
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
        user <- map["user"]
        thumb <- map["thumb"]
        isViewed <- map["isViewed"]
        isFavorite <- map["isFavorite"]
        viewByUser <- map["viewByUser"]
        storyTags <- map["tag"]
        publish <- map["publish"]
        updated <- map["updated"]
        isShared <- map["isShared"]
        likes <- map["likes"]
        commentCount <- map["commentCount"]
    }
    
}

class StorySliderTag: Mappable {
    
    var question: String?
    var emoji: String?
    var colorStart: String?
    var colorEnd: String?
    var myAns: Float?
    var averageAns: Float?
    var isAnswer: Bool?
    var totalCount: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        question <- map["question"]
        emoji <- map["emoji"]
        colorStart <- map["colorStart"]
        colorEnd <- map["colorEnd"]
        myAns <- map["myAns"]
        averageAns <- map["averageAns"]
        totalCount <- map["totalCount"]
        if averageAns == nil,
            let aAns = map["averageAns"].currentValue as? NSNumber {
            averageAns = Float(truncating: aAns)
        }
        if myAns == nil,
            let mAns = map["myAns"].currentValue as? NSNumber {
            myAns = Float(truncating: mAns)
        }
        isAnswer <- map["isAnswer"]
    }
    
}

class StoryPollOption: Mappable {
    
    var id: String?
    var averageAns: Int?
    var colorEnd: String?
    var colorStart: String?
    var fontSize: Float?
    var optionNumber: Int?
    var text: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        text <- map["text"]
        colorStart <- map["colorStart"]
        colorEnd <- map["colorEnd"]
        fontSize <- map["fontSize"]
        averageAns <- map["averageAns"]
        optionNumber <- map["optionNumber"]
        if averageAns == nil,
            let aAns = map["averageAns"].currentValue as? NSNumber {
            averageAns = Int(truncating: aAns)
        }
        if fontSize == nil,
            let fSize = map["fontSize"].currentValue as? NSNumber {
            fontSize = Float(truncating: fSize)
        }
        if optionNumber == nil,
            let opNumber = map["optionNumber"].currentValue as? NSNumber {
            optionNumber = Int(truncating: opNumber)
        }
    }
    
}

class StoryPollTag: Mappable {
    
    var question: String?
    var totalCount: Int?
    var isAnswer: Bool?
    var myAns: Int?
    var option1Count: Int?
    var option2Count: Int?
    var options: [StoryPollOption]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        question <- map["question"]
        options <- map["options"]
        totalCount <- map["totalCount"]
        isAnswer <- map["isAnswer"]
        myAns <- map["myAns"]
        option1Count <- map["option1Count"]
        option2Count <- map["option2Count"]
        if myAns == nil,
            let myAns = map["myAns"].currentValue as? NSNumber {
            self.myAns = Int(truncating: myAns)
        }
        if totalCount == nil,
            let totalCount = map["totalCount"].currentValue as? NSNumber {
            self.totalCount = Int(truncating: totalCount)
        }
        if option1Count == nil,
            let option1Count = map["option1Count"].currentValue as? NSNumber {
            self.option1Count = Int(truncating: option1Count)
        }
        if option2Count == nil,
            let option2Count = map["option2Count"].currentValue as? NSNumber {
            self.option2Count = Int(truncating: option2Count)
        }
    }
    
}

class StoryAskQuestionTag: Mappable {
    
    var question: String?
    var colorEnd: String?
    var colorStart: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        question <- map["question"]
        colorStart <- map["colorStart"]
        colorEnd <- map["colorEnd"]
    }
    
}

class StoryTags: Mappable, CustomStringConvertible {
    
    var latitude: Double?
    var longitude: Double?
    var id: String?
    var centerY: Float?
    var tagFontSize: Float?
    var scaleY: Float?
    var tagHeight: Float?
    var centerX: Float?
    var scaleX: Float?
    var rotation: Float?
    var tagWidth: Float?
    var tagText: String?
    var tagType: StoryTagType?
    var themeType: Int?
    var videoId: String?
    var postId: String?
    var storyId: String?
    var userId: String?
    var userProfileURL: String?
    var hasRatio: Bool?
    var storyDetail: [Story]?
    var placeId: String?
    var playlistId: String?
    var sliderTag: StorySliderTag?
    var pollTag: StoryPollTag?
    var askQuestionTag: StoryAskQuestionTag?
    
    required init?(map: Map) {
        mapping(map: map)
    }

    func mapping(map: Map) {
        id <- map["_id"]
        latitude <- map["Latitude"]
        if latitude == nil,
            let latitudeValue = map["Latitude"].currentValue as? String {
            latitude = Double(latitudeValue)
        }
        longitude <- map["Longitude"]
        if longitude == nil,
            let longitudeValue = map["Longitude"].currentValue as? String {
            longitude = Double(longitudeValue)
        }
        tagText <- map["tagText"]
        tagType <- (map["tagType"],EnumTransform<StoryTagType>())
        centerY <- map["centerY"]
        if centerY == nil,
            let centerYValue = map["centerY"].currentValue as? NSNumber {
            centerY = Float(truncating: centerYValue)
        }
        scaleY <- map["scaleY"]
        if scaleY == nil,
            let scaleYValue = map["scaleY"].currentValue as? NSNumber {
            scaleY = Float(truncating: scaleYValue)
        }
        tagFontSize <- map["tagFontSize"]
        if tagFontSize == nil,
            let tagFontSizeValue = map["tagFontSize"].currentValue as? NSNumber {
            tagFontSize = Float(truncating: tagFontSizeValue)
        }
        tagHeight <- map["tagHeight"]
        if tagHeight == nil,
            let tagHeightValue = map["tagHeight"].currentValue as? NSNumber {
            tagHeight = Float(truncating: tagHeightValue)
        }
        centerX <- map["centerX"]
        if centerX == nil,
            let centerXValue = map["centerX"].currentValue as? NSNumber {
            centerX = Float(truncating: centerXValue)
        }
        scaleX <- map["scaleX"]
        if scaleX == nil,
            let scaleXValue = map["scaleX"].currentValue as? NSNumber {
            scaleX = Float(truncating: scaleXValue)
        }
        rotation <- map["rotation"]
        if rotation == nil,
            let rotationValue = map["rotation"].currentValue as? NSNumber {
            rotation = Float(truncating: rotationValue)
        }
        tagWidth <- map["tagWidth"]
        if tagWidth == nil,
            let tagWidthValue = map["tagWidth"].currentValue as? NSNumber {
            tagWidth = Float(truncating: tagWidthValue)
        }
        themeType <- map["themeType"]
        videoId <- map["videoId"]
        postId <- map["postId"]
        storyId <- map["storyId"]
        userId <- map["userId"]
        userProfileURL <- map["userProfileURL"]
        hasRatio <- map["hasRatio"]
        placeId <- map["placeId"]
        playlistId <- map["playListId"]
        sliderTag <- map["sliderTag"]
        pollTag <- map["pollTag"]
        askQuestionTag <- map["askQuestionTag"]
    }
    
}

class OwnStory: Mappable {
    var id: String?
    var user: StoryOwnUser?
    var stories: [Story]?
    var url : String?
    var duration : String?
    var type : String?
    var created : String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        user <- map["user"]
        stories <- map["stories"]
        url <- map["url"]
        duration <- map["duration"]
        type <- map["type"]
        created <- map["created"]
    }
    
}

class StoryOwnUser: Mappable {
    var id: String?
    var displayName: String?
    var profileImageURL: String?
    var profileType : Int = 1
    var profileThumbnail:String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        displayName <- map["displayName"]
        profileImageURL <- map["profileImageURL"]
        profileThumbnail <- map["profileThumbnail"]
        profileType <- map["profileType"]
    }
    
}
