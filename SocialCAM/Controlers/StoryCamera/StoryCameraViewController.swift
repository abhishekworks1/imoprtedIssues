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
import JPSVolumeButtonHandler
import SafariServices

public class CameraModes {
    var name: String
    var recordingType: CameraMode
    
    init(name: String, recordingType: CameraMode) {
        self.name = name
        self.recordingType = recordingType
    }
}

class StoryCameraViewController: UIViewController, ScreenCaptureObservable {
   
    let popupOffset: CGFloat = (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) != 0 ? 110 : 86
    
    var bottomConstraint = NSLayoutConstraint()
    var currentState: State = .closed
    /// All of the currently running animators.
    var runningAnimators = [UIViewPropertyAnimator]()
    /// The progress of each animator. This array is parallel to the `runningAnimators` array.
    var animationProgress = [CGFloat]()
    
    private lazy var panRecognizer: InstantPanGestureRecognizer = {
        let recognizer = InstantPanGestureRecognizer()
        recognizer.delegate = self
        recognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
        return recognizer
    }()
    
    var timer: Timer?
    var volButtonTimer: Timer?
    var secondsElapsed: Int = 0
    var isBusinessCenter: Bool = false
    var quickLinkAppUrl: URL?
    var quickLinkWebsiteUrl: URL?
    
    // MARK: IBOutlets
    @IBOutlet weak var bottomCameraViews: UIView!
    @IBOutlet weak var collectionViewStackVIew: UIStackView!
    @IBOutlet weak var settingsView: UIStackView!
    
    @IBOutlet weak var timerValueView: UIView!
    @IBOutlet weak var faceFiltersView: UIStackView!
    @IBOutlet weak var sceneFilterView: UIStackView!
    @IBOutlet weak var muteStackView: UIStackView!
    @IBOutlet weak var swipeCameraStackView: UIStackView!
    @IBOutlet weak var galleryStackView: UIStackView!
    @IBOutlet weak var fpsView: UIStackView!
    @IBOutlet weak var showhideView: UIStackView!
    @IBOutlet weak var outtakesView: UIStackView!
    @IBOutlet weak var nextButtonView: UIStackView!
    @IBOutlet weak var timerStackView: UIStackView!
    @IBOutlet weak var flashStackView: UIStackView!
    @IBOutlet weak var lastCaptureImageView: UIImageView!
    
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
    
    @IBOutlet weak var lblRightSeparator: UILabel!
    @IBOutlet weak var lblLeftSeparator: UILabel!
    @IBOutlet weak var slowFastVerticalBar: UIView!
    @IBOutlet weak var verticalLines: VerticalBar!
    
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
            circularProgress.progressInsideFillColor = .white
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
    @IBOutlet weak var settingsButton: UIButton! {
        didSet {
            settingsButton.setImage(R.image.storySettings()!, for: .normal)
            settingsButton.setImage(R.image.storyBack()!, for: .selected)
        }
    }
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
    
    @IBOutlet weak var photoTimerView: UIView!
    @IBOutlet weak var flipLabel: UILabel!
    @IBOutlet weak var flashLabel: UILabel!
    @IBOutlet weak var transparentView: TransparentGradientView!
    @IBOutlet weak var zoomSlider: VSSlider!
    @IBOutlet weak var speedSliderLabels: TGPCamelLabels! {
        didSet {
            speedSliderLabels.names = ["-4x", "-3x", "-2x", "1x", "2x", "3x", "4x"]
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
    @IBOutlet weak var speedSliderWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var cameraModeIndicatorView: UIView!
    @IBOutlet var speedIndicatorView: [DottedLineView]!
    @IBOutlet weak var cameraModeIndicatorImageView: UIImageView!
    @IBOutlet weak var switchingAppView: UIView!
    @IBOutlet weak var switchAppButton: UIButton!
    @IBOutlet weak var confirmRecordedSegmentStackView: UIStackView!
    @IBOutlet weak var discardSegmentsStackView: UIStackView!
    @IBOutlet weak var discardSegmentButton: UIButton!
    @IBOutlet weak var signupTooltipView: UIView!
    @IBOutlet weak var quickLinkTooltipView: UIView!
    @IBOutlet weak var lblQuickLinkTooltipView: UILabel!
    @IBOutlet weak var btnDoNotShowAgain: UIButton!
    @IBOutlet weak var appSurveyPopupView: UIView!
    
    // MARK: Variables
    var recordButtonCenterPoint: CGPoint = CGPoint.init()
    
    var totalDurationOfOneSegment: Double = 0
    
    var isCountDownStarted: Bool = false {
        didSet {
            isPageScrollEnable = !isCountDownStarted
        }
    }
    
    var draggingCell: IndexPath?
    var dragAndDropManager: KDDragAndDropManager?
    var volumeHandler: JPSVolumeButtonHandler?
    var deleteRect: CGRect?
    
    var isDisableResequence: Bool = true {
        didSet {
            self.stopMotionCollectionView.isMovable = !isDisableResequence
        }
    }
    
    var isRecording: Bool = false {
        didSet {
            isPageScrollEnable = !isRecording
            if !isLiteApp {
                deleteView.isHidden = isRecording
            }
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
                                             self.nextButtonView,
                                             self.switchAppButton,
                                             self.discardSegmentsStackView,
                                             self.confirmRecordedSegmentStackView],
                                            alpha: alpha)
                    self.isHideTapped = self.hideControls
                    // Make the animation happen
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    var timerType = TimerType.segmentLength
    var selectedTimerValue = SelectedTimer(value: "-", selectedRow: 0)
    var selectedSegmentLengthValue = SelectedTimer(value: "15", selectedRow: 2)
    var selectedPauseTimerValue = SelectedTimer(value: "-", selectedRow: 0)
    var selectedPhotoTimerValue = SelectedTimer(value: "-", selectedRow: 0)
    var isMute: Bool = false {
        didSet {
            NextLevel.shared.audioConfiguration.isMute = self.isMute
        }
    }
    
    var isForceCaptureImageWithVolumeKey: Bool = false
    
    var recordingType: CameraMode = .basicCamera {
        didSet {
            if recordingType != .custom {
                DispatchQueue.main.async {
                    self.speedSlider.isUserInteractionEnabled = true
                    self.slowFastVerticalBar.isHidden = true
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
            
            isShowTimerButton = !(recordingType == .boomerang || recordingType == .slideshow || recordingType == .collage || recordingType == .capture || recordingType == .custom)
            
            isShowMuteButton = !(recordingType == .boomerang || recordingType == .slideshow || recordingType == .collage)
        }
    }
    
    var isShowTimerButton: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.timerButton.isUserInteractionEnabled = self.isShowTimerButton
                UIView.animate(withDuration: 0.1, animations: {
                    self.timerButton.alpha = self.isShowTimerButton ? 1.0 : 0.5
                })
            }
        }
    }
    
    var isShowMuteButton: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.muteButton.isUserInteractionEnabled = self.isShowMuteButton
                UIView.animate(withDuration: 0.1, animations: {
                    self.muteButton.alpha = self.isShowMuteButton ? 1.0 : 0.5
                })
            }
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
    var flashMode: AVCaptureDevice.TorchMode = .on
    var takenImages: [UIImage] = []
    var takenVideoUrls: [SegmentVideos] = [] {
        didSet {
            if (takenVideoUrls.count > 0) && (recordingType == .custom) {
                settingsButton.isSelected = true
            } else {
                settingsButton.isSelected = false
            }
        }
    }
    var takenSlideShowImages: [SegmentVideos] = []
    var videoSpeedType = VideoSpeedType.normal
    var isSpeedChanged = false
    var isStopConnVideo = false
    var firstPercentage: Double = 0.0
    var firstUploadCompletedSize: Double = 0.0
    
    var pageSize: CGSize {
        let layout = self.stopMotionCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
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
    
    var cameraModeArray: [CameraModes] = [
        CameraModes(name: R.string.localizable.fastsloW(), recordingType: .normal),
        CameraModes(name: R.string.localizable.fastmotioN(), recordingType: .fastMotion),
        CameraModes(name: R.string.localizable.photovideO(), recordingType: .basicCamera),
        CameraModes(name: R.string.localizable.boomI(), recordingType: .boomerang),
        CameraModes(name: R.string.localizable.slideshoW(), recordingType: .slideshow),
        CameraModes(name: R.string.localizable.collagE(), recordingType: .collage),
        CameraModes(name: R.string.localizable.handsfreE(), recordingType: .handsfree),
        CameraModes(name: R.string.localizable.custoM(), recordingType: .custom),
        CameraModes(name: R.string.localizable.capturE(), recordingType: .capture),
        CameraModes(name: R.string.localizable.freeMode(), recordingType: .promo),
        CameraModes(name: R.string.localizable.pic2ArtTitle(), recordingType: .pic2Art)]
        
    var timerOptions = ["-",
                        "1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
                        "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
                        "21", "22", "23", "24", "25", "26", "27", "28", "29", "30",
                        "31", "32", "33", "34", "35", "36", "37", "38", "39", "40",
                        "41", "42", "43", "44", "45", "46", "47", "48", "49", "50",
                        "51", "52", "53", "54", "55", "56", "57", "58", "59", "60"]
    
    var segmentLengthOptions = ["5", "10", "15", "20", "25", "30", "40", "50", "60", "70", "80", "90",
                                "100", "110", "120", "130", "140", "150", "160", "170", "180", "190", "200",
                                "210", "220", "230", "240"]
    
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
    var isUserTimerValueChange = true
    var isCameraLoadOnRecording = true
    var progressTimer: Timer?
    var progress: CGFloat = 0
    var progressMaxSeconds: CGFloat = 240
    var currentSpeed: CGFloat {
        var speedvalue = 1.0
        switch videoSpeedType {
        case .normal:
            speedvalue = 1.0
        case .slow(scaleFactor: 2):
            speedvalue = 2.0
        case .slow(scaleFactor: 3):
            speedvalue = 3.0
        case .slow(scaleFactor: 4):
            speedvalue = 4.0
        case .slow(scaleFactor: 5):
            speedvalue = 5.0
        case .fast(scaleFactor: 2):
            speedvalue = 1.0 / 2.0
        case .fast(scaleFactor: 3):
            speedvalue = 1.0 / 3.0
        case .fast(scaleFactor: 4):
            speedvalue = 1.0 / 4.0
        case .fast(scaleFactor: 5):
            speedvalue = 1.0 / 5.0
        default:
            speedvalue = 1.0
        }
        return CGFloat(speedvalue)
    }
    
    var observers = [NSObjectProtocol]()
    var pulse = Pulsing()
    var isHideTapped = false
    var isConfirmCapture = false
    var totalVideoDuration: [CGFloat] = []
    var segmentsProgress: [CGFloat] = []
    var cameraModeCell = 1
    var isVideoRecording = false
    var isVidplayAccountFound: Bool? = false
    var vidplaySessionToken = ""
    
    // MARK: ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getReferralNotification()
        UIApplication.shared.isIdleTimerDisabled = true
        setCameraSettings()
        checkPermissions()
        setupLayout()
        setupLayoutCameraSliderView()
        setupCountDownView()
        addAskQuestionReplyView()
        self.storyUploadManager.delegate = self
        self.storyUploadManager.startUpload()
        layout()
        switchingAppView.isHidden = true
        self.view.isMultipleTouchEnabled = true
        bottomCameraViews.addGestureRecognizer(panRecognizer)
        volumeButtonHandler()
        changeModeHandler()
        dynamicSetSlowFastVerticalBar()
        setViewsForApp()
        setupPic2ArtAppControls()
        if isQuickCamLiteApp || isQuickCamApp {
            setupRecordingView()
        }
        if isLiteApp {
            self.recordingType = .promo
            self.setupLiteAppMode(mode: .promo)
            self.timerValueView.isHidden = true
            for view in [self.lblLeftSeparator, self.lblRightSeparator, self.photoTimerSelectedLabel, self.pauseTimerSelectedLabel] {
                view?.isHidden = true
            }
        }
    }
    
    func setupRecordingView() {
        if self.faceFiltersView.viewWithTag(SystemBroadcastPickerViewBuilder.viewTag) == nil {
            SystemBroadcastPickerViewBuilder.setup(superView: self.faceFiltersView)
        }
    }
    
    private func reloadView() {
        guard let broadCastPicker = SystemBroadcastPickerViewBuilder.broadCastPicker else {
            return
        }
        SystemBroadcastPickerViewBuilder.layout(broadCastPickerView: broadCastPicker)
    }
    
    private func addObserverForRecordingView() {
        self.reloadView()
        let loadingView = RecorderStopScreenView.instanceFromNib()
        
        let observer = self.addObserver(forCapturedDidChange: { [weak self] _ in
            guard let `self` = self else {
                return
            }
            loadingView.show(on: self.view)
            self.reloadView()
        }) { [weak self] _ in
            guard let `self` = self else {
                return
            }
            loadingView.hide()
        }
        self.observers.append(observer)
    }
    
    func setupPic2ArtAppControls() {
        timerStackView.isHidden = isPic2ArtApp
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopCapture()
        self.isViewAppear = false
        removeVolumeButtonHandler()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.bringSubviewToFront(baseView)
        view.bringSubviewToFront(blurView)
        view.bringSubviewToFront(enableAccessView)
        view.bringSubviewToFront(selectTimersView)
        view.bringSubviewToFront(switchingAppView)
        view.bringSubviewToFront(quickLinkTooltipView)
        view.bringSubviewToFront(appSurveyPopupView)
        self.syncUserModel { _ in
            
        }
        getUserSettings()
        if isQuickCamLiteApp || isQuickCamApp {
            addObserverForRecordingView()
        }
        refreshCircularProgressBar()
        if isLiteApp {
            if self.recordingType == .promo {
                self.setupLiteAppMode(mode: .promo)
                for view in [self.lblLeftSeparator, self.lblRightSeparator, self.photoTimerSelectedLabel, self.pauseTimerSelectedLabel] {
                    view?.isHidden = true
                }
            }
            setupLayoutCameraSliderView()
            dynamicSetSlowFastVerticalBar()
        }
        enableFaceDetectionIfNeeded()
        swapeControlsIfNeeded()
        UIApplication.shared.isIdleTimerDisabled = true
        if Defaults.shared.isCameraSettingChanged {
            self.stopCapture()
            Defaults.shared.isCameraSettingChanged = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.isViewAppear = true
                self.startCapture()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.isViewAppear = true
                self.startCapture()
            }
        }
        observeState()
        self.flashView?.removeFromSuperview()
        DispatchQueue.main.async {
            self.recordButtonCenterPoint = self.circularProgress.center
        }
        self.speedSlider.isUserInteractionEnabled = true
        slowFastVerticalBar.isHidden = true
        self.speedLabel.textColor = UIColor.red
        self.speedLabel.text = ""
        self.speedLabel.stopBlink()
        if hideControls {
            hideControls = true
        }
        self.reloadUploadViewData()
        self.stopMotionCollectionView.reloadData()
        dynamicSetSlowFastVerticalBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if recordingType == .slideshow {
            recordingType = .slideshow
        } else if recordingType == .collage {
            recordingType = .collage
        }
        self.resetPositionRecordButton()
        addVolumeButtonHandler()
        addTikTokShareViewIfNeeded()
        if let pasteboard = UIPasteboard(name: UIPasteboard.Name(rawValue: Constant.Application.pasteboardName), create: true),
           let data = pasteboard.data(forPasteboardType: Constant.Application.pasteboardType),
            let image = UIImage(data: data) {
            UIPasteboard.remove(withName: UIPasteboard.Name(rawValue: Constant.Application.pasteboardName))
            openStoryEditor(images: [image])
        }
    }
    
    func addTikTokShareViewIfNeeded() {
        guard Defaults.shared.postViralCamModel != nil,
            let tiktokShareView = TikTokShareView.instanceFromNib() else {
                let tiktokShareViews = self.baseView.subviews.filter({ return $0 is TikTokShareView })
                if tiktokShareViews.count > 0 {
                    (tiktokShareViews[0] as? TikTokShareView)?.onDelete(UIButton())
                }
                return
        }
        let tiktokShareViews = self.baseView.subviews.filter({ return $0 is TikTokShareView })
        if tiktokShareViews.count > 0 {
            (tiktokShareViews[0] as? TikTokShareView)?.configureView()
            return
        }
        tiktokShareView.pannable = true

        if let previewView =  self.gestureView {
            self.baseView.insertSubview(tiktokShareView, aboveSubview: previewView)
        } else {
            self.baseView.insertSubview(tiktokShareView, at: 0)
        }
        tiktokShareView.translatesAutoresizingMaskIntoConstraints = false
        
        tiktokShareView.centerXAnchor.constraint(equalTo: self.baseView.centerXAnchor, constant: 0).isActive = true
        tiktokShareView.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor, constant: 0).isActive = true
        tiktokShareView.widthAnchor.constraint(equalToConstant: 318).isActive = true
    }
    
    func setViewsForApp() {
        if !isSocialCamApp {
            self.fpsView.isHidden = true
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
        print("Deinit \(self.description)")
    }
    
    func dynamicSetSlowFastVerticalBar() {
        var speedOptions = ["-3x", "-2x", "1x", "2x", "3x"]
        if recordingType == .fastMotion {
            speedOptions[0] = ""
            speedOptions[1] = ""
        }
        switch Defaults.shared.appMode {
        case .free, .basic:
            verticalLines.numberOfViews = .speed3x
            speedSliderLabels.names = speedOptions
            speedSliderLabels.value = 2
            speedSlider.ticksListener = speedSliderLabels
            speedSlider.tickCount = speedOptions.count
            speedSlider.value = 2
        case .advanced:
            speedOptions.append("4x")
            speedOptions.insert(recordingType == .fastMotion ? "" : "-4x", at: 0)
            verticalLines.numberOfViews = .speed4x
            speedSliderLabels.names = speedOptions
            speedSliderLabels.value = 3
            speedSlider.ticksListener = speedSliderLabels
            speedSlider.tickCount = speedOptions.count
            speedSlider.value = 3
        default:
            speedOptions.append(contentsOf: ["4x", "5x"])
            speedOptions.insert(contentsOf: [recordingType == .fastMotion ? "" : "-5x", recordingType == .fastMotion ? "" : "-4x"], at: 0)
            verticalLines.numberOfViews = .speed5x
            speedSliderLabels.names = speedOptions
            speedSliderLabels.value = 4
            speedSlider.ticksListener = speedSliderLabels
            speedSlider.tickCount = speedOptions.count
            speedSlider.value = 4
        }
        if recordingType == .fastMotion {
            verticalLines.visibleLeftSideViews = false
            speedSliderLabels.value = UInt(speedOptions.count/2)
            speedSlider.ticksListener = speedSliderLabels
            speedSlider.tickCount = speedOptions.count
            speedSlider.value = CGFloat(Int(speedOptions.count/2))
        }
        if recordingType == .normal || recordingType == .capture {
            if isLiteApp {
                verticalLines.visibleLeftSideViews = true
                verticalLines.numberOfViews = .speed3x
                speedSliderLabels.names = speedOptions
                speedSliderLabels.value = 2
                speedSlider.tickCount = speedOptions.count
                speedSlider.value = 2
                speedSlider.ticksListener = speedSliderLabels
                self.setupLiteAppMode(mode: .normal)
            } else {
                verticalLines.visibleLeftSideViews = true
            }
        }
        if recordingType == .promo {
            timerValueView.isHidden = true
            verticalLines.visibleLeftSideViews = false
            verticalLines.numberOfViews = .speed3x
            speedOptions = ["", "", "1x", "2x", "3x"]
            speedSliderLabels.names = speedOptions
            verticalLines.visibleLeftSideViews = false
            speedSliderLabels.value = 2
            speedSlider.ticksListener = speedSliderLabels
            speedSlider.tickCount = speedOptions.count
            speedSlider.value = 2
            self.setupLiteAppMode(mode: .promo)
        }
        if recordingType == .normal && isBoomiCamApp {
            recordingType = .basicCamera
        }
        if !isViralCamLiteApp || !isFastCamLiteApp || !isQuickCamLiteApp || !isSpeedCamLiteApp || !isSnapCamLiteApp || !isQuickApp {
            speedSlider.isHidden = false
            speedSliderView.isHidden = false
        } else {
            if recordingType != .basicCamera {
                speedSlider.isHidden = Defaults.shared.appMode == .free
                speedSliderView.isHidden = (isPic2ArtApp || isBoomiCamApp) ? true : Defaults.shared.appMode == .free
            } else {
                speedSlider.isHidden = true
                speedSliderView.isHidden = true
            }
        }
        
        speedSliderWidthConstraint.constant = UIScreen.main.bounds.width - (UIScreen.main.bounds.width / CGFloat(speedOptions.count - 1))
        self.speedSlider.layoutIfNeeded()
        self.speedSliderLabels.layoutIfNeeded()
    }
    
    func setupLiteAppMode(mode: CameraMode) {
        fpsView.isHidden = true
        timerStackView.isHidden = true
    }
    
    func changeModeHandler() {
        AppEventBus.onMainThread(self, name: "changeMode") { [weak self] _ in
            guard let `self` = self else {
                return
            }
            
            var cameraModeArray = self.cameraModeArray
            
            if isTimeSpeedApp {
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .slideshow})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .collage})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .fastSlowMotion})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .boomerang})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .custom})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .normal})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .promo})
                if Defaults.shared.appMode == .free {
                    cameraModeArray = cameraModeArray.filter({$0.recordingType != .handsfree})
                    cameraModeArray = cameraModeArray.filter({$0.recordingType != .capture})
                }
                Defaults.shared.cameraMode = .basicCamera
                self.recordingType = Defaults.shared.cameraMode
            } else if isBoomiCamApp {
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .slideshow})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .collage})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .fastSlowMotion})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .boomerang})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .custom})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .normal})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .capture})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .fastMotion})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .handsfree})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .promo})
                Defaults.shared.cameraMode = .basicCamera
                self.recordingType = Defaults.shared.cameraMode
            } else if isPic2ArtApp {
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .fastSlowMotion})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .boomerang})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .custom})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .normal})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .capture})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .fastMotion})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .handsfree})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .promo})
                if let index = cameraModeArray.firstIndex(where: { return $0.recordingType == .handsfree}) {
                    cameraModeArray.remove(at: index)
                    cameraModeArray.insert(CameraModes(name: R.string.localizable.video2Art(), recordingType: .handsfree), at: index)
                }
                Defaults.shared.cameraMode = .basicCamera
                self.recordingType = Defaults.shared.cameraMode
            } else if isLiteApp {
                cameraModeArray = cameraModeArray.filter({$0.recordingType == .promo})
                if Defaults.shared.appMode == .basic {
                    cameraModeArray += self.cameraModeArray.filter({$0.recordingType == .normal})
                } else {
                    Defaults.shared.cameraMode = .promo
                    self.setupLiteAppMode(mode: .promo)
                }
            } else if isSnapCamApp || isFastCamApp || isSpeedCamApp {
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .slideshow})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .fastMotion})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .promo})
                if Defaults.shared.appMode == .free {
                    cameraModeArray = cameraModeArray.filter({$0.recordingType != .capture})
                    cameraModeArray = cameraModeArray.filter({$0.recordingType != .normal})
                }
                if Defaults.shared.appMode != .advanced {
                    cameraModeArray = cameraModeArray.filter({$0.recordingType != .custom})
                    cameraModeArray = cameraModeArray.filter({$0.recordingType != .collage})
                }
                Defaults.shared.cameraMode = .normal
                self.recordingType = Defaults.shared.cameraMode
            } else {
                if Defaults.shared.appMode == .free {
                    Defaults.shared.cameraMode = .normal
                    self.recordingType = Defaults.shared.cameraMode
                    cameraModeArray = cameraModeArray.filter({$0.recordingType != .custom})
                    cameraModeArray = cameraModeArray.filter({$0.recordingType != .fastSlowMotion})
                }
            }
            self.selectedSegmentLengthChange()
            self.setCameraSettings()
            self.cameraSliderView.stringArray = cameraModeArray
            if !isFastCamApp && !isViralCamLiteApp && !isFastCamLiteApp && !isQuickCamLiteApp && !isSpeedCamLiteApp && !isSnapCamLiteApp && !isQuickApp {
                self.cameraSliderView.selectCell = Defaults.shared.cameraMode.rawValue
            }
            self.dynamicSetSlowFastVerticalBar()
        }
    }
    
    func selectedSegmentLengthChange() {
        if Defaults.shared.appMode == .free && (isSpeedCamApp || isFastCamApp || isSnapCamApp) {
            self.selectedSegmentLengthValue = SelectedTimer(value: "10", selectedRow: 1)
        } else {
            self.selectedSegmentLengthValue = SelectedTimer(value: "15", selectedRow: 2)
        }
        self.selectedSegmentLengthValue.saveWithKey(key: "selectedSegmentLengthValue")
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
        guard isCameraLoadOnRecording else {
            return
        }
        do {
            if let metadataObjectViews = metadataObjectViews {
                for view in metadataObjectViews {
                    view.removeFromSuperview()
                }
                self.metadataObjectViews = nil
            }
            try nextLevel.start()
            self.selectedFPS = Float(Defaults.shared.selectedFrameRates ?? "30") ?? 30
            if self.selectedFPS != 30 {
                nextLevel.updateDeviceFormat(withFrameRate: CMTimeScale(selectedFPS),
                                             dimensions: CMVideoDimensions(width: 1280, height: 720))
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
            isMute = isMicOn
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
            self.selectedSegmentLengthChange()
        }
        if let segmentLenghValue = Int(selectedSegmentLengthValue.value) {
            videoSegmentSeconds = CGFloat(segmentLenghValue)
            segmentLengthSelectedLabel.text = selectedSegmentLengthValue.value
        }
        
        pauseTimerSelectedLabel.text = selectedPauseTimerValue.value
        timerSelectedLabel.text = selectedTimerValue.value
        photoTimerSelectedLabel.text = selectedPhotoTimerValue.value
        
        recordingType = Defaults.shared.cameraMode
    }
    
    func stop() {
        if timer != nil && (timer?.isValid)! {
            timer?.invalidate()
        }
        timer = nil
    }
    
    func changeSpeedSliderValues() {
        if recordingType == .fastSlowMotion,
            !self.isMute {
            self.muteButtonClicked(Any.self)
            self.isShowMuteButton = false
        } else if recordingType == .fastSlowMotion,
            self.isMute {
            self.isShowMuteButton = false
        } else {
            self.isShowMuteButton = true
        }
    }

    func setupLayoutCameraSliderView() {
        self.timerValueView.isHidden = isLiteApp ? self.isUserTimerValueChange : !self.isUserTimerValueChange
        var cameraModeArray = self.cameraModeArray
        if isTimeSpeedApp {
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .slideshow})
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .collage})
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .fastSlowMotion})
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .boomerang})
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .custom})
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .normal})
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .promo})
            if Defaults.shared.appMode == .free {
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .handsfree})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .capture})
            }
        } else if isBoomiCamApp {
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .slideshow})
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .collage})
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .fastSlowMotion})
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .boomerang})
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .custom})
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .normal})
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .capture})
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .fastMotion})
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .handsfree})
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .promo})
        } else if isPic2ArtApp {
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .fastSlowMotion})
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .boomerang})
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .custom})
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .normal})
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .capture})
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .fastMotion})
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .handsfree})
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .promo})
            if let index = cameraModeArray.firstIndex(where: { return $0.recordingType == .handsfree}) {
                cameraModeArray.remove(at: index)
                cameraModeArray.insert(CameraModes(name: R.string.localizable.video2Art().uppercased(), recordingType: .handsfree), at: index)
            }
        } else if isLiteApp {
            cameraModeArray = cameraModeArray.filter({$0.recordingType == .promo})
            cameraModeArray += self.cameraModeArray.filter({$0.recordingType == .normal})
            cameraModeArray += self.cameraModeArray.filter({$0.recordingType == .capture})
            cameraModeArray += self.cameraModeArray.filter({$0.recordingType == .pic2Art})
        } else if isSnapCamApp || isFastCamApp || isSpeedCamApp {
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .slideshow})
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .fastMotion})
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .promo})
            if Defaults.shared.appMode == .free {
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .capture})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .normal})
            }
            if Defaults.shared.appMode != .advanced {
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .custom})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .collage})
            }
        } else {
            cameraModeArray = cameraModeArray.filter({$0.recordingType != .promo})
            if Defaults.shared.appMode == .free {
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .custom})
                cameraModeArray = cameraModeArray.filter({$0.recordingType != .fastSlowMotion})
            } else {
                if isSocialCamApp {
                    cameraModeArray = cameraModeArray.filter({$0.recordingType != .capture})
                    cameraModeArray = cameraModeArray.filter({$0.recordingType != .custom})
                }
            }
        }
        
        cameraSliderView.stringArray = cameraModeArray
        cameraSliderView.bottomImage = R.image.cameraModeSelect()
        cameraSliderView.cellTextColor = .white
        cameraSliderView.isScrollEnable = { [weak self] (index, currentMode) in
            guard let `self` = self else { return }
            let currentMode = currentMode.recordingType
            if currentMode == .custom && self.takenVideoUrls.count > 0 {
                let alert = UIAlertController(title: Constant.Application.displayName, message: R.string.localizable.switchingCameraModeWillDeleteTheRecordedVideosAreYouSure(), preferredStyle: .actionSheet)
                let yesAction = UIAlertAction(title: R.string.localizable.oK(), style: .default, handler: handleRemoveVides)
                let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel, handler: nil)
                alert.addAction(yesAction)
                alert.addAction(cancelAction)
                alert.popoverPresentationController?.sourceView = self.view
                alert.popoverPresentationController?.sourceRect = CGRect.init(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
            
        func handleRemoveVides(alertAction: UIAlertAction!) {
            self.removeData()
        }
        
        cameraSliderView.currentCell = { [weak self] (index, currentMode) in
            guard let `self` = self else { return }
            Defaults.shared.cameraMode = currentMode.recordingType
            self.isRecording = false
            
            self.totalDurationOfOneSegment = 0.0
            self.circularProgress.animate(toAngle: 0, duration: 0, completion: nil)
            self.circularProgress.progressInsideFillColor = .white
            self.showControls()
            self.stop()
            
            self.timer = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(self.animate), userInfo: nil, repeats: false)
            
            self.timerValueView.isHidden = isLiteApp ? self.isUserTimerValueChange : !self.isUserTimerValueChange
            self.segmentLengthSelectedLabel.text = self.selectedSegmentLengthValue.value
            self.recordingType = Defaults.shared.cameraMode
            self.circularProgress.centerImage = UIImage()
            self.dynamicSetSlowFastVerticalBar()
            self.changeSpeedSliderValues()
            self.refreshCircularProgressBar()
            switch Defaults.shared.cameraMode {
            case .boomerang:
                self.circularProgress.centerImage = R.image.icoBoomrang()
                self.timerValueView.isHidden = true
                if self.timerValue > 0 {
                    self.timerValue = 0
                    self.resetCountDown()
                }
                if self.photoTimerValue > 0 {
                    self.photoTimerValue = 0
                    self.resetPhotoCountDown()
                }
            case .slideshow:
                self.circularProgress.centerImage = R.image.icoSildeshowMode()
                self.timerValueView.isHidden = true
            case .collage:
                self.circularProgress.centerImage = R.image.icoCollageMode()
                self.timerValueView.isHidden = true
            case .handsfree:
                self.circularProgress.centerImage = isPic2ArtApp ? R.image.icoHandsFreeVideo() : R.image.icoHandsFree()
                if self.recordingType == .custom || self.recordingType == .boomerang || self.recordingType == .capture {
                    self.selectedSegmentLengthChange()
                    self.videoSegmentSeconds = CGFloat((Int(self.selectedSegmentLengthValue.value) ?? 15))
                }
                if self.isRecording {
                    self.isRecording = true
                }
            case .custom:
                self.circularProgress.centerImage = R.image.icoCustomMode()
                self.timerValueView.isHidden = true
            case .capture:
                if isQuickApp && Defaults.shared.appMode == .free {
                    self.showAlertForUpgradeSubscription()
                }
                self.circularProgress.centerImage = R.image.capture_mode()
                self.timerValueView.isHidden = true
            case .promo:
                self.circularProgress.centerImage = UIImage()
                if self.timerValue > 0 {
                    self.timerValue = 0
                    self.resetCountDown()
                }
                if self.photoTimerValue > 0 {
                    self.photoTimerValue = 0
                    self.resetPhotoCountDown()
                }
            case .pic2Art:
                if isQuickApp && Defaults.shared.appMode == .free {
                    self.showAlertForUpgradeSubscription()
                } else {
                    if let isPic2ArtShowed = Defaults.shared.isPic2ArtShowed {
                        if isPic2ArtShowed {
                            self.cameraModeCell = 3
                            Defaults.shared.isPic2ArtShowed = false
                            if let tooltipViewController = R.storyboard.loginViewController.tooltipViewController() {
                                tooltipViewController.pushFromSettingScreen = true
                                tooltipViewController.isPic2ArtGif = true
                                self.navigationController?.pushViewController(tooltipViewController, animated: true)
                            }
                        }
                    }
                }
            case .normal:
                if isQuickApp && Defaults.shared.appMode == .free {
                    self.showAlertForUpgradeSubscription()
                }
            default:
                break
            }
        }
        
        if !isFastCamApp && !isViralCamLiteApp && !isFastCamLiteApp && !isQuickCamLiteApp && !isSpeedCamLiteApp && !isSnapCamLiteApp && !isQuickApp {
            cameraSliderView.selectCell = Defaults.shared.cameraMode.rawValue
        }
        if (isSnapCamLiteApp || isQuickApp) && Defaults.shared.appMode == .basic {
            cameraSliderView.selectCell = self.cameraModeCell
            self.cameraModeCell = 1
        } else if isQuickApp && Defaults.shared.appMode == .free {
            cameraSliderView.selectCell = 0
        }
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.animateTransitionIfNeeded(to: self.currentState.opposite, duration: 0)
        }, completion: { (_ finished: Bool) -> Void in
            if finished {
                self.currentState = .open
            }
        })
    }
    
    func volumeButtonHandler() {
        self.volumeHandler = JPSVolumeButtonHandler(up: {
                            }, downBlock: {
                            })
    }
    
    func addVolumeButtonHandler() {
        NotificationCenter.default.addObserver(self, selector: #selector(volumeChanged(notification:)),
                                               name: .AVSystemVolumeDidChange,
                                               object: nil)
        self.volumeHandler?.start(true)
    }
    
    func removeVolumeButtonHandler() {
        NotificationCenter.default.removeObserver(self,
                                                  name: .AVSystemVolumeDidChange,
                                                  object: nil)
        self.volumeHandler?.stop()
    }
    
    @objc func volumeChanged(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let volumeChangeType = userInfo["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String {
                if volumeChangeType == "ExplicitVolumeChange" {
                    if let newVolume = userInfo["AVSystemController_AudioVolumeNotificationParameter"] as? Double { print(newVolume)
                    }
                    self.volumeButtonPhotoCapture()
                }
            }
        }
    }
    
    func volumeButtonPhotoCapture() {
        if !isRecording && !self.isForceCaptureImageWithVolumeKey {
            self.isForceCaptureImageWithVolumeKey = true
            self.capturePhoto()
        }
    }
    
    func resetPositionRecordButton() {
        DispatchQueue.main.async {
            self.circularProgress.center = self.recordButtonCenterPoint
        }
    }
    
    @objc func animate() {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.animateTransitionIfNeeded(to: self.currentState.opposite, duration: 1)
        }, completion: { (_ finished: Bool) -> Void in
            if finished {
                self.currentState = .open
            }
        })
    }
    
    func setupLayout() {
        stopMotionCollectionView.register(R.nib.imageCollectionViewCell)
    }
    
    func setupCountDownView() {
        self.view.addSubview(sfCountdownView)
    }
    
    func setupImageLoadFromGallary() {
        PhotoLibraryPermission().request { (isAuthorized) in
            if isAuthorized {
                ImagesLibrary.shared.getLatestPhotos(completion: { [weak self] (phAsset) in
                    guard let `self` = self else { return }
                    if let asset = phAsset {
                        self.setLastImageFromGallery(asset: asset)
                    }
                })
                
                ImagesLibrary.shared.lastImageDidUpdateInGalleryBlock = { [weak self] (phAsset) in
                    guard let `self` = self else { return }
                    if let asset = phAsset {
                        self.setLastImageFromGallery(asset: asset)
                    }
                }
            }
        }
    }
    
    func setLastImageFromGallery(asset: PHAsset) {
        ImagesLibrary.shared.imageAsset(asset: asset, completionBlock: { [weak self] (image, _) in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.lastCaptureImageView.image = image
                self.lastCaptureImageView.borderColorV = .white
                self.lastCaptureImageView.borderWidthV = 1.5
            }
        })
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
    
    func checkIsFromSignup() {
        if let isFromSignup = Defaults.shared.isFromSignup {
            if isFromSignup {
                self.signupTooltipView.isHidden = false
                Defaults.shared.isFromSignup = false
                enableAccessView.isHidden = true
                blurView.alpha = 0.9
            }
        }
    }
    
    public func removeData() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.settingsButton.isSelected = false
            self.totalDurationOfOneSegment = 0.0
            self.circularProgress.animate(toAngle: 0, duration: 0, completion: nil)
            self.circularProgress.progressInsideFillColor = .white
            self.takenSlideShowImages.removeAll()
            self.takenImages.removeAll()
            self.takenVideoUrls.removeAll()
            self.stopMotionCollectionView.reloadData()
            self.resetPositionRecordButton()
        }
    }
    
    @objc func speedSliderValueChanged(_ sender: Any) {
        videoSpeedType = speedSlider.speedType
        speedIndicatorViewColorChange()
        guard nextLevel.isRecording else {
            return
        }
        onStartRecordSetSpeed()
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
            flashButton.setImage(R.image.flashAuto(), for: UIControl.State.normal)
            flashLabel.text = R.string.localizable.autoFlash()
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
        nextLevel.videoConfiguration.preset = AVCaptureSession.Preset.hd1280x720
        nextLevel.videoConfiguration.bitRate = 5500000
        nextLevel.videoConfiguration.profileLevel = AVVideoProfileLevelH264HighAutoLevel
        nextLevel.audioConfiguration.bitRate = 96000
        nextLevel.deviceDelegate = self
        nextLevel.videoDelegate = self
        nextLevel.metadataObjectsDelegate = self
        enableFaceDetectionIfNeeded()
        setupImageLoadFromGallary()
    }
    
    func enableFaceDetectionIfNeeded() {
        var metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        if Defaults.shared.enableFaceDetection {
            metadataObjectTypes.append(AVMetadataObject.ObjectType.face)
        }
        nextLevel.metadataObjectTypes = metadataObjectTypes
    }
    
    func swapeControlsIfNeeded() {
        if Defaults.shared.swapeContols {
            galleryStackView.addArrangedSubview(swipeCameraStackView)
            galleryStackView.addArrangedSubview(muteStackView)
            sceneFilterView.addArrangedSubview(faceFiltersView)
            sceneFilterView.addArrangedSubview(outtakesView)
        } else {
            sceneFilterView.addArrangedSubview(muteStackView)
            sceneFilterView.addArrangedSubview(swipeCameraStackView)
            galleryStackView.addArrangedSubview(outtakesView)
            galleryStackView.addArrangedSubview(faceFiltersView)
        }
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
    
    @objc func handlePinchGestureRecognizer(_ pinchGestureRecognizer: UIPinchGestureRecognizer) {
        if !isSnapCamLiteApp || !isQuickApp {
            func minMaxZoom(_ factor: Float) -> Float {
                return min(max(factor, 1.0), 10.0)
            }
            let newScaleFactor = minMaxZoom(Float(pinchGestureRecognizer.scale) * Float(lastZoomFactor))
            switch pinchGestureRecognizer.state {
            case .began: break
            case .changed: NextLevel.shared.videoZoomFactor = newScaleFactor
            case .ended:
                lastZoomFactor = CGFloat(minMaxZoom(newScaleFactor))
                NextLevel.shared.videoZoomFactor = newScaleFactor
            default: break
            }
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
            if isRecording {
                self.isStopConnVideo = true
                self.stopRecording()
                DispatchQueue.main.async {
                    self.isRecording = false
                }
                self.resetPositionRecordButton()
            }
        }
    }
    
    @objc func enterForeground(_ notifi: Notification) {
        if isViewAppear {
            syncUserModel { _ in
                
            }
            startCapture()
            addTikTokShareViewIfNeeded()
            if let pasteboard = UIPasteboard(name: UIPasteboard.Name(rawValue: Constant.Application.pasteboardName), create: true),
               let data = pasteboard.data(forPasteboardType: Constant.Application.pasteboardType),
                let image = UIImage(data: data) {
                UIPasteboard.remove(withName: UIPasteboard.Name(rawValue: Constant.Application.pasteboardName))
                openStoryEditor(images: [image])
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
                    self.showhideView.alpha = 0
                    self.timerStackView.alpha = 0
                    self.nextButtonView.alpha = 0
                    self.settingsView.alpha = 0
                    self.outtakesView.alpha = 0
                    self.fpsView.alpha = 0
                    self.timerValueView.alpha = 0
                    self.faceFiltersView.alpha = 0
                    self.cameraSliderView.alpha = 0
                    self.switchAppButton.alpha = 0
                    self.discardSegmentsStackView.alpha = 0
                    self.confirmRecordedSegmentStackView.alpha = 0
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
                    self.showhideView.alpha = 1
                    self.timerStackView.alpha = 1
                    self.cameraSliderView.alpha = 1
                    self.outtakesView.alpha = 1
                    self.settingsView.alpha = 1
                    self.fpsView.alpha = 1
                    self.timerValueView.alpha = 1
                    self.faceFiltersView.alpha = 1
                    self.collectionViewStackVIew.alpha = 1
                    self.switchAppButton.alpha = 1
                    self.discardSegmentsStackView.alpha = 1
                    self.confirmRecordedSegmentStackView.alpha = 1
                })
            }
        } else {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.1, animations: {
                    self.showhideView.alpha = 1
                })
            }
        }
    }
    
    func startProgress() {
        if isQuickCamApp && Defaults.shared.appMode == .professional && self.recordingType == .capture {
            self.startPulse(position: CGPoint(x: circularProgress.bounds.width/2, y: circularProgress.bounds.height/2))
        }
        self.progressTimer = Timer.scheduledTimer(timeInterval: 0.0625, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    @objc func updateProgress() {
        print(currentSpeed)
        let progressUP = CGFloat(0.0625/progressMaxSeconds) * currentSpeed
        print(progressMaxSeconds)
        print((progressUP / progressMaxSeconds))
        progress += progressUP // (progressUP / progressMaxSeconds)
        print("progress: \(progress)")
        if isQuickCamApp && Defaults.shared.appMode == .professional && self.recordingType == .capture {
            if progress >= 1 {
                if self.getFreeSpace() > 200 {
                    let freeSpace = self.getFreeSpace()
                    self.startRecording()
                    print(freeSpace)
                } else {
                    self.stopRecording()
                }
            }
        } else {
            circularProgress.progress = Double(progress)
            if progress >= 1 {
                if isTimeSpeedApp || isBoomiCamApp || isPic2ArtApp {
                    self.isStopConnVideo = true
                } else {
                    self.isStopConnVideo = self.recordingType != .handsfree ? true : false
                }
                self.stopRecording()
            }
        }
    }
    
    func resetProgressTimer() {
        if recordingType != .normal {
            progress = 0
        }
        self.progressTimer?.invalidate()
    }
    
    func startRecording() {
        guard !nextLevel.isRecording else {
            return
        }
        self.view.bringSubviewToFront(slowFastVerticalBar.superview ?? UIView())
        if recordingType != .basicCamera && Defaults.shared.enableGuildlines {
            slowFastVerticalBar.isHidden = isLiteApp ? false : (Defaults.shared.appMode == .free)
        } else {
            slowFastVerticalBar.isHidden = true
        }
        
        nextLevel.torchMode = NextLevelTorchMode(rawValue: flashMode.rawValue) ?? .auto
        self.isVideoRecording = true
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.circularProgress.trackThickness = 0.75*0.7
            self.circularProgress.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
        }, completion: { completed in
            DispatchQueue.main.async {
                var totalSeconds = self.videoSegmentSeconds
                if isQuickCamApp && Defaults.shared.appMode == .professional && self.recordingType == .capture {
                    self.progressMaxSeconds = 60
                    self.startProgress()
                    NextLevel.shared.record()
                } else {
                    if self.recordingType == .custom {
                        totalSeconds = 240
                    } else if self.recordingType == .boomerang {
                        totalSeconds = 2
                    } else if self.recordingType == .capture {
                        self.settingsButton.isUserInteractionEnabled = false
                        self.switchAppButton.isUserInteractionEnabled = false
                        if (isSpeedCamApp || isFastCamApp || isSnapCamApp) {
                            totalSeconds = Defaults.shared.appMode == .basic ? 60 : 120
                        } else {
                            totalSeconds = 3600
                        }
                    } else if isPic2ArtApp {
                        totalSeconds = 5
                    } else if isLiteApp {
                        self.discardSegmentButton.setImage(R.image.trimBack()?.alpha(1), for: .normal)
                        totalSeconds = self.recordingType == .promo ? 15 : 30
                    }
                    self.progressMaxSeconds = totalSeconds
                    self.circularProgress.progressInsideFillColor = .red
                    self.startProgress()
                    NextLevel.shared.record()
                }
            }
/* TODO: If new logic will not work with all scenario then we need this code.
            self.circularProgress.animate(toAngle: 360, duration: Double(totalSeconds) - (NextLevel.shared.session?.totalDuration.seconds ?? 0)) { completed in
                if completed {
                    print("animation stopped, completed")
                    if self.isTimeSpeedApp || self.isBoomiCamApp {
                        self.isStopConnVideo = true
                    } else {
                        self.isStopConnVideo = self.recordingType != .handsfree ? true : false
                    }
                    self.stopRecording()
                } else {
                    print("animation stopped, was interrupted")
                }
            }
 */
        })
        speedSlider.isUserInteractionEnabled = (recordingType == .handsfree || recordingType == .timer || recordingType == .capture)
        hideRecordingControls()
    }
    
    func stopRecording() {
        nextLevel.torchMode = .off
        self.isVideoRecording = false
        if isLiteApp, recordingType == .normal {
            self.segmentsProgress.append(progress)
            self.circularProgress.drawArc(startAngle: Double(progress))
            self.discardSegmentsStackView.isHidden = false
            self.confirmRecordedSegmentStackView.isHidden = false
            self.stopMotionCollectionView.isHidden = true
        }
        if recordingType == .capture {
            self.settingsButton.isUserInteractionEnabled = true
            self.switchAppButton.isUserInteractionEnabled = true
            self.view.bringSubviewToFront(self.blurView)
            self.view.bringSubviewToFront(self.switchingAppView)
        }
        resetProgressTimer()
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if isQuickCamApp && Defaults.shared.appMode == .professional && self.recordingType == .capture {
                self.stopPulse()
            }
            if self.recordingType == .capture {
                self.circularProgress.animate(toAngle: 0, duration: 0, completion: nil)
            }
            self.circularProgress.pauseAnimation()
            self.circularProgress.trackThickness = 0.75
            self.circularProgress.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.circularProgress.progressInsideFillColor = .white
        }
        
        self.nextLevel.pause { [weak self] in
            guard let `self` = self else { return }
            if let session = self.nextLevel.session {
                if let url = session.lastClipUrl {
                    self.afterVideoCreateSave(url: url, session: session)
                } else if session.currentClipHasStarted {
                    session.endClip(completionHandler: { [weak self] (clip, error) in
                        guard let `self` = self else { return }
                        if error == nil, let url = clip?.url {
                            self.afterVideoCreateSave(url: url, session: session)
                        }
                    })
                }
                session.removeAllClips(removeFiles: false)
            }
            self.nextLevel.audioConfiguration.isMute = self.isMute
        }
        
        if self.recordingType != .custom {
            showControls()
        }
    }
    
    // return free space in MB
    func getFreeSpace() -> Int64 {
        var totalFreeSpaceInBytes: Int64 = 0 //total free space in bytes
        do {
            let spaceFree: Int64 = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())[FileAttributeKey.systemFreeSize] as! Int64
            totalFreeSpaceInBytes = spaceFree
        } catch let error { // Catch error that may be thrown by FileManager
            print("Error is ", error)
        }
        let totalBytes: Int64 = 1 * CLongLong(totalFreeSpaceInBytes)
        let totalMb: Int64 = totalBytes / (1024 * 1024)
        return totalMb
    }
    
    func startPulse(position: CGPoint) {
        pulse = Pulsing(numberOfPulses: Float.infinity, radius: 50, position: position)
        pulse.animationDuration = 0.9
        self.circularProgress.layer.addSublayer(pulse)
    }
    
    func stopPulse() {
        pulse.removeFromSuperlayer()
        self.circularProgress.layer.removeAllAnimations()
    }
    
    func afterVideoCreateSave(url: URL, session: NextLevelSession) {
        if recordingType == .custom {
            takenVideoUrls.append(SegmentVideos(urlStr: url, thumbimage: session.clips.last?.thumbnailImage, latitued: nil, longitued: nil, placeAddress: nil, numberOfSegement: "\(takenVideoUrls.count + 1)", videoduration: nil, combineOneVideo: true))
            settingsButton.isSelected = true
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.setupForPreviewScreen()
            }
        } else {
            guard let cmtime = session.clips.last?.duration else {
                return
            }
            let floatTime = CGFloat(CMTimeGetSeconds(cmtime))
            self.videoDidCompletedSession(url: url, thumbimage: session.clips.last?.thumbnailImage, duration: floatTime)
        }
    }
    
    func videoDidCompletedSession(url: URL, thumbimage: UIImage?, duration: CGFloat) {
        if self.recordingType == .boomerang {
            let loadingView = LoadingView.instanceFromNib()
            loadingView.shouldCancelShow = true
            loadingView.shouldDescriptionTextShow = true
            loadingView.show(on: self.view)
            
            let factory = VideoFactory(type: .boom, video: VideoOrigin(mediaType: nil, mediaUrl: url, referenceURL: nil))
            factory.assetTOcvimgbuffer({ [weak self] (urls) in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    loadingView.hide()
                }
                self.newVideoCreate(url: url, newUrl: urls)
                DispatchQueue.main.async {
                    self.takenVideoUrls.append(SegmentVideos(urlStr: url, thumbimage: thumbimage, numberOfSegement: "\(self.takenVideoUrls.count + 1)"))
                    self.setupForPreviewScreen(duration: duration)
                }
            }, { (progress) in
                DispatchQueue.main.async {
                    loadingView.progressView.setProgress(to: Double(Float(Float(progress.completedUnitCount) / Float(progress.totalUnitCount))), withAnimation: true)
                }
            }, failure: { (_) in
                DispatchQueue.main.async {
                    loadingView.hide()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            })
        } else {
            DispatchQueue.main.async {
                self.takenVideoUrls.append(SegmentVideos(urlStr: url, thumbimage: thumbimage, numberOfSegement: "\(self.takenVideoUrls.count + 1)"))
                self.setupForPreviewScreen(duration: duration)
            }
        }
    }
    
    func newVideoCreate(url: URL, newUrl urls: URL) {
        DispatchQueue.main.async {
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        do {
            let fileManager = FileManager.default
            
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(atPath: url.path)
                try fileManager.moveItem(at: urls, to: url)
            }
        } catch let error as NSError {
            print("An error took place: \(error)")
        }
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
    
    func setupForPreviewScreen(duration: CGFloat = 0.0) {
        self.stopMotionCollectionView.reloadData()
        let layout = self.stopMotionCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let pageSide = (layout?.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        self.stopMotionCollectionView?.contentOffset.x = (self.stopMotionCollectionView?.contentSize.width)! + pageSide
        
        if self.recordingType == .custom {
            self.showControls()
            totalDurationOfOneSegment += self.getDurationOf(videoPath: (self.takenVideoUrls.last?.url)!)
            self.isRecording = false
            if (isSpeedCamApp || isFastCamApp || isSnapCamApp) && (totalDurationOfOneSegment >= 240 || (takenVideoUrls.count >= 5)) {
                self.openStoryEditor(segementedVideos: takenVideoUrls)
            } else if totalDurationOfOneSegment >= 240 || (takenVideoUrls.count >= 10) {
                self.openStoryEditor(segementedVideos: takenVideoUrls)
            }
        } else if self.recordingType == .boomerang {
            self.showControls()
            self.isRecording = false
            self.videoSpeedType = .normal
            self.speedSliderLabels.value = 3
            self.speedSlider.value = 3
            self.isSpeedChanged = false
            if (self.recordingType == .timer) || (self.recordingType == .photoTimer) {
                self.recordingType = .normal
            }
            self.openStoryEditor(segementedVideos: takenVideoUrls)
        } else if self.recordingType == .capture {
            self.showControls()
            self.isRecording = false
            if let url = self.takenVideoUrls.last?.url {
                SCAlbum.shared.saveMovieToLibrary(movieURL: url) { (isSuccess) in
                    if isSuccess {
                        DispatchQueue.main.async {
                            self.view.makeToast(R.string.localizable.videoSaved(), duration: ToastManager.shared.duration, position: .top)
                        }
                    } else {
                        self.view.makeToast(R.string.localizable.pleaseGivePhotosAccessFromSettingsToSaveShareImageOrVideo(), duration: ToastManager.shared.duration, position: .top, style: ToastStyle())
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.speedSlider.isUserInteractionEnabled = true
                self.slowFastVerticalBar.isHidden = true
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
               
            var isVideoStop: Bool = false
            switch Defaults.shared.appMode {
            case .free:
                if currentVideoSeconds*CGFloat(self.takenVideoUrls.count) >= 30 || (takenVideoUrls.count >= 5) {
                    isVideoStop = true
                }
            case .basic:
                if currentVideoSeconds*CGFloat(self.takenVideoUrls.count) >= 60 || (takenVideoUrls.count >= 5) {
                    isVideoStop = true
                }
            case .advanced:
                if currentVideoSeconds*CGFloat(self.takenVideoUrls.count) >= 180 || (takenVideoUrls.count >= 10) {
                    isVideoStop = true
                }
            default:
                if currentVideoSeconds*CGFloat(self.takenVideoUrls.count) >= 240 || (takenVideoUrls.count >= 10) {
                    isVideoStop = true
                }
            }
            
            if !self.isStopConnVideo && !isVideoStop {
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
                switch Defaults.shared.appMode {
                case .free, .basic:
                    speedSliderLabels.value = 2
                    speedSlider.value = 2
                case .advanced:
                    speedSliderLabels.value = 3
                    speedSlider.value = 3
                default:
                    speedSliderLabels.value = 4
                    speedSlider.value = 4
                }
                self.isSpeedChanged = false
                if (self.recordingType == .timer) || (self.recordingType == .photoTimer) {
                    self.recordingType = .normal
                }
                totalVideoDuration.append(duration)
                let totalDurationSum = totalVideoDuration.reduce(0, +)
                if recordingType != .normal {
                    if Defaults.shared.isVideoSavedAfterRecording == true {
                        if let url = self.takenVideoUrls.last?.url {
                            SCAlbum.shared.saveMovieToLibrary(movieURL: url)
                        }
                    }
                    self.openStoryEditor(segementedVideos: takenVideoUrls)
                } else if isLiteApp, recordingType == .normal, totalDurationSum >= 30 {
                    self.openStoryEditor(segementedVideos: takenVideoUrls)
                }
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
    
    func openStoryEditor(segementedVideos: [SegmentVideos], isSlideShow: Bool = false, photosSelection: Bool = false) {
        if isLiteApp {
            Defaults.shared.cameraMode = self.recordingType
        }
        if isPic2ArtApp {
            if self.recordingType == .slideshow {
                guard let storyEditorViewController = R.storyboard.storyEditor.storyEditorViewController() else {
                    fatalError("PhotoEditorViewController Not Found")
                }
                var medias: [StoryEditorMedia] = []
                for segmentedVideo in segementedVideos {
                    if segmentedVideo.url == URL(string: Constant.Application.imageIdentifier) {
                        medias.append(StoryEditorMedia(type: .image(segmentedVideo.image!)))
                    } else {
                        medias.append(StoryEditorMedia(type: .video(segmentedVideo.image!, AVAsset(url: segmentedVideo.url!))))
                    }
                }
                let tiktokShareViews = self.baseView.subviews.filter({ return $0 is TikTokShareView })
                if tiktokShareViews.count > 0 {
                    storyEditorViewController.referType = .tiktokShare
                }
                storyEditorViewController.isBoomerang = photosSelection ? false : (self.recordingType == .boomerang)
                storyEditorViewController.medias = medias
                storyEditorViewController.isSlideShow = isSlideShow
                self.navigationController?.pushViewController(storyEditorViewController, animated: false)
                self.removeData()
                return
            }
            guard let styleTransferVC = R.storyboard.photoEditor.styleTransferVC() else {
                return
            }
           
            for segmentedVideo in segementedVideos {
                if segmentedVideo.url == URL(string: Constant.Application.imageIdentifier) {
                    styleTransferVC.type = .image(image: segmentedVideo.image!)
                    SCAlbum.shared.save(image: segmentedVideo.image!)
                } else {
                    styleTransferVC.type = .video(videoSegments: segementedVideos, index: 0)
                }
            }
            styleTransferVC.isPic2ArtApp = true
            styleTransferVC.isSingleImage = isSlideShow
            styleTransferVC.doneHandler = { segments, tag in
                guard let segementedVideos = segments as? [SegmentVideos], let segementedVideo = segementedVideos.first, let storyEditorViewController = R.storyboard.storyEditor.storyEditorViewController() else {
                    fatalError("PhotoEditorViewController Not Found")
                }
                guard let url = segementedVideo.url else {
                    return
                }
                let medias: [StoryEditorMedia] = [StoryEditorMedia(type: .video(AVAsset(url: url).thumbnailImage() ?? UIImage(), AVAsset(url: url)))]
                
                let tiktokShareViews = self.baseView.subviews.filter({ return $0 is TikTokShareView })
                if tiktokShareViews.count > 0 {
                    storyEditorViewController.referType = .tiktokShare
                }
                storyEditorViewController.isBoomerang = (self.recordingType == .boomerang)
                storyEditorViewController.medias = medias
                storyEditorViewController.isSlideShow = isSlideShow
                self.navigationController?.pushViewController(storyEditorViewController, animated: false)
                self.removeData()
            }
            self.navigationController?.pushViewController(styleTransferVC, animated: true)
            self.removeData()
        } else if isTimeSpeedApp {
            guard let segementedVideo = segementedVideos.first else {
                return
            }
            guard let assetUrl = segementedVideo.url else {
                return
            }
            let currentAsset = AVAsset(url: assetUrl)
            
            guard currentAsset.duration.seconds > 2.0 else {
                self.showAlert(alertMessage: R.string.localizable.minimumTwoSecondsVideoRequiredToChangeSpeed())
                self.removeData()
                return
            }
            guard let histroGramVC = R.storyboard.photoEditor.histroGramVC() else {
                return
            }
            histroGramVC.currentAsset = currentAsset
            histroGramVC.completionHandler = { [weak self] url in
                guard let `self` = self else {
                    return
                }
                guard let storyEditorViewController = R.storyboard.storyEditor.storyEditorViewController() else {
                    fatalError("PhotoEditorViewController Not Found")
                }
                let medias: [StoryEditorMedia] = [StoryEditorMedia(type: .video(AVAsset(url: url).thumbnailImage() ?? UIImage(), AVAsset(url: url)))]
                
                let tiktokShareViews = self.baseView.subviews.filter({ return $0 is TikTokShareView })
                if tiktokShareViews.count > 0 {
                    storyEditorViewController.referType = .tiktokShare
                }
                storyEditorViewController.isBoomerang = photosSelection ? false : (self.recordingType == .boomerang)
                storyEditorViewController.medias = medias
                storyEditorViewController.isSlideShow = isSlideShow
                self.navigationController?.pushViewController(storyEditorViewController, animated: false)
                self.removeData()
            }
            self.navigationController?.pushViewController(histroGramVC, animated: false)
            self.removeData()
        } else if isBoomiCamApp {
            guard let segementedVideo = segementedVideos.first else {
                return
            }
            guard let assetUrl = segementedVideo.url else {
                return
            }
            let avAsset = AVAsset(url: assetUrl)

            guard let specificBoomerangViewController = R.storyboard.storyEditor.specificBoomerangViewController() else {
                return
            }
            
            guard avAsset.duration.seconds > 3.0 else {
                self.showAlert(alertMessage: R.string.localizable.minimumThreeSecondsVideoRequiredToSpecificBoomerang())
                self.removeData()
                return
            }
            specificBoomerangViewController.currentAsset = avAsset
            specificBoomerangViewController.delegate = self
           
            self.navigationController?.pushViewController(specificBoomerangViewController, animated: true)
            self.removeData()
        } else {
            let asset = self.getRecordSession(videoModel: segementedVideos)
            guard let storyEditorViewController = R.storyboard.storyEditor.storyEditorViewController() else {
                fatalError("PhotoEditorViewController Not Found")
            }
            var medias: [StoryEditorMedia] = []
            if isLiteApp, recordingType == .normal {
                progress = 0
                medias.append(StoryEditorMedia(type: .video(segementedVideos.first!.image!, asset)))
            } else {
                for segmentedVideo in segementedVideos {
                    if segmentedVideo.url == URL(string: Constant.Application.imageIdentifier) {
                        medias.append(StoryEditorMedia(type: .image(segmentedVideo.image!)))
                    } else {
                        medias.append(StoryEditorMedia(type: .video(segmentedVideo.image!, AVAsset(url: segmentedVideo.url!))))
                    }
                }
            }
            let tiktokShareViews = self.baseView.subviews.filter({ return $0 is TikTokShareView })
            if tiktokShareViews.count > 0 {
                storyEditorViewController.referType = .tiktokShare
            }
            storyEditorViewController.isBoomerang = photosSelection ? false : (self.recordingType == .boomerang)
            storyEditorViewController.medias = medias
            storyEditorViewController.isSlideShow = isSlideShow
            storyEditorViewController.isFromGallery = photosSelection
            self.navigationController?.pushViewController(storyEditorViewController, animated: false)
            self.removeData()
        }
    }
    
    func openStyleTransferVC(images: [UIImage], isSlideShow: Bool = false) {
        guard images.count > 0 else {
            return
        }
        
        guard let styleTransferVC = R.storyboard.photoEditor.styleTransferVC() else {
            return
        }
        var medias: [StoryEditorMedia] = []
        for image in images {
            medias.append(StoryEditorMedia(type: .image(image)))
            SCAlbum.shared.save(image: image)
        }
        switch medias[0].type {
        case let .image(image):
            styleTransferVC.type = .image(image: image)
        case .video:
            break
        }
        styleTransferVC.cameraMode = self.recordingType
        styleTransferVC.isPic2ArtApp = true
        styleTransferVC.isSingleImage = isSlideShow
        self.navigationController?.pushViewController(styleTransferVC, animated: true)
    }
    
    func openStoryEditor(images: [UIImage], isSlideShow: Bool = false) {
        guard images.count > 0 else {
            return
        }
        if isPic2ArtApp {
            guard let styleTransferVC = R.storyboard.photoEditor.styleTransferVC() else {
                return
            }
            var medias: [StoryEditorMedia] = []
            for image in images {
                medias.append(StoryEditorMedia(type: .image(image)))
                SCAlbum.shared.save(image: image)
            }
            switch medias[0].type {
            case let .image(image):
                styleTransferVC.type = .image(image: image)
            case .video:
                break
            }
            styleTransferVC.isPic2ArtApp = true
            styleTransferVC.isSingleImage = isSlideShow
            self.navigationController?.pushViewController(styleTransferVC, animated: true)
        } else {
            guard let storyEditorViewController = R.storyboard.storyEditor.storyEditorViewController() else {
                       fatalError("PhotoEditorViewController Not Found")
                   }
                   var medias: [StoryEditorMedia] = []
                   for image in images {
                       medias.append(StoryEditorMedia(type: .image(image)))
                   }
                   let tiktokShareViews = self.baseView.subviews.filter({ return $0 is TikTokShareView })
                   if tiktokShareViews.count > 0 {
                       storyEditorViewController.referType = .tiktokShare
                   }
                   storyEditorViewController.isBoomerang = (self.recordingType == .boomerang)
                   storyEditorViewController.medias = medias
                   self.navigationController?.pushViewController(storyEditorViewController, animated: false)
                   self.removeData()
        }
    }
    
    func storyEditor(images: [UIImage], isSlideShow: Bool = false) -> StoryEditorViewController {
        guard let storyEditorViewController = R.storyboard.storyEditor.storyEditorViewController() else {
            fatalError("PhotoEditorViewController Not Found")
        }
        var medias: [StoryEditorMedia] = []
        for image in images {
            medias.append(StoryEditorMedia(type: .image(image)))
        }
        storyEditorViewController.isBoomerang = false
        storyEditorViewController.medias = medias
        storyEditorViewController.isSlideShow = isSlideShow
        return storyEditorViewController
    }
    
    func showAlertOnDiscardVideoSegment() {
        let alert = UIAlertController(title: R.string.localizable.discardClipTitle(), message: R.string.localizable.discardClipMessage(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.discard(), style: .destructive, handler: { (_) in
            self.takenVideoUrls.removeLast()
            self.totalVideoDuration.removeLast()
            self.segmentsProgress.removeLast()
            if let lastSegmentsprogress = self.segmentsProgress.last {
                self.progress = lastSegmentsprogress
            } else {
                self.refreshCircularProgressBar()
                self.view.bringSubviewToFront(self.blurView)
                self.view.bringSubviewToFront(self.switchingAppView)
            }
            self.circularProgress.deleteLayer()
            self.updateProgress()
            if self.takenVideoUrls.isEmpty {
                self.discardSegmentButton.setImage(R.image.trimBack()?.alpha(0.5), for: .normal)
            }
        }))
        alert.addAction(UIAlertAction(title: R.string.localizable.keep(), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getRecordSession(videoModel: [SegmentVideos]) -> AVAsset {
        let recodeSession = SCRecordSession.init()
        for segementModel in videoModel {
            let segment = SCRecordSessionSegment(url: segementModel.url!, info: nil)
            recodeSession.addSegment(segment)
        }
        return recodeSession.assetRepresentingSegments()
    }
    
    func refreshCircularProgressBar() {
        self.circularProgress.animate(toAngle: 0, duration: 0, completion: nil)
        self.totalVideoDuration.removeAll()
        self.segmentsProgress.removeAll()
        self.circularProgress.deleteAllSubLayers()
        self.progress = 0
        self.discardSegmentsStackView.isHidden = true
        self.confirmRecordedSegmentStackView.isHidden = true
        self.slowFastVerticalBar.isHidden = true
    }
    
    func getUserProfile() {
        ProManagerApi.getUserProfile.request(Result<User>.self).subscribe(onNext: { (response) in
            if response.status == ResponseType.success {
                Defaults.shared.currentUser = response.result
                CurrentUser.shared.setActiveUser(response.result)
                self.setupLayoutCameraSliderView()
            } else {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
    
    func showAlertForAppSurvey() {
        appSurveyPopupView.isHidden = false
    }
    
    func getUserSettings() {
        ProManagerApi.getUserSettings.request(Result<UserSettingsResult>.self).subscribe(onNext: { response in
            if response.status == ResponseType.success {
                if let faceDetection = response.result?.userSettings?.faceDetection {
                    Defaults.shared.enableFaceDetection = faceDetection
                }
                if let guidelinesShow = response.result?.userSettings?.guidelinesShow {
                    Defaults.shared.enableGuildlines = guidelinesShow
                }
                if let iconPosition = response.result?.userSettings?.iconPosition {
                    Defaults.shared.swapeContols = iconPosition
                }
                if let supportedFrameRates = response.result?.userSettings?.supportedFrameRates {
                    Defaults.shared.supportedFrameRates = supportedFrameRates
                }
                if let videoResolution = response.result?.userSettings?.videoResolution {
                    Defaults.shared.videoResolution = VideoResolution(rawValue: videoResolution) ?? .low
                }
                if let guidelineTypes = response.result?.userSettings?.guidelineTypes {
                    Defaults.shared.cameraGuidelineTypes = GuidelineTypes(rawValue: guidelineTypes) ?? .dashedLine
                }
                if let guidelineThickness = response.result?.userSettings?.guidelineThickness {
                    Defaults.shared.cameraGuidelineThickness = GuidelineThickness(rawValue: guidelineThickness) ?? .medium
                }
                if let watermarkOpacity = response.result?.userSettings?.watermarkOpacity {
                    Defaults.shared.waterarkOpacity = watermarkOpacity
                }
                if let fastesteverWatermark = response.result?.userSettings?.fastesteverWatermark {
                    Defaults.shared.fastestEverWatermarkSetting = FastestEverWatermarkSetting(rawValue: fastesteverWatermark) ?? .hide
                }
                if let appWatermark = response.result?.userSettings?.appWatermark {
                    Defaults.shared.appIdentifierWatermarkSetting = AppIdentifierWatermarkSetting(rawValue: appWatermark) ?? .hide
                }
                if let guidelineActiveColor = response.result?.userSettings?.guidelineActiveColor {
                    var colorCode = GuidelineActiveColors(rawValue: 5)
                    colorCode = colorCode?.getTypeFromHexString(type: guidelineActiveColor)
                    Defaults.shared.cameraGuidelineActiveColor = colorCode?.getColor ?? R.color.active5()!
                }
                if let guidelineInActiveColor = response.result?.userSettings?.guidelineInActiveColor {
                    var colorCode = GuidelineInActiveColors(rawValue: 6)
                    colorCode = colorCode?.getTypeFromHexString(type: guidelineInActiveColor)
                    Defaults.shared.cameraGuidelineInActiveColor = colorCode?.getColor ?? R.color.inActive6()!
                }
                if let fastesteverWatermark = response.result?.userSettings?.fastesteverWatermark {
                    Defaults.shared.fastestEverWatermarkSetting = FastestEverWatermarkSetting(rawValue: fastesteverWatermark) ?? .hide
                }
                if let appWatermark = response.result?.userSettings?.appWatermark {
                    Defaults.shared.appIdentifierWatermarkSetting = AppIdentifierWatermarkSetting(rawValue: appWatermark) ?? .hide
                }
            } else {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            print(error.localizedDescription)
        }, onCompleted: {
            
        }).disposed(by: (rx.disposeBag))
    }
    
    func showSurveyAlertAfterThreeDays() {
        if !Defaults.shared.isSurveyAlertShowed {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = R.string.localizable.yyyyMMDdTHHMmSsSSSZ()
            if let userCreatedDate = Defaults.shared.userCreatedDate {
                guard let createdDate = dateFormatter.date(from: userCreatedDate) else {
                    return
                }
                guard let dateAfterThreeDays = Calendar.current.date(byAdding: .day, value: 3, to: createdDate) else {
                    return
                }
                if Calendar.current.isDateInToday(dateAfterThreeDays) {
                    showAlertForAppSurvey()
                    Defaults.shared.isSurveyAlertShowed = true
                }
            }
        }
    }
    
    func showAlertForUpgradeSubscription() {
        let alert = UIAlertController(title: Constant.Application.displayName, message: R.string.localizable.upgradeSubscriptionWarning(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.upgradeNow(), style: .default, handler: { (_) in
            if let subscriptionVC = R.storyboard.subscription.subscriptionContainerViewController() {
                self.navigationController?.pushViewController(subscriptionVC, animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: R.string.localizable.later(), style: .cancel, handler: { (_) in
            self.cameraSliderView.selectCell = 0
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.animateTransitionIfNeeded(to: self.currentState.opposite, duration: 0)
            }, completion: { (_ finished: Bool) -> Void in
                if finished {
                    self.currentState = .open
                }
            })
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentSafariBrowser(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
    
    func getUrlForQuickLink() {
        let user = Defaults.shared.currentUser
        let channelId = user?.channelId
        var authToken = Defaults.shared.sessionToken
        if isBusinessCenter {
            quickLinkAppUrl = URL(string: "\(DeepLinkData.deepLinkUrlString)\(DeepLinkData.appDeeplinkName.lowercased())/\(Defaults.shared.releaseType.description)/\(channelId ?? "")/\(authToken ?? "")/\(isLiteApp)")
            quickLinkWebsiteUrl = URL(string: businessCenterWebsiteUrl)
            isBusinessCenter = false
        } else {
            if let isVidplayAccountFound = self.isVidplayAccountFound {
                authToken = isVidplayAccountFound ? self.vidplaySessionToken : "null"
            }
            self.quickLinkAppUrl = URL(string: "\(DeepLinkData.vidplayDeepLinkUrlString)\(DeepLinkData.appDeeplinkName.lowercased())/\(Defaults.shared.releaseType.description)/\(channelId ?? "")/\(authToken ?? "")/\(isLiteApp)")
            self.quickLinkWebsiteUrl = URL(string: vidplayWebsiteUrl)
        }
    }
    
    func syncUserModel(completion: @escaping (_ isCompleted: Bool?) -> Void) {
        ProManagerApi.userSync.request(Result<UserSyncModel>.self).subscribe(onNext: { (response) in
            if response.status == ResponseType.success {
                Defaults.shared.currentUser = response.result?.user
                Defaults.shared.numberOfFreeTrialDays = response.result?.diffDays
                Defaults.shared.userCreatedDate = response.result?.user?.created
                Defaults.shared.isDowngradeSubscription = response.result?.userSubscription?.isDowngraded
                Defaults.shared.isFreeTrial = response.result?.user?.isTempSubscription
                Defaults.shared.allowFullAccess = response.result?.userSubscription?.allowFullAccess
                Defaults.shared.socialPlatforms = response.result?.user?.socialPlatforms
                if let isAllowAffiliate = response.result?.user?.isAllowAffiliate {
                    Defaults.shared.isAffiliateLinkActivated = isAllowAffiliate
                }
                completion(true)
            } else {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
    
    func verifyUserToken(appName: String) {
        ProManagerApi.getToken(appName: appName).request(Result<GetTokenModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            if response.status == ResponseType.success {
                self.isVidplayAccountFound = response.result?.isAccountFound
                self.vidplaySessionToken = response.result?.data?.token ?? ""
            } else {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
    
    func getReferralNotification() {
        ProManagerApi.getReferralNotification.request(Result<GetReferralNotificationModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            if response.status == ResponseType.success {
                Defaults.shared.newSignupsNotificationType = (response.result?.isForEveryone == true) ? .forAllUsers : .forLimitedUsers
            } else {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: rx.disposeBag)
    }
    
}
