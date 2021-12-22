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
    case getSplashImages
    case getViralvids(page: Int, limit: Int, socialPlatform: String?)
    case connectSocial(socialPlatform: String, socialId: String, socialName: String)
    case removeSocialConnection(socialAccountId: String)
    case logIn(email: String, password: String, deviceToken: String?)
    case doNotShowAgain(isDoNotShowMessage: Bool)
    case confirmEmail(userId: String, email: String)
    case signUp(email: String, password: String, channel: String, refChannel: String, isBusiness: Bool, socialId:String?, provider:String?, channelName: String, refferId: String?, deviceToken: String?, birthDate: String?, profileImageURL: String?)
    case socialLogin(socialId: String, email: String?)
    case uploadYoutubeVideo(token: String, videoURL: URL, snippet: [String:Any], status: String)
    case search(channel: String, channelId: String)
    case verifyChannel(channel: String, type: String)
    case getYoutubeCategory(token: String)
    case getyoutubeSubscribedChannel(token: String, forChannelId: String?)
    case youTubeChannelSearch(channelId: String, order: String?, nextPageToken: String?)
    case youTubeDetail(id: String)
    case youTubeChannels(token: String)
    case youTubeKeyWordSerch(key: String, order: String?, nextPageToken: String?)
    case deleteHashTagSet(hashId: String)
    case addHashTagSet(categoryName:String, hashTags:[String], user : String)
    case getHashTagSets(Void)
    case updateHashTagSet(categoryName:String?, hashTags:[String]?, usedCount : Int?,hashId:String)   
    case logOut(deviceToken: String, userId: String)
    case createStory(url: String, duration: String, type: String, storiType: Int, user: String, thumb: String?, lat: String, long: String, address: String, tags: [[String: Any]]?, hashtags: [String]?, publish: Int)
    case writePost(type: String, text: String?, isChekedIn: Bool?, user: String, media: [[String:Any]]?, youTubeData: [String:Any]?, wallTheme: [String:Any]?, albumId: String?, checkedIn: [String:Any]?, hashTags:[String]?, privacy: String?, friendExcept:[String]?, friendsOnly:[String]?, feelingType: String?, feelings:[[String:Any]]?, previewUrlData: [String: Any]?, tagChannelAry:[String]?)
    case updatePost(postID:String, type: String, text: String?, isChekedIn: Bool?, user: String, media: [[String:Any]]?, youTubeData: [String:Any]?, wallTheme: [String:Any]?, albumId: String?, checkedIn: [String:Any]?,hashTags:[String]?,privacy:String?,friendExcept:[String]?,friendsOnly:[String]?,feelingType:String?,feelings:[[String:Any]]?,previewUrlData: [String: Any]?,removedMedia:[String]?,tagArray:[String]?)
    case editStory(storyId: String, storyURL: String, duration: String?, type: String?, storiType: Int?, user: String, thumb: String?, lat: String?, long: String?, address: String?, tags: [[String: Any]]?, hashtags: [String]?, publish: Int?)
    case tagUserSearch(user: String, channelName: String)
    case getWeather(lattitude: String, longitude: String)
    case updateProfile(param:[String:Any])
    case doLogin(userId: String)
    case instgramProfile(accessToken: String)
    case instgramProfileDetails(username: String)
    case getAccessToken(param:[String:Any])
    case getLongLivedToken(param:[String:Any])
    case getChannelList
    case getPackage(parentId: String)
    case deleteFromCart(userId: String, individualChannels: String?, packageName: Int, packageChannels: [String]?)
    case getCart(parentId: String)
    case addPackage(user: String, parentId: String, packageName: String, packageCount: Int, isOwner: Bool, paymentAmount: Int?, paymentResponse: [String: [String: Any]]?)
    case addPayment(userId: String, channelNames: [String]?)
    case checkChannelExists(channelNames: [String])
    case addToCart(userId: String, packageName:Int, individualChannels:[String]?)
    case getChannelSuggestion(channelName: String)
    case getCalculatorConfig(type: String)
    case getWebsiteData
    case setSubscription(type: String, code: String)
    case forgotPassword(username: String)
    case getUserProfile
    case setUserSettings(appWatermark: Int, fastesteverWatermark: Int, faceDetection: Bool, guidelineThickness: Int, guidelineTypes: Int, guidelinesShow: Bool, iconPosition: Bool, supportedFrameRates: [String], videoResolution: Int, watermarkOpacity: Int, guidelineActiveColor: String, guidelineInActiveColor: String)
    case getUserSettings
    case loginWithKeycloak(code: String, redirectUrl: String)
    case logoutKeycloak
    case addReferral(refferingChannel: String)
    case subscriptionList
    case buySubscription(param: [String:Any])
    case userSync
    case downgradeSubscription(subscriptionId: String)
    case getToken(appName: String)
    case createUser(channelId: String, refferingChannel: String)
    case userDelete
    case uploadPicture(image: UIImage, imageSource: String)
    case getReferredUserList(page: Int, limit: Int)
    case setAffiliate(isAllowAffiliate: Bool)
    case addSocialPlatforms(socialPlatforms: [String])
    case setToken(deviceToken: String, deviceType: String)
    case removeToken(deviceToken: String)
    case getReferralNotification
    case setReferralNotification(isForEveryone: Bool, customSignupNumber: Int, isBadgeEarned: Bool)
    case setUserStateFlag(isUserStateFlag: Bool)
    case setCountrys(arrayCountry: [[String:Any]]?)
    case getNotification(page: Int)
    case notificationsRead(notificationId: String)
    case editDisplayName(publicDisplayName: String?, privateDisplayName: String?)
    case setFollow(userId: String)
    case setUnFollow(userId: String)
    
    var endpoint: Endpoint {
        var endpointClosure = MoyaProvider<ProManagerApi>.defaultEndpointMapping(for: self)
        
        switch self {
        case .confirmEmail, .signUp, .verifyChannel, .getSplashImages, .logIn, .youTubeKeyWordSerch, .youTubeDetail, .youTubeChannelSearch, .getYoutubeCategory, .getAccessToken, .socialLogin, .youTubeChannels(_), .forgotPassword, .loginWithKeycloak, .createUser, .search:
            endpointClosure = endpointClosure.adding(newHTTPHeaderFields: APIHeaders().headerWithoutAccessToken)
            
        case .getWeather:
            break
        case .getyoutubeSubscribedChannel(let token, _):
            endpointClosure = endpointClosure.adding(newHTTPHeaderFields: ["Content-Type": "application/json", "Authorization": "Bearer \(token)"])
        case .uploadYoutubeVideo(let token, _, _, _):
            endpointClosure = endpointClosure.adding(newHTTPHeaderFields: ["Authorization": "Bearer \(token)"])
       
            
        default:
            endpointClosure = endpointClosure.adding(newHTTPHeaderFields: APIHeaders().headerWithToken)
        }
        
        print("Request URL : \(endpointClosure.url) \n\n")
        print("Request Header : \(endpointClosure.httpHeaderFields) \n\n")
        if let parameters = self.parameters {
            print("Request parameters : \(parameters) \n")
        }
        return endpointClosure
    }
}

extension ProManagerApi: TargetType {
    public var headers: [String: String]? {
        switch self {
        case .confirmEmail, .signUp, .verifyChannel, .getSplashImages, .logIn, .doLogin, .youTubeKeyWordSerch, .youTubeDetail, .youTubeChannelSearch, .getYoutubeCategory, .socialLogin, .youTubeChannels, .forgotPassword, .loginWithKeycloak, .createUser, .search:
            return APIHeaders().headerWithoutAccessToken
        case .getWeather, .getAccessToken:
            break
        case .uploadYoutubeVideo(let token, _, _, _):
            return ["Authorization": "Bearer \(token)"]
        case .getCalculatorConfig, .getWebsiteData:
            return nil
        default:
            return APIHeaders().headerWithToken
        }
        return nil
    }
    
    public var baseURL: URL {
        switch self {
        case .confirmEmail, .doLogin:
            return URL.init(string: Constant.URLs.cabbage)!
        case .youTubeKeyWordSerch, .youTubeDetail, .youTubeChannelSearch, .getyoutubeSubscribedChannel, .getYoutubeCategory, .youTubeChannels:
            return URL.init(string: Constant.URLs.youtube)!
        case .uploadYoutubeVideo:
            return URL.init(string: "https://www.googleapis.com/upload/youtube/v3/videos?part=snippet&status")!
        case .getWeather:
            return URL.init(string: "https://api.openweathermap.org/data/2.5/weather")!
        case .instgramProfile, .getLongLivedToken:
            return URL.init(string: Constant.Instagram.graphUrl)!
        case .instgramProfileDetails:
            return URL.init(string: Constant.Instagram.baseUrl)!
        case .getAccessToken:
            return URL.init(string: Constant.Instagram.basicUrl)!
        default:
            return URL.init(string: API.shared.baseUrl)!
        }
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .getViralvids:
            return Paths.getViralvids
        case .search:
            return Paths.search
        case .confirmEmail:
            return Paths.confirmEmail
        case .signUp:
            return Paths.signUp
        case .verifyChannel:
            return Paths.verifyChannel
        case .getSplashImages:
            return Paths.getSplashImages
        case .logIn:
            return Paths.login
        case .socialLogin:
            return Paths.socailLogin
        case .doLogin:
            return Paths.doLogin
        case .writePost:
            return Paths.writePost
        case .updatePost(let postID,_, _, _, _, _, _, _, _, _, _, _, _, _, _,_,_,_,_):
            return Paths.updatePost + postID
        case .tagUserSearch:
            return Paths.tagUserSearch
        case .youTubeKeyWordSerch:
            return Paths.youTubeKeyWordSerch
        case .youTubeDetail:
            return Paths.youTubeDetail
        case .youTubeChannelSearch:
            return Paths.youTubeChannelSearch
        case .editStory(let storyId, _, _, _, _, _, _, _, _, _, _, _, _):
            return "stories/\(storyId)"
        case .createStory:
            return Paths.createStory
        case .logOut:
            return Paths.logOut
        case .getWeather:
            return ""
        case .getyoutubeSubscribedChannel(_, let forChannelId):
            if let forChannelId = forChannelId {
                return Paths.getyoutubeSubscribedChannel + "&forChannelId=\(forChannelId)&mine=true"
            } else {
                return Paths.getyoutubeSubscribedChannel + "&mine=true"
            }
        case .getYoutubeCategory :
            return Paths.getYoutubeCategoty
        case .uploadYoutubeVideo:
            return ""
        case .updateHashTagSet(_,_,_,let hashID),.deleteHashTagSet(let hashID):
            return Paths.addHashTag + "/\(hashID)"
        case .addHashTagSet, .getHashTagSets:
            return Paths.addHashTag
        case .updateProfile:
            return Paths.updateProfile
        case .instgramProfile:
            return "me"
        case .instgramProfileDetails(let username):
            return "\(username)/?__a=1"
        case .getAccessToken:
            return "oauth/access_token"
        case .getLongLivedToken:
            return "access_token"
        case .getChannelList:
            return Paths.getChannelList
        case .getPackage( _):
            return Paths.getPackage
        case .deleteFromCart:
            return Paths.deleteFromCart
        case .getCart:
            return Paths.getCart
        case .addPackage:
            return Paths.addPackage
        case .addPayment:
            return Paths.addPayment
        case .checkChannelExists:
            return Paths.checkChannelExists
        case .addToCart:
            return Paths.addToCart
        case .getChannelSuggestion:
            return Paths.getChannelSuggestion
        case .connectSocial(_, _, _):
            return Paths.connectSocial
        case .removeSocialConnection:
            return Paths.removeSocialConnection
        case .youTubeChannels:
            return Paths.youTubechannels
        case .getCalculatorConfig:
            return Paths.getCalculatorConfig
        case .getWebsiteData:
            return Paths.getWebsiteData
        case .setSubscription:
            return Paths.setSubsctiption
        case .forgotPassword:
            return Paths.forgotPassword
        case .getUserProfile:
            return Paths.getUserProfile
        case .setUserSettings, .getUserSettings:
            return Paths.userSettings
        case .loginWithKeycloak:
            return Paths.loginWithKeycloak
        case .logoutKeycloak:
            return Paths.logoutWithKeycloak
        case .addReferral:
            return Paths.addReferral
        case .buySubscription:
            return Paths.buySubscription
        case .subscriptionList:
            return Paths.subsciptionList
        case .userSync:
            return Paths.userSync
        case .downgradeSubscription:
            return Paths.downgradeSubscription
        case .getToken:
            return Paths.getToken
        case .createUser:
            return Paths.createUser
        case .userDelete:
            return Paths.userDelete
        case .uploadPicture:
            return Paths.updateUserProfile
        case .getReferredUserList:
            return Paths.getReferredUsersList
        case .setAffiliate:
            return Paths.setAffiliate
        case .doNotShowAgain:
            return Paths.doNotShowAgain
        case .addSocialPlatforms:
            return Paths.addSocialPlatforms
        case .setToken:
            return Paths.setToken
        case .removeToken:
            return Paths.removeToken
        case .getReferralNotification:
            return Paths.getReferralNotification
        case .setReferralNotification:
            return Paths.setReferralNotification
        case .setUserStateFlag:
            return Paths.setUserStateFlag
        case .setCountrys:
            return Paths.setUserStates
        case .getNotification:
            return Paths.getNotification
        case .notificationsRead:
            return Paths.readNotification
        case .editDisplayName:
            return Paths.editDisplayName
        case .setFollow:
            return Paths.setFollow
        case .setUnFollow:
            return Paths.setUnFollow
        }
       
    }
    
    /// The HTTP method used in the request.
    public var method: Moya.Method {
        switch self {
        case .signUp, .logIn, .verifyChannel, .search, .getAccessToken:
            return .post
        case .getSplashImages, .youTubeKeyWordSerch, .youTubeDetail, .youTubeChannelSearch, .getHashTagSets, .getWeather, .getyoutubeSubscribedChannel, .getYoutubeCategory, .instgramProfile, .instgramProfileDetails, .getLongLivedToken, .getChannelList, .getPackage, .getCart, .getViralvids, .youTubeChannels, .getCalculatorConfig, .getWebsiteData, .getUserProfile, .getUserSettings, .logoutKeycloak, .subscriptionList, .userSync, .getReferredUserList, .getReferralNotification, .getNotification:
            return .get
        case .updateProfile, .editStory, .updatePost, .updateHashTagSet:
            return .put
        case .deleteHashTagSet:
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
        case .doNotShowAgain(let isDoNotShowAgain):
            param = ["isDoNotShowMsg": isDoNotShowAgain]
        case .getViralvids(let page, let limit, let socialPlatform):
            param = ["page": page, "limit": limit]
            if let type = socialPlatform {
                param["type"] = type
            }
        case .search(let channel, let channelId):
            param = ["channelName": channel,
                     "channelId": channelId]
        case .confirmEmail(let userId, let email):
            param = ["userId": userId, "email": email]
        case .signUp(let email, let password, let channel, let refChannel, let isBusiness, let socialId, let provider, let channelName, let refferId, let deviceToken, let birthDate, let profileImageURL):
            param = ["email": email, "password": password, "channelId": channel, "refferingChannel": refChannel, "isBusiness": isBusiness, "channelName": channelName, "deviceType": 1]
            if let rId = refferId {
                param["refferingId"] = rId
            }
            if let deviceToken = deviceToken {
                param["deviceToken"] = deviceToken
            }
            if let birthDate = birthDate {
                param["birthDate"] = birthDate
            }
            if let provider = provider {
                param["provider"] = provider
            }
            if let socialPlatform = provider {
                param["socialPlatform"] = socialPlatform
            }
            if let id = socialId {
                param["socialId"] = id
            }
            if let profileImageURL = profileImageURL {
                param["profileImageURL"] = profileImageURL
            }
        case .socialLogin(let socialId, let email):
            param = ["socialId": socialId, "deviceType": 1]
            if let email = email {
                param["email"] = email
            }
        case .getSplashImages:
            break
        case .verifyChannel(let channel, let type):
            param = ["value": channel, "field": type]
        case .logIn(let email, let password, let deviceToken):
            param = ["username": email, "password": password, "deviceType": 1]
            if let deviceToken = deviceToken {
                param["deviceToken"] = deviceToken
            }
        case .updateProfile(let parameters):
            param = parameters
        case .doLogin(let userId):
            param = ["userId": userId]
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
        case .updatePost( _, let type , let text , let ischekedIn , let user , let media , let youTubeData , let wallTheme, let albumId, let checkedIn , let hashTags , let privacy, let friendExcept, let friendsOnly,  _ ,let feelings, let previewUrlData, let removedMedia,let tagArray):
            param = ["type": type, "text": text ?? "", "IschekedIn": ischekedIn ?? false ,"user": user]
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
            if let feelings = feelings {
                param["feelings"] = feelings
            } else {
                param["feelings"] = NSNull()
            }
            if let removedMedia = removedMedia {
                param["removedMedia"] = removedMedia
            }
        case .tagUserSearch(let user, let chanaleName):
            param = ["userId": user, "channelName": chanaleName]
        case .youTubeKeyWordSerch(let key, let order, let nextToken) :
            param = ["part": "id", "maxResults": "10", "q": key, "type": "video", "key": Constant.GoogleService.serviceKey]
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
        case .logOut(let deviceToken, _):
            param = ["deviceToken": deviceToken]
        case .addHashTagSet(let categoryName, let hashTags, let user):
            param = ["categoryName" : categoryName, "hashTags" : hashTags,"user":user]
        case .getHashTagSets:
            break
        case .updateHashTagSet(let categoryName, let hashTags , let usedCount, _) :
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
        case .getWeather(let lattitude, let longitude):
            param = ["lat": lattitude,
                     "lon": longitude,
                     "appid": Constant.OpenWeather.apiKey,
                     "units": "metric"]
        case .getyoutubeSubscribedChannel:
            break
        case .getYoutubeCategory:
            param = ["part": "snippet", "regionCode": "US", "key": Constant.GoogleService.serviceKey]
        case .uploadYoutubeVideo:
            break
        case .instgramProfile(let accessToken):
            param = [
                "access_token": accessToken,
                "fields": "account_type, username, media_count, username"
            ]
        case .getAccessToken(let parameters):
            param = parameters
        case .getLongLivedToken(let parameters):
            param = parameters
        case .instgramProfileDetails(let username):
            break
        case .getChannelList:
            break
        case .getPackage(let parentId):
            param = ["parentId": parentId]
        case .deleteFromCart(let userId, let individualChannels, let packageName, let packageChannels):
            param = ["userId" : userId, "packageName" :  packageName]
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
        case .getCart(let parentId):
            param = ["parentId": parentId]
        case .addPackage(let user, let parentId, let packageName, let packageCount,let isOwner, let paymentAmount, let paymentResponse):
            param = ["user": user, "parentId": parentId, "packageName": packageName, "packageCount": packageCount, "isOwner": isOwner, "paymentAmount": paymentAmount ?? 0, "paymentResponse": paymentResponse ?? [:]]
        case .addPayment(let userId, let channelNames):
            param = ["userId": userId]
            if let channelNames = channelNames {
                param["channelNames"] = channelNames
            } else {
                param["channelNames"] = NSNull()
            }
        case .checkChannelExists(let channelNames):
            param["channelNames"] = channelNames
        case .addToCart(let userId, let packageName,let individualChannels):
            param = ["userId": userId,
                     "packageName": packageName,
                     "individualChannels": individualChannels ?? ""]
        case .getChannelSuggestion(let channelName):
            param["channelName"] = channelName
        case .connectSocial(let socialPlatform, let socialId, let socialName):
            param = ["socialPlatform": socialPlatform,
                     "socialId": socialId,
                     "socialUsername": socialName]
        case .removeSocialConnection(let socialAccountId):
            param = ["socialAccountId": socialAccountId]
        case .youTubeChannels(let token):
            param = ["part": "snippet,contentDetails,statistics", "key": Constant.GoogleService.serviceKey, "mine": "true", "access_token": token]
        case .getCalculatorConfig(let type):
            param = ["type": type]
        case .getWebsiteData:
            param = ["page": 0, "limit": 100]
        case .setSubscription(let type, let code):
            param = ["code": code, "subscriptionType": type]
        case .forgotPassword(let username):
            param = ["username": username]
        case .getUserProfile:
            break
        case .setUserSettings(let appWatermark, let fastesteverWatermark, let faceDetection, let guidelineThickness, let guidelineTypes, let guidelinesShow, let iconPosition, let supportedFrameRates, let videoResolution, let watermarkOpacity, let guidelineActiveColor, let guidelineInActiveColor):
            param["userSettings"] = ["faceDetection": faceDetection, "guidelinesShow": guidelinesShow, "iconPosition": iconPosition, "supportedFrameRates": supportedFrameRates, "videoResolution" : videoResolution, "guidelineTypes": guidelineTypes, "guidelineThickness": guidelineThickness, "watermarkOpacity": watermarkOpacity, "fastesteverWatermark": fastesteverWatermark, "appWatermark": appWatermark, "guidelineActiveColor": guidelineActiveColor, "guidelineInActiveColor": guidelineInActiveColor]
        case .getUserSettings:
            break
        case .loginWithKeycloak(let code, let redirectUrl):
            param = ["code": code,
                     "redirect_uri": redirectUrl,"platformType":"ios"]
        case .logoutKeycloak:
            break
        case .addReferral(let refferingChannel):
            param = ["refferingChannel": refferingChannel]
        case .subscriptionList:
            break
        case .buySubscription(let parameters):
            param = parameters
        case .userSync:
            break
        case .downgradeSubscription(let subscriptionId):
            param = ["subscriptionId": subscriptionId]
        case .getToken(let appName):
            param = ["appName": appName]
        case .createUser(let channelId, let refferingChannel):
            param = ["channelId": channelId,
                     "refferingChannel": refferingChannel]
        case .userDelete:
            break
        case .uploadPicture:
            break
        case .getReferredUserList(let page, let limit):
            param = ["page": page, "limit": limit]
        case .setAffiliate(let isAllowAffiliate):
            param = ["isAllowAffiliate": isAllowAffiliate]
        case .addSocialPlatforms(let socialPlatforms):
            param = ["socialPlatforms": socialPlatforms]
        case .setToken(let deviceToken, let deviceType):
            param = [StaticKeys.deviceToken: deviceToken,
                     StaticKeys.deviceType: deviceType]
        case .removeToken(let deviceToken):
            param = [StaticKeys.deviceToken: deviceToken]
        case .getReferralNotification:
            break
        case .setReferralNotification(let isForEveryone, let customSignupNumber, let isBadgeEarned):
            param = [StaticKeys.isForEveryone: isForEveryone,
                     StaticKeys.customSignupNumber: customSignupNumber,
                     StaticKeys.badgeEarned: isBadgeEarned]
        case .setUserStateFlag(let isUserStateFlag):
            param = ["isShowFlags": isUserStateFlag]
        case .setCountrys(let countrys):
            if let country = countrys {
                param["userStateFlags"] = country
            }
        case .getNotification(let page):
            param = [StaticKeys.page: page, StaticKeys.limit: Constant.Value.paginationValue]
        case .notificationsRead(let notificationId):
            param = ["notificationId": notificationId]
        case .editDisplayName(let publicDisplayName, let privateDisplayName):
            param = [StaticKeys.publicDisplayName: publicDisplayName,
                     StaticKeys.privateDisplayName: privateDisplayName]
        case .setFollow(let userId):
            param = ["followUserId": userId]
        case .setUnFollow(let userId):
            param = ["followUserId": userId]
        }
        return param
    }
    
    /// The method used for parameter encoding.
    public var parameterEncoding: Moya.ParameterEncoding {
        switch self {
        case .logIn:
            return JSONEncoding.default
        case .getSplashImages, .youTubeDetail, .youTubeKeyWordSerch, .youTubeChannelSearch, .getWeather, .getYoutubeCategory:
            return JSONEncoding.default
        case .getyoutubeSubscribedChannel:
            return TokenURLEncoding.default
        case .getChannelList, .getPackage, .getCart, .getViralvids, .youTubeChannels, .getCalculatorConfig, .getWebsiteData, .getHashTagSets, .getUserProfile, .getUserSettings, .logoutKeycloak, .subscriptionList, .userSync, .getReferredUserList, .getReferralNotification, .getNotification:
            return URLEncoding.default
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
        case .uploadYoutubeVideo(_, let videoURL, let snippet, let status) :
            var multipartFormData: [Moya.MultipartFormData] = []
           
            var snippetString = ""
            
            if let title = snippet["title"] as? String,
                let categoryId = snippet["categoryId"] as? String,
                let channelId = snippet["channelId"] as? String {
                snippetString = "{'snippet':{'title' : '\(title)','description': '\(((snippet["description"]  as? String) ?? ""))','categoryId' : '\(categoryId)','channelId' : '\(channelId)'}}"
            } else if let title = snippet["title"] as? String,
                let categoryId = snippet["categoryId"] as? String {
                snippetString = "{'snippet':{'title' : '\(title)','description': '\(((snippet["description"]  as? String) ?? ""))','categoryId' : '\(categoryId)'}}"
            }
            
            multipartFormData.append(MultipartFormData.init(provider: MultipartFormData.FormDataProvider.data((snippetString.data(using: String.Encoding.utf8, allowLossyConversion: false))!), name: "snippet", mimeType: "application/json"))
            
            let statusString = "{'status' : {'privacyStatus':'\(status)'}}"
            multipartFormData.append(MultipartFormData.init(provider: MultipartFormData.FormDataProvider.data((statusString.data(using: String.Encoding.utf8, allowLossyConversion: false))!), name: "status", mimeType: "application/json"))
            if let videoData = try? Data.init(contentsOf: videoURL) {
                multipartFormData.append(MultipartFormData.init(provider: MultipartFormData.FormDataProvider.data(videoData), name: "video", fileName: videoURL.lastPathComponent, mimeType: "application/octet-stream"))
            }
            return .uploadMultipart(multipartFormData)
        case .uploadPicture(let image, let imageSource):
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                return .requestParameters(parameters: self.parameters ?? [:], encoding: self.parameterEncoding)
            }
            let imageDataMultiPart = [MultipartFormData(provider: .data(imageData), name: "image", fileName: "photo.jpg", mimeType: "image/jpeg")]
            var multipartData = imageDataMultiPart
            let imageSource = "\(imageSource)"
            guard let data = imageSource.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
                return .requestParameters(parameters: self.parameters ?? [:], encoding: self.parameterEncoding)
            }
            multipartData.append(MultipartFormData.init(provider: MultipartFormData.FormDataProvider.data(data), name: "imageSource", mimeType: "application/json"))
            return .uploadMultipart(multipartData)
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
                    print("Json Response \(String(describing: object.toJSONString()))")
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
                    print("Json Response \(String(describing: object.toJSONString()))")
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
                    case .error(let error):
                        observer.onError(error)
                    case .completed:
                        observer.onCompleted()
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
                    print("Json Response \(String(describing: try? object.mapJSON()))")
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
