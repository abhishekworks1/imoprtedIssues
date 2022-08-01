//
//  LegalViewController.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 12/11/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit
import WebKit

class LegalViewController: UIViewController {
    
    // MARK: -
    // MARK: - Outlets
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var webView: WKWebView!
    
    // MARK: -
    // MARK: - Variables
    
    internal var isTermsAndConditions = true
    
    // MARK: -
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showHUD()
        self.lblTitle.text = isTermsAndConditions ? R.string.localizable.termsAndConditions() : R.string.localizable.privacyPolicy()
        
        // FOR NOW URL IS STATIC. IT WILL BE DYNAMIC APP WISE
        
        guard let legalUrl = URL(string: isTermsAndConditions ? termsAndConditionsUrl : privacyPolicyUrl) else { return }
        let urlRequest = URLRequest(url: legalUrl)
        webView.load(urlRequest)
        webView.uiDelegate = self
        webView.navigationDelegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.dismissHUD()
    }

    // MARK: -
    // MARK: - Button Action Methods
    
    @IBAction func btnBackTapped(_ sender: Any) {
        webView.canGoBack ? webView.goBack() : self.navigationController?.popViewController(animated: true)
    }
    
}

extension LegalViewController: WKUIDelegate, WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.dismissHUD()
    }
    
}
