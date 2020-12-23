//
//  RecorderVC.swift
//  SocialScreenRecorder
//
//  Created by Viraj Patel on 11/12/20.
//

import UIKit
import Photos
import AVKit

class RecorderVC: UIViewController, ScreenCaptureObservable {
    
    var observers = [NSObjectProtocol]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if self.view.viewWithTag(SystemBroadcastPickerViewBuilder.viewTag) == nil {
            SystemBroadcastPickerViewBuilder.setup(superView: self.view)
        }
    }
    
    private func reloadView() {
        guard let broadCastPicker = SystemBroadcastPickerViewBuilder.broadCastPicker else {
            return
        }
        SystemBroadcastPickerViewBuilder.layout(broadCastPickerView: broadCastPicker, superView: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.reloadView()

        let observer = self.addObserver(forCapturedDidChange: { [weak self] _ in
            guard let weakSelf = self else {
                return
            }
            weakSelf.reloadView()
        }) { [weak self] _ in
            guard let weakSelf = self else {
                return
            }
            weakSelf.reloadView()
        }
        self.observers.append(observer)
    }
}
