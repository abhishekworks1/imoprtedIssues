//
//  LoginManager.swift
//  ReuseabelLogInComponets
//
//  Created by Sumit Goswami on 09/03/18.
//  Copyright © 2018 Simform Solutions PVT. LTD. All rights reserved.
//

import UIKit
import FBSDKLoginKit

public class FaceBookManager: NSObject {
    
    public static let shared = FaceBookManager()
    
    let facebookManger = FBSDKLoginKit.LoginManager()
   
    var userData: LoginUserData? = nil
    
    var isUserLogin: Bool {
        return AccessToken.isCurrentAccessTokenActive
    }
    
    func loadUserData(completion: @escaping (_ userName: LoginUserData?) -> ()) {
        if isUserLogin {
            guard let _ = AccessToken.current?.tokenString else {
                completion(nil)
                return
            }
            if let existUserData = userData {
                completion(existUserData)
                return
            }
            GraphRequest.init(graphPath: "me", parameters: ["fields": self.getNeededFields(requiredPermission: nil)]).start { [weak self] (connection, response, meError) in
                guard let `self` = self else { return }
                if let _ = meError {
                    completion(nil)
                } else {
                    self.userData = self.parseUserData(dataResponse: response as AnyObject)
                    completion(self.userData)
                }
            }
        } else {
            completion(nil)
        }
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    public func logout() {
        userData = nil
        facebookManger.logOut()
    }
    
    public func login(permission: [ReadPermissions]? = nil, requriedFields: [NeededFields]? = nil, controller: UIViewController, loginCompletion: @escaping (AccessToken?, NSError?) -> (), _ userDatacompletion: @escaping(LoginUserData?, NSError?) -> Void) {
        
        facebookManger.logIn(permissions: getReadPermission(readPermission: permission), from: controller) { (result, error) in
            if let unwrappedError = error {
                self.facebookManger.logOut()
                loginCompletion(nil, unwrappedError as NSError?)
            } else if (result?.isCancelled)! {
                self.facebookManger.logOut()
                loginCompletion(nil, nil)
            } else {
                guard let uResult = result else {
                    loginCompletion(nil, FBError.facebookNoResult)
                    return
                }
                if uResult.declinedPermissions.count == 0 {
                    if let _ = uResult.token?.tokenString {
                        GraphRequest.init(graphPath: "me", parameters: ["fields": self.getNeededFields(requiredPermission: requriedFields)]).start { (connection, response, meError) in
                            if let unwrappedMeError = meError {
                                userDatacompletion(nil, unwrappedMeError as NSError?)
                            } else {
                                userDatacompletion(self.parseUserData(dataResponse: response as AnyObject), nil)
                            }
                        }
                    }
                    loginCompletion(uResult.token, nil)
                } else {
                    loginCompletion(uResult.token, nil)
                }
            }
        }
    }
    
    private func getReadPermission(readPermission: [ReadPermissions]?) -> [String] {
        var permissionString: [String] = [String]()
        if readPermission == nil {
           return FacebookConstante.readPermissions
        } else {
            for value in readPermission! {
                permissionString.append(value.rawValue)
            }
        }
        return permissionString
    }
    
    private func getNeededFields(requiredPermission: [NeededFields]?) -> String {
        var permissionString: String = ""
        if requiredPermission == nil {
            return FacebookConstante.neededFields
        } else {
            for value in requiredPermission! {
                permissionString.append(value.rawValue)
                if value.rawValue != requiredPermission?.last?.rawValue {
                    permissionString.append(",")
                }
            }
        }
        return permissionString
    }
    
    private func parseUserData(dataResponse: AnyObject) -> LoginUserData {
        let userData = LoginUserData()
        if let id = dataResponse.object(forKey: NeededFields.id.rawValue) as? String {
            userData.userId = id
        }
        if let name = dataResponse.object(forKey: NeededFields.name.rawValue) as? String {
            userData.userName = name
        }
        if let about = dataResponse.object(forKey: NeededFields.about.rawValue) as? String {
            userData.about = about
        }
        if let birthday = dataResponse.object(forKey: NeededFields.birthday.rawValue) as? String {
            userData.birthday = birthday
        }
        if let email = dataResponse.object(forKey: NeededFields.email.rawValue) as? String {
            userData.email = email
        }
        if let gender = dataResponse.object(forKey: NeededFields.gender.rawValue) as? String {
            userData.gender = gender == "Male" ? 0 : 1
        }
        if let picture = dataResponse.object(forKey: "picture_large") as? NSDictionary {
            if let data = picture.value(forKey: "data") as? NSDictionary {
                userData.photoUrl = data.value(forKey: "url") as? String ?? ""
            }
        }
        return userData
    }
}
