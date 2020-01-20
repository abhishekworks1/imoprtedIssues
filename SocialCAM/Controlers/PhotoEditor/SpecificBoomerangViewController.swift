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

protocol SpecificBoomerangDelegate {
    func didBoomerang(_ url: URL)
}

class SpecificBoomerangViewController: UIViewController {

    @IBOutlet weak var trimmerView: TrimmerView!
    @IBOutlet weak var boomerangCropView: UIView! {
        didSet {
            boomerangCropView.translatesAutoresizingMaskIntoConstraints = true
        }
    }
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var timePointerView: UIView! {
        didSet {
            timePointerView.translatesAutoresizingMaskIntoConstraints = true
        }
    }

    private var timeObserver: Any?
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var playerLayer: AVPlayerLayer?
    
    public var currentAsset: AVAsset?
    public var delegate: SpecificBoomerangDelegate?

    private var shouldPlay = true
        
    private var boomerangMaxTime = 3.0
    private let boomerangSpeedScale: Int = 2
    private var boomerangMaxLoopCount = 7
    
    private var boomerangLoopCount = 5
    private var boomerangTimeRange: CMTimeRange?
    private var boomerangLoopStartTime: Double = 0
    private var needToSeek = false

    private var needToReverse = true
    
    private var needToChangeScale = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPlayerLayer()
        loadViewWith(asset: currentAsset)
    }
    
    func calculateBoomerangTimeRange() {
        guard let currentAsset = self.currentAsset else {
            return
        }
        let totalSeconds = currentAsset.duration.seconds
        let startSeconds = Double(boomerangCropView.frame.origin.x)*totalSeconds/Double(trimmerView.bounds.width)
        let endSeconds = startSeconds + boomerangMaxTime
        boomerangTimeRange = CMTimeRange(start: CMTime(value: CMTimeValue(startSeconds*100000), timescale: 100000),
                                         end: CMTime(value: CMTimeValue(endSeconds*100000), timescale: 100000))
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
    }
    
    @objc func enterForeground(_ notifi: Notification) {
        if shouldPlay {
            player?.play()
            startObservePlayerTime()
        }
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
    
    var minimumDistanceBetweenDraggableViews: CGFloat? {
        return CGFloat(boomerangMaxTime)
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
        } else {
            let newCenterX = gesture.location(in: self.view).x
            let newFrameX = newCenterX + boomerangCropView.bounds.width/2
            
            if newCenterX > boomerangCropView.center.x {
                if newFrameX < trimmerView.bounds.width {
                    boomerangCropView.center.x = newCenterX
                } else {
                    boomerangCropView.frame.origin.x = trimmerView.bounds.width - boomerangCropView.bounds.width
                }
            } else if newCenterX < boomerangCropView.center.x {
                if (newCenterX - boomerangCropView.bounds.width/2) > 0 {
                    boomerangCropView.center.x = newCenterX
                } else {
                    boomerangCropView.frame.origin.x = 0
                }
            }
            
            let totalSeconds = currentAsset.duration.seconds
            let startSeconds = Double(boomerangCropView.frame.origin.x)*totalSeconds/Double(trimmerView.bounds.width)
            let endSeconds = startSeconds + boomerangMaxTime
            boomerangTimeRange = CMTimeRange(start: CMTime(value: CMTimeValue(startSeconds*100000), timescale: 100000),
                                             end: CMTime(value: CMTimeValue(endSeconds*100000), timescale: 100000))
        }
        if gesture.state == .began {
            resetBoomerangTimeRange()
            pausePlayer()
        } else if gesture.state == .ended {
            playPlayer()
        }
        
    }
    
    @IBAction func onChangeBoomerangLoop(_ sender: UIButton) {
        let supportedLoop = ["1", "2", "3"]
        BasePopConfiguration.shared.backgoundTintColor = R.color.appWhiteColor()!
        BasePopConfiguration.shared.menuWidth = 120
        BasePopConfiguration.shared.showCheckMark = .checkmark
        BasePopConfiguration.shared.joinText = "loop"
        BasePopOverMenu
            .showForSender(sender: sender,
                           with: supportedLoop,
                           withSelectedName: "\((boomerangMaxLoopCount - 1)/2)",
                done: { (selectedIndex) -> Void in
                    let selectedValue = supportedLoop[selectedIndex]
                    self.boomerangMaxLoopCount = Int(selectedValue)!*2 + 1
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
        BasePopOverMenu
            .showForSender(sender: sender,
                           with: supportedSeconds,
                           withSelectedName: "\(Int(boomerangMaxTime))",
                done: { (selectedIndex) -> Void in
                    let selectedValue = supportedSeconds[selectedIndex]
                    self.boomerangMaxTime = Double(selectedValue)!
                    self.changeBoomerangTime()
            },cancel: {
                
            })
    }
    
    @IBAction func onChangeMode(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        needToReverse = sender.isSelected
        resetBoomerangTimeRange()
    }
    
    @IBAction func onDone(_ sender: UIButton) {
        guard let boomerangTimeRange = self.boomerangTimeRange,
            let asset = self.currentAsset else {
                return
        }
        resetBoomerangTimeRange()
        self.pausePlayer()
        let config = SpecificBoomerangExportConfig(firstBoomerangRange: boomerangTimeRange,
                                                   boomerangSpeedScale: boomerangSpeedScale,
                                                   boomerangLoopCount: boomerangMaxLoopCount,
                                                   needToReverse: needToReverse)
        
        let loadingView = LoadingView.instanceFromNib()
        loadingView.loadingViewShow = false
        loadingView.shouldCancelShow = false
        loadingView.shouldDescriptionTextShow = true
        loadingView.show(on: self.view)
        
        let exportSession = SpecificBoomerangExportSession(config: config)
        loadingView.cancelClick = { cancelled in
            if cancelled {
                DispatchQueue.main.async {
                    exportSession.cancelExporting()
                    loadingView.hide()
                }
            }
        }
        exportSession.export(for: asset, progress: { progress in
            loadingView.progressView.setProgress(to: Double(progress), withAnimation: true)
        }) { [weak self] url in
            loadingView.hide()
            guard let `self` = self, let url = url else {
                return
            }
            DispatchQueue.main.async {
                self.delegate?.didBoomerang(url)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func resetBoomerangTimeRange() {
        boomerangLoopStartTime = 0
        boomerangLoopCount = boomerangMaxLoopCount
        boomerangLoopStartTime = .zero
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
    
    func loadAsset(_ asset: AVAsset) {
        trimmerView.layoutIfNeeded()
        trimmerView.minVideoDurationAfterTrimming = boomerangMaxTime
        trimmerView.thumbnailsView.asset = asset
        trimmerView.thumbnailsView.isReloadImages = true
        trimmerView.layoutIfNeeded()
        trimmerView.isHideLeftRightView = true
        trimmerView.cutView.isHidden = true
        trimmerView.timePointerView.isHidden = true
        boomerangCropView.frame.size.width = minimumDistanceBetweenDraggableViews!
        let cropViewGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        boomerangCropView.addGestureRecognizer(cropViewGesture)
        let timePointerGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        timePointerView.addGestureRecognizer(timePointerGesture)
        calculateBoomerangTimeRange()
    }
    
    func changeBoomerangTime() {
        trimmerView.minVideoDurationAfterTrimming = boomerangMaxTime
        boomerangCropView.frame.size.width = minimumDistanceBetweenDraggableViews!
        calculateBoomerangTimeRange()
        resetBoomerangTimeRange()
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
            if self.needToChangeScale {
                self.needToChangeScale = false
                if self.boomerangLoopCount == 0 {
                    self.resetBoomerangTimeRange()
                    self.player?.rate = 1.0
                } else if self.boomerangLoopCount % 2 == 0 {
                    if self.needToReverse {
                        if self.player?.rate != -(Float(self.boomerangSpeedScale)) {
                            self.boomerangLoopCount -= 1
                            self.player?.rate = -(Float(self.boomerangSpeedScale))
                        }
                    } else {
                        self.boomerangLoopCount -= 2
                        self.player?.seekToSeconds((self.boomerangTimeRange?.start ?? .zero).seconds)
                    }
                } else {
                    if self.player?.rate != Float(self.boomerangSpeedScale) {
                        self.boomerangLoopCount -= 1
                        self.player?.rate = Float(self.boomerangSpeedScale)
                    }
                }
            } else {
                self.resetBoomerangTimeRange()
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
            
            if let boomerangTimeRange = self.boomerangTimeRange {
                print("boomerangTime: \(boomerangTimeRange.start.seconds)")
                print("currentTime: \(time.seconds)")
                if time.seconds >= boomerangTimeRange.start.seconds,
                    time.seconds <= boomerangTimeRange.end.seconds {
                    self.needToChangeScale = true
                    if self.boomerangLoopCount == self.boomerangMaxLoopCount {
                        self.boomerangLoopCount -= 1
                        self.player?.rate = Float(self.boomerangSpeedScale)
                    }
                } else if self.needToChangeScale {
                    self.needToChangeScale = false
                    if self.boomerangLoopCount == 0 {
                        self.resetBoomerangTimeRange()
                        self.player?.rate = 1.0
                    } else if self.boomerangLoopCount % 2 == 0 {
                        if self.needToReverse {
                            if self.player?.rate != -(Float(self.boomerangSpeedScale)) {
                                self.boomerangLoopCount -= 1
                                self.player?.rate = -(Float(self.boomerangSpeedScale))
                            }
                        } else {
                            self.boomerangLoopCount -= 2
                            print("seek to \(boomerangTimeRange.start.seconds)")
                            self.player?.seekToSeconds(boomerangTimeRange.start.seconds)
                        }
                    } else {
                        if self.player?.rate != Float(self.boomerangSpeedScale) {
                            self.boomerangLoopCount -= 1
                            self.player?.rate = Float(self.boomerangSpeedScale)
                        }
                    }
                }
                let totalSeconds = currentAsset.duration.seconds
                let centerX = time.seconds*Double(self.trimmerView.bounds.width)/totalSeconds
                self.timePointerView.center.x = CGFloat(centerX)
            }
            
            
        })
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
