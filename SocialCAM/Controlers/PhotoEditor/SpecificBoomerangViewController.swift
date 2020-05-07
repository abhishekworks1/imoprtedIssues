//
//  SelectBoomerangViewController.swift
//  VideoEditor
//
//  Created by Jasmin Patel on 31/12/19.
//  Copyright © 2019 Jasmin Patel. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

protocol SpecificBoomerangDelegate: class {
    func didBoomerang(_ url: URL)
}

class SpecificBoomerangViewController: UIViewController {

    @IBOutlet weak var trimmerSuperView: UIView!
    @IBOutlet weak var trimmerView: TrimmerView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var timePointerView: UIView! {
        didSet {
            timePointerView.translatesAutoresizingMaskIntoConstraints = true
        }
    }
    @IBOutlet weak var addBoomerangButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var changeSpeedButton: UIButton!
    @IBOutlet weak var changeLoopButton: UIButton!
    @IBOutlet weak var changeModeButton: UIButton!
    @IBOutlet weak var changeSecondsButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton! {
        didSet {
            deleteButton.isHidden = true
        }
    }

    private var timeObserver: Any?
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var playerLayer: AVPlayerLayer?
    
    public var currentAsset: AVAsset?
    public weak var delegate: SpecificBoomerangDelegate?
    
    private var boomerangValues: [SpecificBoomerangValue] = []
        
    private var exportSession: SpecificBoomerangExportSession?
    private var loadingView: LoadingView?
    private var manuallyPaused = false
    
    private let maximumSize: CGFloat = 1280
    
    private let maximumFrame: Float = 30
    
    private var loopOptions = BoomerangOptions<Int>(type: .loop, selectedIndex: 2)
    
    private var secondOptions = BoomerangOptions<Double>(type: .second, selectedIndex: 2)

    private var speedOptions = BoomerangOptions<Int>(type: .speed, selectedIndex: 1)
    
    private var modeOptions = BoomerangOptions<Bool>(type: .mode, selectedIndex: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        addPlayerLayer()
        loadViewWith(asset: currentAsset)
        if let asset = currentAsset,
            asset.duration.seconds < 6 {
            addBoomerangButton.isEnabled = false
            addBoomerangButton.alpha = 0.5
        }
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressToVideoView(_:)))
        longPressGesture.minimumPressDuration = 0.2
        self.videoView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func onLongPressToVideoView(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began || gesture.state == .changed {
            pausePlayer()
        } else {
            playPlayer()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeState()
        playerLayer?.frame = CGRect(origin: .zero,
                                    size: videoView.frame.size)
        if let asset = currentAsset {
            loadAsset(asset)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopObservePlayerTime()
        removeObserveState()
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
        pausePlayer()
        exportSession?.cancelExporting()
        self.exportSession = nil
        loadingView?.hide()
        self.loadingView = nil
    }
    
    @objc func enterForeground(_ notifi: Notification) {
        playPlayer()
    }
    
    deinit {
        print("Deinit \(self.description)")
        stopObservePlayerTime()
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerItem = nil
        playerLayer = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    func pausePlayer() {
        player?.pause()
        self.stopObservePlayerTime()
        playPauseButton.isSelected = true
    }
    
    func playPlayer() {
        guard !manuallyPaused else {
            return
        }
        player?.play()
        self.startObservePlayerTime()
        playPauseButton.isSelected = false
    }
    
    @objc func onTap(_ gesture: UITapGestureRecognizer) {
        for boomerangValue in boomerangValues {
            boomerangValue.isSelected = boomerangValue.boomerangView == gesture.view
        }
        changeBoomerangOptions()
    }
    
    @objc func onPan(_ gesture: UIPanGestureRecognizer) {
        guard let currentAsset = self.currentAsset else {
            return
        }
        if gesture.view == timePointerView {
            let newCenterX = gesture.location(in: self.view).x
            timePointerView.center.x = newCenterX
            let totalSeconds = currentAsset.duration.seconds
            let seekSeconds = Double(timePointerView.center.x)*totalSeconds/Double(trimmerView.bounds.width)
            resetBoomerangValues()
            player?.seekToSeconds(seekSeconds)
        } else {
            manageBoomerangViewGesture(gesture.view!,
                                       locationX: gesture.location(in: self.view).x)
        }
        if gesture.state == .began {
            resetBoomerangValues()
            pausePlayer()
        } else if gesture.state == .ended {
            playPlayer()
        }
    }
    
    func changeBoomerangOptions() {
        guard let boomerangValue = boomerangValues.filter({ return $0.isSelected })[safe: 0] else {
            return
        }
        self.changeSpeedButton.setTitle("\(boomerangValue.speedScale)x",
                                        for: .normal)
        self.changeLoopButton.setTitle("\((boomerangValue.maxLoopCount - 1)/2)", for: .normal)
        self.changeSecondsButton.setTitle("\(Int(boomerangValue.maxTime))", for: .normal)
        let image = boomerangValue.needToReverse ? R.image.reverseBoom() : R.image.reverseBoomSelected()
        self.changeModeButton.setImage(image, for: .normal)
    }
    
    func manageBoomerangViewGesture(_ gestureView: UIView, locationX: CGFloat) {
        boomerangValues.sort {
            return $0.boomerangView.frame.origin.x < $1.boomerangView.frame.origin.x
        }
        var nextView: UIView?
        var previousView: UIView?
        var currentView: UIView?
        var selectedIndex: Int = 0
        for (index, boomerangValue) in boomerangValues.enumerated() {
            if boomerangValue.boomerangView == gestureView {
                selectedIndex = index
                currentView = boomerangValue.boomerangView
                nextView = boomerangValues[safe: index + 1]?.boomerangView
                previousView = boomerangValues[safe: index - 1]?.boomerangView
                boomerangValue.isSelected = true
            } else {
                boomerangValue.isSelected = false
            }
        }
        changeBoomerangOptions()
        let newFrame = getBoomerangPartFrame(centerX: locationX,
                                             frame: currentView?.frame ?? .zero)
        if nextView == nil, previousView == nil, let view = currentView {
            view.frame = newFrame
        } else if nextView == nil, let view = currentView, let previousView = previousView {
            let previousViewFrameX = previousView.frame.maxX
            if newFrame.origin.x > previousViewFrameX {
                view.frame = newFrame
            } else {
                view.frame.origin.x = previousViewFrameX
            }
        } else if previousView == nil, let view = currentView, let nextView = nextView {
            let nextViewFrameX = nextView.frame.minX
            if newFrame.maxX < nextViewFrameX {
                view.frame = newFrame
            } else {
                view.frame.origin.x = nextViewFrameX - view.frame.width
            }
        } else if let view = currentView, let nextView = nextView, let previousView = previousView {
            let nextViewFrameX = nextView.frame.minX
            let previousViewFrameX = previousView.frame.maxX
            
            if (newFrame.origin.x > previousViewFrameX) && (newFrame.maxX < nextViewFrameX) {
                view.frame = newFrame
            } else {
                if newFrame.origin.x < previousViewFrameX {
                    view.frame.origin.x = previousViewFrameX
                } else if newFrame.maxX > nextViewFrameX {
                    view.frame.origin.x = nextViewFrameX - view.frame.width
                }
            }
        }
        if let asset = currentAsset {
            boomerangValues[selectedIndex].updateTimeRange(for: asset, boundsWidth: trimmerView.viewWidth)
        }
    }
    
    func getBoomerangPartFrame(centerX: CGFloat, frame: CGRect) -> CGRect {
        let newFrameX = centerX + frame.width/2
        var newFrame = frame
        if centerX > frame.midX {
            if newFrameX < trimmerView.bounds.width {
                newFrame.origin.x = centerX - frame.width/2
            } else {
                newFrame.origin.x = trimmerView.bounds.width - frame.width
            }
        } else if centerX < frame.midX {
            if (centerX - frame.width/2) > 0 {
                newFrame.origin.x = centerX - frame.width/2
            } else {
                newFrame.origin.x = 0
            }
        }
        return newFrame
    }
         
    func getTimeRange(from frame: CGRect, maxTime: Double) -> CMTimeRange {
        guard frame.width > 0 else {
            return .zero
        }
        let totalSeconds = currentAsset?.duration.seconds ?? 0
        let startSeconds = Double(frame.origin.x)*totalSeconds/Double(trimmerView.bounds.width)
        let endSeconds = startSeconds + maxTime
        return CMTimeRange(start: CMTime(value: CMTimeValue(startSeconds*100000), timescale: 100000),
                           end: CMTime(value: CMTimeValue(endSeconds*100000), timescale: 100000))
    }
    
    @IBAction func onChangeBoomerangSpeedScale(_ sender: UIButton) {
        if let selectedBoomerangValue = boomerangValues.filter({ return $0.isSelected })[safe: 0],
            let index = self.speedOptions.options?.firstIndex(where: { return $0.value == selectedBoomerangValue.speedScale }) {
            self.speedOptions.selectedIndex = index
        }
        
        showPopOverMenu(sender: sender, options: speedOptions.displayOptions, selectedOption: speedOptions.selectedOption?.displayText ?? "", joinText: R.string.localizable.speed()) { selectedIndex in
            self.speedOptions.selectedIndex = selectedIndex
            self.changeSpeedButton.setTitle(self.speedOptions.selectedOption?.displayText, for: .normal)
            self.boomerangValues.filter({ return $0.isSelected })[safe: 0]?.speedScale = self.speedOptions.selectedOption!.value
            self.resetBoomerangOptions()
        }
    }
    
    @IBAction func onChangeBoomerangLoop(_ sender: UIButton) {
        if let selectedBoomerangValue = boomerangValues.filter({ return $0.isSelected })[safe: 0],
            let index = self.loopOptions.options?.firstIndex(where: { return $0.value == selectedBoomerangValue.maxLoopCount }) {
            self.loopOptions.selectedIndex = index
        }
        showPopOverMenu(sender: sender, options: loopOptions.displayOptions, selectedOption: loopOptions.selectedOption?.displayText ?? "") { selectedIndex in
            self.loopOptions.selectedIndex = selectedIndex
            let selectedValue = self.loopOptions.selectedOption?.displayText.split(separator: " ")[safe: 0] ?? ""
            self.changeLoopButton.setTitle(String(selectedValue), for: .normal)
            self.boomerangValues.filter({ return $0.isSelected })[safe: 0]?.maxLoopCount = self.loopOptions.selectedOption!.value
            self.resetBoomerangOptions()
        }
    }
    
    @IBAction func onChangeBoomerangSeconds(_ sender: UIButton) {
        if let selectedBoomerangValue = boomerangValues.filter({ return $0.isSelected })[safe: 0],
            let index = self.secondOptions.options?.firstIndex(where: { return $0.value == selectedBoomerangValue.maxTime }) {
            self.secondOptions.selectedIndex = index
        }
        showPopOverMenu(sender: sender, options: secondOptions.displayOptions, selectedOption: secondOptions.selectedOption?.displayText ?? "") { selectedIndex in
            self.secondOptions.selectedIndex = selectedIndex
            let selectedValue = self.secondOptions.selectedOption!.displayText.split(separator: " ")[safe: 0] ?? ""
            self.changeSecondsButton.setTitle(String(selectedValue), for: .normal)
            self.boomerangValues.filter({ return $0.isSelected })[safe: 0]?.maxTime = self.secondOptions.selectedOption!.value
            self.resetBoomerangOptions()
        }
    }
    
    @IBAction func onChangeMode(_ sender: UIButton) {
        if let selectedBoomerangValue = boomerangValues.filter({ return $0.isSelected })[safe: 0],
            let index = self.modeOptions.options?.firstIndex(where: { return $0.value == selectedBoomerangValue.needToReverse }) {
            self.modeOptions.selectedIndex = index
        }
        showPopOverMenu(sender: sender, options: modeOptions.displayOptions, selectedOption: modeOptions.selectedOption?.displayText ?? "") { selectedIndex in
            self.modeOptions.selectedIndex = selectedIndex
            let needToReverse = self.modeOptions.selectedOption?.value ?? false
            let image = needToReverse ? R.image.reverseBoom() : R.image.reverseBoomSelected()
            self.changeModeButton.setImage(image, for: .normal)
            self.boomerangValues.filter({ return $0.isSelected })[safe: 0]?.needToReverse = needToReverse
            self.resetBoomerangOptions()
        }
    }
    
    func showPopOverMenu(sender: UIView, options: [String], selectedOption: String, joinText: String = "", done: @escaping (Int) -> Void) {
        BasePopConfiguration.shared.backgoundTintColor = R.color.appWhiteColor()!
        BasePopConfiguration.shared.menuWidth = 120
        BasePopConfiguration.shared.showCheckMark = .checkmark
        BasePopConfiguration.shared.joinText = joinText
        BasePopOverMenu
            .showForSender(sender: sender,
                           with: options,
                           withSelectedName: selectedOption,
                done: { (selectedIndex) -> Void in
                    done(selectedIndex)
            },cancel: {
                
            })
    }
    
    func hideAddBoomerangButton(hide: Bool) {
        addBoomerangButton.isEnabled = !hide
        addBoomerangButton.alpha = hide ? 0.5 : 1.0
    }
        
    @IBAction func onAddBoomerangView(_ sender: UIButton) {
        guard let asset = currentAsset, boomerangValues.count < 5 else {
            return
        }
        addBoomerangView()
        resetBoomerangOptions()
        deleteButton.isHidden = boomerangValues.count == 1
        let maxCount = Int(asset.duration.seconds/15) + 1
        let shouldHide = boomerangValues.count == 5 ? true : boomerangValues.count == maxCount
        hideAddBoomerangButton(hide: shouldHide)
    }
    
    func needToExport() -> Bool {
        guard let asset = currentAsset,
            let videoTrack = asset.tracks(withMediaType: .video).first else {
                return false
        }
        let width = videoTrack.naturalSize.width
        let height = videoTrack.naturalSize.height
        
        if width > height {
            if width <= maximumSize {
                if videoTrack.nominalFrameRate <= maximumFrame {
                    return false
                }
            }
        } else {
            if height <= maximumSize {
                if videoTrack.nominalFrameRate <= maximumFrame {
                    return false
                }
            }
        }
        return true
    }
         
    @IBAction func onDone(_ sender: UIButton) {
        guard let config = SpecificBoomerangExportConfig(boomerangValues: boomerangValues) else {
            return
        }
        config.adjustBoomerangValues()
        resetBoomerangValues()
        self.pausePlayer()
        loadingView = LoadingView.instanceFromNib()
        loadingView?.loadingViewShow = false
        loadingView?.shouldCancelShow = false
        loadingView?.shouldDescriptionTextShow = true
        loadingView?.show(on: self.view)

        exportSession = SpecificBoomerangExportSession(config: config)
        var viExportSession: VIExportSession?
        if let asset = self.currentAsset,
            needToExport() {
            viExportSession = VIExportSession(asset: asset)
            viExportSession?.progressHandler = { [weak self] (progress) in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    self.loadingView?.progressView.setProgress(to: Double(progress*0.25), withAnimation: true)
                }
            }
            viExportSession?.completionHandler = { [weak self] (error) in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    if let error = error {
                        print(error.localizedDescription)
                    } else if let url = viExportSession?.exportConfiguration.outputURL {
                        if let videoTrack = self.currentAsset?.tracks(withMediaType: .video).first {
                            print(videoTrack.naturalSize)
                        }

                        self.currentAsset = AVAsset(url: url)
                        if let videoTrack = self.currentAsset?.tracks(withMediaType: .video).first {
                            print(videoTrack.naturalSize)
                        }
                        self.exportBoomerangVideo(isResized: true)
                    }
                }
            }
            viExportSession?.export()
        } else {
            exportBoomerangVideo()
        }
        loadingView?.cancelClick = { cancelled in
            if cancelled {
                DispatchQueue.main.async {
                    viExportSession?.cancelExport()
                    self.exportSession?.cancelExporting()
                    self.exportSession = nil
                    self.loadingView?.hide()
                    self.loadingView = nil
                    self.playPlayer()
                }
            }
        }
    }
    
    func exportBoomerangVideo(isResized: Bool = false) {
        guard let asset = self.currentAsset else {
            return
        }
        self.exportSession?.export(for: asset, progress: { progress in
            var progress = isResized ? (0.25 + progress*0.75) : progress
            progress = progress == 0 ? 0.25 : progress
            self.loadingView?.progressView.setProgress(to: Double(progress), withAnimation: true)
        }) { [weak self] url in
            self?.loadingView?.hide()
            self?.loadingView = nil
            guard let `self` = self, let url = url else {
                return
            }
            DispatchQueue.main.async {
                self.delegate?.didBoomerang(url)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func onDeleteBoomerangPart(_ sender: UIButton) {
        guard let asset = currentAsset, boomerangValues.count > 1 else {
            return
        }
        boomerangValues.filter({ return $0.isSelected })[safe: 0]?.boomerangView.removeFromSuperview()
        boomerangValues.removeAll { return $0.isSelected }
        boomerangValues[safe: 0]?.isSelected = true
        let maxCount = Int(asset.duration.seconds/15) + 1
        hideAddBoomerangButton(hide: boomerangValues.count == maxCount)
        deleteButton.isHidden = boomerangValues.count == 1
        changeBoomerangOptions()
        self.player?.rate = 1.0
    }
    
    @IBAction func onPlayPause(_ sender: UIButton) {
        manuallyPaused = !manuallyPaused
        sender.isSelected ? playPlayer() : pausePlayer()
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
        
}

// MARK: Setup View
extension SpecificBoomerangViewController {
    
    func addPlayerLayer() {
        videoView.layoutIfNeeded()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = CGRect(origin: .zero,
                                    size: videoView.frame.size)
        playerLayer?.isOpaque = false
        
        playerLayer?.backgroundColor = UIColor.clear.cgColor
        playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        if let aLayer = playerLayer {
            videoView.layer.addSublayer(aLayer)
        }
    }
    
    func setupPlayer(for playerItem: AVPlayerItem) {
        if player != nil {
            player?.pause()
            player = nil
        }
        player = AVPlayer(playerItem: playerItem)
        playerLayer?.player = player
    }
    
    func loadViewWith(asset: AVAsset?) {
        if let asset = asset {
            addPlayerIfNeeded(for: asset)
        }
    }
    
    func addPlayerIfNeeded(for asset: AVAsset) {
        playerItem = AVPlayerItem.init(asset: asset)
        if playerLayer == nil {
            addPlayerLayer()
        }
        setupPlayer(for: playerItem!)
        player?.play()
        
        if player != nil {
            addPlayerEndTimeObserver()
            startObservePlayerTime()
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
}

extension SpecificBoomerangViewController {
    
    func setupFirstBoomerangPart() {
        if boomerangValues.isEmpty {
            addBoomerangView(isSelected: true)
        }
    }
    
    func addBoomerangView(isSelected: Bool = false) {
        let boomerangValue = SpecificBoomerangValue.defaultInit()
        boomerangValue.isSelected = isSelected
        boomerangValue.boomerangView.frame = CGRect(x: 0,
                                                    y: 5,
                                                    width: 50,
                                                    height: trimmerSuperView.frame.height - 10)
        boomerangValue.updateBoomerangViewSize(duration: trimmerView.thumbnailsView.videoDuration.seconds, durationSize: trimmerView.thumbnailsView.durationSize)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        boomerangValue.boomerangView.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        boomerangValue.boomerangView.addGestureRecognizer(tapGesture)
        for (index, boomValue) in boomerangValues.enumerated() {
            if let nextBoomValue = boomerangValues[safe: index + 1] {
                if abs(boomValue.boomerangView.frame.maxX - nextBoomValue.boomerangView.frame.minX) > boomerangValue.boomerangView.frame.width {
                    boomerangValue.boomerangView.frame.origin.x = boomValue.boomerangView.frame.maxX
                    break
                }
            } else {
                if abs(boomValue.boomerangView.frame.maxX - trimmerView.frame.width) < boomerangValue.boomerangView.frame.width {
                    boomerangValue.boomerangView.frame.origin.x = 0
                } else {
                    boomerangValue.boomerangView.frame.origin.x = boomValue.boomerangView.frame.maxX
                }
                break
            }
        }
        trimmerSuperView.addSubview(boomerangValue.boomerangView)
        boomerangValues.append(boomerangValue)
        changeBoomerangOptions()
    }
    
    func loadAsset(_ asset: AVAsset) {
        trimmerView.layoutIfNeeded()
        trimmerView.minVideoDurationAfterTrimming = 3.0
        trimmerView.thumbnailsView.asset = asset
        trimmerView.thumbnailsView.isReloadImages = true
        trimmerView.layoutIfNeeded()
        trimmerView.isHideLeftRightView = true
        trimmerView.cutView.isHidden = true
        trimmerView.timePointerView.isHidden = true
        setupFirstBoomerangPart()
        let timePointerGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        timePointerView.addGestureRecognizer(timePointerGesture)
        resetBoomerangOptions()
        let maxCount = Int(asset.duration.seconds/15) + 1
        hideAddBoomerangButton(hide: boomerangValues.count == maxCount)
    }
    
    func resetBoomerangOptions() {
        guard let asset = currentAsset else {
            return
        }
        for boomerangValue in boomerangValues {
            boomerangValue.updateBoomerangViewSize(duration: trimmerView.thumbnailsView.videoDuration.seconds, durationSize: trimmerView.thumbnailsView.durationSize)
            boomerangValue.updateTimeRange(for: asset, boundsWidth: trimmerView.viewWidth)
            boomerangValue.reset()
        }
    }
        
    func resetBoomerangValues() {
        for boomerangValue in boomerangValues {
            boomerangValue.reset()
        }
    }

}

// MARK: Observer
extension SpecificBoomerangViewController {
        
    func addPlayerEndTimeObserver() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let `self` = self,
                let currentPlayerItem = notification.object as? AVPlayerItem,
                currentPlayerItem == self.playerItem
                else {
                    return
            }
            let filteredBoomerangValues = self.boomerangValues.filter({ return $0.needToChangeScale })
            if filteredBoomerangValues.count == 0 {
                self.pausePlayer()
                self.resetBoomerangValues()
                self.player?.seekToSeconds(CMTime.zero.seconds) { (_) in
                    self.playPlayer()
                }
            } else {
                for boomerangValue in self.boomerangValues {
                    if boomerangValue.timeRange != .zero {
                        if boomerangValue.needToChangeScale {
                            self.changeScaleIfNeeded(for: boomerangValue)
                            break
                        }
                    }
                }
            }
        }
    }
    
    func startObservePlayerTime() {
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 24), queue: DispatchQueue.main, using: { [weak self] time in
            guard let `self` = self, let currentAsset = self.currentAsset else {
                return
            }
            self.changePlayerSpeedIfNeeded(time: time)
            let totalSeconds = currentAsset.duration.seconds
            let centerX = time.seconds*Double(self.trimmerView.bounds.width)/totalSeconds
            self.timePointerView.center.x = CGFloat(centerX)
        })
    }
    
    func changePlayerSpeedIfNeeded(time: CMTime) {
        let currentBoomerangValue = boomerangValues.filter({ return $0.isRunning })[safe: 0]
        if let boomerangValue = currentBoomerangValue {
            _ = checkTimeRange(for: time, boomerangValue: boomerangValue)
        } else {
            for boomerangValue in boomerangValues {
                if checkTimeRange(for: time, boomerangValue: boomerangValue) {
                    break
                }
            }
        }
    }
    
    func checkTimeRange(for time: CMTime, boomerangValue: SpecificBoomerangValue) -> Bool {
        if boomerangValue.timeRange != .zero {
            if boomerangValue.timeRange.containsTime(time) {
                boomerangValue.needToChangeScale = true
                boomerangValue.isRunning = true
                if boomerangValue.currentLoopCount == boomerangValue.maxLoopCount {
                    boomerangValue.currentLoopCount -= 1
                    self.player?.rate = Float(boomerangValue.speedScale)
                }
                return true
            } else if boomerangValue.needToChangeScale {
                changeScaleIfNeeded(for: boomerangValue)
                return true
            } else if boomerangValue.isRunning {
                return true
            }
        }
        return false
    }
    
    func changeScaleIfNeeded(for boomerangValue: SpecificBoomerangValue) {
        boomerangValue.needToChangeScale = false
        if boomerangValue.currentLoopCount == 0 {
            boomerangValue.reset()
            self.player?.rate = 1.0
        } else if boomerangValue.currentLoopCount % 2 == 0 {
            if boomerangValue.needToReverse {
                if self.player?.rate != -(Float(boomerangValue.speedScale)) {
                    boomerangValue.currentLoopCount -= 1
                    self.player?.rate = -(Float(boomerangValue.speedScale))
                }
            } else {
                boomerangValue.currentLoopCount -= 2
                self.player?.seekToSeconds(boomerangValue.timeRange.start.seconds)
            }
        } else {
            if self.player?.rate != Float(boomerangValue.speedScale) {
                boomerangValue.currentLoopCount -= 1
                self.player?.rate = Float(boomerangValue.speedScale)
            }
        }
    }
    
    func stopObservePlayerTime() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    
}

extension AVPlayer {
    
    func seekToSeconds(_ seconds: Double, completionHandler: ((Bool) -> Void)? = nil) {
        let playerTimescale = currentItem?.asset.duration.timescale ?? 1
        let time = CMTime(seconds: seconds, preferredTimescale: playerTimescale)
        seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) {
            (finished) in
            completionHandler?(finished)
        }
    }
    
}
