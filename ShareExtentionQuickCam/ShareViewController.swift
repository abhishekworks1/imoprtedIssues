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
    var imagePath = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handleResponseOfShareData()

    }
    
    
    override func viewDidAppear(_ animated: Bool) {

        let alertView = UIAlertController(title: "Export", message: "", preferredStyle: .alert)

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
                            try? FileManager.default.copyItem(at: url, to: URL(fileURLWithPath: path))
                            print("&&&&&&&&&&&&&&&&&&")
                            let newurl = URL(fileURLWithPath: url.path)
                            do {
                                let imageData = try Data(contentsOf: newurl)
                                let image = UIImage(data: imageData)
                                print(image)
                                self.imagePath = self.convertImageToBase64String(img: image!)
                            } catch let dataErr {
                                print(dataErr.localizedDescription)
                            }
                            print("&&&&&&&&&&&&&&&&&&")
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
                    let result = self.openURL(URL(string: "quickcamrefer://app.share?\(self.imagePath)")!)
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
        
        let containerURL = FileManager().containerURL(forSecurityApplicationGroupIdentifier: UserDefaults.GroupName.name)
        docPath = "\(containerURL?.path ?? "")/share"
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
            removeItem(docPath)
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
    
    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
    
}


extension UserDefaults {
    struct GroupName {
        static let name = "group.app.quickcam.app.ShareExtentionQ"
    }
    static let group = UserDefaults(suiteName: GroupName.name)!
}
