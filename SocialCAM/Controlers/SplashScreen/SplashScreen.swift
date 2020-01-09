//
//  SplashScreen.swift
//  SocialCAM
//
//  Created by Viraj Patel on 08/01/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit
import SwiftySound

class SplashScreen: UIViewController {
    
    @IBOutlet open var backgroundImageView: UIImageView!
    var arrImage: [UIImage?] = []
   
    deinit {
        print("SplashScreen Deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let startUpSound = R.file.startUpMp3() {
            Sound.play(url: startUpSound)
        }
        changeBackgroundImage()
        getSplashImages()
    }
    
    func changeBackgroundImage() {
        do {
            if try Folder.home.subfolder(named: Constant.Application.splashImagesFolderName).files.count > 0 {
                var images: [UIImage] = []
                try Folder.home.subfolder(named: Constant.Application.splashImagesFolderName).files.enumerated().forEach { (index, file) in
                    let image = UIImage(data: try file.read())
                    images.append(image ?? UIImage())
                }
                arrImage.append(contentsOf: images)
            }
            
        } catch {
            
        }
        if arrImage.isEmpty {
            arrImage.append(R.image.launchScreen())
        }
        backgroundImageView.image = arrImage.randomElement() as? UIImage
        DispatchQueue.runAfterDelay(delayMSec: 5) {
            if let storyCameraViewController = R.storyboard.storyCameraViewController.storyCameraNavigation() {
                Utils.appDelegate?.window?.rootViewController = storyCameraViewController
            }
        }
    }
    
    func getSplashImages() {
        ProManagerApi.getSplashImages.request(ResultArray<SplashImages>.self).subscribe(onNext: { [weak self] (responce) in
            guard let `self` = self else { return }
            guard let splashImages = responce.result else {
                return
            }
            self.saveImages(splashImages)
            print(responce)
            
        }, onError: { error in
            print(error)
        }, onCompleted: {
        }).disposed(by: rx.disposeBag)
    }
    
    func saveImages(_ splashImages: [SplashImages]) {
        for splashImage in splashImages {
            guard let splashImageType = splashImage.type, splashImageType == .background, let imageURLs = splashImage.imageArray else {
                return
            }
            var imageLocalURLs: [String?] = []
            for imageURL in imageURLs {
                guard let serverImageURL = URL(string: imageURL) else {
                    return
                }
                Utils.downloadImage(from: serverImageURL) { (localURL) in
                    imageLocalURLs.append(localURL)
                }
            }
            print("imageLocalURLs \(imageLocalURLs)")
        }
    }
}
