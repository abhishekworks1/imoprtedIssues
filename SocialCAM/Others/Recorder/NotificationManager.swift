//
//  NotificationManager.swift
//  SocialScreenRecorder
//
//  Created by Viraj Patel on 15/12/20.
//

import Foundation
import Photos

public protocol NotificationManagerDelegate: class {
    func error(message: String)
    func success()
}

open class NotificationManager: NSObject {
   
    static let shared: NotificationManager = NotificationManager()
    
    weak var delegate: NotificationManagerDelegate?
    
    public override init() {
        super.init()
    }
    
    func openNotificationScreen() {
        guard let notificationVC = R.storyboard.notificationVC.notificationVC() else {
            fatalError("notificationVC Not Found")
        }
        if let currentController = UIWindow.currentController {
            if let pageViewController = currentController as? PageViewController, let navigation = pageViewController.pageControllers[pageViewController.currentIndex!] as? UINavigationController {
                navigation.pushViewController(notificationVC, animated: true)
            }
        }
    }
    
    func openReviewScreenWithLastVideo() {
        guard let fileVideo = FileSystemUtil.getAllFiles().first, let file = fileVideo["absolutePath"] as? String, let fileUrl = URL(string: file), file.contains("test_file") && file.contains("mp4") else {
            return
        }
        
        guard let storyEditorViewController = R.storyboard.storyEditor.storyEditorViewController() else {
            fatalError("StoryEditorViewController Not Found")
        }
        var medias: [StoryEditorMedia] = []
        medias.append(StoryEditorMedia(type: .video(AVAsset(url: fileUrl).thumbnailImage()!, AVAsset(url: fileUrl))))
        
        storyEditorViewController.medias = medias
        storyEditorViewController.isSlideShow = false
        storyEditorViewController.referType = .socialScreenRecorder
        if let currentController = UIWindow.currentController {
            if let pageViewController = currentController as? PageViewController, let navigation = pageViewController.pageControllers[pageViewController.currentIndex!] as? UINavigationController {
                navigation.pushViewController(storyEditorViewController, animated: true)
            }
        }
    }
   
}
