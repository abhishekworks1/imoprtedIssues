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
    
    func getAccessToken(code: String, clientId: String, clientSecret: String, redirectUrl: String, completion: @escaping (_ accessTokenResponse: String?) -> ()) {
        let params = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "code": code,
            "redirect_uri": redirectUrl,
            "grant_type": "authorization_code"
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Accept": "application/json"
        ]
        
        AF.request(Constant.Instagram.basicUrl + "oauth/access_token", method: .post, parameters: params, encoding:  URLEncoding.httpBody, headers: headers).responseJSON(completionHandler: { (response) in
            switch(response.result) {
            case.success(let jsonData):
                print("success", jsonData)
                guard let json = jsonData as? [String: Any], let accessToken = json["access_token"] as? String else {
                    return
                }
                completion(accessToken)
            case.failure(let error):
                print("Not Success",error.localizedDescription)
                completion(nil)
            }
        })
    }
    
    func getLongLivedToken(accessToken: String, clientSecret: String, completion: @escaping (_ accessTokenResponse: String?) -> ()) {
        AF.request(Constant.Instagram.graphUrl + "access_token?client_secret=\(clientSecret)&grant_type=ig_exchange_token&access_token=\(accessToken)").responseJSON(completionHandler: { (response) in
            switch(response.result) {
            case.success(let jsonData):
                print("success", jsonData)
                guard let json = jsonData as? [String: Any], let accessToken = json["access_token"] as? String else {
                    return
                }
                completion(accessToken)
            case.failure(let error):
                print("Not Success",error.localizedDescription)
                completion(nil)
            }
        })
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
