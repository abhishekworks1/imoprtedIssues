//
//  ProManagerApi.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 17/05/17.
//  Copyright © 2017 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import Moya_ObjectMapper
import RxSwift
import ObjectMapper

public enum ProManagerApi {
    case logIn(email: String, password: String, deviceToken: String?)
    case verifyChannel(q: String, type: String)
    case signUp(email: String, password: String, channel: String, refChannel: String, isBusiness: Bool, socialId: String?, provider: String?, channelName: String, about: String?, categories:[String], hashTags:[String], bannerImageURL: String?, profileImageURL: String?, refferId: String?, deviceToken: String?, deepLinkUrl: String?)
    case search(channel: String)
    case updateProfile(param:[String:Any])
    case searchUser(channel: String)
    case topSearch(channel: String)
    case uploadPicture(image: UIImage, url: URL)
    case socialLogin(email: String?, firstname: String?, lastname: String?, country: String, socialId: String, channelId: String, refChannel: String?, business: Bool?, provider: String, password: String?, profileImageURL: String?, bannerImageURL: String?, deviceToken: String?)
    case TweetPost(status: String)
    case getProfile(userid: String, profileid: String, parentId: String)
    case getProfileByName(userid: String, profileid: String, parentId: String)
    case getPlaceHolder
    case downloadPic(url: String, destination: String)
    case followChannel(follower: String, following: String)
    case unfollowChannel(follower: String, following: String)
    case forgotPassword(email: String)
    // Promaneger Api
    case newUserAdded(userId: String, command: String?, socialSite: String?)
    case setChannel(userId: String, channelName: String?, channelId: String, hashtags:[String], interested:[String])
    case confirmEmail(userId: String, email: String)
    case socialPost(userId: String, socialSite: String)
    case doLogin(userId: String)
    case getuser(userId: String)
    case getDashboardPosts(userId: String, page: Int, browserType: Int?, type: Int?)
    case getPostComments(articleId: String, userId: String, page: Int)
    case getPostComment(commentId: String)
    case getCommentReplies(commentId: String, userId: String, page: Int)
    case addReply(replyMsg: String, pictureUrl: String?, videoUrl: String?, commentId: String, postId: String, userId: String, replyType: String)
    case writePost(type: String, text: String?, IschekedIn: Bool?, user: String, media: [[String:Any]]?, youTubeData: [String:Any]?, wallTheme: [String:Any]?, albumId: String?, checkedIn: [String:Any]?, hashTags:[String]?, privacy: String?, friendExcept:[String]?, friendsOnly:[String]?, feelingType: String?, feelings:[[String:Any]]?, previewUrlData: [String: Any]?, tagChannelAry:[String]?)
    case addComment(txtComment: String, picture: String?, video: String?, postId: String, userId: String, commentType: String)
    case likePost(articleId: String, userId: String, likeType: String)
    case disLikePost(articleId: String, userId: String)
    case likeComment(commentId: String, userId: String, likeType: String)
    case disLikeComment(commentId: String, userId: String)
    case likeReply(replyId: String, user: String, likeType: String)
    case disLikeReply(replyId: String, user: String)
    case getAlbums(user: String)
    case createAlbum(user: String, name: String)
    case getMyPost(userId: String, profileId: String, page: Int)
    case getMyYoutubePost(userId: String, profileId: String, page: Int)
    case blockUser(user: String, blocked: String, isBlocked: Bool)
    case repotPost(user: String, blocked: String, isBlocked: Bool)
    case deletePost(id: String)
    case getFriends(friends:[String])
    case updateAlbum(id: String, user: String, name: String, album_data:[[String:Any]])
    case tagUserSearch(user: String, channelName: String)
    case getFollowers(user: String, otherUser: String, parentId: String, String?)
    case getFollowings(user: String, otherUser: String, parentId: String, String?)
    case searchHash(hash: String, userid: String)
    case getHashPost(hash: String, userid: String, page: Int, type: Int?)
    case getLocationPost(placeId: String, userId: String, page: Int, type: Int?)
    case getHashStories(hash: String, offset: Int, page: Int)
    case getLocationStories(placeId: String, offset: Int, page: Int)
    case shreInAppPost(userId: String, postId: String)
    case shareWithWriteInAppPost(userId: String, postId: String, text: String?, IschekedIn: Bool?, checkedIn: [String:Any]?, hashTags:[String]?, privacy: String?, friendExcept:[String]?, friendsOnly:[String]?, feelingType: String?, feelings:[[String:Any]]?, tagArray:[String]?)
    case youTubeKeyWordSerch(q: String, order: String?, nextPageToken: String?)
    case youTubeDetail(id: String)
    case youTubeChannelSearch(channelId: String, order: String?, nextPageToken: String?)
    case youtubeRate(accessToken: String, videoId: String, rating: String)
    case getStories
    case getStoryByID(id: String)
    case getOwnStory
    case viewStory(storyId: String, viewUserId: String)
    case deleteStory(storyId: String)
    case getEmojies
    case editStory(storyId: String, storyURL: String, duration: String?, type: String?, storiType: Int?, user: String, thumb: String?, lat: String?, long: String?, address: String?, tags: [[String: Any]]?, hashtags: [String]?, publish: Int?)
    case createStory(url: String, duration: String, type: String, storiType: Int, user: String, thumb: String?, lat: String, long: String, address: String, tags: [[String: Any]]?, hashtags: [String]?, publish: Int)
    case addToFavourites(isFavourite: Bool, forUserId: String, forStoryId: String)
    case getFollowingNotification(user: String, type: String, page: Int)
    case getYouNotification(user: String, type: String, page: Int)
    case getMediaStories(type: Int, offeset: Int, page: Int, browserType: Int, user: String?, otherUser: String?, publish: Int?)
    case verifyUserAccount(verifyToken: String?, email: String?)
    case resendVerificationLink(email: String?)
    case storyByUser(userId: String)
    case deleteComment(commentId: String, user: String)
    case deleteReply(commentId: String, user: String, replyId: String)
    case getPostDetail(postId: String)
    case logOut(deviceToken: String, userId: String)
    case updatePost(postID: String, type: String, text: String?, ischekedIn: Bool?, user: String, media: [[String:Any]]?, youTubeData: [String:Any]?, wallTheme: [String:Any]?, albumId: String?, checkedIn: [String:Any]?, hashTags:[String]?, privacy: String?, friendExcept:[String]?, friendsOnly:[String]?, feelingType: String?, feelings:[[String:Any]]?, previewUrlData: [String: Any]?, removedMedia:[String]?, tagArray:[String]?)
    case getStoryFavoriteList(otherUserId: String?)
    case getChannelSuggestion(channelName: String)
    case addToCart(userId: String, packageName: Int, individualChannels:[String]?)
    case getCart(parentId: String)
    case getChannelList(Void)
    case deleteFromCart(userId: String, individualChannels: String?, packageName: Int, packageChannels: [String]?)
    case addPayment(userId: String, channelNames: [String]?)
    case checkChannelExists(channelNames: [String])
    case addAsFavorite(userId: String, PostId: String, isFav: Bool)
    case getFavoriteList(userId: String, page: Int, type: Int?, offset: Int)
    case addHashTagSet(categoryName: String, hashTags:[String], user: String)
    case getHashTagSets(Void)
    case updateHashTagSet(categoryName: String?, hashTags:[String]?, usedCount: Int?, hashId: String)
    case deleteHashTagSet(hashId: String)
    case increaseHashtagCount(hashIds:[String])
    case getPackage(parentId: String)
    case addPackage(user: String, parentId: String, packageName: String, packageCount: Int, isOwner: Bool, paymentAmount: Int?, paymentResponse: [String : [String : Any]]?)
    case createPlaylist(name: String, imageUrl: String?, user: String, type: Int, hash:[String]?)
    case getPlaylist(userid: String, typeId: Int?)
    case addToPlaylist(user: String, typeId: [String], paylist: String, type: Int)
    case getHashTagDetail(userId: String, hashtag: String)
    case followHashTag(userId: String, hashtagId: String, follow: Bool)
    case getPlaylistStory(page: Int, playlistId: String, type: Int, offset: Int)
    case deletePlaylist(id: String)
    case deletePlaylistItem(addPlayListId: String)
    case getWeather(lattitude: String, longitude: String)
    case getFollowedHashPostStory(userId: String, type: Int, page: Int, offset: Int)
    case copyPlayList(playlistId: String, user: String)
    case getPlayListInfo(playlistId: String)
    case followPlaylist(follow: Bool, followUserId: String, playlistId: String)
    case likePlaylist(like: Bool, likeUserId: String, playlistId: String, type: String?)
    case getPlayListComments(playlistId: String, userId: String, page: Int)
    case addPlayListComment(txtComment: String, picture: String?, video: String?, playlist: String, userId: String, commentType: String)
    case deletePlaylistComment(commentId: String, user: String)
    case likePlayListComment(commentId: String, user: String, type: String?, like: Bool)
    case reArrangePlaylist(user: String, playlistList:[[String:Any]])
    case deleteStories(storyId:[String])
    case questionAnswer([String : Any])
    case getTaggedStories(userId: String, page: Int, offset: Int)
    case getTaggedFeed(userId: String, type: Int, page: Int, offset: Int)
    case getRelationsData
    case addFamilyMember(user: String, relationUser: String, relation: String, privacy: String)
    case getFamilyMember(user: String, status: Int?)
    case acceptRejectFamilyRequest(user: String, status: Int, relationUser: String)
    case getFamilyStories(user: String, page: Int, offset: Int)
    case getFamilyFeed(user: String, type: Int, page: Int, offset: Int)
    case addAsVip(user: String, vipUser: String, add: Bool)
    case getVipList(user: String)
    case getVipUserPostList(user: String, type: Int, page: Int, offset: Int)
    case getVipUserStoryList(user: String, page: Int, offset: Int)
    case youtubeChannelSubscribe(token: String, channelId: String)
    case getyoutubeSubscribedChannel(token: String, forChannelId: String?)
    case unsubscribeYoutubeChannel(token: String, subscribtionId: String)
    case getAnswerList(storyId: String, tagId: String, userId: String)
    case reportUser(user: String, reportUser: String, reportType: Int)
    case createQuiz(userId: String, introduction: [String: Any], title: [String: Any], startDateTime: String, endDateTime: String, theme: String)
    case updateQuiz(outroPage: [String: Any], quizId: String, introduction: [String: Any], isPublish: Bool)
    case addQuizQuestionAnswer(quizId: String, userId: String, question: String, background: [String: Any], answerList: [[String: Any]], correctAnswer: [Int], weightage: String, style: [String: Any])
    case getQuizAnswerList(quizId: String)
    case getQuizList(userId: String, page: Int, offset: Int)
    case getQuizQuestionList(quizId: String)
    case addQuizAnswer(userId: String, question: String, background: [String: Any], answerList: [[String: Any]], correctAnswer: String, startDateTime: String, endDateTime: String, isQuizExpire: Bool)
    case getYoutubeCategory(token: String)
    case uploadYoutubeVideo(token: String, videoURL: URL, snippet: [String:Any], status: String)
    case deleteQuiz(id: String)
    case addAnswers(quizId: String, userId: String, answerList: [[String: Any]])
    
    case searchStory(hashtag: String, userid: String, storyTypes: [String], offset: Int, page: Int)
    case searchPost(hashtag: String, userid: String, types: [String], offset: Int, page: Int)
    case removeToken(token: String)
    case moveStoryIntoChannel(userid: String, otherChannelId: String, storyId: [String])
    case pushOnDownload(storyIds: [String], userid: String, downloadedUserId: String)
    case storieLike(storyId: String, user: String, type: String, like: Int)
    case getStorieLikes(storyId: String)
    case getStorieComments(storyId: String, userId: String, page: Int)
    case addCommentStory(storyId: String, userId: String, text: String, type: String)
    case likeOnStoryComment(commentId: String, user: String, type: String, like: Int)
    case deleteStoryComment(commentId: String, user: String)
    
    var endpoint: Endpoint {
        var endpointClosure = MoyaProvider<ProManagerApi>.defaultEndpointMapping(for: self)
        
        switch self {
        case .logIn, .signUp, .verifyChannel, .socialLogin, .TweetPost, . newUserAdded, .setChannel, .confirmEmail, .socialPost, .doLogin, .getuser, .getPlaceHolder, .forgotPassword, .youTubeKeyWordSerch, .youTubeDetail, .youTubeChannelSearch, .getEmojies, .getYoutubeCategory, .deleteStory:
            endpointClosure = endpointClosure.adding(newHTTPHeaderFields: APIHeaders().headerWithoutAccessToken)
            break
        case .getWeather:
            break
        case .youtubeRate(let token, _, _), .youtubeChannelSubscribe(let token, _), .getyoutubeSubscribedChannel(let token, _), .unsubscribeYoutubeChannel(let token, _):
            endpointClosure = endpointClosure.adding(newHTTPHeaderFields: ["Content-Type": "application/json", "Authorization": "Bearer \(token)"])
        case .uploadYoutubeVideo(let token, _, _, _):
            endpointClosure = endpointClosure.adding(newHTTPHeaderFields: ["Authorization": "Bearer \(token)"])
        case .removeToken:
            endpointClosure = endpointClosure.adding(newHTTPHeaderFields: ["Content-Type": "application/json"])
            break
        default:
            endpointClosure = endpointClosure.adding(newHTTPHeaderFields: APIHeaders().headerWithToken)
            break
        }
        
        print("Request URL : \(endpointClosure.url) \n\n")
        if let parameters = self.parameters {
            print("Request parameters : \(parameters) \n")
        }
        return endpointClosure
    }
}

extension ProManagerApi: TargetType {
    public var headers: [String: String]? {
        switch self {
        case .logIn, .signUp, .verifyChannel, .socialLogin, .TweetPost, . newUserAdded, .setChannel, .confirmEmail, .socialPost, .doLogin, .getuser, .getPlaceHolder, .forgotPassword, .youTubeKeyWordSerch, .youTubeDetail, .youTubeChannelSearch, .getEmojies, .getYoutubeCategory, .deleteStory:
            return APIHeaders().headerWithoutAccessToken
        case .getWeather:
            break
        case .youtubeRate(let token, _, _), .youtubeChannelSubscribe(let token, _), .getyoutubeSubscribedChannel(let token, _), .unsubscribeYoutubeChannel(let token, _):
            return ["Content-Type": "application/json",
                    "Authorization": "Bearer \(token)"]
        case .uploadYoutubeVideo(let token, _, _, _):
            return ["Authorization": "Bearer \(token)"]
        case .removeToken:
            return ["Content-Type": "application/json"]
        default:
            return APIHeaders().headerWithToken
        }
        return nil
    }
    
    public var baseURL: URL {
        switch self {
        case .uploadPicture(_, let url):
            return url
        case .TweetPost(let status):
            let  x = Constant.URLs.twitter + "statuses/update.json?" + status
            return URL.init(string: x)!
        case .newUserAdded, .setChannel, .confirmEmail, .socialPost, .doLogin, .getuser:
            return URL.init(string: Constant.URLs.cabbage)!
        case .downloadPic(let url, _):
            return URL.init(string: url)!
        case .youTubeKeyWordSerch, .youTubeDetail, .youTubeChannelSearch, .youtubeRate, .youtubeChannelSubscribe, .getyoutubeSubscribedChannel, .unsubscribeYoutubeChannel, .getYoutubeCategory:
            return URL.init(string: Constant.URLs.youtube)!
        case .uploadYoutubeVideo:
            return URL.init(string: "https://www.googleapis.com/upload/youtube/v3/videos?part=snippet&status")!
        case .getWeather:
            return URL.init(string: "https://api.openweathermap.org/data/2.5/weather")!
        default:
            return URL.init(string: Constant.URLs.base)!
        }
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .logIn:
            return Paths.login
        case .verifyChannel:
            return Paths.verifyChannel
        case .signUp:
            return Paths.signUp
        case .search:
            return Paths.search
        case .updateProfile:
            return Paths.updateProfile
        case .searchUser:
            return Paths.searchUser
        case .topSearch:
            return Paths.topSearch
        case .uploadPicture:
            return ""
        case .socialLogin:
            return Paths.socailLogin
        case .TweetPost:
            return ""
        case .getProfile:
            return Paths.getProfile
        case .getProfileByName:
            return Paths.getProfileByName
        case .getPlaceHolder:
            return Paths.getPlaceHolder
        case .forgotPassword:
            return Paths.forgotPassword
        case .newUserAdded:
            return Paths.newUserAdded
        case .setChannel:
            return Paths.setChannel
        case .confirmEmail:
            return Paths.confirmEmail
        case .socialPost:
            return Paths.socialPost
        case .doLogin:
            return Paths.doLogin
        case .getuser:
            return Paths.getuser
        case .downloadPic:
            return ""
        case .followChannel:
            return  Paths.followChannel
        case .unfollowChannel:
            return  Paths.unfollowChannel
        case .getDashboardPosts:
            return Paths.getDashboardPosts
        case .getPostComments:
            return Paths.getPostComments
        case .getPostComment:
            return Paths.getPostComment
        case .getCommentReplies:
            return Paths.getCommentReplies
        case .addReply:
            return Paths.addReply
        case .writePost:
            return Paths.writePost
        case .addComment:
            return Paths.addComment
        case .likePost:
            return Paths.likePost
        case .disLikePost:
            return Paths.disLikePost
        case .likeComment:
            return Paths.likeComment
        case .disLikeComment:
            return Paths.disLikeComment
        case .likeReply:
            return Paths.likeReply
        case .disLikeReply:
            return Paths.disLikeReply
        case  .getAlbums:
            return Paths.getAlbums
        case .createAlbum:
            return Paths.createAlbum
        case .getMyPost:
            return Paths.getMyPost
        case .getMyYoutubePost:
            return Paths.getMyYoutubePost
        case .blockUser :
            return Paths.blockUser
        case .repotPost:
            return Paths.repotPost
        case .deletePost(let id):
            return Paths.deletePost + id
        case .deletePlaylist(let id):
            return Paths.deletePlaylist + id
        case .getFriends:
            return Paths.getFriends
        case .updateAlbum(let id, _, _, _):
            return Paths.updateAlbum + id
        case .tagUserSearch:
            return Paths.tagUserSearch
        case .getFollowers:
            return Paths.getFollowers
        case .getFollowings:
            return Paths.getFollowings
        case .searchHash:
            return Paths.searchHash
        case .getHashPost:
            return Paths.getHashPost
        case .getLocationPost:
            return Paths.getLocationPost
        case .getHashStories:
            return Paths.getHashStories
        case .getLocationStories:
            return Paths.getLocationStories
        case .shreInAppPost(_, let postId):
            return Paths.shreInAppPost + postId
        case .shareWithWriteInAppPost(_, let postId, _, _, _, _, _, _, _, _, _, _):
            return Paths.shreInAppPost + postId
        case .youTubeKeyWordSerch:
            return Paths.youTubeKeyWordSerch
        case .youTubeDetail:
            return Paths.youTubeDetail
        case .youTubeChannelSearch:
            return Paths.youTubeChannelSearch
        case .youtubeRate:
            return Paths.youTubeRatting
        case .getStories:
            return Paths.getStories
        case .getOwnStory:
            return Paths.getOwnStory
        case .viewStory:
            return "stories/viewStory"
        case .deleteStory(let storyId):
            return "stories/\(storyId)"
        case .editStory(let storyId, _, _, _, _, _, _, _, _, _, _, _, _):
            return "stories/\(storyId)"
        case .addToFavourites:
            return "stories/addAsFavorite"
        case .getEmojies:
            return Paths.getEmojis
        case .createStory:
            return Paths.createStory
        case .getFollowingNotification:
            return Paths.getFollowingNotification
        case .getYouNotification:
            return Paths.getYouNotification
        case .getMediaStories:
            return Paths.getMediaStories
        case .verifyUserAccount:
            return Paths.verifyUserAccount
        case .resendVerificationLink:
            return Paths.resendVerificationLink
        case .storyByUser(let otherId):
            return Paths.storyByUser + "?otherUserStory="+otherId
        case .deleteComment:
            return Paths.deleteComment
        case .deleteReply:
            return Paths.deleteReply
        case .getPostDetail(let postId):
            return Paths.getPostDetail + postId
        case .logOut:
            return Paths.logOut
        case .updatePost(let postID, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _):
            return Paths.updatePost + postID
        case .getStoryFavoriteList:
            return Paths.getStoryFavoriteList
        case .getChannelSuggestion:
            return Paths.getChannelSuggestion
        case .addToCart:
            return Paths.addToCart
        case .getCart:
            return Paths.getCart
        case .deleteFromCart:
            return Paths.deleteFromCart
        case .getChannelList:
            return Paths.getChannelList
        case .addPayment:
            return Paths.addPayment
        case .checkChannelExists:
            return Paths.checkChannelExists
            
        case .addAsFavorite:
            return Paths.addAsFavorite
        case .getFavoriteList:
            return Paths.getFavoriteList
            
        case .addHashTagSet, .getHashTagSets:
            return Paths.addHashTag
        case .increaseHashtagCount:
            return Paths.increaseHashtagCount
        case .updateHashTagSet(_, _, _, let hashID), .deleteHashTagSet(let hashID):
            return Paths.addHashTag + "/\(hashID)"
        case .getPackage:
            return Paths.getPackage
        case .addPackage:
            return Paths.addPackage
        case .getStoryByID(let id):
            return Paths.getStoryByID + "/\(id)"
        case .createPlaylist:
            return Paths.createPlaylist
        case .getPlaylist:
            return Paths.getPlaylist
        case .addToPlaylist:
            return Paths.addToPlaylist
        case .getHashTagDetail:
            return Paths.getHashTagDetail
        case .followHashTag:
            return Paths.followHashTag
        case .getPlaylistStory:
            return Paths.getPlaylistStory
        case .deletePlaylistItem:
            return Paths.deletePlaylistItem
        case .getWeather:
            return ""
        case .getFollowedHashPostStory:
            return Paths.getFollowedHashPostStory
        case .copyPlayList:
            return Paths.copyPlayList
        case .getPlayListInfo(let playlist):
            return Paths.getPlayListInfo + playlist
        case .followPlaylist:
            return Paths.followPlaylist
        case .likePlaylist:
            return Paths.likePlaylist
        case .getPlayListComments:
            return Paths.getPlayListComments
        case .addPlayListComment:
            return Paths.addPlayListComment
        case .deletePlaylistComment:
            return Paths.deletePlaylistComment
        case .likePlayListComment:
            return Paths.likePlayListComment
        case .reArrangePlaylist:
            return Paths.reArrangePlaylist
        case .deleteStories:
            return Paths.deleteStories
        case .questionAnswer:
            return "stories/addAnswer"
        case .getTaggedStories:
            return Paths.getTaggedStories
        case .getTaggedFeed:
            return Paths.getTaggedFeed
        case .getRelationsData:
            return Paths.getRelationsData
        case .addFamilyMember:
            return Paths.addFamilyMember
        case .getFamilyMember:
            return Paths.getFamilyMember
        case .acceptRejectFamilyRequest:
            return Paths.acceptRejectFamilyRequest
        case .getFamilyStories:
            return Paths.getFamilyStories
        case .getFamilyFeed:
            return Paths.getFamilyFeed
        case .addAsVip:
            return Paths.addAsVip
        case .getVipList:
            return Paths.getVipList
        case .getVipUserPostList:
            return Paths.getVipUserPostList
        case .getVipUserStoryList:
            return Paths.getVipUserStoryList
        case .youtubeChannelSubscribe:
            return Paths.youtubeChannelSubscribe
        case .getyoutubeSubscribedChannel(_, let forChannelId):
            if let forChannelId = forChannelId {
                return Paths.getyoutubeSubscribedChannel + "&forChannelId=\(forChannelId)&mine=true"
            } else {
                return Paths.getyoutubeSubscribedChannel + "&mine=true"
            }
        case .unsubscribeYoutubeChannel(_, let subscribtionId):
            return Paths.unsubscribeYoutubeChannel + "?id=\(subscribtionId)"
        case .getAnswerList:
            return "stories/getAnswerList"
        case .reportUser:
            return Paths.reportUser
        case .createQuiz:
            return Paths.createQuiz
        case .updateQuiz(_, let quizId, _, _):
            return Paths.updateQuiz + quizId
        case .addQuizQuestionAnswer:
            return Paths.addQuizQuestionAnswer
        case .getQuizAnswerList:
            return Paths.getQuizAnswerList
        case .getQuizList:
            return Paths.getQuizList
        case .getQuizQuestionList:
            return Paths.getQuizQuestionList
        case .addQuizAnswer:
            return Paths.addQuizAnswer
        case .getYoutubeCategory :
            return Paths.getYoutubeCategoty
        case .uploadYoutubeVideo:
            return ""
        case .deleteQuiz(let id):
            return Paths.deleteQuiz + id
        case .addAnswers:
            return Paths.addAnswers
        case .searchStory:
            return "review/searchStory"
        case .searchPost:
            return "review/searchPosts"
        case .removeToken:
            return "users/removeDeviceToken"
        case .pushOnDownload:
            return Paths.pushOnDownload
        case .moveStoryIntoChannel:
            return Paths.moveStoryIntoChannel
        case .storieLike:
            return "stories/like"
        case .getStorieLikes:
            return "stories/like"
        case .getStorieComments:
            return "stories/getComments"
        case .addCommentStory:
            return "stories/addComment"
        case .likeOnStoryComment:
            return "stories/likeComment"
        case .deleteStoryComment:
            return "stories/deleteComment"
        }
       
    }
    
    /// The HTTP method used in the request.
    public var method: Moya.Method {
        switch self {
        case .logIn, .verifyChannel, .signUp, .search, .searchUser, .socialLogin, .TweetPost, .getProfile, .viewStory:
            return .post
        case .getPlaceHolder, .youTubeKeyWordSerch, .youTubeDetail, .getStories, .getOwnStory, .youTubeChannelSearch, .getEmojies, .getPostDetail, .getPostComment, .getStoryFavoriteList, .getCart, .getChannelList, .getPackage, .getHashTagSets, .getStoryByID, .getPlaylist, .getWeather, .getPlayListInfo, .getRelationsData, .getyoutubeSubscribedChannel, .getYoutubeCategory, .getPlaylistStory:
            return .get
        case .updateProfile, .uploadPicture, .blockUser, .repotPost, .updateAlbum, .updatePost, .updateHashTagSet, .updateQuiz, .editStory:
            return .put
        case .deletePost, .deleteComment, .deleteReply, .deleteStory, .deleteHashTagSet, .deletePlaylist, .deletePlaylistComment, .unsubscribeYoutubeChannel, .deleteQuiz, .deleteStoryComment:
            return .delete
        case .logOut:
            return .patch
        default :
            return .post
        }
    }
    
    /// The parameters to be incoded in the request.
    public var parameters: [String: Any]? {
        var param = [String: Any]()
        switch self {
        case .logIn(let email, let password, let deviceToken):
            param = ["username": email, "password": password, "deviceType": 1]
            if let deviceToken = deviceToken {
                param["deviceToken"] = deviceToken
            }
        case .verifyChannel(let q, let type):
            param = ["value": q, "field": type]
        case .signUp(let email, let password, let channel, let refChannel, let isBusiness, let socialId, let provider, let channelName, let about, let categories, let hashTags, let bannerImageURL, let profileImageURL, let refferId, let deviceToken, let deepLinkUrl):
            param = ["email": email, "password": password, "channelId": channel, "refferingChannel": refChannel, "isBusiness": isBusiness, "channelName": channelName, "about": about ?? "", "deviceType": 1]
            if  !categories.isEmpty {
                param["categories"] = categories
            }
            if  !hashTags.isEmpty {
                param["hashTags"] = hashTags
            }
            if let provider = provider {
                param["provider"] = provider
            }
            if let id = socialId {
                param["socialId"] = id
            }
            if let bi  = bannerImageURL {
                param["bannerImageURL"] = bi
            }
            if let pi = profileImageURL {
                param["profileImageURL"] = pi
            }
            if let rId = refferId {
                param["refferingId"] = rId
            }
            if let deviceToken = deviceToken {
                param["deviceToken"] = deviceToken
            }
            if let deepLinkUrl = deepLinkUrl {
                param["deepLinkUrl"] = deepLinkUrl
            }
        case .search(let channel):
            param = ["channelName": channel]
        case .updateProfile(let p):
            param = p
        case .searchUser(let channel):
            param = ["channelName": channel, "userId": Defaults.shared.currentUser?.id ?? ""]
        case .topSearch(let channel):
            param = ["channelName": channel, "userId": Defaults.shared.currentUser?.id ?? ""]
        case .uploadPicture:
            break
        case .socialLogin(let email, let firstname, let lastname, let country, let socialId, let channelId, let  refChannel, let business, let provider, let password, _, _, let deviceToken):
            param = ["country": country, "socialId": socialId, "provider": provider, "channelId": channelId, "deviceType": 1]
            if let e = email {
                param["email"] = e
            }
            if let f = firstname {
                param["firstName"] = f
            }
            if let l = lastname {
                param["lastName"] = l
            }
            if let b = business {
                param["isBusiness"] = b
            }
            if let r = refChannel {
                param["refferingChannel"] = r
            }
            if let p = password {
                param["password"] = p
            }
            if let deviceToken =  deviceToken {
                param["deviceToken"] = deviceToken
            }
        case .TweetPost(let status):
            param = ["status": status]
        case .getProfile(let userid, let profileid, let parentId):
            param = ["userid": userid, "profileid": profileid, "parentId": parentId]
        case .getProfileByName(let userid, let profileid, let parentId):
            param = ["userid": userid, "profileid": profileid, "parentId": parentId]
        case .forgotPassword(let email):
            param = ["email": email]
        case .newUserAdded(let userId, let command, let socialSite):
            param = ["userId": userId]
            if let c = command {
                param["command"] = c
            }
            if let s = socialSite {
                param["socialSite"] = s
            }
        case .setChannel(let userId, let channelName, let channelId, let hashtags, let interested):
            param = ["userId": userId, "channelId": channelId, "hashtags": hashtags, "interests": interested]
            if let chname = channelName {
                param["channelName"] = chname
            }
        case .confirmEmail(let userId, let email):
            param = ["userId": userId, "email": email]
        case .socialPost(let userId, let socialSite):
            param = ["userId": userId, "socialSite": socialSite]
        case .doLogin(let userId):
            param = ["userId": userId]
        case .getuser(let userId):
            param = ["userId": userId]
        case .getPlaceHolder:
            break
        case .downloadPic:
            break
        case .followChannel(let follower, let following):
            param = ["follower": follower, "following": following]
        case .unfollowChannel(let follower, let following):
            param = ["follower": follower, "following": following]
        case .getDashboardPosts(let userId, let page, let browserType, let type):
            param = ["user": userId, "page": "\(page)"]
            if let type = type {
                param["type"] = "\(type)"
            }
            if let browserType = browserType {
                param["browserType"] = "\(browserType)"
            }
        case .getPostComments(let articleId, let userId, let page):
            param = ["articleId": articleId, "user": userId, "page": page]
        case .getPostComment(let commentId):
            param = ["commentId": commentId]
            break
        case .getCommentReplies(let commentId, let userId, let page):
            param = ["commentId": commentId, "user": userId, "page": page]
        case .addReply(let replyMsg, let pictureUrl, let videoUrl, let commentId, let postId, let userId, let replyType):
            param = ["text": replyMsg, "picture": pictureUrl ?? "", "video": videoUrl ?? "", "comment": commentId, "post": postId, "user": userId, "type": replyType]
        case .writePost(let type, let text, let ischekedIn, let user, var media, let youTubeData, let wallTheme, let albumId, let checkedIn, let hashTags, let privacy, let friendExcept, let friendsOnly, _, let feelings, let previewUrlData, let tagChannelAry):
            if type == "video",
                let medias = media {
                var newMedia: [[String: Any]]?
                for var media in medias {
                    if let urlString = media["url"] as? String,
                        let url = URL(string: urlString) {
                        media["duration"] = "\(url.duration)"
                    }
                    if newMedia == nil {
                        newMedia = [[String: Any]]()
                    }
                    newMedia?.append(media)
                }
                media = newMedia
            }
            param = ["type": type, "text": text ?? "", "IschekedIn": ischekedIn ?? false, "user": user]
            if let media = media {
                param["media"] = media
            }
            if let youTubeData = youTubeData {
                param["youTubeData"] = youTubeData
            }
            if let previewData = previewUrlData {
                param["linkPreviewData"] = previewData
            }
            if let wallTheme = wallTheme {
                param["wallTheme"] = wallTheme
            }
            if let albumId = albumId {
                param["albumId"] = albumId
            }
            if let checkedIn = checkedIn {
                param["checkedIn"] = checkedIn
            }
            if let hashTags = hashTags {
                param["hashTags"] = hashTags
            }
            if let privacy = privacy {
                param["privacy"] = privacy
            }
            if let frndE = friendExcept {
                param["privacyUsersExcept"] = frndE
            }
            if let frndO = friendsOnly {
                param["privacyUsersOnly"] = frndO
            }
            if let feelings = feelings {
                param["feelings"] = feelings
            }
            if let tagChannelAry = tagChannelAry {
                param["tagChannelAry"] = tagChannelAry
            }
        case .shareWithWriteInAppPost(let userId, _, let text, let ischekedIn, let checkedIn, let hashTags, let privacy, let friendExcept, let friendsOnly, let feelingType, let feelings, let tagArray):
            param = ["type": "text", "text": text ?? "", "IschekedIn": ischekedIn ?? false, "user": userId]
            if let checkedIn = checkedIn {
                param["checkedIn"] = checkedIn
            }
            if let hashTags = hashTags {
                param["hashTags"] = hashTags
            }
            if let privacy = privacy {
                param["privacy"] = privacy
            }
            if let frndE = friendExcept {
                param["privacyUsersExcept"] = frndE
            }
            if let frndO = friendsOnly {
                param["privacyUsersOnly"] = frndO
            }
            if let feelType = feelingType {
                param["feelingType"] = feelType
            }
            if let feelings = feelings {
                param["feelings"] = feelings
            }
            if let tagArray = tagArray {
                param["tagChannelAry"] = tagArray
            }
        case .addComment(let txtComment, let picture, let video, let postId, let userId, let commentType):
            param = ["text": txtComment, "picture": picture ?? "", "video": video ?? "", "post": postId, "user": userId, "type": commentType]
        case .likePost(let articleId, let userId, let likeType):
            param = ["articleId": articleId, "user": userId, "type": likeType]
        case .disLikePost(let articleId, let userId):
            param = ["articleId": articleId, "user": userId]
        case .likeComment(let commentId, let userId, let likeType):
            param = ["commentId": commentId, "user": userId, "type": likeType]
        case .disLikeComment(let commentId, let userId):
            param = ["commentId": commentId, "user": userId]
        case .getAlbums(let user):
            param = ["user": user]
        case .createAlbum(let user, let name):
            param = ["user": user, "name": name]
        case .getMyPost(let userId, let profileId, let page):
            param = ["userid": userId, "profile": profileId, "page": page]
        case .getMyYoutubePost(let userId, let profileId, let page):
            param = ["userId": userId, "profile": profileId, "page": page]
        case .blockUser(let user, let blocked, let isBlocked):
            param = ["blocked": blocked, "user": user, "isBlocked": isBlocked]
        case .repotPost(let user, let blocked, let isBlocked):
            param = ["blocked": blocked, "user": user, "isBlocked": isBlocked]
        case .deletePost:
            break
        case .deletePlaylist:
            break
        case .getFriends(let friends):
            param = ["friends": friends]
        case .updateAlbum(_, let user, let name, let albumData):
            param = ["user": user, "name": name, "album_data": albumData]
        case .tagUserSearch(let user, let chanaleName):
            param = ["userId": user, "channelName": chanaleName]
        case .likeReply(let replyId, let user, let likeType):
            param = ["replyId": replyId, "user": user, "type": likeType]
        case .disLikeReply(let replyId, let user):
            param = ["replyId": replyId, "user": user]
        case .getFollowers(let user, let otherUser, let parentId, let search):
            param = ["userid": user, "user_id": otherUser, "parentId": parentId]
            if let search = search, search.isEmpty == false {
                param["search"] = search
            }
        case .getFollowings(let user, let otherUser, let parentId, let search):
            param = ["userid": user, "user_id": otherUser, "parentId": parentId]
            if let search = search, search.isEmpty == false {
                param["search"] = search
            }
        case .searchHash(let hash, let userId):
            param = ["hashTag": hash, "userid": userId]
        case .getHashPost(let hash, let user, _, let type):
            param = ["hashTag": hash, "userid": user]
            if let type = type {
                param["type"] = type
            }
        case .getLocationPost(let placeId, let userId, _, let type):
            param = ["userid": userId, "location": placeId]
            if let type = type {
                param["type"] = type
            }
        case .getHashStories(let hash, let offset, let page):
            param = ["hashTag": hash, "offset": offset, "page": page]
        case .getLocationStories(let placeId, let offset, let page):
            param = ["location": placeId, "offset": offset, "page": page]
        case .shreInAppPost(let userId, _ ):
            param = ["user": userId, "privacy": "Public"]
        case .youTubeKeyWordSerch(let q, let order, let nextToken) :
            param = ["part": "id", "maxResults": "10", "q": q, "type": "video", "key": Constant.GoogleService.serviceKey]
            if let next = nextToken {
                param["pageToken"] = next
            }
            if let order = order {
                param["order"] = order
            }
        case .youTubeChannelSearch(let channelId, let order, let nextToken):
            param = ["part": "id", "maxResults": "10", "channelId": channelId, "type": "video", "key": Constant.GoogleService.serviceKey]
            if let next = nextToken {
                param["pageToken"] = next
            }
            if let order = order {
                param["order"] = order
            }
        case .youTubeDetail(let id):
            param = ["part": "snippet,statistics", "fields": "items(snippet(title,description,tags,thumbnails,channelTitle,publishedAt,channelId),statistics,id)", "key": Constant.GoogleService.serviceKey, "id": id]
        case .youtubeRate(_, let videoId, let rating):
            param = ["id": videoId, "rating": rating]
            break
        case .getStories, .getOwnStory, .deleteStory, .getStoryByID:
            return nil
        case .getCart(let parentId):
            param = ["parentId": parentId]
            break
        case .getPlaylist(let userid, let type):
            param = ["userid": userid]
            if let type = type {
                param["type"] = type
            }
            break
        case .getPackage(let parentId):
            param = ["parentId": parentId]
            break
        case .addToFavourites(let isFavourite, let userId, let storyId):
            return [
                "favoriteUserId": userId,
                "storyId": storyId,
                "add": isFavourite
            ]
        case .viewStory(let storyId, let viewUserId):
            return ["storyId": storyId,
                    "viewUserId": viewUserId]
        case .getEmojies:
            break
        case .editStory(_, let storyURL, _, _, _, _, let thumb, _, _, _, let tags, let hashtags, let publish):
            param = ["url": storyURL]
            if let thumb = thumb {
                param["thumb"] = thumb
            }
            if let publish = publish {
                param["publish"] = publish
            }
            if let tags = tags {
                param["tag"] = tags
            }
            if let hashTags = hashtags {
                param["hashTags"] = hashTags
            }
            break
        case .createStory(let url, let duration, let type, let storiType, let user, let thumb, let lat, let long, let address, let tags, let hashtags, let publish):
            param = ["url": url,
                     "duration": duration,
                     "type": type,
                     "storyType": storiType,
                     "user": user,
                     "address": address,
                     "latitude": lat,
                     "longitude": long,
                     "publish": publish]
            if let thumb = thumb {
                param["thumb"] = thumb
            }
            if let tags = tags {
                param["tag"] = tags
            }
            if let hashTags = hashtags {
                param["hashTags"] = hashTags
            }
        case .getFollowingNotification(let user, let type, let page):
            param = ["user": user, "type": type, "page": page]
        case .getYouNotification(let user, let type, let page):
            param = ["user": user, "type": type, "page": page]
        case .getMediaStories(_, let offeset, let page, let browserType, let user, let otherUser, let publish):
            param = ["offset": offeset, "page": page, "browserType": "\(browserType)"]
            if let user = user {
                param["user"] = user
            }
            if let otherUser = otherUser {
                param["otherUserId"] = otherUser
            }
            if let publish = publish {
                param["publish"] = publish
            }
        case .verifyUserAccount(let token, let email):
            if let token = token {
                param = ["verifyToken": token, "email": email ?? ""]
            }
        case .resendVerificationLink(let email):
            if let email = email {
                param = ["email": email]
            }
        case .storyByUser:
            param = [:]
        case .deleteComment(let commentId, let user):
            param = ["commentId": commentId, "user": user]
        case .deleteReply(let commentId, let user, let replyId):
            param = ["commentId": commentId, "user": user, "replyId": replyId]
        case .getPostDetail:
            param = [:]
        case .logOut(let deviceToken, _):
            param = ["deviceToken": deviceToken]
        case .updatePost( _, let type, let text, let ischekedIn, let user, let media, let youTubeData, let wallTheme, let albumId, let checkedIn, let hashTags, let privacy, let friendExcept, let friendsOnly, _, let feelings, let previewUrlData, let removedMedia, let tagArray):
            param = ["type": type, "text": text ?? "", "IschekedIn": ischekedIn ?? false, "user": user]
            if let tags = tagArray {
                param["tagChannelAry"] = tags
            }
            if let media = media {
                param["media"] = media
            } else {
                param["media"] = NSNull()
            }
            if let youTubeData = youTubeData {
                param["youTubeData"] = youTubeData
            } else {
                param["youTubeData"] = NSNull()
            }
            if let previewData = previewUrlData {
                param["linkPreviewData"] = previewData
            } else {
                param["linkPreviewData"] = NSNull()
            }
            if let wallTheme = wallTheme {
                param["wallTheme"] = wallTheme
            }
            if let albumId = albumId {
                param["albumId"] = albumId
            }
            if let checkedIn = checkedIn {
                param["checkedIn"] = checkedIn
            } else {
                param["checkedIn"] = NSNull()
            }
            if let hashTags = hashTags {
                param["hashTags"] = hashTags
            }
            if let privacy = privacy {
                param["privacy"] = privacy
                if privacy == "FRIENDS_EXCEPT" {
                    if let frndE = friendExcept {
                        param["privacyUsersExcept"] = frndE
                    }
                } else {
                    param["privacyUsersExcept"] = []
                }
                if privacy == "FRIENDS_ONLY" {
                    if let frndO = friendsOnly {
                        param["privacyUsersOnly"] = frndO
                    }
                } else {
                    param["privacyUsersOnly"] = []
                }
            }
            //            if let feelType = feelingType {
            //                param["feelingType"] = feelType
            //            }
            if let feelings = feelings {
                param["feelings"] = feelings
            } else {
                param["feelings"] = NSNull()
            }
            if let removedMedia = removedMedia {
                param["removedMedia"] = removedMedia
            }
        case .getStoryFavoriteList(let otherUserId):
            if let ouid = otherUserId {
                param["otherUserId"] = ouid
            }
        case .addToCart(let userId, let packageName, let individualChannels):
            param = ["userId": userId,
                     "packageName": packageName,
                     "individualChannels": individualChannels ?? ""]
        case .deleteFromCart(let userId, let individualChannels, let packageName, let packageChannels):
            param = ["userId": userId, "packageName": packageName]
            if let individualChannels = individualChannels {
                param["individualChannels"] = individualChannels
            } else {
                param["individualChannels"] = NSNull()
            }
            if let packageChannels = packageChannels {
                param["packageChannels"] = packageChannels
            } else {
                param["packageChannels"] = NSNull()
            }
        case .addPayment(let userId, let channelNames):
            param = ["userId": userId]
            if let channelNames = channelNames {
                param["channelNames"] = channelNames
            } else {
                param["channelNames"] = NSNull()
            }
            
        case .addPackage(let user, let parentId, let packageName, let packageCount, let isOwner, let paymentAmount, let paymentResponse):
            param = ["user": user, "parentId": parentId, "packageName": packageName, "packageCount": packageCount, "isOwner": isOwner, "paymentAmount": paymentAmount ?? 0, "paymentResponse": paymentResponse ?? [:]]
        case .checkChannelExists(let channelNames):
            param["channelNames"] = channelNames
        case .getChannelSuggestion(let channelName):
            param["channelName"] = channelName
            break
        case .getChannelList:
            break
        case .addAsFavorite(let userId, let postId, let isFav):
            param = ["favoriteUserId": userId, "postId": postId, "add": isFav]
        case .getFavoriteList(let userId, let page, let type, _):
            param = ["userId": userId, "page": "\(page)"]
            if let type = type {
                param["type"] = "\(type)"
            }
        case .addHashTagSet(let categoryName, let hashTags, let user):
            param = ["categoryName": categoryName, "hashTags": hashTags, "user": user]
        case .getHashTagSets:
            break
        case .updateHashTagSet(let categoryName, let hashTags, let usedCount, _) :
            if let categoryName = categoryName {
                param["categoryName"] = categoryName
            }
            if let hashTags = hashTags {
                param["hashTags"] = hashTags
            }
            if let usedCount = usedCount {
                param["usedCount"] = usedCount
            }
        case .deleteHashTagSet:
            break
        case .increaseHashtagCount(let hashIds):
            param["hashIds"] = hashIds
        case .createPlaylist(let name, let imageUrl, let user, let type, let hash):
            param["name"] = name
            param["user"] = user
            param["type"] = type
            if let imageUrl = imageUrl {
                param["imageUrl"] = imageUrl
            } else {
                param["imageUrl"] = nil
            }
            if let hash = hash {
                param["hashTags"] = hash
            }
            
        case .addToPlaylist(let user, let typeId, let paylist, let type):
            param["user"] = user
            param["paylist"] = paylist
            param["type"] = type
            param["typeId"] = typeId
        case .getHashTagDetail(let userId, let hashtag):
            param = ["userId": userId, "hashtag": hashtag]
        case .followHashTag(let userId, let hashtagId, let follow):
            param = ["userId": userId, "hashtagId": hashtagId, "follow": follow ? 1 : 0]
        case .getPlaylistStory(let page, let playlistId, let type, let offset):
            param = ["page": page, "playlistId": playlistId, "type": type, "offset": offset]
            
        case .deletePlaylistItem(let addPlayListId):
            param["addPlayListId"] = addPlayListId
        case .getWeather(let lattitude, let longitude):
            param = ["lat": lattitude,
                     "lon": longitude,
                     "appid": Constant.OpenWeather.apiKey,
                     "units": "metric"]
        case .getFollowedHashPostStory(let userId, let type, let page, let offset):
            param = ["user": userId, "type": type, "page": page, "offset": offset]
        case .copyPlayList(let playlist, let user):
            param = ["playlistId": playlist, "copyUserId": user]
        case .getPlayListInfo:
            break
        case .followPlaylist(let follow, let followUserId, let playlistId):
            param = ["follow": follow, "followUserId": followUserId, "playlistId": playlistId]
        case .likePlaylist(let like, let likeUserId, let playlistId, let type):
            param = ["like": like, "likeUserId": likeUserId, "playlistId": playlistId]
            if let type = type {
                param["type"] = type
            }
        case .getPlayListComments(let playlistId, let userId, let page):
            param = ["playlistId": playlistId, "page": page, "user": userId]
        case .addPlayListComment(let txtComment, let picture, let video, let playlist, let userId, let commentType):
            param = ["text": txtComment, "picture": picture ?? "", "video": video ?? "", "playlist": playlist, "user": userId, "type": commentType]
        case .deletePlaylistComment(let commentId, let user):
            param = ["commentId": commentId, "user": user]
        case .likePlayListComment(let commentId, let user, let type, let like):
            param =  ["commentId": commentId, "user": user, "like": (like ? 1 : 0)]
            if let type = type {
                param["type"] = type
            }
        case .reArrangePlaylist(let user, let playlistList) :
            param = ["user": user, "playlistList": playlistList]
        case .deleteStories(let storyId):
            param = ["storyId": storyId]
        case .questionAnswer(let params):
            param = params
        case .getTaggedStories(let userId, let page, let offset):
            param = ["user": userId, "page": page, "offset": offset]
        case .getTaggedFeed(let userId, let type, let page, let offset):
            param = ["user": userId, "page": page, "type": type, "offset": offset]
        case .getRelationsData:
            break
        case .addFamilyMember(let user, let relationUser, let relation, let privacy):
            param = ["user": user, "relationUser": relationUser, "relation": relation, "privacy": privacy]
        case .getFamilyMember(let user, let status):
            param = ["user": user]
            if let status = status {
                param["status"] = status
            }
        case .acceptRejectFamilyRequest(let user, let status, let relationUser):
            param = ["user": user, "status": status, "relationUser": relationUser]
        case .getFamilyStories(let user, let page, let offset):
            param = ["user": user, "page": page, "offset": offset]
        case .getFamilyFeed(let user, let type, let page, let offset):
            param = ["user": user, "page": page, "type": type, "offset": offset]
        case .addAsVip(let user, let vipUser, let add):
            param = ["user": user, "vipUser": vipUser, "add": add]
        case .getVipList(let user):
            param = ["user": user]
        case .getVipUserPostList(let user, let type, let page, let offset):
            param = ["user": user, "page": page, "type": type, "offset": offset]
        case .getVipUserStoryList(let user, let page, let offset):
            param = ["user": user, "page": page, "offset": offset]
        case .youtubeChannelSubscribe(_, let channelId):
            param = [ "snippet": ["resourceId": ["kind": "youtube#channel", "channelId": channelId]]]
        case .getyoutubeSubscribedChannel:
            break
        case .unsubscribeYoutubeChannel:
            break
        // param = ["forChannelId":forChannelId,"mine":true]
        case .getAnswerList(let storyId, let tagId, let userId):
            return ["story": storyId,
                    "tagId": tagId,
                    "user": userId]
        case .reportUser(let user, let reportUser, let reportType):
            param = ["user": user, "reportUser": reportUser, "reportType": reportType]
        case .createQuiz(let userId, let introduction, let title, let startDateTime, let endDateTime, let theme):
            param = ["userId": userId, "introduction": introduction, "title": title, "startDateTime": startDateTime, "endDateTime": endDateTime, "theme": theme]
        case .updateQuiz(let outroPage, _, let introduction, let isPublish):
            if !introduction.isEmpty {
                param = ["introduction": introduction]
            } else {
                param = ["OutroPage": outroPage, "isPublish": isPublish]
            }
        case .addQuizQuestionAnswer(let quizId, let userId, let question, let background, let answerList, let correctAnswer, let weightage, let style):
            param = ["quizId": quizId, "userId": userId, "question": question, "background": background, "answerList": answerList, "correctAnswer": correctAnswer, "weightage": weightage, "style": style]
        case .getQuizAnswerList(let quizId):
            param = ["quizId": quizId]
        case .getQuizList(let userId, let page, let offset):
            param = ["userId": userId, "page": page, "offset": offset]
        case .getQuizQuestionList(let quizId):
            param = ["quizId": quizId]
        case .addQuizAnswer(let userId, let question, let background, let answerList, let correctAnswer, let startDateTime, let endDateTime, let isQuizExpire):
            param = ["userId": userId, "question": question, "background": background, "answerList": answerList, "correctAnswer": correctAnswer, "startDateTime": startDateTime, "endDateTime": endDateTime, "isQuizExpire": isQuizExpire]
        case .getYoutubeCategory:
            param = ["part": "snippet", "regionCode": "US", "key": Constant.GoogleService.serviceKey]
            break
        case .uploadYoutubeVideo:
            break
        case .deleteQuiz:
            break
        case .searchPost(let hashtag, let userid, let types, let offset, let page):
            return ["hashtag": hashtag,
                    "userid": userid,
                    "type": types,
                    "offset": offset,
                    "page": page]
        case .searchStory(let hashtag, let userid, let storyTypes, let offset, let page):
            return ["hashtag": hashtag,
                    "userid": userid,
                    "storyType": storyTypes,
                    "offset": offset,
                    "page": page]
        case .removeToken(let token):
            return ["deviceToken": token]
        case .addAnswers(let quizId, let userId, let answerList):
            param = ["quizId": quizId, "userId": userId, "answerList": answerList]
        case .moveStoryIntoChannel(let userId, let otherChannelId, let storyId):
            param = ["userId": userId, "otherChannelId": otherChannelId, "storyIds": storyId]
        case .pushOnDownload(let storyIds, let userid, let downloadedUserId):
            param = ["storyIds": storyIds, "userid": userid, "downloadedUserId": downloadedUserId]
        case .storieLike(let storyId, let user, let type, let like):
            param = ["storyId": storyId, "user": user, "type": type, "like": like]
        case .getStorieLikes(let storyId):
            param = ["storyId": storyId]
        case .getStorieComments(let storyId, let userId, let page):
            param = ["story": storyId, "user": userId, "page": page]
        case .addCommentStory(let storyId, let userId, let text, let type):
            param = ["story": storyId, "user": userId, "text": text, "type": type]
        case .likeOnStoryComment(let commentId, let user, let type, let like):
            param = ["commentId": commentId, "user": user, "type": type, "like": like]
        case .deleteStoryComment(let commentId, let user):
            param = ["commentId": commentId, "user": user]
        }
        return param
    }
    
    /// The method used for parameter encoding.
    public var parameterEncoding: Moya.ParameterEncoding {
        switch self {
        case .logIn:
            return JSONEncoding.default
        case
        .TweetPost, .getPlaceHolder, .youTubeDetail, .youTubeKeyWordSerch, .getStories, .youTubeChannelSearch, .getEmojies, .getPostDetail, .getPostComment, .getStoryFavoriteList, .getCart, .getChannelList, .getHashTagSets, .getPackage, .getStoryByID, .getPlaylist, .getWeather, .getPlayListInfo, .getRelationsData, .getOwnStory, .getYoutubeCategory, .getPlaylistStory:
            return URLEncoding.methodDependent
        case .youtubeRate:
            return URLEncoding.queryString
        case .youtubeChannelSubscribe, .getyoutubeSubscribedChannel, .unsubscribeYoutubeChannel:
            return TokenURLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
    
    /// Provides stub data for use in testing.
    public var sampleData: Data {
        return Data()
    }
    
    /// The type of HTTP task to be performed.
    public var task: Moya.Task {
        switch self {
        case .uploadPicture(let image, _):
            let imageData = image.jpegData(compressionQuality: 0.8)
            let imageDataMultiPart = [MultipartFormData(provider: .data(imageData!), name: "file", fileName: "photo.jpg", mimeType: "image/jpeg")]
            let multipartData = imageDataMultiPart
            return .uploadMultipart(multipartData)
        case .uploadYoutubeVideo(_, let videoURL, let snippet, let status) :
            var multipartFormData: [Moya.MultipartFormData] = []
            if let title = snippet["title"] as? String,
                let categoryId = snippet["categoryId"]  as? String {
                let snippetString = "{'snippet':{'title' : '\(title)','description': '\(((snippet["description"]  as? String) ?? ""))','categoryId' : '\(categoryId)'}}"
                multipartFormData.append(MultipartFormData.init(provider: MultipartFormData.FormDataProvider.data((snippetString.data(using: String.Encoding.utf8, allowLossyConversion: false))!), name: "snippet", mimeType: "application/json"))
            }
            let statusString = "{'status' : {'privacyStatus':'\(status)'}}"
            multipartFormData.append(MultipartFormData.init(provider: MultipartFormData.FormDataProvider.data((statusString.data(using: String.Encoding.utf8, allowLossyConversion: false))!), name: "status", mimeType: "application/json"))
            if let videoData = try? Data.init(contentsOf: videoURL) {
                multipartFormData.append(MultipartFormData.init(provider: MultipartFormData.FormDataProvider.data(videoData), name: "video", fileName: videoURL.lastPathComponent, mimeType: "application/octet-stream"))
            }
            return .uploadMultipart(multipartFormData)
        default:
            return .requestParameters(parameters: self.parameters ?? [:], encoding: self.parameterEncoding)
        }
    }
    
    /// Whether or not to perform Alamofire validation. Defaults to `false`.
    public var validate: Bool {
        return true
    }
    
    public func request<T: Mappable>(_ map: T.Type) -> Observable<T> {
        let endPointClosure = { (target: ProManagerApi) -> Endpoint in
            return self.endpoint
        }
        return Observable.create { observer -> Disposable in
            let lockService = MoyaProvider<ProManagerApi>(endpointClosure: endPointClosure,
                                                          plugins: [CachePolicyPlugin()])
            let request = lockService
                .rx
                .request(self)
                .mapObject(T.self)
                .subscribe(onSuccess: { (object) in
                    observer.onNext(object)
                }, onError: { (error) in
                    observer.onError(error)
                })
            return Disposables.create {
                request.dispose()
            }
        }
    }
    
    public func requestArray<T: Mappable>(_ map: T.Type) -> Observable<[T]> {
        let endPointClosure = { (target: ProManagerApi) -> Endpoint in
            return self.endpoint
        }
        
        return Observable.create { observer -> Disposable in
            let lockService = MoyaProvider<ProManagerApi>(endpointClosure: endPointClosure,
                                                          plugins: [CachePolicyPlugin()])
            let request = lockService
                .rx
                .request(self)
                .mapArray(T.self)
                .subscribe(onSuccess: { (object) in
                    observer.onNext(object)
                }, onError: { (error) in
                    observer.onError(error)
                })
            return Disposables.create {
                request.dispose()
            }
        }
    }
    
    public func requestWithProgress<T: Mappable>(_ map: T.Type) -> Observable<ProgressResponse> {
        let endPointClosure = { (target: ProManagerApi) -> Endpoint in
            return self.endpoint
        }
        return Observable.create { observer in
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            let lockService = MoyaProvider<ProManagerApi>(endpointClosure: endPointClosure,
                                                          plugins: [CachePolicyPlugin()])
            let request = lockService.rx.requestWithProgress(self)
                .subscribe { event -> Void in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    switch event {
                    case .next(let lockSatatus):
                        observer.onNext(lockSatatus)
                        break
                    case .error(let error):
                        observer.onError(error)
                        break
                    case .completed:
                        observer.onCompleted()
                        break
                    }
            }
            return Disposables.create {
                request.dispose()
            }
        }
    }
    
    public func request() -> Observable<Response> {
        let endPointClosure = { (target: ProManagerApi) -> Endpoint in
            return self.endpoint
        }
        return Observable.create { observer -> Disposable in
            let lockService = MoyaProvider<ProManagerApi>(endpointClosure: endPointClosure,
                                                          plugins: [CachePolicyPlugin()])
            let request = lockService
                .rx
                .request(self)
                .subscribe(onSuccess: { (object) in
                    observer.onNext(object)
                }, onError: { (error) in
                    observer.onError(error)
                })
            return Disposables.create {
                request.dispose()
            }
        }
    }
    
}

struct TokenURLEncoding: Moya.ParameterEncoding {
    
    public static var `default`: TokenURLEncoding { return TokenURLEncoding() }
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        
        var req = try urlRequest.asURLRequest()
        
        guard let request = (req as NSURLRequest).mutableCopy() as? NSMutableURLRequest,
            let components = NSURLComponents(string: request.url!.absoluteString.removingPercentEncoding!) else {
                
                // Handle the error
                return req
        }
        if (parameters?.count ?? 0) > 0 {
            let json = try JSONSerialization.data(withJSONObject: parameters!,
                                                  options: JSONSerialization.WritingOptions.prettyPrinted)
            req.httpBody = json
        }
        
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if let url = components.url {
            req.url = url
        } else {
            if let urlString = request.url!.absoluteString.removingPercentEncoding, let url = URL(string: urlString) {
                req.url = url
            }
        }
        
        return req
    }
}
protocol CachePolicyGettable {
    var cachePolicy: URLRequest.CachePolicy { get }
}

final class CachePolicyPlugin: PluginType {
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        if let cachePolicyGettable = target as? CachePolicyGettable {
            var mutableRequest = request
            mutableRequest.cachePolicy = cachePolicyGettable.cachePolicy
            return mutableRequest
        }
        
        return request
    }
}
extension ProManagerApi: CachePolicyGettable {
    var cachePolicy: URLRequest.CachePolicy {
        guard !UIApplication.checkInternetConnection() else {
            return .reloadIgnoringLocalAndRemoteCacheData
        }
        if self.method == .get {
            return .returnCacheDataElseLoad
        }
        return .reloadIgnoringLocalAndRemoteCacheData
    }
}
