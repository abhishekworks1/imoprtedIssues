//
//  SpeedViewController.swift
//  SocialCAM
//
//  Created by Viraj Patel on 09/12/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit
import SCRecorder
import TGPControls

class SpeedViewController: UIViewController {
    
    @IBOutlet weak var speedSliderView: UIView!
    @IBOutlet weak var speedSliderLabels: TGPCamelLabels! {
        didSet {
            speedSliderLabels.names = ["-3x", "-2x", "1x", "2x", "3x"]
            speedSlider.ticksListener = speedSliderLabels
        }
    }
    
    @IBOutlet weak var speedSlider: TGPDiscreteSlider! {
        didSet {
            speedSlider.addTarget(self, action: #selector(speedSliderValueChanged(_:)), for: UIControl.Event.valueChanged)
        }
    }
    
    @IBOutlet weak var circularProgress: CircularProgress! {
        didSet {
            circularProgress.startAngle = -90
            circularProgress.progressThickness = 0.2
            circularProgress.trackThickness = 0.75
            circularProgress.trackColor = ApplicationSettings.appLightGrayColor
            circularProgress.progressInsideFillColor = ApplicationSettings.appWhiteColor
            circularProgress.clockwise = true
            circularProgress.roundedCorners = true
            circularProgress.set(colors: UIColor.red)
        }
    }
    var photoTapGestureRecognizer: UITapGestureRecognizer?
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    var recoredButtonCenterPoint: CGPoint = CGPoint.init()
    var panStartPoint: CGPoint = .zero
    var panStartZoom: CGFloat = 0.0
    var lastZoomFactor: CGFloat = 1.0
    var videoSpeedType = VideoSpeedType.normal
    var isSpeedChanged = false
    var rate: Float = 0
    
    @IBOutlet open var baseFlowView: UIView!
    @IBOutlet open var baseChartView: UIView!
    
    @IBOutlet open var videoView: UIView!
    @IBOutlet open var coverView: UIView!
    @IBOutlet open var fullStackView: UIStackView!
    @IBOutlet open var fullView: UIView!
    @IBOutlet open var exportActivityIndicator: UIActivityIndicatorView!
    @IBOutlet open var btnMute: UIButton!
    @IBOutlet open var btnPlayPause: UIButton!
    @IBOutlet open var btnShowHideHistoGram: UIButton!
    @IBOutlet open var lblShowCurrentTime: UILabel!
    @IBOutlet weak var trimmerView: TrimmerView!
    @IBOutlet weak var deleteFlowPointButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var timeControlView: UIView! {
        didSet {
            timeControlView.isHidden = true
        }
    }
    @IBOutlet weak var flowTypeButton: UIButton!
    @IBOutlet weak var flowControlView: UIView!
    @IBOutlet weak var minimumSecondsLabel: UILabel!
    @IBOutlet weak var maximumSecondsLabel: UILabel!
    @IBOutlet weak var selectedSecondsLabel: UILabel!

    var flowChartView: FlowChartView!
    
    var playbackTimeCheckerTimer: Timer?
    var isMute: Bool = false
    
    var videoSegments: [SegmentVideos] = []
    
    var currentIndex: Int = 0
    var lastStartSeconds: Double = 0
    var currentAsset: AVAsset?
    
    var currentDotView: FlowDotView?
    
    var doneHandler: (([SegmentVideos]) -> Void)?
    
    var isExporting: Bool = false {
        didSet {
            doneButton.isHidden = isExporting
            exportActivityIndicator.isHidden = !isExporting
            if isExporting {
                exportActivityIndicator.startAnimating()
            } else {
                exportActivityIndicator.stopAnimating()
            }
        }
    }
    
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var playerLayer: AVPlayerLayer?
    
    var draggedSeconds: Double = 0
    
    var videoScalerParts: [VideoScalerPart] = [VideoScalerPart.init(startTime: 0, rate: 1)]
    
    var shouldPlayAfterDrag = true
    
    var timeSlider: PivotSlider?
    
    var scalerValues: [VideoScalerValue] = []
    
    var isTimeGraph: Bool {
        return !flowTypeButton.isSelected
    }
     
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopPlaybackTimeChecker()
        removeObserveState()
    }
    
    deinit {
        print("Deinit \(self.description)")
        stopPlaybackTimeChecker()
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerItem = nil
        playerLayer = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let yourAttributes = [NSAttributedString.Key.foregroundColor: ApplicationSettings.appWhiteColor, NSAttributedString.Key.font: UIFont.sfuiTextRegular]
        
        let finalString =  NSMutableAttributedString(string: "", attributes: yourAttributes as [NSAttributedString.Key: Any])
        self.lblShowCurrentTime.text = ""
        self.lblShowCurrentTime.attributedText = finalString
        self.playPauseClicked(btnPlayPause!)
        self.playPauseClicked(btnPlayPause!)
        observeState()
        playerLayer?.frame = videoView.frame
    }
    
    func hmsString(from seconds: Float) -> String {
        let roundedSeconds = Int(seconds.rounded())
        let hours = (roundedSeconds / 3600)
        let minutes = (roundedSeconds % 3600) / 60
        let seconds = (roundedSeconds % 3600) % 60
        func timeString(_ time: Int) -> String {
            return time < 10 ? "0\(time)" : "\(time)"
        }
        if hours > 0 {
            return "\(timeString(hours)):\(timeString(minutes)):\(timeString(seconds))"
        }
        return "\(timeString(minutes)):\(timeString(seconds))"
    }
    
    func currentTimeSliderSeconds() -> Float {
        let totalSeconds = Float(currentAsset?.duration.seconds ?? 0)
        let minimumSeconds = totalSeconds/3
        let maximumSeconds = totalSeconds*3

        var seconds = totalSeconds
        let value = timeSlider?.value ?? 0
        if value < 0 {
            seconds = totalSeconds - (totalSeconds - minimumSeconds)*abs(value)
        } else if value > 0 {
            seconds = totalSeconds + (maximumSeconds - totalSeconds)*value
        }
        return seconds
    }
        
    @objc func timeSliderValueChanged(_ sender: Any) {
        selectedSecondsLabel.text = hmsString(from: currentTimeSliderSeconds())
    }
    
    @objc func timeSliderEndTracking(_ sender: Any) {
        if let asset = timeSliderAsset() {
            playerItem = AVPlayerItem.init(asset: asset)
            player?.replaceCurrentItem(with: playerItem)
        }
        player?.seek(to: .zero)
    }
    
    func timeSliderAsset() -> AVMutableComposition? {
        guard let asset = currentAsset else {
            return nil
        }

        let seconds = currentTimeSliderSeconds()
        
        let timeScale: CMTimeScale = 1000000000
        let scaleValues = [VideoScalerValue(range: CMTimeRange(start: .zero,
                                                               duration: CMTimeMakeWithSeconds(asset.duration.seconds, preferredTimescale: timeScale)),
                                            duration: CMTimeMakeWithSeconds(Double(seconds), preferredTimescale: timeScale),
                                            rate: 1)]
        return VideoScaler.shared.scaleVideo(asset: asset, scalerValues: scaleValues).0
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
        btnPlayPause.isSelected = false
        stopPlaybackTimeChecker()
        shouldPlayAfterDrag = player?.isPlayingPlayer ?? true
    }
    
    @objc func enterForeground(_ notifi: Notification) {
        if shouldPlayAfterDrag {
            btnPlayPause.isSelected = true
            startPlaybackTimeChecker()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPlayerLayer()
        loadViewWith(asset: currentAsset)
        videoProgressViewGesture()
    }
    
    func videoProgressViewGesture() {
        self.longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureRecognizer(_:)))
        if let longPressGestureRecognizer = self.longPressGestureRecognizer {
            circularProgress.isUserInteractionEnabled = true
            longPressGestureRecognizer.minimumPressDuration = 0.5
            longPressGestureRecognizer.allowableMovement = 10.0
            circularProgress.addGestureRecognizer(longPressGestureRecognizer)
        }
    }
    
    @objc internal func handleLongPressGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            recoredButtonCenterPoint = circularProgress.center
            self.panStartPoint = gestureRecognizer.location(in: self.view)
            self.setSpeed(type: .normal, value: 0)
            self.player?.play()
        case .changed:
            let translation = gestureRecognizer.location(in: circularProgress)
            circularProgress.center = CGPoint(x: circularProgress.center.x + translation.x - 35,
                                              y: circularProgress.center.y + translation.y - 35)
            
            let newPoint = gestureRecognizer.location(in: self.view)
            
            let normalPart = (UIScreen.main.bounds.width * CGFloat(142.5)) / 375
            let screenPart = Int((UIScreen.main.bounds.width - normalPart) / 4)

            if abs((Int(self.panStartPoint.x) - Int(newPoint.x))) > 50 {
                let difference = abs((Int(self.panStartPoint.x) - Int(newPoint.x))) - 50
                if (Int(self.panStartPoint.x) - Int(newPoint.x)) > 0 {
                    if difference > screenPart {
                        if videoSpeedType != VideoSpeedType.slow(scaleFactor: 3.0) {
                            DispatchQueue.main.async {
                                self.setSpeed(type: .slow(scaleFactor: 3.0),
                                                  value: -3,
                                                  sliderValue: 0)
                            }
                        }
                    } else {
                        if videoSpeedType != VideoSpeedType.slow(scaleFactor: 2.0) {
                            DispatchQueue.main.async {
                                self.setSpeed(type: .slow(scaleFactor: 2.0),
                                                  value: -2,
                                                  sliderValue: 1)
                            }
                        }
                    }
                    
                } else {
                    if difference > screenPart {
                        if videoSpeedType != VideoSpeedType.fast(scaleFactor: 3.0) {
                            DispatchQueue.main.async {
                                self.setSpeed(type: .fast(scaleFactor: 3.0),
                                                  value: 3,
                                                  sliderValue: 4)
                            }
                        }
                    } else {
                        if videoSpeedType != VideoSpeedType.fast(scaleFactor: 2.0) {
                            DispatchQueue.main.async {
                                self.setSpeed(type: .fast(scaleFactor: 2.0),
                                                  value: 2,
                                                  sliderValue: 3)
                            }
                        }
                    }
                }
            } else {
                if videoSpeedType != VideoSpeedType.normal {
                    DispatchQueue.main.async {
                        self.setSpeed(type: .normal,
                                      value: 0)
                    }
                }
            }
        case .ended: 
            DispatchQueue.main.async {
                self.setSpeed(type: .normal, value: 0)
                self.circularProgress.center = self.recoredButtonCenterPoint
            }
        case .cancelled:
            break
        case .failed:
            break
        default:
            break
        }
    }
    
    func setSpeed(type: VideoSpeedType, value: Float, text: String = "", sliderValue: Int = 2) {
        self.videoSpeedType = type
        self.isSpeedChanged = true
        self.speedSliderLabels.value = UInt(sliderValue)
        self.speedSlider.value = CGFloat(sliderValue)
        rate = value
        guard let asset = currentAsset else {
            return
        }
        let duration = (player?.currentItem?.currentTime().seconds ?? 0) - lastStartSeconds
        lastStartSeconds = (player?.currentItem?.currentTime().seconds ?? 0)
        let timeScale: CMTimeScale = asset.duration.timescale
        var scaleDuration = CMTimeMakeWithSeconds(abs(duration*Double(rate)), preferredTimescale: timeScale)
        if rate > 0 {
            scaleDuration = CMTimeMakeWithSeconds(abs(duration/Double(rate)), preferredTimescale: timeScale)
        }
        let startTime = CMTime(seconds: lastStartSeconds, preferredTimescale: timeScale)
        scalerValues.append(VideoScalerValue(range:
            CMTimeRange(start: startTime, duration: CMTime(seconds: duration, preferredTimescale: timeScale)), duration: scaleDuration, rate: Int(rate)))
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension SpeedViewController {
    
    func loadAsset(_ asset: AVAsset) {
        trimmerView.layoutIfNeeded()
        trimmerView.minVideoDurationAfterTrimming = 3.0
        trimmerView.thumbnailsView.asset = asset
        trimmerView.rightImage = R.image.cut_handle_icon()
        trimmerView.leftImage = R.image.cut_handle_icon()
        trimmerView.thumbnailsView.isReloadImages = true
        trimmerView.layoutIfNeeded()
        trimmerView.isHideLeftRightView = true
        trimmerView.cutView.isHidden = true
        trimmerView.timePointerView.isHidden = true
    }
    
}
extension SpeedViewController: FlowChartViewDelegate {
    
    func longPressOnPoint(view: FlowDotView) {
        player?.pause()
        stopPlaybackTimeChecker()
        btnPlayPause.isSelected = false
        currentDotView = view
    }
    
    func didStartDragging() {
        print("didStartDragging")
        shouldPlayAfterDrag = player?.isPlayingPlayer ?? true
        draggedSeconds = adjustTime(currentTime: player?.currentTime().seconds ?? 0)
        player?.pause()
        stopPlaybackTimeChecker()
        btnPlayPause.isSelected = false
    }
    
    func didStopDragging() {
        print("didStopDragging")
        guard let asset = currentAsset else {
            return
        }
        let (mutableAsset, scalerParts) = VideoScaler.shared.scaleVideo(asset: asset, scalerValues: self.scalerValues)
        if let asset = mutableAsset {
            playerItem = AVPlayerItem.init(asset: asset)
            playerItem!.audioTimePitchAlgorithm = .lowQualityZeroLatency
            player?.replaceCurrentItem(with: playerItem)
            videoScalerParts = scalerParts
        }
        if shouldPlayAfterDrag {
            player?.play()
            btnPlayPause.isSelected = true
        }
        let seekTime = CMTime.init(value: CMTimeValue.init(self.currentTime(adjustedTime: draggedSeconds)*1000000000), timescale: 1000000000)
        player?.seek(to: seekTime, completionHandler: { [weak self]_ in
            if self?.shouldPlayAfterDrag ?? false {
                self?.startPlaybackTimeChecker()
            }
        })
    }
    
    func shouldAddPoint() -> Bool {
        guard let asset = currentAsset else {
            return false
        }
        let assetDuartion = asset.duration.seconds
        let shouldAddPoint = flowChartView.getSpeedValues().count <= Int(assetDuartion)
        return shouldAddPoint
    }
    
    func didAddPoint() {
        print("didAddPoint")
        guard let asset = currentAsset else {
            return
        }
        let (mutableAsset, scalerParts) = VideoScaler.shared.scaleVideo(asset: asset, scalerValues: self.scalerValues)
        if let asset = mutableAsset {
            playerItem = AVPlayerItem.init(asset: asset)
            player?.replaceCurrentItem(with: playerItem)
            videoScalerParts = scalerParts
        }
        if shouldPlayAfterDrag {
            player?.play()
            btnPlayPause.isSelected = true
        }
        let seekTime = CMTime.zero
        player?.seek(to: seekTime, completionHandler: { [weak self]_ in
            if self?.shouldPlayAfterDrag ?? false {
                self?.startPlaybackTimeChecker()
            }
        })
    }
    
}
// MARK: Setup View
extension SpeedViewController {
    
    func addPlayerLayer() {
        videoView.layoutIfNeeded()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = videoView.frame
        playerLayer?.isOpaque = false
        
        playerLayer?.backgroundColor = ApplicationSettings.appClearColor.cgColor
        playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
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
        playerItem!.audioTimePitchAlgorithm = .lowQualityZeroLatency
        loadAsset(asset)
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
}

// MARK: Observer
extension SpeedViewController {
    
    func addPlayerEndTimeObserver() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let `self` = self,
                let currentPlayerItem = notification.object as? AVPlayerItem,
                currentPlayerItem == self.playerItem
                else {
                    return
            }
            let rate: Float = self.rate
           
            guard !self.isExporting, let asset = self.currentAsset else {
                return
            }
            
            let duration = (self.player?.currentItem?.duration.seconds ?? 0) - self.lastStartSeconds
            self.videoScalerParts.append(VideoScalerPart.init(startTime: self.player?.currentItem?.currentTime().seconds ?? 0, rate: Int(rate)))
                
            self.lastStartSeconds = (self.player?.currentItem?.currentTime().seconds ?? 0)
            
            let timeScale: CMTimeScale = asset.duration.timescale
            
            var scaleDuration = CMTimeMakeWithSeconds(abs(duration*Double(rate)), preferredTimescale: timeScale)
            
            if rate > 0 {
                scaleDuration = CMTimeMakeWithSeconds(abs(duration/Double(rate)), preferredTimescale: timeScale)
            }
            
            let startTime = CMTime(seconds: self.lastStartSeconds, preferredTimescale: timeScale)
            self.scalerValues.append(VideoScalerValue(range:
                CMTimeRange(start: startTime, duration: CMTime(seconds: duration, preferredTimescale: timeScale)), duration: scaleDuration, rate: Int(rate)))
            
            self.doneBtnClicked(UIButton())
        }
    }
}

extension SpeedViewController {
    @objc func speedSliderValueChanged(_ sender: Any) {
        videoSpeedType = speedSlider.speedType
        
    }
}
