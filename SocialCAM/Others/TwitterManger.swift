//
//  TwitterManger.swift
//  SocialCAM
//
//  Created by Viraj Patel on 19/11/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import TwitterKit
import AVKit

public struct SocialLoginError {
    static let userUnauthorized:NSError = NSError(domain: "ShiploopHttpResponseErrorDomain", code:401, userInfo: [NSLocalizedDescriptionKey:"Unauthorized",                                                                                                              NSLocalizedFailureReasonErrorKey:"User not logged in"])
    static let parsingError:NSError = NSError(domain: "ShiploopHttpResponseErrorDomain", code: 422, userInfo: [NSLocalizedDescriptionKey:"Parsing Error", NSLocalizedFailureReasonErrorKey:"User data parsing error"])
}

public struct TwitterURL {
    static let VerifyCredentails = "https://api.twitter.com/1.1/account/verify_credentials.json"
    static let Logout = "https://api.twitter.com"
}

public enum TWReadPermissions: String {
    case includeEmail          =  "include_email"
    case skipStatus            =  "skip_status"
}

public struct TwitterDefaultPermission {
    public static let userPermission: [String: Any] = [TWReadPermissions.includeEmail.rawValue: "true", TWReadPermissions.skipStatus.rawValue: "true"]
}

open class TwitterManger: NSObject {
    
    static let shared: TwitterManger = TwitterManger()
    
    private var store: TWTRSessionStore {
        return TWTRTwitter.sharedInstance().sessionStore
    }
    
    var userData: LoginUserData? = nil
    
    var isUserLogin: Bool {
        return store.hasLoggedInUsers()
    }
    
    func loadUserData(completion: @escaping (_ userModel: LoginUserData?) -> ()) {
        if isUserLogin {
            guard let userId = store.session()?.userID else {
                completion(nil)
                return
            }
            if let existUserData = userData {
                completion(existUserData)
                return
            }
            let twitterClient = TWTRAPIClient(userID: userId)
            twitterClient.loadUser(withID: userId) { [weak self] (user, error) in
                guard let `self` = self else { return }
                print(user?.profileImageURL ?? "")
                print(user?.name ?? "")
                self.userData = LoginUserData(userId: userId, userName: user?.name, email: user?.screenName, gender: 0, photoUrl: user?.profileImageURL)
                completion(self.userData)
            }
        } else {
            completion(nil)
        }
    }
        
    public override init() {
        super.init()
        TWTRTwitter.sharedInstance().start(withConsumerKey: Constant.TWTRTwitter.consumerKey, consumerSecret: Constant.TWTRTwitter.consumerSecret)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [AnyHashable: Any] = [:]) -> Bool {
        return TWTRTwitter.sharedInstance().application(app, open: url, options: options)
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
    
    public func getLoggedInUserDetailswith(permission: [String: Any] = TwitterDefaultPermission.userPermission, completion:@escaping (_ userData: LoginUserData?, _ error: Error?) -> ()) {
        let store = TWTRTwitter.sharedInstance().sessionStore
        guard let userId = store.session()?.userID else { return }
        if store.session(forUserID: userId) != nil {
            let client = TWTRAPIClient.withCurrentUser()
            let request = client.urlRequest(withMethod: "GET", urlString: TwitterURL.VerifyCredentails, parameters: permission, error: nil)
            
            client.sendTwitterRequest(request, completion: { (response, data, error) in
                print("\n\(String(describing: data)) \(String(describing: response)) \(String(describing: error))\n\n")
                if data != nil {
                    if let jsonData = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                        let responseData = LoginUserData(userId: "\(String(describing: jsonData["id"] as? Int))", userName: jsonData["name"] as? String, email: jsonData["email"]  as? String, gender: 0, photoUrl: jsonData["profile_image_url"] as? String)
                        completion(responseData, nil)
                    } else {
                        completion(nil, SocialLoginError.parsingError)
                    }
                } else {
                    completion(nil, error)
                }
            })
            
        } else {
            completion(nil, SocialLoginError.userUnauthorized)
        }
    }
    
    func uploadImageOnTwitter(withText text: String = Constant.Application.displayName, image: UIImage, completion: @escaping (Bool, String?) -> Void) {
        guard let userId = store.session()?.userID else { return }
        let client = TWTRAPIClient.init(userID: userId)
        client.sendTweet(withText: text, image: image) { (tweet, error) in
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
        client.sendTweet(withText: text, videoData: videoData) { (tweet, error) in
            if let error = error {
                print(error.localizedDescription as Any)
                completion(false, error.localizedDescription)
            } else {
                completion(true, tweet?.author.name)
            }
        }
    }
    
    func logout() {
        self.userData = nil
        guard let userId = store.session()?.userID else { return }
        store.logOutUserID(userId)
        guard let url = URL(string: TwitterURL.Logout) else {
            return
        }
        let cookies = HTTPCookieStorage.shared.cookies(for: url)
        for cookie in cookies! {
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
    }
}
