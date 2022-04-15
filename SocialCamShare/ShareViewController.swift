//
//  ShareViewController.swift
//  SocialCamShare
//
//  Created by Viraj Patel on 10/02/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit
import Social
//import URLEmbeddedView
import RxSwift
import ObjectMapper
import NSObject_Rx

class ShareViewController: SLComposeServiceViewController {
    
    private var urlString: String?
    private var textString: String?
    var host: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func fetchData() {
        if Defaults.shared.currentUser != nil {
            if let item = extensionContext?.inputItems.first as? NSExtensionItem,
                let itemProvider = item.attachments?.first,
                itemProvider.hasItemConformingToTypeIdentifier("public.url") {
                itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { (url, _) in
                    if let shareURL = url as? URL {
                        self.host = shareURL.host
                        self.urlString = String(describing: shareURL)
                        print(shareURL)
                        self.setData()
                    }
                }
            }
        } else {
            displayUIAlertController(title: R.string.localizable.loginError(), message: R.string.localizable.pleaseLoginFirstOnApp(), viewController: self)
        }
    }
    
    func displayUIAlertController(title: String, message: String, viewController: UIViewController) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
            let errMsg = NSError(domain: "domain", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Localised details here"])
            viewController.extensionContext!.cancelRequest(withError: errMsg)
        }))
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func setData() {
        OGDataProvider.shared.fetchOGData(urlString: self.urlString!) { (data: OpenGraph.Data, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                var json: [String: Any] = ["bookmarkUrl": self.urlString ?? ""]
                if let title = data.pageTitle {
                    json["title"] = title
                } else {
                    if let host = self.host {
                        json["title"] = host
                    }
                }
                if let imgUrl = data.imageUrl?.absoluteString {
                    json["thumb"] = imgUrl
                }
                
                if let desc = data.pageDescription {
                    json["description"] = desc
                }
                
                if let siteName = data.siteName {
                    json["shortLink"] = siteName
                } else {
                    if let host = self.host {
                        json["shortLink"] = host
                    }
                }
                
                ProManagerApi.writePost(type: "bookmark", user: Defaults.shared.currentUser?.id ?? "", bookmark: json, privacy: "Only me").request(Result<SharedPost>.self).subscribe(onNext: { (response) in
                    print(response)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                    })
                }, onError: { _ in
                    self.displayUIAlertController(title: "", message: "Error", viewController: self)
                }, onCompleted: {
                    
                }).disposed(by: self.rx.disposeBag)
                
            }
        }
    }
    
    override func isContentValid() -> Bool {
        if urlString != nil || textString != nil {
            if !contentText.isEmpty {
                return true
            }
        }
        return true
    }
    
    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.fetchData()
    }
    
    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
}
