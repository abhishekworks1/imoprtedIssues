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
        } else {
//            var userId: String = ""
//            if let user = CurrentUser.shared.activeUser, let channelId = user.channelId {
//                userId = channelId
//            } else if let channelId = newChannelId {
//                userId = channelId
//            }
//            let buo = BranchUniversalObject.init(canonicalIdentifier: userId)
//            buo.title = userId
//            buo.contentDescription = ""
//            buo.imageUrl = ""
//            buo.publiclyIndex = true
//            buo.locallyIndex = true
//            buo.contentMetadata.customMetadata["channelName"] = userId
//
//            let lp: BranchLinkProperties = BranchLinkProperties()
//            lp.channel = userId
//            lp.feature = "sharing"
//            lp.campaign = "channelName"
//            lp.stage = "Newuser"
//
//            lp.addControlParam("$desktop_url", withValue: "http://pro-manager.simform.solutions/" + userId)
//            lp.addControlParam("$ios_url", withValue: "http://pro-manager.simform.solutions/" + userId)
//            lp.addControlParam("$ipad_url", withValue: "http://pro-manager.simform.solutions/" + userId)
//            lp.addControlParam("$android_url", withValue: "http://pro-manager.simform.solutions/" + userId)
//            lp.addControlParam("$match_duration", withValue: "2000")
//
//            lp.addControlParam("custom_data", withValue: "yes")
//            lp.addControlParam("look_at", withValue: "this")
//            lp.addControlParam("nav_to", withValue: "over here")
//            lp.addControlParam("random", withValue: UUID.init().uuidString)
//
//            buo.getShortUrl(with: lp) { (url, error) in
//                self.setReferrerChannelURL(url)
//                print(url ?? "")
//                complation(true, url ?? "")
//            }
        }
    }
    
}
