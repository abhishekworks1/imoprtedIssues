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
    @IBOutlet weak var storyCollectionView: DragAndDropCollectionView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var topToolbar: UIView!
    @IBOutlet weak var bottomToolbar: UIView!
    @IBOutlet weak var topGradient: UIView!
    @IBOutlet weak var bottomGradient: UIView!
    @IBOutlet weak var storyView: UIView!
    @IBOutlet open var btnPlayPause: UIButton!
    @IBOutlet weak var splitView: UIView!
    @IBOutlet weak var mergeView: UIView!
    @IBOutlet open var videoView: UIView!
    
    @IBOutlet weak var segmentTypeMergeView: UIStackView! {
        didSet {
            segmentTypeMergeView.isHidden = true
        }
    }
    
    @IBOutlet weak var segmentEditOptionButton: UIButton!
    @IBOutlet weak var segmentEditOptionView: UIStackView!
    @IBOutlet weak var rearrangedView: UIView! {
        didSet {
            rearrangedView.isHidden = true
        }
    }
    
    @IBOutlet weak var mergeButton: UIButton!
    @IBOutlet weak var combineButton: UIButton!
    @IBOutlet weak var resequenceButton: UIButton!
    @IBOutlet weak var resequenceLabel: UILabel!
    
    var isOriginalSequence = false
    var undoMgr = MyUndoManager<Void>()
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var playerLayer: AVPlayerLayer?
    var draggingCell: IndexPath?
    var lastMergeCell: IndexPath?
    
    var isMovable: Bool = false
    private var dragAndDropManager: DragAndDropManager?
    
    // MARK: - Public Properties
    public private(set) var currentTime = CMTime.zero
    var videoUrls: [StoryEditorMedia] = []
    
    var storyEditorMedias: [[StoryEditorMedia]] = []
    var resetStoryEditorMedias: [[StoryEditorMedia]] = []
    
    var currentPlayVideo: Int = -1
    var selectedItem: Int = 0
    var isViewAppear = false
    var currentPage: Int = 0
    var playerObserver: Any?
    var isEditMode: Bool = false
    var isMergeModeEnable: Bool = false {
        didSet {
            if !isMergeModeEnable {
                splitView.alpha = 1
                mergeView.alpha = 0.5
                segmentEditOptionView.isHidden = true
                segmentEditOptionButton.isHidden = true
                segmentTypeMergeView.isHidden = true
            } else {
                splitView.alpha = 0.5
                mergeView.alpha = 1
                segmentEditOptionView.isHidden = segmentEditOptionButton.isSelected
                segmentEditOptionButton.isHidden = false
                segmentTypeMergeView.isHidden = true
            }
        }
    }
    
    var positionConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    var isPlayerInitialize = false
    let positionBar = UIView()
    var playbackTimeCheckerTimer: Timer?
    var doneHandler: ((_ urls: [StoryEditorMedia]) -> Void)?
    @IBInspectable open var isTimePrecisionInfinity: Bool = false
    var tolerance: CMTime {
        return isTimePrecisionInfinity ? CMTime.indefinite : CMTime.zero
    }
    
    var getCurrentIndexPath: IndexPath {
        return IndexPath.init(row: self.currentPage, section: 0)
    }
    
    func currentAsset(index: Int, secondIndex: Int = 0) -> AVAsset? {
        var avAsset: AVAsset?
        guard storyEditorMedias.count > index else {
            return avAsset
        }
        switch self.storyEditorMedias[index][secondIndex].type {
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
    
    func thumbImage(index: Int, secondIndex: Int = 0) -> UIImage? {
        var image: UIImage?
        switch self.storyEditorMedias[index][secondIndex].type {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        for videoSegment in videoUrls {
            storyEditorMedias.append([videoSegment])
            resetStoryEditorMedias.append([videoSegment])
        }
        isMergeModeEnable = false
    }
    
    deinit {
        stopPlaybackTimeChecker()
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerItem = nil
        playerLayer = nil
        NotificationCenter.default.removeObserver(self)
        undoMgr.removeAll()
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
        playerLayer?.frame = videoView.frame
        if !isPlayerInitialize {
            isPlayerInitialize = true
            connVideoPlay()
        }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopPlaybackTimeChecker()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let player = player {
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
        cell.imagesView.layoutIfNeeded()
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
        self.storyCollectionView.register(R.nib.imageCollectionViewCell)
        
        self.dragAndDropManager = DragAndDropManager(canvas: self.view,
                                                     collectionViews: [self.storyCollectionView])
    }
    
    
    func getPosition(from time: CMTime, cell: ImageCollectionViewCell, index: IndexPath) -> CGFloat? {
        if let cell: ImageCollectionViewCell = self.storyCollectionView.cellForItem(at: getCurrentIndexPath) as? ImageCollectionViewCell {
            guard let currentAsset = currentAsset(index: self.currentPage) else {
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
            cell.imagesView.layoutIfNeeded()
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
        if let player = self.player {
            let playBackTime = player.currentTime()
            if let cell: ImageCollectionViewCell = self.storyCollectionView.cellForItem(at: getCurrentIndexPath) as? ImageCollectionViewCell {
                guard let startTime = cell.trimmerView.startTime, let endTime = cell.trimmerView.endTime else {
                    return
                }
                
                cell.trimmerView.seek(to: playBackTime)
                seek(to: CMTime.init(seconds: playBackTime.seconds, preferredTimescale: 10000), cell: cell)
                
                if playBackTime >= endTime {
                    player.seek(to: startTime, toleranceBefore: tolerance, toleranceAfter: tolerance)
                    cell.trimmerView.seek(to: startTime)
                    cell.trimmerView.resetTimePointer()
                }
            }
            
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let player = player {
            player.pause()
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let player = player {
            if player.timeControlStatus == .playing {
                player.play()
            }
            if let cell: ImageCollectionViewCell = self.storyCollectionView.cellForItem(at: getCurrentIndexPath) as? ImageCollectionViewCell {
                guard let startTime = cell.trimmerView.startTime else {
                    return
                }
                player.seek(to: startTime, toleranceBefore: tolerance, toleranceAfter: tolerance)
            }
        }
    }
}

// MARK: UICollectionViewDataSource
extension TrimEditorViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storyEditorMedias.count
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
        if self.currentPage == indexPath.row || storyEditorMedias[indexPath.row][0].isSelected {
            borderColor = ApplicationSettings.appPrimaryColor.cgColor
            borderWidth = 3
            cell.lblVideoersiontag.isHidden = false
        } else {
            borderColor = ApplicationSettings.appWhiteColor.cgColor
            borderWidth = 3
            cell.lblVideoersiontag.isHidden = true
        }
        
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
       
        cell.imagesView.layer.cornerRadius = 5
        cell.imagesView.layer.borderWidth = borderWidth
        cell.imagesView.layer.borderColor = borderColor
        let storySegment = storyEditorMedias[indexPath.row]
        
        if self.currentPage == indexPath.row {
            for (index, _) in storySegment.enumerated() {
                mainView = UIView.init(frame: CGRect(x: 0, y: 3, width: Double(41 * 1.2), height: Double(cell.imagesView.frame.height * 1.18)))
                
                imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: Double(41 * 1.2), height: Double(cell.imagesView.frame.height * 1.18)))
                imageView.image = thumbImage(index: indexPath.row, secondIndex: index)
                imageView.contentMode = .scaleToFill
                imageView.clipsToBounds = true
                mainView.addSubview(imageView)
                cell.imagesStackView.addArrangedSubview(mainView)
            }
            cell.loadAsset(currentAsset)
            cell.trimmerView.delegate = self
            cell.isEditMode = isEditMode
            if isEditMode {
                self.removePositionBar(cell: cell)
            } else {
                self.setupPositionBar(cell: cell)
            }
        } else {
            if !storyEditorMedias[indexPath.row][0].isSelected {
                for (index, _) in storySegment.enumerated() {
                    mainView = UIView(frame: CGRect(x: 0, y: 3, width: Double(41), height: 52))
                    
                    imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: Double(41), height: 52))
                    imageView.image = thumbImage(index: indexPath.row, secondIndex: index)
                    imageView.contentMode = .scaleToFill
                    imageView.clipsToBounds = true
                    mainView.addSubview(imageView)
                    cell.imagesStackView.addArrangedSubview(mainView)
                }
            } else {
                mainView = UIView.init(frame: CGRect(x: 0, y: 3, width: Double(41 * 1.2), height: Double(cell.imagesView.frame.height * 1.18)))
                imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: Double(41 * 1.2), height: Double(cell.imagesView.frame.height * 1.18)))
                imageView.image = thumbImage(index: indexPath.row)
                imageView.contentMode = .scaleToFill
                imageView.clipsToBounds = true
                mainView.addSubview(imageView)
                cell.imagesStackView.addArrangedSubview(mainView)
            }
            
            cell.isEditMode = false
        }
        cell.isHidden = false
        if let draggingPathOfCellBeingDragged = self.storyCollectionView.draggingPathOfCellBeingDragged {
            if draggingPathOfCellBeingDragged.item == indexPath.item {
                cell.isHidden = true
            }
        }
        
        return cell
    }
    
    func collectionViewEdgesAndScroll(_ collectionView: UICollectionView, rect: CGRect) {
        guard let currentPlayer = self.player else { return }
        currentPlayer.pause()
    }
    
    func collectionViewLastEdgesAndScroll(_ collectionView: UICollectionView, rect: CGRect) {
        DispatchQueue.main.async {
            guard let currentPlayer = self.player else { return }
            if currentPlayer.timeControlStatus == .playing {
                currentPlayer.play()
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
        if self.currentPlayVideo == self.storyEditorMedias.count {
            self.currentPlayVideo = 0
        }
        self.currentPage = self.currentPlayVideo
        self.storyCollectionView.reloadData()
        guard let currentAsset = self.currentAsset(index: self.currentPage) else {
            return
        }
        self.loadViewWith(asset: currentAsset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let storySegment = storyEditorMedias[indexPath.row]
        if currentPage == indexPath.row {
            if isEditMode {
                return CGSize(width: 225, height: Double(98 * 1.17))
            } else {
                return CGSize(width: (Double(storySegment.count * 41) * 1.2), height: Double(98 * 1.17))
            }
        }
        return CGSize(width: (Double(storySegment.count * 41)), height: Double(98))
    }
    
}

extension TrimEditorViewController {
    
    func addPlayerLayer() {
        videoView.layoutIfNeeded()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = videoView.frame
        playerLayer?.isOpaque = false
        
        playerLayer?.backgroundColor = ApplicationSettings.appClearColor.cgColor
        playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        if let aLayer = playerLayer {
            videoView.layer.addSublayer(aLayer)
        }
    }
    
    func setupPlayer(for playerItem: AVPlayerItem) {
        if player != nil {
            player = nil
        }
        player = AVPlayer(playerItem: playerItem)
        playerLayer?.player = player
        player?.play()
        self.startPlaybackTimeChecker()
    }
    
    func replaceNewViewWith(asset: AVAsset?) {
        if let asset = asset {
            player?.replaceCurrentItem(with: AVPlayerItem.init(asset: asset))
            player?.play()
        }
    }
    
    func loadViewWith(asset: AVAsset?) {
        if let asset = asset {
            addPlayerIfNeeded(for: asset)
        }
    }
    
    func addPlayerIfNeeded(for asset: AVAsset) {
        playerItem = AVPlayerItem.init(asset: asset)
        playerItem!.audioTimePitchAlgorithm = .lowQualityZeroLatency
        if playerLayer == nil {
            addPlayerLayer()
        }
        setupPlayer(for: playerItem!)
        if player != nil {
            addPlayerEndTimeObserver()
        }
    }
    
    func removePlayerIfNeeded() {
        if playerItem != nil {
            playerItem = nil
        }
        if player != nil {
            player?.pause()
            player = nil
            self.stopPlaybackTimeChecker()
        }
        if self.playerLayer != nil {
            self.playerLayer?.removeFromSuperlayer()
            self.playerLayer = nil
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    func addPlayerEndTimeObserver() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let `self` = self,
                let currentPlayerItem = notification.object as? AVPlayerItem,
                currentPlayerItem == self.playerItem
                else {
                    return
            }
            self.connVideoPlay()
        }
    }
}

// MARK: TrimmerViewDelegate
extension TrimEditorViewController: TrimmerViewDelegate {
    
    func trimmerDidBeginDragging(_ trimmer: TrimmerView, with currentTimeTrim: CMTime) {
        
    }
    
    func trimmerDidChangeDraggingPosition(_ trimmer: TrimmerView, with currentTimeTrim: CMTime) {
        if let player = player {
            player.seek(to: currentTimeTrim, toleranceBefore: tolerance, toleranceAfter: tolerance)
        }
    }
    
    func trimmerDidEndDragging(_ trimmer: TrimmerView, with startTime: CMTime, endTime: CMTime) {
        if let player = player {
            player.seek(to: startTime, toleranceBefore: tolerance, toleranceAfter: tolerance)
        }
    }
    
    func trimmerScrubbingDidChange(_ trimmer: TrimmerView, with currentTimeScrub: CMTime) {
        if let player = player {
            player.seek(to: currentTimeScrub, toleranceBefore: tolerance, toleranceAfter: tolerance)
            
            if let cell: ImageCollectionViewCell = self.storyCollectionView.cellForItem(at: getCurrentIndexPath) as? ImageCollectionViewCell {
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
            if let player = player {
                player.seek(to: currentTimeScrub, toleranceBefore: tolerance, toleranceAfter: tolerance)
                if player.timeControlStatus == .playing {
                    player.play()
                }
            }
        }
    }
    
    func trimVideo(_ trimmer: TrimmerView, with currentTimeScrub: CMTime) {
        guard (currentTimeScrub.seconds - trimmer.startTime!.seconds) >= 3 else {
            self.view.makeToast(R.string.localizable.minimum3SecondRequireToSplitOrTrim())
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            if let player = player {
                player.seek(to: currentTimeScrub, toleranceBefore: tolerance, toleranceAfter: tolerance)
                if player.timeControlStatus == .playing {
                    player.play()
                }
            }
            return
        }
        
        do {
            try Utils.time {
                self.registerCombineAllData(data: self.storyEditorMedias)
                guard let asset = currentAsset(index: self.currentPage) else {
                    return
                }
                let trimmed = try asset.assetByTrimming(startTime: CMTime.init(seconds: currentTimeScrub.seconds, preferredTimescale: 10000), endTime: trimmer.endTime!)
                let thumbimage = UIImage.getThumbnailFrom(asset: trimmed) ?? UIImage()
                
                self.storyEditorMedias[self.currentPage][0] = StoryEditorMedia(type: .video(thumbimage, trimmed))
                do {
                    try Utils.time {
                        let trimmedAsset = try asset.assetByTrimming(startTime: trimmer.startTime!, endTime: CMTime.init(seconds: currentTimeScrub.seconds, preferredTimescale: 10000))
                        let image = UIImage.getThumbnailFrom(asset: trimmedAsset) ?? UIImage()
                        self.storyEditorMedias.insert([StoryEditorMedia(type: .video(image, trimmedAsset))], at: self.currentPage)
                        
                        self.connVideoPlay(isReload: true)
                    }
                } catch let error {
                    print("\(error)")
                }
            }
        } catch let error {
            print("\(error)")
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
            guard let currentPlayer = self.player else { return }
            currentPlayer.pause()
            stopPlaybackTimeChecker()
        }
    }
    
    @objc func enterForeground(_ notifi: Notification) {
        if isViewAppear {
            guard let currentPlayer = self.player else { return }
            if currentPlayer.timeControlStatus == .playing {
                currentPlayer.play()
                startPlaybackTimeChecker()
            }
        }
    }
}
extension TrimEditorViewController {
    
    func connVideoPlay(isReload: Bool = false) {
        
        if !self.isEditMode || isReload {
            self.currentPlayVideo += 1
            if self.currentPlayVideo == self.storyEditorMedias.count {
                self.currentPlayVideo = 0
            }
            self.currentPage = self.currentPlayVideo
            if self.storyEditorMedias.count == 1 {
                self.isEditMode = true
            }
            self.selectedItem = self.currentPage
            
            self.storyCollectionView.reloadData()
            guard let currentAsset = self.currentAsset(index: self.currentPage) else {
                return
            }
            
            self.loadViewWith(asset: currentAsset)
        } else {
            self.player?.seek(to: CMTime.zero)
            self.player?.play()
        }
        if let player = self.player, !self.storyEditorMedias.isEmpty {
            if let cell: ImageCollectionViewCell = self.storyCollectionView.cellForItem(at: self.getCurrentIndexPath) as? ImageCollectionViewCell {
                guard let startTime = cell.trimmerView.startTime else {
                    return
                }
                player.seek(to: startTime, toleranceBefore: self.tolerance, toleranceAfter: self.tolerance)
            }
        }
    }
}

extension TrimEditorViewController {
    
    @IBAction func btnShowHideSegmentEditOption(_ sender: UIButton) {
        segmentEditOptionView.isHidden = !sender.isSelected
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func segmentBeforeMergeButtonTapped(_ sender: AnyObject) {
        mergeVideo(isBefore: true)
    }
    
    @IBAction func segmentAfterMergeButtonTapped(_ sender: AnyObject) {
        mergeVideo(isBefore: false)
    }
    
    @IBAction func resequenceButtonTapped(_ sender: AnyObject) {
        resequenceButton.isSelected = !resequenceButton.isSelected
        if resequenceButton.isSelected {
            resequenceLabel.text = "Rearranged"
        } else {
            resequenceLabel.text = "Original"
        }
        isOriginalSequence = !isOriginalSequence
        self.storyCollectionView.reloadData()
    }
    
    @IBAction func mergeButtonTapped(_ sender: AnyObject) {
        mergeButton.isSelected = !mergeButton.isSelected
        isMovable = !isMovable
    }
    
    @IBAction func undoSButtonTapped(_ sender: AnyObject) {
        if undoMgr.canUndo() {
            undoMgr.undo()
            DispatchQueue.main.async {
                self.combineButton.isSelected = false
                self.storyCollectionView.reloadData()
            }
        }
    }
    
    @IBAction func resetButtonTapped(_ sender: AnyObject) {
        if undoMgr.canUndo() {
            undoMgr.removeAll()
            combineButton.isSelected = false
            videoUrls.removeAll()
            mergeButton.isSelected = false
            
            storyEditorMedias = resetStoryEditorMedias
            self.currentPlayVideo = -1
            self.connVideoPlay(isReload: true)
        }
    }
    
    @IBAction func combineButtonTapped(_ sender: AnyObject) {
        guard !combineButton.isSelected else {
            return
        }
        combineButton.isSelected = !combineButton.isSelected
        DispatchQueue.main.async {
            if self.storyEditorMedias.count > 1 {
                self.registerCombineAllData(data: self.storyEditorMedias)
                
                let storySegment = StorySegment()
                for (index, _) in self.storyEditorMedias.enumerated() {
                    for (indexSecond, _) in self.storyEditorMedias[index].enumerated() {
                        guard let asset = self.currentAsset(index: index, secondIndex: indexSecond) else {
                            return
                        }
                        storySegment.addAsset(StoryAsset(asset: asset))
                    }
                }
                
                let thumbimage = UIImage.getThumbnailFrom(asset: storySegment.assetRepresentingSegments()) ?? UIImage()
                
                guard let tempFirstSegment = self.storyEditorMedias[0][0].copy() as? StoryEditorMedia else {
                    return
                }
                self.storyEditorMedias.removeAll()
                tempFirstSegment.type = .video(thumbimage, storySegment.assetRepresentingSegments())
                self.storyEditorMedias.append([tempFirstSegment])
                self.currentPlayVideo = -1
                self.connVideoPlay(isReload: true)
            }
        }
    }
    
    func getCombineUndo(data: [[StoryEditorMedia]]) -> (() -> Void) {
        return { [weak self] () -> Void in
            guard let `self` = self else {
                return
            }
            self.storyEditorMedias.removeAll()
            for video in data {
                self.storyEditorMedias.append(video)
            }
        }
    }
    
    func registerCombineAllData(data: [[StoryEditorMedia]]) {
        undoMgr.add(undo: getCombineUndo(data: data), redo: getCombineUndo(data: data))
    }
    
    func registerReplaceNewData(data: [StoryEditorMedia], index: Int) {
        undoMgr.add(undo: getReplaceRedo(model: data, index: index), redo: getReplaceRedo(model: data, index: index))
    }
    
    func registerReplaceDeleteData(data: [StoryEditorMedia], index: Int) {
        undoMgr.add(undo: getReplace(model: data, index: index), redo: getReplace(model: data, index: index))
    }
    
    func getReplace(model: [StoryEditorMedia], index: Int) -> (() -> Void) {
        return { [weak self]() -> Void in
            guard let `self` = self else {
                return
            }
            self.storyEditorMedias.insert(model, at: index)
        }
    }
    
    func getReplaceRedo(model: [StoryEditorMedia], index: Int) -> (() -> Void) {
        return { [weak self] () -> Void in
            guard let `self` = self else {
                return
            }
            self.storyEditorMedias.remove(at: index)
            self.storyEditorMedias.insert(model, at: index)
        }
    }
    
    func mergeVideo(isBefore: Bool) {
        DispatchQueue.main.async {
            if self.lastMergeCell != self.draggingCell {
                let model = self.storyEditorMedias[self.lastMergeCell!.row]
                let modelDrag = self.storyEditorMedias[self.draggingCell!.row]
                
                self.registerReplaceNewData(data: model, index: self.lastMergeCell!.row)
                self.registerReplaceDeleteData(data: modelDrag, index: self.draggingCell!.row)
                
                for videosItem in self.storyEditorMedias[self.draggingCell!.row] {
                    if isBefore {
                        self.storyEditorMedias[self.lastMergeCell!.row].insert(videosItem, at: 0)
                    } else {
                        self.storyEditorMedias[self.lastMergeCell!.row].append(videosItem)
                    }
                }
                let storySegment = StorySegment()
                for videosItem in self.storyEditorMedias[self.lastMergeCell!.row] {
                    var avAsset: AVAsset?
                    switch videosItem.type {
                    case .image:
                        break
                    case let .video(_, asset):
                        avAsset = asset
                    }
                    guard let currentAsset = avAsset else {
                        return
                    }
                    storySegment.addAsset(StoryAsset(asset: currentAsset))
                }
                let thumbimage = UIImage.getThumbnailFrom(asset: storySegment.assetRepresentingSegments()) ?? UIImage()
                
                self.storyEditorMedias[self.lastMergeCell!.row][0].type = StoryEditorType.video(thumbimage, storySegment.assetRepresentingSegments())
                
                self.storyEditorMedias.remove(at: self.draggingCell!.row)
            }
            
            self.currentPlayVideo = -1
            self.connVideoPlay(isReload: true)
            self.segmentTypeMergeView.isHidden = true
            self.segmentEditOptionView.isHidden = false
            self.storyCollectionView.isUserInteractionEnabled = true
            self.bottomToolbar.isHidden = false
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        if let doneHandler = self.doneHandler {
            var urls: [StoryEditorMedia] = []
            for video in self.storyEditorMedias {
                urls.append(video.first!)
            }
            doneHandler(urls)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func playPauseClicked(_ sender: Any) {
        if let player = self.player {
            if player.timeControlStatus == .playing {
                player.pause()
                btnPlayPause.isSelected = false
            } else {
                player.play()
                btnPlayPause.isSelected = true
            }
        }
    }
    
    @IBAction func mergeButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        isMergeModeEnable = sender.isSelected
    }
    
    @IBAction func btnTrimClick(_ sender: UIButton) {
        if let player = self.player, !isMergeModeEnable {
            if let cell: ImageCollectionViewCell = self.storyCollectionView.cellForItem(at: getCurrentIndexPath) as? ImageCollectionViewCell {
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
    
}

extension TrimEditorViewController: DragAndDropCollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, indexPathForDataItem dataItem: AnyObject) -> IndexPath? {
        guard let data = dataItem as? StoryEditorMedia,
            let index = self.storyEditorMedias.first!.firstIndex(where: { $0 == data }) else {
                return nil
        }
        return IndexPath(item: index, section: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, dataItemForIndexPath indexPath: IndexPath) -> AnyObject {
        return storyEditorMedias[indexPath.item][0]
    }
    
    func collectionView(_ collectionView: UICollectionView, moveDataItemFromIndexPath from: IndexPath, toIndexPath to: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, insertDataItem dataItem: AnyObject, atIndexPath indexPath: IndexPath) {
       
    }
    
    func collectionView(_ collectionView: UICollectionView, deleteDataItemAtIndexPath indexPath: IndexPath) -> Void {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellIsDraggableAtIndexPath indexPath: IndexPath) -> Bool {
        return isMovable
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, startDrag dataItem: AnyObject, atIndexPath indexPath: IndexPath) {
        print("Stat Move : \(indexPath)")
        draggingCell = indexPath
        if let player = self.player {
            if player.timeControlStatus == .playing {
                player.pause()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, stopDrag dataItem: AnyObject, atIndexPath indexPath: IndexPath) {
        print("stopDrag : \(indexPath)")
        self.lastMergeCell = indexPath
        
        if self.lastMergeCell != self.draggingCell {
            storyCollectionView.isUserInteractionEnabled = false
            segmentEditOptionView.isHidden = true
            segmentEditOptionButton.isHidden = true
            segmentTypeMergeView.isHidden = false
            bottomToolbar.isHidden = true
        }
    }
    
}
