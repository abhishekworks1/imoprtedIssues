//
//  StoryCameraViewController.swift
//  ProManager
//
//  Created by Viraj Patel on 10/10/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit
import TGPControls
import Toast_Swift
import Photos
import PhotosUI
import MobileCoreServices
import SCRecorder
import AVKit

class StoryCameraViewController: UIViewController {
   
    let popupOffset: CGFloat = 110
    var bottomConstraint = NSLayoutConstraint()
    var currentState: State = .closed
    /// All of the currently running animators.
    var runningAnimators = [UIViewPropertyAnimator]()
    /// The progress of each animator. This array is parallel to the `runningAnimators` array.
    var animationProgress = [CGFloat]()
    private lazy var panRecognizer: InstantPanGestureRecognizer = {
        let recognizer = InstantPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
        return recognizer
    }()
    
    // MARK: IBOutlets
    @IBOutlet weak var bottomCameraViews: UIView!
    @IBOutlet weak var collectionViewStackVIew: UIStackView!
    @IBOutlet weak var settingsView: UIStackView!
    
    @IBOutlet weak var timerValueView: UIView!
    @IBOutlet weak var faceFiltersView: UIStackView!
    @IBOutlet weak var sceneFilterView: UIStackView!
    @IBOutlet weak var fpsView: UIStackView!
    @IBOutlet weak var showhideView: UIStackView!
    @IBOutlet weak var outtakesView: UIStackView!
    @IBOutlet weak var nextButtonView: UIStackView!
    @IBOutlet weak var timerStackView: UIStackView!
    @IBOutlet weak var flashStackView: UIStackView!
    
    @IBOutlet weak var photoTimerSelectedLabel: UILabel!
    @IBOutlet weak var pauseTimerSelectedLabel: UILabel!
    @IBOutlet weak var timerSelectedLabel: UILabel!
    @IBOutlet weak var segmentLengthSelectedLabel: UILabel!
    @IBOutlet weak var photoTimerSelectionLabel: UILabel!
    @IBOutlet weak var pauseTimerSelectionLabel: UILabel!
    @IBOutlet weak var timerSelectionLabel: UILabel!
    @IBOutlet weak var segmentLengthSelectionLabel: UILabel!
    @IBOutlet weak var photoTimerSelectionButton: UIButton!
    @IBOutlet weak var pauseTimerSelectionButton: UIButton!
    @IBOutlet weak var timerSelectionButton: UIButton!
    @IBOutlet weak var segmentLengthSelectionButton: UIButton!
    @IBOutlet weak var selectTimersView: UIView!
    @IBOutlet weak var timerPicker: PickerView! {
        didSet {
            timerPicker.dataSource = self
            timerPicker.delegate = self
            timerPicker.scrollingStyle = .default
            timerPicker.selectionStyle = .overlay
            timerPicker.tintColor = ApplicationSettings.appWhiteColor
            timerPicker.selectionTitle.text = R.string.localizable.seconds()
        }
    }
    
    @IBOutlet weak var speedSliderView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var slowVerticalBar: UIView!
    @IBOutlet weak var fastVerticalBar: UIView!
    @IBOutlet weak var enableMicrophoneButton: UIButton!
    @IBOutlet weak var enableCameraButton: UIButton!
    @IBOutlet weak var enableAccessView: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var effectButton: UIButton!
    
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
    @IBOutlet weak var selectedTimerLabel: UILabel!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var outtakesButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var zoomSliderView: UIView!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var muteLabel: UILabel!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var btnShowHide: ColorImageButton!
    @IBOutlet weak var flashButton: UIButton! {
        didSet {
            flashButton.setImage(R.image.flashOff(), for: UIControl.State.normal)
        }
    }
    
    @IBOutlet weak var cameraSliderView: InstaSlider!
    
    @IBOutlet weak var flipLabel: UILabel!
    @IBOutlet weak var flashLabel: UILabel!
    @IBOutlet weak var transparentView: TransparentGradientView!
    @IBOutlet weak var zoomSlider: VSSlider!
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
    
    @IBOutlet var stopMotionCollectionView: KDDragAndDropCollectionView!
    @IBOutlet weak var lblStoryCount: UILabel!
    @IBOutlet weak var lblStoryPercentage: UILabel!
    
    @IBOutlet weak var storyUploadView: UIView!
    
    @IBOutlet weak var storyUploadRoundView: UIView!
    
    @IBOutlet weak var storyUploadImageView: UIImageView! {
        didSet {
            storyUploadImageView.layer.cornerRadius = 1
        }
    }
    
    // MARK: Variables
    var recoredButtonCenterPoint: CGPoint = CGPoint.init()
    
    var totalDurationOfOneSegment: Double = 0
    
    var isCountDownStarted: Bool = false {
        didSet {
            isPageScrollEnable = !isCountDownStarted
        }
    }
    
    var draggingCell: IndexPath?
    var dragAndDropManager: KDDragAndDropManager?
    var deleteRect: CGRect?
    
    var isDisableResequence: Bool = true {
        didSet {
            self.stopMotionCollectionView.isMovable = !isDisableResequence
        }
    }
    
    var isRecording: Bool = false {
        didSet {
            isPageScrollEnable = !isRecording
            deleteView.isHidden = isRecording
            DispatchQueue.main.async {
                if self.isRecording {
                    self.collectionViewStackVIew.isHidden = !self.takenVideoUrls.isEmpty
                } else {
                    self.collectionViewStackVIew.isHidden = false
                }
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
            
        }
    }
    
    let storyUploadManager = StoryDataManager.shared
    
    var hideControls: Bool = false {
        didSet {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, animations: {
                    let alpha: CGFloat = self.hideControls ? 0 : 1
                    self.setAlphaOnControls([self.timerValueView,
                                             self.settingsView,
                                             self.fpsView,
                                             self.outtakesView,
                                             self.sceneFilterView,
                                             self.deleteView,
                                             self.faceFiltersView,
                                             self.zoomSliderView,
                                             self.timerStackView,
                                             self.flashStackView,
                                             self.nextButtonView],
                                            alpha: alpha)
                    // Make the animation happen
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    var timerType = TimerType.segmentLength
    var selectedTimerValue = SelectedTimer(value: "-", selectedRow: 0)
    var selectedSegmentLengthValue = SelectedTimer(value: "240", selectedRow: 10)
    var selectedPauseTimerValue = SelectedTimer(value: "-", selectedRow: 0)
    var selectedPhotoTimerValue = SelectedTimer(value: "-", selectedRow: 0)
    var isMute: Bool = false {
        didSet {
            NextLevel.shared.audioConfiguration.isMute = self.isMute
            if NextLevel.shared.isRecording {
                self.isMute ? muteButton.startBlink(0.5) : muteButton.stopBlink()
            }
        }
    }
    
    var recordingType: CameraMode = .normal {
        didSet {
            if recordingType != .custom {
                DispatchQueue.main.async {
                    self.speedSlider.isUserInteractionEnabled = true
                    self.slowVerticalBar.isHidden = true
                    self.fastVerticalBar.isHidden = true
                    self.speedLabel.textColor = UIColor.red
                    self.speedLabel.text = ""
                    self.speedLabel.stopBlink()
                    if self.recordingType != .timer {
                        self.takenImages.removeAll()
                        self.takenVideoUrls.removeAll()
                        self.dragAndDropManager = KDDragAndDropManager(
                            canvas: self.view,
                            collectionViews: [self.stopMotionCollectionView]
                        )
                        self.deleteRect = self.deleteView.frame
                        self.stopMotionCollectionView.reloadData()
                    }
                }
                DispatchQueue.main.async {
                    self.timerButton.isUserInteractionEnabled = true
                    UIView.animate(withDuration: 0.1, animations: {
                        self.timerButton.alpha = 1
                    })
                }
            } else if recordingType == .custom {
                self.dragAndDropManager = KDDragAndDropManager(
                    canvas: self.view,
                    collectionViews: [self.stopMotionCollectionView]
                )
                self.speedSlider.isUserInteractionEnabled = true
                self.isDisableResequence = true
                self.deleteRect = self.deleteView.frame
                self.stopMotionCollectionView.reloadData()
                self.collectionViewStackVIew.isUserInteractionEnabled = true
                DispatchQueue.main.async {
                    self.timerButton.isUserInteractionEnabled = false
                    UIView.animate(withDuration: 0.1, animations: {
                        self.timerButton.alpha = 0.5
                    })
                }
            } else if recordingType == .capture || recordingType == .boomerang {
                DispatchQueue.main.async {
                    self.timerButton.isUserInteractionEnabled = false
                    UIView.animate(withDuration: 0.1, animations: {
                        self.timerButton.alpha = 0.5
                    })
                }
            }
            
            if recordingType == .slideshow || recordingType == .collage || recordingType == .boomerang {
                DispatchQueue.main.async {
                    self.timerButton.isUserInteractionEnabled = false
                    self.muteButton.isUserInteractionEnabled = false
                    UIView.animate(withDuration: 0.1, animations: {
                        self.timerButton.alpha = 0.5
                        self.muteButton.alpha = 0.5
                    })
                }
            } else if recordingType != .custom && recordingType != .capture {
                DispatchQueue.main.async {
                    self.timerButton.isUserInteractionEnabled = true
                    self.muteButton.isUserInteractionEnabled = true
                    UIView.animate(withDuration: 0.1, animations: {
                        self.timerButton.alpha = 1
                        self.muteButton.alpha = 1
                    })
                }
            }
            if recordingType == .capture {
                DispatchQueue.main.async {
                    self.closeButton.tag = 2
                    self.closeButton.setImage(R.image.handsfree(), for: UIControl.State.normal)
                    self.closeButton.setImage(R.image.handsfreeSelected()?.sd_tintedImage(with: ApplicationSettings.appPrimaryColor), for: UIControl.State.selected)
                }
            } else {
                DispatchQueue.main.async {
                    self.closeButton.tag = 1
                    self.closeButton.setImage(R.image.icoDone(), for: UIControl.State.normal)
                    self.closeButton.setImage(R.image.icoDone(), for: UIControl.State.selected)
                }
            }
            
            let showNextButton = (recordingType == .custom || recordingType == .slideshow || recordingType == .collage || recordingType == .capture)
            self.nextButtonView.isHidden = !showNextButton
        }
    }
    
    var isViewAppear = false
    var isShowEffectCollectionView = false
    var effectData = [EffectData]()
    var styleData = [StyleData]()
    var collectionMode: CollectionMode = .effect
    let minimumZoom: CGFloat = 1.0
    var maximumZoom: CGFloat = 3.0
    var lastZoomFactor: CGFloat = 1.0
    var photoTapGestureRecognizer: UITapGestureRecognizer?
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    var panStartPoint: CGPoint = .zero
    var panStartZoom: CGFloat = 0.0
    var currentCameraPosition = AVCaptureDevice.Position.front
    var flashMode: AVCaptureDevice.TorchMode = .off
    var takenImages: [UIImage] = []
    var takenVideoUrls: [SegmentVideos] = []
    var takenSlideShowImages: [SegmentVideos] = []
    var videoSpeedType = VideoSpeedType.normal
    var isSpeedChanged = false
    var isStopConnVideo = false
    var firstPercentage: Double = 0.0
    var firstUploadCompletedSize: Double = 0.0
    
    var pageSize: CGSize {
        let layout = self.stopMotionCollectionView.collectionViewLayout as? UPCarouselFlowLayout
        var pageSize = layout?.itemSize
        if layout?.scrollDirection == .horizontal {
            pageSize?.width += layout?.minimumLineSpacing ?? 0
        } else {
            pageSize?.height += layout?.minimumLineSpacing ?? 0
        }
        return pageSize ?? CGSize.init(width: 0, height: 0)
    }
    
    lazy  var sfCountdownView: CountdownView = {
        let countdownView = CountdownView.init(frame: self.view.bounds)
        countdownView.delegate = self
        countdownView.backgroundAlpha = 0.2
        countdownView.countdownColor = ApplicationSettings.appWhiteColor
        countdownView.countdownFrom = 3
        countdownView.finishText = "Start"
        countdownView.updateAppearance()
        countdownView.isHidden = true
        return countdownView
    }()
    
    var videoSegmentSeconds: CGFloat = 240
    var timerValue = 0
    var pauseTimerValue = 0
    var photoTimerValue = 0
    var cameraModeArray: [String] = [R.string.localizable.typE(), R.string.localizable.livE(), R.string.localizable.photovideO(), R.string.localizable.boomeranG(), R.string.localizable.slideshoW(), R.string.localizable.collagE(), R.string.localizable.handfreE(), R.string.localizable.custoM(), R.string.localizable.capturE()]
    
    var timerOptions = ["-",
                        "1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
                        "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
                        "21", "22", "23", "24", "25", "26", "27", "28", "29", "30",
                        "31", "32", "33", "34", "35", "36", "37", "38", "39", "40",
                        "41", "42", "43", "44", "45", "46", "47", "48", "49", "50",
                        "51", "52", "53", "54", "55", "56", "57", "58", "59", "60"]
    
    var segmentLengthOptions = [
        "5",
        "10",
        "20",
        "30",
        "60",
        "90",
        "120",
        "150",
        "180",
        "210",
        "240"]
    
    var pauseTimerOptions = ["-",
                             "1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
                             "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
                             "21", "22", "23", "24", "25", "26", "27", "28", "29", "30",
                             "31", "32", "33", "34", "35", "36", "37", "38", "39", "40",
                             "41", "42", "43", "44", "45", "46", "47", "48", "49", "50",
                             "51", "52", "53", "54", "55", "56", "57", "58", "59", "60"]
    
    var photoTimerOptions = ["-",
                             "1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
                             "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
                             "21", "22", "23", "24", "25", "26", "27", "28", "29", "30",
                             "31", "32", "33", "34", "35", "36", "37", "38", "39", "40",
                             "41", "42", "43", "44", "45", "46", "47", "48", "49", "50",
                             "51", "52", "53", "54", "55", "56", "57", "58", "59", "60"]
    
    public var storiCamType: StoriCamType = .story
    public weak var storySelectionDelegate: StorySelectionDelegate?
    var isPageScrollEnable: Bool = true
    var imageViewToPan: UIImageView?
    var replyQuePanGesture: UIPanGestureRecognizer?
    var replyQuePinchGesture: UIPinchGestureRecognizer?
    var replyQueRotationGestureRecognizer: UIRotationGestureRecognizer?
    var replyQueTapGesture: UITapGestureRecognizer?
    var previewView: UIView?
    var gestureView: UIView?
    var focusView: FocusIndicatorView?
    var flashView: UIView?
    var currentBrightness: CGFloat = 0.0
    var metadataObjectViews: [UIView]?
    let nextLevel = NextLevel.shared
    var selectedFPS: Float = 30
    
    // MARK: ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        checkPermissions()
        setupLayout()
        setupLayoutCameraSliderView()
        setCameraSettings()
        setupCountDownView()
        addAskQuestionReplyView()
        self.storyUploadManager.delegate = self
        self.storyUploadManager.startUpload()
        view.bringSubviewToFront(baseView)
        view.bringSubviewToFront(blurView)
        view.bringSubviewToFront(enableAccessView)
        view.bringSubviewToFront(selectTimersView)
        layout()
        self.view.addGestureRecognizer(panRecognizer)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopCapture()
        isViewAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        isViewAppear = true
        startCapture()
        observeState()
        self.flashView?.removeFromSuperview()
        if recordingType != .custom {
            self.circularProgress.animate(toAngle: 0, duration: 0, completion: nil)
        }
        self.speedSlider.isUserInteractionEnabled = true
        slowVerticalBar.isHidden = true
        fastVerticalBar.isHidden = true
        self.speedLabel.textColor = UIColor.red
        self.speedLabel.text = ""
        self.speedLabel.stopBlink()
        if hideControls {
            hideControls = true
        }
        self.reloadUploadViewData()
        self.stopMotionCollectionView.reloadData()
        speedSlider.isHidden = !Defaults.shared.isPro
        speedSliderView.isHidden = !Defaults.shared.isPro
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if recordingType == .slideshow {
            recordingType = .slideshow
        } else if recordingType == .collage {
            recordingType = .collage
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        removeObserveState()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: Setup Camera
extension StoryCameraViewController {
    
    func deSelectButtonWith(_ buttons: [UIButton]) {
        for button in buttons {
            button.isSelected = false
        }
    }
    
    func hideLabels(_ buttons: [UILabel]) {
        for button in buttons {
            button.isHidden = true
        }
    }

    func startCapture() {
        do {
            try nextLevel.start()
            if selectedFPS != 30 {
                nextLevel.updateDeviceFormat(withFrameRate: CMTimeScale(selectedFPS),
                                             dimensions: CMVideoDimensions(width: 1920, height: 1080))
            }
        } catch {
            debugPrint("failed to start camera session")
        }
    }
    
    func stopCapture() {
        nextLevel.stop()
    }
    
    func setCameraSettings() {
        if let flashmode = Defaults.shared.flashMode {
            flashMode = AVCaptureDevice.TorchMode(rawValue: flashmode) ?? .off
        } else {
            flashMode = .off
            Defaults.shared.flashMode = flashMode.rawValue
        }
        setupFlashUI()
        if let cameraPosition = Defaults.shared.cameraPosition {
            currentCameraPosition = AVCaptureDevice.Position(rawValue: cameraPosition == 0 ? 1 : cameraPosition) ?? .front
        } else {
            currentCameraPosition = .front
            Defaults.shared.cameraPosition = currentCameraPosition.rawValue
        }
        self.setCameraPositionUI()
        if let isMicOn = Defaults.shared.isMicOn {
            isMute = !isMicOn
        } else {
            isMute = false
            Defaults.shared.isMicOn = !isMute
        }
        setupMuteUI()
        
        if let selectedTimerValue = SelectedTimer.loadWithKey(key: "selectedTimerValue", model: SelectedTimer.self) {
            self.selectedTimerValue = selectedTimerValue
        } else {
            self.selectedTimerValue = SelectedTimer(value: "-", selectedRow: 0)
            self.selectedTimerValue.saveWithKey(key: "selectedTimerValue")
        }
        if selectedTimerValue.selectedRow == 0 {
            timerValue = 0
        } else {
            timerValue = Int(selectedTimerValue.value) ?? 0
        }
        
        if let selectedPauseTimerValue = SelectedTimer.loadWithKey(key: "selectedPauseTimerValue", model: SelectedTimer.self) {
            self.selectedPauseTimerValue = selectedPauseTimerValue
        } else {
            self.selectedPauseTimerValue = SelectedTimer(value: "-", selectedRow: 0)
            self.selectedPauseTimerValue.saveWithKey(key: "selectedPauseTimerValue")
        }
        if selectedPauseTimerValue.selectedRow == 0 {
            pauseTimerValue = 0
        } else {
            pauseTimerValue = Int(selectedPauseTimerValue.value) ?? 0
        }
        
        if let selectedPhotoTimerValue = SelectedTimer.loadWithKey(key: "selectedPhotoTimerValue", model: SelectedTimer.self) {
            self.selectedPhotoTimerValue = selectedPhotoTimerValue
        } else {
            self.selectedPhotoTimerValue = SelectedTimer(value: "-", selectedRow: 0)
            self.selectedPhotoTimerValue.saveWithKey(key: "selectedPhotoTimerValue")
        }
        if selectedPhotoTimerValue.selectedRow == 0 {
            photoTimerValue = 0
        } else {
            photoTimerValue = Int(selectedPhotoTimerValue.value) ?? 0
        }
        
        if let selectedSegmentLengthValue = SelectedTimer.loadWithKey(key: "selectedSegmentLengthValue", model: SelectedTimer.self) {
            self.selectedSegmentLengthValue = selectedSegmentLengthValue
        } else {
            self.selectedSegmentLengthValue = SelectedTimer(value: "240", selectedRow: (segmentLengthOptions.count - 1))
            self.selectedSegmentLengthValue.saveWithKey(key: "selectedSegmentLengthValue")
        }
        if let segmentLenghValue = Int(selectedSegmentLengthValue.value) {
            videoSegmentSeconds = CGFloat(segmentLenghValue)
            segmentLengthSelectedLabel.text = selectedSegmentLengthValue.value
        }
        
        pauseTimerSelectedLabel.text = selectedPauseTimerValue.value
        timerSelectedLabel.text = selectedTimerValue.value
        photoTimerSelectedLabel.text = selectedPhotoTimerValue.value
        
        recordingType = Defaults.shared.cameraMode
        cameraSliderView.selectCell = Defaults.shared.cameraMode.rawValue
    }
    
    func setupLayoutCameraSliderView() {
        cameraSliderView.stringArray = cameraModeArray
        cameraSliderView.bottomImage = R.image.cameraModeSelect()
        cameraSliderView.cellTextColor = .white
        cameraSliderView.currentCell = { [weak self] (index) in
            guard let `self` = self else { return }
            Defaults.shared.cameraMode = CameraMode(rawValue: index) ?? .normal
            self.isRecording = false
            
            self.totalDurationOfOneSegment = 0.0
            self.circularProgress.animate(toAngle: 0, duration: 0, completion: nil)
        
            self.showControls()
            self.currentState = .open
            self.animateTransitionIfNeeded(to: self.currentState.opposite, duration: 1)
            self.timerValueView.isHidden = false
            self.segmentLengthSelectedLabel.text = self.selectedSegmentLengthValue.value
            self.circularProgress.centerImage = UIImage()
            switch index {
            case 3:
                self.circularProgress.centerImage = R.image.icoBoomrang()
                self.recordingType = .boomerang
                self.timerValueView.isHidden = true
                if self.timerValue > 0 {
                    self.timerValue = 0
                    self.resetCountDown()
                }
                if self.photoTimerValue > 0 {
                    self.photoTimerValue = 0
                    self.resetPhotoCountDown()
                }
            case 4:
                self.circularProgress.centerImage = R.image.icoSildeshowMode()
                self.recordingType = .slideshow
                self.timerValueView.isHidden = true
            case 5:
                self.circularProgress.centerImage = R.image.icoCollageMode()
                self.recordingType = .collage
                self.timerValueView.isHidden = true
            case 6:
                self.circularProgress.centerImage = R.image.icoHandsFree()
                if self.recordingType == .custom || self.recordingType == .boomerang || self.recordingType == .capture {
                    self.selectedSegmentLengthValue = SelectedTimer(value: "240", selectedRow: (self.segmentLengthOptions.count - 1))
                    self.selectedSegmentLengthValue.saveWithKey(key: "selectedSegmentLengthValue")
                    self.videoSegmentSeconds = CGFloat((Int(self.selectedSegmentLengthValue.value) ?? 240))
                }
                self.recordingType = .handsfree
                if self.isRecording {
                    self.isRecording = true
                }
            case 7:
                self.circularProgress.centerImage = R.image.icoCustomMode()
                self.recordingType = .custom
                self.timerValueView.isHidden = true
            case 8:
                self.recordingType = .capture
                self.timerValueView.isHidden = false
            default:
                self.recordingType = .normal
            }
        }
    }
    
    func setupLayout() {
        let layout = self.stopMotionCollectionView.collectionViewLayout as? UPCarouselFlowLayout
        layout?.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: 0.01)
        stopMotionCollectionView.register(R.nib.imageCollectionViewCell)
    }
    
    func setupCountDownView() {
        self.view.addSubview(sfCountdownView)
    }
    
    func changePermissionButtonColor() {
        if ApplicationSettings.isCameraEnabled {
            enableCameraButton.setTitleColor(ApplicationSettings.appLightGrayColor, for: .normal)
        } else {
            enableCameraButton.setTitleColor(R.color.appPrimaryColor(), for: .normal)
        }
        if ApplicationSettings.isMicrophoneEnabled {
            enableMicrophoneButton.setTitleColor(ApplicationSettings.appLightGrayColor, for: .normal)
        } else {
            enableMicrophoneButton.setTitleColor(R.color.appPrimaryColor(), for: .normal)
        }
    }
    
    func checkPermissions() {
        #if targetEnvironment(simulator)
        blurView.isHidden = false
        enableAccessView.isHidden = false
        #else
        changePermissionButtonColor()
        if ApplicationSettings.isCameraEnabled && ApplicationSettings.isMicrophoneEnabled {
            blurView.isHidden = true
            enableAccessView.isHidden = true
            initCamera()
        } else {
            blurView.isHidden = false
            enableAccessView.isHidden = false
        }
        #endif
    }
    
    
    public func removeData() {
        self.totalDurationOfOneSegment = 0.0
        self.circularProgress.animate(toAngle: 0, duration: 0, completion: nil)
        self.takenSlideShowImages.removeAll()
        self.takenImages.removeAll()
        self.takenVideoUrls.removeAll()
        self.stopMotionCollectionView.reloadData()
    }
    
    @objc func speedSliderValueChanged(_ sender: Any) {
        videoSpeedType = speedSlider.speedType
        guard nextLevel.isRecording else {
            return
        }
        switch speedSlider.value {
        case 0:
            nextLevel.videoConfiguration.timescale = 3
            self.speedLabel.text = "Slow 3x"
            self.speedLabel.startBlink()
            break
        case 1:
            nextLevel.videoConfiguration.timescale = 2
            self.speedLabel.text = "Slow 2x"
            self.speedLabel.startBlink()
            break
        case 3:
            nextLevel.videoConfiguration.timescale = 1/2
            self.speedLabel.text = "Fast 2x"
            self.speedLabel.startBlink()
            break
        case 4:
            nextLevel.videoConfiguration.timescale = 1/3
            self.speedLabel.text = "Fast 3x"
            self.speedLabel.startBlink()
            break
        default:
            nextLevel.videoConfiguration.timescale = 1
            self.speedLabel.text = ""
            self.speedLabel.stopBlink()
            break
        }
        self.view.bringSubviewToFront(self.speedLabel)
    }
    
    func showCollectionView(_ mode: CollectionMode = .effect) {
        self.collectionMode = mode
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func hidenCollectionView() {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func setupMuteUI() {
        if isMute {
            muteButton.setImage(R.image.storyMute(), for: UIControl.State.normal)
            muteLabel.text = R.string.localizable.micOff()
        } else {
            muteButton.setImage(R.image.unmute(), for: UIControl.State.normal)
            muteLabel.text = R.string.localizable.micOn()
        }
    }
    
    func resetCountDown() {
        selectedTimerValue.value = "-"
        selectedTimerValue.selectedRow = 0
        timerSelectedLabel.text = selectedTimerValue.value
        self.selectedTimerValue.saveWithKey(key: "selectedTimerValue")
    }
    
    func resetPauseCountDown() {
        selectedPauseTimerValue.value = "-"
        selectedPauseTimerValue.selectedRow = 0
        pauseTimerSelectedLabel.text = selectedPauseTimerValue.value
        self.selectedPauseTimerValue.saveWithKey(key: "selectedPauseTimerValue")
    }
    
    func resetPhotoCountDown() {
        selectedPhotoTimerValue.value = "-"
        selectedPhotoTimerValue.selectedRow = 0
        photoTimerSelectedLabel.text = selectedPhotoTimerValue.value
        self.selectedPhotoTimerValue.saveWithKey(key: "selectedPhotoTimerValue")
    }
    
    func setupFlashUI() {
        switch flashMode {
        case .off:
            flashButton.setImage(R.image.flashOff(), for: UIControl.State.normal)
            flashLabel.text = R.string.localizable.noFlash()
        case .auto:
            flashButton.setImage(R.image.flashAuto(), for: UIControl.State.normal)
            flashLabel.text = R.string.localizable.autoFlash()
        case .on:
            flashButton.setImage(R.image.flashOn(), for: UIControl.State.normal)
            flashLabel.text = R.string.localizable.flash()
        @unknown default:
            flashButton.setImage(R.image.flashOff(), for: UIControl.State.normal)
            flashLabel.text = R.string.localizable.noFlash()
        }
    }
   
    func initCamera() {
        self.baseView.layoutIfNeeded()
        self.focusView = FocusIndicatorView(frame: .zero)
        
        self.gestureView = UIView(frame: self.view.bounds)
        if let gestureView = self.gestureView {
            gestureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            gestureView.backgroundColor = .clear
            self.baseView.insertSubview(gestureView, at: 0)
            
            let focusTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleFocusTapGestureRecognizer(_:)))
            focusTapGestureRecognizer.delegate = self
            focusTapGestureRecognizer.numberOfTapsRequired = 1
            gestureView.addGestureRecognizer(focusTapGestureRecognizer)
            
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGestureRecognizer(_:)))
            gestureView.addGestureRecognizer(pinchGestureRecognizer)
        }
        
        self.previewView = UIView(frame: self.baseView.bounds)
        if let previewView = self.previewView {
            previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            previewView.backgroundColor = UIColor.black
            NextLevel.shared.previewLayer.frame = previewView.bounds
            previewView.layer.addSublayer(NextLevel.shared.previewLayer)
            self.baseView.insertSubview(previewView, at: 0)
        }
        
        self.longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureRecognizer(_:)))
        if let longPressGestureRecognizer = self.longPressGestureRecognizer {
            circularProgress.isUserInteractionEnabled = true
            
            longPressGestureRecognizer.delegate = self
            longPressGestureRecognizer.minimumPressDuration = 0.5
            longPressGestureRecognizer.allowableMovement = 10.0
            circularProgress.addGestureRecognizer(longPressGestureRecognizer)
        }
        
        self.photoTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handlePhotoTapGestureRecognizer(_:)))
        if let photoTapGestureRecognizer = self.photoTapGestureRecognizer {
            circularProgress.isUserInteractionEnabled = true
            
            photoTapGestureRecognizer.delegate = self
            circularProgress.addGestureRecognizer(photoTapGestureRecognizer)
        }
        nextLevel.devicePosition = currentCameraPosition
        nextLevel.videoConfiguration.preset = AVCaptureSession.Preset.hd1920x1080
        nextLevel.videoConfiguration.bitRate = 5500000
        nextLevel.videoConfiguration.profileLevel = AVVideoProfileLevelH264HighAutoLevel
        nextLevel.audioConfiguration.bitRate = 96000
        nextLevel.deviceDelegate = self
        nextLevel.videoDelegate = self
        nextLevel.metadataObjectsDelegate = self
        nextLevel.metadataObjectTypes = [AVMetadataObject.ObjectType.face, AVMetadataObject.ObjectType.qr]
        
    }
    
    @objc  func handleFocusTapGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        let tapPoint = gestureRecognizer.location(in: self.previewView)
        
        if let focusView = self.focusView {
            var focusFrame = focusView.frame
            focusFrame.origin.x = CGFloat((tapPoint.x - (focusFrame.size.width * 0.5)).rounded())
            focusFrame.origin.y = CGFloat((tapPoint.y - (focusFrame.size.height * 0.5)).rounded())
            focusView.frame = focusFrame
            
            self.previewView?.addSubview(focusView)
            focusView.startAnimation()
        }
        
        let adjustedPoint = NextLevel.shared.previewLayer.captureDevicePointConverted(fromLayerPoint: tapPoint)
        NextLevel.shared.focusExposeAndAdjustWhiteBalance(atAdjustedPoint: adjustedPoint)
    }
    
    @objc  func handlePinchGestureRecognizer(_ pinchGestureRecognizer: UIPinchGestureRecognizer) {
        func minMaxZoom(_ factor: Float) -> Float {
            return min(max(factor, 1.0), 10.0)
        }
        let newScaleFactor = minMaxZoom(Float(pinchGestureRecognizer.scale) * Float(lastZoomFactor))
        switch pinchGestureRecognizer.state {
        case .began: fallthrough
        case .changed: NextLevel.shared.videoZoomFactor = newScaleFactor
        case .ended:
            lastZoomFactor = CGFloat(minMaxZoom(newScaleFactor))
            NextLevel.shared.videoZoomFactor = newScaleFactor
        default: break
        }
    }
    
    func addAskQuestionReplyView() {
        switch storiCamType {
        case .replyStory(let question, let answer):
            let replyAskQueView = AskQuestionReplyView()
            replyAskQueView.questionText = question
            replyAskQueView.answerText = answer
            self.baseView.insertSubview(replyAskQueView, at: 0)
            
            replyAskQueView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                replyAskQueView.centerXAnchor.constraint(equalTo: self.baseView.centerXAnchor, constant: 0),
                replyAskQueView.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor, constant: 0),
                replyAskQueView.widthAnchor.constraint(equalTo: self.baseView.widthAnchor, multiplier: 0.7)
            ])
            replyAskQueView.layoutIfNeeded()
            replyAskQueView.updateColors()
            self.addGesturesTo(view: replyAskQueView)
        default:
            break
        }
    }
}
// MARK: Manage Application State
extension StoryCameraViewController {
    
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
            stopCapture()
            if nextLevel.isRecording {
                self.isStopConnVideo = true
                self.stopRecording()
            }
        }
    }
    
    @objc func enterForeground(_ notifi: Notification) {
        
        if isViewAppear {
            startCapture()
        }
        
    }
    
}

extension StoryCameraViewController: PhotosPickerViewControllerDelegate {
    
    func selectAlbum(collection: PHAssetCollection) {
        
    }
    
    func albumViewCameraRollUnauthorized() {
        
    }
    
    func albumViewCameraRollAuthorized() {
        
    }
    
    func dismissPhotoPicker(withTLPHAssets: [ImageAsset]) {
        if !withTLPHAssets.isEmpty {
            if self.recordingType == .slideshow || self.recordingType == .collage {
                for image in withTLPHAssets {
                    self.takenSlideShowImages.append(SegmentVideos(urlStr: URL.init(string: Constant.Application.imageIdentifier)!, thumbimage: image.fullResolutionImage!, latitued: nil, longitued: nil, placeAddress: nil, numberOfSegement: String(self.takenSlideShowImages.count + 1), videoduration: nil, combineOneVideo: false))
                }
                DispatchQueue.main.async {
                    self.stopMotionCollectionView.reloadData()
                    
                    if self.takenSlideShowImages.count == 20 {
                        self.btnDoneClick(sender: UIButton())
                    }
                }
            } else {
                if withTLPHAssets.count == 1 {
                    if withTLPHAssets[0].assetType == .video {
                        if let videoUrl = withTLPHAssets[0].videoUrl {
                            do {
                                let videodata = try Data(contentsOf: videoUrl)
                                let videoName = String.fileName + FileExtension.mp4.rawValue
                                let data = videodata
                                let url = Utils.getLocalPath(videoName)
                                try? data.write(to: url)
                                if self.recordingType == .custom {
                                    self.takenVideoUrls.append(SegmentVideos(urlStr: url, thumbimage: withTLPHAssets[0].thumbImage, latitued: nil, longitued: nil, placeAddress: nil, numberOfSegement: String(self.takenSlideShowImages.count + 1), videoduration: nil, combineOneVideo: false))
                                    self.stopMotionCollectionView.reloadData()
                                } else {
                                    DispatchQueue.main.async {
                                        self.openPhotoEditorForVideo(videoURLs: [SegmentVideos.init(urlStr: url, thumbimage: withTLPHAssets[0].thumbImage, latitued: nil, longitued: nil, placeAddress: nil, numberOfSegement: "\(self.takenVideoUrls.count + 1)", videoduration: nil)],
                                                                     images: [withTLPHAssets[0].thumbImage])
                                    }
                                }
                            } catch {
                                
                            }
                            
                        } else if let asset = withTLPHAssets[0].asset {
                            let manager = PHImageManager.default()
                            manager.requestAVAsset(forVideo: asset, options: nil) { (avasset, _, _) in
                                if let avassetURL = avasset as? AVURLAsset {
                                    if self.recordingType == .custom {
                                        self.takenVideoUrls.append(SegmentVideos(urlStr: avassetURL.url, thumbimage: withTLPHAssets[0].thumbImage, latitued: nil, longitued: nil, placeAddress: nil, numberOfSegement: String(self.takenSlideShowImages.count + 1), videoduration: nil, combineOneVideo: false))
                                        self.stopMotionCollectionView.reloadData()
                                    } else {
                                        DispatchQueue.main.async {
                                            self.openPhotoEditorForVideo(videoURLs: [SegmentVideos.init(urlStr: avassetURL.url, thumbimage: withTLPHAssets[0].thumbImage, latitued: nil, longitued: nil, placeAddress: nil, numberOfSegement: "\(self.takenVideoUrls.count + 1)", videoduration: nil)],
                                                                         images: [withTLPHAssets[0].thumbImage])
                                        }
                                    }
                                } else {
                                    self.showAlert(alertMessage: R.string.localizable.selectedVideoIsnTSupported())
                                }
                            }
                        }
                    } else {
                        self.recordingType = .normal
                        self.openPhotoEditorForImage(withTLPHAssets[0].fullResolutionImage!)
                    }
                    
                } else {
                    let exportGroup = DispatchGroup()
                    let exportQueue = DispatchQueue(label: "com.queue.videoQueue")
                    let dispatchSemaphore = DispatchSemaphore(value: 0)
                    
                    for video in withTLPHAssets {
                        exportGroup.enter()
                        if let videoUrl = video.videoUrl {
                            do {
                                let videodata = try Data(contentsOf: videoUrl)
                                let videoName = String.fileName + FileExtension.mov.rawValue
                                let data = videodata
                                let url = Utils.getLocalPath(videoName)
                                try? data.write(to: url)
                                self.takenVideoUrls.append(SegmentVideos(urlStr: url, thumbimage: video.thumbImage, latitued: nil, longitued: nil, placeAddress: nil, numberOfSegement: String(self.takenSlideShowImages.count + 1), videoduration: nil, combineOneVideo: false))
                                
                                dispatchSemaphore.signal()
                                exportGroup.leave()
                            } catch {
                                
                            }
                        } else if let asset = video.asset, video.assetType == .video {
                            let manager = PHImageManager.default()
                            manager.requestAVAsset(forVideo: asset, options: nil) { (avasset, _, _) in
                                if let avassetURL = avasset as? AVURLAsset {
                                    DispatchQueue.main.async {
                                        self.takenVideoUrls.append(SegmentVideos(urlStr: avassetURL.url, thumbimage: video.thumbImage, latitued: nil, longitued: nil, placeAddress: nil, numberOfSegement: String(self.takenSlideShowImages.count + 1), videoduration: nil, combineOneVideo: false))
                                    }
                                    dispatchSemaphore.signal()
                                    exportGroup.leave()
                                } else {
                                    self.showAlert(alertMessage: R.string.localizable.selectedVideoIsnTSupported())
                                    dispatchSemaphore.signal()
                                    exportGroup.leave()
                                }
                            }
                            dispatchSemaphore.wait()
                        } else if video.assetType == .image {
                            self.takenSlideShowImages.append(SegmentVideos(urlStr: URL.init(string: Constant.Application.imageIdentifier)!, thumbimage: video.fullResolutionImage, latitued: nil, longitued: nil, placeAddress: nil, numberOfSegement: String(self.takenSlideShowImages.count + 1), videoduration: nil, combineOneVideo: false))
                            dispatchSemaphore.signal()
                            exportGroup.leave()
                        } else {
                            dispatchSemaphore.signal()
                            exportGroup.leave()
                        }
                    }
                    exportGroup.notify(queue: exportQueue) {
                        print("finished......")
                        DispatchQueue.main.async {
                            var internalStoryData = [InternalStoryData]()
                            
                            for url in self.takenSlideShowImages {
                                if url.url == URL.init(string: Constant.Application.imageIdentifier) {
                                    let image = url.image!
                                    let storyTime = "3.0"
                                    let fileName = String.fileName + FileExtension.jpg.rawValue
                                    let data = image.jpegData(compressionQuality: 1.0)
                                    let url = Utils.getLocalPath(fileName)
                                    try? data?.write(to: url)
                                    
                                    let storyData = InternalStoryData(address: "", duration: storyTime, lat: "", long: "", thumbTime: 0.0, type: "image", url: url.absoluteString, userId: Defaults.shared.currentUser?.id ?? "", watermarkURL: "", isMute: false, filterName: nil, exportedUrls: [""], hiddenHashtags: nil, tags: nil)
                                    storyData.publish = Defaults.shared.isPublish ? 1 : 0
                                    internalStoryData.append(storyData)
                                } else {
                                    var urls = [String]()
                                    for segementModel in url.videos {
                                        urls.append(segementModel.url?.absoluteString ?? "")
                                    }
                                    let fileName = String.fileName + FileExtension.png.rawValue
                                    let data = url.image!.pngData()
                                    let watermarkURL = Utils.getLocalPath(fileName)
                                    try? data?.write(to: watermarkURL)
                                    
                                    let storyData = InternalStoryData(address: "", duration: "", lat: "", long: "", thumbTime: url.thumbTime!.seconds, type: "video", url: "", userId: Defaults.shared.currentUser?.id ?? "", watermarkURL: watermarkURL.absoluteString, isMute: false, filterName: nil, exportedUrls: urls, hiddenHashtags: nil, tags: nil)
                                    storyData.publish = Defaults.shared.isPublish ? 1 : 0
                                    internalStoryData.append(storyData)
                                }
                            }
                            if Defaults.shared.isPro {
                                _ = StoryDataManager.shared.createStoryUploadData(internalStoryData)
                                StoryDataManager.shared.startUpload()
                                self.takenSlideShowImages.removeAll()
                            } else {
                                if !self.takenSlideShowImages.isEmpty {
                                    self.takenVideoUrls.removeAll()
                                    var tempTakenImagesURLs: [SegmentVideos] = []
                                    for item in self.takenSlideShowImages {
                                        tempTakenImagesURLs.append(item)
                                    }
                                    self.recordingType = .slideshow
                                    self.cameraSliderView.selectCell = self.recordingType.rawValue
                                    
                                    self.takenSlideShowImages = tempTakenImagesURLs
                                } else {
                                    self.takenSlideShowImages.removeAll()
                                    if self.recordingType != .custom {
                                        var tempTakenVideoURLs: [SegmentVideos] = []
                                        for item in self.takenVideoUrls {
                                            tempTakenVideoURLs.append(item)
                                        }
                                        self.recordingType = .custom
                                        self.cameraSliderView.selectCell = self.recordingType.rawValue
                                        self.takenVideoUrls = tempTakenVideoURLs
                                    }
                                }
                                
                                self.stopMotionCollectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
}


// MARK: Setup Focus View
extension StoryCameraViewController {
    
    func setAlphaOnControls(_ views: [UIView], alpha: CGFloat) {
        for view in views {
            view.alpha = alpha
        }
    }
}

// MARK: Setup Recording
extension StoryCameraViewController {
    
    func hideRecordingControls() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1, animations: {
                if self.recordingType == .slideshow || self.recordingType == .collage {
                    self.fpsView.alpha = 0
                    self.timerValueView.alpha = 0
                } else {
                    self.nextButtonView.alpha = 0
                    self.settingsView.alpha = 0
                    self.outtakesView.alpha = 0
                    self.fpsView.alpha = 0
                    self.timerValueView.alpha = 0
                    self.faceFiltersView.alpha = 0
                    self.cameraSliderView.alpha = 0
                }
            })
        }
    }
    
    func showControls() {
        if !self.hideControls {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.1, animations: {
                    if self.recordingType == .slideshow || self.recordingType == .collage || self.recordingType == .capture || self.recordingType == .custom {
                        self.nextButtonView.alpha = 1
                    }
                    self.cameraSliderView.alpha = 1
                    self.outtakesView.alpha = 1
                    self.settingsView.alpha = 1
                    self.fpsView.alpha = 1
                    self.timerValueView.alpha = 1
                    self.faceFiltersView.alpha = 1
                    self.collectionViewStackVIew.alpha = 1
                })
            }
        }
    }
    
    func startRecording() {
        guard !nextLevel.isRecording else {
            return
        }
        self.isMute ? muteButton.startBlink(0.5) : muteButton.stopBlink()
        self.view.bringSubviewToFront(slowVerticalBar.superview ?? UIView())
        slowVerticalBar.isHidden = false
        fastVerticalBar.isHidden = false
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.circularProgress.trackThickness = 0.75*1.5
            self.circularProgress.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }, completion: { completed in
            NextLevel.shared.record()
            var totalSeconds = self.videoSegmentSeconds
            if self.recordingType == .custom {
                totalSeconds = 240
            } else if self.recordingType == .boomerang {
                totalSeconds = 2
            }
            self.circularProgress.animate(toAngle: 360, duration: Double(totalSeconds) - (NextLevel.shared.session?.totalDuration.seconds ?? 0)) { completed in
                if completed {
                    print("animation stopped, completed")
                    self.isStopConnVideo = false
                    self.stopRecording()
                } else {
                    print("animation stopped, was interrupted")
                }
            }
        })
        speedSlider.isUserInteractionEnabled = (recordingType == .handsfree || recordingType == .timer)
        hideRecordingControls()
    }
    
    func stopRecording() {
        muteButton.stopBlink()
        if self.recordingType == .custom {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.circularProgress.trackThickness = 0.75
                self.circularProgress.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: { (_: Bool) in
                self.nextLevel.pause {
                    if let session = self.nextLevel.session {
                        if let url = session.lastClipUrl {
                            self.takenVideoUrls.append(SegmentVideos(urlStr: url, thumbimage: session.clips.last?.thumbnailImage, latitued: nil, longitued: nil, placeAddress: nil, numberOfSegement: "\(self.takenVideoUrls.count + 1)", videoduration: nil, combineOneVideo: true))
                            
                            DispatchQueue.main.async {
                                self.setupForPreviewScreen()
                            }
                            session.removeAllClips(removeFiles: false)
                        } else if session.currentClipHasStarted {
                            session.endClip(completionHandler: { (clip, error) in
                                if error == nil, let url = clip?.url {
                                    self.takenVideoUrls.append(SegmentVideos(urlStr: url, thumbimage: clip?.thumbnailImage, latitued: nil, longitued: nil, placeAddress: nil, numberOfSegement: "\(self.takenVideoUrls.count + 1)", videoduration: nil, combineOneVideo: true))
                                    
                                    DispatchQueue.main.async {
                                        self.setupForPreviewScreen()
                                    }
                                    session.removeAllClips(removeFiles: false)
                                }
                            })
                        }
                    }
                }
            })
            return
        }
        showControls()
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.circularProgress.trackThickness = 0.75
            self.circularProgress.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: { (_: Bool) in
            self.nextLevel.pause {
                self.circularProgress.animate(toAngle: 0, duration: 0) { _ in
                    if let session = self.nextLevel.session {
                        if let url = session.lastClipUrl {
                            print("Recording completed \(url.path)")
                            self.takenVideoUrls.append(SegmentVideos(urlStr: url, thumbimage: session.clips.last?.thumbnailImage, latitued: nil, longitued: nil, placeAddress: nil, numberOfSegement: "\(self.takenVideoUrls.count + 1)", videoduration: nil))
                            session.removeAllClips(removeFiles: false)
                            DispatchQueue.main.async {
                                self.setupForPreviewScreen()
                            }
                        } else if session.currentClipHasStarted {
                            session.endClip(completionHandler: { (clip, error) in
                                if error == nil, let url = clip?.url {
                                    print("Recording completed \(url.path)")
                                    self.takenVideoUrls.append(SegmentVideos(urlStr: url, thumbimage: clip?.thumbnailImage, latitued: nil, longitued: nil, placeAddress: nil, numberOfSegement: "\(self.takenVideoUrls.count + 1)", videoduration: nil))
                                    session.removeAllClips(removeFiles: false)
                                    DispatchQueue.main.async {
                                        self.setupForPreviewScreen()
                                    }
                                }
                            })
                        }
                    }
                    self.nextLevel.audioConfiguration.isMute = self.isMute
                }
            }
        })
    }
    
    func getDurationOf(videoPath: URL) -> Double {
        return AVAsset.init(url: videoPath).duration.seconds
    }
    
    func displayCountDown(_ value: Int) {
        DispatchQueue.main.async {
            self.isCountDownStarted = true
            
            self.sfCountdownView.isHidden = false
            self.sfCountdownView.countdownFrom = value
            self.sfCountdownView.start()
            self.view.bringSubviewToFront(self.sfCountdownView)
        }
    }
    
    func setupForPreviewScreen() {
        self.stopMotionCollectionView.reloadData()
        let layout = self.stopMotionCollectionView.collectionViewLayout as? UPCarouselFlowLayout
        let pageSide = (layout?.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        self.stopMotionCollectionView?.contentOffset.x = (self.stopMotionCollectionView?.contentSize.width)! + pageSide
        
        if self.recordingType == .custom {
            self.showControls()
            totalDurationOfOneSegment += self.getDurationOf(videoPath: (self.takenVideoUrls.last?.url)!)
            self.isRecording = false
            if totalDurationOfOneSegment > 240.0 {
                totalDurationOfOneSegment = 0.0
                self.openPhotoEditorForVideo()
            }
            
        } else if self.recordingType == .boomerang {
            self.showControls()
            self.isRecording = false
            self.videoSpeedType = .normal
            self.speedSliderLabels.value = 2
            self.speedSlider.value = 2
            self.isSpeedChanged = false
            if (self.recordingType == .timer) || (self.recordingType == .photoTimer) {
                self.recordingType = .normal
            }
            self.openPhotoEditorForVideo()
        } else if self.recordingType == .capture {
            self.showControls()
            self.isRecording = false
            let album = SCAlbum.shared
            album.albumName = "\(Constant.Application.displayName) - StoryCam"
            if let url = self.takenVideoUrls.last?.url {
                album.saveMovieToLibrary(movieURL: url)
                self.view.makeToast(R.string.localizable.videoSaved())
            }
            
            DispatchQueue.main.async {
                self.speedSlider.isUserInteractionEnabled = true
                self.slowVerticalBar.isHidden = true
                self.fastVerticalBar.isHidden = true
                self.speedLabel.textColor = UIColor.red
                self.speedLabel.text = ""
                self.speedLabel.stopBlink()
                
                if self.recordingType != .timer {
                    self.takenImages.removeAll()
                    self.takenVideoUrls.removeAll()
                    self.dragAndDropManager = KDDragAndDropManager(
                        canvas: self.view,
                        collectionViews: [self.stopMotionCollectionView]
                    )
                    self.deleteRect = self.deleteView.frame
                    self.stopMotionCollectionView.reloadData()
                }
            }
        } else {
            let currentVideoSeconds = self.videoSegmentSeconds
            if !self.isStopConnVideo && currentVideoSeconds*CGFloat(self.takenVideoUrls.count) < 240 {
                if (self.recordingType == .handsfree || self.recordingType == .timer) && self.pauseTimerValue > 0 && !nextLevel.isRecording {
                    self.displayCountDown(self.pauseTimerValue)
                } else {
                    self.isRecording = true
                    self.startRecording()
                }
            } else {
                self.showControls()
                self.isRecording = false
                self.videoSpeedType = .normal
                self.speedSliderLabels.value = 2
                self.speedSlider.value = 2
                self.isSpeedChanged = false
                if (self.recordingType == .timer) || (self.recordingType == .photoTimer) {
                    self.recordingType = .normal
                }
                self.openPhotoEditorForVideo()
            }
        }
    }
    
    func setCameraPositionUI() {
        switch self.currentCameraPosition {
        case .front:
            self.flipLabel.text = R.string.localizable.selfie()
            self.flipButton.setImage(R.image.cameraFlip(), for: UIControl.State.normal)
        case .back:
            self.flipLabel.text = R.string.localizable.rear()
            self.flipButton.setImage(R.image.cameraFlipBack(), for: UIControl.State.normal)
        default:
            break
        }
    }
}

extension StoryCameraViewController {
    
    func openPhotoEditorForVideo() {
        let photoEditor = getPhotoEditor()
        photoEditor.videoUrls = self.takenVideoUrls
        photoEditor.currentCamaraMode = recordingType
        if recordingType == .custom {
            photoEditor.isOriginalSequence = true
        }
        self.navigationController?.pushViewController(photoEditor, animated: true)
        self.removeData()
    }
    
    func openCollageMakerForCollage() {
        DispatchQueue.main.async {
            if let collageMakerVC = R.storyboard.collageMaker.collageMakerVC() {
                collageMakerVC.assets = self.takenSlideShowImages
                collageMakerVC.delegate = self
                self.navigationController?.pushViewController(collageMakerVC, animated: true)
                self.removeData()
            }
        }
    }
    
    func openPhotoEditorForSlideShow() {
        let photoEditor = getPhotoEditor(storiType: .slideShow)
        photoEditor.videoUrls = self.takenSlideShowImages
        photoEditor.currentCamaraMode = recordingType
        self.navigationController?.pushViewController(photoEditor, animated: true)
        removeData()
    }
    
    func openPhotoEditorForImage(_ image: UIImage) {
        let photoEditor = getPhotoEditor()
        photoEditor.image = image
        self.navigationController?.pushViewController(photoEditor, animated: true)
        self.removeData()
    }
    
    func openPhotoEditorForVideo(videoURLs: [SegmentVideos], images: [UIImage]) {
        let photoEditor = getPhotoEditor()
        photoEditor.videoUrls = videoURLs
        self.navigationController?.pushViewController(photoEditor, animated: true)
        self.removeData()
    }
    
    func getPhotoEditor(storiType: StoriType = .default) -> PhotoEditorViewController {
        
        guard let photoEditor = R.storyboard.photoEditor.photoEditorViewController() else {
            fatalError("PhotoEditorViewController Not Found")
        }
        photoEditor.outtakesDelegate = self
        photoEditor.storiCamType = storiCamType
        photoEditor.storiType = storiType
        photoEditor.storySelectionDelegate = storySelectionDelegate
        return photoEditor
    }
    
}
