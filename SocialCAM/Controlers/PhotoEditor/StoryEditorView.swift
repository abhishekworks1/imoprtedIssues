//
//  StoryEditorView.swift
//  PhotoVideoEditor
//
//  Created by Jasmin Patel on 28/11/19.
//  Copyright © 2019 Jasmin Patel. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

enum StoryEditorType: Equatable {
    case image(UIImage)
    case video(UIImage, AVAsset)
}

class StoryEditorView: UIView {
    
    private var mediaGestureView: UIView
    
    private var mediaContentMode: StoryImageView.ImageContentMode = .scaleAspectFit
    
    private var storySwipeableFilterView: StorySwipeableFilterView
    
    private var drawView: SketchView
    
    private var filterNameLabel: UILabel
    
    private var deleteView: UIView?
    
    private var undoView: UIView?

    private var storyPlayer: StoryPlayer?
    
    public var type: StoryEditorType = .image(#imageLiteral(resourceName: "videoBackground"))
    
    private var isZooming = false {
        didSet {
            self.storySwipeableFilterView.selectFilterScrollView.isScrollEnabled = !isZooming
        }
    }
    // Draw
    private var isDrawing: Bool = false
    public var drawColor: UIColor = .white {
        didSet {
            self.drawView.lineColor = drawColor
        }
    }
    
    private var imageViewToPan: UIImageView?
    private var lastPanPoint: CGPoint?
    // TextView
    private var isTyping: Bool = false
    private var textViews: [UITextView] = []
    private var lastTextViewTransform: CGAffineTransform?
    private var lastTextViewTransCenter: CGPoint?
    private var lastTextViewFont: UIFont?
    private var activeTextView: UITextView?
    public var textColor: UIColor = .white {
        didSet {
            self.activeTextView?.textColor = textColor
        }
    }
    
    public var selectedColor: UIColor = .white {
        didSet {
            if isDrawing {
                drawColor = selectedColor
            } else {
                textColor = selectedColor
            }
        }
    }
    
    public var filters: [StoryFilter]? {
        didSet {
            storySwipeableFilterView.layoutSubviews()
            storySwipeableFilterView.filters = self.filters
        }
    }
    
    public var selectedFilter: StoryFilter? {
        return storySwipeableFilterView.selectedFilter
    }
    
    public var imageTransformation: StoryImageView.ImageTransformation {
        let tx = self.mediaGestureView.frame.origin.x*100 / storySwipeableFilterView.frame.size.width
        let ty = self.mediaGestureView.frame.origin.y*100 / storySwipeableFilterView.frame.size.height
        
        let scaleX = sqrt(pow(mediaGestureView.transform.a, 2) + pow(mediaGestureView.transform.c, 2))
        let scaleY = sqrt(pow(mediaGestureView.transform.b, 2) + pow(mediaGestureView.transform.d, 2))
        
        let rotation = atan2(mediaGestureView.transform.b, mediaGestureView.transform.a)
        return StoryImageView.ImageTransformation(tx: tx, ty: ty, scaleX: scaleX, scaleY: scaleY, rotation: rotation)
    }
    
    public var thumbnailImage: UIImage?
    
    public var isSelected: Bool = false
    
    public var isMuted: Bool = false {
        didSet {
            self.storyPlayer?.isMuted = isMuted
        }
    }
    
    public var seekTime: CMTime = .zero {
        didSet {
            self.storyPlayer?.seek(to: seekTime)
        }
    }
    
    public var currentTime: CMTime {
        return self.storyPlayer?.currentTime() ?? .zero
    }
    
    override var frame: CGRect {
        didSet {
            self.mediaGestureView.frame = self.mediaRect()
            self.storySwipeableFilterView.frame = bounds
            self.drawView.frame = bounds
            self.filterNameLabel.frame = CGRect(origin: .zero,
                                                size: CGSize(width: width, height: 50))
            self.adjustMediaTransformIfNeeded()
        }
    }

    init(frame: CGRect, type: StoryEditorType, contentMode: StoryImageView.ImageContentMode, deleteView: UIView? = nil, undoView: UIView? = nil) {
        mediaGestureView = UIView()
        storySwipeableFilterView = StorySwipeableFilterView()
        drawView = SketchView()
        filterNameLabel = UILabel()
        var scaleFrame = frame
        scaleFrame.size.height = scaleFrame.size.width*667/375
        super.init(frame: scaleFrame)
        self.type = type
        self.mediaContentMode = contentMode
        self.deleteView = deleteView
        self.undoView = undoView
        setup()
        backgroundColor = ApplicationSettings.appClearColor
        storySwipeableFilterView.backgroundColor = ApplicationSettings.appClearColor
        for subview in storySwipeableFilterView.subviews {
            subview.backgroundColor = ApplicationSettings.appClearColor
        }
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {
        print("Deinit \(self.description)")
        self.storyPlayer?.unsetupDisplayLink()
    }
    
    override var isHidden: Bool {
        didSet {
            if self.isHidden {
                self.storyPlayer?.pause()
                self.storyPlayer?.seek(to: .zero)
            } else {
                self.storyPlayer?.play()
            }
        }
    }
    
}

extension StoryEditorView {
    
    func updatedThumbnailImage() -> UIImage? {
        if !self.isHidden {
            self.thumbnailImage = self.toImage()
        }
        return self.thumbnailImage
    }
    
    var isPlaying: Bool {
        return self.storyPlayer?.isPlaying ?? false
    }
    
    func pause() {
        self.storyPlayer?.pause()
    }
    
    func play() {
        self.storyPlayer?.play()
    }
    
    func currentFilteredImage() -> UIImage? {
        guard let filteredImage = storySwipeableFilterView.renderedUIImage() else {
            return nil
        }
        return filteredImage
    }
    
    func applyFilter() {
        guard let filteredImage = currentFilteredImage() else {
            return
        }
        replaceMedia(.image(filteredImage))
        if let filters = storySwipeableFilterView.filters {
            storySwipeableFilterView.scroll(to: filters[0],
                                            animated: false)
        }
    }
    
    func replaceMedia(_ type: StoryEditorType) {
        self.type = type
        switch self.type {
        case let .image(image):
            self.storySwipeableFilterView.setImageBy(image)
            self.thumbnailImage = self.storySwipeableFilterView.renderedUIImage()
        case let .video(_, asset):
            storyPlayer?.setItemBy(asset)
            storyPlayer?.play()
        }
        DispatchQueue.runOnMainThread {
            self.mediaGestureView.transform = .identity
            self.mediaGestureView.frame = self.mediaRect()
            self.adjustMediaTransformIfNeeded()
        }
    }
    
}
// MARK: StoryPlayerDelegate
extension StoryEditorView: StoryPlayerDelegate {
    func player(_ player: StoryPlayer, didRenderFirstFrame storyImageView: StoryImageView) {
        guard case .video = type else {
            return
        }
        self.thumbnailImage = self.storySwipeableFilterView.renderedUIImage()
    }
}
// MARK: Setup
extension StoryEditorView: StorySwipeableFilterViewDelegate {
    
    func setup() {
        mediaGestureView.frame = mediaRect()
        addSubview(mediaGestureView)
        
        storySwipeableFilterView.frame = bounds
        storySwipeableFilterView.isUserInteractionEnabled = true
        storySwipeableFilterView.isMultipleTouchEnabled = true
        storySwipeableFilterView.isExclusiveTouch = false
        storySwipeableFilterView.backgroundColor = .black
        storySwipeableFilterView.imageContentMode = mediaContentMode
        storySwipeableFilterView.delegate = self
        addSubview(storySwipeableFilterView)
        addMediaGestures()
        adjustMediaTransformIfNeeded()
        
        switch type {
        case let .image(image):
            self.storySwipeableFilterView.setImageBy(image)
            self.thumbnailImage = self.storySwipeableFilterView.renderedUIImage()
        case let .video(_, asset):
            storyPlayer = StoryPlayer()
            storyPlayer?.scImageView = storySwipeableFilterView
            storyPlayer?.loopEnabled = true
            storyPlayer?.delegate = self
            storyPlayer?.setItemBy(asset)
            storyPlayer?.play()
            self.thumbnailImage = asset.thumbnailImage()
        }
        setupDrawView()
        
        filterNameLabel.frame = CGRect(origin: .zero,
                                       size: CGSize(width: width, height: 50))
        filterNameLabel.center = self.center
        filterNameLabel.font = R.font.sfuiTextBold(size: 35)
        filterNameLabel.textColor = .white
        filterNameLabel.textAlignment = .center
        addSubview(filterNameLabel)
    }
    
    func mediaRect() -> CGRect {
        var mediaSize = CGSize.zero
        switch type {
        case let .image(image):
            mediaSize = image.size
            break
        case let .video(_, asset):
            guard let assetTrack = asset.tracks(withMediaType: .video).first else {
                return bounds
            }
            mediaSize = assetTrack.naturalSize
            mediaSize = mediaSize.applying(assetTrack.preferredTransform)
            break
        }
        if mediaContentMode == .scaleAspectFill {
            var aspectFillSize = CGSize(width: bounds.size.width,
                                        height: bounds.size.height)
            let newHeight: CGFloat = bounds.size.height / mediaSize.height
            let newWidth: CGFloat = bounds.size.width / mediaSize.width

            if newHeight > newWidth {
                aspectFillSize.width = newHeight * mediaSize.width
            } else if newWidth > newHeight {
                aspectFillSize.height = newWidth * mediaSize.height
            }
            return CGRect(origin: CGPoint(x: bounds.origin.x - aspectFillSize.width/2, y: 0),
                          size: aspectFillSize)
            
        } else if mediaContentMode == .scaleAspectFit {
            return AVMakeRect(aspectRatio: mediaSize,
                              insideRect: bounds)
        }
        
        return bounds
    }
    
    func swipeableFilterView(_ swipeableFilterView: StorySwipeableFilterView, didScrollTo filter: StoryFilter?) {
        filterNameLabel.isHidden = false
        filterNameLabel.text = swipeableFilterView.selectedFilter?.name
        filterNameLabel.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.filterNameLabel.alpha = 1
        }, completion: { (isCompleted) in
            if isCompleted {
                UIView.animate(withDuration: 0.3, delay: 1, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
                    self.filterNameLabel.alpha = 0
                }, completion: { (isFinished) in
                    
                })
            }
        })
    }
    
}
// MARK: Text
extension StoryEditorView: UITextViewDelegate {
    
    func startTextEditing() {
        isTyping = true
        let textView = UITextView(frame: CGRect(x: 0,
                                                y: center.y,
                                                width: bounds.width,
                                                height: 30))
        textView.tintColor = .white
        textView.textAlignment = .center
        textView.font = UIFont.systemFont(ofSize: 30)
        textView.textColor = textColor
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        textView.layer.shadowOpacity = 0.2
        textView.layer.shadowRadius = 1.0
        textView.layer.backgroundColor = UIColor.clear.cgColor
        textView.autocorrectionType = .no
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.tag = textViews.count
        textView.delegate = self
        addSubview(textView)
        addStickerGestures(textView)
        textView.becomeFirstResponder()
        textViews.append(textView)
    }
    
    func endTextEditing() {
        endEditing(true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let rotation = atan2(textView.transform.b, textView.transform.a)
        if rotation == 0 {
            let oldFrame = textView.frame
            let sizeToFit = textView.sizeThatFits(CGSize(width: oldFrame.width, height:CGFloat.greatestFiniteMagnitude))
            textView.frame.size = CGSize(width: oldFrame.width, height: sizeToFit.height)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        isTyping = true
        lastTextViewTransform = textView.transform
        lastTextViewTransCenter = textView.center
        lastTextViewFont = textView.font!
        activeTextView = textView
        textView.superview?.bringSubviewToFront(textView)
        UIView.animate(withDuration: 0.3,
                       animations: {
                        textView.transform = CGAffineTransform.identity
                        textView.center = CGPoint(x: UIScreen.main.bounds.width / 2,
                                                  y: UIScreen.main.bounds.height / 5)
        }, completion: nil)
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        isTyping = false
        guard lastTextViewTransform != nil && lastTextViewTransCenter != nil && lastTextViewFont != nil
            else {
                return
        }
        activeTextView = nil
        textView.font = self.lastTextViewFont!
        UIView.animate(withDuration: 0.3,
                       animations: {
                        textView.transform = self.lastTextViewTransform!
                        textView.center = self.lastTextViewTransCenter!
        }, completion: nil)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return isTyping
    }

}
// MARK: Draw
extension StoryEditorView: SketchViewDelegate {
    
    func setupDrawView() {
        drawView.frame = bounds
        drawView.backgroundColor = .clear
        drawView.isUserInteractionEnabled = false
        drawView.sketchViewDelegate = self
        addSubview(drawView)
    }
    
    func startDrawing() {
        isDrawing = true
        drawView.isUserInteractionEnabled = true
        undoView?.isHidden = !drawView.canUndo()
    }
    
    func endDrawing() {
        isDrawing = false
        drawView.isUserInteractionEnabled = false
        undoView?.isHidden = true
    }
    
    func undoDraw() {
        drawView.undo()
        undoView?.isHidden = !drawView.canUndo()
    }
    
    func drawView(_ view: SketchView, didEndDrawUsingTool tool: AnyObject) {
        undoView?.isHidden = !view.canUndo()
    }
    
}
// MARK: Media Gestures
extension StoryEditorView {
    
    func addMediaGestures() {
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(handleMediaPanGesture(_:)))
        panGesture.delegate = self
        panGesture.cancelsTouchesInView = false
        storySwipeableFilterView.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(handleMediaPinchGesture(_:)))
        pinchGesture.delegate = self
        pinchGesture.cancelsTouchesInView = false
        storySwipeableFilterView.addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self,
                                                          action: #selector(handleMediaRotationGesture(_:)))
        rotationGesture.delegate = self
        rotationGesture.cancelsTouchesInView = false
        storySwipeableFilterView.addGestureRecognizer(rotationGesture)
    }
    
    func adjustMediaTransformIfNeeded() {
        let tx = mediaGestureView.frame.origin.x*100 / storySwipeableFilterView.frame.size.width
        let ty = mediaGestureView.frame.origin.y*100 / storySwipeableFilterView.frame.size.height
        
        let scaleX = sqrt(pow(mediaGestureView.transform.a, 2) + pow(mediaGestureView.transform.c, 2))
        let scaleY = sqrt(pow(mediaGestureView.transform.b, 2) + pow(mediaGestureView.transform.d, 2))
        
        let rotation = atan2(mediaGestureView.transform.b, mediaGestureView.transform.a)
        
        storySwipeableFilterView.imageTransformation = StoryImageView.ImageTransformation(tx: tx, ty: ty, scaleX: scaleX, scaleY: scaleY, rotation: rotation)
        
        storySwipeableFilterView.setNeedsDisplay()
    }
    
    @objc func handleMediaPanGesture(_ recognizer: UIPanGestureRecognizer) {
        guard self.isZooming && recognizer.state == .changed else {
            return
        }
        let translation = recognizer.translation(in: self)
        mediaGestureView.center = CGPoint(x: mediaGestureView.center.x + translation.x,
                                          y: mediaGestureView.center.y + translation.y)
        recognizer.setTranslation(.zero, in: self)
        adjustMediaTransformIfNeeded()
    }
    
    @objc func handleMediaPinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        let location = recognizer.location(in: self)
        guard mediaGestureView.frame.contains(location) else {
            return
        }
        switch recognizer.state {
        case .began:
            self.isZooming = true
            break
        case .changed:
            let pinchCenter = CGPoint(x: recognizer.location(in: mediaGestureView).x - mediaGestureView.bounds.midX,
                                      y: recognizer.location(in: mediaGestureView).y - mediaGestureView.bounds.midY)
            let transform = mediaGestureView.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: recognizer.scale, y: recognizer.scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            mediaGestureView.transform = transform
            recognizer.scale = 1
            break
        case .ended, .failed, .cancelled:
            self.isZooming = false
            break
        case .possible:
            break
        @unknown default:
            break
        }
        adjustMediaTransformIfNeeded()
    }
    
    @objc func handleMediaRotationGesture(_ recognizer: UIRotationGestureRecognizer) {
        mediaGestureView.transform = mediaGestureView.transform.rotated(by: recognizer.rotation)
        recognizer.rotation = 0
        adjustMediaTransformIfNeeded()
    }
    
}
// MARK: Sticker Gestures
extension StoryEditorView {
    
    func addSticker(_ sticker: StorySticker) {
        switch sticker.type {
        case .image:
            let imageView = UIImageView(image: sticker.image)
            imageView.contentMode = .scaleAspectFit
            imageView.frame.size = CGSize(width: 150, height: 150)
            imageView.center = center
            self.addSubview(imageView)
            addStickerGestures(imageView)
        case .camera:
            addCameraView()
        case .emoji:
            let emojiLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
            emojiLabel.textAlignment = .center
            emojiLabel.text = sticker.emojiText
            emojiLabel.font = UIFont.systemFont(ofSize: 70)
            emojiLabel.center = center
            self.addSubview(emojiLabel)
            addStickerGestures(emojiLabel)
        default:
            break
        }
    }
    
    func addCameraView() {
        let cameraView = CameraView.instanceFromNib()
        self.addSubview(cameraView)
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        // apply constraint
        cameraView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        cameraView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        cameraView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        cameraView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        // set text
        cameraView.setup()
        cameraView.translatesAutoresizingMaskIntoConstraints = true
        cameraView.cameraClick = { image in
            
        }
        self.addStickerGestures(cameraView)
        cameraView.center = self.center
    }
    
    func addStickerGestures(_ view: UIView) {
        view.isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(handleStickerPanGesture(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(handleStickerPinchGesture(_:)))
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self,
                                                          action: #selector(handleStickerRotationGesture(_:)))
        rotationGesture.delegate = self
        view.addGestureRecognizer(rotationGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(handleStickerTapGesture(_:)))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func handleStickerPanGesture(_ recognizer: UIPanGestureRecognizer) {
        guard !isTyping else {
            return
        }
        if let view = recognizer.view {
            if view is UIImageView {
                // Tap only on visible parts on the image
                if recognizer.state == .began {
                    for imageView in subImageViews(view: self) {
                        let location = recognizer.location(in: imageView)
                        let alpha = imageView.alphaAtPoint(location)
                        if alpha > 0 {
                            imageViewToPan = imageView
                            break
                        }
                    }
                }
                if imageViewToPan != nil {
                    moveView(view: imageViewToPan!, recognizer: recognizer)
                }
            } else {
                moveView(view: view, recognizer: recognizer)
            }
        }
    }
    
    func moveView(view: UIView, recognizer: UIPanGestureRecognizer) {
        guard let superView = self.superview else {
            return
        }
        deleteView?.isHidden = false
        
        view.superview?.bringSubviewToFront(view)
        let pointToSuperView = recognizer.location(in: superView)
        
        view.center = CGPoint(x: view.center.x + recognizer.translation(in: self).x,
                              y: view.center.y + recognizer.translation(in: self).y)
        
        recognizer.setTranslation(.zero, in: self)
        
        if let previousPoint = lastPanPoint {
            // View is going into deleteView
            if (deleteView?.frame.contains(pointToSuperView) ?? false),
                !(deleteView?.frame.contains(previousPoint) ?? false) {
                if #available(iOS 10.0, *) {
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                }
                UIView.animate(withDuration: 0.3, animations: {
                    self.deleteView?.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                    view.transform = view.transform.scaledBy(x: 0.5, y: 0.5)
                    view.center = recognizer.location(in: self)
                })
            }
                // View is going out of deleteView
            else if (deleteView?.frame.contains(previousPoint) ?? false),
                !(deleteView?.frame.contains(pointToSuperView) ?? false) {
                // Scale to original Size
                UIView.animate(withDuration: 0.3, animations: {
                    self.deleteView?.transform = CGAffineTransform(scaleX: 1, y: 1)
                    view.transform = view.transform.scaledBy(x: 2, y: 2)
                    view.center = recognizer.location(in: self)
                })
            }
        }
        lastPanPoint = pointToSuperView
        
        if recognizer.state == .ended {
            imageViewToPan = nil
            lastPanPoint = nil
            let point = recognizer.location(in: superview)
            
            if deleteView?.frame.contains(point) ?? false { // Delete the view
                view.removeFromSuperview()
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                self.deleteView?.transform = CGAffineTransform(scaleX: 1, y: 1)
            } else if !bounds.contains(view.center) { // Snap the view back to canvasImageView
                UIView.animate(withDuration: 0.3, animations: {
                    view.center = self.center
                })
            }   
        }
    }
    
    @objc func handleStickerPinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        guard !isTyping else {
            return
        }
        if let view = recognizer.view {
            if let textView = view as? UITextView {
                
                textView.transform = textView.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            } else {
                view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            }
            recognizer.scale = 1
        }
    }
    
    @objc func handleStickerRotationGesture(_ recognizer: UIRotationGestureRecognizer) {
        guard !isTyping else {
            return
        }
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    @objc func handleStickerTapGesture(_ recognizer: UITapGestureRecognizer) {
        guard !isTyping else {
            return
        }
        if let view = recognizer.view {
            if view is UIImageView {
                // Tap only on visible parts on the image
                for imageView in subImageViews(view: self) {
                    let location = recognizer.location(in: imageView)
                    let alpha = imageView.alphaAtPoint(location)
                    if alpha > 0 {
                        scaleEffect(view: imageView)
                        break
                    }
                }
            } else {
                scaleEffect(view: view)
            }
        }
    }
    
    func subImageViews(view: UIView) -> [UIImageView] {
        var imageviews: [UIImageView] = []
        for imageView in view.subviews {
            if let imgView = imageView as? UIImageView {
                imageviews.append(imgView)
            }
        }
        return imageviews
    }
    
    func scaleEffect(view: UIView) {
        view.superview?.bringSubviewToFront(view)
        
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        let previouTransform = view.transform
        UIView.animate(withDuration: 0.2,
                       animations: {
                        view.transform = view.transform.scaledBy(x: 1.2, y: 1.2)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.2) {
                            view.transform  = previouTransform
                        }
        })
    }
    
}
// MARK: UIGestureRecognizerDelegate
extension StoryEditorView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
}