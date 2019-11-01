//
//  PhotosPickerViewController.swift
//  ProManager
//
//  Created by Viraj Patel on 13/06/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import MobileCoreServices

struct AssetsCollection {
    var phAssetCollection: PHAssetCollection? = nil
    var fetchResult: PHFetchResult<PHAsset>? = nil
    var useCameraButton: Bool = false
    var recentPosition: CGPoint = CGPoint.zero
    var title: String
    var localIdentifier: String
    var count: Int {
        get {
            guard let count = self.fetchResult?.count, count > 0 else { return self.useCameraButton ? 1 : 0 }
            return count + (self.useCameraButton ? 1 : 0)
        }
    }
    
    init(collection: PHAssetCollection) {
        self.phAssetCollection = collection
        self.title = collection.localizedTitle ?? ""
        self.localIdentifier = collection.localIdentifier
    }
    
    func getAsset(at index: Int) -> PHAsset? {
        if self.useCameraButton && index == 0 { return nil }
        let index = index - (self.useCameraButton ? 1 : 0)
        guard let result = self.fetchResult, index < result.count else { return nil }
        return result.object(at: max(index,0))
    }
    
    func getTLAsset(at index: Int) -> ImageAsset? {
        if self.useCameraButton && index == 0 { return nil }
        let index = index - (self.useCameraButton ? 1 : 0)
        guard let result = self.fetchResult, index < result.count else { return nil }
        return ImageAsset(asset: result.object(at: max(index,0)))
    }
    
    func getAssets(at range: CountableClosedRange<Int>) -> [PHAsset]? {
        let lowerBound = range.lowerBound - (self.useCameraButton ? 1 : 0)
        let upperBound = range.upperBound - (self.useCameraButton ? 1 : 0)
        return self.fetchResult?.objects(at: IndexSet(integersIn: max(lowerBound,0)...min(upperBound,count)))
    }
    
    static func ==(lhs: AssetsCollection, rhs: AssetsCollection) -> Bool {
        return lhs.localIdentifier == rhs.localIdentifier
    }
}

public protocol PhotosPickerViewControllerDelegate: class {
    func dismissPhotoPicker(withPHAssets: [ImageAsset])
    func dismissPhotoPicker(withTLPHAssets: [ImageAsset])
    func dismissComplete()
    func photoPickerDidCancel()
    func canSelectAsset(phAsset: PHAsset) -> Bool
    func didExceedMaximumNumberOfSelection(picker: PhotosPickerViewController)
    func handleNoAlbumPermissions(picker: PhotosPickerViewController)
    func handleNoCameraPermissions(picker: PhotosPickerViewController)
    func selectAlbum(collection: PHAssetCollection)
    func albumViewCameraRollUnauthorized()
    func albumViewCameraRollAuthorized()
}

extension PhotosPickerViewControllerDelegate {
    public func deninedAuthoization() { }
    public func dismissPhotoPicker(withPHAssets: [ImageAsset]) { }
    public func dismissPhotoPicker(withTLPHAssets: [ImageAsset]) { }
    public func dismissComplete() { }
    public func photoPickerDidCancel() { }
    public func canSelectAsset(phAsset: PHAsset) -> Bool { return true }
    public func didExceedMaximumNumberOfSelection(picker: PhotosPickerViewController) { }
    public func handleNoAlbumPermissions(picker: PhotosPickerViewController) { }
    public func handleNoCameraPermissions(picker: PhotosPickerViewController) { }
    public func selectAlbum(collection: PHAssetCollection) { }
    public func albumViewCameraRollUnauthorized() { }
    public func albumViewCameraRollAuthorized() { }

}

//for log
public protocol PhotosPickerLogDelegate: class {
    func selectedCameraCell(picker: PhotosPickerViewController)
    func deselectedPhoto(picker: PhotosPickerViewController, at: Int)
    func selectedPhoto(picker: PhotosPickerViewController, at: Int)
    func selectedAlbum(picker: PhotosPickerViewController, title: String, at: Int)
}

extension PhotosPickerLogDelegate {
    func selectedCameraCell(picker: PhotosPickerViewController) { }
    func deselectedPhoto(picker: PhotosPickerViewController, at: Int) { }
    func selectedPhoto(picker: PhotosPickerViewController, at: Int) { }
    func selectedAlbum(picker: PhotosPickerViewController, collections: [AssetsCollection], at: Int) { }
}


public struct PhotosPickerConfigure {
    public var defaultCameraRollTitle = "Camera Roll"
    public var tapHereToChange = "Tap here to change"
    public var cancelTitle = "Cancel"
    public var doneTitle = "Done"
    public var emptyMessage = "No albums"
    public var emptyImage: UIImage? = #imageLiteral(resourceName: "uploadStory")
    public var usedCameraButton = false
    public var usedPrefetch = true
    public var allowedLivePhotos = false
    public var allowedVideo = false
    public var allowedVideoRecording = false
    public var recordingVideoQuality: UIImagePickerController.QualityType = .typeMedium
    public var maxVideoDuration: TimeInterval? = nil
    public var autoPlay = false
    public var muteAudio = true
    public var mediaType: PHAssetMediaType? = nil
    public var numberOfColumn = 3
    public var singleSelectedMode = true
    public var maxSelectedAssets: Int? = nil
    public var fetchOption: PHFetchOptions? = nil
    public var selectedRedColor = UIColor.red
    public var selectedColor = UIColor(red: 88 / 255, green: 144 / 255, blue: 255 / 255, alpha: 1.0)
    public var cameraBgColor = UIColor(red: 221 / 255, green: 223 / 255, blue: 226 / 255, alpha: 1)
    public var cameraIcon = #imageLiteral(resourceName: "icoCamara")
    public var videoIcon = #imageLiteral(resourceName: "video_icon")
    public var placeholderIcon = UIImage()
    public var nibSet: (nibName: String, bundle: Bundle)? = nil
    public var cameraCellNibSet: (nibName: String, bundle: Bundle)? = nil
    public init() {

    }
}

extension PhotosPickerViewController: DropdownControllerDelegate {

    func dropdownController(_ controller: DropdownController, didSelect album: ImageAlbum) {
        selectedAlbum = album
        show(album: album)

        dropdownController.toggle()
        arrowButton.toggle(controller.expanding)
        arrowButton.updateText(album.collection.localizedTitle ?? "")
    }
}

open class PhotosPickerViewController: UIViewController {

    @IBOutlet weak var topNavigationBarView: UINavigationBar!
    @IBOutlet open var titleView: UIView!
    @IBOutlet open var titleLabel: UILabel!
    @IBOutlet open var subTitleStackView: UIStackView!
    @IBOutlet open var subTitleLabel: UILabel!
    @IBOutlet open var collectionView: UICollectionView!
    @IBOutlet open var indicator: UIActivityIndicatorView!

    @IBOutlet open var customNavItem: UINavigationItem!
    @IBOutlet open var doneButton: UIBarButtonItem!
    @IBOutlet open var cancelButton: UIBarButtonItem!
    @IBOutlet open var navigationBarTopConstraint: NSLayoutConstraint!
    @IBOutlet open var emptyView: UIView!
    @IBOutlet open var emptyImageView: UIImageView!
    @IBOutlet open var emptyMessageLabel: UILabel!
    open var onlyCellUIChange: Bool = false
    public weak var delegate: PhotosPickerViewControllerDelegate? = nil
    public weak var logDelegate: PhotosPickerLogDelegate? = nil
    public var configure = PhotosPickerConfigure()

    var items: [ImageAsset] = []
    let library = ImagesLibrary()
    var selectedAlbum: ImageAlbum?
    let once = Once()
    var allAlbums: [ImageAlbum] = []
    var currentCamaraMode: CameraMode = .normal
    var isAllPhotos = false

    var selectionType: AssetType = .image
    
    fileprivate var images: [ImageAsset] = []
    fileprivate var imageManager: PHCachingImageManager?
    fileprivate var previousPreheatRect: CGRect = .zero
    fileprivate let cellSize = CGSize(width: 100, height: 100)

    public var selectedAssets: [ImageAsset] = []
    lazy var arrowButton: ArrowButton = self.makeArrowButton()
    lazy var dropdownController: DropdownController = self.makeDropdownController()

    private func makeArrowButton() -> ArrowButton {
        let button = ArrowButton()
        button.layoutSubviews()

        return button
    }

    func makeDropdownController() -> DropdownController {
        let controller = DropdownController()
        controller.delegate = self

        return controller
    }

    fileprivate var usedCameraButton: Bool {
        get {
            return self.configure.usedCameraButton
        }
    }
    fileprivate var allowedVideo: Bool {
        get {
            return self.configure.allowedVideo
        }
    }
    fileprivate var usedPrefetch: Bool {
        get {
            return self.configure.usedPrefetch
        }
        set {
            self.configure.usedPrefetch = newValue
        }
    }
    fileprivate var allowedLivePhotos: Bool {
        get {
            return self.configure.allowedLivePhotos
        }
        set {
            self.configure.allowedLivePhotos = newValue
        }
    }
    
    @objc open var canSelectAsset: ((PHAsset) -> Bool)? = nil
    @objc open var didExceedMaximumNumberOfSelection: ((PhotosPickerViewController) -> Void)? = nil
    @objc open var handleNoAlbumPermissions: ((PhotosPickerViewController) -> Void)? = nil
    @objc open var handleNoCameraPermissions: ((PhotosPickerViewController) -> Void)? = nil
    @objc open var dismissCompletion: (() -> Void)? = nil
    fileprivate var completionWithPHAssets: (([PHAsset]) -> Void)? = nil
    fileprivate var completionWithTLPHAssets: (([PHAsset]) -> Void)? = nil
    fileprivate var didCancel: (() -> Void)? = nil
    
    fileprivate var collections = [AssetsCollection]()
    fileprivate var focusedCollection: AssetsCollection? = nil
    
    fileprivate var requestIds = [IndexPath: PHImageRequestID]()
    fileprivate var cloudRequestIds = [IndexPath: PHImageRequestID]()
   
    fileprivate var oldIndexSelected: IndexPath? = nil

    fileprivate var queue = DispatchQueue(label: "tilltue.photos.pikcker.queue")
    fileprivate var thumbnailSize = CGSize.zero
    fileprivate var placeholderThumbnail: UIImage? = nil
    fileprivate var cameraImage: UIImage? = nil

    deinit {
        print("deinit PhotosPickerViewController")

    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init() {
        super.init(nibName: "PhotosPickerViewController", bundle: Bundle(for: PhotosPickerViewController.self))
    }

    @objc convenience public init(withPHAssets: (([PHAsset]) -> Void)? = nil, didCancel: (() -> Void)? = nil) {
        self.init()
        self.completionWithPHAssets = withPHAssets
        self.didCancel = didCancel
    }

    convenience public init(withTLPHAssets: (([PHAsset]) -> Void)? = nil, didCancel: (() -> Void)? = nil) {
        self.init()
        self.completionWithTLPHAssets = withTLPHAssets
        self.didCancel = didCancel
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    func show(album: ImageAlbum) {
        items = album.items
        images = album.items
        collectionView.reloadData()
        collectionView.g_scrollToTop()

        self.delegate?.selectAlbum(collection: album.collection)
    }

    // MARK: - Asset Caching

    func resetCachedAssets() {

        imageManager?.stopCachingImagesForAllAssets()
        previousPreheatRect = CGRect.zero
    }

    func checkAuthorization() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                switch status {
                case .authorized:
                    self?.initPhotoLibrary()
                default:
                    self?.handleDeniedAlbumsAuthorization()
                }
            }
        case .authorized:
            self.initPhotoLibrary()
        case .restricted: fallthrough
        case .denied:
            handleDeniedAlbumsAuthorization()
        @unknown default:
            handleDeniedAlbumsAuthorization()
        }
    }

    fileprivate func handleDeniedAlbumsAuthorization() {
        self.delegate?.handleNoAlbumPermissions(picker: self)
        self.handleNoAlbumPermissions?(self)
    }

    fileprivate func handleDeniedCameraAuthorization() {
        self.delegate?.handleNoCameraPermissions(picker: self)
        self.handleNoCameraPermissions?(self)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        [arrowButton].forEach {
            titleView.addSubview($0)
        }
        arrowButton.g_pinCenter()
        arrowButton.g_pin(height: 50)
        arrowButton.addTarget(self, action: #selector(arrowButtonTouched(_:)), for: .touchUpInside)

        addChild(dropdownController)
        self.view.insertSubview(dropdownController.view, aboveSubview: self.view)
        dropdownController.didMove(toParent: self)

        dropdownController.view.g_pin(on: .left)
        dropdownController.view.g_pin(on: .right)
        var totalHegight: CGFloat = topNavigationBarView.frame.height + 20
        if #available(iOS 11.0, *) {
            if ((UIApplication.shared.keyWindow?.safeAreaInsets.top)! > CGFloat(0.0)) {
                totalHegight = totalHegight + (UIApplication.shared.keyWindow?.safeAreaInsets.top)! + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!
                dropdownController.view.g_pin(on: .height, constant: -totalHegight)
            }
            else
            {
                dropdownController.view.g_pin(on: .height, constant: -totalHegight)
            }
        }
        else {
            dropdownController.view.g_pin(on: .height, constant: -totalHegight)
        }

        dropdownController.expandedTopConstraint = dropdownController.view.g_pin(on: .top, view: topNavigationBarView, on: .bottom, constant: 0)
        dropdownController.expandedTopConstraint?.isActive = false
        dropdownController.collapsedTopConstraint = dropdownController.view.g_pin(on: .top, on: .bottom)

        makeUI()
    }

    @objc func arrowButtonTouched(_ button: ArrowButton) {
        dropdownController.toggle()
        button.toggle(dropdownController.expanding)
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.thumbnailSize == CGSize.zero {
            initItemSize()
        }
        if #available(iOS 11.0, *) {
        } else if self.navigationBarTopConstraint.constant == 0 {
            self.navigationBarTopConstraint.constant = 20
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkAuthorization()
    }
}

// MARK: - UI & UI Action
extension PhotosPickerViewController {

    @objc public func registerNib(nibName: String, bundle: Bundle) {
        self.collectionView.register(UINib(nibName: nibName, bundle: bundle), forCellWithReuseIdentifier: nibName)
    }

    fileprivate func centerAtRect(image: UIImage?, rect: CGRect, bgColor: UIColor = ApplicationSettings.appWhiteColor) -> UIImage? {
        guard let image = image else { return nil }
        UIGraphicsBeginImageContextWithOptions(rect.size, false, image.scale)
        bgColor.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
        image.draw(in: CGRect(x: rect.size.width / 2 - image.size.width / 2, y: rect.size.height / 2 - image.size.height / 2, width: image.size.width, height: image.size.height))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }

    fileprivate func initItemSize() {
        guard let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let count = CGFloat(self.configure.numberOfColumn)
        let width = (self.view.frame.size.width - (5 * (count - 1))) / count
        self.thumbnailSize = CGSize(width: width, height: width)
        layout.itemSize = self.thumbnailSize
        self.collectionView.collectionViewLayout = layout
        self.placeholderThumbnail = centerAtRect(image: self.configure.placeholderIcon, rect: CGRect(x: 0, y: 0, width: width, height: width))
        self.cameraImage = centerAtRect(image: self.configure.cameraIcon, rect: CGRect(x: 0, y: 0, width: width, height: width), bgColor: self.configure.cameraBgColor)
    }

    @objc open func makeUI() {
        registerNib(nibName: "AllPhotosCollectionViewCell", bundle: Bundle(for: AllPhotosCollectionViewCell.self))
        if let nibSet = self.configure.nibSet {
            registerNib(nibName: nibSet.nibName, bundle: nibSet.bundle)
        }
        if let nibSet = self.configure.cameraCellNibSet {
            registerNib(nibName: nibSet.nibName, bundle: nibSet.bundle)
        }
        cancelButton.title = configure.cancelTitle
        doneButton.title = configure.doneTitle
        emptyView.isHidden = true
        emptyImageView.image = configure.emptyImage
        emptyMessageLabel.text = configure.emptyMessage
        titleLabel.text = "                           "
        if #available(iOS 10.0, *), usedPrefetch {
            collectionView.isPrefetchingEnabled = true
            collectionView.prefetchDataSource = self
        } else {
            usedPrefetch = false
        }
        if #available(iOS 9.0, *), allowedLivePhotos {
        } else {
            allowedLivePhotos = false
        }
    }

    fileprivate func initPhotoLibrary() {

        // Check the status of authorization for PHPhotoLibrary
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            self.imageManager = PHCachingImageManager()

            var type: AssetType = .both
            if currentCamaraMode == .slideshow || currentCamaraMode == .collage {
                type = .image
                self.configure.singleSelectedMode = false
                self.configure.maxSelectedAssets = 20
            }
            else if currentCamaraMode == .quizImage {
                type = .image
                self.configure.singleSelectedMode = false
            }
            else if currentCamaraMode == .quizVideo {
                type = .video
                self.configure.singleSelectedMode = false
            } else {
                type = .both
                self.configure.singleSelectedMode = false
            }
            self.once.run {
                self.library.reload(type, {
                    self.allAlbums = self.library.albums
                    if self.selectedAlbum == nil {
                        if let album = self.library.albums.first {
                            self.setAlbums(album)
                        }
                    }

                    self.arrowButton.isHidden = false
                    self.arrowButton.updateText(self.selectedAlbum?.collection.localizedTitle ?? "")

                    self.collectionView.reloadData()
                    self.collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition())
                })
            }

            DispatchQueue.main.async {
                self.delegate?.albumViewCameraRollAuthorized()
            }
        }
    }

    fileprivate func setAlbums(_ album: ImageAlbum) {
        self.selectedAlbum = album
        self.show(album: album)
        self.dropdownController.albums = self.allAlbums
        self.dropdownController.tableView.reloadData()
    }

    // User Action

    @IBAction open func cancelButtonTap() {
        self.dismiss(done: false)
    }

    @IBAction open func doneButtonTap() {
        guard self.selectedAssets.count > 0 else {
            return
        }
        self.dismiss(done: true)
    }

    fileprivate func dismiss(done: Bool) {
        if done {
            if self.selectedAssets.count > 0 {
                doneButton.isEnabled = false
                cancelButton.isEnabled = false
                let exportGroup = DispatchGroup()
                let exportQueue = DispatchQueue(label: "com.queue.videoQueue")
                let dispatchSemaphore = DispatchSemaphore(value: 0)
                
                self.indicator.startAnimating()
                let viewData = LoadingView.instanceFromNib()
                viewData.shouldCancleShow = true
                viewData.loadingViewShow = true
                viewData.show(on: view)
                for (index, assests) in self.selectedAssets.enumerated() {
                    exportGroup.enter()
                    if assests.assetType == .video {
                        exportQueue.async {
                          if let asset = assests.asset {
                            assests.tempCopyMediaFile(asset: asset, convertLivePhotosToJPG: false, progressBlock: { (progress) in
                                print(progress)
                            }, completionBlock: { [weak self] (url, mimeType) in
                                print("completion\(url)")
                                print(mimeType )
                                guard let strongSelf = self else { return }
                                strongSelf.selectedAssets[index].videoUrl = url
                                strongSelf.selectedAssets[index].thumbImage = UIImage.getThumbnailFrom(videoUrl: url) ?? UIImage()
                                
                                dispatchSemaphore.signal()
                                exportGroup.leave()
                                }, failBlock: { _ in
                                    dispatchSemaphore.signal()
                                    exportGroup.leave()
                            })
                            dispatchSemaphore.wait()
                            }
                        }
                    }
                    else {
                        exportQueue.async {
                            if assests.fullResolutionImage != nil {
                                dispatchSemaphore.signal()
                                exportGroup.leave()
                            } else {
                                _ = assests.cloudImageDownload(progressBlock: { (progress) in
                                    DispatchQueue.main.async {
                                        print(progress)
                                    }
                                }, completionBlock: { [weak self] (fullResolutionImage) in
                                    if let image = fullResolutionImage {
                                        //use image
                                        guard let `self` = self else { return }
                                        self.selectedAssets[index].fullResolutionDownloadedImage = image
                                    }
                                    dispatchSemaphore.signal()
                                    exportGroup.leave()
                                })
                                dispatchSemaphore.wait()
                            }
                        }
                    }
                }

                exportGroup.notify(queue: exportQueue) {
                    print("finished Video Select all..")
                    DispatchQueue.main.async {
                        if self.selectedAssets.count != 0 {
                            self.delegate?.dismissPhotoPicker(withTLPHAssets: self.selectedAssets)
                            self.completionWithTLPHAssets?([self.selectedAssets[0].asset])
                            viewData.hide()
                            self.dismiss(animated: false) { [weak self] in
                                guard let strongSelf = self else { return }
                                strongSelf.indicator?.stopAnimating()
                                strongSelf.delegate?.dismissComplete()
                                strongSelf.dismissCompletion?()
                            }
                        } else {
                            self.doneButton.isEnabled = true
                            self.cancelButton.isEnabled = true
                        }
                    }
                }
            }
        } else {
            self.dismiss(animated: false) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.didCancel?()
                strongSelf.delegate?.dismissComplete()
                strongSelf.dismissCompletion?()
            }
        }
    }
    
    fileprivate func maxCheck() -> Bool {
        if self.configure.singleSelectedMode {
            self.selectedAssets.removeAll()
            self.orderUpdateCells()
        }
        if let max = self.configure.maxSelectedAssets, max <= self.selectedAssets.count {
            self.delegate?.didExceedMaximumNumberOfSelection(picker: self)
            self.didExceedMaximumNumberOfSelection?(self)
            return true
        }
        return false
    }
    
    fileprivate func canSelect(phAsset: PHAsset) -> Bool {
        if let closure = self.canSelectAsset {
            return closure(phAsset)
        } else if let delegate = self.delegate {
            return delegate.canSelectAsset(phAsset: phAsset)
        }
        return true
    }
    
}


// MARK: - Video & LivePhotos Control PHLivePhotoViewDelegate
extension PhotosPickerViewController: PHLivePhotoViewDelegate {
   
    public func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        livePhotoView.isMuted = true
        livePhotoView.startPlayback(with: .hint)
    }

    public func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
    }
}

// MARK: - UICollectionView delegate & datasource
extension PhotosPickerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    fileprivate func getSelectedAssets(_ asset: ImageAsset) -> ImageAsset? {
        if let index = self.selectedAssets.firstIndex(where: { $0.asset == asset.asset }) {
            return self.selectedAssets[index]
        }
        return nil
    }
    
    fileprivate func orderUpdateCells() {
        let visibleIndexPaths = self.collectionView.indexPathsForVisibleItems.sorted(by: { $0.row < $1.row })
        for indexPath in visibleIndexPaths {
            guard let cell = self.collectionView.cellForItem(at: indexPath) as? AllPhotosCollectionViewCell else { continue }
            let asset = self.images[(indexPath as NSIndexPath).item]
            if let selectedAsset = getSelectedAssets(asset) {
                cell.selectedAsset = true
                cell.orderLabel?.text = "\(selectedAsset.selectedOrder)"
            }else {
                cell.selectedAsset = false
            }
        }
    }
    
    //Delegate
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? AllPhotosCollectionViewCell else { return }

        let asset = self.images[(indexPath as NSIndexPath).item]
        cell.popScaleAnim()

        if let index = self.selectedAssets.firstIndex(where: { $0.asset == asset.asset }) {
            //deselect
            self.logDelegate?.deselectedPhoto(picker: self, at: indexPath.row)
            self.selectedAssets.remove(at: index)
            #if swift(>=4.1)
                self.selectedAssets = self.selectedAssets.enumerated().compactMap({ (offset, asset) -> ImageAsset? in
                    let asset = asset
                    asset.selectedOrder = offset + 1
                    return asset
                })
            #else
                self.selectedAssets = self.selectedAssets.enumerated().flatMap({ (offset, asset) -> Image? in
                    let asset = asset
                    return asset
                })
            #endif
            cell.selectedAsset = false
         
            self.orderUpdateCells()
            
            oldIndexSelected = indexPath
        } else {
            self.logDelegate?.selectedPhoto(picker: self, at: indexPath.row)
            if selectedAssets.count == 0 {
                selectionType = asset.assetType
            }
            guard !maxCheck() else { return }

            asset.selectedOrder = self.selectedAssets.count + 1
            self.selectedAssets.append(asset)
            
            cell.selectedAsset = true
            cell.orderLabel?.text = "\(asset.selectedOrder)"
        }
    }

    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let requestId = self.requestIds[indexPath] else { return }
        self.requestIds.removeValue(forKey: indexPath)
        self.library.cancelPHImageRequest(requestId: requestId)
    }

    //Datasource
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        func makeCell(nibName: String) -> AllPhotosCollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibName, for: indexPath) as! AllPhotosCollectionViewCell
            cell.configure = self.configure
            cell.imageView?.image = self.placeholderThumbnail
            cell.liveBadgeImageView = nil
            return cell
        }
        let nibName = self.configure.nibSet?.nibName ?? "AllPhotosCollectionViewCell"
        let cell = makeCell(nibName: nibName)

        let currentTag = cell.tag + 1
        cell.tag = currentTag

        let asset = self.images[(indexPath as NSIndexPath).item]

        if let selectedAsset = getSelectedAssets(asset) {
            cell.orderLabel?.text = "\(selectedAsset.selectedOrder)"
            cell.selectedAsset = true
        } else {
            cell.selectedAsset = false
        }
        
        if asset.state == .progress {
            cell.indicator?.startAnimating()
        }else {
            cell.indicator?.stopAnimating()
        }
        
        if let phAsset = asset.asset {
            if self.usedPrefetch {
                let options = PHImageRequestOptions()
                options.deliveryMode = .opportunistic
                options.resizeMode = .exact
                options.isNetworkAccessAllowed = true
                let requestId = self.library.imageAsset(asset: phAsset, size: self.thumbnailSize, options: options) { [weak self, weak cell] (image, complete) in
                    guard let `self` = self else { return }
                    DispatchQueue.main.async {
                        if self.requestIds[indexPath] != nil {
                            cell?.imageView?.image = image
                            cell?.durationView?.isHidden = asset.assetType != .video
                            cell?.duration = asset.assetType == .video ? phAsset.duration : nil
                            if complete {
                                self.requestIds.removeValue(forKey: indexPath)
                            }
                        }
                    }
                }
                if requestId > 0 {
                    self.requestIds[indexPath] = requestId
                }
            } else {
                queue.async { [weak self, weak cell] in
                    guard let `self` = self else { return }
                    let requestId = self.library.imageAsset(asset: phAsset, size: self.thumbnailSize, completionBlock: { (image, complete) in
                        DispatchQueue.main.async {
                            if self.requestIds[indexPath] != nil {
                                cell?.imageView?.image = image
                                cell?.durationView?.isHidden = asset.assetType != .video
                                cell?.duration = asset.assetType == .video ? phAsset.duration : nil
                                if complete {
                                    self.requestIds.removeValue(forKey: indexPath)
                                }
                            }
                        }
                    })
                    if requestId > 0 {
                        self.requestIds[indexPath] = requestId
                    }
                }
            }
        }
        cell.alpha = 0
        UIView.transition(with: cell, duration: 0.1, options: .curveEaseIn, animations: {
            cell.alpha = 1
        }, completion: nil)
        return cell
    }

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    //Prefetch
    open func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if self.usedPrefetch {
            queue.async { [weak self] in
                guard let `self` = self, let collection = self.focusedCollection else { return }
                var assets = [PHAsset]()
                for indexPath in indexPaths {
                    if let asset = collection.getAsset(at: indexPath.row) {
                        assets.append(asset)
                    }
                }
                let scale = max(UIScreen.main.scale,2)
                let targetSize = CGSize(width: self.thumbnailSize.width*scale, height: self.thumbnailSize.height*scale)
                self.library.imageManager.startCachingImages(for: assets, targetSize: targetSize, contentMode: .aspectFill, options: nil)
            }
        }
    }

    open func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        if self.usedPrefetch {
            for indexPath in indexPaths {
                guard let requestId = self.requestIds[indexPath] else { continue }
                self.library.cancelPHImageRequest(requestId: requestId)
                self.requestIds.removeValue(forKey: indexPath)
            }
            queue.async { [weak self] in
                guard let `self` = self, let collection = self.focusedCollection else { return }
                var assets = [PHAsset]()
                for indexPath in indexPaths {
                    if let asset = collection.getAsset(at: indexPath.row) {
                        assets.append(asset)
                    }
                }
                let scale = max(UIScreen.main.scale,2)
                let targetSize = CGSize(width: self.thumbnailSize.width*scale, height: self.thumbnailSize.height*scale)
                self.library.imageManager.stopCachingImages(for: assets, targetSize: targetSize, contentMode: .aspectFill, options: nil)
            }
        }
    }
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? AllPhotosCollectionViewCell {
            let asset = self.images[(indexPath as NSIndexPath).item]
            if let selectedAsset = getSelectedAssets(asset) {
                cell.orderLabel?.text = "\(selectedAsset.selectedOrder)"
                cell.selectedAsset = true
            } else {
                cell.selectedAsset = false
            }
        }
    }
}
