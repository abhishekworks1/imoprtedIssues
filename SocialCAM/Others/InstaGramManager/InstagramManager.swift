//
//  AuthManager.swift
//  SimpleInstagram
//
//  Created by INITS on 23/01/2020.
//  Copyright © 2020 clementozemoya. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import RxAlamofire
import ObjectMapper

class InstagramManager: NSObject {
    
    public static let shared = InstagramManager()
   
    var presenter: ProfilePresenter?
    weak var delegate: ProfileDelegate?
    let disposeBag = DisposeBag()
   
    override init() {
        super.init()
        presenter = ProfilePresenter(delegate: self)
    }
    
    var isUserLogin: Bool {
        return Defaults.shared.instagramToken == nil ? false : true
    }
    
    var profileDetails: ProfileDetailsResponse? {
        if isUserLogin, let profileDetailsResponse = Defaults.shared.instagramProfile {
           return profileDetailsResponse
        } else {
            return nil
        }
    }
    
    func loadProfile() {
        presenter?.fetchProfile()
    }
    
    public func logout() {
        Defaults.shared.instagramProfile = nil
        Defaults.shared.instagramToken = nil
    }
    
    func getAccessToken(code: String, clientId: String, clientSecret: String, redirectUrl: String) -> Observable<AccessTokenResponse> {
        let url = Constant.Instagram.basicUrl + "oauth/access_token"
        let params = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "code": code,
            "redirect_uri": redirectUrl,
            "grant_type": "authorization_code"
        ]
        return RxAlamofire.requestJSON(.post, url, parameters: params)
            .debug()
            .mapObject(type: AccessTokenResponse.self)
    }
    
    func getLongLivedToken(accessToken: String, clientSecret: String) -> Observable<AccessTokenResponse> {
        let url = Constant.Instagram.graphUrl + "access_token"
        let params = [
            "client_secret": clientSecret,
            "access_token": accessToken,
            "grant_type": "ig_exchange_token"
        ]
        return RxAlamofire.requestJSON(.get, url, parameters: params)
            .debug()
            .mapObject(type: AccessTokenResponse.self)
    }
}

// MARK: - Profile delegate
extension InstagramManager: ProfileDelegate {
    func profileDidLoad(profile: ProfileDetailsResponse) {
        Defaults.shared.instagramProfile = profile
        delegate?.profileDidLoad(profile: profile)
    }
    
    func profileLoadFailed(error: Error) {
        delegate?.profileLoadFailed(error: error)
    }
    
}
