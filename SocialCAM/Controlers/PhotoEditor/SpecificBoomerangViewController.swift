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
    @IBOutlet weak var firstBoomerangView: UIView! {
        didSet {
            firstBoomerangView.translatesAutoresizingMaskIntoConstraints = true
        }
    }
    @IBOutlet weak var secondBoomerangView: UIView! {
        didSet {
            secondBoomerangView.translatesAutoresizingMaskIntoConstraints = true
        }
    }
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var timePointerView: UIView! {
        didSet {
            timePointerView.translatesAutoresizingMaskIntoConstraints = true
        }
    }
    @IBOutlet weak var addBoomerangButton: UIButton!
    
    private var isFirstBoomerangSelected = true {
        didSet {
            let firstViewColor = isFirstBoomerangSelected ? R.color.quetag_darkPastelGreen() : R.color.storytag_fadedRed()
            let secondViewColor = isFirstBoomerangSelected ? R.color.storytag_fadedRed() : R.color.quetag_darkPastelGreen()
            firstBoomerangView.layer.borderColor = firstViewColor?.cgColor
            secondBoomerangView.layer.borderColor = secondViewColor?.cgColor
        }
    }

    private var timeObserver: Any?
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var playerLayer: AVPlayerLayer?
    
    public var currentAsset: AVAsset?
    public weak var delegate: SpecificBoomerangDelegate?

    private var firstBoomerangValue = SpecificBoomerangValue(maxTime: 3.0,
                                                             speedScale: 2,
                                                             currentLoopCount: 7,
                                                             maxLoopCount: 7,
                                                             needToReverse: true)
    
    private var secondBoomerangValue = SpecificBoomerangValue(maxTime: 3.0,
                                                              speedScale: 2,
                                                              currentLoopCount: 7,
                                                              maxLoopCount: 7,
                                                              needToReverse: true)


    private var needToReverse = true
    
    private var needToChangeScale = false
    
    private var canStartSecondPart = false

    private var exportSession: SpecificBoomerangExportSession?
    private var loadingView: LoadingView?

    override func viewDidLoad() {
        super.viewDidLoad()
        addPlayerLayer()
        loadViewWith(asset: currentAsset)
        if let asset = currentAsset,
            asset.duration.seconds < 6 {
            addBoomerangButton.isEnabled = false
            addBoomerangButton.alpha = 0.5
        }
    }
    
    func calculateBoomerangTimeRange() {
        firstBoomerangValue.timeRange = getTimeRange(from: firstBoomerangView.frame,
                                                     maxTime: firstBoomerangValue.maxTime)
        secondBoomerangValue.timeRange = getTimeRange(from: secondBoomerangView.frame,
                                                      maxTime: secondBoomerangValue.maxTime)
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
        player?.pause()
        stopObservePlayerTime()
        exportSession?.cancelExporting()
        self.exportSession = nil
        loadingView?.hide()
        self.loadingView = nil
    }
    
    @objc func enterForeground(_ notifi: Notification) {
        player?.play()
        startObservePlayerTime()
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
    
    func widthOfBoomerangView(maxTime: Double) -> CGFloat {
        return CGFloat(maxTime)
            * trimmerView.thumbnailsView.durationSize
            / CGFloat(trimmerView.thumbnailsView.videoDuration.seconds)
    }
    
    func pausePlayer() {
        player?.pause()
        self.stopObservePlayerTime()
    }
    
    func playPlayer() {
        player?.play()
        self.startObservePlayerTime()
    }
    
    @objc func onTap(_ gesture: UITapGestureRecognizer) {
        isFirstBoomerangSelected = gesture.view == firstBoomerangView
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
            resetBoomerangTimeRange()
            player?.seekToSeconds(seekSeconds) { finished in
                self.player?.play()
            }
        } else if gesture.view == firstBoomerangView {
            isFirstBoomerangSelected = true
            let locationX = gesture.location(in: self.view).x
            let newFrame = getBoomerangPartFrame(centerX: locationX,
                                                 frame: firstBoomerangView.frame)
            
            let firstBoxEndX = newFrame.origin.x + firstBoomerangView.bounds.width
            let secondBoxStartX = secondBoomerangView.frame.origin.x
            
            if secondBoxStartX > firstBoxEndX {
                firstBoomerangView.frame = newFrame
            } else {
                firstBoomerangView.frame.origin.x = secondBoxStartX - firstBoomerangView.bounds.width
            }
            firstBoomerangValue.timeRange = getTimeRange(from: firstBoomerangView.frame,
                                                         maxTime: firstBoomerangValue.maxTime)
            
        } else if gesture.view == secondBoomerangView {
            isFirstBoomerangSelected = false
            let locationX = gesture.location(in: self.view).x
            let newFrame = getBoomerangPartFrame(centerX: locationX,
                                                 frame: secondBoomerangView.frame)
            
            let firstBoxEndX = firstBoomerangView.frame.origin.x + firstBoomerangView.bounds.width
            let secondBoxStartX = newFrame.origin.x
            
            if secondBoxStartX > firstBoxEndX {
                secondBoomerangView.frame = newFrame
            } else {
                secondBoomerangView.frame.origin.x = firstBoxEndX
            }
            secondBoomerangValue.timeRange = getTimeRange(from: secondBoomerangView.frame,
                                                          maxTime: secondBoomerangValue.maxTime)
        }
        if gesture.state == .began {
            resetBoomerangTimeRange()
            pausePlayer()
        } else if gesture.state == .ended {
            playPlayer()
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
    
    @IBAction func onChangeBoomerangLoop(_ sender: UIButton) {
        let supportedLoop = ["1", "2", "3"]
        BasePopConfiguration.shared.backgoundTintColor = R.color.appWhiteColor()!
        BasePopConfiguration.shared.menuWidth = 120
        BasePopConfiguration.shared.showCheckMark = .checkmark
        BasePopConfiguration.shared.joinText = "loop"
        let boomerangMaxLoopCount = isFirstBoomerangSelected ? firstBoomerangValue.maxLoopCount : secondBoomerangValue.maxLoopCount
        BasePopOverMenu
            .showForSender(sender: sender,
                           with: supportedLoop,
                           withSelectedName: "\((boomerangMaxLoopCount - 1)/2)",
                done: { (selectedIndex) -> Void in
                    let selectedValue = supportedLoop[selectedIndex]
                    if self.isFirstBoomerangSelected {
                        self.firstBoomerangValue.maxLoopCount = Int(selectedValue)!*2 + 1
                    } else {
                        self.secondBoomerangValue.maxLoopCount = Int(selectedValue)!*2 + 1
                    }
                    self.changeBoomerangTime()
            },cancel: {
                
            })

    }
    
    @IBAction func onChangeBoomerangSeconds(_ sender: UIButton) {
        let supportedSeconds = ["1", "2", "3"]
        BasePopConfiguration.shared.backgoundTintColor = R.color.appWhiteColor()!
        BasePopConfiguration.shared.menuWidth = 120
        BasePopConfiguration.shared.showCheckMark = .checkmark
        BasePopConfiguration.shared.joinText = "sec"
        let boomerangMaxTime = isFirstBoomerangSelected ? firstBoomerangValue.maxTime : secondBoomerangValue.maxTime
        BasePopOverMenu
            .showForSender(sender: sender,
                           with: supportedSeconds,
                           withSelectedName: "\(Int(boomerangMaxTime))",
                done: { (selectedIndex) -> Void in
                    let selectedValue = supportedSeconds[selectedIndex]
                    if self.isFirstBoomerangSelected {
                        self.firstBoomerangValue.maxTime = Double(selectedValue)!
                    } else {
                        self.secondBoomerangValue.maxTime = Double(selectedValue)!
                    }
                    self.changeBoomerangTime()
            },cancel: {
                
            })
    }
    
    @IBAction func onChangeMode(_ sender: UIButton) {
        let supportedModes = ["Forward", "Reverse"]
        BasePopConfiguration.shared.backgoundTintColor = R.color.appWhiteColor()!
        BasePopConfiguration.shared.menuWidth = 120
        BasePopConfiguration.shared.showCheckMark = .checkmark
        BasePopConfiguration.shared.joinText = ""
        let selectedName = needToReverse ? supportedModes[1] : supportedModes[0]
        BasePopOverMenu
            .showForSender(sender: sender,
                           with: supportedModes,
                           withSelectedName: selectedName,
                done: { (selectedIndex) -> Void in
                    self.needToReverse = selectedIndex > 0
                    self.resetBoomerangTimeRange()
            },cancel: {
                
            })
    }
    
    func hideAddBoomerangButton(hide: Bool) {
        addBoomerangButton.isEnabled = !hide
        addBoomerangButton.alpha = hide ? 0.5 : 1.0
    }
    
    func hideBoomerangView(_ view: UIView) {
        view.frame.size.width = 0
        view.frame.origin.x = view == secondBoomerangView ? trimmerView.frame.width : 0
        view.isHidden = true
    }
    
    @IBAction func onAddBoomerangView(_ sender: UIButton) {
        hideAddBoomerangButton(hide: true)
        
        firstBoomerangView.isHidden = false
        firstBoomerangView.frame.origin.x = 0
        firstBoomerangView.frame.size.width = widthOfBoomerangView(maxTime: firstBoomerangValue.maxTime)
        firstBoomerangValue.timeRange = getTimeRange(from: firstBoomerangView.frame,
                                                     maxTime: firstBoomerangValue.maxTime)

        secondBoomerangView.isHidden = false
        secondBoomerangView.frame.size.width = widthOfBoomerangView(maxTime: secondBoomerangValue.maxTime)
        secondBoomerangView.frame.origin.x = trimmerView.bounds.width - secondBoomerangView.bounds.width
        secondBoomerangValue.timeRange = getTimeRange(from: secondBoomerangView.frame,
                                                      maxTime: secondBoomerangValue.maxTime)
        resetBoomerangTimeRange()
    }
    
    @IBAction func onDone(_ sender: UIButton) {
        guard let asset = self.currentAsset,
            let config = SpecificBoomerangExportConfig(firstBoomerangValue: firstBoomerangValue, secondBoomerangValue: secondBoomerangValue) else {
                return
        }
        resetBoomerangTimeRange()
        self.pausePlayer()
        let loadingView = LoadingView.instanceFromNib()
        loadingView.loadingViewShow = false
        loadingView.shouldCancelShow = false
        loadingView.shouldDescriptionTextShow = true
        loadingView.show(on: self.view)

        exportSession = SpecificBoomerangExportSession(config: config)
        loadingView.cancelClick = { cancelled in
            if cancelled {
                DispatchQueue.main.async {
                    self.exportSession?.cancelExporting()
                    self.exportSession = nil
                    self.loadingView?.hide()
                    self.loadingView = nil
                }
            }
        }
        exportSession?.export(for: asset, progress: { progress in
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
        guard !firstBoomerangView.isHidden, !secondBoomerangView.isHidden else {
            return
        }
        let boomerangView = isFirstBoomerangSelected ? firstBoomerangView : secondBoomerangView
        hideBoomerangView(boomerangView!)
        isFirstBoomerangSelected = isFirstBoomerangSelected ? false : isFirstBoomerangSelected
        calculateBoomerangTimeRange()
        resetBoomerangTimeRange()
        hideAddBoomerangButton(hide: false)
        self.player?.rate = 1.0
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func resetBoomerangTimeRange() {
        needToChangeScale = false
        let currentTime = self.player?.currentTime() ?? .zero
        canStartSecondPart = (firstBoomerangValue.timeRange?.end.seconds ?? 0) < currentTime.seconds
        firstBoomerangValue.resetLoopCount()
        secondBoomerangValue.resetLoopCount()
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
        loadAsset(asset)
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
        firstBoomerangView.frame.size.width = widthOfBoomerangView(maxTime: firstBoomerangValue.maxTime)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        firstBoomerangView.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        firstBoomerangView.addGestureRecognizer(tapGesture)
    }
    
    func setupSecondBoomerangPart() {
        secondBoomerangView.frame.size.width = widthOfBoomerangView(maxTime: secondBoomerangValue.maxTime)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        secondBoomerangView.addGestureRecognizer(panGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        secondBoomerangView.addGestureRecognizer(tapGesture)
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
        setupSecondBoomerangPart()
        let timePointerGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        timePointerView.addGestureRecognizer(timePointerGesture)
        hideBoomerangView(secondBoomerangView)
        calculateBoomerangTimeRange()
        resetBoomerangTimeRange()
    }
    
    func changeBoomerangTime() {
        firstBoomerangView.frame.size.width = widthOfBoomerangView(maxTime: firstBoomerangValue.maxTime)
        secondBoomerangView.frame.size.width = widthOfBoomerangView(maxTime: secondBoomerangValue.maxTime)
        calculateBoomerangTimeRange()
        resetBoomerangTimeRange()
    }
}

// MARK: Observer
extension SpecificBoomerangViewController {
    
    func changeScale() {
        let boomerangLoopCount = isFirstBoomerangSelected ? firstBoomerangValue.currentLoopCount : secondBoomerangValue.currentLoopCount
        let boomerangSpeedScale = isFirstBoomerangSelected ? firstBoomerangValue.speedScale : secondBoomerangValue.speedScale
        let boomerangTimeRange = isFirstBoomerangSelected ? firstBoomerangValue.timeRange : secondBoomerangValue.timeRange
        guard boomerangTimeRange != .zero else {
            return
        }
        if boomerangLoopCount == 0 {
            self.resetBoomerangTimeRange()
            self.canStartSecondPart = false
            self.player?.rate = 1.0
        } else if boomerangLoopCount % 2 == 0 {
            if self.needToReverse {
                if self.player?.rate != -(Float(boomerangSpeedScale)) {
                    if isFirstBoomerangSelected {
                        firstBoomerangValue.currentLoopCount -= 1
                    } else {
                        secondBoomerangValue.currentLoopCount -= 1
                    }
                    self.player?.rate = -(Float(boomerangSpeedScale))
                }
            } else {
                if isFirstBoomerangSelected {
                    firstBoomerangValue.currentLoopCount -= 2
                } else {
                    secondBoomerangValue.currentLoopCount -= 2
                }
                self.player?.seekToSeconds((boomerangTimeRange?.start ?? .zero).seconds)
            }
        } else {
            if self.player?.rate != Float(boomerangSpeedScale) {
                if isFirstBoomerangSelected {
                    firstBoomerangValue.currentLoopCount -= 1
                } else {
                    secondBoomerangValue.currentLoopCount -= 1
                }
                self.player?.rate = Float(boomerangSpeedScale)
            }
        }
    }
    
    func addPlayerEndTimeObserver() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let `self` = self,
                let currentPlayerItem = notification.object as? AVPlayerItem,
                currentPlayerItem == self.playerItem
                else {
                    return
            }
            if self.needToChangeScale {
                self.needToChangeScale = false
                self.changeScale()
            } else {
                self.resetBoomerangTimeRange()
                self.canStartSecondPart = false
                self.player?.seekToSeconds(CMTime.zero.seconds) { (_) in
                    self.player?.play()
                }
            }
        }
    }
    
    func startObservePlayerTime() {
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 24), queue: DispatchQueue.main, using: { [weak self] time in
            guard let `self` = self, let currentAsset = self.currentAsset else {
                return
            }
            
            if let boomerangTimeRange = self.firstBoomerangValue.timeRange,
                boomerangTimeRange != .zero,
                !self.canStartSecondPart {
                self.changePlayerSpeed(time: time,
                                       boomerangTimeRange: boomerangTimeRange,
                                       isSecondPart: false)
            } else if let boomerangTimeRange = self.secondBoomerangValue.timeRange,
                boomerangTimeRange != .zero,
                !self.secondBoomerangView.isHidden {
                self.changePlayerSpeed(time: time,
                                       boomerangTimeRange: boomerangTimeRange,
                                       isSecondPart: true)
            } else {
                
            }
            
            let totalSeconds = currentAsset.duration.seconds
            let centerX = time.seconds*Double(self.trimmerView.bounds.width)/totalSeconds
            self.timePointerView.center.x = CGFloat(centerX)

        })
    }
    
    func changePlayerSpeed(time: CMTime, boomerangTimeRange: CMTimeRange, isSecondPart: Bool) {
        let boomerangMaxLoopCount = isFirstBoomerangSelected ? firstBoomerangValue.maxLoopCount : secondBoomerangValue.maxLoopCount
        let boomerangLoopCount = isFirstBoomerangSelected ? firstBoomerangValue.currentLoopCount : secondBoomerangValue.currentLoopCount
        let boomerangSpeedScale = isFirstBoomerangSelected ? firstBoomerangValue.speedScale : secondBoomerangValue.speedScale
        print("playerspeed \(self.player?.rate)")
        print("boomerangLoopCount \(boomerangLoopCount)")
        print("boomerangMaxLoopCount \(boomerangMaxLoopCount)")
        if time.seconds >= boomerangTimeRange.start.seconds,
            time.seconds <= boomerangTimeRange.end.seconds {
            self.needToChangeScale = true
            if boomerangLoopCount == boomerangMaxLoopCount {
                if isFirstBoomerangSelected {
                    firstBoomerangValue.currentLoopCount -= 1
                } else {
                    secondBoomerangValue.currentLoopCount -= 1
                }
                self.player?.rate = Float(boomerangSpeedScale)
            }
        } else if self.needToChangeScale {
            self.needToChangeScale = false
            if boomerangLoopCount == 0 {
                self.resetBoomerangTimeRange()
                self.canStartSecondPart = !isSecondPart
                self.player?.rate = 1.0
            } else if boomerangLoopCount % 2 == 0 {
                if self.needToReverse {
                    if self.player?.rate != -(Float(boomerangSpeedScale)) {
                        if isFirstBoomerangSelected {
                            firstBoomerangValue.currentLoopCount -= 1
                        } else {
                            secondBoomerangValue.currentLoopCount -= 1
                        }
                        self.player?.rate = -(Float(boomerangSpeedScale))
                    }
                } else {
                    if isFirstBoomerangSelected {
                        firstBoomerangValue.currentLoopCount -= 2
                    } else {
                        secondBoomerangValue.currentLoopCount -= 2
                    }
                    print("seek to \(boomerangTimeRange.start.seconds)")
                    self.player?.seekToSeconds(boomerangTimeRange.start.seconds)
                }
            } else {
                if self.player?.rate != Float(boomerangSpeedScale) {
                    if isFirstBoomerangSelected {
                        firstBoomerangValue.currentLoopCount -= 1
                    } else {
                        secondBoomerangValue.currentLoopCount -= 1
                    }
                    self.player?.rate = Float(boomerangSpeedScale)
                }
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
