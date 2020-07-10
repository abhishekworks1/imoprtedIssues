//
//  SendStoryShareVC.swift
//  SocialCamMediaShare
//
//  Created by Viraj Patel on 03/03/20.
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

class SendStoryShareVC: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var storyImgView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressContainerView: UIView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnSendStory: UIButton!
    @IBOutlet weak var btnSendWrtten: UIButton!
    
    // MARK: - Variables
    let imageContentType = kUTTypeImage as String
    let videoContentType = kUTTypeMPEG4 as String
    let quickTimeContentType = kUTTypeQuickTimeMovie as String
    let urlContentType = kUTTypeURL as String
    var filterImage: FilterImage?
    var session: String?
    var user: User?
    var uniqueFileName: String {
        return String.fileName
    }
    var thumbUrl = String()
    var player: AVPlayer?
    var videoDuration: Double = 0
    fileprivate var disposeBag = DisposeBag()

    // MARK: - View Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    
    // MARK:- IBAction events
    @IBAction func closeBtnTapped(_ sender: Any) {
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    @IBAction func sendStoryTapped(_ sender: Any) {
        guard let filterImage = filterImage else { print("Filter image is empty"); return }
        switch filterImage.type {
        case .image:
            print("Image type")
            if let image = filterImage.image,
                let data = image.jpegData(compressionQuality: 1.0),
                let pasteboard = UIPasteboard(name: UIPasteboard.Name(rawValue: "com.simform.Pic2Art.CopyFrom"), create: true) {
                pasteboard.setData(data, forPasteboardType: "com.simform.Pic2Art.shareImageData")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                _ = self.openURL(URL(string: "pic2art://com.simform.Pic2Art")!)
                self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            })
        case .video:
            print("Video type")
            displayAlertController(title: "", message: "Coming soon..", viewController: self)
            break
        default:
            break
        }
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
    
    @IBAction func cancelUploadTapped(_ sender: Any) {
        AWSManager.shared.cancelAllUploads()
        progressContainerView.isHidden = true
        btnSendStory.isUserInteractionEnabled = true
    }
    
    @IBAction func playBtnTapped(_ sender: Any) {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
}

// MARK: - Functions and Methods
extension SendStoryShareVC {
    
    func sendStoryImage() {
       uploadToAmazon()
    }
    
    func sendStoryVideo() {
        uploadToAmazon()
    }
    
    func createStory(url: String) {
//        guard let filterImage = filterImage, let user = user, let id = user.id else { print("Empty filter image"); return }
//        let type = filterImage.type
//
//        switch type {
//        case .image:
//            ProManagerApi.createStory(url: url, duration: "5.0", type: "image", user: id, thumb: "").request().subscribe(onNext: { (response) in
//                if response.statusCode == 1 {
//                    print("\n\n\n-->Sucess Created Story\n\n\n")
//                }
//                self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
//            }, onError: { (error) in
//                print("\n\n\nError: \(error.localizedDescription)\n\n\n")
//            }).disposed(by: disposeBag)
//        case .video:
//            ProManagerApi.createStory(url: url, duration: String(videoDuration), type: "video", user: id, thumb: thumbUrl)
//                .request()
//                .subscribe(onNext: { (response) in
//                    if response.statusCode == 1 {
//                        print("\n\n\n-->Sucess Created Story\n\n\n")
//                    }
//                    self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
//            }, onError: { (error) in
//                print("\n\n\nError: \(error.localizedDescription)\n\n\n")
//            }).disposed(by: disposeBag)
//        case .images:
//            break
//        }
    }
    
    func uploadToAmazon() {
        guard let filterImage = filterImage, let image = filterImage.image else { return }
        var formate = String.fileName
        let thumbImageFormate = formate + FileExtension.jpg.rawValue
        formate += ((self.filterImage?.url == nil) ? FileExtension.jpg.rawValue : ".mp4")
        
        let resizeImg = image.resizeImage(newWidth: 180)
        let thumbName = ("thumb" + thumbImageFormate)
        
        if filterImage.url == nil {
            self.progressContainerView.isHidden = false
            Utils.uploadImage(imgName: formate, img: image, progressBlock: { [weak self] progress in
                self?.progressView.progress = progress/100
                }, callBack: { [weak self] url -> Void in
                    print("\n\n--->Url: \(url)\n\n")
                    self?.createStory(url: url)
            })
        } else {
            guard let videoUrl = filterImage.url else { return }
            self.progressContainerView.isHidden = false
            
            Utils.uploadImage(imgName: thumbName, img: resizeImg, progressBlock: { progress in
               print("\n\n--->Thumbnail uploaded\n\n\n")
            }, callBack: { url -> Void in
                self.thumbUrl = url
            })
            let videoData: Data?
            do {
                videoData = try Data(contentsOf: videoUrl, options: NSData.ReadingOptions.alwaysMapped)
                Utils.uploadVideo(videoName: formate, videoData: videoData!, progressBlock: { progress in
                    self.progressView.progress = progress/100
                }, callBack: { [weak self] url -> Void in
                    print("\n\n--->Url: \(url)\n\n")
                    self?.createStory(url: url)
                })
            } catch _ {
                videoData = nil
                return
            }
        }
    }
    
    func fetchData() {
        guard let sessionToken = Defaults.shared.sessionToken,
            let currentUser = Defaults.shared.currentUser else {
                displayAlertController(title: "Login Error", message: "Please login First on App", viewController: self)
                return
        }
        self.session = sessionToken
        self.user = currentUser
        
        if let item = self.extensionContext?.inputItems[0] as? NSExtensionItem,
            let attachments = item.attachments {
            for ele in attachments {
                
                if let itemProvider = ele as? NSItemProvider {
                    if itemProvider.hasItemConformingToTypeIdentifier(urlContentType) {
                        itemProvider.loadItem(forTypeIdentifier: urlContentType, options: nil, completionHandler: { (text, error) in
                            if let shareURL = text as? NSURL {
                                SDWebImageManager.shared.loadImage(with: shareURL as URL, options: SDWebImageOptions.highPriority, progress: { (progress, tProgress, url) in
                                    
                                }, completed: { (img, data, error, type, result, url) in
                                    if let image = img {
                                        DispatchQueue.main.async {
                                            let filterImage = FilterImage(image: image, index: 0)
                                            self.filterImage = filterImage
                                            self.storyImgView.image = filterImage.image
                                        }
                                    }
                                })
                            }
                            
                        })
                    } else if itemProvider.hasItemConformingToTypeIdentifier(videoContentType) || itemProvider.hasItemConformingToTypeIdentifier(quickTimeContentType) {
                        itemProvider.loadItem(forTypeIdentifier: (itemProvider.hasItemConformingToTypeIdentifier(quickTimeContentType)) ? quickTimeContentType : videoContentType, options: nil, completionHandler: { (video, error) in
                            
                            var videourl: URL?
                            if let item = video as? Data {
                                var formate = String.fileName
                                formate += FileExtension.mov.rawValue
                                
                                let filename = self.getDocumentsDirectory().appendingPathComponent(formate)
                                try? item.write(to: filename)
                                videourl = filename.absoluteURL
                            }
                            
                            if let videoUrl = video as? URL {
                                videourl = videoUrl
                            }
                            
                            if let url = videourl {
                                let asset = AVURLAsset(url: url)
                                
                                let durationInSeconds = asset.duration.seconds / 5
                                self.videoDuration = asset.duration.seconds
                                if durationInSeconds > 1 {
                                    self.displayAlertController(title: "Error", message: "Choose a video that's shorter than 5 seconds.", viewController: self)
                                    return
                                }
                                
                                DispatchQueue.main.async {
                                    self.player = AVPlayer(url: url)
                                    let imageLarge : UIImage = UIImage.getThumbnailFrom(videoUrl: url) ?? UIImage()
                                    let image = imageLarge.resizeImage(newWidth: CGFloat(400.0))
//                                    if let exportURL = url {
                                        self.filterImage = FilterImage(url: url, index: 0)
                                    self.filterImage?.image = image
                                    self.filterImage?.thumbImage = image
                                        self.storyImgView.image = self.filterImage?.thumbImage
                                        self.btnPlay.isHidden = false
//                                    }
                                }
                            }
                        })
                    } else if itemProvider.hasItemConformingToTypeIdentifier(imageContentType) {
                        itemProvider.loadItem(forTypeIdentifier: imageContentType, options: nil, completionHandler: { (item, error) in
                            var imgData: Data?
                            if let url = item as? URL {
                                imgData = try? Data(contentsOf: url)
                            }
                            if let img = item as? UIImage {
                                imgData = img.jpegData(compressionQuality: 0.6)
                            }
                            
                            DispatchQueue.main.async {
                                if let imgData = imgData, let imageLarge = UIImage.init(data: imgData) {
                                    let image = imageLarge.resizeImage(newWidth: CGFloat(400.0))
                                    self.filterImage = FilterImage(image: image, index: 0)
                                    self.storyImgView.image = self.filterImage?.image
                                    self.btnPlay.isHidden = true
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    func displayAlertController(title: String, message: String, viewController : UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) -> () in
            let errMsg = NSError(domain: "domain", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Localised details here"])
            viewController.extensionContext!.cancelRequest(withError: errMsg)
        }))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
}
