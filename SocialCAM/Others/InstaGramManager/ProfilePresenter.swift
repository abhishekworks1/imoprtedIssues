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
    }
    
    func loadProfile() {
        guard let token = Defaults.shared.instagramToken else { return }
        AF.request(Constant.Instagram.graphUrl + "me?access_token=\(token)&fields=id,username,account_type").responseJSON(completionHandler: { (response) in
            switch(response.result) {
            case.success(let jsonData):
                print("success", jsonData)
                guard let json = jsonData as? [String: Any], let username = json["username"] as? String else {
                    return
                }
                self.loadProfileDetails(username: username)
            case.failure(let error):
                print("Not Success",error.localizedDescription)
            }
        })
    }
    
    func loadProfileDetails(username: String) {
        AF.request(Constant.Instagram.baseUrl + "\(username)/?__a=1").responseJSON(completionHandler: { (response) in
            switch(response.result) {
            case.success(let jsonData):
                print("success", jsonData)
                guard let json = jsonData as? [String: Any] else {
                    return
                }
                guard let userProfile = Mapper<ProfileDetailsResponse>().map(JSONString: json.dict2json() ?? "") else {
                    return
                }
                self.delegate?.profileDidLoad(profile: userProfile)
                
            case.failure(let error):
                print("Not Success",error.localizedDescription)
                self.delegate?.profileLoadFailed(error: error)
            }
        })
    }
}
