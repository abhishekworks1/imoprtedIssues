//
//  LoadingView.swift
//  LoaderView
//
//  Created by Viraj Patel on 31/07/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

protocol LoadingViewEffect {
    func setup(main: LoadingView)
    func prepareForResize(main: LoadingView)
    func update(at time: TimeInterval)
}

internal class LoadingContainerView: UIView {
    
    internal var loadingView: LoadingView!
    
    deinit {
        print("deinit LoadingContainerView")
    }
    
    internal init(loadingView: LoadingView) {
        self.loadingView = loadingView
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.loadingView = LoadingView()
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

public class LoadingView: UIView {
    
    class func instanceFromNib() -> LoadingView {
        return UINib(nibName: "LoadingView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! LoadingView
    }
    
    @IBInspectable public var speedFactor: CGFloat = 1.0
    @IBInspectable public var mainColor: UIColor = ApplicationSettings.appWhiteColor
    @IBInspectable public var colorVariation: CGFloat = 0.0
    @IBInspectable public var sizeFactor: CGFloat = 1.0
    @IBInspectable public var spreadingFactor: CGFloat = 1.0
    @IBInspectable public var lifeSpanFactor: CGFloat = 1.0
    @IBInspectable public var variantKey: String = ""
   
    var isResized = true
    
    @IBOutlet weak var lblCompleted: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
   
    public var shouldCancelShow = false {
        didSet {
            btnCancel.isHidden = shouldCancelShow
        }
    }
    
    public var loadingViewShow = false {
        didSet {
            lblCompleted.isHidden = loadingViewShow
            progressView.isHidden = loadingViewShow
            loadingView.isHidden = !loadingViewShow
        }
    }
    
    var containerView: LoadingContainerView?
    public var shouldDimBackground = true
    public var dimBackgroundColor = ApplicationSettings.appBlackColor.withAlphaComponent(0.6)
    public var isBlocking = true
    public var shouldTapToDismiss = false
    public var sizeInContainer: CGSize = CGSize(width: 180, height: 180)
   
    var cancelClick: ((Bool) -> Void)?
    
    @IBAction func btnCancelClick(_ sender: UIButton) {
        if let handler = cancelClick {
            handler(true)
        }
    }
    
    @IBOutlet weak var progressView: CircularProgressBar! {
        didSet {
            progressView.labelSize = 30
            progressView.safePercent = 100
        }
    }
    
    weak var advertiseTimer: Timer?
    var currentSelectedImg: Int = 0 // for advertise selected imag
    var imgAdvertisementArray: [String] = ["ad1", "ad2", "ad3", "ad4", "ad5", "ad6"]
    
    @IBOutlet weak var imgAdvertise: UIImageView!
    @IBOutlet weak var loadingView: FSLoading!
    
    deinit {
        print("deinit LoadingView")
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func advertisementTimer() {
        if currentSelectedImg < imgAdvertisementArray.count {
            imgAdvertise.image = UIImage(named: imgAdvertisementArray[currentSelectedImg])
        }
        advertiseTimer =  Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] (_) in
            guard let `self` = self else {
                return
            }
            self.manageAdvertisement()
        }
    }
    
    func manageAdvertisement() {
        let nIndex = currentSelectedImg + 1
        if nIndex < imgAdvertisementArray.count {
            currentSelectedImg = currentSelectedImg + 1
        } else {
            currentSelectedImg = 0
        }
        if currentSelectedImg < imgAdvertisementArray.count {
            imgAdvertise.image = UIImage(named: imgAdvertisementArray[currentSelectedImg])
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open func setup() {
        advertisementTimer()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    public func showOnKeyWindow(completion: (() -> Void)? = nil) {
        show(on: UIApplication.shared.keyWindow!, completion: completion)
    }
    
    public func show(on view: UIView, completion: (() -> Void)? = nil) {
        progressView.setProgress(to: 0.0, withAnimation: false)
        var targetView = view
        if let view = view as? UIScrollView, let superView = view.superview {
            targetView = superView
        }
        // Remove existing container views
        let containerViews = targetView.subviews.filter { view -> Bool in
            return view is LoadingContainerView
        }
        containerViews.forEach { view in
            if let view = view as? LoadingContainerView { view.free() }
        }
        
        backgroundColor = ApplicationSettings.appClearColor
        sizeInContainer = view.frame.size
        containerView = LoadingContainerView(loadingView: self)
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
        hide(from: UIApplication.shared.keyWindow!)
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
