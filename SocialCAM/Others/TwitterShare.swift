//
//  TwitterShare.swift
//  SocialCAM
//
//  Created by Viraj Patel on 19/11/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import TwitterKit
import AVKit

open class TwitterShare: NSObject {
    
    static let shared: TwitterShare = TwitterShare()
    
    var delegate: ShareStoriesDelegate?
   
    private var store: TWTRSessionStore {
        return TWTRTwitter.sharedInstance().sessionStore
    }
    
    var isTwitterLogin: Bool {
        return store.hasLoggedInUsers()
    }
    
    public override init() {
        super.init()
        TWTRTwitter.sharedInstance().start(withConsumerKey: Constant.TWTRTwitter.consumerKey, consumerSecret: Constant.TWTRTwitter.consumerSecret)
       
    }
    
    func login(completion: @escaping (Bool, String?) -> Void) {
        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
            if session != nil {
                print("\(String(describing: session?.userName))")
                completion(true, session?.userName)
            } else {
                let message = error?.localizedDescription
                completion(false, message)
                print("error: " + (message ?? ""))
            }
        })
    }
    
    func uploadImageOnTwitter(withText text: String = Constant.Application.displayName, image: UIImage, completion: @escaping (Bool, String?) -> Void) {
        guard let userId = store.session()?.userID else { return }
        let client = TWTRAPIClient.init(userID: userId)
        client.sendTweet(withText: text, image: image) {
            (tweet, error) in
            if let error = error {
                print(error.localizedDescription as Any)
                completion(false, error.localizedDescription)
            } else {
                completion(true, tweet?.author.name)
            }
        }
    }
    
    func uploadVideoOnTwitter(withText text: String = Constant.Application.displayName, videoUrl: URL, completion: @escaping (Bool, String?) -> Void) {
        guard let userId = store.session()?.userID else { return }
        let client = TWTRAPIClient.init(userID: userId)
        // Get data from Url
        guard let videoData = try? Data(contentsOf: videoUrl) else {
            // Handle if data is nil
            return
        }
        client.sendTweet(withText: text, videoData: videoData) {
            (tweet, error) in
            if let error = error {
                print(error.localizedDescription as Any)
                completion(false, error.localizedDescription)
            } else {
                completion(true, tweet?.author.name)
            }
        }
    }
    
    func logout() {
        guard let userId = store.session()?.userID else { return }
        store.logOutUserID(userId)
    }
}
