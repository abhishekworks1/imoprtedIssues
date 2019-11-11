//
//  CurrentUser.swift
//  ProManager
//
//  Created by Viraj Patel on 07/08/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import AVKit

class CurrentUser {
    
    static let shared = CurrentUser()
    
    var referrerChannelURL: String? = nil
    
    func setReferrerChannelURL(_ referrerURL: String?) {
        referrerChannelURL = referrerURL
    }
    
    var activeUser: User?
    
    func setActiveUser(_ user: User?) {
        activeUser = user
        if user == nil {
            referrerChannelURL = nil
        } else {
            setReferrerChannelURL(user?.deepLinkUrl)
        }
    }
    
    func createNewReferrerChannelURL(_ isNewCreate: Bool = false,_ newChannelId: String? = nil, complation: @escaping (Bool, String)-> (Void)) {
        if let url = referrerChannelURL, !isNewCreate {
            complation(false, url)
            return
        }
    }
    
}
