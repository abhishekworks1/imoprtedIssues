//
//  ShareViewController.swift
//  ShareExtentionQuickCam
//
//  Created by Siddharth on 29/04/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit
import MobileCoreServices

@objc(ShareExtensionViewController)
class ShareViewController: UIViewController {
    
    var docPath = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handleResponseOfShareData()
//                self.handleSharedFile()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {

        let alertView = UIAlertController(title: "Export", message: " ", preferredStyle: .alert)

        self.present(alertView, animated: true, completion: {

            let group = DispatchGroup()

            NSLog("inputItems: \(self.extensionContext!.inputItems.count)")

            for item: Any in self.extensionContext!.inputItems {

                let inputItem = item as! NSExtensionItem

                for provider: Any in inputItem.attachments! {

                    let itemProvider = provider as! NSItemProvider
                    group.enter()
                    itemProvider.loadItem(forTypeIdentifier: kUTTypeData as String, options: nil) { data, error in
                        if error == nil {
                            //  Note: "data" may be another type (e.g. Data or UIImage). Casting to URL may fail. Better use switch-statement for other types.
                            //  "screenshot-tool" from iOS11 will give you an UIImage here
                            let url = data as! URL
                            let path = "\(self.docPath)/\(url.pathComponents.last ?? "")"
                            print(">>> sharepath: \(String(describing: url.path))")
//                            UserDefaults.standard.setValue(url.path, forKey: "SharedImage")
                            try? FileManager.default.copyItem(at: url, to: URL(fileURLWithPath: path))
                           

                        } else {
                            NSLog("\(error)")
                        }
                        group.leave()
                    }
                }
            }

            group.notify(queue: DispatchQueue.main) {
                NSLog("done")

                let files = try! FileManager.default.contentsOfDirectory(atPath: self.docPath)

                NSLog("directory: \(files)")

                //  Serialize filenames, call openURL:
                do {
                    let jsonData : Data = try JSONSerialization.data(
                        withJSONObject: [
                            "action" : "incoming-files"
                        ],
                        options: JSONSerialization.WritingOptions.init(rawValue: 0))
                    let jsonString = (NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    let result = self.openURL(URL(string: "quickcamrefer://app.share?\(jsonString!)")!)
                } catch {
                    alertView.message = "Error: \(error.localizedDescription)"
                }
                self.dismiss(animated: false) {
                    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                }
            }
        })
    }
    
    
    
    //  Function must be named exactly like this so a selector can be found by the compiler!
    //  Anyway - it's another selector in another instance that would be "performed" instead.
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
    
    func handleResponseOfShareData() {
        
        let containerURL = FileManager().containerURL(forSecurityApplicationGroupIdentifier: "app.quickcam.app.ShareExtentionQuickCam")
        docPath = "\(containerURL?.path ?? "")/share/"
        print("****************")
        print(docPath)
        print("****************")
        let dicUrl = create(directory: docPath)
        
        docPath = dicUrl.path
        
        print("****************")
        print(docPath)
        print("****************")
        
        //  removing previous stored files
        if docPath != "" {
            let files = try! FileManager.default.contentsOfDirectory(atPath: docPath)
            for file in files {
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: "\(docPath)/\(file)"))
            }
        }
        
    }

    
    func create(directory: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryURL = documentsDirectory.appendingPathComponent(directory)

        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            fatalError("Error creating directory: \(error.localizedDescription)")
        }
        return directoryURL
    }
    
    func removeItem(_ relativeFilePath: String) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let absoluteFilePath = documentsDirectory.appendingPathComponent(relativeFilePath)
        try? FileManager.default.removeItem(at: absoluteFilePath)
    }
    
}
//    private func save(_ data: Data, key: String, value: Any) {
//        // You must use the userdefaults of an app group, otherwise the main app don't have access to it.
//        let userDefaults = UserDefaults(suiteName: "group.app.quickcam.app.ShareExtentionQ")
//        userDefaults?.set(data, forKey: key)
//    }
    
    
//    private func handleSharedFile() {
//        // extracting the path to the URL that is being shared
//        let attachments = (extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
//        let contentType = kUTTypeData as String
//        for provider in attachments {
//            // Check if the content type is the same as we expected
//            if provider.hasItemConformingToTypeIdentifier(contentType) {
//                provider.loadItem(forTypeIdentifier: contentType,
//                                  options: nil) { [unowned self] (data, error) in
//                    // Handle the error here if you want
//                    guard error == nil else { return }
//
//                    if let url = data as? URL,
//                       let imageData = try? Data(contentsOf: url) {
//                        self.save(imageData, key: "imageData", value: imageData)
//                        openURL(url)
//                    } else {
//                        // Handle this situation as you prefer
//                        fatalError("Impossible to save image")
//                    }
//                }}
//        }
//    }
