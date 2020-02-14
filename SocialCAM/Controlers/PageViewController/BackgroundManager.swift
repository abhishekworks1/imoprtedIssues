//
//  BackgroundManager.swift
//  SocialCAM
//
//  Created by Viraj Patel on 12/02/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit

open class BackgroundManager: NSObject {
    
    static let shared: BackgroundManager = BackgroundManager()
   
    public override init() {
        super.init()
        getSplashImages()
    }
    
    func changeBackgroundImage() -> [UIImage] {
        var arrImage: [UIImage] = []
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
        return arrImage
    }
    
    func getSplashImages() {
        ProManagerApi.getSplashImages.request(ResultArray<SplashImages>.self).subscribe(onNext: { [weak self] (responce) in
            guard let `self` = self else { return }
            guard let splashImages = responce.result else {
                return
            }
            self.saveImages(splashImages)
        }, onError: { error in
            print(error)
        }, onCompleted: {
        }).disposed(by: rx.disposeBag)
    }
    
    func saveImages(_ splashImages: [SplashImages]) {
        for splashImage in splashImages {
            if let splashImageType = splashImage.type, splashImageType == .post, let imageURLs = splashImage.imageArray {
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
        Utils.removeDownloaded()
    }
}
