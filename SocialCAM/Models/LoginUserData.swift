//
//  LoginUserData.swift
//  SocialCAM
//
//  Created by Viraj Patel on 30/01/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation

public class LoginUserData: Codable {
    public var userId: String? = ""
    public var userName: String? = ""
    public var email: String? = ""
    public var gender: Int = 0
    public var birthday: String? = ""
    public var about: String? = ""
    public var photoUrl: String? = ""
    public var idToken: String? = ""
    public var accessToken: String? = ""
    
    init(userId: String? = nil, userName: String? = nil, email: String? = nil, gender: Int? = nil, birthday: String? = nil, about: String? = nil, photoUrl: String? = nil, idToken: String? = nil, accessToken: String? = nil) {
        self.userId = userId ?? ""
        self.userName = userName ?? ""
        self.email = email ?? ""
        self.gender = gender ?? 0
        self.birthday = birthday ?? ""
        self.about = about ?? ""
        self.photoUrl = photoUrl ?? ""
        self.idToken = idToken ?? ""
        self.accessToken = accessToken ?? ""
    }
    
}
