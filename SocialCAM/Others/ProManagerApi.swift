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
    case logIn(email: String, password: String, deviceToken: String?)
    case uploadYoutubeVideo(token: String, videoURL: URL, snippet: [String:Any], status: String)
    case getYoutubeCategory(token: String)
    case getyoutubeSubscribedChannel(token: String, forChannelId: String?)
    case youTubeChannelSearch(channelId: String, order: String?, nextPageToken: String?)
    case youTubeDetail(id: String)
    case youTubeKeyWordSerch(key: String, order: String?, nextPageToken: String?)
    case deleteHashTagSet(hashId: String)
    case getHashTagSets(Void)
    case logOut(deviceToken: String, userId: String)
    case createStory(url: String, duration: String, type: String, storiType: Int, user: String, thumb: String?, lat: String, long: String, address: String, tags: [[String: Any]]?, hashtags: [String]?, publish: Int)
    case writePost(type: String, text: String?, isChekedIn: Bool?, user: String, media: [[String:Any]]?, youTubeData: [String:Any]?, wallTheme: [String:Any]?, albumId: String?, checkedIn: [String:Any]?, hashTags:[String]?, privacy: String?, friendExcept:[String]?, friendsOnly:[String]?, feelingType: String?, feelings:[[String:Any]]?, previewUrlData: [String: Any]?, tagChannelAry:[String]?)
    case editStory(storyId: String, storyURL: String, duration: String?, type: String?, storiType: Int?, user: String, thumb: String?, lat: String?, long: String?, address: String?, tags: [[String: Any]]?, hashtags: [String]?, publish: Int?)
    case tagUserSearch(user: String, channelName: String)
    case getWeather(lattitude: String, longitude: String)
    case updateProfile(param:[String:Any])
    case doLogin(userId: String)
    
    
    var endpoint: Endpoint {
        var endpointClosure = MoyaProvider<ProManagerApi>.defaultEndpointMapping(for: self)
        
        switch self {
        case .getSplashImages, .logIn,.youTubeKeyWordSerch, .youTubeDetail, .youTubeChannelSearch, .getYoutubeCategory:
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
        if let parameters = self.parameters {
            print("Request parameters : \(parameters) \n")
        }
        return endpointClosure
    }
}

extension ProManagerApi: TargetType {
    public var headers: [String: String]? {
        switch self {
        case .getSplashImages, .logIn, .doLogin, .youTubeKeyWordSerch, .youTubeDetail, .youTubeChannelSearch, .getYoutubeCategory:
            return APIHeaders().headerWithoutAccessToken
        case .getWeather:
            break
        case .uploadYoutubeVideo(let token, _, _, _):
            return ["Authorization": "Bearer \(token)"]
        default:
            return APIHeaders().headerWithToken
        }
        return nil
    }
    
    public var baseURL: URL {
        switch self {
        case .doLogin:
            return URL.init(string: Constant.URLs.cabbage)!
        case .youTubeKeyWordSerch, .youTubeDetail, .youTubeChannelSearch, .getyoutubeSubscribedChannel, .getYoutubeCategory:
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
        case .getSplashImages:
            return Paths.getSplashImages
        case .logIn:
            return Paths.login
        case .doLogin:
            return Paths.doLogin
        case .writePost:
            return Paths.writePost
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
        case .deleteHashTagSet(let hashID):
            return Paths.addHashTag + "/\(hashID)"
        case .getHashTagSets:
            return Paths.addHashTag
        case .updateProfile:
            return Paths.updateProfile
        }
       
    }
    
    /// The HTTP method used in the request.
    public var method: Moya.Method {
        switch self {
        case .logIn:
            return .post
        case .getSplashImages, .youTubeKeyWordSerch, .youTubeDetail,.youTubeChannelSearch, .getHashTagSets, .getWeather, .getyoutubeSubscribedChannel, .getYoutubeCategory:
            return .get
        case .updateProfile, .editStory:
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
        case .getSplashImages:
            break
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
        case .getHashTagSets:
            break
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
        }
        return param
    }
    
    /// The method used for parameter encoding.
    public var parameterEncoding: Moya.ParameterEncoding {
        switch self {
        case .logIn:
            return JSONEncoding.default
        case .getSplashImages, .youTubeDetail, .youTubeKeyWordSerch, .youTubeChannelSearch, .getHashTagSets, .getWeather, .getYoutubeCategory:
            return URLEncoding.methodDependent
        case .getyoutubeSubscribedChannel:
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
