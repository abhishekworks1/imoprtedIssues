//
//  TrimEditorViewController.swift
//  ProManager
//
//  Created by Viraj Patel on 15/11/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import AVKit

class TrimEditorViewController: UIViewController {
    @IBOutlet weak var postStoryButton: UIButton!
    @IBOutlet weak var storyExportLabel: UILabel!
    @IBOutlet weak var storyCollectionView: DragAndDropCollectionView!
    @IBOutlet weak var editStoryCollectionView: DragAndDropCollectionView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var topToolbar: UIView!
    @IBOutlet weak var bottomToolbar: UIView!
    @IBOutlet weak var topGradient: UIView!
    @IBOutlet weak var bottomGradient: UIView!
    @IBOutlet weak var storyView: UIView!
    @IBOutlet open var btnPlayPause: UIButton!
    @IBOutlet weak var splitView: UIView!
    @IBOutlet weak var mergeView: UIView!
    @IBOutlet weak var handlerModeView: UIView!
    @IBOutlet open var videoView: UIView!
    @IBOutlet weak var doneView: UIView!
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
    var isStartMovable: Bool = false
    
    // MARK: - Public Properties
    var videoUrls: [StoryEditorMedia] = []
    var storyEditorMedias: [[StoryEditorMedia]] = []
    var resetStoryEditorMedias: [[StoryEditorMedia]] = []
    
    var currentPlayVideo: Int = -1
    var isViewAppear = false
    var currentPage: Int = 0
    var playerObserver: Any?
    var isEditMode: Bool = true
    var heightConstraint: NSLayoutConstraint?
    var isPlayerInitialize = false
    var playbackTimeCheckerTimer: Timer?
    var doneHandler: ((_ urls: [StoryEditorMedia]) -> Void)?
    @IBInspectable open var isTimePrecisionInfinity: Bool = false
    var tolerance: CMTime {
        return isTimePrecisionInfinity ? CMTime.indefinite : CMTime.zero
    }
    var saveTime: CMTime = CMTime.zero
    
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
        guard let asset = currentAsset(index: index), let thumbImage = asset.thumbnailImage() else {
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
        doneView.alpha = 0.5
        doneView.isUserInteractionEnabled = false
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
        print("Deinit \(self.description)")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isViewAppear = true
        observeState()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playerLayer?.frame = videoView.frame
        if !isPlayerInitialize {
            isPlayerInitialize = true
            connVideoPlay(isReload: true)
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
    }
    
    fileprivate func setupLayout() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.storyCollectionView.register(R.nib.imageCollectionViewCell)
        self.editStoryCollectionView.register(R.nib.imageCollectionViewCell)
    }
    
    func getPosition(from time: CMTime, cell: ImageCollectionViewCell, index: IndexPath) -> CGFloat? {
        if let cell: ImageCollectionViewCell = self.storyCollectionView.cellForItem(at: getCurrentIndexPath) as? ImageCollectionViewCell {
            guard let currentAsset = currentAsset(index: self.currentPage) else {
                return 0
            }
            
            let timeRatio = CGFloat(time.value) * CGFloat(currentAsset.duration.timescale) /
                (CGFloat(time.timescale) * CGFloat(currentAsset.duration.value))
            return timeRatio * cell.bounds.width
        } else if let cell: ImageCollectionViewCell = self.editStoryCollectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? ImageCollectionViewCell {
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
        cell.imagesView.layoutIfNeeded()
        cell.videoPlayerPlayback(to: time, asset: cell.trimmerView.thumbnailsView.asset)
        cell.layoutIfNeeded()
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
        if isStartMovable {
            return
        }
        if let player = self.player {
            let playBackTime = player.currentTime()
            if let cell: ImageCollectionViewCell = self.editStoryCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? ImageCollectionViewCell {
                if !isStartMovable {
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
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let player = player {
            player.pause()
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let player = player {
            if player.timeControlStatus == .playing && !btnPlayPause.isSelected {
                player.play()
            }
            if let cell: ImageCollectionViewCell = self.storyCollectionView.cellForItem(at: getCurrentIndexPath) as? ImageCollectionViewCell {
                guard let startTime = cell.trimmerView.startTime else {
                    return
                }
                player.seek(to: startTime, toleranceBefore: tolerance, toleranceAfter: tolerance)
            } else if let cell: ImageCollectionViewCell = self.editStoryCollectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? ImageCollectionViewCell {
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
        if collectionView == self.editStoryCollectionView {
            return 1
        }
        return storyEditorMedias.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.imageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell else {
            fatalError("Unable to find cell with '\(R.nib.imageCollectionViewCell.identifier)' reuseIdentifier")
        }
        
        let storySegment = storyEditorMedias[indexPath.row]
        
        if collectionView == self.editStoryCollectionView {
            guard let currentSelectedAsset = currentAsset(index: currentPage) else {
                return cell
            }
            cell.setEditLayout(indexPath: indexPath, currentPage: currentPage, currentAsset: currentSelectedAsset)
        } else {
            guard let currentAsset = currentAsset(index: indexPath.row) else {
                return cell
            }
            cell.setLayout(indexPath: indexPath, currentPage: currentPage, currentAsset: currentAsset, storySegment: storySegment)
        }
        cell.trimmerView.delegate = self
        
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
            if currentPlayer.timeControlStatus == .playing && !self.btnPlayPause.isSelected {
                currentPlayer.play()
            }
        }
    }
}

// MARK: UICollectionViewDelegate
extension TrimEditorViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.editStoryCollectionView {
            return
        }
        currentPlayVideo = indexPath.row
        if currentPlayVideo == storyEditorMedias.count {
            currentPlayVideo = 0
        }
        currentPage = currentPlayVideo
        storyCollectionView.reloadData()
        editStoryCollectionView.reloadData()
        guard let currentAsset = self.currentAsset(index: currentPage) else {
            return
        }
        loadViewWith(asset: currentAsset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let storySegment = storyEditorMedias[indexPath.row]
        if collectionView == self.editStoryCollectionView {
            return CGSize(width: Double(self.view.frame.width - 40), height: Double(118 * 1.17))
        } else {
            return CGSize(width: (Double(storySegment.count * 35)), height: Double(98))
        }
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
        btnPlayPause.isSelected = true
        startPlaybackTimeChecker()
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
    
    func trimmerDidBeginDragging(_ trimmer: TrimmerView, with currentTimeTrim: CMTime, isLeftGesture: Bool) {
        if let player = player {
            isStartMovable = true
            player.pause()
            self.saveTime = player.currentTime()
        }
    }
    
    func trimmerDidChangeDraggingPosition(_ trimmer: TrimmerView, with currentTimeTrim: CMTime) {
        if let player = player,
           let cell: ImageCollectionViewCell = self.editStoryCollectionView.cellForItem(at: self.getCurrentIndexPath) as? ImageCollectionViewCell {
            player.seek(to: currentTimeTrim, toleranceBefore: tolerance, toleranceAfter: tolerance)
            self.seek(to: CMTime.init(seconds: currentTimeTrim.seconds, preferredTimescale: 10000), cell: cell)
        }
    }
    
    func trimmerDidEndDragging(_ trimmer: TrimmerView, with startTime: CMTime, endTime: CMTime, isLeftGesture: Bool) {
        if let player = player {
            isStartMovable = false
            DispatchQueue.main.async {
                if self.btnPlayPause.isSelected {
                    if !isLeftGesture {
                        guard let endTime = trimmer.endTime else {
                            return
                        }
                        let newEndTime = endTime - CMTime.init(seconds: 2, preferredTimescale: endTime.timescale)
                        player.seek(to: newEndTime, toleranceBefore: self.tolerance, toleranceAfter: self.tolerance)
                    }
                    player.play()
                }
            }
        }
    }
    
    func trimmerScrubbingDidChange(_ trimmer: TrimmerView, with currentTimeScrub: CMTime) {
        if let player = player {
            player.seek(to: currentTimeScrub, toleranceBefore: tolerance, toleranceAfter: tolerance)
            if player.timeControlStatus == .playing {
                player.pause()
            }
            if let cell: ImageCollectionViewCell = self.editStoryCollectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? ImageCollectionViewCell {
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
        // Todo: Swap to trim feature disable temp
        //if position.y >= -100 {
        // {
        if let player = player {
            player.seek(to: currentTimeScrub, toleranceBefore: tolerance, toleranceAfter: tolerance)
            if btnPlayPause.isSelected {
                player.play()
            }
        }
    }
    
    func trimVideo(_ trimmer: TrimmerView, with currentTimeScrub: CMTime) {
        guard (currentTimeScrub.seconds - trimmer.startTime!.seconds) >= 3 else {
            self.view.makeToast(R.string.localizable.minimum3SecondRequireToSplitOrTrim())
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            if let player = player {
                player.seek(to: currentTimeScrub, toleranceBefore: tolerance, toleranceAfter: tolerance)
                if player.timeControlStatus == .playing && !btnPlayPause.isSelected {
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
            self.btnPlayPause.isSelected = false
            stopPlaybackTimeChecker()
        }
    }
    
    @objc func enterForeground(_ notifi: Notification) {
        if isViewAppear {
            guard let currentPlayer = self.player else { return }
            if currentPlayer.timeControlStatus == .playing && !btnPlayPause.isSelected {
                currentPlayer.play()
            }
            startPlaybackTimeChecker()
        }
    }
}
extension TrimEditorViewController {
    
    func connVideoPlay(isReload: Bool = false) {
        if !isEditMode || isReload {
            currentPlayVideo += 1
            if currentPlayVideo == self.storyEditorMedias.count {
                currentPlayVideo = 0
            }
            currentPage = currentPlayVideo
            storyCollectionView.reloadData()
            editStoryCollectionView.reloadData()
            guard let currentAsset = self.currentAsset(index: currentPage) else {
                return
            }
            loadViewWith(asset: currentAsset)
        } else {
            player?.seek(to: CMTime.zero)
            player?.play()
            btnPlayPause.isSelected = true
        }
        
        if let player = self.player, !self.storyEditorMedias.isEmpty {
            if let cell: ImageCollectionViewCell = self.storyCollectionView.cellForItem(at: self.getCurrentIndexPath) as? ImageCollectionViewCell {
                guard let startTime = cell.trimmerView.startTime else {
                    return
                }
                player.seek(to: startTime, toleranceBefore: self.tolerance, toleranceAfter: self.tolerance)
            }
            if let cell: ImageCollectionViewCell = self.editStoryCollectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? ImageCollectionViewCell {
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
            resequenceLabel.text = R.string.localizable.rearranged()
        } else {
            resequenceLabel.text = R.string.localizable.original()
        }
        isOriginalSequence = !isOriginalSequence
        self.storyCollectionView.reloadData()
    }
    
    @IBAction func mergeButtonTapped(_ sender: AnyObject) {
        mergeButton.isSelected = !mergeButton.isSelected
        combineButton.isSelected = false
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
        mergeButton.isSelected = false
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
            self.editStoryCollectionView.isUserInteractionEnabled = true
            self.bottomToolbar.isHidden = false
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        guard let button = sender as? UIButton else {
            return
        }
        if button.tag == 1 {
            if isEditMode, let cell: ImageCollectionViewCell = self.editStoryCollectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? ImageCollectionViewCell {
                guard let startTime = cell.trimmerView.startTime, let endTime = cell.trimmerView.endTime else {
                    return
                }
                do {
                    try Utils.time {
                        guard let asset = currentAsset(index: self.currentPage) else {
                            return
                        }
                        let trimmedAsset = try asset.assetByTrimming(startTime: startTime, endTime: endTime)
                        
                        let thumbimage = UIImage.getThumbnailFrom(asset: trimmedAsset) ?? UIImage()
                        
                        self.storyEditorMedias[self.currentPage][0] = StoryEditorMedia(type: .video(thumbimage, trimmedAsset))
                        self.connVideoPlay(isReload: true)
                        cell.trimmerView.trimViewLeadingConstraint.constant = 0
                        cell.trimmerView.trimViewTrailingConstraint.constant = cell.trimmerView.frame.width
                    }
                } catch let error {
                    print("💩 \(error)")
                }
            }
        } else {
            if let doneHandler = self.doneHandler, isEditMode, let cell: ImageCollectionViewCell = self.editStoryCollectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? ImageCollectionViewCell {
                guard let startTime = cell.trimmerView.startTime, let endTime = cell.trimmerView.endTime else {
                    return
                }
                do {
                    try Utils.time {
                        guard let asset = currentAsset(index: self.currentPage) else {
                            return
                        }
                        let trimmedAsset = try asset.assetByTrimming(startTime: startTime, endTime: endTime)
                        
                        let thumbimage = UIImage.getThumbnailFrom(asset: trimmedAsset) ?? UIImage()
                        
                        self.storyEditorMedias[self.currentPage][0] = StoryEditorMedia(type: .video(thumbimage, trimmedAsset))
                        var urls: [StoryEditorMedia] = []
                        for video in self.storyEditorMedias {
                            urls.append(video.first!)
                        }
                        doneHandler(urls)
                    }
                } catch let error {
                    print("💩 \(error)")
                }
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func playPauseClicked(_ sender: Any) {
        if let player = self.player {
            if player.timeControlStatus == .playing {
                player.pause()
                btnPlayPause.isSelected = false
                doneView.alpha = 1
                doneView.isUserInteractionEnabled = true
            } else {
                player.play()
                btnPlayPause.isSelected = true
                
                doneView.alpha = 0.5
                doneView.isUserInteractionEnabled = false
            }
        }
    }
    
    @IBAction func handleButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if let player = self.player {
            if player.timeControlStatus == .playing {
                player.pause()
                btnPlayPause.isSelected = false
            }
        }
    }
    
    @IBAction func mergeButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnTrimClick(_ sender: UIButton) {
        if let player = self.player {
            if let cell: ImageCollectionViewCell = self.editStoryCollectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? ImageCollectionViewCell {
                guard let trimmerView = cell.trimmerView else {
                    return
                }
                combineButton.isSelected = false
                self.trimVideo(trimmerView, with: player.currentTime())
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
