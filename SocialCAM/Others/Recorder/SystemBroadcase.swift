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
    
    private static var broadCastPickerHeight: CGFloat {
        return CGFloat(44.0)
    }
    
    private static var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }
    
    static func setup(superView: UIView, tag: Int = viewTag) {
        
        let broadCastPickerFrame = CGRect(x: 0,
                                          y: 0,
                                          width: superView.frame.width,
                                          height: broadCastPickerHeight)
        broadCastPicker = RPSystemBroadcastPickerView(frame: broadCastPickerFrame)
        broadCastPicker?.preferredExtension = Constant.Application.recorderExtensionIdentifier
        broadCastPicker?.tag = tag
        
        guard let broadCastPickerView = broadCastPicker else {
            return
        }
        
        // Add subview
        superView.addSubview(broadCastPickerView)
        layout(broadCastPickerView: broadCastPickerView, superView: superView)
    }
    
    static func layout(broadCastPickerView: RPSystemBroadcastPickerView, superView: UIView) {
        
        let isCaptured = UIScreen.main.isCaptured
        let buttonTitle = isCaptured ? R.string.localizable.stopRecored() : R.string.localizable.screenRecored()
        broadCastPickerView.backgroundColor = isCaptured ? .red : .clear
        broadCastPickerView.roundCorners(corners: [.allCorners], radius: 22)
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
    }
}
