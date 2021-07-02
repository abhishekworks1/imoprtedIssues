//
//  KeycloakAuthViewController.swift
//  SocialCAM
//
//  Created by Nilisha Gupta on 18/06/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit
import WebKit
import FirebaseCrashlytics

class KeycloakAuthViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var webView: WKWebView!
    
    // MARK: - Variables
    internal var isRegister = true
    var urlString = ""
    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        CommonFunctions.WebCacheCleaner.clean()
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        self.showHUD()
        webView.customUserAgent = Constant.WebviewUserAgent.userAgent
        guard let keycloakURL = URL(string: urlString) else {
            return
        }
        let urlRequest = URLRequest(url: keycloakURL)
        webView.load(urlRequest)
        webView.reload()
        webView.navigationDelegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.dismissHUD()
    }
    
    // MARK: - Button Action Methods
    @IBAction func btnBackTapped(_ sender: Any) {
        webView.canGoBack ? webView.goBack() : self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - WKNavigationDelegate
extension KeycloakAuthViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if navigationAction.request.url != nil {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false),
                  let fragments = components.fragment else {
                decisionHandler(.allow)
                return
            }
            components.query = fragments
            if let url = components.scheme {
                let redirectUrl = "\(url)\(KeycloakRedirectLink.endUrl)"
                var code: String?
                for item in components.queryItems! {
                    if item.name == R.string.localizable.code() {
                        code = item.value
                    }
                }
                loginWithKeycloak(code: code ?? "", redirectUrl: redirectUrl)
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.dismissHUD()
    }
    
}

// MARK: - Api methods
extension KeycloakAuthViewController {
    
    func loginWithKeycloak(code: String, redirectUrl: String) {
        ProManagerApi.loginWithKeycloak(code: code, redirectUrl: redirectUrl).request(Result<LoginResult>.self).subscribe(onNext: { (response) in
            if response.status == ResponseType.success {
                self.goHomeScreen(response)
            } else {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: rx.disposeBag)
    }
    
    func goHomeScreen(_ response: Result<LoginResult>) {
        Defaults.shared.sessionToken = response.sessionToken
        Defaults.shared.currentUser = response.result?.user
        Defaults.shared.isRegistered = response.result?.isRegistered
        Defaults.shared.numberOfFreeTrialDays = response.result?.diffDays
        Defaults.shared.isPic2ArtShowed = response.result?.isRegistered
        Defaults.shared.userCreatedDate = response.result?.user?.created
        CurrentUser.shared.setActiveUser(response.result?.user)
        Crashlytics.crashlytics().setUserID(CurrentUser.shared.activeUser?.username ?? "")
        CurrentUser.shared.createNewReferrerChannelURL { (_, _) -> Void in }
        let parentId = Defaults.shared.currentUser?.parentId ?? Defaults.shared.currentUser?.id
        Defaults.shared.parentID = parentId
        #if !IS_SHAREPOST && !IS_MEDIASHARE && !IS_VIRALVIDS  && !IS_SOCIALVIDS && !IS_PIC2ARTSHARE
        self.goToHomeScreen(isRefferencingChannelEmpty: response.result?.user?.refferingChannel == nil)
        #endif
    }
    
    func goToHomeScreen(isRefferencingChannelEmpty: Bool) {
        #if PIC2ARTAPP || TIMESPEEDAPP || BOOMICAMAPP
        Utils.appDelegate?.window?.rootViewController = R.storyboard.pageViewController.pageViewController()
        #else
        if isRefferencingChannelEmpty {
            let referringChannelSuggestionViewController = R.storyboard.loginViewController.referringChannelSuggestionViewController()
            Utils.appDelegate?.window?.rootViewController = referringChannelSuggestionViewController
        } else {
            let cameraNavVC = R.storyboard.storyCameraViewController.storyCameraViewNavigationController()
            cameraNavVC?.navigationBar.isHidden = true
            Utils.appDelegate?.window?.rootViewController = cameraNavVC
        }
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        #endif
    }
    
}
