//
//  MergeVideoVC.swift
//  SocialCAM
//
//  Created by Viraj Patel on 29/09/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit

class MergeVideoVC: UIViewController {
    
    @IBOutlet weak var storyCollectionView: DragAndDropCollectionView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var topToolbar: UIView!
    @IBOutlet weak var topGradient: UIView!
    @IBOutlet weak var bottomGradient: UIView!
    @IBOutlet open var btnPlayPause: UIButton!
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
    
    private var undoMgr = MyUndoManager<Void>()
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var playerLayer: AVPlayerLayer?
    private var draggingCell: IndexPath?
    private var lastMergeCell: IndexPath?
    
    private var isMovable: Bool = false
    private var dragAndDropManager: DragAndDropManager?
    
    private var currentPlayVideo: Int = -1
    private var isViewAppear = false
    private var currentPage: Int = 0
    
    // MARK: - Public Properties
    var videoUrls: [StoryEditorMedia] = []
    var storyEditorMedias: [[StoryEditorMedia]] = []
    var resetStoryEditorMedias: [[StoryEditorMedia]] = []
    var doneHandler: ((_ urls: [StoryEditorMedia]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        for videoSegment in videoUrls {
            storyEditorMedias.append([videoSegment])
            resetStoryEditorMedias.append([videoSegment])
        }
    }
    
    deinit {
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerItem = nil
        playerLayer = nil
        undoMgr.removeAll()
        NotificationCenter.default.removeObserver(self)
        print("Deinit \(self.description)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isViewAppear = true
        observeState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playerLayer?.frame = videoView.frame
        connVideoPlay(isReload: true)
        player?.isMuted = Defaults.shared.isEditSoundOff
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let player = player {
            player.pause()
        }
        removeObserveState()
    }
    
    fileprivate func setupLayout() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.storyCollectionView.register(R.nib.imageCollectionViewCell)
        self.dragAndDropManager = DragAndDropManager(canvas: self.view,
                                                     collectionViews: [self.storyCollectionView])
    }
    
    // MARK: - Private Functions
    private var getCurrentIndexPath: IndexPath {
        return IndexPath(row: self.currentPage, section: 0)
    }
    
    private func currentAsset(index: Int, secondIndex: Int = 0) -> AVAsset? {
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
    
    private func thumbImage(index: Int, secondIndex: Int = 0) -> UIImage? {
        guard let asset = currentAsset(index: index), let thumbImage = asset.thumbnailImage() else {
            return nil
        }
        return thumbImage
    }
}

// MARK: UICollectionViewDataSource
extension MergeVideoVC: UICollectionViewDataSource {
    
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
        let storySegment = storyEditorMedias[indexPath.row]
        guard let currentAsset = currentAsset(index: indexPath.row) else {
            return cell
        }
        cell.setLayout(indexPath: indexPath, currentPage: currentPage, currentAsset: currentAsset, storySegment: storySegment)
        cell.lblSegmentCount.text = " "
        if let draggingPathOfCellBeingDragged = self.storyCollectionView.draggingPathOfCellBeingDragged {
            if draggingPathOfCellBeingDragged.item == indexPath.item {
                cell.isHidden = true
            }
        }
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension MergeVideoVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentPlayVideo = indexPath.row
        if currentPlayVideo == storyEditorMedias.count {
            currentPlayVideo = 0
        }
        currentPage = currentPlayVideo
        storyCollectionView.reloadData()
        guard let currentAsset = self.currentAsset(index: self.currentPage) else {
            return
        }
        loadViewWith(asset: currentAsset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (Double(storyEditorMedias[indexPath.row].count * 35)), height: Double(98))
    }
    
}

extension MergeVideoVC {
    
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

// MARK: Observe
extension MergeVideoVC {
    
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
        }
    }
    
    @objc func enterForeground(_ notifi: Notification) {
        if isViewAppear {
            guard let currentPlayer = self.player else { return }
            if currentPlayer.timeControlStatus == .playing && !btnPlayPause.isSelected {
                currentPlayer.play()
            }
        }
    }
}
extension MergeVideoVC {
    
    func connVideoPlay(isReload: Bool = false) {
        if isReload {
            currentPlayVideo += 1
            if currentPlayVideo == storyEditorMedias.count {
                currentPlayVideo = 0
            }
            currentPage = currentPlayVideo
            
            storyCollectionView.reloadData()
            guard let currentAsset = self.currentAsset(index: self.currentPage) else {
                return
            }
            
            loadViewWith(asset: currentAsset)
        } else {
            self.player?.seek(to: CMTime.zero)
            self.player?.play()
            btnPlayPause.isSelected = true
        }
        
        if let player = self.player, !self.storyEditorMedias.isEmpty {
            if let cell: ImageCollectionViewCell = self.storyCollectionView.cellForItem(at: self.getCurrentIndexPath) as? ImageCollectionViewCell {
                guard let startTime = cell.trimmerView.startTime else {
                    return
                }
                player.seek(to: startTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            }
        }
    }
}

extension MergeVideoVC {
    
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
        storyCollectionView.reloadData()
    }
    
    @IBAction func mergeButtonTapped(_ sender: AnyObject) {
        mergeButton.isSelected = !mergeButton.isSelected
        isMovable = !isMovable
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
            currentPlayVideo = -1
            connVideoPlay(isReload: true)
        }
    }
    
    @IBAction func combineButtonTapped(_ sender: AnyObject) {
        btnPlayPause.isSelected = true
        guard !combineButton.isSelected else {
            return
        }
        mergeButton.isSelected = false
        isMovable = mergeButton.isSelected
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
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        if let doneHandler = self.doneHandler {
            var urls: [StoryEditorMedia] = []
            for video in storyEditorMedias {
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
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension MergeVideoVC: DragAndDropCollectionViewDataSource {
    
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
        draggingCell = indexPath
        if let player = self.player {
            if player.timeControlStatus == .playing {
                player.pause()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, stopDrag dataItem: AnyObject, atIndexPath indexPath: IndexPath?, sourceRect rect: CGRect) {
        guard let indexPath = indexPath else {
            return
        }
        lastMergeCell = indexPath
        
        if lastMergeCell != draggingCell {
            storyCollectionView.isUserInteractionEnabled = false
            segmentEditOptionView.isHidden = true
            segmentEditOptionButton.isHidden = true
            segmentTypeMergeView.isHidden = false
        } else {
            if let player = self.player {
                if player.timeControlStatus == .paused && btnPlayPause.isSelected {
                    player.play()
                }
            }
        }
    }
}
