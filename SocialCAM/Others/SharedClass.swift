//
//  SharedClass.swift
//  ProManager
//
//  Created by Viraj Patel on 16/09/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

protocol AppMode_Enum  {
    var description: String { get }
}

enum AppMode: Int, AppMode_Enum {
    case free = 0
    case basic
    case advanced
    case professional
    
    var description: String {
       switch self {
    case .free:
       return "Free"
    case .basic:
       return "Basic"
    case .advanced:
       return "Advanced"
    case .professional:
          return "Professional"
    default:
          return "Free"
       }
    }
}

enum ShapeType: Int {
    case heart
    case hexa
    case star
}

enum SocialShare: Int {
    case facebook = 0
    case twitter
    case instagram
    case snapchat
    case youtube
    case tiktok
    case storiCam
    case storiCamPost
}

enum SocialLogin: Int, CaseIterable {
    case facebook = 0
    case twitter
    case instagram
    case snapchat
    case youtube
    case storiCam
    
    static let allValues = [facebook, twitter, instagram, snapchat, youtube, storiCam]
}

public enum CameraMode: Int {
    case normal = 0
    case basicCamera
    case boomerang
    case slideshow
    case collage
    case handsfree
    case custom
    case capture
    case fastMotion
    case fastSlowMotion
    case timer
    case photoTimer
    case quizImage
    case quizVideo
    case multiplePhotos
    case promo
}

public enum RecordingType {
    case boom
    case video
    case image
    case rewind
    case handFree
    case timer
    case photoTimer
    case stopMotion
    case custom
    case slideShow
    case collage
    case quizImage
    case quizVideo
    case multiplePhotos
    case customImageVideoSave
}

enum SearchListType: Int {
    case hashSearch
    case locationSeacrh
}

enum BrowserType: Int {
    case following = 1
    case trending = 2
    case featured = 7
    case media = 4
    case family = 5
    case custom = 6
    case favourite = 3
}

enum ChannelsType: Int {
    case channels = 1
    case packages = 2
}

enum RequestStatus: Int {
    case pending = 0
    case accept = 1
    case reject = 2
}

enum PostTypes: String {
    case text = "text"
    case image = "image"
    case video = "video"
    case postwall = "postwall"
    case shared = "Shared"
    case youtube = "youtube"
    case location = "Location"
}

enum FileExtension: String {
    case jpg = ".jpg"
    case png = ".png"
    case mov = ".mov"
    case mp4 = ".mp4"
}

enum OpeningScreen: Int {
    case camera = 0
    case dashboard
    case chat
}

enum GuidelineTypes: Int {
    case solidLine = 0
    case dottedLine
    case dashedLine
}

enum GuidelineThickness: Int {
    case small = 1
    case medium = 3
    case thick = 5
}

public enum ImageFormat {
    case PNG
    case JPEG(Float)
}

enum ProfilePicType: Int {
    case imageType = 1
    case videoType = 2
}

public struct ResponseType {
    static let success = "success"
}

public struct Messages {
    static let kOK = "OK"
    static let kEmptyAlbumName = "Please enter gallery name."
    static let kundefineError = "Something went wrong! Please try again later"
    static let kSelectFrnd = "Please select atleast one friend."
    static let kNotLoginMsg = "User is not login. Please login to SocialCam and try again later."
}

public struct FetchDataBefore {
    static let bottomMargin: CGFloat = 900.0
}

public struct Reactions {
    static let reactionLIKE = "like"
    static let reactionLOVE = "love"
    static let reactionLAUGH = "laugh"
    static let reactionWOW = "wow"
    static let reactionSAD = "sad"
    static let reactionANGRY = "angry"
}

struct TrimError: Error {
    let description: String
    let underlyingError: Error?
    
    init(_ description: String, underlyingError: Error? = nil) {
        self.description = "TrimVideo: " + description
        self.underlyingError = underlyingError
    }
}

public struct Paths {
    static let getViralvids = "viralvids"
    static let getSplashImages = "getSplashImages"
    static let login = "auth/signin"
    static let verifyChannel = "auth/verifyField"
    static let signUp = "auth/signupEmail"
    static let search = "auth/searchChannels"
    static let getCategories = "auth/getCategories"
    static let updateProfile = "users/updateProfile"
    static let connectSocial = "users/addSocialConnection"
    static let removeSocialConnection = "users/removeSocialConnection"
    static let searchUser = "users/searchChannel"
    static let topSearch = "users/topSearch"
    static let socailLogin = "auth/signup"
    static let getProfile = "users/getProfile"
    static let getProfileByName = "users/getProfileByChannel"
    static let getPlaceHolder = "auth/getPlaceHolder"
    static let forgotPassword = "auth/forgot"
    static let newUserAdded = "new-user-added"
    static let setChannel = "set-channel"
    static let confirmEmail = "confirm-email"
    static let socialPost = "social-post"
    static let doLogin = "do-login"
    static let getuser = "get-user"
    static let followChannel = "follow/followChannel"
    static let unfollowChannel = "follow/unfollowChannel"
    static let getDashboardPosts = "articles/getPosts"
    static let getPostComments = "articles/getComments"
    static let getPostComment = "articles/getCommentDetail"
    static let getCommentReplies = "articles/getReplies"
    static let addReply = "articles/addReply"
    static let writePost = "articles/write"
    static let addComment = "articles/addComment"
    static let likePost = "articles/likePost"
    static let disLikePost = "articles/disLikePost"
    static let getConfiguration = "admin/getConfigurations"
    static let likeComment = "articles/likeComment"
    static let disLikeComment = "articles/disLikeComment"
    static let likeReply = "articles/likeReply"
    static let disLikeReply = "articles/disLikeReply"
    static let getAlbums = "albums/getAlbums"
    static let createAlbum = "albums/createAlbum"
    static let getMyPost = "articles/getWritten"
    static let getMyYoutubePost = "articles/getMyYoutubePost"
    static let blockUser = "users/blockUser"
    static let getBlockedUser = "users/blockedUsers"
    static let repotPost = "articles/blockPost"
    static let deletePost = "articles/"
    static let getFriends = "users/getFriends"
    static let updateAlbum = "albums/"
    static let tagUserSearch = "users/searchChannelIds"
    static let getFollowers = "follow/getFollowers"
    static let getFollowings = "follow/getFollowing"
    static let searchHash = "users/searchTags"
    static let getHashPost = "articles/searchTags"
    static let getLocationPost = "articles/searchLocations"
    static let getHashStories = "stories/searchTags"
    static let getLocationStories = "stories/searchStoryLocation"
    static let shreInAppPost = "articles/share/"
    static let youTubeKeyWordSerch = "search"
    static let youTubeDetail = "videos"
    static let youTubechannels = "channels"
    static let youTubeChannelSearch = "search"
    static let youTubeRatting = "videos/rate"
    static let getStories = "stories/getStories"
    static let getOwnStory = "storyByUser"
    static let getEmojis = "getFeelings"
    static let createStory = "stories/createStory"
    static let getFollowingNotification = "users/getFollowerNotifications"
    static let getYouNotification = "users/getNotifications"
    static let getMediaStories = "stories/getMediaStories"
    static let verifyUserAccount = "users/verifyUserAccount"
    static let resendVerificationLink = "auth/resendVerificationLink"
    static let storyByUser = "/api/storyByUser"
    static let deleteComment = "articles/deleteComment"
    static let deleteReply = "articles/deleteReply"
    static let getPostDetail = "articles/"
    static let logOut = "users/logout"
    static let updatePost = "articles/"
    static let getStoryFavoriteList = "stories/favoriteList"
    static let getChannelSuggestion = "channelSuggestion"
    static let addToCart = "users/addToCart"
    static let getCart = "users/getCart"
    static let deleteFromCart = "users/deleteFromCart"
    static let getChannelList = "users/getChannelLists"
    static let addPayment = "users/addPayment"
    static let checkChannelExists = "users/checkChannelExists"
    static let addAsFavorite = "articles/addAsFavorite"
    static let getFavoriteList = "articles/favoriteList"
    static let addHashTag = "hashtags"
    static let increaseHashtagCount = "hashtags/increaseHashtagCount"
    static let getPackage = "users/getPackage"
    static let addPackage = "users/addPackage"
    static let getStoryByID = "stories"
    static let createPlaylist = "playlists"
    static let getPlaylist = "playlists"
    static let addToPlaylist = "addToPlaylist"
    static let getHashTagDetail = "articles/getHashTagDetail"
    static let followHashTag = "articles/followHashtag"
    static let getPlaylistStory = "getPlaylist"
    static let deletePlaylist = "playlists/"
    static let deletePlaylistItem = "deletePlaylistItem"
    static let getFollowedHashPostStory = "hashtags/getFollowedPostStory"
    static let copyPlayList = "copyPlayList"
    static let getPlayListInfo = "playlists/"
    static let followPlaylist = "followPlaylist"
    static let likePlaylist = "likeplaylist"
    static let getPlayListComments = "playlists/getComments"
    static let addPlayListComment = "playlists/addComment"
    static let deletePlaylistComment = "playlists/deleteComment"
    static let likePlayListComment = "playlists/likeComment"
    static let reArrangePlaylist = "reArrangePlaylist"
    static let deleteStories = "stories/deleteStories"
    static let getTaggedStories = "tags/getStories"
    static let getTaggedFeed = "tags/getPosts"
    static let getRelationsData = "families/getMasterRelationData"
    static let addFamilyMember = "families"
    static let getFamilyMember = "getFamilyMemberList"
    static let acceptRejectFamilyRequest = "updateFamilyRequest"
    static let getFamilyStories = "families/getStories"
    static let getFamilyFeed = "families/getPosts"
    static let addAsVip = "users/addAsVip"
    static let getVipList = "users/getVipList"
    static let getVipUserPostList = "users/getVipUserPostList"
    static let getVipUserStoryList = "users/getVipUserStoryList"
    static let youtubeChannelSubscribe = "subscriptions?part=snippet"
    static let getyoutubeSubscribedChannel = "subscriptions?part=snippet"
    static let unsubscribeYoutubeChannel = "subscriptions"
    static let reportUser = "users/reportUser"
    static let createQuiz = "quizzes"
    static let updateQuiz = "quizzes/"
    static let addQuizQuestionAnswer = "quizzes/addQuestionAnswer"
    static let getQuizAnswerList = "quizzes/getAnswerList"
    static let getQuizList = "quizzes/getQuizList"
    static let getQuizQuestionList = "quizzes/getAnswerList"
    static let addQuizAnswer = "quizzes/addQuizAnswer"
    static let getYoutubeCategoty = "videoCategories"
    static let uploadYoutubeVideo = "videos?part=snippet&status"
    static let deleteQuiz = "quizzes/"
    static let addAnswers = "quizzes/addAnswer"
    static let moveStoryIntoChannel = "stories/addToOtherChannel"
    static let pushOnDownload = "stories/pushOnDownload"
    static let storieLike = "stories/like"
    static let getCommentsStory = "getComments"
    
}

public struct APIHeaders {
    
    let headerWithToken =  ["Content-Type": "application/json",
                                   "userid": Defaults.shared.currentUser?.id ?? "",
                                   "deviceType": "1",
                                   "x-access-token": Defaults.shared.sessionToken ?? "" ]
    let headerWithoutAccessToken = ["Content-Type": "application/json",
                                           "deviceType": "1"]
}

public struct Constant {
    
    struct AWS {
        // Client Bucket
        static let poolID = "us-west-2:4918c1f8-d173-4668-8891-d6892a147259"
        static let baseUrl = "https://s3-us-west-2.amazonaws.com/"
        static let NAME = "spinach-cafe"
        static let FOLDER = "main-image"
        static let URL = "http://\(Constant.AWS.NAME).s3.amazonaws.com/"
    }
    
    struct URLs {
        #if DEBUG
        static let base = "https://stage-api.austinconversionoptimization.com/api/"
        #else
        static let base = "https://demo-api.austinconversionoptimization.com/api/"
        #endif
        static let cabbage = "https://staging.cabbage.cafe/api/v1/"
        static let faq = "https://www.google.com"
        static let twitter = "https://api.twitter.com/1.1/"
        static let youtube = "https://www.googleapis.com/youtube/v3/"
        #if SOCIALCAMAPP
            static let websiteURL = "https://socialcam.iicc.online"
        #elseif VIRALCAMAPP || VIRALCAMLITEAPP
            static let websiteURL = "https://viralcam.iicc.online"
        #elseif SOCCERCAMAPP
            static let websiteURL = "https://soccercam.iicc.online"
        #elseif FUTBOLCAMAPP
            static let websiteURL = "https://futbolcam.iicc.online"
        #elseif PIC2ARTAPP
            static let websiteURL = "https://pic2art.iicc.online"
        #elseif BOOMICAMAPP
            static let websiteURL = "https://boomicam.iicc.online"
        #elseif TIMESPEEDAPP
            static let websiteURL = "https://timespeed.iicc.online"
        #elseif FASTCAMAPP || FASTCAMLITEAPP
            static let websiteURL = "https://fastcam.iicc.online"
        #elseif QUICKCAMLITEAPP
            static let websiteURL = "https://quickcam.iicc.online"
        #else
            static let websiteURL = Defaults.shared.currentUser?.viralcamReferralLink ?? "https://viralcam.iicc.online"
        #endif
        static let socialCamWebsiteURL = "https://socialcam.iicc.online"
        static let pic2ArtWebsiteURL = "https://pic2art.iicc.online"
        static let soccercamWebsiteURL = "http://soccercam.iicc.online"
        static let futbolWebsiteURL = "http://futbolcam.iicc.online"
    }
    
    struct Application {
        #if VIRALCAMAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "ViralCam"
        static let simformIdentifier: String = "com.simform.viralcam"
        static let proModeCode: String = "viralcam2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/sk1foNLO")
        static let splashBG = UIImage(named: "viralcamSplashBG")!
        static let appIcon = UIImage(named: "viralCamSplashLogo")!
        #elseif SOCCERCAMAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "SoccerCam"
        static let simformIdentifier: String = "com.simform.SoccerCam"
        static let proModeCode: String = "soccercam2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/1dRtt5SV")
        static let splashBG = UIImage(named: "footballCamSplashBG")!
        static let appIcon = UIImage(named: "soccerCamSplashBG")!
        #elseif FUTBOLCAMAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "FutbolCam"
        static let simformIdentifier: String = "com.simform.SoccerCam"
        static let proModeCode: String = "futbolcam2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/1dRtt5SV")
        static let splashBG = UIImage(named: "footballCamSplashBG")!
        static let appIcon = UIImage(named: "futbolCamSplashLogo")!
        #elseif QUICKCAMAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "QuickCam"
        static let simformIdentifier: String = "com.simform.QuickCam"
        static let proModeCode: String = "quickcam2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/1dRtt5SV")
        static let splashBG = UIImage(named: "quickCamSplashBG")!
        static let appIcon = UIImage(named: "quickCamSplashLogo")!
        #elseif SNAPCAMAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "SnapCam"
        static let simformIdentifier: String = "com.simform.SnapCam"
        static let proModeCode: String = "snapcam2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/MTVSBnbC")
        static let splashBG = UIImage(named: "snapCamSplash")!
        static let appIcon = UIImage(named: "snapCamSplashIcon")!
        #elseif PIC2ARTAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "PIC2ART"
        static let simformIdentifier: String = "com.simform.Pic2Art"
        static let proModeCode: String = "pic2art2020"
        static let pic2artProModeCode: String = "pic2art2020pro!!"
        static let publicLink = URL(string: "https://testflight.apple.com/join/hshtsh9O")
        static let splashBG = UIImage(named: "Pic2ArtSplash")!
        static let appIcon = UIImage(named: "Pic2ArtSplashIcon")!
        #elseif BOOMICAMAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "BOOMICAM"
        static let simformIdentifier: String = "com.simform.BoomiCam"
        static let proModeCode: String = "boomicam2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/kYCCo1AW")
        static let splashBG = UIImage(named: "boomiCamSplashBG")!
        static let appIcon = UIImage(named: "boomiCamSplashLogo")!
        #elseif TIMESPEEDAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "TIMESPEED"
        static let simformIdentifier: String = "com.simform.timespeed"
        static let proModeCode: String = "timespeed2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/MhCuGbHp")
        static let splashBG = UIImage(named: "timeSpeedSplashBG")!
        static let appIcon = UIImage(named: "timeSpeedSplashLogo")!
        #elseif FASTCAMAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "ViralCam"
        static let simformIdentifier: String = "com.simform.fastCam"
        static let proModeCode: String = "fastcam2020"
        static let publicLink = URL(string: "")
        static let splashBG = UIImage(named: "footballCamSplashBG")!
        static let appIcon = UIImage(named: "ssuTimeSpeed")!
        #elseif SOCIALCAMAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "SocialCam"
        static let simformIdentifier: String = "com.simform.storiCamPro"
        static let proModeCode: String = "socialcam2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/6zE0nt7P")
        static let splashBG = UIImage(named: "socialCamSplashBG")!
        static let appIcon = UIImage(named: "socialCamSplashLogo")!
        #elseif VIRALCAMLITEAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "ViralCam Lite"
        static let simformIdentifier: String = "com.simform.viralcamLite"
        static let proModeCode: String = "socialcam2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/6zE0nt7P")
        static let splashBG = UIImage(named: "viralcamSplashBG")!
        static let appIcon = UIImage(named: "viralcamLiteSplash")!
        #elseif FASTCAMLITEAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "FastCam Lite"
        static let simformIdentifier: String = "com.simform.fastCamLite"
        static let proModeCode: String = "socialcam2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/6zE0nt7P")
        static let splashBG = UIImage(named: "fastcamLiteSplashBG")!
        static let appIcon = UIImage(named: "fastcamLiteWatermarkLogo")!
        #elseif QUICKCAMLITEAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "QuickCam Lite"
        static let simformIdentifier: String = "com.simform.fastCamLite"
        static let proModeCode: String = "socialcam2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/6zE0nt7P")
        static let splashBG = UIImage(named: "quickcamLiteLaunchScreenBG")!
        static let appIcon = UIImage(named: "quickcamliteSplashLogo")!
        #endif
        
        static let groupIdentifier: String = "group.com.simform.storiCamPro"
        static let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        static let appBuildNumber: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
          
        static let imageIdentifier: String = "www.google.com"
        static let splashImagesFolderName: String = "SplashImages"

        static let referralLink = Defaults.shared.currentUser?.viralcamReferralLink ?? Constant.URLs.websiteURL
    }
    
    struct PayPalMobile {
        static let productionKey: String = "AQWNB7gjYT8WwL21H4ZWDvPuK1zgwtO0f0VEQzjKJEGs0aUyNxUEULJzQr9Ni_W-d_igQiVe78CV08-Z"
        static let sandboxKey: String = "AU9oTOQVlZWA0dgy6e8MHb54YiPrMKaYXkl5zyquZ0Tj277I2a1d-uNTmyt0kCs5QkbQSFRwIM_Bz4c3"
    }
    
    struct STKStickersManager {
        static let apiKey: String = "70e36a7b2ca143977e700a83dc03c82e"
        static let userID: String = UUID().uuidString
    }
    
    struct TWTRTwitter {
        #if SOCIALCAMAPP
            static let consumerKey: String = "y39BclEMDbGXVzAaiXv55PGrn"
            static let consumerSecret: String = "o4NcSHnBPaS1jeNW4xjMGg2WTVHm3HUV7WPsCt3b4nRWHa2Kcf"
        #else
            static let consumerKey: String = "DJCr4ckk2RhVWckLrw524qcou"
            static let consumerSecret: String = "w20x8fh0Cqgh4iJDYscTMmlzMEalcgouPqHnuRoXb6rdzA7Uzk"
        #endif
    }
    
    struct Instagram {
        #if SOCIALCAMAPP
            static let redirectUrl = "https://storicam-pro.firebaseapp.com/__/auth/handler"
            static let clientId = "2576474045942603"
            static let clientSecret = "65d21fa18fd9e28142f2384e654ee5d3"
        #elseif TIMESPEED
            static let redirectUrl = "https://timespeed-ae42c.firebaseapp.com/__/auth/handler"
            static let clientId = "735709803849520"
            static let clientSecret = "31178bad36620198c990029030b39aa8"
        #elseif PIC2ARTAPP
            static let redirectUrl = "https://pic2art-46a45.firebaseapp.com/__/auth/handler"
            static let clientId = "548440479177267"
            static let clientSecret = "8ce8dcb63d5115475c3167788a4086c7"
        #elseif BOOMICAMAPP
            static let redirectUrl = "https://boomicam-c281f.firebaseapp.com/__/auth/handler"
            static let clientId = "731166734353630"
            static let clientSecret = "18873cdad99dd8dc5f077c52499197cf"
        #elseif FASTCAMAPP
            static let redirectUrl = "https://fastcam-475e3.firebaseapp.com/__/auth/handler"
            static let clientId = "269809577621901"
            static let clientSecret = "249aca0886ce40cb8a816c108aa1a7cd"
        #elseif SOCCERCAMAPP
            static let redirectUrl = "https://soccercam-d15a0.firebaseapp.com/__/auth/handler"
            static let clientId = "361365258591189"
            static let clientSecret = "dd1b754b16bb106217d18e8935b46c8c"
        #elseif FUTBOLCAMAPP
            static let redirectUrl = "https://futbolcam-ddf06.firebaseapp.com/__/auth/handler"
            static let clientId = "1431217550411859"
            static let clientSecret = "39554fc089d5154b5ee77499e549eb65"
        #elseif QUICKCAMAPP
        static let redirectUrl = "https://quickcam-fde9d.firebaseapp.com/__/auth/handler"
        static let clientId = "896406730769747"
        static let clientSecret = "47bfa6fac6eef802ab5346f896013a9c"
        #elseif SNAPCAMAPP
        static let redirectUrl = "https://snapcam-1594222751745.firebaseapp.com/__/auth/handler"
        static let clientId = "649595362296150"
        static let clientSecret = "2d0401703d64b6fc1546249cfd1693d9"
        #else
            static let redirectUrl = "https://viralcam-c3c84.firebaseapp.com/__/auth/handler"
            static let clientId = "228138878240656"
            static let clientSecret = "b82cdaa4c3b7755248721767b0318480"
        #endif
        
        static let link = "instagram://library?LocalIdentifier="
        static let authorizeUrl = "https://api.instagram.com/oauth/authorize/"
        
        static let scope = "user_profile,user_media"
        static let basicUrl = "https://api.instagram.com/"
        static let graphUrl = "https://graph.instagram.com/"
        static let baseUrl = "https://www.instagram.com/"
    }
    
    struct AppCenter {
        #if SOCIALCAMAPP
            static let apiKey: String = "b8e186c4-5b4e-45a2-96e5-7904b346ab00"
        #else
            static let apiKey: String = "83e20bd1-613c-481f-86bd-5906c12b95d9"
        #endif
    }
    
    struct GoogleService {
        #if SOCIALCAMAPP
            static let serviceKey: String = "AIzaSyByYKvdBZiTuBogp55PWogJ_NDokbD_8hg"
            static let placeClientKey: String = "AIzaSyBOPskgf7r5ylpQBZv6GMWXcyl1BU5ZTbo"
        #elseif VIRALCAMAPP
            static let serviceKey: String = "AIzaSyBbkguZz4hljlOd-Cs0u5b2GyVUNt7Y1m4"
            static let placeClientKey: String = "AIzaSyBbkguZz4hljlOd-Cs0u5b2GyVUNt7Y1m4"
        #elseif SOCCERCAMAPP
            static let serviceKey: String = "AIzaSyD8EqdyN152SfMvOhB4nUCRk_5aWoP-U1A"
            static let placeClientKey: String = "AIzaSyD8EqdyN152SfMvOhB4nUCRk_5aWoP-U1A"
        #elseif FUTBOLCAMAPP
        static let serviceKey: String = "AIzaSyCF0PBGqnCPVtKFYdYaHv1HYN5X-j4R7U0"
        static let placeClientKey: String = "AIzaSyCF0PBGqnCPVtKFYdYaHv1HYN5X-j4R7U0"
        #elseif QUICKCAMAPP
        static let serviceKey: String = "AIzaSyDb7qoLWUdqXgq2rdEvpxFg95iE8Vh20Pc"
        static let placeClientKey: String = "AIzaSyDb7qoLWUdqXgq2rdEvpxFg95iE8Vh20Pc"
        #elseif SNAPCAMAPP
        static let serviceKey: String = "AIzaSyD9_sy-klWwfrLTrT4ub-E4fC-iwnzoCG0"
        static let placeClientKey: String = "AIzaSyD9_sy-klWwfrLTrT4ub-E4fC-iwnzoCG0"
        #elseif PIC2ARTAPP
            static let serviceKey: String = "AIzaSyBOBVwEf8bMfwCreZS-IBAEqm57A0szOfg"
            static let placeClientKey: String = "AIzaSyBOBVwEf8bMfwCreZS-IBAEqm57A0szOfg"
        #elseif TIMESPEED
            static let serviceKey: String = "AIzaSyA0GnKcXJS6uFQUm_SASEsCaGgoeJhq2QA"
            static let placeClientKey: String = "AIzaSyBOBVwEf8bMfwCreZS-IBAEqm57A0szOfg"
        #elseif BOOMICAMAPP
            static let serviceKey: String = "AIzaSyBLzWJnjwjKkMwBvoQ0FvXDAXTWd_AmrD4"
            static let placeClientKey: String = "AIzaSyBLzWJnjwjKkMwBvoQ0FvXDAXTWd_AmrD4"
        #elseif FASTCAMAPP
            static let serviceKey: String = "AIzaSyARGjWmJYjfSyK8UAf_dJW4YLqq220hnCM"
            static let placeClientKey: String = "AIzaSyARGjWmJYjfSyK8UAf_dJW4YLqq220hnCM"
        #else
            static let serviceKey: String = "AIzaSyBOBVwEf8bMfwCreZS-IBAEqm57A0szOfg"
            static let placeClientKey: String = "AIzaSyBOBVwEf8bMfwCreZS-IBAEqm57A0szOfg"
        #endif
        static let youtubeScope: String = "https://www.googleapis.com/auth/youtube.force-ssl"
    }
    
    struct OpenWeather {
        static let apiKey: String = "004230507a06e61af439bd7c564e5441"
    }
    
    struct Sentry {
        static let dsn = "https://e7751d4eaf0746dab650503adbb943fa@sentry.io/1548827"
    }
    
}

class StoryTagGradientLayer: CAGradientLayer { }
#if !IS_SHAREPOST && !IS_MEDIASHARE && !IS_VIRALVIDS && !IS_SOCIALVIDS && !IS_PIC2ARTSHARE
class BaseQuestionTagView: BaseStoryTagView { }
#endif

// MARK: - Control
public enum Control {
    case crop
    case sticker
    case draw
    case text
    case save
    case share
    case clear
}

enum SlideShowExportType {
    case outtakes
    case notes
    case chat
    case feed
    case story
    case sendChat
}

#if !IS_SHAREPOST && !IS_MEDIASHARE && !IS_VIRALVIDS  && !IS_SOCIALVIDS && !IS_PIC2ARTSHARE
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
        case (.shareYoutube, .shareYoutube):
            return true
        case (let .shareFeed(lhsPostID), let .shareFeed(rhsPostID)):
            return (lhsPostID == rhsPostID)
        case (let .shareStory(lhsStoryID), let .shareStory(rhsStoryID)):
            return (lhsStoryID == rhsStoryID)
        case (let .sharePlaylist(lhsPlaylist), let .sharePlaylist(rhsPlaylist)):
            if let lhsPlayListId = lhsPlaylist.id,
                let rhsPlayListId = rhsPlaylist.id {
                return lhsPlayListId == rhsPlayListId
            } else {
                return false
            }
        case (.replyStory, .replyStory):
            return true
        default:
            return false
        }
    }
}
#endif

enum StorySelectionType {
    case image(image: UIImage)
    case video(fileURL: URL)
    case error(error: Error)
}

enum VideoSpeedType: Equatable {
    
    static func ==(lhs: VideoSpeedType, rhs: VideoSpeedType) -> Bool {
        switch (lhs, rhs) {
        case (VideoSpeedType.normal, VideoSpeedType.normal):
            return true
        case (VideoSpeedType.slow(let scaleFactor), VideoSpeedType.slow(let scaleFactor2)):
            if scaleFactor == scaleFactor2 {
                return true
            }
            return false
        case (VideoSpeedType.fast(let scaleFactor), VideoSpeedType.fast(let scaleFactor2)):
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

enum StoryType: String {
    case image = "image"
    case video = "video"
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
    case image
    case video
    case images
}

enum CurrentMode: Int {
    case frames
    case photos
    case border
    case space
    case background
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
    
    static var data: [StyleData] {
        var styleData: [StyleData] = []
        for index in 0...43 {
            styleData.append(StyleData(name: "", image: UIImage(named: "styletransfer_\(index)")!, styleImage: nil))
        }
        return styleData
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

class TrasparentTagView: UIView { }
