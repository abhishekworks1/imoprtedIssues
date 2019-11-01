//
//  CreatePostData.swift
//  ProManager
//
//  Created by Viraj Patel on 16/09/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

class CreatePostData {
    
    var type: String
    var text: String?
    var isChekedIn: Bool
    var userID: String
    var mediaData: [[String:Any]]?
    var youTubeData: [String:Any]?
    var wallTheme: [String:Any]?
    var albumId: String?
    var checkedInData: [String:Any]?
    var hashTags: [String]?
    var privacy: String?
    var friendExcept: [String]?
    var friendsOnly: [String]?
    var feelingType: String?
    var feelings: [[String:Any]]?
    var previewUrlData: [String: Any]?
    
    init(type: String, text: String?, isChekedIn: Bool, userID: String, mediaData: [[String:Any]]?, youTubeData: [String:Any]?, wallTheme: [String:Any]?, albumId: String?, checkedInData: [String:Any]?, hashTags: [String]?, privacy: String?, friendExcept: [String]?, friendsOnly: [String]?, feelingType: String?, feelings: [[String:Any]]?, previewUrlData: [String: Any]?) {
        self.type = type
        self.text = text
        self.isChekedIn = isChekedIn
        self.userID = userID
        self.mediaData = mediaData
        self.youTubeData = youTubeData
        self.wallTheme = wallTheme
        self.albumId = albumId
        self.checkedInData = checkedInData
        self.hashTags = hashTags
        self.privacy = privacy
        self.friendExcept = friendExcept
        self.friendsOnly = friendsOnly
        self.feelingType = feelingType
        self.feelings = feelings
        self.previewUrlData = previewUrlData
    }
}
