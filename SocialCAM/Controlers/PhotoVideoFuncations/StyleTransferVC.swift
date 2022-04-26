//
//  ViewController.swift
//  StyleTrasfer
//
//  Created by Jasmin Patel on 30/04/19.
//  Copyright © 2019 Simform. All rights reserved.
//

import UIKit
import CoreML
import SCRecorder
import InfiniteLayout

enum StyleTransferType {
    case image(image: UIImage)
    case video(videoSegments: [SegmentVideos], index: Int)
}

class StyleCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var lblFilterNumber: UILabel!
    @IBOutlet weak var styleImageView: UIImageView!
}

extension StyleTransferVC: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UILongPressGestureRecognizer {
            return true
        } else {
            return false
        }
    }
}

class StyleTransferVC: UIViewController, CollageMakerVCDelegate {
    
    @IBOutlet weak var collectionView: InfiniteCollectionView!
    var cameraMode: CameraMode = .basicCamera
    var indexOfPic = 0
    var dragAndDropManager: KDDragAndDropManager?
    @IBOutlet weak var btnSlideShow: UIButton!
    @IBOutlet weak var btnCollage: UIButton!
    @IBOutlet weak var btnDropDown: UIButton!
    @IBOutlet weak var btnAddImage: UIButton!
    @IBOutlet weak var btnDownload: UIButton! {
        didSet {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
            longPressGesture.minimumPressDuration = 0.5
            btnDownload.addGestureRecognizer(longPressGesture)
        }
    }

    var isShowHideMode: Bool = false {
        didSet {
            btnDropDown.isHidden = isShowHideMode
            btnSlideShow.isHidden = !isShowHideMode
            btnCollage.isHidden = !isShowHideMode
        }
    }
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var videoView: MLVideoView!
    
    @IBOutlet weak var filterImageView: UIImageView! {
        didSet {
            filterImageView.isUserInteractionEnabled = true
            filterImageView.clipsToBounds = true
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressOnImageView(_:)))
            longPressGesture.minimumPressDuration = 0.1
            filterImageView.addGestureRecognizer(longPressGesture)
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = CGSize.init(width: UIScreen.width*43, height: scrollView.frame.height)
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressOnImageView(_:)))
            longPressGesture.minimumPressDuration = 0.1
            scrollView.addGestureRecognizer(longPressGesture)
        }
    }
    
    // Gesture recognizers
    fileprivate var pinchRecognizer: UIPinchGestureRecognizer?
    fileprivate var rotationRecognizer: UIRotationGestureRecognizer?
    fileprivate var panRecognizer: UIPanGestureRecognizer?
    fileprivate var referenceCenter: CGPoint = .zero
    
    var isZooming = false {
        didSet {
            scrollView.isScrollEnabled = !isZooming
        }
    }
    
    var infiniteScrollingBehaviour: InfiniteScrollingBehaviour!

    func addGestureRecognizers() {
        pinchRecognizer = UIPinchGestureRecognizer(target: self,
                                                   action: #selector(handlePinchOrRotate(gesture:)))
        
        rotationRecognizer = UIRotationGestureRecognizer(target: self,
                                                         action: #selector(handlePinchOrRotate(gesture:)))
        panRecognizer = UIPanGestureRecognizer(target: self,
                                               action: #selector(handlePan(gesture:)))
        
        let gestures: [UIGestureRecognizer] = [
            pinchRecognizer!,
            rotationRecognizer!,
            panRecognizer!
        ]
        gestures.forEach {
            $0.delegate = self
            scrollView.addGestureRecognizer($0)
        }
    }
    
    /// Tells the DrawTextView to handle a pan gesture.
    ///
    /// - Parameter gesture: The pan gesture recognizer to handle.
    /// - Note: This method is triggered by the DrawDrawController's internal pan gesture recognizer.
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        if !isZooming {
            return
        }
        switch (gesture.state) {
        case .began:
            referenceCenter = filterImageView.center
        case .changed:
            let panTranslation = gesture.translation(in: self.view)
            filterImageView.center = CGPoint(x: referenceCenter.x + panTranslation.x,
                                             y: referenceCenter.y + panTranslation.y)
        case .ended:
            referenceCenter = filterImageView.center
        default: break
        }
    }
    
    @objc func handlePinchOrRotate(gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .began:
            self.isZooming = true
        case .changed:
            break
        case .ended, .failed, .cancelled:
            self.isZooming = false
        case .possible:
            break
        @unknown default:
            break
        }
        if let gesture = gesture as? UIRotationGestureRecognizer {
            filterImageView.transform = filterImageView.transform.rotated(by: gesture.rotation)
            gesture.rotation = 0
        }
        if let gesture = gesture as? UIPinchGestureRecognizer {
            filterImageView.transform = filterImageView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            gesture.scale = 1
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var transparentActivityView: UIView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    public var selectedItemArray: [SegmentVideos] = [] {
        didSet {
            if selectedItemArray.count >= 2 {
                isShowHideMode = true
            } else {
                isShowHideMode = false
            }
        }
    }
    let numberOfStyles: NSNumber = NSNumber(value: 43)
    
    var styleData: [StyleData] = StyleData.data
    var orignalImage: UIImage?
    var filteredImage: UIImage?
    var selectedFilterIndexPath: IndexPath = IndexPath.init(row: 0, section: 0)
    
    var selectedIndex = -1
    
    var isProcessing: Bool = false {
        didSet {
            activityIndicator.isHidden = !isProcessing
            transparentActivityView.isHidden = !isProcessing
            isProcessing ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        }
    }
    
    public var isSingleImage: Bool = false
    
    var doneHandler: ((Any, Int) -> Void)?
    
    var type: StyleTransferType = .image(image: UIImage())
    
    var coreMLExporter = CoreMLExporter()
    
    var isPic2ArtApp: Bool = false
    
    deinit {
        print("Deinit \(self.description)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
        setupLayout()
        addGestureRecognizers()
        if isSingleImage {
            btnAddImage.isHidden = true
        }
        if cameraMode == .pic2Art {
            btnAddImage.isHidden = true
        }
    }
        
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !self.videoView.isHidden {
            removeObserveState()
        }
    }
    
    fileprivate func setupLayout() {
        self.dragAndDropManager = KDDragAndDropManager(
            canvas: self.view,
            collectionViews: [imageCollectionView]
        )
        
        let imageCollectionViewLayout = self.imageCollectionView.collectionViewLayout as? UPCarouselFlowLayout
        imageCollectionViewLayout?.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: 0.1)
        imageCollectionView.register(R.nib.imageCollectionViewCell)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.videoView.isHidden {
            observeState()
            self.videoView.player.pause()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.videoView.player.play()
            }
        }
    }
    
    func observeState() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.enterBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.enterForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func removeObserveState() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func enterBackground(_ notifi: Notification) {
        videoView.player.pause()
    }
    
    @objc func enterForeground(_ notifi: Notification) {
        videoView.player.play()
    }
    
    @objc func onLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
            selectedItemArray.count > 0 else {
                return
        }
        switch type {
        case .image:
            let group = DispatchGroup()
            for item in selectedItemArray {
                group.enter()
                if let url = item.url,
                    let imageData = try? Data(contentsOf: url),
                    let image = UIImage(data: imageData) {
                    SCAlbum.shared.save(image: image) { (isSuccess) in
                        group.leave()
                    }
                }
            }
            group.notify(queue: .main) {
                let photoText = (self.selectedItemArray.count == 1) ? "photo" : "photos"
                let message = "\(self.selectedItemArray.count) \(photoText) saved"
                self.view.makeToast(message, duration: 2.0, position: .bottom)
            }
        case .video:
            break
        }
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        DispatchQueue.main.async {
            if !self.videoView.isHidden {
                self.videoView.stop()
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnShowHide(_ sender: UIButton) {
        switch type {
        case .image:
            if let filterImage = filteredImage {
                if isPic2ArtApp {
                    self.didSelectImage(image: filterImage)
                } else {
                    self.doneHandler?(filterImage, sender.tag)
                    self.navigationController?.popViewController(animated: false)
                }
            }
        case .video:
            saveImage(sender)
        }
    }
    
    func didSelectSlideShow(images: [SegmentVideos]) {
        var slideShowImages: [UIImage] = []
        for segment in images {
            slideShowImages.append(segment.image ?? UIImage())
        }
        guard slideShowImages.count > 2 else {
            self.showAlert(alertMessage: R.string.localizable.minimumThreeImagesRequiredForSlideshowVideo())
            return
        }
        self.openPhotoEditorForImage(slideShowImages, isSlideShow: true)
    }
    
    func didSelectCollage(images: [SegmentVideos]) {
        DispatchQueue.main.async {
            if let collageMakerVC = R.storyboard.collageMaker.collageMakerVC() {
                collageMakerVC.assets = images
                collageMakerVC.delegate = self
                self.navigationController?.pushViewController(collageMakerVC, animated: true)
            }
        }
    }
    
    func didSelectImage(image: UIImage) {
        self.openPhotoEditorForImage([image])
    }
    
    func openPhotoEditorForImage(_ image: [UIImage], isSlideShow: Bool = false) {
        let photoEditor = openStoryEditor(images: image, isSlideShow: isSlideShow)
        if isPic2ArtApp {
            self.navigationController?.pushViewController(photoEditor, animated: true)
        } else {
            if let navController = self.navigationController {
                let newVC = photoEditor
                var stack = navController.viewControllers
                stack.remove(at: stack.count - 1)
                stack.remove(at: stack.count - 1)
                stack.insert(newVC, at: stack.count)
                navController.setViewControllers(stack, animated: false)
            }
        }
    }
    
    func openStoryEditor(images: [UIImage], isSlideShow: Bool = false) -> StoryEditorViewController {
        guard let storyEditorViewController = R.storyboard.storyEditor.storyEditorViewController() else {
            fatalError("PhotoEditorViewController Not Found")
        }
        var medias: [StoryEditorMedia] = []
        for image in images {
            medias.append(StoryEditorMedia(type: .image(image)))
        }
        storyEditorViewController.isBoomerang = false
        storyEditorViewController.medias = medias
        storyEditorViewController.isSlideShow = isSlideShow
        storyEditorViewController.cameraMode = cameraMode
        return storyEditorViewController
    }
    
    @IBAction func saveImage(_ sender: UIButton) {
        switch type {
        case .image:
            if selectedItemArray.count >= 1 {
                if sender.tag == 1 {
                    self.didSelectSlideShow(images: selectedItemArray)
                } else {
                    self.didSelectCollage(images: selectedItemArray)
                    return
                }
            } else {
                if let filterImage = filteredImage {
                    if isPic2ArtApp {
                        self.didSelectImage(image: filterImage)
                    } else {
                        self.doneHandler?(filterImage, sender.tag)
                    }
                }
            }
            if !isPic2ArtApp {
                self.navigationController?.popViewController(animated: false)
            }
        case .video(let videoSegments, let index):
            let mergeSession = SCRecordSession()
            for segementModel in videoSegments[index].videos {
                let segment = SCRecordSessionSegment(url: segementModel.url!, info: nil)
                mergeSession.addSegment(segment)
            }
            videoView.player.pause()
            let loadingView = LoadingView.instanceFromNib()
            loadingView.shouldDescriptionTextShow = true
            loadingView.show(on: view, completion: {
                loadingView.cancelClick = { [weak self] _ in
                    guard let `self` = self else { return }
                    self.cancelExporting(UIButton())
                    loadingView.hide()
                }
            })
            
            coreMLExporter.exportVideo(for: mergeSession.assetRepresentingSegments(), and: selectedIndex, progress: { progress in
                DispatchQueue.main.async {
                    loadingView.progressView.setProgress(to: Double(progress), withAnimation: true)
                }
            }, completion: { exportedURL in
                if let url = exportedURL {
                    DispatchQueue.main.async {
                        self.videoView.stop()
                        loadingView.hide()
                    }
                    var updatedSegments = videoSegments
                    let updatedSegment = SegmentVideos(urlStr: url,
                                                       thumbimage: videoSegments[index].image,
                                                       latitued: nil,
                                                       longitued: nil,
                                                       placeAddress: nil,
                                                       numberOfSegement: videoSegments[index].numberOfSegementtext,
                                                       videoduration: nil,
                                                       combineOneVideo: true)
                    updatedSegments.remove(at: index)
                    updatedSegments.insert(updatedSegment, at: index)
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                        self.doneHandler?(updatedSegments, sender.tag)
                    }
                }
            })
        }
    }
    
    @IBAction func addImageClick(_ sender: Any) {
        if let filterImage = filteredImage {
            
            let fileName = String.fileName + FileExtension.png.rawValue
            let data = filterImage.pngData()
            let destinationImageURL = Utils.getLocalPath(fileName)
            try? data?.write(to: destinationImageURL)
            
            selectedItemArray.append(SegmentVideos(urlStr: destinationImageURL, thumbimage: filteredImage, latitued: nil, longitued: nil, placeAddress: nil, numberOfSegement: "\(self.selectedItemArray.count + 1)", videoduration: nil))
            self.imageCollectionView.reloadData()
        }
    }
    
    @IBAction func downloadImage(_ sender: Any) {
        switch type {
        case .image:
            if let image = filteredImage {
                SCAlbum.shared.save(image: image) { (isSuccess) in
                    if isSuccess {
                        DispatchQueue.main.async {
                            self.view.makeToast(R.string.localizable.photoSaved(), duration: 2.0, position: .bottom)
                        }
                    } else {
                        self.view.makeToast(R.string.localizable.pleaseGivePhotosAccessFromSettingsToSaveShareImageOrVideo())
                    }
                }
            }
        case .video(let videoSegments, let index):
            let mergeSession = SCRecordSession()
            for segementModel in videoSegments[index].videos {
                let segment = SCRecordSessionSegment(url: segementModel.url!, info: nil)
                mergeSession.addSegment(segment)
            }
            videoView.player.pause()
            let loadingView = LoadingView.instanceFromNib()
            loadingView.shouldDescriptionTextShow = true
            loadingView.show(on: view, completion: {
                loadingView.cancelClick = { [weak self] _ in
                    guard let `self` = self else { return }
                    self.cancelExporting(UIButton())
                    loadingView.hide()
                }
            })
            
            coreMLExporter.exportVideo(for: mergeSession.assetRepresentingSegments(), and: selectedIndex, progress: { progress in
                DispatchQueue.main.async {
                    loadingView.progressView.setProgress(to: Double(progress), withAnimation: true)
                }
            }, completion: { exportedURL in
                if let url = exportedURL {
                    DispatchQueue.main.async {
                        self.videoView.player.play()
                        loadingView.hide()
                    }
                    SCAlbum.shared.saveMovieToLibrary(movieURL: url) { (isSuccess) in
                        if isSuccess {
                            DispatchQueue.main.async {
                                self.view.makeToast(R.string.localizable.videoSaved())
                            }
                        } else {
                            self.view.makeToast(R.string.localizable.pleaseGivePhotosAccessFromSettingsToSaveShareImageOrVideo())
                        }
                    }
                }
            })
        }
    }
    
    @IBAction func cancelExporting(_ sender: Any) {
        DispatchQueue.main.async {
            self.videoView.player.play()
        }
        coreMLExporter.cancelExporting()
    }
    
    @objc func handleLongPressOnImageView(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began || gesture.state == .changed {
            removeFilter()
        } else {
            applyFilter()
        }
    }
    
    @objc func handleLongPressOnFilterImageView(_ gesture: UILongPressGestureRecognizer) {
//        Defaults.shared.callHapticFeedback(isHeavy: false)
        if gesture.state == .began {
            selectedFilterIndexPath = IndexPath.init(row: gesture.view!.tag, section: 0)
            type = .image(image: filteredImage!)
            self.applyStyle(index: gesture.view!.tag)
            styleData[selectedFilterIndexPath.row].isSelected = true
            self.collectionView.reloadData()
            applyFilter()
        }
    }
    
    func removeFilter() {
        type = .image(image: orignalImage!)
        switch type {
        case .image(let image):
            filterImageView.image = image
        default:
            break
        }
    }
    
    func applyFilter() {
        filterImageView.image = filteredImage
    }
    
    func setData() {
        isShowHideMode = false
        selectedIndex = 0
        self.styleData[selectedIndex].isSelected = true
        switch type {
        case .image(let image):
            videoView.isHidden = true
            let size = scaledSize(size: image.size)
            let rect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
            UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
            image.draw(in: rect)
            guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return }
            UIGraphicsEndImageContext()
            filteredImage = newImage
            type = .image(image: newImage)
            filterImageView.image = newImage
            orignalImage = newImage
            self.applyStyle(index: selectedIndex)
        case .video(let videoSegments, let index):
            btnAddImage.isHidden = true
            btnDropDown.setImage(R.image.rightIconSetting(), for: UIControl.State())
            btnDropDown.tag = 2
            let mergeSession = SCRecordSession()
            for segementModel in videoSegments[index].videos {
                let segment = SCRecordSessionSegment(url: segementModel.url!, info: nil)
                mergeSession.addSegment(segment)
            }
            videoView.play(asset: mergeSession.assetRepresentingSegments())
        }
        selectedItemArray = []
    }
    
    func scaledSize(size: CGSize) -> CGSize {
        var scale: CGFloat = 1.0
        
        if size.width > size.height {
            if size.width > 1280 {
                scale = 1280/size.width
            }
        } else {
            if size.height > 1280 {
                scale = 1280/size.height
            }
        }
        
        let targetSize = CGSize(width: floor(size.width * scale), height: floor(size.height * scale))
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize.init(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize.init(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        return newSize
    }
    
    func pixelBuffer(from image: UIImage) -> CVPixelBuffer? {
        let maxWidth: CGFloat = image.size.width
        let maxHeight: CGFloat = image.size.height
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: maxWidth, height: maxHeight), true, 2.0)
        image.draw(in: CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight))
        UIGraphicsEndImageContext()
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(maxWidth), Int(maxHeight), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(maxWidth), height: Int(maxHeight), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: maxHeight)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    func applyStyle(index: Int) {
        Defaults.shared.callHapticFeedback(isHeavy: false)
        if #available(iOS 12.0, *) {
            selectedIndex = index
            switch type {
            case .image(let image):
                if (selectedIndex % styleData.count) == 0 {
                    self.filteredImage = image
                    self.applyFilter()
                    return
                }
                guard !self.isProcessing else {
                    return
                }
                DispatchQueue.main.async {
                    self.isProcessing = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let model = StyleTransferModel43()
                    do {
                        let styles = try MLMultiArray(shape: [self.numberOfStyles],
                                                      dataType: .double)
                        for index in 0..<styles.count {
                            styles[index] = 0.0
                        }
                        styles[(self.selectedIndex % self.styleData.count) - 1] = 1.0
                        if let image = self.pixelBuffer(from: image) {
                            do {
                                let predictionOutput = try model.prediction(image: image, index: styles)
                                let ciImage = CIImage(cvPixelBuffer: predictionOutput.stylizedImage)
                                let tempContext = CIContext(options: nil)
                                let tempImage = tempContext.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(predictionOutput.stylizedImage), height: CVPixelBufferGetHeight(predictionOutput.stylizedImage)))
                                self.filteredImage = UIImage(cgImage: tempImage!)
                                self.applyFilter()
                            } catch let error as NSError {
                                print("CoreML Model Error: \(error)")
                            }
                        }
                    } catch let error as NSError {
                        print("CoreML Model Error: \(error)")
                    }
                    self.isProcessing = false
                }
            case .video:
                videoView.selectedIndex = selectedIndex % styleData.count
            }
        }
    }
    
}

extension StyleTransferVC: UIScrollViewDelegate {
    
    func multiplier(estimatedItemSize: CGSize, enabled: Bool) -> Int {
        guard enabled else {
            return 1
        }
        let min = Swift.min(estimatedItemSize.width, estimatedItemSize.height)
        let count = ceil((max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 4) / min)
        return Int(count)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let totalCells = self.styleData.count * self.multiplier(estimatedItemSize: collectionView.infiniteLayout.itemSize, enabled: collectionView.infiniteLayout.isEnabled)
            if scrollView.panGestureRecognizer.translation(in: scrollView.superview).x > 0 {
                selectedIndex = selectedIndex == 0 ? totalCells - 1 : selectedIndex - 1
            } else {
                selectedIndex = selectedIndex == totalCells - 1 ? 0 : selectedIndex + 1
            }
            guard !self.isProcessing else {
                return
            }
            for (index, style) in self.styleData.enumerated() {
                style.isSelected = (index == selectedIndex)
            }
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: IndexPath(row: selectedIndex, section: 0),
                                             at: .centeredHorizontally,
                                             animated: true)
            self.applyStyle(index: selectedIndex)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let index = collectionView!.indexPathForItem(at: visiblePoint)
        if indexOfPic != index?.row ?? 0 {
            indexOfPic = index?.row ?? 0
//            Defaults.shared.callHapticFeedback(isHeavy: false)
        }
    }
}

extension StyleTransferVC: KDDragAndDropCollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, indexPathForDataItem dataItem: AnyObject) -> IndexPath? {
        guard let candidate = dataItem as? SegmentVideos else { return nil }

        for (index, item) in selectedItemArray.enumerated() {
            if candidate.id != item.id {
                continue
            }
            return IndexPath(item: index, section: 0)
        }

        return nil
    }

    func collectionView(_ collectionView: UICollectionView, dataItemForIndexPath indexPath: IndexPath) -> AnyObject {
        return selectedItemArray[indexPath.item]
    }

    func collectionView(_ collectionView: UICollectionView, deleteDataItemAtIndexPath indexPath: IndexPath) {

    }

    func collectionView(_ collectionView: UICollectionView, moveDataItemFromIndexPath from: IndexPath, toIndexPath to: IndexPath) {

    }

    func collectionView(_ collectionView: UICollectionView, insertDataItem dataItem: AnyObject, atIndexPath indexPath: IndexPath) {

    }

    func collectionView(_ collectionView: UICollectionView, cellIsDraggableAtIndexPath indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionViewEdgesAndScroll(_ collectionView: UICollectionView, rect: CGRect) {

    }

    func collectionViewLastEdgesAndScroll(_ collectionView: UICollectionView, rect: CGRect) {
        let newrect = rect.origin.y + collectionView.frame.origin.y
        let newrectData = CGRect.init(x: rect.origin.x, y: newrect, width: rect.width, height: rect.height)

        let checkframeDelete = CGRect(x: collectionView.frame.origin.x, y: collectionView.frame.origin.y, width: collectionView.frame.width, height: collectionView.frame.height)

        if !checkframeDelete.intersects(newrectData) {
            if let kdCollectionView = collectionView as? KDDragAndDropCollectionView {
                if let draggingPathOfCellBeingDragged = kdCollectionView.draggingPathOfCellBeingDragged {
                    selectedItemArray.remove(at: draggingPathOfCellBeingDragged.row)
                    self.collectionView.reloadData()
                }
            }
        }
    }

}

extension StyleTransferVC: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            return styleData.count
        } else if collectionView.tag == 2 {
            return selectedItemArray.count
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.imageCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.imageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell else {
                return UICollectionViewCell()
            }

            let borderColor: CGColor! = ApplicationSettings.appBlackColor.cgColor
            let borderWidth: CGFloat = 3

            cell.imagesStackView.tag = indexPath.row

            var images = [SegmentVideos]()

            images = [selectedItemArray[indexPath.row]]

            let views = cell.imagesStackView.subviews
            for view in views {
                cell.imagesStackView.removeArrangedSubview(view)
            }

            cell.lblSegmentCount.text = String(indexPath.row + 1)

            for imageName in images {
                let mainView = UIView.init(frame: CGRect(x: 0, y: 3, width: 41, height: 52))

                let imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 41, height: 52))
                imageView.image = imageName.image
                imageView.contentMode = .scaleToFill
                imageView.clipsToBounds = true
                mainView.addSubview(imageView)
                cell.imagesStackView.addArrangedSubview(mainView)
            }

            cell.imagesView.layer.cornerRadius = 5
            cell.imagesView.layer.borderWidth = borderWidth
            cell.imagesView.layer.borderColor = borderColor

            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.styleCollectionViewCell, for: indexPath) else {
                return UICollectionViewCell()
            }
            cell.styleImageView.image = styleData[indexPath.row % styleData.count].image
            cell.tag = indexPath.row % styleData.count
            cell.lblFilterNumber.text = "\(Int(indexPath.row % styleData.count) + 1)"
            let borderWidth: CGFloat = styleData[indexPath.row % styleData.count].isSelected ? 2.0 : 0.0
            cell.styleImageView.layer.borderWidth = borderWidth
            switch type {
            case .image:
                let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressOnFilterImageView(_:)))
                longPressGesture.minimumPressDuration = 0.2
                cell.addGestureRecognizer(longPressGesture)
            default:
                break
            }
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        Defaults.shared.callHapticFeedback(isHeavy: false)
        guard indexPath.row != selectedIndex, !self.isProcessing, collectionView != self.imageCollectionView else {
            return
        }
        switch type {
        case .image:
            type = .image(image: orignalImage!)
        case .video:
            break
        }

        for (index, style) in self.styleData.enumerated() {
            style.isSelected = (index == (indexPath.row % styleData.count))
        }
        collectionView.reloadData()
        let xScrollOffset = CGFloat(indexPath.row)*UIScreen.width
        self.scrollView.setContentOffset(CGPoint(x: xScrollOffset, y: 0),
                                         animated: false)
        self.applyStyle(index: indexPath.row)
    }
}

