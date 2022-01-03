//
//  SystemBroadcase.swift
//  SocialScreenRecorder
//
//  Created by Viraj Patel on 11/12/20.
//

import Foundation
import ReplayKit

struct SystemBroadcastPickerViewBuilder {
    
    static var broadCastPicker: RPSystemBroadcastPickerView?
    
    static var viewTag: Int {
        return 987654321
    }
    
    private static var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }
    
    static func setup(superView: UIView, tag: Int = viewTag, broadCastPickerHeight: CGFloat = 44) {
        let broadCastPickerFrame = CGRect(x: 0,
                                          y: 0,
                                          width: broadCastPickerHeight,
                                          height: broadCastPickerHeight)
        broadCastPicker = RPSystemBroadcastPickerView(frame: broadCastPickerFrame)
        broadCastPicker?.preferredExtension = Constant.Application.recorderExtensionIdentifier
        broadCastPicker?.tag = tag
        
        guard let broadCastPickerView = broadCastPicker else {
            return
        }
        
        // Add subview
        superView.addSubview(broadCastPickerView)
        broadCastPickerView.subviews.forEach {
            if let button = $0 as? UIButton {
                button.setImage(R.image.recordingScreen(), for: .normal)
            }
        }
        
        // Set autolayout
        broadCastPickerView.translatesAutoresizingMaskIntoConstraints = false
        broadCastPickerView.centerXAnchor.constraint(equalTo: superView.centerXAnchor, constant: 0).isActive = true
        broadCastPickerView.centerYAnchor.constraint(equalTo: superView.centerYAnchor, constant: 0).isActive = true
        broadCastPickerView.widthAnchor.constraint(equalToConstant: broadCastPickerHeight).isActive = true
        broadCastPickerView.heightAnchor.constraint(equalToConstant: broadCastPickerHeight).isActive = true
        broadCastPickerView.layoutIfNeeded()
        superView.layoutIfNeeded()
        
        layout(broadCastPickerView: broadCastPickerView)
        
//        extensionContext?.loadBroadcastingApplicationInfo(completion: {
//                    (bundleID, displayName, appIcon) in
//
//                    })
    }
    
    static func layout(broadCastPickerView: RPSystemBroadcastPickerView) {
        let isCaptured = UIScreen.main.isCaptured
        broadCastPickerView.backgroundColor = isCaptured ? .red : .clear
        broadCastPickerView.roundCorners(corners: [.allCorners], radius: broadCastPickerView.frame.height / 2)
    }
    
    static func removeBroadcastPicker(){
        guard let broadCastPickerView = broadCastPicker else {
            return
        }
        
        // remove from superview
        broadCastPickerView.removeFromSuperview()
    }
}
