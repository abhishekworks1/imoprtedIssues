//
//  ProfilePresenter.swift
//  SimpleInstagram
//
//  Created on 23/01/2020.
//  Copyright © 2020 clementozemoya. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import RxAlamofire
import ObjectMapper

protocol ProfileDelegate: class {
    func profileDidLoad(profile: ProfileDetailsResponse)
    func profileLoadFailed(error: Error)
}

class ProfilePresenter {
    
    var delegate: ProfileDelegate?
    let disposeBag = DisposeBag()
    
    required init(delegate: ProfileDelegate) {
        self.delegate = delegate
        fetchProfile()
    }
    
    func fetchProfile() {
        loadProfile()
            .flatMap({ meResponse -> Observable<ProfileDetailsResponse> in
                return self.loadProfileDetails(username: meResponse.username ?? "")
            })
            .subscribe( onNext: { [weak self] response in
                guard let `self` = self else {
                    return
                }
                print("Profile loaded successfully")
                self.delegate?.profileDidLoad(profile: response)
            }, onError: { [weak self] error in
                guard let `self` = self else {
                    return
                }
                print("Error loading profile", error)
                self.delegate?.profileLoadFailed(error: error)
            }).disposed(by: disposeBag)
    }
    
    func loadProfile() -> Observable<MeResponse> {
        guard let token = Defaults.shared.instagramToken else { return Observable.empty() }
        return getMe(accessToken: token)
            .do(onNext: { response in
                print("On next")
            })
    }
    
    func getMe(accessToken: String) -> Observable<MeResponse> {
        let url = Constant.Instagram.graphUrl + "me"
        let params = [
            "access_token": accessToken,
            "fields": "account_type, username, media_count, username"
        ]
        return RxAlamofire.requestJSON(.get, url, parameters: params)
            .debug()
            .mapObject(type: MeResponse.self)
    }
    
    func getProfileDetails(username: String) -> Observable<ProfileDetailsResponse> {
        let url = Constant.Instagram.baseUrl + "\(username)/?__a=1"
        
        return RxAlamofire.requestJSON(.get, url)
            .debug()
            .mapObject(type: ProfileDetailsResponse.self)
    }
    
    func loadProfileDetails(username: String) -> Observable<ProfileDetailsResponse> {
        return getProfileDetails(username: username)
    }
}
