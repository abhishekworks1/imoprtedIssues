//
//  LoginManager.swift
//  GoogleSigninReusabelComponets
//
//  Created by Sumit Goswami on 20/03/18.
//  Copyright © 2018 Simform Solutions PVT. LTD. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase

public typealias UserDataComplition = (_ userData: LoginUserData?, _ error: Error?) -> Void

public class GoogleManager: NSObject {
    
    public let googleManager = GIDSignIn.sharedInstance()
    var userDataBlock: UserDataComplition?
    var userDidDisconnectWithBlock: UserDataComplition?
    
    var isUserLogin: Bool {
        guard let signIn = GIDSignIn.sharedInstance() else { return false }
        if signIn.hasPreviousSignIn() {
            let hashYoutubeScope = GIDSignIn.sharedInstance().scopes.contains {
                guard let scope = $0 as? String  else {
                    return false
                }
                return scope == Constant.GoogleService.youtubeScope
            }
            return hashYoutubeScope
        } else {
            return false
        }
    }
    
    func getUserName(completion: @escaping (_ userName: String?) -> ()) {
        guard let signIn = GIDSignIn.sharedInstance() else {
            completion(nil)
            return
        }
        if isUserLogin {
            if signIn.currentUser == nil {
                signIn.restorePreviousSignIn()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    signIn.currentUser.authentication.getTokensWithHandler({ (accessToken, error) in
                        guard error == nil else { return }
                        let token = accessToken
                        completion(signIn.currentUser.profile.name)
                    })
                }
            } else {
                completion(signIn.currentUser.profile.name)
            }
        }
    }
    
    func getUserToken(completion: @escaping (_ userData: String?) -> ()) {
        guard let signIn = GIDSignIn.sharedInstance() else {
            completion(nil)
            return
        }
        if isUserLogin {
            if signIn.currentUser == nil {
                signIn.restorePreviousSignIn()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    signIn.currentUser.authentication.getTokensWithHandler({ (accessToken, error) in
                        guard error == nil else { return }
                        let token = accessToken
                        completion(token?.accessToken)
                    })
                }
            } else {
                signIn.currentUser.authentication.getTokensWithHandler({ (accessToken, error) in
                    guard error == nil else { return }
                    let token = accessToken
                    completion(token?.accessToken)
                })
            }
        }
    }
    
    var userData: LoginUserData?
    
    // this is the Swift way to do singletons
    static let shared = GoogleManager()
    
    internal override init() {
        super.init()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        var scopes = GIDSignIn.sharedInstance().scopes
        scopes?.append(Constant.GoogleService.youtubeScope)
        GIDSignIn.sharedInstance().scopes = scopes
    }
    
    public func logout() {
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().disconnect()
    }
    
    public func login(controller: UIViewController, complitionBlock: @escaping UserDataComplition, didDisconnectBlock: @escaping UserDataComplition) {
        userDataBlock = complitionBlock
        userDidDisconnectWithBlock = didDisconnectBlock
        googleManager?.presentingViewController = controller
        googleManager?.delegate = self
        googleManager?.signIn()
    }
    
    public func handelOpenUrl(app: UIApplication, url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
}

// MARK: - GIDSignInDelegate
extension GoogleManager: GIDSignInDelegate {
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
            if let block = self.userDataBlock {
                block(nil, error)
            }
        } else {
            // Perform any operations on signed in user here.
            let data = LoginUserData(userId: user.userID, userName: user.profile.name, email: user.profile.email, gender: 0, photoUrl: user.profile.imageURL(withDimension: 200)?.absoluteString, idToken: user.authentication.idToken, accessToken: user.authentication.accessToken)
            userData = data
            if let block = self.userDataBlock {
                block(data, nil)
            }
        }
    }
    
    public func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
            if let block = self.userDidDisconnectWithBlock {
                block(nil, error)
            }
        } else {
            userData = nil
            if let block = self.userDidDisconnectWithBlock {
                block(nil, nil)
            }
        }
    }
}
