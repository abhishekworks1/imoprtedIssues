//
//  APIManager.swift
//  Bookmarks
//
//  Created by Steffi Pravasi on 15/10/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import Moya_ObjectMapper
import RxSwift
import ObjectMapper

public enum ProManagerApi {
    case writePost(type: String, user: String, bookmark: [String:Any]?, privacy:String?)
    case createStory(url: String, duration: String, type: String, user: String, thumb: String?)
    case createViralvids(title: String, image: String?, description: String?, referenceLink: String?, hashtags: [String]?)
    case getViralvids(Void)
    
    var endpoint: Endpoint {
        var endpointClosure = MoyaProvider<ProManagerApi>.defaultEndpointMapping(for: self)
        endpointClosure = endpointClosure.adding(newHTTPHeaderFields: ["Content-Type": "application/json", "x-access-token": Defaults.shared.sessionToken ?? "", "userid": Defaults.shared.currentUser?.id ?? ""])
        return endpointClosure
    }
}

public struct NewPaths {
    static let writePost = "articles/write"
    static let createStory = "stories/createStory"
    static let createViralvids = "viralvids/create"
    static let getViralvids = "viralvids"
}

extension ProManagerApi: TargetType {
    
    public var headers: [String : String]? {
        return ["Content-Type": "application/json", "x-access-token": Defaults.shared.sessionToken ?? "", "userid": Defaults.shared.currentUser?.id ?? ""]
    }
    
    public var baseURL: URL {
        return URL.init(string: Constant.URLs.base)!
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .getViralvids:
             return NewPaths.getViralvids
        case .createViralvids:
            return NewPaths.createViralvids
        case .writePost:
            return NewPaths.writePost
        case .createStory:
            return NewPaths.createStory
        }
    }
    
    /// The HTTP method used in the request.
    public var method: Moya.Method {
        switch self {
        case .getViralvids:
            return .get
        default:
            return .post
        }
        
    }
    
    /// The parameters to be incoded in the request.
    public var parameters: [String : Any]? {
        var param = [String:Any]()
        switch self {
        case .writePost(let type, let user, let media, let privacy):
            param = ["type": type ,"user": user]
            if let media = media {
                param["bookmark"] = media
            }
            if let privacy = privacy {
                param["privacy"] = privacy
            }
        case .createStory(let url, let duration, let type, let user, let thumb):
            param = ["url": url,
                     "duration": duration,
                     "type": type,
                     "user": user,
                     "address": "",
                     "latitude": "0.0",
                     "longitude": "0.0"]
            if let thumb = thumb {
                param["thumb"] = thumb
            }
        case .createViralvids(title: let title, image: let image, description: let description, referenceLink: let referenceLink, hashtags: let hashtags):
            param = ["title": title]
            if let image = image {
                param["image"] = image
            }
            if let description = description {
                param["description"] = description
            }
            if let referenceLink = referenceLink {
                param["referenceLink"] = referenceLink
            }
            if let hashtags = hashtags {
                param["hashtags"] = hashtags
            }
        case .getViralvids():
            break
        }
        return param
    }
    
    /// The method used for parameter encoding.
    public var parameterEncoding: Moya.ParameterEncoding {
        return JSONEncoding.default
    }
    
    /// Provides stub data for use in testing.
    public var sampleData: Data {
        return Data()
    }
    
    /// The type of HTTP task to be performed.
    public var task: Moya.Task {
        return .requestParameters(parameters: self.parameters ?? [:], encoding: self.parameterEncoding)
        
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
            let lockService = MoyaProvider<ProManagerApi>(endpointClosure: endPointClosure)
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
            let lockService = MoyaProvider<ProManagerApi>(endpointClosure: endPointClosure)
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
            
            let lockService = MoyaProvider<ProManagerApi>(endpointClosure: endPointClosure)
            let request = lockService.rx.requestWithProgress(self)
                .subscribe { event -> Void in
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
            let lockService = MoyaProvider<ProManagerApi>(endpointClosure: endPointClosure)
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
