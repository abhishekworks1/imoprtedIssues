//
//  AppleSignInManager.swift
//  SocialCAM
//
//  Created by Viraj Patel on 06/02/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import AuthenticationServices

@available(iOS 13.0, *)
open class AppleSignInManager: NSObject {
    
    static let shared: AppleSignInManager = AppleSignInManager()
    var userDataBlock: UserDataComplition?
    var userDidDisconnectWithBlock: UserDataComplition?
    var userData: LoginUserData?
    var presentController: UIViewController?
    
    var isUserLogin: Bool {
        return Defaults.shared.appleLoginUserData != nil ? true : false
    }
    
    func loadUserData(completion: @escaping (_ userModel: LoginUserData?) -> Void) {
        if isUserLogin {
            if let existUserData = userData {
                completion(existUserData)
            } else if let appleLoginUserData = Defaults.shared.appleLoginUserData {
                completion(appleLoginUserData)
            }
        } else {
            completion(nil)
        }
    }
    
    public override init() {
        super.init()
    }
    
    func login(controller: UIViewController, complitionBlock: @escaping UserDataComplition, didDisconnectBlock: @escaping UserDataComplition) {
        presentController = controller
        userDidDisconnectWithBlock = didDisconnectBlock
        userDataBlock = complitionBlock
        handleAuthorizationAppleIDButtonPress()
    }
    
    func logout() {
        Defaults.shared.appleLoginUserData = nil
        userData = nil
    }
    
    @objc func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.presentationContextProvider = self
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
}

@available(iOS 13.0, *)
extension AppleSignInManager: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("\(error.localizedDescription)")
        Defaults.shared.appleLoginUserData = nil
        userData = nil
        if let block = self.userDidDisconnectWithBlock {
            block(nil, error)
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        
        let id: String = appleIDCredential.user
        let email: String = appleIDCredential.email ?? ""
        let lname: String = appleIDCredential.fullName?.familyName ?? ""
        let fname: String = appleIDCredential.fullName?.givenName ?? ""
        let name: String = fname + lname
        let appleId: String = appleIDCredential.identityToken?.base64EncodedString() ?? ""
        let result =  String("ID:\(id),\n Email:\(email),\n  Name:\(name),\n  IdentityToken:\(appleId)")
        print(result)
        let userData = LoginUserData(userId: "\(id))", userName: name, email: email, gender: 0, photoUrl: "", idToken: appleId, accessToken: appleId)
        Defaults.shared.appleLoginUserData = userData
        self.userData = userData
        if let block = self.userDataBlock {
            block(userData, nil)
        }
    }
    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return presentController!.view.window!
    }
    
}
