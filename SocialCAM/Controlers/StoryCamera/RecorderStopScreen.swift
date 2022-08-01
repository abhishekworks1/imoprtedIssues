//
//  RecorderStopScreen.swift
//  QuickCamLite
//
//  Created by Viraj Patel on 31/12/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

protocol RecorderStopScreenViewEffect {
    func setup(main: RecorderStopScreenView)
    func prepareForResize(main: RecorderStopScreenView)
    func update(at time: TimeInterval)
}

internal class RecorderStopScreenContainerView: UIView {
    
    internal var loadingView: RecorderStopScreenView!
    
    deinit {
        print("Deinit \(self.description)")
    }
    
    internal init(loadingView: RecorderStopScreenView) {
        self.loadingView = loadingView
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.loadingView = RecorderStopScreenView()
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        if loadingView.shouldDimBackground {
            backgroundColor = loadingView.dimBackgroundColor
        } else {
            backgroundColor = ApplicationSettings.appClearColor
        }
        self.isUserInteractionEnabled = loadingView.isBlocking
        addSubview(loadingView)
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        loadingView.widthAnchor.constraint(equalToConstant: loadingView.sizeInContainer.width).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: loadingView.sizeInContainer.height).isActive = true
    }
    
    internal func free() {
        if let _ = superview { removeFromSuperview() }
        if let loadingView = loadingView { loadingView.removeFromSuperview() }
        loadingView = nil
    }
}

public class RecorderStopScreenView: UIView {
    
    class func instanceFromNib() -> RecorderStopScreenView {
        return R.nib.recorderStopScreen.firstView(owner: nil) ?? RecorderStopScreenView(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
    }
    
    @IBInspectable public var mainColor: UIColor = ApplicationSettings.appWhiteColor
    var isResized = true
    
    @IBOutlet weak var recorderView: UIView!
   
    var containerView: RecorderStopScreenContainerView?
    public var shouldDimBackground = true
    public var dimBackgroundColor = ApplicationSettings.appBlackColor.withAlphaComponent(0.6)
    public var isBlocking = true
    public var shouldTapToDismiss = false
    public var sizeInContainer: CGSize = CGSize(width: 180, height: 180)
   
    deinit {
        print("Deinit \(self.description)")
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    open func setup() {
        guard let recorderView = self.recorderView else {
            return
        }
        if recorderView.viewWithTag(SystemBroadcastPickerViewBuilder.viewTag) == nil {
            SystemBroadcastPickerViewBuilder.setup(superView: recorderView, broadCastPickerHeight: 100)
        }
    }
    
    public func showOnKeyWindow(completion: (() -> Void)? = nil) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        show(on: window, completion: completion)
    }
    
    public func show(on view: UIView, completion: (() -> Void)? = nil) {
        var targetView = view
        if let view = view as? UIScrollView, let superView = view.superview {
            targetView = superView
        }
        // Remove existing container views
        let containerViews = targetView.subviews.filter { view -> Bool in
            return view is RecorderStopScreenContainerView
        }
        containerViews.forEach { view in
            if let view = view as? RecorderStopScreenContainerView { view.free() }
        }
        
        backgroundColor = ApplicationSettings.appClearColor
        sizeInContainer = view.frame.size
        containerView = RecorderStopScreenContainerView(loadingView: self)
        if let containerView = containerView {
            
            containerView.translatesAutoresizingMaskIntoConstraints = false
            targetView.addSubview(containerView)
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            containerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            containerView.isHidden = true
            
            if shouldTapToDismiss {
                containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hide)))
            }
            showContainerView()
        }
        completion?()
    }
    
    static public func hideFromKeyWindow() {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        hide(from: window)
    }
    
    static public func hide(from view: UIView) {
        let containerViews = view.subviews.filter { (view) -> Bool in
            return view is LoadingContainerView
        }
        containerViews.forEach { (view) in
            if let containerView = view as? LoadingContainerView {
                containerView.loadingView.hide()
            }
        }
    }
    
    @objc open func hide() {
        hideContainerView()
    }
   
    fileprivate func showContainerView() {
        DispatchQueue.runOnMainThread {
            if let containerView = self.containerView {
                containerView.isHidden = false
                containerView.alpha = 0.0
                UIView.animate(withDuration: 0.1) {
                    containerView.alpha = 1.0
                }
            }
        }
    }
    
    fileprivate func hideContainerView() {
        DispatchQueue.runOnMainThread {
            if let containerView = self.containerView {
                UIView.animate(withDuration: 0.1, animations: {
                    containerView.alpha = 0.0
                }, completion: { _ in
                    containerView.free()
                })
            }
        }
    }
    
}
