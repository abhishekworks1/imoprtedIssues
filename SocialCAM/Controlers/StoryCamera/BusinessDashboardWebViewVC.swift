//
//  BusinessDashboardWebViewVC.swift
//  SocialCAM
//
//  Created by Navroz Huda on 23/06/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit
import WebKit

class BusinessDashboardWebViewVC: UIViewController {
    
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
        
        let urlString = "\(websiteUrl)/share-wizard?redirect_uri=\(redirectUri)"
         print(urlString)
         guard let url = URL(string: urlString) else {
                 return
         }
        let urlRequest = URLRequest(url: url)
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
//        webView.canGoBack ? webView.goBack() :
        self.navigationController?.popViewController(animated: true)
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
        let rootViewController: UIViewController? = R.storyboard.pageViewController.pageViewController()
        Utils.appDelegate?.window?.rootViewController = rootViewController
    }
    
    func doNotShowAgainAPI() {
        ProManagerApi.doNotShowAgain(isDoNotShowMessage: btnDoNotShowAgain.isSelected).request(Result<LoginResult>.self).subscribe(onNext: { (response) in
        }, onError: { error in
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: rx.disposeBag)
    }
    
}
extension BusinessDashboardWebViewVC: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if navigationAction.request.url != nil {
            guard let url = navigationAction.request.url else {
              
                decisionHandler(.cancel)
                return
            }
            if url.absoluteString == "quickcamrefer://app"{
                let storySettingsVC = R.storyboard.storyCameraViewController.storySettingsVC()!
                navigationController?.pushViewController(storySettingsVC, animated: true)
            }
            print(url)
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.dismissHUD()
    }
    
}
