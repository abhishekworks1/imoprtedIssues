//
//  InstagramMediaDownloader.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 24/07/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit
import Photos

typealias Json = [String : Any]

final class InstagramUser {
    
    let username: String
    
    let avatarUrl: URL
    
    var avatarImage: UIImage?
    
    init(username: String, avatarUrl: URL) {
        self.username = username
        self.avatarUrl = avatarUrl
    }
}

final class Post {
    
    let user: InstagramUser
    
    let imageUrl: URL
    
    let videoUrl: URL?
    
    var image: UIImage?
    
    var isVideo: Bool {
        return videoUrl != nil
    }

    init(user: InstagramUser, imageUrl: URL, videoUrl: URL?) {
        self.user = user
        self.imageUrl = imageUrl
        self.videoUrl = videoUrl
    }
}

final class SaveService {
    
    static var videoUrl: URL?
    
    static func saveImage(_ image: UIImage, completion: @escaping (Error?) -> ()) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                return DispatchQueue.main.async {
                    completion(.accessDenied)
                }
            }
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { saved, error in
                DispatchQueue.main.async {
                    if saved, error == nil {
                        completion(nil)
                    } else {
                        completion(.unknown)
                    }
                }
            }
        }
    }
    
    static func saveVideo(_ remoteUrl: URL, completion: @escaping (Error?) -> ()) {
        downloadVideo(with: remoteUrl) { videoUrl in
            guard let videoUrl = videoUrl else {
                return DispatchQueue.main.async {
                    completion(.unknown)
                }
            }
            SaveService.videoUrl = videoUrl
        }
    }
    
    private static func writeVideoToLibrary(_ videoUrl: URL, completion: @escaping (Error?) -> ()) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                return DispatchQueue.main.async {
                    completion(.accessDenied)
                }
            }
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoUrl)
            }) { saved, error in
                try? FileManager.default.removeItem(at: videoUrl)
                DispatchQueue.main.async {
                    if saved, error == nil {
                        completion(nil)
                    } else {
                        completion(.unknown)
                    }
                }
            }
        }
    }
    
    private static func downloadVideo(with url: URL, completion: @escaping (URL?) -> ()) {
        URLSession.shared.downloadTask(with: url) { url, response, error in
            guard let tempUrl = url, error == nil else {
                return completion(nil)
            }
            let fileManager = FileManager.default
            let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let videoFileUrl = documentsUrl.appendingPathComponent("video.mp4")
            if fileManager.fileExists(atPath: videoFileUrl.path) {
                try? fileManager.removeItem(at: videoFileUrl)
            }
            do {
                try fileManager.moveItem(at: tempUrl, to: videoFileUrl)
                completion(videoFileUrl)
            } catch {
                completion(nil)
            }
        }.resume()
    }
}

extension SaveService {
    
    enum Error: LocalizedError {
        
        case accessDenied
        
        case unknown
    }
}

final class InstaService {
    
    static func checkLink(_ link: String) -> String? {
        let regex = try! NSRegularExpression(pattern: "^https://(www.)?instagram.com/.*/", options: .caseInsensitive)
        let matches = regex.matches(in: link, options: [], range: NSMakeRange(0, link.count))
        guard !matches.isEmpty else {
            return nil
        }
        if let activeLink = link.components(separatedBy: "?").first {
            return activeLink
        } else {
            return nil
        }
    }
    
    static func getMediaPost(with link: String, completion: @escaping (Post?) -> ()) {
        getJson(link) { json in
            guard let json = json else {
                return DispatchQueue.main.async {
                    completion(nil)
                }
            }
            parseJson(json) { post in
                DispatchQueue.main.async {
                    completion(post)
                }
            }
        }
    }
    
    private static func getJson(_ link: String, completion: @escaping (Json?) -> ()) {
        let url = URL(string: "\(link)?__a=1")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return completion(nil)
            }
            if let json = (try? JSONSerialization.jsonObject(with: data)) as? Json {
                completion(json)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    private static func parseJson(_ json: Json, completion: @escaping (Post?) -> ()) {
        guard let graph = json["graphql"] as? Json,
            let media = graph["shortcode_media"] as? Json,
            let owner = media["owner"] as? Json else {
                return completion(nil)
        }
        
        guard let username = owner["username"] as? String,
            let avatarUrl = (owner["profile_pic_url"] as? String)?.url else {
                return completion(nil)
        }
        
        let user = InstagramUser(username: username, avatarUrl: avatarUrl)
        
        URLSession.getImage(url: avatarUrl) { avatarImage in
            user.avatarImage = avatarImage
            
            guard let imageUrl = (media["display_url"] as? String)?.url else {
                return completion(nil)
            }
            
            URLSession.getImage(url: imageUrl) { image in
                guard let image = image else {
                    return completion(nil)
                }
                
                let videoUrl = (media["video_url"] as? String)?.url
                
                let post = Post(user: user, imageUrl: imageUrl, videoUrl: videoUrl)
                post.image = image
                
                completion(post)
            }
        }
    }
}

extension URLSession {
    
    class func getImage(url: URL, completion: @escaping (UIImage?) -> ()) {
        shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let data = data, error == nil {
                    completion(UIImage(data: data))
                } else {
                    completion(nil)
                }
            }
        }.resume()
    }
}

extension String {
    
    var url: URL? {
        return URL(string: self)
    }
    
}
