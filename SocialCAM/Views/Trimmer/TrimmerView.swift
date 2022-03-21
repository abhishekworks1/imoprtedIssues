//
//  TrimmerView.swift
//  TrimmerVideo
//
//  Created by Diego Caroli on 19/09/2018.
//  Copyright © 2018 Diego Caroli. All rights reserved.
//

import UIKit
import AVKit

@objc public protocol TrimmerViewDelegate: class {
    @objc optional func trimmerDidBeginDragging(
        _ trimmer: TrimmerView,
        with currentTimeTrim: CMTime, isLeftGesture: Bool)
    
    @objc optional func trimmerDidChangeDraggingPosition(
        _ trimmer: TrimmerView,
        with currentTimeTrim: CMTime)
    
    @objc optional func trimmerDidEndDragging(
        _ trimmer: TrimmerView,
        with startTime: CMTime,
        endTime: CMTime, isLeftGesture: Bool)
    
    @objc optional func trimmerScrubbingDidBegin(
        _ trimmer: TrimmerView,
        with currentTimeScrub: CMTime)
    
    @objc optional func trimmerScrubbingDidChange(
        _ trimmer: TrimmerView,
        with currentTimeScrub: CMTime)
    
    @objc optional func trimmerScrubbingDidEnd(
        _ trimmer: TrimmerView,
        with currentTimeScrub: CMTime,
        with sender: UIPanGestureRecognizer)
}

@IBDesignable
open class TrimmerView: UIView {
    
    // MARK: IBInspectable
    @IBInspectable open var mainColor: UIColor = ApplicationSettings.appPrimaryColor {
        didSet {
            trimView.layer.borderColor = mainColor.cgColor
            leftDraggableView.backgroundColor = mainColor
            rightDraggableView.backgroundColor = mainColor
        }
    }
    
    @IBInspectable open var borderWidth: CGFloat = 2 {
        didSet {
            trimView.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable open var alphaView: CGFloat = 0.7 {
        didSet {
            leftMaskView.alpha = alphaView
            rightMaskView.alpha = alphaView
        }
    }
    
    @IBInspectable open var draggableViewWidth: CGFloat = 2 {
        didSet {
            dimmingViewLeadingAnchor = thumbnailsView.leadingAnchor
                .constraint(equalTo: leadingAnchor, constant: draggableViewWidth)
            dimmingViewTrailingAnchor = thumbnailsView.trailingAnchor
                .constraint(equalTo: trailingAnchor, constant: -draggableViewWidth)
            trimViewWidthContraint = trimView.widthAnchor
                .constraint(greaterThanOrEqualToConstant: draggableViewWidth * 2 + borderWidth)
            leftDraggableViewWidthAnchor = leftDraggableView.widthAnchor
                .constraint(equalToConstant: draggableViewWidth)
            rightDraggableViewWidthAnchor = rightDraggableView.widthAnchor
                .constraint(equalToConstant: draggableViewWidth)
        }
    }
    
    @IBInspectable open var timePointerViewWidth: CGFloat = 2 {
        didSet {
            timePointerViewWidthgAnchor = timePointerView.widthAnchor
                .constraint(equalToConstant: timePointerViewWidth)
            timePointerViewHeightAnchor = timePointerView.heightAnchor
                .constraint(equalToConstant: bounds.height - timePointerViewWidth * 2)
        }
    }
    
    @IBInspectable open var leftImage: UIImage? = UIImage.init(named: "cut_handle_icon") {
        didSet {
            leftImageView.image = leftImage
            leftImageViewCenterX = leftImageView.centerXAnchor
                .constraint(equalTo: leftDraggableView.centerXAnchor)
            leftImageViewCenterY = leftImageView.centerYAnchor
                .constraint(equalTo: leftDraggableView.centerYAnchor)
            let heightAnc = leftImageView.heightAnchor.constraint(equalToConstant: 60)
            let widthAnc = leftImageView.widthAnchor.constraint(equalToConstant: 20)
            NSLayoutConstraint.activate([heightAnc, widthAnc])
        }
    }
    
    @IBInspectable open var rightImage: UIImage? = UIImage.init(named: "cut_handle_icon") {
        didSet {
            rightImageView.image = rightImage
            rightImageViewCenterX = rightImageView.centerXAnchor
                .constraint(equalTo: rightDraggableView.centerXAnchor)
            rightImageViewCenterY = rightImageView.centerYAnchor
                .constraint(equalTo: rightDraggableView.centerYAnchor)
            let heightAnc = rightImageView.heightAnchor.constraint(equalToConstant: 60)
            let widthAnc = rightImageView.widthAnchor.constraint(equalToConstant: 20)
            NSLayoutConstraint.activate([heightAnc, widthAnc])
        }
    }
    
    @IBInspectable open var minVideoDurationAfterTrimming: Double = 3.0
    
    @IBInspectable open var isTimePointerVisible: Bool = true
  
    @IBInspectable open var isHideLeftRightView: Bool = false {
        didSet {
            if isHideLeftRightView {
                self.leftDraggableView.isHidden = true
                self.rightDraggableView.isHidden = true
            } else {
                self.leftDraggableView.isHidden = false
                self.rightDraggableView.isHidden = false
            }
        }
    }
    
    @IBInspectable open var isLeftRightViewTapable: Bool = false
    
    open weak var delegate: TrimmerViewDelegate?
   
    var minDistance: CGFloat = 0
    open var viewCornerRadius: CGFloat = 10.0
    
    // MARK: Views
    lazy var trimView: UIView = {
        let view = UIView()
        view.frame = .zero
        view.backgroundColor = ApplicationSettings.appClearColor
        view.layer.borderWidth = 2.0
        view.layer.cornerRadius = viewCornerRadius
        view.clipsToBounds = false
        view.layer.masksToBounds = true
        view.layer.borderColor = ApplicationSettings.appPrimaryColor.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var leftDraggableView: UIView = {
        let view = DraggableView()
        view.frame = .zero
        view.backgroundColor = ApplicationSettings.appClearColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var rightDraggableView: UIView = {
        let view = DraggableView()
        view.frame = .zero
        view.backgroundColor = ApplicationSettings.appClearColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var leftMaskView: UIView = {
        let view = UIView()
        view.frame = .zero
        view.backgroundColor = ApplicationSettings.appWhiteColor
        view.alpha = 0.7
        view.layer.cornerRadius = viewCornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        view.clipsToBounds = false
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy var rightMaskView: UIView = {
        let view = UIView()
        view.frame = .zero
        view.backgroundColor = ApplicationSettings.appWhiteColor
        view.alpha = 0.7
        view.layer.cornerRadius = viewCornerRadius
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy var topTrimCornerView: UIView = {
        let view = UIView()
        view.frame = .zero
        view.backgroundColor = ApplicationSettings.appClearColor
        view.layer.borderWidth = 5.0
        view.layer.cornerRadius = viewCornerRadius
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.layer.borderColor = ApplicationSettings.appClearColor.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy var leftTopCornerMaskView: UIView = {
        let cutView = UIImageView.init(image: R.image.imgTrimCorners())
        cutView.frame = .zero
        cutView.translatesAutoresizingMaskIntoConstraints = false
        cutView.isUserInteractionEnabled = true
        return cutView
    }()
    
    lazy var leftBottomCornerMaskView: UIView = {
        let cutView = UIImageView.init(image: R.image.imgTrimCorners())
        cutView.frame = .zero
        cutView.translatesAutoresizingMaskIntoConstraints = false
        cutView.isUserInteractionEnabled = true
        return cutView
    }()
    
    lazy var rightTopCornerMaskView: UIView = {
        let cutView = UIImageView.init(image: R.image.imgTrimCorners())
        cutView.frame = .zero
        cutView.translatesAutoresizingMaskIntoConstraints = false
        cutView.isUserInteractionEnabled = true
        return cutView
    }()
    
    lazy var rightBottomCornerMaskView: UIView = {
        let cutView = UIImageView.init(image: R.image.imgTrimCorners())
        cutView.frame = .zero
        cutView.translatesAutoresizingMaskIntoConstraints = false
        cutView.isUserInteractionEnabled = true
        return cutView
    }()
    
    private let leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = .zero
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    private let rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = .zero
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    public var cutView: UIView = {
        let cutView = UIImageView.init(image: R.image.icoTrimCutter())
        cutView.frame = .zero
        cutView.translatesAutoresizingMaskIntoConstraints = false
        cutView.isUserInteractionEnabled = true
        return cutView
    }()
    
    public let timePointerView: UIView = {
        let view = DraggableView()
        view.frame = .zero
        view.backgroundColor = ApplicationSettings.appWhiteColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    open var thumbnailsView: ThumbnailsView = {
        let thumbsView = ThumbnailsView()
        thumbsView.frame = .zero
        thumbsView.layer.cornerRadius = 10
        thumbsView.clipsToBounds = false
        thumbsView.layer.masksToBounds = true
        thumbsView.translatesAutoresizingMaskIntoConstraints = false
        thumbsView.isUserInteractionEnabled = true
        return thumbsView
    }()
    
    // MARK: Properties
    
    // Return the minimum distance between the left and right view expressed in seconds
    open var minimumDistanceBetweenDraggableViews: CGFloat? {
        return CGFloat(minVideoDurationAfterTrimming)
            * thumbnailsView.durationSize
            / CGFloat(thumbnailsView.videoDuration.seconds)
    }
    
    /// Return the time of the start
    open var startTime: CMTime? {
        let startPosition = leftDraggableView.frame.maxX - thumbnailsView.frame.origin.x
        
        return thumbnailsView.getTime(from: startPosition)
    }
    
    /// Return the time of the end
    open var endTime: CMTime? {
        let endPosition = rightDraggableView.frame.minX - thumbnailsView.frame.origin.x
        
        return thumbnailsView.getTime(from: endPosition)
    }

    var currentPointerTime: CMTime? {
        let startPosition = timePointerView.frame.maxX - thumbnailsView.frame.origin.x
        return thumbnailsView.getTime(from: startPosition)
    }
    
    var thumbnailViewRect: CGRect {
        return CGRect(
            x: draggableViewWidth,
            y: 30,
            width: bounds.width - 2 * draggableViewWidth,
            height: bounds.height - 30)
    }
   
    var leftPanGesture: UIPanGestureRecognizer = UIPanGestureRecognizer.init()

    var leftTapPanGesture: UITapGestureRecognizer = UITapGestureRecognizer.init()
    var rightTapPanGesture: UITapGestureRecognizer = UITapGestureRecognizer.init()
    
    var rightPanGesture: UIPanGestureRecognizer = UIPanGestureRecognizer.init()
    
    // MARK: Constraints
    lazy var currentLeadingConstraint: CGFloat = 0
    lazy var currentTrailingConstraint: CGFloat = 0
    lazy var currentPointerLeadingConstraint: CGFloat = 0
    
    private var dimmingViewTopAnchor: NSLayoutConstraint!
    private var dimmingViewBottomAnchor: NSLayoutConstraint!
    private var dimmingViewLeadingAnchor: NSLayoutConstraint!
    private var dimmingViewTrailingAnchor: NSLayoutConstraint!
    
    private var trimViewTopAnchorConstraint: NSLayoutConstraint!
    private  var trimViewBottomAnchorConstraint: NSLayoutConstraint!
    var trimViewLeadingConstraint: NSLayoutConstraint!
    var trimViewTrailingConstraint: NSLayoutConstraint!
    var trimViewWidthContraint: NSLayoutConstraint!
    
    private var leftDraggableViewLeadingAnchor: NSLayoutConstraint!
    private var leftDraggableViewWidthAnchor: NSLayoutConstraint!
    private var leftDraggableViewTopAnchor: NSLayoutConstraint!
    private var leftDraggableViewBottomAnchor: NSLayoutConstraint!
    
    private var rightDraggableViewTopAnchor: NSLayoutConstraint!
    private var rightDraggableViewBottomAnchor: NSLayoutConstraint!
    private var rightDraggableViewTrailingAnchor: NSLayoutConstraint!
    private var rightDraggableViewWidthAnchor: NSLayoutConstraint!
    
    private var leftMaskViewTopAnchor: NSLayoutConstraint!
    private var leftMaskViewBottomAnchor: NSLayoutConstraint!
    private var leftMaskViewLeadingAnchor: NSLayoutConstraint!
    private var leftMaskViewTrailingAnchor: NSLayoutConstraint!
     
    private var rightMaskViewTopAnchor: NSLayoutConstraint!
    private var rightMaskViewBottomAnchor: NSLayoutConstraint!
    private var rightMaskViewTrailingAnchor: NSLayoutConstraint!
    private var rightMaskViewLeadingAnchor: NSLayoutConstraint!
    
    private var timePointerViewWidthgAnchor: NSLayoutConstraint!
    private var timePointerViewHeightAnchor: NSLayoutConstraint!
    private var timePointerViewTopAnchor: NSLayoutConstraint!
    var timePointerViewLeadingAnchor: NSLayoutConstraint!
   
    private var cutViewWidthgAnchor: NSLayoutConstraint!
    private var cutViewHeightAnchor: NSLayoutConstraint!
    private var cutViewTopAnchor: NSLayoutConstraint!
    private var cutViewLeadingAnchor: NSLayoutConstraint!
    
    private var leftImageViewCenterX: NSLayoutConstraint!
    private var leftImageViewCenterY: NSLayoutConstraint!
    
    private var rightImageViewCenterX: NSLayoutConstraint!
    private var rightImageViewCenterY: NSLayoutConstraint!
    
    // MARK: View Life Cycle
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        dimmingViewTopAnchor = thumbnailsView.topAnchor
            .constraint(equalTo: topAnchor, constant: 0)
        dimmingViewBottomAnchor = thumbnailsView.bottomAnchor
            .constraint(equalTo: bottomAnchor, constant: 0)
        dimmingViewLeadingAnchor = thumbnailsView.leadingAnchor
            .constraint(equalTo: leadingAnchor, constant: draggableViewWidth)
        dimmingViewTrailingAnchor = thumbnailsView.trailingAnchor
            .constraint(equalTo: trailingAnchor, constant: -draggableViewWidth)
        
        let dimmingViewTopAnchor2 = topTrimCornerView.topAnchor
            .constraint(equalTo: topAnchor, constant: 0)
        let dimmingViewBottomAnchor2 = topTrimCornerView.bottomAnchor
            .constraint(equalTo: bottomAnchor, constant: 0)
        let dimmingViewLeadingAnchor2 = topTrimCornerView.leadingAnchor
            .constraint(equalTo: leadingAnchor, constant: draggableViewWidth)
        let dimmingViewTrailingAnchor2 = topTrimCornerView.trailingAnchor
            .constraint(equalTo: trailingAnchor, constant: -draggableViewWidth)
        
        let leftTopCornerMaskViewTopAnchor = leftTopCornerMaskView.topAnchor
            .constraint(equalTo: trimView.topAnchor, constant: 0)
        let leftTopCornerMaskViewHeightAnchor = leftTopCornerMaskView.heightAnchor
            .constraint(equalToConstant: 15)
        let leftTopCornerMaskViewLeadingAnchor = leftTopCornerMaskView.leadingAnchor
            .constraint(equalTo: trimView.leadingAnchor, constant: 0)
        let leftTopCornerMaskViewWidthAnchor = leftTopCornerMaskView.widthAnchor
            .constraint(equalToConstant: 15)
        
        let leftBottomCornerMaskViewTopAnchor = leftBottomCornerMaskView.bottomAnchor
            .constraint(equalTo: trimView.bottomAnchor, constant: 0)
        let leftBottomCornerMaskViewHeightAnchor = leftBottomCornerMaskView.heightAnchor
            .constraint(equalToConstant: 15)
        let leftBottomCornerMaskViewLeadingAnchor = leftBottomCornerMaskView.leadingAnchor
            .constraint(equalTo: trimView.leadingAnchor, constant: 0)
        let leftBottomCornerMaskViewWidthAnchor = leftBottomCornerMaskView.widthAnchor
            .constraint(equalToConstant: 15)
        
        let rightTopCornerMaskViewTopAnchor = rightTopCornerMaskView.topAnchor
            .constraint(equalTo: trimView.topAnchor, constant: 0)
        let rightTopCornerMaskViewHeightAnchor = rightTopCornerMaskView.heightAnchor
            .constraint(equalToConstant: 15)
        let rightTopCornerMaskViewLeadingAnchor = rightTopCornerMaskView.trailingAnchor
            .constraint(equalTo: trimView.trailingAnchor, constant: 0)
        let rightTopCornerMaskViewWidthAnchor = rightTopCornerMaskView.widthAnchor
            .constraint(equalToConstant: 15)
        
        let rightBottomCornerMaskViewTopAnchor = rightBottomCornerMaskView.bottomAnchor
            .constraint(equalTo: trimView.bottomAnchor, constant: 0)
        let rightBottomCornerMaskViewHeightAnchor = rightBottomCornerMaskView.heightAnchor
            .constraint(equalToConstant: 15)
        let rightBottomCornerMaskViewLeadingAnchor = rightBottomCornerMaskView.trailingAnchor
            .constraint(equalTo: trimView.trailingAnchor, constant: 0)
        let rightBottomCornerMaskViewWidthAnchor = rightBottomCornerMaskView.widthAnchor
            .constraint(equalToConstant: 15)
        
        trimViewTopAnchorConstraint = trimView.topAnchor
            .constraint(equalTo: topAnchor, constant: 30)
        trimViewBottomAnchorConstraint = trimView.bottomAnchor
            .constraint(equalTo: bottomAnchor, constant: 0)
        trimViewLeadingConstraint = trimView.leadingAnchor
            .constraint(equalTo: leadingAnchor, constant: 0)
        trimViewTrailingConstraint = trimView.trailingAnchor
            .constraint(equalTo: trailingAnchor, constant: 0)
        trimViewWidthContraint = trimView.widthAnchor
            .constraint(greaterThanOrEqualToConstant: draggableViewWidth * 2 + borderWidth)
        
        leftDraggableViewLeadingAnchor = leftDraggableView.leadingAnchor
            .constraint(equalTo: trimView.leadingAnchor, constant: 0)
        leftDraggableViewWidthAnchor = leftDraggableView.widthAnchor
            .constraint(equalToConstant: draggableViewWidth)
        leftDraggableViewTopAnchor = leftDraggableView.topAnchor
            .constraint(equalTo: trimView.topAnchor, constant: 0)
        leftDraggableViewBottomAnchor = leftDraggableView.bottomAnchor
            .constraint(equalTo: trimView.bottomAnchor, constant: 0)
        
        rightDraggableViewTopAnchor = rightDraggableView.topAnchor
            .constraint(equalTo: trimView.topAnchor, constant: 0)
        rightDraggableViewBottomAnchor = rightDraggableView.bottomAnchor
            .constraint(equalTo: trimView.bottomAnchor, constant: 0)
        rightDraggableViewTrailingAnchor = rightDraggableView.trailingAnchor
            .constraint(equalTo: trimView.trailingAnchor, constant: 0)
        rightDraggableViewWidthAnchor = rightDraggableView.widthAnchor
            .constraint(equalToConstant: draggableViewWidth)
        
        leftMaskViewTopAnchor = leftMaskView.topAnchor
            .constraint(equalTo: trimView.topAnchor, constant: 0)
        leftMaskViewBottomAnchor = leftMaskView.bottomAnchor
            .constraint(equalTo: trimView.bottomAnchor, constant: 0)
        leftMaskViewLeadingAnchor = leftMaskView.leadingAnchor
            .constraint(equalTo: leadingAnchor, constant: 0)
        leftMaskViewTrailingAnchor = leftMaskView.trailingAnchor
            .constraint(equalTo: leftDraggableView.leadingAnchor, constant: 0)
        
        rightMaskViewTopAnchor = rightMaskView.topAnchor
            .constraint(equalTo: topAnchor, constant: 30)
        rightMaskViewBottomAnchor = rightMaskView.bottomAnchor
            .constraint(equalTo: bottomAnchor, constant: 0)
        rightMaskViewTrailingAnchor = rightMaskView.trailingAnchor
            .constraint(equalTo: trailingAnchor, constant: 0)
        rightMaskViewLeadingAnchor = rightMaskView.leadingAnchor
            .constraint(equalTo: rightDraggableView.trailingAnchor, constant: 0)
        
        timePointerViewWidthgAnchor = timePointerView.widthAnchor
            .constraint(equalToConstant: timePointerViewWidth)
        timePointerViewHeightAnchor = timePointerView.heightAnchor
            .constraint(equalToConstant: frame.height - 20)
        timePointerViewTopAnchor = timePointerView.topAnchor
            .constraint(equalTo: topAnchor, constant: borderWidth + 30)
        timePointerViewLeadingAnchor = timePointerView.leadingAnchor
            .constraint(equalTo: leftDraggableView.trailingAnchor, constant: 0)
        
        cutViewWidthgAnchor = cutView.widthAnchor
            .constraint(equalToConstant: 35)
        cutViewHeightAnchor = cutView.heightAnchor
            .constraint(equalToConstant: 35)
        cutViewTopAnchor = cutView.topAnchor
            .constraint(equalTo: topAnchor, constant: 0)
        cutViewLeadingAnchor = cutView.leadingAnchor
            .constraint(equalTo: leftDraggableView.trailingAnchor, constant: 15)
        
        leftImageViewCenterX = leftImageView.centerXAnchor
            .constraint(equalTo: leftDraggableView.centerXAnchor)
        leftImageViewCenterY = leftImageView.centerYAnchor
            .constraint(equalTo: leftDraggableView.centerYAnchor)
        
        rightImageViewCenterX = rightImageView.centerXAnchor
            .constraint(equalTo: rightDraggableView.centerXAnchor)
        rightImageViewCenterY = rightImageView.centerYAnchor
            .constraint(equalTo: rightDraggableView.centerYAnchor)
       
        trimViewLeadingConstraint.priority = UILayoutPriority(rawValue: 750)
        trimViewTrailingConstraint.priority = UILayoutPriority(rawValue: 750)
        
        setup()
        
        NSLayoutConstraint.activate([dimmingViewTopAnchor2,
                                     dimmingViewBottomAnchor2,
                                     dimmingViewLeadingAnchor2,
                                     dimmingViewTrailingAnchor2])
        
        NSLayoutConstraint.activate([leftTopCornerMaskViewTopAnchor,
                                     leftTopCornerMaskViewHeightAnchor,
                                     leftTopCornerMaskViewLeadingAnchor,
                                     leftTopCornerMaskViewWidthAnchor])
        
        NSLayoutConstraint.activate([leftBottomCornerMaskViewTopAnchor,
                                     leftBottomCornerMaskViewHeightAnchor,
                                     leftBottomCornerMaskViewLeadingAnchor,
                                     leftBottomCornerMaskViewWidthAnchor])
        
        NSLayoutConstraint.activate([rightTopCornerMaskViewTopAnchor,
                                     rightTopCornerMaskViewHeightAnchor,
                                     rightTopCornerMaskViewLeadingAnchor,
                                     rightTopCornerMaskViewWidthAnchor])
        
        NSLayoutConstraint.activate([rightBottomCornerMaskViewTopAnchor,
                                     rightBottomCornerMaskViewHeightAnchor,
                                     rightBottomCornerMaskViewLeadingAnchor,
                                     rightBottomCornerMaskViewWidthAnchor])
        
        NSLayoutConstraint.activate([dimmingViewTopAnchor,
                                     dimmingViewBottomAnchor,
                                     dimmingViewLeadingAnchor,
                                     dimmingViewTrailingAnchor])
        NSLayoutConstraint.activate([
            trimViewTopAnchorConstraint,
            trimViewBottomAnchorConstraint,
            trimViewLeadingConstraint,
            trimViewTrailingConstraint,
            trimViewWidthContraint])
        NSLayoutConstraint.activate([
            leftDraggableViewLeadingAnchor,
            leftDraggableViewWidthAnchor,
            leftDraggableViewTopAnchor,
            leftDraggableViewBottomAnchor])
        NSLayoutConstraint.activate([
            rightDraggableViewTopAnchor,
            rightDraggableViewBottomAnchor,
            rightDraggableViewTrailingAnchor,
            rightDraggableViewWidthAnchor])
        NSLayoutConstraint.activate([
            leftMaskViewTopAnchor,
            leftMaskViewBottomAnchor,
            leftMaskViewLeadingAnchor,
            leftMaskViewTrailingAnchor])
       
        NSLayoutConstraint.activate([
            rightMaskViewTopAnchor,
            rightMaskViewBottomAnchor,
            rightMaskViewLeadingAnchor,
            rightMaskViewTrailingAnchor])
        NSLayoutConstraint.activate([
            leftImageViewCenterX,
            leftImageViewCenterY,
            rightImageViewCenterX,
            rightImageViewCenterY])
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        thumbnailsView.frame = thumbnailViewRect
    }
    
    // MARK: Setups views
    private func setup() {
       backgroundColor = ApplicationSettings.appClearColor
        
        addSubview(thumbnailsView)
        addSubview(trimView)
        
       
        
        addSubview(topTrimCornerView)
        addSubview(leftMaskView)
        addSubview(rightMaskView)
       
        
        topTrimCornerView.addSubview(leftTopCornerMaskView)
        topTrimCornerView.addSubview(leftBottomCornerMaskView)
        topTrimCornerView.addSubview(rightTopCornerMaskView)
        topTrimCornerView.addSubview(rightBottomCornerMaskView)
        
        leftBottomCornerMaskView.transformRotate(angle: 270)
        rightTopCornerMaskView.transformRotate(angle: 90)
        rightBottomCornerMaskView.transformRotate(angle: 180)
        
        addSubview(leftDraggableView)
        addSubview(rightDraggableView)
        
        leftDraggableView.addSubview(leftImageView)
        rightDraggableView.addSubview(rightImageView)
    
        setupTimePointer()
        setupCutTimePointer()
        addSubview(leftDraggableView)
        addSubview(rightDraggableView)
        
        leftDraggableView.addSubview(leftImageView)
        rightDraggableView.addSubview(rightImageView)
        
        setupPanGestures()
        minDistanceUpdate()
        leftDraggableView.layer.zPosition = 1
        timePointerView.bringSubviewToFront(leftDraggableView)
        
        addSubview(cutView)
    }
//    func updateColorForCut(){
//
//        trimView.backgroundColor = ApplicationSettings.appWhiteColor
//        trimView.alpha = 0.7
//
//        leftDraggableView.backgroundColor = mainColor
//        leftDraggableView.alpha = 1.0
//
//        rightDraggableView.backgroundColor = mainColor
//        rightDraggableView.alpha = 1.0
//
//    }
    private func minDistanceUpdate() {
        self.layoutIfNeeded()
        self.minDistance = self.bounds.width - abs((trimViewTrailingConstraint.constant - trimViewLeadingConstraint.constant) - (draggableViewWidth * 2))
    }
    
    private func setupTimePointer() {
        if isTimePointerVisible {
            addSubview(timePointerView)
            
            NSLayoutConstraint.activate([
                timePointerViewHeightAnchor,
                timePointerViewWidthgAnchor,
                timePointerViewTopAnchor,
                timePointerViewLeadingAnchor
                ])
            
        } else {
            timePointerView.removeFromSuperview()
            
            NSLayoutConstraint.deactivate([
                timePointerViewHeightAnchor,
                timePointerViewWidthgAnchor,
                timePointerViewTopAnchor,
                timePointerViewLeadingAnchor
                ])
            
            
        }
    }
    private func setupCutTimePointer() {
        if isTimePointerVisible {
            addSubview(cutView)
            NSLayoutConstraint.activate([
                cutViewWidthgAnchor,
                cutViewHeightAnchor,
                cutViewTopAnchor,
                cutViewLeadingAnchor
                ])
        } else {
            
            cutView.removeFromSuperview()
            
            NSLayoutConstraint.deactivate([
                cutViewWidthgAnchor,
                cutViewHeightAnchor,
                cutViewTopAnchor,
                cutViewLeadingAnchor
                ])
        }
    }
    // MARK: Gestures
    private func setupPanGestures() {
        let thumbsPanGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(handleScrubbingPan))
        trimView.addGestureRecognizer(thumbsPanGesture)
        
        let timePointerViewGesture = UIPanGestureRecognizer(target: self, action: #selector(handleTimePointerViewPan))
        timePointerView.addGestureRecognizer(timePointerViewGesture)
        
        let cutTimePointerViewGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCutTimePointerViewPan))
        cutView.addGestureRecognizer(cutTimePointerViewGesture)
        
        leftPanGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePan))
        leftDraggableView.addGestureRecognizer(leftPanGesture)
        
        leftTapPanGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleLeftRightTap))
        leftDraggableView.addGestureRecognizer(leftTapPanGesture)
        
        rightTapPanGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleLeftRightTap))
        rightDraggableView.addGestureRecognizer(rightTapPanGesture)
        
        rightPanGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePan))
        rightDraggableView.addGestureRecognizer(rightPanGesture)
        
    }
    
    @objc func handleTimePointerViewPan(_ sender: UIPanGestureRecognizer) {
        guard let view = sender.view else { return }
        let translation = sender.translation(in: view)
       // print("handleTimePointerViewPan")
        sender.setTranslation(.zero, in: view)
        let position = sender.location(in: view)
        switch sender.state {
        case .began:
            currentLeadingConstraint = trimViewLeadingConstraint.constant
            currentPointerLeadingConstraint = position.x + view.frame.minX - draggableViewWidth
            guard let time = thumbnailsView.getTime(from: currentPointerLeadingConstraint) else { return }
            delegate?.trimmerScrubbingDidBegin?(self, with: time)
        case .changed:
            currentPointerLeadingConstraint += translation.x
            if currentLeadingConstraint < currentPointerLeadingConstraint {
                guard let time = thumbnailsView.getTime(from: currentPointerLeadingConstraint) else { return }
                delegate?.trimmerScrubbingDidChange?(self, with: time)
            }
        case .failed, .ended, .cancelled:
            if currentLeadingConstraint > currentPointerLeadingConstraint {
                currentPointerLeadingConstraint = currentLeadingConstraint
            }
            guard let time = thumbnailsView.getTime(from: currentPointerLeadingConstraint) else { return }
            delegate?.trimmerScrubbingDidEnd?(self, with: time, with: sender)
        default:
            break
        }
    }
    @objc func handleCutTimePointerViewPan(_ sender: UIPanGestureRecognizer) {
        guard let view = sender.view else { return }
        let translation = sender.translation(in: view)
      //  print("handleTimePointerViewPan")
        sender.setTranslation(.zero, in: view)
        let position = sender.location(in: view)
        switch sender.state {
        case .began:
            currentLeadingConstraint = trimViewLeadingConstraint.constant
            currentPointerLeadingConstraint = position.x + view.frame.minX - draggableViewWidth
            guard let time = thumbnailsView.getTime(from: currentPointerLeadingConstraint) else { return }
            delegate?.trimmerScrubbingDidBegin?(self, with: time)
        case .changed:
            currentPointerLeadingConstraint += translation.x
            if currentLeadingConstraint < currentPointerLeadingConstraint {
                guard let time = thumbnailsView.getTime(from: currentPointerLeadingConstraint) else { return }
                delegate?.trimmerScrubbingDidChange?(self, with: time)
            }
        case .failed, .ended, .cancelled:
            if currentLeadingConstraint > currentPointerLeadingConstraint {
                currentPointerLeadingConstraint = currentLeadingConstraint
            }
            guard let time = thumbnailsView.getTime(from: currentPointerLeadingConstraint) else { return }
            delegate?.trimmerScrubbingDidEnd?(self, with: time, with: sender)
        default:
            break
        }
    }
    
    @objc func handleLeftRightTap(_ sender: UITapGestureRecognizer) {
        print("handleLeftRightTap")
        return
        guard let view = sender.view else { return }
        
        let isLeftGesture = (view == leftDraggableView)
        if isHideLeftRightView { return }
        if isLeftGesture {
            currentLeadingConstraint = trimViewLeadingConstraint.constant
        } else {
            currentTrailingConstraint = trimViewTrailingConstraint.constant
        }
        DispatchQueue.main.async {
            self.layoutIfNeeded()
            self.layoutSubviews()
        }
        if isLeftGesture {
            updateLeadingHandleConstraint()
        } else {
            guard let minDistance = minimumDistanceBetweenDraggableViews
                else { return }
            let maxConstraint = (self.bounds.width
                - (draggableViewWidth * 2)
                - minDistance) - trimViewLeadingConstraint.constant
            let newPosition = max((trimViewWidthContraint.constant - ((self.frame.width - trimViewLeadingConstraint.constant) - self.timePointerViewLeadingAnchor.constant)), -maxConstraint)
            trimViewTrailingConstraint.constant = newPosition
        }
        
        DispatchQueue.main.async {
            self.layoutIfNeeded()
            self.layoutSubviews()
        }
    }
    
    /// Update the leading contraint of the left draggable view after the pan gesture
    func updateLeadingHandleConstraint() {
        guard let minDistance = minimumDistanceBetweenDraggableViews
            else { return }
        
        let maxConstraint = (self.bounds.width
            - (draggableViewWidth * 2)
            - minDistance) + trimViewTrailingConstraint.constant
        
        let newPosition = min(currentLeadingConstraint + self.timePointerViewLeadingAnchor.constant, maxConstraint)
        
        trimViewLeadingConstraint.constant = newPosition
    }
    
    /// Update the trailing contraint of the right draggable view after the pan gesture
    func updateTrailingHandleConstraint() {
        guard let minDistance = minimumDistanceBetweenDraggableViews
            else { return }
        
        let maxConstraint = (self.bounds.width
            - (draggableViewWidth * 2)
            - minDistance) - trimViewLeadingConstraint.constant
        
        let newPosition = max((trimViewTrailingConstraint.constant - (self.frame.width - self.timePointerViewLeadingAnchor.constant - trimViewTrailingConstraint.constant - trimViewLeadingConstraint.constant)), -maxConstraint)
        
        trimViewTrailingConstraint.constant = newPosition
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let view = sender.view else { return }
        
        let isLeftGesture = (view == leftDraggableView)
        if isHideLeftRightView { return }
        
        switch sender.state {
            
        case .began:
            if isLeftGesture {
                currentLeadingConstraint = trimViewLeadingConstraint.constant
            } else {
                currentTrailingConstraint = trimViewTrailingConstraint.constant
            }
            
            if let start = startTime {
                delegate?.trimmerDidBeginDragging?(self, with: start, isLeftGesture: isLeftGesture)
            }
            
        case .changed:
            self.layoutIfNeeded()
            
            let translation = sender.translation(in: view)
            if isLeftGesture {
                updateLeadingConstraint(with: translation)
            } else {
                updateTrailingConstraint(with: translation)
            }
            
            UIView.animate(withDuration: 0.1) {
                self.layoutIfNeeded()
            }
            
            if isLeftGesture, let startTime = startTime {
                delegate?.trimmerDidChangeDraggingPosition?(self, with: startTime)
                timePointerView.isHidden = true
                cutView.isHidden = true
            } else if let endTime = endTime {
                delegate?.trimmerDidChangeDraggingPosition?(self, with: endTime)
                timePointerView.isHidden = true
                cutView.isHidden = true
            }
            
        case .cancelled, .failed, .ended:
            if let startTime = startTime, let endTime = endTime {
                delegate?.trimmerDidEndDragging?(
                    self,
                    with: startTime,
                    endTime: endTime,
                    isLeftGesture: isLeftGesture)
                
                timePointerView.isHidden = false
                cutView.isHidden = false
                timePointerViewLeadingAnchor.constant = 0
            }
            
        default:
            break
        }
    }
    
    @objc func handleScrubbingPan(_ sender: UIPanGestureRecognizer) {
        guard let view = sender.view else { return }
        let translation = sender.translation(in: view)
        let position = sender.location(in: view)
        
        switch sender.state {
        case .began:
            currentLeadingConstraint = trimViewLeadingConstraint.constant
            currentTrailingConstraint = trimViewTrailingConstraint.constant
            currentPointerLeadingConstraint = position.x + view.frame.minX - draggableViewWidth
            minDistanceUpdate()
            guard let time = thumbnailsView.getTime(from: currentPointerLeadingConstraint) else { return }
            delegate?.trimmerScrubbingDidBegin?(self, with: time)
        case .changed:
            let maxConstraint = (self.frame.width - (draggableViewWidth * 2) - minDistance) + trimViewTrailingConstraint.constant
            let newConstraintLeading = min(max(0, currentLeadingConstraint + (translation.x)), maxConstraint)
            trimViewLeadingConstraint.constant = newConstraintLeading
            
            let maxConstraintRight = (self.frame.width - (draggableViewWidth * 2) - minDistance) - trimViewLeadingConstraint.constant
            let newConstraintTrailing = clamp(currentTrailingConstraint + translation.x, -maxConstraintRight, 0)
            trimViewTrailingConstraint.constant = newConstraintTrailing
        case .failed, .ended, .cancelled:
            guard let time = thumbnailsView.getTime(
                from: trimViewLeadingConstraint.constant) else { return }
            delegate?.trimmerScrubbingDidEnd?(self, with: time, with: sender)
        default:
            break
        }
    }
    
    // MARK: Methods
    
    /// Update the leading contraint of the left draggable view after the pan gesture
    func updateLeadingConstraint(with translation: CGPoint) {
        guard let minDistance = minimumDistanceBetweenDraggableViews
            else { return }
        
        let maxConstraint = (self.bounds.width
            - (draggableViewWidth * 2)
            - minDistance) + trimViewTrailingConstraint.constant
        
        let newPosition = clamp(
            currentLeadingConstraint + translation.x,
            0, maxConstraint)
        
        trimViewLeadingConstraint.constant = newPosition
    }
    
    /// Update the trailing contraint of the right draggable view after the pan gesture
    func updateTrailingConstraint(with translation: CGPoint) {
        guard let minDistance = minimumDistanceBetweenDraggableViews
            else { return }
        
        let maxConstraint = (self.bounds.width
            - (draggableViewWidth * 2)
            - minDistance) - trimViewLeadingConstraint.constant
        
        let newPosition = clamp(
            currentTrailingConstraint + translation.x,
            -maxConstraint, 0)
        
        trimViewTrailingConstraint.constant = newPosition
    }
    
    /// Set up the new position of the pointer when the video play
    open func seek(to time: CMTime) {
        guard let newPosition = thumbnailsView.getPosition(from: time)
            else { return }
        
        let offsetPosition = thumbnailsView
            .convert(CGPoint(x: newPosition, y: 0), to: trimView)
            .x - draggableViewWidth
        
        let maxPosition = rightDraggableView.frame.minX
            - leftDraggableView.frame.maxX
            - timePointerView.frame.width
        
        let clampedPosition = clamp(offsetPosition, 0, maxPosition)
        DispatchQueue.main.async {
            self.timePointerViewWidth = 2
            self.timePointerViewLeadingAnchor.constant = CGFloat(clampedPosition)
            self.cutViewLeadingAnchor.constant = CGFloat(clampedPosition) - 15
            self.layoutIfNeeded()
            self.layoutSubviews()
        }
    }
    
    /// Reset the pointer near the left draggable view
    open func resetTimePointer() {
        timePointerViewLeadingAnchor.constant = 0
    }
    
}

private func clamp<T: Comparable>(_ number: T, _ minimum: T, _ maximum: T) -> T {
    return min(maximum, max(minimum, number))
}
