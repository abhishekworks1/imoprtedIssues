//
//  HistroGramVC.swift
//  ProManager
//
//  Created by Viraj Patel on 11/01/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit
import SCRecorder
import TGPControls

enum SpeedType: Int {
    case flow = 0
    case timeFlow = 1
    case cameraSpeed = 2
}

class HistroGramVC: UIViewController {
   
    @IBOutlet open var cameraSpeedControlView: UIView!
    @IBOutlet weak var speedChangeModesView: UIView!
    @IBOutlet weak var controlView: UIView!
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
    
    @IBOutlet weak var speedSliderLabels: TGPCamelLabels! {
           didSet {
               speedSliderLabels.names = ["-3x", "-2x", "1x", "2x", "3x"]
               speedSlider.ticksListener = speedSliderLabels
           }
       }
    @IBOutlet weak var speedSlider: TGPDiscreteSlider! {
        didSet {
            
        }
    }
    
    @IBOutlet open var flowButton: UIButton!
    @IBOutlet open var chartButton: UIButton!
    @IBOutlet open var cameraSpeedButton: UIButton!
    
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    var recoredButtonCenterPoint: CGPoint = CGPoint.init()
    var panStartPoint: CGPoint = .zero
    var videoSpeedType = VideoSpeedType.normal
    var lastStartSeconds: Double = 0
    var scalerValues: [VideoScalerValue] = []
    var videoSpeedValue: Float = 1
    var currentSpeedMode: SpeedType = .flow {
        didSet {
            switch currentSpeedMode {
            case .flow:
                flowButton.alpha = 1
                chartButton.alpha = 0.5
                cameraSpeedButton.alpha = 0.5
                progressBar.isHidden = false
                flowControlView.isHidden = false
                timeControlView.isHidden = true
                cameraSpeedControlView.isHidden = true
                btnPlayPause.isHidden = false
                btnMute.isHidden = false
                let (mutableAsset, scalerParts) = VideoScaler.shared.scaleVideo(asset: currentAsset!, scalerValues: calculateScaleValues())
                if let asset = mutableAsset {
                    playerItem = AVPlayerItem.init(asset: asset)
                    player?.replaceCurrentItem(with: playerItem)
                    videoScalerParts = scalerParts
                }
                player?.seek(to: .zero)
                player?.play()
            case .timeFlow:
                flowButton.alpha = 0.5
                chartButton.alpha = 1
                cameraSpeedButton.alpha = 0.5
                progressBar.isHidden = true
                flowControlView.isHidden = true
                timeControlView.isHidden = false
                cameraSpeedControlView.isHidden = true
                btnPlayPause.isHidden = false
                btnMute.isHidden = false
                if let asset = timeSliderAsset() {
                    playerItem = AVPlayerItem(asset: asset)
                    player?.replaceCurrentItem(with: playerItem)
                }
                player?.seek(to: .zero)
                player?.play()
            case .cameraSpeed:
                flowButton.alpha = 0.5
                chartButton.alpha = 0.5
                cameraSpeedButton.alpha = 1
                progressBar.isHidden = true
                flowControlView.isHidden = true
                timeControlView.isHidden = true
                cameraSpeedControlView.isHidden = false
                btnPlayPause.isHidden = true
                btnMute.isHidden = true
                player?.seek(to: .zero)
                player?.pause()
            default:
                break
            }
        }
    }
    
    @IBOutlet open var baseFlowView: UIView!
    @IBOutlet open var baseChartView: UIView!
    @IBOutlet open var videoView: UIView!
    @IBOutlet open var coverView: UIView!
    @IBOutlet open var fullStackView: UIStackView!
    @IBOutlet open var fullView: UIView!
    @IBOutlet open var progressBar: UIView!
    @IBOutlet open var exportActivityIndicator: UIActivityIndicatorView!
    @IBOutlet open var btnMute: UIButton!
    @IBOutlet open var btnPlayPause: UIButton!
    @IBOutlet open var btnShowHideHistoGram: UIButton!
    @IBOutlet open var lblShowCurrentTime: UILabel!
    @IBOutlet weak var trimmerView: TrimmerView!
    @IBOutlet weak var deleteFlowPointButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var timeControlView: UIView!
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
    
    var currentAsset: AVAsset?
    
    var currentDotView: FlowDotView?
    
    var doneHandler: (([SegmentVideos]) -> Void)?
    
    var completionHandler: ((URL) -> ())? = nil

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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopPlaybackTimeChecker()
        removeObserveState()
    }
    
    deinit {
        print("HistroGramVC Deinit")
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
        if flowChartView == nil {
            setupFlowChart()
            addGestureToProgressBar()
            currentSpeedMode = .flow
        }
        if timeSlider == nil {
            setUpSlider()
        }
        observeState()
        playerLayer?.frame = videoView.frame
    }
    
    func setUpSlider() {
        timeControlView.layoutIfNeeded()
        timeSlider = PivotSlider(frame: CGRect(origin: CGPoint(x: 0, y: 25),
                                               size: CGSize(width: timeControlView.frame.width, height: 50)))
        timeControlView.addSubview(timeSlider!)
        timeSlider?.addTarget(self,
                              action: #selector(timeSliderValueChanged(_:)),
                              for: .valueChanged)
        timeSlider?.addTarget(self,
                              action: #selector(timeSliderEndTracking(_:)),
                              for: .touchDragExit)
        let totalSeconds = Float(currentAsset?.duration.seconds ?? 0)
        let minimumSeconds = totalSeconds/3
        let maximumSeconds = totalSeconds*3
        
        minimumSecondsLabel.text = hmsString(from: minimumSeconds)
        maximumSecondsLabel.text = hmsString(from: maximumSeconds)
        selectedSecondsLabel.text = hmsString(from: totalSeconds)
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
            player?.play()
            btnPlayPause.isSelected = true
            startPlaybackTimeChecker()
        }
    }
    
    func setupFlowChart() {
        baseChartView.layoutIfNeeded()
        baseFlowView.layoutIfNeeded()
        flowChartView = FlowChartView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: baseFlowView.bounds.height))
        flowChartView.delegate = self
        baseFlowView.addSubview(flowChartView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPlayerLayer()
        loadViewWith(asset: currentAsset)
        videoProgressViewGesture()
    }
    
    func addGestureToProgressBar() {
        self.progressBar.translatesAutoresizingMaskIntoConstraints = true
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(progressBarDidPan))
        self.progressBar.addGestureRecognizer(panGesture)
    }
    
    @objc func progressBarDidPan(_ gesture: UIPanGestureRecognizer) {
        guard let asset = currentAsset else {
            return
        }
        if gesture.state == .began {
            shouldPlayAfterDrag = player?.isPlayingPlayer ?? true
        }
        if gesture.state == .began || gesture.state == .changed {
            if let isPlaying = player?.isPlayingPlayer,
                isPlaying {
                player?.pause()
                stopPlaybackTimeChecker()
                btnPlayPause.isSelected = false
            }
            let translation = gesture.translation(in: self.view)
            gesture.view!.center = CGPoint(x: gesture.view!.center.x + translation.x, y: gesture.view!.center.y)
            gesture.setTranslation(CGPoint.zero, in: self.view)
            let actualDuration = asset.duration.seconds
            let currentTm = currentTime(adjustedTime: Double((gesture.view!.center.x*CGFloat(actualDuration))/UIScreen.main.bounds.width))
            let seekTime = CMTime.init(value: CMTimeValue.init(currentTm*1000000000), timescale: 1000000000)
            player?.seek(to: seekTime)
            self.setProgressViewProgress(player: player!, changeProgressBar: true)
        }
        if gesture.state == .ended {
            if shouldPlayAfterDrag {
                player?.play()
                btnPlayPause.isSelected = true
            }
            let actualDuration = asset.duration.seconds
            let currentTm = currentTime(adjustedTime: Double((gesture.view!.center.x*CGFloat(actualDuration))/UIScreen.main.bounds.width))
            let seekTime = CMTime.init(value: CMTimeValue.init(currentTm*1000000000), timescale: 1000000000)
            player?.seek(to: seekTime, completionHandler: { [weak self] _ in
                if self?.shouldPlayAfterDrag ?? false {
                    self?.startPlaybackTimeChecker()
                }
            })
        }
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension HistroGramVC {
    
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

// CameraSpeed Controll Funcations
extension HistroGramVC {
    
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
            self.setSpeed(type: .normal, value: 1)
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
                                      value: 1)
                    }
                }
            }
        case .ended:
            self.setSpeed(type: .normal, value: 1)
            DispatchQueue.main.async {
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
        self.speedSliderLabels.value = UInt(sliderValue)
        self.speedSlider.value = CGFloat(sliderValue)

        self.videoSpeedValue = value
        guard let asset = currentAsset else {
            return
        }
        let duration = (playerItem?.currentTime().seconds ?? asset.duration.seconds) - lastStartSeconds
        lastStartSeconds = (playerItem?.currentTime().seconds ?? asset.duration.seconds)
        print("duration :\(duration)")
        print("lastStartSeconds :\(lastStartSeconds)")
        let timeScale: CMTimeScale = asset.duration.timescale
        var scaleDuration = CMTimeMakeWithSeconds(abs(duration*Double(value)), preferredTimescale: timeScale)
        if value > 0 {
            scaleDuration = CMTimeMakeWithSeconds(abs(duration/Double(value)), preferredTimescale: timeScale)
        }
        print("scaleDuration :\(scaleDuration)")
        let startTime = CMTime(seconds: lastStartSeconds, preferredTimescale: timeScale)
        print("startTime :\(startTime)")
        scalerValues.append(VideoScalerValue(range:
            CMTimeRange(start: startTime, duration: CMTime(seconds: duration, preferredTimescale: timeScale)), duration: scaleDuration, rate: Int(value)))
        
    }
}

extension HistroGramVC: FlowChartViewDelegate {
    
    func longPressOnPoint(view: FlowDotView) {
        player?.pause()
        stopPlaybackTimeChecker()
        btnPlayPause.isSelected = false
        deleteFlowPointButton.isHidden = false
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
        let (mutableAsset, scalerParts) = VideoScaler.shared.scaleVideo(asset: asset, scalerValues: calculateScaleValues())
        if let asset = mutableAsset {
            playerItem = AVPlayerItem.init(asset: asset)
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
        let (mutableAsset, scalerParts) = VideoScaler.shared.scaleVideo(asset: asset, scalerValues: calculateScaleValues())
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
extension HistroGramVC {
    
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
        loadAsset(asset)
        if playerLayer == nil {
            addPlayerLayer()
        }
        setupPlayer(for: playerItem!)
        player?.play()
        
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
extension HistroGramVC {
    
    func addPlayerEndTimeObserver() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let `self` = self,
                let currentPlayerItem = notification.object as? AVPlayerItem,
                currentPlayerItem == self.playerItem
                else {
                    return
            }
            if self.currentSpeedMode != .cameraSpeed {
                currentPlayerItem.seek(to: CMTime.zero, completionHandler: { (_) in
                    self.player?.play()
                })
            } else {
                self.setSpeed(type: .normal, value: self.videoSpeedValue)
                DispatchQueue.main.async {
                    self.circularProgress.center = self.recoredButtonCenterPoint
                }
            }
        }
    }
}
