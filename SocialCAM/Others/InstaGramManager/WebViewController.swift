//
//  WebViewController.swift
//  SimpleInstagram
//
//  Created on 23/01/2020.
//  Copyright © 2020 clementozemoya. All rights reserved.
//

import UIKit
import WebKit
import RxSwift

public protocol InstagramLoginViewControllerDelegate: class {
    func instagramLoginDidFinish(accessToken: String?, error: Error?)
}

class WebViewController: UIViewController {
    
    var webView: WKWebView!
    var activityIndicator: UIActivityIndicatorView?
    
    weak var delegate: InstagramLoginViewControllerDelegate?
    var isAccessToken = false
    let redirectUrl = Constant.Instagram.redirectUrl
    let clientId = Constant.Instagram.clientId
    let clientSecret = Constant.Instagram.clientSecret
    let disposeBag = DisposeBag()
    
    let btnClose: UIButton = {
        let closeButton = UIButton()
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(R.image.icoClose(), for: .normal)
        return closeButton
    }()
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        #if RELEASE
        webConfiguration.websiteDataStore = .nonPersistent()
        #endif
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
        webView.addSubview(btnClose)
        btnClose.topAnchor.constraint(equalTo: webView.topAnchor).isActive = true
        btnClose.leadingAnchor.constraint(equalTo: webView.leadingAnchor, constant: 5).isActive = true
        btnClose.widthAnchor.constraint(equalToConstant: 40).isActive = true
        btnClose.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnClose.addTarget(self, action: #selector(self.btnCloseClicked), for: .touchUpInside)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var components = URLComponents(string: Constant.Instagram.authorizeUrl)!
        
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectUrl),
            URLQueryItem(name: "scope", value: Constant.Instagram.scope),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "display", value: "touch")]
        
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = false
        webView.load(URLRequest(url: components.url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData))
    }

    func extractAccessCode() {
        guard let url = webView.url?.absoluteString.removingPercentEncoding else { return }
        if url.contains("code=") {
            guard let startIndex = url.range(of: "code=")?.upperBound else {
                return
            }
            guard let endIndex = url.firstIndex(of: "#") else {
                return
            }
            let accessCode = url[startIndex..<endIndex]
            print("Access code = \(accessCode)")
            getLongLivedAccessToken(with: String(accessCode))
        }
    }
    
    /*
     * Fetches a short lived access token using the access code, then exchanges it with a long lived token
     */
    func getLongLivedAccessToken(with accessCode: String) {
        InstagramManager.shared.getAccessToken(code: accessCode, clientId: clientId, clientSecret: clientSecret, redirectUrl: redirectUrl) { (response) in
            InstagramManager.shared.getLongLivedToken(accessToken: response!, clientSecret: self.clientSecret) { (accessTokenResponse) in
                print("Access token got: \(String(describing: accessTokenResponse))")
                if let accessToken = accessTokenResponse {
                    Defaults.shared.instagramToken = accessToken
                    self.delegate?.instagramLoginDidFinish(accessToken: accessToken, error: nil)
                    self.dismiss(animated: true)
                } else {
                    self.delegate?.instagramLoginDidFinish(accessToken: nil, error: nil)
                    self.dismiss(animated: true)
                }
            }
        }
        
    }
    
    @objc func btnCloseClicked() {
        self.dismiss(animated: true)
    }
       
}

extension WebViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator?.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        activityIndicator = UIActivityIndicatorView.init(frame: CGRect(origin: CGPoint(x: view.frame.size.width / 2 - 20, y: 40), size: CGSize(width: 40, height: 40)))
        activityIndicator?.startAnimating()
        view.addSubview(activityIndicator!)
        
        guard let url = webView.url?.absoluteString.removingPercentEncoding else {
            return
        }
        if url.contains("code="), !isAccessToken {
            isAccessToken = true
            self.extractAccessCode()
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator?.isHidden = true
        activityIndicator?.stopAnimating()
    }
}
