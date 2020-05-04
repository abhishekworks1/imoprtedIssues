//
//  VideosWebViewVC.swift
//  SocialCAM
//
//  Created by Viraj Patel on 04/05/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import WebKit
import RxSwift

//public protocol InstagramLoginViewControllerDelegate: class {
//    func instagramLoginDidFinish(accessToken: String?, error: Error?)
//}

class VideosWebViewVC: UIViewController {
    
    var webView: WKWebView!
    var activityIndicator: UIActivityIndicatorView?
    
    weak var delegate: InstagramLoginViewControllerDelegate?
    
    let disposeBag = DisposeBag()
    var websiteUrl: String = Constant.Instagram.authorizeUrl
    
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
    
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = false
        webView.load(URLRequest(url: URLComponents(string: websiteUrl)!.url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData))
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
            
        }
    }
    
    @objc func btnCloseClicked() {
        self.dismiss(animated: true)
    }
       
}

extension VideosWebViewVC: WKNavigationDelegate, WKUIDelegate {
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
        if url.contains("code=") {
            self.extractAccessCode()
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator?.isHidden = true
        activityIndicator?.stopAnimating()
    }
}
