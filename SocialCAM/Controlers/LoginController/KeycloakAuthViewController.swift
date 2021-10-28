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
    @IBOutlet weak var loginTooltip: UIView!
    @IBOutlet weak var lblLoginTooltip: UILabel!
    @IBOutlet weak var doNotShowAgainView: UIView!
    @IBOutlet weak var btnDoNotShowAgain: UIButton!
    @IBOutlet weak var tooltipView: UIView!
    var isProfileTooltipHide = false
    
    // MARK: - Variables
    internal var isRegister = true
    var urlString = ""
    var isSessionCodeExist = true
    
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
    
    /// Hide and show tooltip
    private func hideShowTooltipView(shouldShow: Bool) {
        self.loginTooltip.isHidden = !shouldShow
        self.tooltipView.isHidden = !shouldShow
    }
    
    @IBAction func btnDoNotShowAgainClicked(_ sender: UIButton) {
        btnDoNotShowAgain.isSelected = !btnDoNotShowAgain.isSelected
        isProfileTooltipHide = !isProfileTooltipHide
        Defaults.shared.isProfileTooltipHide = isProfileTooltipHide
        Defaults.shared.isShowAllPopUpChecked = false
    }
    
    @IBAction func btnOkayClicked(_ sender: UIButton) {
        self.hideShowTooltipView(shouldShow: false)
        self.doNotShowAgainAPI()
        if let editProfilePicViewController = R.storyboard.editProfileViewController.editProfilePicViewController() {
            editProfilePicViewController.isSignUpFlow = true
            navigationController?.pushViewController(editProfilePicViewController, animated: true)
        }
    }
    
    @IBAction func btnCancelClicked(_ sender: UIButton) {
        self.hideShowTooltipView(shouldShow: false)
        self.doNotShowAgainAPI()
        if let isRegistered = Defaults.shared.isRegistered, isRegistered {
            let tooltipViewController = R.storyboard.loginViewController.tooltipViewController()
            Utils.appDelegate?.window?.rootViewController = tooltipViewController
            tooltipViewController?.blurView.isHidden = false
            tooltipViewController?.blurView.alpha = 0.7
            tooltipViewController?.signupTooltipView.isHidden = false
        } else {
            let rootViewController: UIViewController? = R.storyboard.pageViewController.pageViewController()
            Utils.appDelegate?.window?.rootViewController = rootViewController
        }
    }
    
    func doNotShowAgainAPI() {
        ProManagerApi.doNotShowAgain(isDoNotShowMessage: btnDoNotShowAgain.isSelected).request(Result<LoginResult>.self).subscribe(onNext: { (response) in
        }, onError: { error in
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: rx.disposeBag)
    }
    
}

// MARK: - WKNavigationDelegate
extension KeycloakAuthViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if navigationAction.request.url != nil {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }
            if let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false),
               let fragments = components.fragment {
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
            } else {
                if navigationAction.navigationType == WKNavigationType.linkActivated {
                    webView.load(navigationAction.request)
                    decisionHandler(.cancel)
                    return
                }
            }
            let urlString = "\(url)"
            if urlString.contains("\(redirectUri)?refferingChannel=") {
                if !isSessionCodeExist {
                    let separatedString = urlString.split(separator: "&")
                    let referringChannel = String(separatedString.first?.split(separator: "=").last ?? "")
                    let channelId = String(separatedString.last?.split(separator: "=").last ?? "")
                    self.createUser(referringChannel: referringChannel, channelId: channelId)
                } else {
                    self.redirectToHomeScreen()
                }
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
        ProManagerApi.loginWithKeycloak(code: code, redirectUrl: redirectUrl).request(Result<LoginResult>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            if response.status == ResponseType.success {
                self.goHomeScreen(response)
                self.setDeviceToken()
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
        Defaults.shared.isFirstTimePic2ArtRegistered = response.result?.isRegistered
        Defaults.shared.isFirstVideoRegistered = response.result?.isRegistered
        Defaults.shared.isQuickLinkShowed = response.result?.isRegistered
        Defaults.shared.isFromSignup = response.result?.isRegistered
        Defaults.shared.userCreatedDate = response.result?.user?.created
        Defaults.shared.channelId = response.result?.user?.channelId
        CurrentUser.shared.setActiveUser(response.result?.user)
        Crashlytics.crashlytics().setUserID(CurrentUser.shared.activeUser?.username ?? "")
        CurrentUser.shared.createNewReferrerChannelURL { (_, _) -> Void in }
        let parentId = Defaults.shared.currentUser?.parentId ?? Defaults.shared.currentUser?.id
        Defaults.shared.parentID = parentId
        #if !IS_SHAREPOST && !IS_MEDIASHARE && !IS_VIRALVIDS  && !IS_SOCIALVIDS && !IS_PIC2ARTSHARE
        self.goToHomeScreen(isRefferencingChannelEmpty: response.result?.user?.refferingChannel == nil, channelId: response.result?.user?.channelId ?? "")
        #endif
    }
    
    func goToHomeScreen(isRefferencingChannelEmpty: Bool, channelId: String) {
        #if PIC2ARTAPP || TIMESPEEDAPP || BOOMICAMAPP
        Utils.appDelegate?.window?.rootViewController = R.storyboard.pageViewController.pageViewController()
        #else
        if isRefferencingChannelEmpty {
            guard let sessioToken = Defaults.shared.sessionToken, let keycloakURL = URL(string: "\(websiteUrl)\(Paths.onboarding)\(sessioToken)\(Paths.redirect_uri)\(redirectUri)") else {
                return
            }
            let urlRequest = URLRequest(url: keycloakURL)
            webView.load(urlRequest)
        } else {
            if let isShow = Defaults.shared.currentUser?.isDoNotShowMsg, !isShow && Defaults.shared.currentUser?.profileImageURL == "" {
                self.hideShowTooltipView(shouldShow: true)
            } else {
                let rootViewController: UIViewController? = R.storyboard.pageViewController.pageViewController()
                Utils.appDelegate?.window?.rootViewController = rootViewController
            }
        }
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        #endif
    }
    
    func redirectToHomeScreen() {
        if let isRegistered = Defaults.shared.isRegistered {
            if isRegistered {
                self.doNotShowAgainView.isHidden = false
                if let isShow = Defaults.shared.currentUser?.isDoNotShowMsg, !isShow && Defaults.shared.currentUser?.profileImageURL == "" {
                    self.hideShowTooltipView(shouldShow: true)
                } else {
                    let tooltipViewController = R.storyboard.loginViewController.tooltipViewController()
                    Utils.appDelegate?.window?.rootViewController = tooltipViewController
                    tooltipViewController?.blurView.isHidden = false
                    tooltipViewController?.blurView.alpha = 0.7
                    tooltipViewController?.signupTooltipView.isHidden = false
                }
            } else {
                let rootViewController: UIViewController? = R.storyboard.pageViewController.pageViewController()
                Utils.appDelegate?.window?.rootViewController = rootViewController
            }
        } else {
            let rootViewController: UIViewController? = R.storyboard.pageViewController.pageViewController()
            Utils.appDelegate?.window?.rootViewController = rootViewController
        }
    }
    
    func createUser(referringChannel: String, channelId: String) {
        ProManagerApi.createUser(channelId: channelId, refferingChannel: referringChannel).request(Result<LoginResult>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            if response.status == ResponseType.success {
                Defaults.shared.sessionToken = response.sessionToken
                self.isSessionCodeExist = true
                Defaults.shared.currentUser = response.result?.user
                Defaults.shared.isRegistered = true
                Defaults.shared.numberOfFreeTrialDays = response.result?.diffDays
                Defaults.shared.isPic2ArtShowed = Defaults.shared.isRegistered
                Defaults.shared.isQuickLinkShowed = Defaults.shared.isRegistered
                Defaults.shared.isFromSignup = Defaults.shared.isRegistered
                Defaults.shared.userCreatedDate = response.result?.user?.created
                CurrentUser.shared.setActiveUser(response.result?.user)
                self.setDeviceToken()
                self.redirectToHomeScreen()
            } else {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: rx.disposeBag)
    }
    
    func setDeviceToken() {
        if let deviceToken = Defaults.shared.deviceToken {
            ProManagerApi.setToken(deviceToken: deviceToken, deviceType: "ios").request(Result<SetTokenModel>.self).subscribe(onNext: { [weak self] (response) in
                guard let `self` = self else {
                    return
                }
                if response.status != ResponseType.success {
                    self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
                }
            }, onError: { error in
                self.showAlert(alertMessage: error.localizedDescription)
            }, onCompleted: {
            }).disposed(by: rx.disposeBag)
        }
    }
    
}
