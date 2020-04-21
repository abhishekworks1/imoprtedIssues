//
//  SharePostVC.swift
//  SocialCamMediaShare
//
//  Created by Viraj Patel on 21/04/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import Social
import MobileCoreServices
import SDWebImage
import AVKit
import UIKit
import Foundation
import AVFoundation
import RxSwift
import Moya
import URLEmbeddedView

class SharePostVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var imgPost: UIImageView!
 
    @IBOutlet weak var imgSocialIcon: UIImageView!
    
    @IBOutlet weak var txtHashtags: UITextField!
   
    @IBOutlet weak var txtDesc: UITextView!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var btnSendPost: UIButton!
    
    @IBOutlet weak var btnClose: UIButton!
    
    // MARK: - Variables
    private var urlString: String?
    private var textString: String?
    var host: String?
    fileprivate var disposeBag = DisposeBag()

    // MARK: - View Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
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
                        
                    }
                }
            }
        } else {
            displayUIAlertController(title: R.string.localizable.loginError(), message: R.string.localizable.pleaseLoginFirstOnApp(), viewController: self)
        }
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
                
//                ProManagerApi.writePost(type: "bookmark", user: Defaults.shared.currentUser?.id ?? "", bookmark: json, privacy: "Only me").request(Result<SharedPost>.self).subscribe(onNext: { (response) in
//                    print(response)
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
//                        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
//                    })
//                }, onError: { _ in
//                    self.displayUIAlertController(title: "", message: "Error", viewController: self)
//                }, onCompleted: {
//
//                }).disposed(by: self.rx.disposeBag)
                
            }
        }
    }
    
    // MARK:- IBAction events
    @IBAction func closeBtnTapped(_ sender: Any) {
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    @IBAction func sendStoryTapped(_ sender: Any) {
        self.setData()
    }
    
    @objc func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }
    
    func displayUIAlertController(title: String, message: String, viewController: UIViewController) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
            let errMsg = NSError(domain: "domain", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Localised details here"])
            viewController.extensionContext!.cancelRequest(withError: errMsg)
        }))
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
