//
//  StoryCamShared.swift
//  ProManager
//
//  Created by Viraj Patel on 23/10/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit
import TGPControls

extension TGPDiscreteSlider {
    var speedType: VideoSpeedType {
        set { }
        get {
            switch value {
            case 0:
                return .slow(scaleFactor: 3.0)
            case 1:
                return .slow(scaleFactor: 2.0)
            case 2:
                return .normal
            case 3:
                return .fast(scaleFactor: 2.0)
            case 4:
                return .fast(scaleFactor: 3.0)
            case 5:
                return .fast(scaleFactor: 4.0)
            default:
                return .normal
            }
        }
    }
}

enum StoriCamType: Equatable {
    case story
    case chat
    case feed
    case shareYoutube(postData: CreatePostData)
    case shareFeed(postID: String)
    case shareStory(storyID: String)
    case sharePlaylist(playlist: GetPlaylist)
    
    case replyStory(question: String, answer: String)
    
    static func == (lhs: StoriCamType, rhs: StoriCamType) -> Bool {
        switch (lhs, rhs) {
        case (.story, .story), (.chat, .chat), (.feed, .feed):
            return true
        case (.shareYoutube(_), .shareYoutube(_)):
            return true
        case (let .shareFeed(lhsPostID), let .shareFeed(rhsPostID)):
            return (lhsPostID == rhsPostID)
        case (let .shareStory(lhsStoryID), let .shareStory(rhsStoryID)):
            return (lhsStoryID == rhsStoryID)
        case (let .sharePlaylist(lhsPlaylist), let .sharePlaylist(rhsPlaylist)):
            if let lhsPlayListId = lhsPlaylist._id,
                let rhsPlayListId = rhsPlaylist._id {
                return lhsPlayListId == rhsPlayListId
            } else {
                return false
            }
        case (.replyStory(_), .replyStory(_)):
            return true
        default:
            return false
        }
    }
}


enum StorySelectionType {
    case image(image: UIImage)
    case video(fileURL: URL)
    case error(error: Error)
}

enum VideoSpeedType: Equatable {
    
    static func ==(lhs: VideoSpeedType, rhs: VideoSpeedType) -> Bool {
        switch (lhs,rhs) {
        case (VideoSpeedType.normal,VideoSpeedType.normal):
            return true
        case (VideoSpeedType.slow(let scaleFactor),VideoSpeedType.slow(let scaleFactor2)):
            if scaleFactor == scaleFactor2 {
                return true
            }
            return false
        case (VideoSpeedType.fast(let scaleFactor),VideoSpeedType.fast(let scaleFactor2)):
            if scaleFactor == scaleFactor2 {
                return true
            }
            return false
        default: return false
        }
    }
    
    case normal
    case slow(scaleFactor: Float)
    case fast(scaleFactor: Float)
}



enum StoriType: Int {
    case `default` = 0
    case collage
    case slideShow
    case review
    case gif
    case meme
    case shared
}

enum PublishMode: Int {
    case publish = 1
    case unPublish = 0
}

enum TimerType: Int {
    case timer = 1
    case segmentLength
    case pauseTimer
    case photoTimer
}

enum StoryTagState: Int {
    case white = 0
    case blur
    case whiteAlpha
}

enum StoryTagType: Int {
    case hashtag = 0
    case mension
    case location
    case youtube
    case feed
    case story
    case playlist
    case link
    case slider
    case poll
    case askQuestion
}

enum CollectionMode {
    case effect
    case style
}

enum ProMediaType {
    case Image
    case Video
    case Images
}

enum CurrentMode: Int {
    case frames
    case photos
}

protocol CollageMakerVCDelegate: class {
    func didSelectImage(image: UIImage)
}

class EffectData {
    var name: String
    var image: UIImage
    var path: String

    init(name: String, image: UIImage, path: String) {
        self.name = name
        self.image = image
        self.path = path
    }
}

class SelectedTimer: Codable, SaveUserDefaultsProtocol {
    
    var value: String = ""
    var selectedRow: Int = 0
    
    init(value: String, selectedRow: Int) {
        self.value = value
        self.selectedRow = selectedRow
    }
    
}

class StyleData {
    var name: String
    var image: UIImage
    var styleImage: UIImage?
    var isSelected = false
    
    init(name: String, image: UIImage, styleImage: UIImage?) {
        self.name = name
        self.image = image
        self.styleImage = styleImage
    }
}


protocol OuttakesTakenDelegate: class {
    func didTakeOuttakes(_ message: String)
}

protocol StorySelectionDelegate: class {
    func didSelectStoryWith(_ type: StorySelectionType)
    func didSelectFeedMedia(medias: [FilterImage])
}

extension StorySelectionDelegate {
    func didSelectFeedMedia(medias: [FilterImage]) { }
    func didSelectStoryWith(_ type: StorySelectionType) { }
}

protocol ShowReactionAlert: class {
    func showAlert()
}
