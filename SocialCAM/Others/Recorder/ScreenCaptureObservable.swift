//
//  ScreenCaptureObservable.swift
//  SocialScreenRecorder
//
//  Created by Viraj Patel on 11/12/20.
//

import Foundation
import UIKit

protocol ScreenCaptureObservable {
    
    var observers: [NSObjectProtocol] {get}
    func addObserver(forCapturedDidChange startCapturingBlock: ((Notification) -> Void)?,
                     stopCapturingBlock: ((Notification) -> Void)?) -> NSObjectProtocol
    
    func removeObserver(observers: inout [NSObjectProtocol])
    
}

extension ScreenCaptureObservable where Self: UIViewController {
    func addObserver(forCapturedDidChange startCapturingBlock: ((Notification) -> Void)? = nil,
                     stopCapturingBlock: ((Notification) -> Void)? = nil) -> NSObjectProtocol {
        
        let observer = NotificationCenter
            .default
            .addObserver(forName: UIScreen.capturedDidChangeNotification, object: nil, queue: .main) { [weak self] notification in
                
                if UIScreen.main.isCaptured {
                    AppPreferences.shared.set(value: true, forKey: .startedScreenRecording)
                    startCapturingBlock?(notification)
                    print("******startedScreenRecording*********")

                    return
                }
                
                AppPreferences.shared.set(value: false, forKey: .startedScreenRecording)
                
                if let block = stopCapturingBlock {
                    print("******stopCapturingBlock*********")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        NotificationManager.shared.openReviewScreenWithLastVideo()
                    }
                    block(notification)
                } else {
                    let finishedTutorial = AppPreferences.shared.bool(forKey: .finishedTutorial)
                    if finishedTutorial {
                        return
                    }
                }
        }
        return observer
    }
    
    func removeObserver(observers: inout [NSObjectProtocol]) {
        NotificationCenter.default.removeObserver(self)
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
        observers.removeAll()
    }
}
