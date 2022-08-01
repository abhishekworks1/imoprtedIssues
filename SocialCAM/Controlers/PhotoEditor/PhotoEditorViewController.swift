//
//  PhotoEditioViewController.swift
//  SocialCAM
//
//  Created by Viraj Patel on 04/11/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import SCRecorder
//import ColorSlider
import IQKeyboardManagerSwift
import CoreLocation
import SwiftVideoGenerator
//import URLEmbeddedView

class BaseStoryTag {
    var view: BaseStoryTagView
    var tag: InternalStoryTag
    
    init(view: BaseStoryTagView, tag: InternalStoryTag) {
        self.view = view
        self.tag = tag
    }
}

class StoryExportProgress: RPCircularProgress {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        trackTintColor = ApplicationSettings.appClearColor
        progressTintColor = ApplicationSettings.appPrimaryColor
        thicknessRatio = 0.15
    }
    
}

class PhotoEditorViewController: UIViewController {
    
    // MARK: Outlets
    
    var loadingView: LoadingView? = LoadingView.instanceFromNib()
    
    @IBOutlet weak var topGradient: UIView!
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var canvasViewWidth: NSLayoutConstraint!
    @IBOutlet weak var canvasImageView: UIImageView! {
        didSet {
            canvasImageView.contentMode = .scaleAspectFit
        }
    }
    
    @IBOutlet weak var topToolbar: UIView!
    @IBOutlet weak var editOptionsToolBar: UIView!
    @IBOutlet weak var multiFilterView: UIView!
    @IBOutlet weak var soundView: UIView!
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var horizontalFlipView: UIView!
    @IBOutlet weak var horizontalFlipButton: UIButton!
    @IBOutlet weak var verticalFlipView: UIView!
    @IBOutlet weak var verticalFlipButton: UIButton!
    
    @IBOutlet weak var addNewMusicView: UIView! {
        didSet {
            addNewMusicView.isHidden = true
        }
    }
    @IBOutlet weak var addNewMusicButton: UIButton!
    @IBOutlet weak var addNewMusicLabel: UILabel!
    
    @IBOutlet weak var trimView: UIView! {
        didSet {
            trimView.isHidden = true
        }
    }
    
    @IBOutlet weak var timeSpeedView: UIView! {
        didSet {
            timeSpeedView.isHidden = true
        }
    }
    
    @IBOutlet weak var deleteView: UIView! {
        didSet {
            deleteView.isHidden = true
            deleteView.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var hashtagButton: UIButton!
    @IBOutlet weak var saveOuttakesButton: UIButton!
    @IBOutlet weak var photoSegmentDeleteView: UIView! {
        didSet {
            photoSegmentDeleteView.isHidden = true
        }
    }
    
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
    @IBOutlet weak var resequenceButton: UIButton!
    @IBOutlet weak var resequenceLabel: UILabel!
    @IBOutlet weak var segmentCombineView: UIView!
    @IBOutlet weak var combineButton: UIButton!
    @IBOutlet weak var pic2ArtView: UIView!
    @IBOutlet weak var mergeButton: UIButton!
    @IBOutlet weak var pausePlayButton: UIButton!
    
    @IBOutlet weak var stopMotionCollectionView: KDDragAndDropCollectionView!
    
    @IBOutlet weak var photosStackView: UIStackView!
    @IBOutlet weak var custImage1: UIImageView!
    @IBOutlet weak var custImage2: UIImageView!
    @IBOutlet weak var custImage3: UIImageView!
    @IBOutlet weak var custImage4: UIImageView!
    @IBOutlet weak var custImage5: UIImageView!
    @IBOutlet weak var custImage6: UIImageView!
    @IBOutlet var btnImageClose: [UIButton]!
    @IBOutlet var photosView: [UIView]!
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var videoCoverView: UIView! {
        didSet {
            videoCoverView.isHidden = true
        }
    }
    @IBOutlet weak var thumbHeight: NSLayoutConstraint!
    @IBOutlet weak var thumbSelectorView: ThumbSelectorView!
    @IBOutlet weak var segmentedProgressBar: ProgressView!
    @IBOutlet weak var segementSafeAreaBottomConstraints: NSLayoutConstraint!
    @IBOutlet weak var segementCollectionViewBottomConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var lblCurrentSlidingTime: UILabel! {
        didSet {
            lblCurrentSlidingTime.isHidden = true
        }
    }
    
    @IBOutlet weak var bottomGradient: UIView!
    @IBOutlet weak var bottomToolbar: UIView!
    @IBOutlet weak var selectCropView: UIView!
    
    @IBOutlet weak var outtakesView: UIView!
    @IBOutlet weak var outtakesExportLabel: UILabel!
    @IBOutlet weak var outtakesProgress: StoryExportProgress!
    
    @IBOutlet weak var notesView: UIView!
    @IBOutlet weak var notesExportLabel: UILabel!
    @IBOutlet weak var notesProgress: StoryExportProgress!
    
    @IBOutlet weak var socialShareView: UIView!
    @IBOutlet weak var socialShareExportLabel: UILabel!
    @IBOutlet weak var socialShareProgress: StoryExportProgress!
    
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var chatExportLabel: UILabel!
    @IBOutlet weak var postToChatProgress: StoryExportProgress!
    
    @IBOutlet weak var feedView: UIView!
    @IBOutlet weak var feedExportLabel: UILabel!
    @IBOutlet weak var postToFeedProgress: StoryExportProgress!
    
    @IBOutlet weak var youTubeView: UIView!
    @IBOutlet weak var youTubeExportLabel: UILabel!
    @IBOutlet weak var youTubeProgress: StoryExportProgress!
    
    @IBOutlet weak var storyView: UIView!
    @IBOutlet weak var storyExportLabel: UILabel!
    @IBOutlet weak var postStoryProgress: StoryExportProgress!
    @IBOutlet weak var postStoryButton: UIButton!
    
    @IBOutlet weak var editImageWithOptionsView: UIView!
    
    @IBOutlet weak var mensionPickerView: UIView!
    @IBOutlet weak var mensionCollectionView: UICollectionView!
    @IBOutlet weak var mensionPickerViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var emojiCollectionView: UICollectionView!
    @IBOutlet weak var emojiPickerView: UIView!
    @IBOutlet weak var emojiPickerViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var doneButtonView: UIView!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var btnshowHideEditImage: UIButton!
    
    @IBOutlet weak var bottomContainerView: UIView! {
        didSet {
            bottomContainerView.isHidden = true
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var cursorContainerViewCenterConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var filterNameLabel: UILabel!
    
    @IBOutlet weak var doneTagEditButton: UIButton!
    
    @IBOutlet weak var slideShowView: UIView!
    @IBOutlet weak var slideShowCollectionView: KDDragAndDropCollectionView!
    
    // select story time
    @IBOutlet weak var selectStoryTimeView: UIView! {
        didSet {
            selectStoryTimeView.isHidden = false
        }
    }
    @IBOutlet weak var storyTimeLabel: UILabel!
    @IBOutlet weak var storyTimePickerSuperView: UIView!
    @IBOutlet weak var storyTimePickerView: PickerView! {
        didSet {
            storyTimePickerView.dataSource = self
            storyTimePickerView.delegate = self
            storyTimePickerView.scrollingStyle = .default
            storyTimePickerView.selectionStyle = .overlay
            storyTimePickerView.tintColor = ApplicationSettings.appWhiteColor
            storyTimePickerView.selectionTitle.text = "seconds"
        }
    }
    
    @IBOutlet weak var storiCamBottomToolBar: UIStackView!
    
    @IBOutlet weak var socialShareBottomToolBar: UIStackView!
    
    @IBOutlet weak var youtubeShareView: UIView!
    @IBOutlet weak var tiktokShareView: UIView!
    @IBOutlet weak var chingariShareView: UIView!
    // MARK: Variables
    
    var displayKeyframeImages: [KeyframeImage] = []
    fileprivate var slideShowImages: [SegmentVideos] = []
    
    public var asset: AVAsset?
    
    public var videoPath: String?
    /// current playback time of video
    public private(set) var currentTime = CMTime.zero
    
    var youTubeData: [String: Any]?
    var youTubeHashtags: [String]?
    var isZooming = false {
        didSet {
            self.filterSwitcherView?.selectFilterScrollView.isScrollEnabled = !isZooming
        }
    }
    var isDeleteShoworNot: Bool = false
    
    var isEditOptionsToolBarShoworNot: Bool = false
    
    var isPhotosStackViewShoworNot: Bool = false
    
    var isSegmentEditOptionViewShoworNot: Bool = false
    
    var isVideoCoverViewShoworNot: Bool = false
    
    var isEditMode: Bool = false
    var textViews: [UITextView] = []
    var lastImageOrientation: UIImage.Orientation?
    var editingStack: EditingStack?
     
    var dragAndDropController: DNDDragAndDropController!
    
    var isViewEditMode: Bool = false {
        didSet {
            videoCoverView.isHidden = isViewEditMode ? true : isVideoCoverViewShoworNot
            editOptionsToolBar.isHidden = isViewEditMode ? true : isEditOptionsToolBarShoworNot
            photosStackView.isHidden = isViewEditMode ? true : isPhotosStackViewShoworNot
            segmentEditOptionView.isHidden = isViewEditMode ? true : isSegmentEditOptionViewShoworNot
            segmentEditOptionButton.isHidden = isViewEditMode ? true : isSegmentEditOptionViewShoworNot
            deleteView.isHidden = isViewEditMode ? true : isDeleteShoworNot
            photoSegmentDeleteView.isHidden = isViewEditMode ? true : isPhotosStackViewShoworNot
            saveOuttakesButton.isHidden = isViewEditMode
            self.dragAndDropManager = isViewEditMode ? nil : KDDragAndDropManager(
                canvas: self.view,
                collectionViews: [stopMotionCollectionView]
            )
            btnshowHideEditImage.isSelected = isViewEditMode
            
            UIView.animate(withDuration: 0.5, animations: {
                self.segementSafeAreaBottomConstraints.isActive = self.isViewEditMode
                self.segementCollectionViewBottomConstraints.isActive = !self.isViewEditMode
                
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            })
            if isVideo {
                bottomContainerView.isHidden = !bottomContainerView.isHidden
                segmentedProgressBar.isHidden = !segmentedProgressBar.isHidden
                pausePlayButton.isHidden = isViewEditMode
                if let player = self.scPlayer {
                    playButton.isSelected = player.isPlaying
                    pausePlayButton.isSelected = !player.isPlaying
                }
            }
        }
    }
    
    var videoAsset: AVAsset? {
        if let asset = asset {
            return asset
        }
        
        if let videoPath = videoPath, !videoPath.isEmpty {
            var videoURL = URL(string: videoPath)
            if videoURL == nil || videoURL?.scheme == nil {
                videoURL = URL(fileURLWithPath: videoPath)
            }
            
            if let videoURL = videoURL {
                let urlAsset = AVURLAsset(url: videoURL, options: nil)
                return urlAsset
            }
        }
        
        return nil
    }
    
    var currentTagView: BaseStoryTagView?
    var storyTags: [BaseStoryTag] = []
    var hiddenHashtags: [String] = []
    
    var storyTimeOptions = ["1",
                            "2",
                            "3",
                            "4",
                            "5",
                            "6",
                            "7",
                            "8",
                            "9",
                            "10"]
    
    public var videoUrl: SegmentVideos?
    
    public var image: UIImage?
    
    public var exportedURL: URL?
    
    public var storyId: String?
    
    public var storyRePost: Bool = false
    
    public var publish: Int = PublishMode.publish.rawValue
    
    public var isMute: Bool = false
    
    var stickersVCIsVisible = false
    
    var textColor: UIColor = ApplicationSettings.appWhiteColor
    var isDrawing: Bool = false
    
    var lastPanPoint: CGPoint?
    var lastTextViewTransform: CGAffineTransform?
    var lastTextViewTransCenter: CGPoint?
    var lastTextViewFont: UIFont?
    var activeTextView: UITextView?
    var imageViewToPan: UIImageView?
    
    var isTyping: Bool = false
    var isTagTyping = false
    var isQuestionTyping = false
    
    var draggingCell: IndexPath?
    var lastMargeCell: IndexPath?
    
    var currentCamaraMode: CameraMode = .normal
    
    var isMovable: Bool = true {
        didSet {
            self.stopMotionCollectionView.isMovable = isMovable
        }
    }
    
    var isDisableResequence: Bool = false {
        didSet {
            self.stopMotionCollectionView.isMovable = !isDisableResequence
        }
    }
    
    var fromCell: IndexPath?
    
    var isVideo: Bool = false {
        didSet {
            selectStoryTimeView.isHidden = isVideo
            soundView.isHidden = !isVideo
            coverView.isHidden = !isVideo
            youTubeView.isHidden = !isVideo
            youtubeShareView.isHidden = !isVideo
            tiktokShareView.isHidden = !isVideo
        }
    }
    
    // Preview Adjust
    
    public var selectedSlideShowImages: [SegmentVideos?] = [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
    
    public var videoUrls: [SegmentVideos] = []
    public var videoResetUrls: [SegmentVideos] = []
    var videos: [FilterImage] = []
    public var currentPlayVideo: Int = -1
    public var selectedItem: Int = 0
    var isImageCellSelect: Bool = false
    
    var isViewAppear = false
    
    var dragAndDropManager: KDDragAndDropManager?
    var mensionCollectionViewDelegate: MensionCollectionViewDelegate!
    var emojiCollectionViewDelegate: EmojiCollectionViewDelegate!
    
    weak var cursorContainerViewController: KeyframePickerCursorVC!
    var scPlayer: StoryPlayer?
    
    var sketchView: SketchView?
    var colorSlider: ColorSlider?
    var filterSwitcherView: StorySwipeableFilterView?
    
    var halfModalTransitioningDelegate: HalfModalTransitioningDelegate?
    
    var stickersViewController: StickersViewController!
    
    var tagVC: TagVC!
    weak var outtakesDelegate: OuttakesTakenDelegate?
    
    var deleterectFrame: CGRect?
    
    var outtakesFrame: CGRect?
    var notesFrame: CGRect?
    var chatFrame: CGRect?
    var feedFrame: CGRect?
    var youtubeFrame: CGRect?
    var storyFrame: CGRect?
    
    var currentPage: Int = 0
    
    var lat = ""
    var long = ""
    var address = ""
    
    public var selectedVideoUrlSave: SegmentVideos?
    
    var isOriginalSequence = false
    
    var selectedUrl: URL?
    
    var undoMgr = MyUndoManager<Void>()
    
    var storiType: StoriType = .default
    var storiCamType: StoriCamType = .story
    weak var storySelectionDelegate: StorySelectionDelegate?
    
    var temperature: String?
    
    private let positionBar = UIView()
    private let handleWidth: CGFloat = 15
    private var positionConstraint: NSLayoutConstraint?
    
    private var heightConstraint: NSLayoutConstraint?
    
    var playbackTimeCheckerTimer: Timer?
    
    var isPlayerInitialize = false
    
    deinit {
        self.loadingView?.hide()
        self.loadingView = nil
        self.undoMgr.removeAll()
        self.scPlayer?.unsetupDisplayLink()
        print("Deinit \(self.description)")
    }
    
    func initLocation() {
        LocationManager.sharedInstance.delegate = self
        LocationManager.sharedInstance.refreshLocation()
        if let temp = Defaults.shared.currentTemperature {
            self.temperature = temp
        }
    }
    
    func setupStopMotionCollectionView() {
        self.stopMotionCollectionView.register(R.nib.slideshowImagesCell)
        self.stopMotionCollectionView.register(R.nib.imageCollectionViewCell)
    }
    
    func setupColorSlider() {
        colorSlider = ColorSlider(orientation: .vertical, previewSide: .left)
        if let colorSlider = colorSlider {
            colorSlider.addTarget(self, action: #selector(colorSliderValueChanged(_:)), for: UIControl.Event.valueChanged)
            self.view.addSubview(colorSlider)
            let colorSliderHeight = CGFloat(175)
            colorSlider.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                colorSlider.centerXAnchor.constraint(equalTo: editOptionsToolBar.centerXAnchor),
                colorSlider.topAnchor.constraint(equalTo: editOptionsToolBar.topAnchor, constant: 80),
                colorSlider.widthAnchor.constraint(equalToConstant: 15),
                colorSlider.heightAnchor.constraint(equalToConstant: colorSliderHeight)
            ])
            colorSlider.isHidden = true
        }
    }
    
    @objc func colorSliderValueChanged(_ sender: ColorSlider) {
        if isDrawing {
            sketchView?.lineColor = sender.color
        } else if activeTextView != nil {
            activeTextView?.textColor = sender.color
            textColor = sender.color
        }
    }
    
    var storyRect: CGRect {
        var mediaSize = CGSize.zero
        if self.currentCamaraMode == .slideshow {
            guard !videoUrls.isEmpty, let image = videoUrls.first?.image else {
                return canvasImageView.frame
            }
            mediaSize = image.size
        } else if let image = self.image {
            mediaSize = image.size
        } else {
            var assetTrack: AVAssetTrack?
            if !videoUrls.isEmpty, let asset = videoUrls.first?.currentAsset {
                assetTrack = asset.tracks(withMediaType: .video).first
            }
            guard let track = assetTrack else {
                return canvasImageView.frame
            }
            mediaSize = track.naturalSize
            mediaSize = mediaSize.applying(track.preferredTransform)
            mediaSize.width = CGFloat(abs(Float(mediaSize.width)))
            mediaSize.height = CGFloat(abs(Float(mediaSize.height)))
        }
        
        if canvasImageView.contentMode == .scaleAspectFill {
            let fillSize = self.canvasImageView.aspectFillSize(for: mediaSize)
            
            return CGRect(origin: CGPoint(x: canvasImageView.frame.origin.x - fillSize.width/2,
                                          y: 0),
                          size: fillSize)
            
        } else if canvasImageView.contentMode == .scaleAspectFit {
            return AVMakeRect(aspectRatio: mediaSize,
                              insideRect: canvasImageView.bounds)
        }
        
        return canvasImageView.frame
    }
    var dummyView: UIView!
    
    func setupFilter() {
        self.canvasViewWidth.constant = UIScreen.height*(375/667)
        
        self.canvasView.layoutIfNeeded()
        self.canvasView.layoutSubviews()
        self.canvasImageView.layoutIfNeeded()
        self.canvasImageView.layoutSubviews()
        dummyView = UIView()
        dummyView.frame = self.storyRect
        self.canvasImageView.addSubview(dummyView)
        self.filterSwitcherView = StorySwipeableFilterView(frame: CGRect(x: 0, y: 0, width: self.canvasImageView.frame.width, height: self.canvasImageView.frame.height))
        self.filterSwitcherView?.delegate = self
        self.filterSwitcherView?.isUserInteractionEnabled = true
        self.filterSwitcherView?.isMultipleTouchEnabled = true
        self.filterSwitcherView?.isExclusiveTouch = false
        filterSwitcherView?.contentMode = canvasImageView.contentMode
        self.filterSwitcherView?.backgroundColor = ApplicationSettings.appClearColor
        
        for subview in (filterSwitcherView?.subviews)! {
            subview.backgroundColor = ApplicationSettings.appClearColor
        }
        self.canvasImageView.addSubview(filterSwitcherView!)
        
        let emptyFilter = StoryFilter(name: "",
                                      ciFilter: CIFilter())
        let fadeFilter = StoryFilter(name: "Fade",
                                     ciFilter: CIFilter(name: "CIPhotoEffectFade") ?? CIFilter())
        let chromeFilter = StoryFilter(name: "Chrome",
                                       ciFilter: CIFilter(name: "CIPhotoEffectChrome") ?? CIFilter())
        let transferFilter = StoryFilter(name: "Transfer",
                                         ciFilter: CIFilter(name: "CIPhotoEffectTransfer") ?? CIFilter())
        let instantFilter = StoryFilter(name: "Instant",
                                        ciFilter: CIFilter(name: "CIPhotoEffectInstant") ?? CIFilter())
        let monoFilter = StoryFilter(name: "Mono",
                                     ciFilter: CIFilter(name: "CIPhotoEffectMono") ?? CIFilter())
        let noirFilter = StoryFilter(name: "Noir",
                                     ciFilter: CIFilter(name: "CIPhotoEffectNoir") ?? CIFilter())
        let processFilter = StoryFilter(name: "Process",
                                        ciFilter: CIFilter(name: "CIPhotoEffectProcess") ?? CIFilter())
        let tonalFilter = StoryFilter(name: "Tonal",
                                      ciFilter: CIFilter(name: "CIPhotoEffectTonal") ?? CIFilter())
        let structureFilter = StoryFilter(name: "Structure",
                                          ciFilter: CIFilter(name: "CISharpenLuminance", parameters: ["inputSharpness": 5.0]) ?? CIFilter())
        
        var filters = [emptyFilter,
                       structureFilter,
                       fadeFilter,
                       chromeFilter,
                       transferFilter,
                       instantFilter,
                       monoFilter,
                       noirFilter,
                       processFilter,
                       tonalFilter]
        
        let styleRootDirPath = URL(fileURLWithPath: Bundle.main.bundlePath).appendingPathComponent("Resources/FilterResources/filter").path
        
        if let styleFileNameArr = try? FileManager.default.contentsOfDirectory(atPath: styleRootDirPath) {
            for styleFileName in styleFileNameArr {
                let stylePath = URL(fileURLWithPath: styleRootDirPath).appendingPathComponent(styleFileName).path
                if !FileManager.default.fileExists(atPath: stylePath) {
                    continue
                }
                if let styleImage = UIImage(contentsOfFile: stylePath),
                    let ciFilter = CIFilter.filter(from: styleImage),
                    let name = URL(fileURLWithPath: styleFileName).deletingPathExtension().path.components(separatedBy: "/").last {
                    var filter = StoryFilter(name: name,
                                             ciFilter: ciFilter)
                    filter.path = stylePath
                    filters.append(filter)
                }
            }
        }
        
        filterSwitcherView?.filters = filters
        if self.currentCamaraMode != .slideshow {
            self.addGesturesTo(view: self.filterSwitcherView!)
        }
        self.setTransformationInFilterSwitcherView()
    }
    
    func setTransformationInFilterSwitcherView() {
        guard let filterSwitcherView = self.filterSwitcherView else {
            return
        }
        let tx = self.dummyView.frame.origin.x*100 / filterSwitcherView.frame.size.width
        let ty = self.dummyView.frame.origin.y*100 / filterSwitcherView.frame.size.height

        let scaleX = sqrt(pow(dummyView.transform.a, 2) + pow(dummyView.transform.c, 2))
        let scaleY = sqrt(pow(dummyView.transform.b, 2) + pow(dummyView.transform.d, 2))

        let rotation = atan2(self.dummyView.transform.b, self.dummyView.transform.a)
        self.filterSwitcherView?.imageTransformation = StoryImageView.ImageTransformation(tx: tx, ty: ty, scaleX: scaleX, scaleY: scaleY, rotation: rotation)
        self.filterSwitcherView?.setNeedsDisplay()
    }
    
    func setupSketchView() {
        sketchView = SketchView(frame: CGRect.init(origin: CGPoint.zero, size: UIScreen.main.bounds.size))
        sketchView?.backgroundColor = ApplicationSettings.appClearColor
        sketchView?.isUserInteractionEnabled = false
        sketchView?.sketchViewDelegate = self
        canvasImageView.addSubview(sketchView ?? UIView())
    }
    
    func setupStoryPlayer() {
        scPlayer = StoryPlayer()
        scPlayer?.scImageView = filterSwitcherView
        scPlayer?.delegate = self
        scPlayer?.loopEnabled = true
    }
    
    func hideShowOptions(isImage: Bool, isBoom: Bool, isSlideShow: Bool) {
        addNewMusicView.isHidden = !isSlideShow
        photosStackView.isHidden = !isSlideShow
        deleteView.isHidden = isSlideShow
        photoSegmentDeleteView.isHidden = !isSlideShow
        isDisableResequence = isSlideShow
        editImageWithOptionsView.isHidden = !isImage
        videoCoverView.isHidden = isImage
        horizontalFlipView.isHidden = !isImage
        verticalFlipView.isHidden = !isImage
        stopMotionCollectionView.isHidden = (isImage || isBoom)
        coverView.isHidden = (isImage || isSlideShow)
        segmentedProgressBar.isHidden = (isImage || isSlideShow)
        lblCurrentSlidingTime.isHidden = (isImage || isSlideShow)
        if Defaults.shared.isPro {
            timeSpeedView.isHidden = (isImage || isSlideShow)
        } else {
            timeSpeedView.isHidden = true
        }
        segmentEditOptionView.isHidden = (isImage || isBoom || isSlideShow)
        segmentEditOptionButton.isHidden = (isImage || isBoom || isSlideShow)
        soundView.isHidden = (isImage || isBoom || isSlideShow)
        youTubeView.isHidden = (isImage || isBoom || isSlideShow)
        trimView.isHidden = (isImage || isBoom || isSlideShow)
        pausePlayButton.isHidden = (isImage || isSlideShow)
        pic2ArtView.isHidden = !isImage
        selectCropView.isHidden = isSlideShow
    }
    
    func setupUIForStoryType() {
        doneButton.backgroundColor = ApplicationSettings.appPrimaryColor
        var isImage = false
        var isBoom = false
        var isSlideShow = false
        
        if let img = image {
            filterSwitcherView?.setImageBy(img)
            isVideo = false
            isImage = true
            multiFilterView.isHidden = false
        } else {
            if currentCamaraMode != .slideshow {
                setupStoryPlayer()
            }
            self.dragAndDropManager = KDDragAndDropManager(
                canvas: self.view,
                collectionViews: [stopMotionCollectionView]
            )
            deleterectFrame = deleteView.frame
            isVideo = true
            videoResetUrls = []
            videoResetUrls = videoUrls
            
            let isCombineSegments = !Defaults.shared.isCombineSegments
            
            if !isCombineSegments {
                segmentCombineView.isHidden = true
            }
            
            if !videoUrls.isEmpty {
                if self.currentCamaraMode == .boomerang {
                    let loadingView = LoadingView.instanceFromNib()
                    loadingView.shouldCancelShow = true
                    loadingView.show(on: view)
                    
                    DispatchQueue.global().async {
                        let factory = VideoFactory(type: .boom, video: VideoOrigin(mediaType: nil, mediaUrl: URL.init(fileURLWithPath: self.videoUrls[0].url!.path), referenceURL: nil))
                        factory.assetTOcvimgbuffer({ [weak self] (urls) in
                            guard let strongSelf = self else { return }
                            DispatchQueue.main.async {
                                loadingView.hide()
                            }
                            
                            strongSelf.newVideoCreate(url: strongSelf.videoUrls[0].url!, newUrl: urls)
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
                    }
                    isBoom = true
                } else if self.currentCamaraMode == .slideshow {
                    stopMotionCollectionView.reloadData()
                    if let img = self.videoUrls[0].image {
                        filterSwitcherView?.setImageBy(img)
                        isVideo = false
                    }
                    
                    enableSaveButtons(false, alpha: 0.5)
                    custImage1.tag = 1
                    custImage2.tag = 2
                    custImage3.tag = 3
                    custImage4.tag = 4
                    custImage5.tag = 5
                    custImage6.tag = 6

                    dragAndDropController = DNDDragAndDropController.init(window: UIApplication.shared.keyWindow!)
                    dragAndDropController.registerDragSource(custImage1, with: self)
                    dragAndDropController.registerDragSource(custImage2, with: self)
                    dragAndDropController.registerDragSource(custImage3, with: self)
                    dragAndDropController.registerDragSource(custImage4, with: self)
                    dragAndDropController.registerDragSource(custImage5, with: self)
                    dragAndDropController.registerDragSource(custImage6, with: self)
                    
                    dragAndDropController.registerDropTarget(photoSegmentDeleteView, with: self)
                    dragAndDropController.registerDropTarget(chatView, with: self)
                    dragAndDropController.registerDropTarget(feedView, with: self)
                    isSlideShow = true
                }
                
                coverImageView.image = self.videoUrls[0].image
                self.videoUrl = self.videoUrls[0]
            }
        }
        
        hideShowOptions(isImage: isImage, isBoom: isBoom, isSlideShow: isSlideShow)
        
    }
    
    func enableSaveButtons(_ isEnable: Bool, alpha: CGFloat) {
        storyView.isUserInteractionEnabled = isEnable
        storyView.alpha = alpha
        outtakesView.isUserInteractionEnabled = isEnable
        outtakesView.alpha = alpha
        chatView.isUserInteractionEnabled = isEnable
        chatView.alpha = alpha
        feedView.isUserInteractionEnabled = isEnable
        feedView.alpha = alpha
        notesView.isUserInteractionEnabled = isEnable
        notesView.alpha = alpha
        youTubeView.isUserInteractionEnabled = isEnable
        youTubeView.alpha = alpha
        socialShareView.isUserInteractionEnabled = isEnable
        socialShareView.alpha = alpha
    }
    
    func isProVersionApp(_ isPro: Bool) {
        socialShareBottomToolBar.isHidden = false
        storiCamBottomToolBar.isHidden = true
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
                if self.currentCamaraMode == .boomerang {
                    self.videoUrls[0].currentAsset = SegmentVideos.getRecordSession(videoModel: [SegmentVideo(segmentVideos: self.videoUrls[0])])
                    connVideoPlay()
                }
            }
            
        } catch let error as NSError {
            print("An error took place: \(error)")
        }
    }
    
    func connVideoPlay(isFirstTime: Bool = false) {
        DispatchQueue.main.async {
            self.currentPlayVideo += 1
            
            if self.currentPlayVideo == self.videoUrls.count {
                self.currentPlayVideo = 0
            }
            self.currentPage = self.currentPlayVideo
            self.stopMotionCollectionView.reloadData()
            
            if !self.videoUrls.isEmpty {
                let item = self.videoUrls[self.currentPlayVideo].currentAsset
                self.segmentedProgressBar.currentTime = 0.0
                if let itemSegment = item {
                    self.scPlayer?.setItemBy(itemSegment)
                    self.asset = itemSegment
                    
                    self.loadData()
                    self.configUI()
                    self.segmentedProgressBar.duration = itemSegment.duration.seconds
                }
            }
            
            if self.thumbHeight.constant == 0.0 {
                if let player = self.scPlayer {
                    if isFirstTime {
                        player.play()
                    } else {
                        player.isPlaying ? player.play() : nil
                    }
                    self.startPlaybackTimeChecker()
                    if let cell: ImageCollectionViewCell = self.stopMotionCollectionView.cellForItem(at: IndexPath.init(row: self.currentPage, section: 0)) as? ImageCollectionViewCell {
                        
                        guard let startTime = cell.trimmerView.startTime else {
                            return
                        }
                        
                        player.seek(to: startTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
                    }
                }
                self.segmentedProgressBar.currentTime = 0.0
            }
            
            if self.thumbSelectorView != nil && self.scPlayer != nil && self.scPlayer?.currentItem?.asset != nil {
                self.thumbSelectorView.asset = self.scPlayer?.currentItem?.asset
            }
        }
    }
    
    public func loadData() {
        if let asset = videoAsset {
            let imageGenerator = KeyframeImageGenerator()
            imageGenerator.generateDefaultSequenceOfImages(from: asset) { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.displayKeyframeImages.removeAll()
                self.displayKeyframeImages.append(contentsOf: $0)
                self.collectionView.reloadData()
            }
        }
    }
    
    public func configUI() {
        collectionView.alwaysBounceHorizontal = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.size.width / 2, bottom: 0, right: UIScreen.main.bounds.size.width / 2)
        cursorContainerViewController.seconds = 0
    }
    
    func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playButton.isSelected = true
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self,
                                                        selector:
            #selector(self.onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }
    
    func stopPlaybackTimeChecker() {
        playButton.isSelected = false
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
    
    @objc func onPlaybackTimeChecker() {
        if let player = self.scPlayer {
            setProgressViewProgress(player: player)
            self.videoPlayerPlayback(to: player.currentTime())
        }
    }
    
    // MARK: - Playback Progress Changed
    func videoPlayerPlayback(to time: CMTime) {
        // save current play time
        currentTime = time
        
        guard let asset = videoAsset,
            !time.seconds.isNaN,
            !asset.duration.seconds.isNaN,
            asset.duration.seconds != 0 else {
                return
        }
        let percent = CMTimeGetSeconds(time) / asset.duration.seconds
        let videoTrackLength = 67 * displayKeyframeImages.count
        let position = CGFloat(videoTrackLength) * CGFloat(percent) - UIScreen.main.bounds.size.width / 2
        collectionView.contentOffset = CGPoint(x: position, y: collectionView.contentOffset.y)
        cursorContainerViewController.seconds = CMTimeGetSeconds(time)
        
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int) {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func setProgressViewProgress(player: StoryPlayer) {
        let playBackTime = player.currentTime()
        
        if playBackTime.seconds >= 0 && playBackTime.isNumeric {
            self.segmentedProgressBar.currentTime = playBackTime.seconds
            
            var totalTime = 0.0
            var progressTime = 0.0
            for (index, videoAsset) in videoUrls.enumerated() {
                totalTime += (videoAsset.currentAsset?.duration.seconds)!
                if index < self.currentPage {
                    progressTime += (videoAsset.currentAsset?.duration.seconds)!
                }
            }
            
            progressTime += playBackTime.seconds
            
            let (progressTimeM, progressTimeS) = secondsToHoursMinutesSeconds(Int(Float(progressTime).roundToPlaces(places: 0)))
            let progressTimeMiliS = Utils.secondsToMiliseconds(progressTime)
            let (totalTimeM, totalTimeS) = secondsToHoursMinutesSeconds(Int(Float(totalTime).roundToPlaces(places: 0)))
            let totalTimeMiliS = Utils.secondsToMiliseconds(Double(Float(totalTime).roundToPlaces(places: 0)))
            self.lblCurrentSlidingTime.text = "\(progressTimeM):\(progressTimeS) / \(totalTimeM):\(totalTimeS)"
        }
        
        if let cell: ImageCollectionViewCell = self.stopMotionCollectionView.cellForItem(at: IndexPath.init(row: self.currentPage, section: 0)) as? ImageCollectionViewCell {
            guard let startTime = cell.trimmerView.startTime, let endTime = cell.trimmerView.endTime else {
                return
            }
            
            cell.trimmerView.seek(to: playBackTime)
            
            if playBackTime >= endTime && endTime != CMTime.zero {
                self.scPlayer?.seek(to: startTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
                cell.trimmerView.seek(to: startTime)
                cell.trimmerView.resetTimePointer()
            }
        }
    }
    
}

extension PhotoEditorViewController {
    
    func addGesturesTo(view: UIView) {
        self.dummyView.isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(handlePanGestureInFilterSwitcherView(_:)))
        panGesture.delegate = self
        panGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(handlePinchGestureInFilterSwitcherView(_:)))
        pinchGesture.delegate = self
        pinchGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self,
                                                          action: #selector(handleRotationGestureInFilterSwitcherView(_:)))
        rotationGesture.delegate = self
        rotationGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(rotationGesture)
    }
    
    @objc func handlePanGestureInFilterSwitcherView(_ recognizer: UIPanGestureRecognizer) {
        guard self.isZooming && recognizer.state == .changed else {
            return
        }
        let translation = recognizer.translation(in: canvasImageView)
        self.dummyView.center = CGPoint(x: self.dummyView.center.x + translation.x,
                                        y: self.dummyView.center.y + translation.y)
        recognizer.setTranslation(CGPoint.zero, in: canvasImageView)
        setTransformationInFilterSwitcherView()
    }
    
    @objc func handlePinchGestureInFilterSwitcherView(_ recognizer: UIPinchGestureRecognizer) {
        let location = recognizer.location(in: self.canvasImageView)
        guard self.dummyView.frame.contains(location) else {
            return
        }
        switch recognizer.state {
        case .began:
            self.isZooming = true
        case .changed:
            let pinchCenter = CGPoint(x: recognizer.location(in: self.dummyView).x - self.dummyView.bounds.midX,
                                      y: recognizer.location(in: self.dummyView).y - self.dummyView.bounds.midY)
            let transform = self.dummyView.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: recognizer.scale, y: recognizer.scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            self.dummyView.transform = transform
            recognizer.scale = 1
        case .ended, .failed, .cancelled:
            self.isZooming = false
        case .possible:
            break
        @unknown default:
            break
        }
        setTransformationInFilterSwitcherView()
    }
    
    @objc func handleRotationGestureInFilterSwitcherView(_ recognizer: UIRotationGestureRecognizer) {
        self.dummyView.transform = self.dummyView.transform.rotated(by: recognizer.rotation)
        recognizer.rotation = 0
        setTransformationInFilterSwitcherView()
    }
    
}

extension PhotoEditorViewController: UIGestureRecognizerDelegate {
    
    /**
     UIPanGestureRecognizer - Moving Objects
     Selecting transparent parts of the imageview won't move the object
     */
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        if let view = recognizer.view {
            if view is UIImageView {
                // Tap only on visible parts on the image
                if recognizer.state == .began {
                    for imageView in subImageViews(view: canvasImageView) {
                        let location = recognizer.location(in: imageView)
                        let alpha = imageView.alphaAtPoint(location)
                        if alpha > 0 {
                            imageViewToPan = imageView
                            break
                        }
                    }
                }
                if imageViewToPan != nil {
                    moveView(view: imageViewToPan!, recognizer: recognizer)
                }
            } else {
                moveView(view: view, recognizer: recognizer)
            }
        }
    }
    
    /**
     UIPinchGestureRecognizer - Pinching Objects
     If it's a UITextView will make the font bigger so it doen't look pixlated
     */
    @objc func pinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            if let textView = view as? UITextView {
                
                textView.transform = textView.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            } else {
                view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            }
            recognizer.scale = 1
        }
    }
    
    /**
     UIRotationGestureRecognizer - Rotating Objects
     */
    @objc func rotationGesture(_ recognizer: UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    /**
     UITapGestureRecognizer - Taping on Objects
     Will make scale scale Effect
     Selecting transparent parts of the imageview won't move the object
     */
    @objc func tapGesture(_ recognizer: UITapGestureRecognizer) {
        if let view = recognizer.view {
            if view is UIImageView {
                // Tap only on visible parts on the image
                for imageView in subImageViews(view: canvasImageView) {
                    let location = recognizer.location(in: imageView)
                    let alpha = imageView.alphaAtPoint(location)
                    if alpha > 0 {
                        scaleEffect(view: imageView)
                        break
                    }
                }
            } else {
                scaleEffect(view: view)
            }
        }
    }
    
    /*
     Support Multiple Gesture at the same time
     */
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func screenHastTagEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            self.openTags(UIButton())
        }
    }
    
    func dismiss() {
        DispatchQueue.runOnMainThread {
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    func getTags() -> [InternalStoryTag] {
        var internalStoryTags: [InternalStoryTag] = []
        for tag in storyTags {
            setTagPositionFor(tag.tag, view: tag.view)
            if tag.tag.tagType == StoryTagType.slider.rawValue,
                let sliderQueView = tag.view as? StorySliderQueView {
                let sliderTagDict = ["question": sliderQueView.questionText,
                                     "emoji": sliderQueView.slider.emojiText,
                                     "colorStart": sliderQueView.startColor.toHexString(),
                                     "colorEnd": sliderQueView.endColor.toHexString(),
                                     "averageAns": 0,
                                     "myAns": 0] as [String: Any]
                let sliderTagString = sliderTagDict.dict2json()
                tag.tag.sliderTag = sliderTagString
            } else if tag.tag.tagType == StoryTagType.poll.rawValue,
                let pollQueView = tag.view as? StoryPollQueView {
                let pollTagDict = ["question": pollQueView.questionText,
                                   "options": [["optionNumber": 1,
                                                 "text": pollQueView.firstOptionText,
                                                 "averageAns": 0,
                                                 "colorStart": "",
                                                 "colorEnd": "",
                                                 "fontSize": Float(pollQueView.firstOptionTextView.font?.pointSize ?? 0)],
                                                ["optionNumber": 2,
                                                 "text": pollQueView.secondOptionText,
                                                 "averageAns": 0,
                                                 "colorStart": "",
                                                 "colorEnd": "",
                                                 "fontSize": Float(pollQueView.secondOptionTextView.font?.pointSize ?? 0)]]] as [String: Any]
                
                let pollTagString = pollTagDict.dict2json()
                tag.tag.pollTag = pollTagString
            } else if tag.tag.tagType == StoryTagType.askQuestion.rawValue,
                let askQueView = tag.view as? StoryAskQuestionView {
                let askQueTagDict = ["question": askQueView.questionText,
                                     "colorStart": askQueView.textStartColor.toHexString(),
                                     "colorEnd": askQueView.textEndColor.toHexString()] as [String: Any]
                
                let askQueTagString = askQueTagDict.dict2json()
                tag.tag.askQuestionTag = askQueTagString
            }
            internalStoryTags.append(tag.tag)
        }
        return internalStoryTags
    }
    
    func setTagPositionFor(_ tag: InternalStoryTag, view: UIView) {
        tag.tagFontSize = 20.0
        tag.tagHeight = Float(view.originalFrame.height)
        tag.tagWidth = Float(view.originalFrame.width)
        tag.centerX = Float(view.xGlobalCenterPoint)
        tag.centerY = Float(view.yGlobalCenterPoint)
        tag.scaleX = Float(view.scaleXValue)
        tag.scaleY = Float(view.scaleYValue)
        tag.rotation = Float(view.rotationValue)
    }
    
    func composeImageWith(_ image: UIImage) -> UIImage {
        UIGraphicsBeginImageContext(image.size)
        let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return compositeImage!
    }
    
    func openTags(_ sender: Any) {
        self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: tagVC)
        self.halfModalTransitioningDelegate?.height = 250
        tagVC.modalPresentationStyle = .custom
        tagVC.hashTagViewControllerDelegate = self
        tagVC.transitioningDelegate = self.halfModalTransitioningDelegate
        self.present(tagVC, animated: true, completion: nil)
    }
    
    // to Override Control Center screen edge pan from bottom
    
    /**
     Scale Effect
     */
    func scaleEffect(view: UIView) {
        view.superview?.bringSubviewToFront(view)
        
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
        let previouTransform =  view.transform
        UIView.animate(withDuration: 0.2,
                       animations: {
                        view.transform = view.transform.scaledBy(x: 1.2, y: 1.2)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.2) {
                            view.transform  = previouTransform
                        }
        })
    }
    
    /**
     Moving Objects
     delete the view if it's inside the delete view
     Snap the view back if it's out of the canvas
     */
    
    func moveView(view: UIView, recognizer: UIPanGestureRecognizer) {
        guard doneButtonView.isHidden else {
            return
        }
        deleteView.isHidden = false
        
        view.superview?.bringSubviewToFront(view)
        let pointToSuperView = recognizer.location(in: self.view)
        
        view.center = CGPoint(x: view.center.x + recognizer.translation(in: canvasImageView).x,
                              y: view.center.y + recognizer.translation(in: canvasImageView).y)
        
        recognizer.setTranslation(CGPoint.zero, in: canvasImageView)
        
        if let previousPoint = lastPanPoint,
            !(view is AskQuestionReplyView) {
            // View is going into deleteView
            if deleteView.frame.contains(pointToSuperView) && !deleteView.frame.contains(previousPoint) {
                if #available(iOS 10.0, *) {
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                }
                UIView.animate(withDuration: 0.3, animations: {
                    self.deleteView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                    view.transform = view.transform.scaledBy(x: 0.5, y: 0.5)
                    view.center = recognizer.location(in: self.canvasImageView)
                })
            }
                // View is going out of deleteView
            else if deleteView.frame.contains(previousPoint) && !deleteView.frame.contains(pointToSuperView) {
                // Scale to original Size
                UIView.animate(withDuration: 0.3, animations: {
                    self.deleteView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    view.transform = view.transform.scaledBy(x: 2, y: 2)
                    view.center = recognizer.location(in: self.canvasImageView)
                })
            }
        }
        lastPanPoint = pointToSuperView
        
        if recognizer.state == .ended {
            imageViewToPan = nil
            lastPanPoint = nil
            let point = recognizer.location(in: self.view)
            
            if deleteView.frame.contains(point) { // Delete the view
                if let tagView = view as? BaseStoryTagView {
                    self.storyTags = self.storyTags.filter { $0.view != tagView }
                }
                if !(view is AskQuestionReplyView) {
                    view.removeFromSuperview()
                }
                if #available(iOS 10.0, *) {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
                self.deleteView.transform = CGAffineTransform(scaleX: 1, y: 1)
            } else if !canvasImageView.bounds.contains(view.center) { // Snap the view back to canvasImageView
                UIView.animate(withDuration: 0.3, animations: {
                    view.center = self.canvasImageView.center
                })
                
            }
        }
    }
    
    func subImageViews(view: UIView) -> [UIImageView] {
        var imageviews: [UIImageView] = []
        for imageView in view.subviews {
            if let imgView = imageView as? UIImageView {
                imageviews.append(imgView)
            }
        }
        return imageviews
    }
    
}
