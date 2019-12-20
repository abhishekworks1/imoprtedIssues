//
//  TrimEditorViewController.swift
//  ProManager
//
//  Created by Viraj Patel on 15/11/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import AVKit
import SCRecorder
import IQKeyboardManagerSwift
import CoreLocation

class TrimEditorViewController: UIViewController {
    @IBOutlet weak var postStoryButton: UIButton!
    @IBOutlet weak var storyExportLabel: UILabel!
    @IBOutlet weak var stopMotionCollectionView: KDDragAndDropCollectionView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var canvasImageView: UIImageView!
    @IBOutlet weak var topToolbar: UIView!
    @IBOutlet weak var bottomToolbar: UIView!
    @IBOutlet weak var topGradient: UIView!
    @IBOutlet weak var bottomGradient: UIView!
    @IBOutlet weak var storyView: UIView!
    @IBOutlet open var btnPlayPause: UIButton!
    
    // MARK: - Public Properties
    public private(set) var currentTime = CMTime.zero
    public var videoUrl: StoryEditorMedia?
    public var image: UIImage?
    public var videoUrls: [StoryEditorMedia] = []
    
    public var currentPlayVideo: Int = -1
    public var selectedItem: Int = 0
    fileprivate var isViewAppear = false
    var filterSwitcherView: StorySwipeableFilterView?
    var recordSession: SCRecordSession?
    var scPlayer: StoryPlayer?
    var currentPage: Int = 0
    var playerObserver: Any?
    var selectedUrl: URL?
    var storiCamType: StoriCamType = .story
    var isEditMode: Bool = false
    var isViewEditMode: Bool = false {
        didSet {
            if isViewEditMode {
                bottomToolbar.isHidden = true
            } else {
                bottomToolbar.isHidden = (storiCamType == .chat)
            }
        }
    }
    var positionConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    private var isPlayerInitialize = false
    let positionBar = UIView()
    let handleWidth: CGFloat = 15
    var playbackTimeCheckerTimer: Timer?
    var doneHandler: ((_ urls: [StoryEditorMedia]) -> Void)?
    @IBInspectable open var isTimePrecisionInfinity: Bool = false
    var tolerance: CMTime {
        return isTimePrecisionInfinity ? CMTime.indefinite : CMTime.zero
    }
    
    var getCurrentIndexPath: IndexPath {
        return IndexPath.init(row: self.currentPage, section: 0)
    }
    
    func currentAsset(index: Int) -> AVAsset? {
        var avAsset: AVAsset?
        switch self.videoUrls[index].type {
        case .image:
            break
        case let .video(_, asset):
            avAsset = asset
        }
        guard let currentAsset = avAsset else {
            return nil
        }
        return currentAsset
    }
    
    func thumbImage(index: Int) -> UIImage? {
        var image: UIImage?
        switch self.videoUrls[index].type {
        case .image:
            break
        case let .video(thumbImage, _):
            image = thumbImage
        }
        guard let thumbImage = image else {
            return nil
        }
        return thumbImage
    }
    
    
    // Register Custom font before we load XIB
    public override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFilter()
        setupLayout()
        setupVideoPlayer()
    }
    
    func setupPositionBar(cell: ImageCollectionViewCell) {
        positionBar.frame = CGRect(x: 0, y: 0, width: 3, height: cell.imagesView.frame.height)
        positionBar.backgroundColor = ApplicationSettings.appWhiteColor
        positionBar.center = CGPoint(x: cell.imagesView.frame.maxX, y: cell.imagesView.center.y)
        positionBar.layer.cornerRadius = 1
        positionBar.translatesAutoresizingMaskIntoConstraints = false
        positionBar.isUserInteractionEnabled = false
        cell.contentView.addSubview(positionBar)
        
        positionBar.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        positionBar.widthAnchor.constraint(equalToConstant: 2).isActive = true
        heightConstraint = positionBar.heightAnchor.constraint(equalToConstant: CGFloat(cell.imagesView.frame.height))
        heightConstraint?.isActive = true
        positionConstraint = positionBar.leftAnchor.constraint(equalTo: cell.imagesView.leftAnchor, constant: 0)
        positionConstraint?.isActive = true
    }
    
    func removePositionBar(cell: ImageCollectionViewCell) {
        positionBar.removeFromSuperview()
    }
    
    fileprivate func setupLayout() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.stopMotionCollectionView.register(R.nib.imageCollectionViewCell)
    }
    
    func setupVideoPlayer() {
        scPlayer = StoryPlayer()
        scPlayer?.scImageView = filterSwitcherView
        scPlayer?.delegate = self
        scPlayer?.loopEnabled = true
        
        print("Recording completed After Video Count \(videoUrls.count)")
    }
    
    func connVideoPlay() {
        DispatchQueue.main.async {
            self.currentPlayVideo += 1
            if self.currentPlayVideo == self.videoUrls.count {
                self.currentPlayVideo = 0
            }
            self.currentPage = self.currentPlayVideo
            if self.videoUrls.count == 1 {
                self.isEditMode = true
            }
            self.selectedItem = self.currentPage
            self.stopMotionCollectionView.reloadData()
            
            if let player = self.scPlayer, !self.videoUrls.isEmpty {
                guard let currentAsset = self.currentAsset(index: self.currentPlayVideo) else {
                    return
                }
                
                player.setItemBy(currentAsset)
                if player.isPlaying {
                    player.play()
                    self.startPlaybackTimeChecker()
                }
                if let cell: ImageCollectionViewCell = self.stopMotionCollectionView.cellForItem(at: self.getCurrentIndexPath) as? ImageCollectionViewCell {
                    guard let startTime = cell.trimmerView.startTime else {
                        return
                    }
                    player.seek(to: startTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
                }
            }
        }
    }
    
    deinit {
        print("TrimEditiorVC Deinit")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isViewAppear = true
        observeState()
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isPlayerInitialize {
            isPlayerInitialize = true
            connVideoPlay()
            if let player = scPlayer {
                player.play()
                startPlaybackTimeChecker()
            }
        }
    }
    
    func setupFilter() {
        self.filterSwitcherView = StorySwipeableFilterView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        self.filterSwitcherView?.isUserInteractionEnabled = true
        self.filterSwitcherView?.isMultipleTouchEnabled = true
        self.filterSwitcherView?.isExclusiveTouch = false
        filterSwitcherView?.contentMode = .scaleAspectFill
        self.filterSwitcherView?.backgroundColor = ApplicationSettings.appClearColor
        
        for subview in (filterSwitcherView?.subviews)! {
            subview.backgroundColor = ApplicationSettings.appClearColor
        }
        
        self.canvasImageView.addSubview(filterSwitcherView!)
        let emptyFilter = StoryFilter(name: "", ciFilter: CIFilter())
        filterSwitcherView?.filters = [emptyFilter]
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopPlaybackTimeChecker()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let player = scPlayer {
            player.pause()
            stopPlaybackTimeChecker()
            if let observer = self.playerObserver {
                player.removeTimeObserver(observer)
                self.playerObserver = nil
            }
        }
        
        removeObserveState()
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        if let doneHandler = self.doneHandler {
            var urls: [StoryEditorMedia] = []
            for video in self.videoUrls {
                urls.append(video)
            }
            doneHandler(urls)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func playPauseClicked(_ sender: Any) {
        if let player = self.scPlayer {
            if player.isPlaying {
                player.pause()
                stopPlaybackTimeChecker()
                btnPlayPause.isSelected = false
            } else {
                player.play()
                startPlaybackTimeChecker()
                btnPlayPause.isSelected = true
            }
        }
    }
    
    @IBAction func btnTrimClick(_ sender: UIButton) {
        if let player = self.scPlayer {
            if let cell: ImageCollectionViewCell = self.stopMotionCollectionView.cellForItem(at: getCurrentIndexPath) as? ImageCollectionViewCell {
                guard let trimmerView = cell.trimmerView else {
                    return
                }
                self.trimVideo(trimmerView, with: player.currentTime())
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getPosition(from time: CMTime, cell: ImageCollectionViewCell, index: IndexPath) -> CGFloat? {
        if let cell: ImageCollectionViewCell = self.stopMotionCollectionView.cellForItem(at: getCurrentIndexPath) as? ImageCollectionViewCell {
            guard let currentAsset = currentAsset(index: self.currentPlayVideo) else {
                return 0
            }
            
            let timeRatio = CGFloat(time.value) * CGFloat(currentAsset.duration.timescale) /
                (CGFloat(time.timescale) * CGFloat(currentAsset.duration.value))
            return timeRatio * cell.bounds.width
        }
        return 0
    }
    
    /// Move the position bar to the given time.
    func seek(to time: CMTime, cell: ImageCollectionViewCell) {
        if let newPosition = getPosition(from: time, cell: cell, index: IndexPath.init(row: 0, section: 0)) {
            let offsetPosition = newPosition
            let maxPosition = cell.imagesView.bounds.width
            let normalizedPosition = min(max(0, offsetPosition), maxPosition)
            positionConstraint?.constant = normalizedPosition
            heightConstraint?.constant = cell.imagesView.frame.height
            cell.layoutIfNeeded()
        }
    }
    
    func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self,
                                                        selector:
            #selector(self.onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }
    
    func stopPlaybackTimeChecker() {
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
    
    @objc func onPlaybackTimeChecker() {
        if let player = self.scPlayer {
            let playBackTime = player.currentTime()
            if let cell: ImageCollectionViewCell = self.stopMotionCollectionView.cellForItem(at: getCurrentIndexPath) as? ImageCollectionViewCell {
                guard let startTime = cell.trimmerView.startTime, let endTime = cell.trimmerView.endTime else {
                    return
                }
                
                cell.trimmerView.seek(to: playBackTime)
                seek(to: CMTime.init(seconds: playBackTime.seconds, preferredTimescale: 10000), cell: cell)
                
                if playBackTime >= endTime {
                    player.seek(to: startTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
                    cell.trimmerView.seek(to: startTime)
                    cell.trimmerView.resetTimePointer()
                }
            }
            
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let player = scPlayer {
            player.pause()
            stopPlaybackTimeChecker()
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let player = scPlayer {
            if player.isPlaying {
                player.play()
                startPlaybackTimeChecker()
            }
            if let cell: ImageCollectionViewCell = self.stopMotionCollectionView.cellForItem(at: getCurrentIndexPath) as? ImageCollectionViewCell {
                guard let startTime = cell.trimmerView.startTime else {
                    return
                }
                player.seek(to: startTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            }
        }
    }
}

// MARK: UICollectionViewDataSource
extension TrimEditorViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoUrls.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.imageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell else {
            fatalError("Unable to find cell with '\(R.nib.imageCollectionViewCell.identifier)' reuseIdentifier")
        }
        
        var borderColor: CGColor! = ApplicationSettings.appClearColor.cgColor
        var borderWidth: CGFloat = 0
        if self.currentPage == indexPath.row || videoUrls[indexPath.row].isSelected {
            borderColor = ApplicationSettings.appPrimaryColor.cgColor
            borderWidth = 3
            cell.lblVideoersiontag.isHidden = false
        } else {
            borderColor = ApplicationSettings.appWhiteColor.cgColor
            borderWidth = 3
            cell.lblVideoersiontag.isHidden = true
        }
        
        cell.isHidden = false
        cell.imagesStackView.tag = indexPath.row
        
        let views = cell.imagesStackView.subviews
        for view in views {
            cell.imagesStackView.removeArrangedSubview(view)
        }
        
        cell.lblSegmentCount.text = "\(indexPath.row + 1)"
        
        guard let currentAsset = currentAsset(index: indexPath.row) else {
            return cell
        }
        
        var mainView: UIView = UIView()
        var imageView = UIImageView()
        
        if self.currentPage == indexPath.row {
            mainView = UIView.init(frame: CGRect(x: 0, y: 3, width: Double(41 * 1.2), height: Double(cell.imagesView.frame.height * 1.18)))
            imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: Double(41 * 1.2), height: Double(cell.imagesView.frame.height * 1.18)))
            imageView.image = thumbImage(index: indexPath.row)
            imageView.contentMode = .scaleToFill
            imageView.clipsToBounds = true
            mainView.addSubview(imageView)
            cell.imagesStackView.addArrangedSubview(mainView)
            cell.loadAsset(currentAsset)
            cell.trimmerView.delegate = self
            if isEditMode {
                self.scPlayer?.setItemBy(currentAsset)
                self.removePositionBar(cell: cell)
                cell.trimmerView.isHidden = false
                cell.imagesView.isHidden = true
                cell.imagesStackView.isHidden = true
            } else {
                self.setupPositionBar(cell: cell)
                cell.trimmerView.isHidden = true
                cell.imagesView.isHidden = false
                cell.imagesStackView.isHidden = false
                
            }
        } else {
            if videoUrls[indexPath.row].isSelected {
                mainView = UIView.init(frame: CGRect(x: 0, y: 3, width: Double(41 * 1.2), height: Double(cell.imagesView.frame.height * 1.18)))
                imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: Double(41 * 1.2), height: Double(cell.imagesView.frame.height * 1.18)))
                
            } else {
                mainView = UIView.init(frame: CGRect(x: 0, y: 3, width: 41, height: 52))
                imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 41, height: 52))
            }
            imageView.image = thumbImage(index: indexPath.row)
            imageView.contentMode = .scaleToFill
            imageView.clipsToBounds = true
            mainView.addSubview(imageView)
            
            cell.imagesStackView.addArrangedSubview(mainView)
            cell.trimmerView.isHidden = true
            cell.imagesView.isHidden = false
            cell.imagesStackView.isHidden = false
        }
        cell.imagesView.layer.cornerRadius = 5
        cell.imagesView.layer.borderWidth = borderWidth
        cell.imagesView.layer.borderColor = borderColor
        
        return cell
    }
    
    func collectionViewEdgesAndScroll(_ collectionView: UICollectionView, rect: CGRect) {
        guard let currentPlayer = self.scPlayer else { return }
        currentPlayer.pause()
        stopPlaybackTimeChecker()
    }
    
    func collectionViewLastEdgesAndScroll(_ collectionView: UICollectionView, rect: CGRect) {
        DispatchQueue.main.async {
            guard let currentPlayer = self.scPlayer else { return }
            if currentPlayer.isPlaying {
                currentPlayer.play()
                self.startPlaybackTimeChecker()
            }
        }
    }
}

// MARK: UICollectionViewDelegate
extension TrimEditorViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedItem == indexPath.row {
            isEditMode = !isEditMode
        } else {
            isEditMode = true
        }
        selectedItem = indexPath.row
        self.currentPlayVideo = indexPath.row
        if self.currentPlayVideo == self.videoUrls.count {
            self.currentPlayVideo = 0
        }
        self.currentPage = self.currentPlayVideo
        self.stopMotionCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if currentPage == indexPath.row {
            if isEditMode {
                return CGSize(width: 225, height: Double(98 * 1.17))
            } else {
                return CGSize(width: 41 * 1.2, height: Double(98 * 1.17))
            }
        }
        return CGSize(width: 41, height: 98)
    }
    
}

// MARK: TrimmerViewDelegate
extension TrimEditorViewController: TrimmerViewDelegate {
    
    func trimmerDidBeginDragging(_ trimmer: TrimmerView, with currentTimeTrim: CMTime) {
        
    }
    
    func trimmerDidChangeDraggingPosition(_ trimmer: TrimmerView, with currentTimeTrim: CMTime) {
        if let player = scPlayer {
            player.seek(to: currentTimeTrim, toleranceBefore: tolerance, toleranceAfter: tolerance)
        }
    }
    
    func trimmerDidEndDragging(_ trimmer: TrimmerView, with startTime: CMTime, endTime: CMTime) {
        if let player = scPlayer {
            player.seek(to: startTime, toleranceBefore: tolerance, toleranceAfter: tolerance)
        }
    }
    
    func trimmerScrubbingDidChange(_ trimmer: TrimmerView, with currentTimeScrub: CMTime) {
        if let player = scPlayer {
            player.seek(to: currentTimeScrub, toleranceBefore: tolerance, toleranceAfter: tolerance)
            
            if let cell: ImageCollectionViewCell = self.stopMotionCollectionView.cellForItem(at: getCurrentIndexPath) as? ImageCollectionViewCell {
                guard let startTime = cell.trimmerView.startTime, let endTime = cell.trimmerView.endTime else {
                    return
                }
                cell.trimmerView.seek(to: currentTimeScrub)
                
                if currentTimeScrub >= endTime {
                    cell.trimmerView.seek(to: startTime)
                    cell.trimmerView.resetTimePointer()
                }
            }
        }
    }
    
    func trimmerScrubbingDidEnd(_ trimmer: TrimmerView, with currentTimeScrub: CMTime, with sender: UIPanGestureRecognizer) {
        guard let view = sender.view else { return }
        _ = sender.translation(in: view)
        sender.setTranslation(.zero, in: view)
        let position = sender.location(in: view)
        print(position)
        if position.y >= -100 {
            if let player = scPlayer {
                player.seek(to: currentTimeScrub, toleranceBefore: tolerance, toleranceAfter: tolerance)
                if player.isPlaying {
                    player.play()
                    self.startPlaybackTimeChecker()
                }
            }
        }
    }
    
    func trimVideo(_ trimmer: TrimmerView, with currentTimeScrub: CMTime) {
        guard (currentTimeScrub.seconds - trimmer.startTime!.seconds) >= 3 else {
            self.view.makeToast(R.string.localizable.minimum3SecondRequireToSplitOrTrim())
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            if let player = scPlayer {
                player.seek(to: currentTimeScrub, toleranceBefore: tolerance, toleranceAfter: tolerance)
                if player.isPlaying {
                    player.play()
                    self.startPlaybackTimeChecker()
                }
            }
            return
        }
        
        do {
            try Utils.time {
                guard let asset = currentAsset(index: self.currentPage) else {
                    return
                }
                let trimmed = try asset.assetByTrimming(startTime: CMTime.init(seconds: currentTimeScrub.seconds, preferredTimescale: 10000), endTime: trimmer.endTime!)
                let thumbimage = getThumbnailFrom(asset: trimmed) ?? UIImage()
                
                self.videoUrls[self.currentPage] = StoryEditorMedia(type: .video(thumbimage, trimmed))
                do {
                    try Utils.time {
                        let trimmedAsset = try asset.assetByTrimming(startTime: trimmer.startTime!, endTime: CMTime.init(seconds: currentTimeScrub.seconds, preferredTimescale: 10000))
                        let image = getThumbnailFrom(asset: trimmedAsset) ?? UIImage()
                        self.videoUrls.insert(StoryEditorMedia(type: .video(image, trimmedAsset)), at: self.currentPage)
                        
                        self.connVideoPlay()
                        if let player = scPlayer {
                            if player.isPlaying {
                                player.play()
                                self.startPlaybackTimeChecker()
                            }
                        }
                    }
                } catch let error {
                    print("\(error)")
                }
            }
        } catch let error {
            print("\(error)")
        }
    }
    
    func getThumbnailFrom(asset: AVAsset) -> UIImage? {
        do {
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: Observe
extension TrimEditorViewController {
    
    func observeState() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.enterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.enterForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func removeObserveState() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func enterBackground(_ notifi: Notification) {
        if isViewAppear {
            guard let currentPlayer = self.scPlayer else { return }
            currentPlayer.pause()
            stopPlaybackTimeChecker()
        }
    }
    
    @objc func enterForeground(_ notifi: Notification) {
        if isViewAppear {
            guard let currentPlayer = self.scPlayer else { return }
            if currentPlayer.isPlaying {
                currentPlayer.play()
                startPlaybackTimeChecker()
            }
        }
    }
}
extension TrimEditorViewController: StoryPlayerDelegate {
    
    func player(_ player: StoryPlayer, didPlay currentTime: CMTime, loopsCount: Int) {
        self.stopMotionCollectionView.reloadData()
    }
    
    func playerDidEnd() {
        DispatchQueue.main.async {
            if !self.isEditMode {
                self.currentPlayVideo += 1
                
                if self.currentPlayVideo == self.videoUrls.count {
                    self.currentPlayVideo = 0
                }
                self.currentPage = self.currentPlayVideo
                self.stopMotionCollectionView.reloadData()
                self.stopMotionCollectionView.layoutIfNeeded()
                self.stopMotionCollectionView.setNeedsLayout()
                
                if !self.videoUrls.isEmpty {
                    guard let currentAsset = self.currentAsset(index: self.currentPlayVideo) else {
                        return
                    }
                    self.scPlayer?.setItemBy(currentAsset)
                }
                if let cell: ImageCollectionViewCell = self.stopMotionCollectionView.cellForItem(at: self.getCurrentIndexPath) as? ImageCollectionViewCell {
                    guard let startTime = cell.trimmerView.startTime else {
                        return
                    }
                    self.scPlayer?.seek(to: startTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
                }
            }
        }
    }
    
    func player(_ player: StoryPlayer, didReachEndFor item: AVPlayerItem) {
        self.playerDidEnd()
    }
    
}
