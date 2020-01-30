//
//  ProfileDetails.swift
//  SimpleInstagram
//
//  Created by INITS on 23/01/2020.
//  Copyright © 2020 clementozemoya. All rights reserved.
//

import Foundation
import ObjectMapper

class ProfileDetailsResponse: Codable, Mappable {
    var fullname: String?
    var biography: String?
    var follow: Int?
    var followedBy: Int?
    var profilePicUrl: String?
    var id: String?
    var username: String?
    
    required init(map: Map) {
    }
    
    func mapping(map: Map) {
        fullname <- map["graphql.user.full_name"]
        biography <- map["graphql.user.biography"]
        follow <- map["graphql.user.edge_follow.count"]
        followedBy <- map["graphql.user.edge_followed_by.count"]
        profilePicUrl <- map["graphql.user.profile_pic_url"]
        id <- map["graphql.user.id"]
        username <- map["graphql.user.username"]
    }
}
