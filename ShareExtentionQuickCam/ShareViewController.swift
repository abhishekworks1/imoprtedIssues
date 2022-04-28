//
//  ShareViewController.swift
//  ShareExtentionQuickCam
//
//  Created by Siddharth on 26/04/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getImage()
    }
    
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    func getImage() {
        if let inputItem = extensionContext!.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first as? NSItemProvider {
                // This line was missing
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeJPEG as String) {
                    itemProvider.loadItem(forTypeIdentifier: kUTTypeJPEG as String) { [unowned self] (imageData, error) in
                        if let item = imageData as? Data {
                            //                            self.imageView.image = UIImage(data: item)
                        }
                    }
                }
            }
        }
    }
    
    
}
