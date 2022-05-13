//
//  StoryEditorViewController.swift
//  SocialCAM
//
//  Created by Jasmin Patel on 10/12/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftVideoGenerator
import AVKit
import IQKeyboardManagerSwift
//import ColorSlider
import GoogleAPIClientForREST
import SwiftUI
import Photos

class ShareStoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var storyImageView: UIImageView!
    @IBOutlet weak var checkMarkView: UIImageView!
}

class ShareOptionTableViewCell: UITableViewCell {
    @IBOutlet weak var optionImageView: UIImageView!
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
        
    func configureCell(_ shareOption: StoryEditorViewController.ShareOption) {
        optionImageView.image = shareOption.image
        optionLabel.text = shareOption.name
    }

}

class StoryEditorMedia: CustomStringConvertible, NSCopying, Equatable {
   
    var storyIndex: Int?
    var id: String
    var type: StoryEditorType
    var isSelected: Bool
    
    init(type: StoryEditorType, isSelected: Bool = false) {
        self.id = UUID().uuidString
        self.type = type
        self.isSelected = isSelected
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = StoryEditorMedia(type: type, isSelected: isSelected)
        return copy
    }
    
    static func == (lhs: StoryEditorMedia, rhs: StoryEditorMedia) -> Bool {
        return lhs.id == rhs.id
    }
}

class StoryEditorCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailNumberLabel: UILabel!
    @IBOutlet weak var thumbnailTimeLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    var deleteSlideshowImageHandler: ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        if let handler = self.deleteSlideshowImageHandler {
            handler(sender.tag)
        }
    }
    
}

class StoryEditorViewController: UIViewController {
    
    struct ShareOption {
        var name: String
        var image: UIImage?
        
        static let options: [ShareOption] = [
            ShareOption(name: R.string.localizable.facebook(),
                        image: R.image.icoFacebook()),
            ShareOption(name: R.string.localizable.twitter(),
                        image: R.image.icoTwitter()),
            ShareOption(name: R.string.localizable.instagram(),
                        image: R.image.icoInstagram()),
            ShareOption(name: R.string.localizable.snapchat(),
                        image: R.image.icoSnapchat()),
            ShareOption(name: R.string.localizable.youtube(),
                        image: R.image.icoYoutube()),
            ShareOption(name: R.string.localizable.tikTok(),
                        image: R.image.icoTikTok())
        ]
    }
    
    @IBOutlet weak var blurView: UIView!

    @IBOutlet weak var shareCollectionViewHeight: NSLayoutConstraint!

    @IBOutlet weak var shareViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.tableFooterView = UIView()
        }
    }
    @IBOutlet weak var playButtonBottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var waterMarkGIFView: UIView!
    
    @IBOutlet weak var shareCollectionView: UICollectionView!
    
    @IBOutlet weak var splitOptionView: UIView!
    @IBOutlet weak var editToolBarView: UIView!
    @IBOutlet weak var downloadView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var imgFastestEverWatermark: UIImageView!
    @IBOutlet weak var imgQuickCamWaterMark: UIImageView!
    @IBOutlet weak var userNameLabelWatermark: UILabel!
    var timeFloatArray = [Float]()
    @IBOutlet weak var specificBoomerangView: UIView! {
        didSet {
            self.specificBoomerangView.isHidden = true
        }
    }
    @IBOutlet weak var soundOptionView: UIView! {
        didSet {
            self.soundOptionView.isHidden = true
        }
    }
    @IBOutlet weak var addMusicOptionView: UIView! {
        didSet {
            self.addMusicOptionView.isHidden = true
        }
    }
    @IBOutlet weak var addMusicButton: UIButton!
    @IBOutlet weak var addMusicLabel: UILabel!
    @IBOutlet weak var trimOptionView: UIView! {
        didSet {
            self.trimOptionView.isHidden = true
        }
    }
    @IBOutlet weak var omitOptionView: UIView! {
        didSet {
            self.omitOptionView.isHidden = true
        }
    }
    @IBOutlet weak var mergeOptionView: UIView! {
        didSet {
            self.mergeOptionView.isHidden = true
        }
    }
    
    @IBOutlet weak var timeSpeedOptionView: UIView! {
        didSet {
            self.timeSpeedOptionView.isHidden = true
        }
    }
    @IBOutlet weak var pic2ArtOptionView: UIView!
    @IBOutlet weak var cropOptionView: UIView!
    @IBOutlet weak var editOptionView: UIView!
    @IBOutlet weak var applyFilterOptionView: UIView!

    @IBOutlet weak var slideShowPreviewView: UIView!
    
    @IBOutlet weak var slideShowFillAuto: UIView!
 
    @IBOutlet weak var soundButton: UIButton!
    
    @IBOutlet weak var backgroundCollectionView: UIView!
    @IBOutlet weak var collectionView: DragAndDropCollectionView!
    @IBOutlet weak var nativePlayercollectionView: UICollectionView!
    @IBOutlet weak var slideShowCollectionView: DragAndDropCollectionView!
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var deleteView: UIView!

    @IBOutlet weak var youtubeShareView: UIView!
    @IBOutlet weak var tiktokShareView: UIView!
   // @IBOutlet weak var storiCamShareView: UIView!
    
    @IBOutlet weak var discardPopUpMessageLabel: UILabel!
    @IBOutlet weak var btnShowHideEditImage: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nativePlayerPlayPauseButton: UIButton!
    @IBOutlet weak var bottomContainerView: UIView! {
        didSet {
            bottomContainerView.isHidden = true
        }
    }
    
    @IBOutlet weak var socialShareBottomView: UIView!
    @IBOutlet weak var progressBarView: UIView!
    @IBOutlet weak var videoProgressBar: UISlider!
    //@IBOutlet weak var videoProgressBar: VideoSliderView!
    @IBOutlet weak var storyProgressBar: ProgressView!
    @IBOutlet weak var lblStoryTime: UILabel!
    
    @IBOutlet weak var cursorContainerViewCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var ssuTagView: UIView!
    @IBOutlet weak var doneButtonView: UIView!
    @IBOutlet weak var backButtonView: UIView!
    @IBOutlet weak var closeDoneButtonView: UIView!
    @IBOutlet weak var closeLabel: UILabel!
    @IBOutlet weak var showHideLabel: UILabel!
    @IBOutlet weak var showHideView: UIView!
    @IBOutlet weak var cropPopupBlurView: UIVisualEffectView!
    @IBOutlet weak var croppedAlertView: UIView!
    
    @IBOutlet weak var socialMediaMainView: UIView!

    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var btnYoutube: UIButton!
    @IBOutlet weak var btnInstagram: UIButton!
    @IBOutlet weak var btnTwitter: UIButton!
    @IBOutlet weak var btnTiktok: UIButton!
    @IBOutlet weak var lblSaveShare: UILabel!
    
    @IBOutlet weak var ivvwFacebook: UIImageView!
    @IBOutlet weak var ivvwYoutube: UIImageView!
    @IBOutlet weak var ivvwInstagram: UIImageView!
    @IBOutlet weak var ivvwTwitter: UIImageView!
    @IBOutlet weak var ivvwTiktok: UIImageView!
    
   // @IBOutlet weak var btnStoricamShare: UIButton!
    @IBOutlet weak var hideToolTipView: UIView!
    @IBOutlet weak var btnDoNotShowAgain: UIButton!
    @IBOutlet weak var btnFastesteverWatermark: UIButton!
    @IBOutlet weak var btnAppIdentifierWatermark: UIButton!
    @IBOutlet weak var watermarkView: UIView!
    @IBOutlet weak var watermarkOptionsView: UIView!
    @IBOutlet weak var btnSelectFastesteverWatermark: UIButton!
    @IBOutlet weak var btnSelectAppIdentifierWatermark: UIButton!
    @IBOutlet weak var btnMadeWithWatermark: UIButton!
    @IBOutlet weak var imgViewMadeWithGif: UIImageView!
    @IBOutlet weak var btnSelectedMadeWithGif: UIButton!
    @IBOutlet weak var btnMadeWithGif: UIButton!
    @IBOutlet weak var editTooltipView: UIView!
    @IBOutlet var imgEditTooltip: [UIImageView]?
    @IBOutlet weak var lblEditTooltip: UILabel!
    @IBOutlet weak var btnSkipEditTooltip: UIButton!
    @IBOutlet weak var discardVideoPopupView: UIView!
    @IBOutlet weak var btnDoNotShowDiscardVideo: UIButton!
    @IBOutlet weak var lblUserNameWatermark: UILabel!
    @IBOutlet weak var lblPublicDisplaynameWatermark: UILabel!
    @IBOutlet weak var btnSelectPublicDisplaynameWatermark: UIButton!
    @IBOutlet weak var btnPublicDisplaynameWatermark: UIButton!
    
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var saveVideoPopupView: UIView!
    
    @IBOutlet weak var lblVideoSaveText: UILabel!
    private let fastestEverWatermarkBottomMargin = 112
    weak var cursorContainerViewController: KeyframePickerCursorVC!
    var playbackTimeCheckerTimer: Timer?
    var displayKeyframeImages: [KeyframeImage] = []
    public var currentVideoAsset: AVAsset? {
        var avAsset: AVAsset?
        switch storyEditors[currentStoryIndex].type {
        case .image:
            break
        case let .video(_, asset):
            avAsset = asset
        }
        return avAsset
    }
    
    var startDraggingIndex: Int?
    public var medias = [StoryEditorMedia]()
    public var selectedSlideShowMedias = [StoryEditorMedia]() {
        didSet {
            var imageData: [UIImage] = []
            for media in selectedSlideShowMedias {
                if case let .image(image) = media.type,
                    image != UIImage() {
                    imageData.append(image)
                }
            }
            if imageData.count > 0 {
                slideShowFillAuto.alpha = 0.7
                slideShowFillAuto.isUserInteractionEnabled = false
            } else {
                slideShowFillAuto.alpha = 1
                slideShowFillAuto.isUserInteractionEnabled = true
            }
        }
    }
    var draggableIndex = -1

    private var filteredImagesStory: [StoryEditorMedia] = []
    
    private var storyEditors: [StoryEditorView] = []

    private var isVideoPlay: Bool = false
    
    private var currentStoryIndex = 0
    
    private var editingStack: EditingStack?
        
    private var dragAndDropManager: DragAndDropManager?
    
    private var slideShowAudioURL: URL?
    
    public var isSlideShow: Bool = false
    
    public var isBoomerang: Bool = false

    private var colorSlider: ColorSlider!
    var cameraMode: CameraMode = .basicCamera
    
    private var loadingView: LoadingView? = LoadingView.instanceFromNib()
    
    private var slideShowExportedURL: URL?
    var videoExportedURL: URL?
    
    var isDragged = false
    public var referType: ReferType = .none
    var popupVC: STPopupController = STPopupController()
    var isCropped: Bool = false
    var croppedImage: UIImage?
    var croppedBGcolor: UIColor = .black
    var croppedUrl: URL?
    var isHideTapped = false
    var isFastesteverWatermarkShow = false
    var isAppIdentifierWatermarkShow = false
    var isMadeWithGifShow = false
    var isPublicDisplaynameWatermarkShow = false
    var isSettingsChange = false
    var socialShareTag = 0
    var isTiktokShare = false
    var editTooltipCount = 0
    var editTooltipText = Constant.EditTooltip.editTooltipTextArray
    var isDiscardVideoPopupHide = false
    var storyEditorsSubviews: [StoryEditorView] = []
    var isTrim = false
    var isFromGallery = false
    var isVideoModified = false
    var isVideoRecorded = false
    var isSagmentSelection = false
    var isCurrentAssetMuted = false
    var socialShareExportURL:URL?
    var isShowToolTipView = false
    var isViewEditMode: Bool = false {
        didSet {
            editToolBarView.isHidden = isViewEditMode
            shareView.isHidden = isViewEditMode
            downloadView.isHidden = true
            backButtonView.isHidden = isViewEditMode
            if (storyEditors.count > 1) {
                collectionView.isHidden = isViewEditMode
                backgroundCollectionView.isHidden = isViewEditMode
            }
            if isSlideShow {
                self.slideShowCollectionView.isHidden = isViewEditMode
            }
            
            btnShowHideEditImage.isSelected = isViewEditMode
            isViewEditMode ? (showHideLabel.text = R.string.localizable.show()) : (showHideLabel.text = R.string.localizable.hide())
            if currentVideoAsset != nil {
                playPauseButton.isHidden = isViewEditMode
                progressBarView.isHidden = !progressBarView.isHidden
            }
            socialShareBottomView.isHidden = true
            showHideView.isHidden = isViewEditMode
            watermarkView.isHidden = isViewEditMode
            isHideTapped = isViewEditMode
            self.imgFastestEverWatermark.isHidden = isViewEditMode
            if !isViewEditMode {
                self.imgFastestEverWatermark.isHidden = Defaults.shared.fastestEverWatermarkSetting == .hide
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        videoProgressBar.timeSlider.layer.cornerRadius = videoProgressBar.timeSlider.frame.height/2
        isShowToolTipView = UserDefaults.standard.bool(forKey: "isShowToolTipView")
        socialMediaViewTapGesture()
        if let isRegistered = Defaults.shared.isRegistered {
            if isRegistered {
                Defaults.shared.isRegistered = false
                showEditTooltip()
            }
        }
        downloadViewGesture()
        imgViewMadeWithGif.loadGif(name: R.string.localizable.madeWithQuickCamLite())
        self.lblUserNameWatermark.text = "@\(Defaults.shared.currentUser?.username ?? "")"
        self.userNameLabelWatermark.text = "@\(Defaults.shared.currentUser?.username ?? "")"
        setupFilterViews()
        setGestureViewForShowHide(view: storyEditors[currentStoryIndex])
        selectedSlideShowMedias = (0...20).map({ _ in StoryEditorMedia(type: .image(UIImage())) })
        slideShowCollectionView.reloadData()
        var collectionViews: [UIView] = [collectionView]
        if isSlideShow {
            collectionViews.append(slideShowCollectionView)
        }
        self.dragAndDropManager = DragAndDropManager(canvas: self.view,
                                                     collectionViews: collectionViews)
        if Defaults.shared.isVideoSavedAfterRecording && !isFromGallery {
            if cameraMode == .pic2Art {
                lblVideoSaveText.text = R.string.localizable.yourPic2ArtIsAutomaticallySavedYouCanTurnOffAutoSavingInTheCameraSettings()
            } else {
                lblVideoSaveText.text = R.string.localizable.yourVideoWasAutomaticallySavedYouCanTurnOffAutoSavingInTheCameraSettings()
            }
            if let isRegistered = Defaults.shared.isFirstVideoRegistered, cameraMode != .pic2Art {
                if isRegistered {
                    Defaults.shared.isFirstVideoRegistered = false
                    self.hideSaveVideoPopupView(isHide: false)
                } else {
                    DispatchQueue.main.async {
                       // self.view.makeToast(R.string.localizable.videoSaved())
                    }
                }
            } else if let isRegistered = Defaults.shared.isFirstTimePic2ArtRegistered, cameraMode == .pic2Art {
                if isRegistered {
                    Defaults.shared.isFirstTimePic2ArtRegistered = false
                    self.hideSaveVideoPopupView(isHide: false)
                }
            }
        }
        self.socialShareExportURL = nil
        self.socialMediaMainView.isHidden = true
        Defaults.shared.isEditSoundOff = false
        if cameraMode == .pic2Art {
            lblSaveShare.text = R.string.localizable.savePic2art()
        } else {
            lblSaveShare.text = R.string.localizable.saveVideo()
        }
    }
    
    
    func socialMediaViewTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSocialMediaView))
        tapGesture.numberOfTapsRequired = 1
        socialMediaMainView.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTapSocialMediaView(sender: UITapGestureRecognizer) {
        socialMediaMainView.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        //self.socialMediaMainView.frame = CGRect(x: self.view.frame.size.width, y: 0,width: self.view.frame.size.width ,height: self.view.frame.size.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setSocialShareView()
        if  cameraMode == .pic2Art {
            self.imgFastestEverWatermark.image = R.image.pic2artwatermark()
            self.imgQuickCamWaterMark.image = R.image.quickcamWatermark()
        }
        self.imgFastestEverWatermark.isHidden = Defaults.shared.fastestEverWatermarkSetting == .hide
        isFastesteverWatermarkShow = Defaults.shared.fastestEverWatermarkSetting == .show
        btnSelectFastesteverWatermark.isSelected = isFastesteverWatermarkShow
        btnFastesteverWatermark.isSelected = isFastesteverWatermarkShow
        isAppIdentifierWatermarkShow = Defaults.shared.appIdentifierWatermarkSetting == .show
        btnSelectAppIdentifierWatermark.isSelected = isAppIdentifierWatermarkShow
        btnAppIdentifierWatermark.isSelected = isAppIdentifierWatermarkShow
        isMadeWithGifShow = Defaults.shared.madeWithGifSetting == .show
        btnSelectedMadeWithGif.isSelected = isMadeWithGifShow
        isPublicDisplaynameWatermarkShow = Defaults.shared.publicDisplaynameWatermarkSetting == .show
        btnSelectPublicDisplaynameWatermark.isSelected = isPublicDisplaynameWatermarkShow
        isPublicDisplaynameWatermarkShow = Defaults.shared.publicDisplaynameWatermarkSetting == .show
        self.lblPublicDisplaynameWatermark.text = "@\(Defaults.shared.currentUser?.username ?? "")"
        setGestureViewForShowHide(view: storyEditors[currentStoryIndex])
       
        storyEditors[currentStoryIndex].isMuted = isCurrentAssetMuted
        
        if Defaults.shared.appMode == .free {
            btnFastesteverWatermark.isSelected = true
            btnAppIdentifierWatermark.isSelected = true
            btnSelectAppIdentifierWatermark.isSelected = true
            btnSelectedMadeWithGif.isSelected = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if cameraMode == .pic2Art {
            if Defaults.shared.appMode == .free && Defaults.shared.appMode == .basic {
                editOptionView.isHidden = true
            } else {
                editOptionView.isHidden = false
            }
            btnFastesteverWatermark.setImage(R.image.pic2artwatermark(), for: .normal)
        }
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        videoProgressBar.addTapGesture()
        videoProgressBar.layoutSubviews()
        isVideoPlay ? pauseVideo() : playVideo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = true
        pauseVideo()
    }
    
    deinit {
        print("Deinit \(self.description)")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        self.view.layoutIfNeeded()
        for storyEditor in storyEditors {
            storyEditor.frame = mediaImageView.frame
        }
    }
    
    func setupFilterViews() {
        setupColorSlider()
        self.view.layoutIfNeeded()
        mediaImageView.layoutIfNeeded()
        for (index, type) in medias.enumerated() {
            let storyEditorView = StoryEditorView(frame: mediaImageView.frame,
                                                  type: type.type,
                                                  contentMode: .scaleAspectFit,
                                                  deleteView: deleteView,
                                                  undoView: undoButton)
            storyEditorView.delegate = self
            storyEditorView.socialShareView = self.socialShareBottomView
            view.insertSubview(storyEditorView, aboveSubview: mediaImageView)

            
            storyEditorView.center = mediaImageView.center
            if !isQuickApp {
                storyEditorView.filters = StoryFilter.filters
            }
            storyEditorView.addTikTokShareViewIfNeeded()
            if index > 0 {
                storyEditorView.isHidden = true
            }
            storyEditors.append(storyEditorView)
        }
        for index in 0..<storyEditorsSubviews.count {
            for views in storyEditorsSubviews[index].subviews {
                if views.className == "FollowMeStoryView" || views.className == "UIImageView" || views.className == "UITextView" {
                    if isTrim {
                        storyEditors[index].addSubview(views)
                        for recognizer in views.gestureRecognizers ?? [] {
                            views.removeGestureRecognizer(recognizer)
                        }
                        storyEditors[index].addStickerGestures(views)
                    } else {
                        storyEditors.first?.addSubview(views)
                        for recognizer in views.gestureRecognizers ?? [] {
                            views.removeGestureRecognizer(recognizer)
                        }
                        storyEditors.first?.addStickerGestures(views)
                    }
                }
            }
        }
        collectionView.reloadData()
        if storyEditors.count > 1 {
            isSagmentSelection = true
        }else{
            isSagmentSelection = false
        }
        for index in 0..<storyEditors.count {
            self.storyEditors[index].isCropped = self.isCropped
        }
        if currentVideoAsset != nil {
            self.loadData()
            self.configUI()
        }
        
        hideOptionIfNeeded()
    }
    
    /// Set images for social share buttons
    func setSocialShareView() {
        if Defaults.shared.appMode == .free && (isSnapCamLiteApp || isQuickApp) {
//            btnFacebook.setImage(R.image.icoFacebookTransparent(), for: .normal)
//            btnYoutube.setImage(R.image.icoYoutubeTransparent(), for: .normal)
//            btnInstagram.setImage(R.image.icoInstagramTransparent(), for: .normal)
//            btnTwitter.setImage(R.image.icoTwitterTransparent(), for: .normal)
//            btnTiktok.setImage(R.image.icoTiktokTransparent(), for: .normal)
            
//            ivvwFacebook.image = R.image.icoFacebookTransparent()
//            ivvwYoutube.image = R.image.icoYoutubeTransparent()
//            ivvwInstagram.image = R.image.icoInstagramTransparent()
//            ivvwTwitter.image = R.image.icoTwitterTransparent()
//            ivvwTiktok.image = R.image.icoTiktokTransparent()
            
            ivvwFacebook.image = R.image.icoFacebook()
            ivvwYoutube.image = R.image.icoYoutube()
            ivvwInstagram.image = R.image.icoInstagram()
            ivvwTwitter.image = R.image.icoTwitter()
            ivvwTiktok.image = R.image.icoTikTok()
        } else {
//            btnFacebook.setImage(R.image.icoFacebook(), for: .normal)
//            btnYoutube.setImage(R.image.icoYoutube(), for: .normal)
//            btnInstagram.setImage(R.image.icoInstagram(), for: .normal)
//            btnTwitter.setImage(R.image.icoTwitter(), for: .normal)
//            btnTiktok.setImage(R.image.icoTikTok(), for: .normal)
            
            ivvwFacebook.image = R.image.icoFacebook()
            ivvwYoutube.image = R.image.icoYoutube()
            ivvwInstagram.image = R.image.icoInstagram()
            ivvwTwitter.image = R.image.icoTwitter()
            ivvwTiktok.image = R.image.icoTikTok()
        }
    }
    
    func setupColorSlider() {
        colorSlider = ColorSlider(orientation: .vertical, previewSide: .left)
        colorSlider.addTarget(self, action: #selector(colorSliderValueChanged(_:)), for: UIControl.Event.valueChanged)
        view.insertSubview(colorSlider, aboveSubview: undoButton)
        let colorSliderHeight = CGFloat(175)
        colorSlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorSlider.centerXAnchor.constraint(equalTo: undoButton.centerXAnchor),
            colorSlider.topAnchor.constraint(equalTo: undoButton.bottomAnchor, constant: 20),
            colorSlider.widthAnchor.constraint(equalToConstant: 15),
            colorSlider.heightAnchor.constraint(equalToConstant: colorSliderHeight)
        ])
        colorSlider.isHidden = true
    }
    
    @objc func colorSliderValueChanged(_ sender: ColorSlider) {
        storyEditors[currentStoryIndex].selectedColor = sender.color
    }
    
    func hideOptionIfNeeded() {
        var isImage = false
        switch storyEditors[currentStoryIndex].type {
        case .image:
            isImage = true
        default: break
        }
        if let currentUser = Defaults.shared.currentUser, let isAdvanceMode = currentUser.advanceGameMode {
            //self.storiCamShareView.isHidden = !isAdvanceMode
        } else {
            //self.storiCamShareView.isHidden = true
        }
        
        self.editOptionView.isHidden = !isImage
        self.applyFilterOptionView.isHidden = !isImage
        if !isTimeSpeedApp && !isFastCamApp && !isPic2ArtApp && !isViralCamApp && !isQuickCamApp && !isViralCamLiteApp && !isFastCamLiteApp && !isQuickCamLiteApp && !isSnapCamLiteApp && !isSpeedCamApp && !isSpeedCamLiteApp && !isQuickApp {
            self.specificBoomerangView.isHidden = (Defaults.shared.appMode != .free && isBoomerang) ? true : isImage
        } else {
            self.specificBoomerangView.isHidden = true
        }
        self.ssuTagView.isHidden = false
        
        if isQuickCamLiteApp {
            self.pic2ArtOptionView.isHidden = false
        } else if !isFastCamApp {
            self.pic2ArtOptionView.isHidden = (Defaults.shared.appMode != .free && Defaults.shared.appMode != .basic) ? !isImage : true
        } else {
            self.pic2ArtOptionView.isHidden = true
        }
        self.soundOptionView.isHidden = isImage
        self.trimOptionView.isHidden = isImage
        self.splitOptionView.isHidden = true//isImage
        self.omitOptionView.isHidden = isImage
        var videoCount = 0
        for editor in storyEditors {
            if case StoryEditorType.video(_, _) = editor.type {
                videoCount += 1
            }
        }
        
        self.mergeOptionView.isHidden = !(!isImage && (videoCount > 1))
       
        if !isBoomiCamApp && !isFastCamApp && !isViralCamLiteApp && !isFastCamLiteApp && !isQuickCamLiteApp && !isSpeedCamLiteApp && !isSnapCamLiteApp && !isQuickApp {
            self.timeSpeedOptionView.isHidden = Defaults.shared.appMode != .free ? isImage : true
        } else {
            self.timeSpeedOptionView.isHidden = true
        }
        
        self.slideShowCollectionView.isHidden = !isSlideShow
        self.slideShowPreviewView.isHidden = !isSlideShow
        self.slideShowFillAuto.isHidden = !isSlideShow
        self.addMusicOptionView.isHidden = !isSlideShow
        self.collectionView.isHidden = !(storyEditors.count > 1)
//        self.playButtonBottomLayoutConstraint.constant = (storyEditors.count > 1) ? 70 : 10
        self.backgroundCollectionView.isHidden = self.collectionView.isHidden
        
        self.youtubeShareView.isHidden = isImage //isImage
        self.tiktokShareView.isHidden = isImage
        self.playPauseButton.isHidden = isImage
        self.progressBarView.isHidden = isImage
    }
         
    func hideToolBar(hide: Bool, hideColorSlider: Bool = false) {
        editToolBarView.isHidden = hide
        downloadView.isHidden = true//hide
        backButtonView.isHidden = hide
        deleteView.isHidden = true//hideColorSlider ? true : hide
        collectionView.isHidden = (storyEditors.count > 1) ? hide : true
        slideShowCollectionView.isHidden = !isSlideShow ? true : hide
        slideShowPreviewView.isHidden = !isSlideShow ? true : hide
        self.slideShowFillAuto.isHidden = !isSlideShow ? true : hide
        doneButtonView.isHidden = !hide
        closeDoneButtonView.isHidden = !hide
        showHideView.isHidden = !doneButtonView.isHidden
        colorSlider.isHidden = hideColorSlider ? true : !hide
    }
    
    func hideCropPopView(isHide: Bool) {
        cropPopupBlurView.isHidden = isHide
        croppedAlertView.isHidden = isHide
        isVideoPlay ? pauseVideo() : playVideo()
    }
    
    func changeCroppedMediaFrame(image: UIImage, croppedUrl: URL) {
        self.croppedImage = image
        self.croppedUrl = croppedUrl
    }
    
    func showAlertForUpgradeSubscription() {
        let cameraModeNames = "\(R.string.localizable.fastsloW()),\(R.string.localizable.capturE()),\(R.string.localizable.pic2Art())"
        let alert = UIAlertController(title: Constant.Application.displayName, message: R.string.localizable.upgradeSubscriptionWarning(cameraModeNames), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.no(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: R.string.localizable.yes(), style: .default, handler: { (_) in
            if let subscriptionVC = R.storyboard.subscription.subscriptionContainerViewController() {
                self.navigationController?.pushViewController(subscriptionVC, animated: true)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func hideToolTipView(isHide: Bool) {
        hideToolTipView.isHidden = isHide
    }
    
    func hideSocialMediaShareView(isHidden: Bool) {
        socialMediaMainView.isHidden = isHidden
    }
    
    func showAlertForWatermarkShowHide() {
        let alert = UIAlertController(title: Constant.Application.displayName, message: R.string.localizable.updateDefaultSettings(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.oK(), style: .default, handler: { (_) in
            Defaults.shared.fastestEverWatermarkSetting = self.isFastesteverWatermarkShow ?  .show : .hide
            Defaults.shared.appIdentifierWatermarkSetting = self.isAppIdentifierWatermarkShow ? .show : .hide
        }))
        alert.addAction(UIAlertAction(title: R.string.localizable.later(), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func hideWatermarkView(isHide: Bool) {
        if cameraMode == .pic2Art {
            waterMarkGIFView.isHidden = true
        } else {
            waterMarkGIFView.isHidden = false
        }
        cropPopupBlurView.isHidden = isHide
        watermarkOptionsView.isHidden = isHide
    }
    
    func showEditTooltip() {
        editTooltipView.isHidden = false
        imgEditTooltip?.first?.alpha = 1
        lblEditTooltip.text = editTooltipText.first
    }
    
    func hideShowDiscardVideoPopup(shouldShow: Bool) {
        self.discardVideoPopupView.isHidden = !shouldShow
    }
    
    @IBAction func didChangeUISliderValue(_ sender: UISlider) {
        guard let asset = currentVideoAsset else {
            return
        }
        let currentTime = CMTimeMakeWithSeconds(Float64(sender.value), preferredTimescale: asset.duration.timescale)
        storyEditors[currentStoryIndex].seekTime = currentTime
        self.playbackTimechecker(sliderValue:sender.value)
//        self.videoProgressBar.currentTime = sender.value
        self.videoProgressBar.value = sender.value
        self.storyProgressBar.currentTime = TimeInterval(sender.value)
    }
    
    
}

extension StoryEditorViewController: StickerDelegate {
    
    func didSelectSticker(_ sticker: StorySticker) {
        storyEditors[currentStoryIndex].addSticker(sticker)
        self.needToExportVideo()
    }
    
}

extension StoryEditorViewController {

    @IBAction func decorClicked(_ sender: UIButton) {
        guard let stickerViewController = R.storyboard.storyEditor.stickerViewController() else {
            return
        }
        stickerViewController.delegate = self
        present(stickerViewController, animated: true, completion: nil)
    }
    
    @IBAction func snapDecorClicked(_ sender: UIButton) {
        Defaults.shared.callHapticFeedback(isHeavy: false)
        guard let bitmojiStickerPickerViewController = R.storyboard.storyEditor.bitmojiStickerPickerViewController() else {
            return
        }
        bitmojiStickerPickerViewController.completionBlock = { [weak self] (string, image) in
            guard let `self` = self else { return }
            guard let stickerImage = image else {
                return
            }
            self.isVideoModified = true
            self.didSelectSticker(StorySticker(image: stickerImage, type: .image))
            self.needToExportVideo()
            self.isSettingsChange = true
        }
        present(bitmojiStickerPickerViewController, animated: true, completion: nil)
    }
    
    @IBAction func textClicked(_ sender: UIButton) {
        storyEditors[currentStoryIndex].startTextEditing()
        storyEditors[currentStoryIndex].startEditingAction = { [weak self] (isEditing, textColor) in
            guard let `self` = self else { return }
            self.hideToolBar(hide: isEditing)
            self.colorSlider.color = textColor
            self.colorSlider.layoutSubviews()
        }
        hideToolBar(hide: true)
        colorSlider.color = storyEditors[currentStoryIndex].textColor
        colorSlider.layoutSubviews()
        self.isSettingsChange = true
        Defaults.shared.callHapticFeedback(isHeavy: false)
    }
    
    @IBAction func drawClicked(_ sender: UIButton) {
        storyEditors[currentStoryIndex].startDrawing()
        hideToolBar(hide: true)
        colorSlider.color = storyEditors[currentStoryIndex].drawColor
        colorSlider.layoutSubviews()
    }
    
    @IBAction func addMusicClicked(_ sender: UIButton) {
        let addNewMusicVC = R.storyboard.photoEditor.musicPickerVC()!
        addNewMusicVC.selectedURL = self.slideShowAudioURL
        addNewMusicVC.finishAddMusicBlock = { [weak self] (fileUrl, success) in
            guard let `self` = self else { return }
            self.slideShowAudioURL = success ? fileUrl : nil
            let tintColor = success ? ApplicationSettings.appPrimaryColor : ApplicationSettings.appWhiteColor
            self.addMusicButton.tintColor = tintColor
            self.addMusicLabel.textColor = tintColor
        }
        
        self.navigationController?.pushViewController(addNewMusicVC, animated: true)
    }

    @IBAction func soundClicked(_ sender: UIButton) {
        isVideoModified = true
        Defaults.shared.callHapticFeedback(isHeavy: false)
        storyEditors[currentStoryIndex].isMuted = !storyEditors[currentStoryIndex].isMuted
        Defaults.shared.isEditSoundOff = storyEditors[currentStoryIndex].isMuted
        self.needToExportVideo()
        let soundIcon = storyEditors[currentStoryIndex].isMuted ? R.image.storySoundOff() : R.image.storySoundOn()
        isCurrentAssetMuted = storyEditors[currentStoryIndex].isMuted ? true : false
        soundButton.setImage(soundIcon, for: .normal)
    }
    
    @IBAction func mergeVideosClicked(_ sender: UIButton) {
        let mergeVC: MergeVideoVC = R.storyboard.videoTrim.mergeVideoVC()!
        
        var filteredMedias: [StoryEditorMedia] = []
        for editor in storyEditors {
            if case StoryEditorType.video(_, _) = editor.type {
                filteredMedias.append(StoryEditorMedia(type: editor.type))
            } else {
                filteredImagesStory.append(StoryEditorMedia(type: editor.type))
            }
        }
        
        mergeVC.videoUrls = filteredMedias
        mergeVC.doneHandler = { [weak self] urls in
            guard let `self` = self else {
                return
            }
            self.currentStoryIndex = 0
            self.medias.removeAll()
            
            for item in urls {
                guard let storyEditorMedia = item.copy() as? StoryEditorMedia else {
                    return
                }
                self.medias.append(storyEditorMedia)
            }
            self.isTrim = false
//            self.isVideoModified = true
            self.medias.append(contentsOf: self.filteredImagesStory)
            if !self.storyEditorsSubviews.isEmpty {
                self.storyEditorsSubviews.removeAll()
            }
            for storyEditor in self.storyEditors {
                self.storyEditorsSubviews.append(storyEditor)
                storyEditor.removeFromSuperview()
            }
            self.filteredImagesStory.removeAll()
            self.storyEditors.removeAll()
            self.setupFilterViews()
            self.needToExportVideo()
        }
        self.navigationController?.pushViewController(mergeVC, animated: true)
    }
    
    @IBAction func trimClicked(_ sender: UIButton) {
        Defaults.shared.callHapticFeedback(isHeavy: false)
        let trimVC: TrimEditorViewController = R.storyboard.videoTrim.trimEditorViewController()!
        trimVC.isFromSplitView = false
        var filteredMedias: [StoryEditorMedia] = []
        for editor in storyEditors {
            if case StoryEditorType.video(_, _) = editor.type {
                filteredMedias.append(StoryEditorMedia(type: editor.type))
            } else {
                filteredImagesStory.append(StoryEditorMedia(type: editor.type))
            }
        }
        
        trimVC.videoUrls = filteredMedias
        trimVC.doneHandler = { [weak self] urls in
            guard let `self` = self else {
                return
            }
            self.currentStoryIndex = 0
            self.medias.removeAll()
            
            for (storyIndex, item) in urls.enumerated() {
                let newIndex = storyIndex + 1
                guard let storyEditorMedia = item.copy() as? StoryEditorMedia else {
                    return
                }
                storyEditorMedia.storyIndex = newIndex
                self.medias.append(storyEditorMedia)
            }
            self.isVideoModified = true
            self.isTrim = true
            self.medias.append(contentsOf: self.filteredImagesStory)
            if !self.storyEditorsSubviews.isEmpty {
                self.storyEditorsSubviews.removeAll()
            }
            for storyEditor in self.storyEditors {
                self.storyEditorsSubviews.append(storyEditor)
                storyEditor.removeFromSuperview()
            }
            self.filteredImagesStory.removeAll()
            self.storyEditors.removeAll()
            self.setupFilterViews()
            self.needToExportVideo()
        }
        self.navigationController?.pushViewController(trimVC, animated: true)
    }
    
    @IBAction func shareOnMediaClicked(_ sender: UIButton) {
        playPauseButton.isSelected = false
        self.playPauseButtonClick(playPauseButton)
        self.socialMediaMainView.isHidden = false
    
    }
    
    @IBAction func didTapSplitButtonClicked(_ sender: UIButton) {
        Defaults.shared.callHapticFeedback(isHeavy: false)
        let trimVC: TrimEditorViewController = R.storyboard.videoTrim.trimEditorViewController()!
        trimVC.isFromSplitView = true
        var filteredMedias: [StoryEditorMedia] = []
        for editor in storyEditors {
            if case StoryEditorType.video(_, _) = editor.type {
                filteredMedias.append(StoryEditorMedia(type: editor.type))
            } else {
                filteredImagesStory.append(StoryEditorMedia(type: editor.type))
            }
        }
        
        trimVC.videoUrls = filteredMedias
        trimVC.doneHandler = { [weak self] urls in
            guard let `self` = self else {
                return
            }
            self.currentStoryIndex = 0
            self.medias.removeAll()
            
            for (storyIndex, item) in urls.enumerated() {
                var newIndex = storyIndex + 1
                guard let storyEditorMedia = item.copy() as? StoryEditorMedia else {
                    return
                }
                storyEditorMedia.storyIndex = newIndex
                self.medias.append(storyEditorMedia)
            }
            self.isTrim = true
            self.isVideoModified = true
            self.medias.append(contentsOf: self.filteredImagesStory)
            if !self.storyEditorsSubviews.isEmpty {
                self.storyEditorsSubviews.removeAll()
            }
            for storyEditor in self.storyEditors {
                self.storyEditorsSubviews.append(storyEditor)
                storyEditor.removeFromSuperview()
            }
            self.filteredImagesStory.removeAll()
            self.storyEditors.removeAll()
            self.setupFilterViews()
            self.needToExportVideo()
        }
        self.navigationController?.pushViewController(trimVC, animated: true)
    }
    
    
    
    @IBAction func omitClicked(_ sender: UIButton) {
        Defaults.shared.callHapticFeedback(isHeavy: false)
        let trimVC: OmitEditorViewController = R.storyboard.videoTrim.omitEditorViewController()!
        
        var filteredMedias: [StoryEditorMedia] = []
        for editor in storyEditors {
            if case StoryEditorType.video(_, _) = editor.type {
                filteredMedias.append(StoryEditorMedia(type: editor.type))
            } else {
                filteredImagesStory.append(StoryEditorMedia(type: editor.type))
            }
        }
        
        trimVC.videoUrls = filteredMedias
        trimVC.doneHandler = { [weak self] urls in
            guard let `self` = self else {
                return
            }
            self.currentStoryIndex = 0
            self.medias.removeAll()
            
            for item in urls {
                guard let storyEditorMedia = item.copy() as? StoryEditorMedia else {
                    return
                }
                self.medias.append(storyEditorMedia)
            }
            self.isTrim = true
            self.isVideoModified = true
            self.medias.append(contentsOf: self.filteredImagesStory)
            if !self.storyEditorsSubviews.isEmpty {
                self.storyEditorsSubviews.removeAll()
            }
            for storyEditor in self.storyEditors {
                self.storyEditorsSubviews.append(storyEditor)
                storyEditor.removeFromSuperview()
            }
            self.filteredImagesStory.removeAll()
            self.storyEditors.removeAll()
            self.setupFilterViews()
            self.needToExportVideo()
        }
        self.navigationController?.pushViewController(trimVC, animated: true)
    }
    @IBAction func timeSpeedClicked(_ sender: UIButton) {
        guard let currentAsset = currentVideoAsset else {
            return
        }
        let assetSize = currentAsset.tracks(withMediaType: .video)[0].naturalSize
        if assetSize.height >= 2160 { // 3840 × 2160
            DispatchQueue.runOnMainThread {
                if let loadingView = self.loadingView {
                    loadingView.progressView.setProgress(to: Double(0), withAnimation: true)
                    loadingView.isExporting = true
                    loadingView.shouldDescriptionTextShow = true
                    loadingView.show(on: self.view, completion: {
                        loadingView.cancelClick = { _ in
                            VideoMediaHelper.shared.cancelExporting()
                            loadingView.hide()
                        }
                    })
                }
            }
            
            VideoMediaHelper.shared.compressMovie(asset: currentAsset, filename: String.fileName + ".mp4", quality: VideoQuality.high, deleteSource: true, progressCallback: { [weak self] (progress) in
                guard let `self` = self else {
                    return
                }
                DispatchQueue.runOnMainThread {
                    if let loadingView = self.loadingView {
                        loadingView.progressView.setProgress(to: Double(progress), withAnimation: true)
                    }
                }
            }) { [weak self] url in
                guard let `self` = self else {
                    return
                }
                self.hideLoadingView()
                guard let videoUrl = url else {
                    return
                }
                let currentAsset = AVAsset(url: videoUrl)
                guard currentAsset.duration.seconds > 2.0 else {
                    self.showAlert(alertMessage: R.string.localizable.minimumTwoSecondsVideoRequiredToChangeSpeed())
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    self.showHistogram(currentAsset: currentAsset)
                }
            }
        } else {
            self.showHistogram(currentAsset: currentAsset)
        }
    }
    
    func showHistogram(currentAsset: AVAsset) {
        guard let histroGramVC = R.storyboard.photoEditor.histroGramVC() else {
            return
        }
        histroGramVC.currentAsset = currentAsset
        histroGramVC.completionHandler = { [weak self] url in
            guard let `self` = self else {
                return
            }
            if case let StoryEditorType.video(image, _) = self.storyEditors[self.currentStoryIndex].type {
                self.storyEditors[self.currentStoryIndex].replaceMedia(.video(image, AVAsset(url: url)))
                self.nativeVideoPlayerRefresh()
                self.needToExportVideo()
            }
        }
        self.navigationController?.pushViewController(histroGramVC, animated: false)
    }
    
    @IBAction func pic2ArtClicked(_ sender: UIButton) {
        guard let styleTransferVC = R.storyboard.photoEditor.styleTransferVC() else {
            return
        }
        switch storyEditors[currentStoryIndex].type {
        case let .image(image):
            styleTransferVC.type = .image(image: image)
        case .video:
            break
        }
        styleTransferVC.isSingleImage = isSlideShow
        styleTransferVC.doneHandler = { [weak self] data, currentMode in
            guard let `self` = self else {
                return
            }
            if let filteredImage = data as? UIImage {
                self.storyEditors[self.currentStoryIndex].replaceMedia(.image(filteredImage))
            }
        }
        self.navigationController?.pushViewController(styleTransferVC, animated: true)
    }

    @IBAction func maskClicked(_ sender: UIButton) {
        guard let imageCropperVC = R.storyboard.photoEditor.imageCropperVC() else {
            return
        }
        switch storyEditors[currentStoryIndex].type {
        case let .image(image):
            imageCropperVC.image = image
        case .video:
            imageCropperVC.image = storyEditors[currentStoryIndex].currentFilteredImage()
        }
        imageCropperVC.delegate = self
        self.navigationController?.pushViewController(imageCropperVC, animated: true)
    }
    
    @IBAction func cropClicked(_ sender: UIButton) {
        Defaults.shared.callHapticFeedback(isHeavy: false)
        var cropViewController: CropViewController
        switch storyEditors[currentStoryIndex].type {
        case let .image(image):
            cropViewController = CropViewController(image: image)
        case let .video(_, asset):
            cropViewController = CropViewController(avAsset: asset)
        }
        cropViewController.delegate = self
        cropViewController.modalPresentationStyle = .fullScreen
        present(cropViewController, animated: true)
    }

    @IBAction func editClicked(_ sender: UIButton) {
        var currentImage: UIImage?
        switch storyEditors[currentStoryIndex].type {
        case let .image(image):
            currentImage = image.resizeImageWith(newSize: CGSize.init(width: 750, height: 1334))
        default:
            break
        }
        var pixelEditViewController: PixelEditViewController?
        if let editingStack = editingStack {
            pixelEditViewController = PixelEditViewController.init(editingStack: editingStack)
        } else if let image = currentImage {
            pixelEditViewController = PixelEditViewController.init(image: image)
        }
        if let controller = pixelEditViewController {
            controller.delegate = self
            let navigationController = UINavigationController(rootViewController: controller)
            navigationController.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    @IBAction func filterApplyClicked(_ sender: UIButton) {
        sender.startPulse(with: ApplicationSettings.appPrimaryColor, animation: YGPulseViewAnimationType.radarPulsing)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            sender.stopPulse()
        }
        sender.press(completion: { (_) in
            
        })
        storyEditors[currentStoryIndex].applyFilter()
    }
    
    @IBAction func specificBoomerangClicked(_ sender: UIButton) {
        guard case let StoryEditorType.video(_, avAsset) = self.storyEditors[self.currentStoryIndex].type,
        let specificBoomerangViewController = R.storyboard.storyEditor.specificBoomerangViewController() else {
            return
        }
        
        guard avAsset.duration.seconds > 3.0 else {
            self.showAlert(alertMessage: R.string.localizable.minimumThreeSecondsVideoRequiredToSpecificBoomerang())
            return
        }
        storyEditors[currentStoryIndex].pause()
        specificBoomerangViewController.currentAsset = avAsset
        specificBoomerangViewController.delegate = self
        self.navigationController?.pushViewController(specificBoomerangViewController, animated: true)
    }
    
    @IBAction func undoDrawClicked(_ sender: Any) {
        storyEditors[currentStoryIndex].undoDraw()
    }
    
    @IBAction func backClicked(_ sender: UIButton) {
        if isPic2ArtApp || cameraMode == .pic2Art {
            discardPopUpMessageLabel.text = "Are you sure you want to discard your Pic2Art?"
        } else {
            discardPopUpMessageLabel.text = "Are you sure you want to discard your video?"
        }
        if Defaults.shared.isShowAllPopUpChecked == true {
            self.hideShowDiscardVideoPopup(shouldShow: true)
        } else if Defaults.shared.isDiscardVideoPopupHide == false {
            self.hideShowDiscardVideoPopup(shouldShow: true)
        } else {
            Defaults.shared.postViralCamModel = nil
            if isPic2ArtApp || cameraMode == .pic2Art {
                
                if let controllers = navigationController?.viewControllers,
                    controllers.count > 0 {
                    for controller in controllers {
                        if let storyCameraVC = controller as? StoryCameraViewController {
                          //  navigationController?.popToViewController(storyCameraVC, animated: true)
                            guard let storyCamVC = R.storyboard.storyCameraViewController.storyCameraViewController() else { return }
                            storyCamVC.isfromPicsArt = true
                            self.navigationController?.pushViewController(storyCamVC, animated: true)
                            return
                        }
                    }
                }
            }
            navigationController?.popViewController(animated: true)
            Defaults.shared.callHapticFeedback(isHeavy: false)
        }
    }
    
    @IBAction func doneClicked(_ sender: UIButton) {
        Defaults.shared.callHapticFeedback(isHeavy: false,isImportant: true)
        storyEditors[currentStoryIndex].endDrawing()
        storyEditors[currentStoryIndex].endTextEditing()
        hideToolBar(hide: false)
    }
    
    @IBAction func closeDoneClicked(_ sender: UIButton) {
        Defaults.shared.callHapticFeedback(isHeavy: false)
        storyEditors[currentStoryIndex].endDrawing()
        storyEditors[currentStoryIndex].endTextEditing()   //cancelTextEditing()
        hideToolBar(hide: false)
    }
    @IBAction func saveShareClicked(_ sender: UIButton) {
        Defaults.shared.callHapticFeedback(isHeavy: false,isImportant: true)
        referType = storyEditors[currentStoryIndex].referType
        imageVideoExport(isDownload: true,isFromDoneTap:false)
        btnSocialMediaBackClick(sender)
        /*if Defaults.shared.isVideoSavedAfterRecording{
            Defaults.shared.callHapticFeedback(isHeavy: false,isImportant: true)
            referType = storyEditors[currentStoryIndex].referType
            imageVideoExport(isDownload: true,isFromDoneTap:true)
        }else{
            self.navigationController?.popViewController(animated: true)
        } */
    }
  
    @IBAction func downloadClicked(_ sender: UIButton) {
        if isPic2ArtApp || cameraMode == .pic2Art {
            handlePicToArtSave()
        } else {
            handleQuickCamVideoSave()
        }
        
        //pop to recording screen if auto save is off
//        let isVideoModify = self.isVideoModified
//        let isVideoRecord = self.isVideoRecorded
//        if Defaults.shared.isAutoSavePic2Art == false {
//            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//
//            alert.addAction(UIAlertAction(title: R.string.localizable.saveVideoThisTimeOnly(), style: .default, handler:{(UIAlertAction)in
//                Defaults.shared.callHapticFeedback(isHeavy: false,isImportant: true)
//                self.referType = self.storyEditors[self.currentStoryIndex].referType
//                self.imageVideoExport(isDownload: true,isFromDoneTap:true)
//            }))
//
//            alert.addAction(UIAlertAction(title: R.string.localizable.alwaysSaveEditedVideos(), style: .default , handler:{ (UIAlertAction)in
//                self.saveVideoInQuickCamFolder()
//            }))
//
//            /*alert.addAction(UIAlertAction(title: R.string.localizable.discardVideoThisTimeOnly(), style: .default , handler:{ (UIAlertAction)in
//                self.navigationController?.popViewController(animated: true)
//            }))*/
//
//            alert.addAction(UIAlertAction(title: R.string.localizable.cancel(), style: .cancel, handler:{ (UIAlertAction)in
//            }))
//
//            //uncomment for iPad Support
//            //alert.popoverPresentationController?.sourceView = self.view
//
//            self.present(alert, animated: true, completion: {
//                print("completion block")
//            })
//        }
//        else {
//            //if isVideoSavedAfterEditing is on
//            if Defaults.shared.isVideoSavedAfterRecording == false {
//                //isVideoSavedAfterRecording is false
////                if isVideoModify == false {
////                    if isVideoRecord {
////                        //source camera
////                        self.saveVideoInQuickCamFolder()
////                    } else {
////                        //source gallery
////                        let alert = UIAlertController(title: "", message: R.string.localizable.savingWillCreateAnIdenticalCopy(), preferredStyle: .actionSheet)
////
////                        alert.addAction(UIAlertAction(title: R.string.localizable.oK(), style: .default , handler:{ (UIAlertAction)in
////                            self.saveVideoInQuickCamFolder()
////                        }))
////
////                        alert.addAction(UIAlertAction(title: R.string.localizable.cancel(), style: .default , handler:{ (UIAlertAction)in
////                            self.navigationController?.popViewController(animated: true) //confirm once with Krushali
////                        }))
////
////                        self.present(alert, animated: true, completion: {
////                            print("completion block")
////                        })
////                    }
////                }
////                else {
//                    // videoModified is true
//                    self.saveVideoInQuickCamFolder()
////                }
//            }
//            else {
//                //isVideoSavedAfterRecording is true
//                if isVideoModify == false {
//                    if isVideoRecord {
//                        self.navigationController?.popViewController(animated: true) //confirm once with Krushali
//                    } else {
//                        //video from gallery
//                        self.navigationController?.popViewController(animated: true) //confirm once with Krushali
//                    }
//                }
//                else {
//                    // videoModified is true
//                    self.saveVideoInQuickCamFolder()
//                }
//            }
//        }
    }
    
    func handlePicToArtSave() {
        if Defaults.shared.isAutoSavePic2Art == false {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            alert.addAction(UIAlertAction(title: R.string.localizable.savePic2artThisTimeOnly(), style: .default, handler:{(UIAlertAction)in
                Defaults.shared.callHapticFeedback(isHeavy: false,isImportant: true)
                self.referType = self.storyEditors[self.currentStoryIndex].referType
                self.imageVideoExport(isDownload: true,isFromDoneTap:true)
            }))
            
            alert.addAction(UIAlertAction(title: R.string.localizable.alwaysSaveEditedPic2art(), style: .default , handler:{ (UIAlertAction)in
                self.savePic2ArtInQuickCamFolder()
            }))

            alert.addAction(UIAlertAction(title: R.string.localizable.cancel(), style: .cancel, handler:{ (UIAlertAction)in
            }))
            
            self.present(alert, animated: true, completion: {
                print("completion block")
            })
        } else {
            Defaults.shared.callHapticFeedback(isHeavy: false,isImportant: true)
            self.referType = self.storyEditors[self.currentStoryIndex].referType
            self.imageVideoExport(isDownload: true,isFromDoneTap:true)
        }
       /* else {
            if Defaults.shared.isVideoSavedAfterRecording == false {
                    self.saveVideoInQuickCamFolder()
            }
            else {
                self.navigationController?.popViewController(animated: true) //confirm once with Krushali
            }
        }*/
    }
    
    func handleQuickCamVideoSave() {
        if Defaults.shared.isVideoSavedAfterRecording == false {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            alert.addAction(UIAlertAction(title: R.string.localizable.saveVideoThisTimeOnly(), style: .default, handler:{(UIAlertAction)in
                Defaults.shared.callHapticFeedback(isHeavy: false,isImportant: true)
                self.referType = self.storyEditors[self.currentStoryIndex].referType
                self.imageVideoExport(isDownload: true,isFromDoneTap:true)
            }))
            
            alert.addAction(UIAlertAction(title: R.string.localizable.alwaysSaveEditedVideos(), style: .default , handler:{ (UIAlertAction)in
                self.saveVideoInQuickCamFolder()
            }))

            alert.addAction(UIAlertAction(title: R.string.localizable.cancel(), style: .cancel, handler:{ (UIAlertAction)in
            }))
            
            self.present(alert, animated: true, completion: {
                print("completion block")
            })
        }
        else {
            if Defaults.shared.isVideoSavedAfterRecording == false {
                    self.saveVideoInQuickCamFolder()
            }
            else {
                self.navigationController?.popViewController(animated: true) //confirm once with Krushali
            }
        }
    }
    
    func savePic2ArtInQuickCamFolder() {
        Defaults.shared.isAutoSavePic2Art = true
        Defaults.shared.callHapticFeedback(isHeavy: false,isImportant: true)
        self.referType = self.storyEditors[self.currentStoryIndex].referType
        self.imageVideoExport(isDownload: true,isFromDoneTap:true)
    }
    func saveVideoInQuickCamFolder() {
        Defaults.shared.isVideoSavedAfterEditing = true
        Defaults.shared.callHapticFeedback(isHeavy: false,isImportant: true)
        self.referType = self.storyEditors[self.currentStoryIndex].referType
        self.imageVideoExport(isDownload: true,isFromDoneTap:true)
    }
    
    @IBAction func slideShowAutoFillClicked(_ sender: UIButton) {
        guard slideShowFillAuto.isUserInteractionEnabled else {
            return
        }
        var imageData: [UIImage] = []
        for media in selectedSlideShowMedias {
            if case let .image(image) = media.type,
                image != UIImage() {
                imageData.append(image)
            }
        }
        var minimumValue: Int = 10
        switch Defaults.shared.appMode {
        case .basic:
            minimumValue = 10
        case .advanced:
            minimumValue = 20
        case .professional:
            minimumValue = 20
        default:
            minimumValue = 10
        }
        
        for (_, storyEditor) in storyEditors.enumerated() {
            switch storyEditor.type {
            case .image:
                DispatchQueue.runOnMainThread {
                    if let image = storyEditor.updatedThumbnailImage() {
                        imageData.append(image)
                    }
                }
            case .video(_, _):
                break
            }
        }
        
        DispatchQueue.runOnMainThread {
            for (index, media) in self.selectedSlideShowMedias.enumerated() {
                if index < minimumValue, index < imageData.count {
                    media.type = .image(imageData[index])
                }
            }
            self.slideShowCollectionView.reloadData()
            self.slideShowFillAuto.alpha = 0.7
            self.slideShowFillAuto.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func previewSlideShowClicked(_ sender: UIButton) {
        self.saveSlideShow(success: { [weak self] (exportURL) in
            guard let `self` = self else {
                return
            }
            DispatchQueue.runOnMainThread {
                let player = AVPlayer(url: exportURL)
                let playerController = AVPlayerViewController()
                playerController.player = player
                self.present(playerController, animated: true) {
                    player.play()
                }
            }
        }, failure: { (error) in
            print(error)
        })
    }
    
    func imageVideoExport(isDownload: Bool = false, isFromDoneTap: Bool = false,type: SocialShare = .facebook) {
        if isSlideShow {
            saveSlideShow(success: { [weak self] (exportURL) in
                guard let `self` = self else {
                    return
                }
                self.slideShowExportedURL = exportURL
                if isDownload {
                    DispatchQueue.runOnMainThread {
                        self.saveImageOrVideoInGallery(exportURL: exportURL)
                        if isFromDoneTap{
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                } else {
                    DispatchQueue.runOnMainThread {
                        if type == .youtube {
                            self.checkYoutubeAuthentication(exportURL)
                        }else if type == .more {
                            self.shareWithActivity(url:exportURL)
                        } else {
                            SocialShareVideo.shared.shareVideo(url: exportURL, socialType: type, referType: self.referType)
                        }
                        self.pauseVideo()
                    }
                }
            }, failure: { (error) in
                print(error)
            })
        } else {
            switch storyEditors[currentStoryIndex].type {
            case .image:
                if let image = storyEditors[currentStoryIndex].updatedThumbnailImage() {
                    if isDownload {
                        if  cameraMode == .pic2Art && (self.isFastesteverWatermarkShow || self.isAppIdentifierWatermarkShow || self.isPublicDisplaynameWatermarkShow) {
                            self.mergeImageAndTextWatermark(image: image)
                            self.view.makeToast(R.string.localizable.photoSaved())
                        } else {
                            self.saveImageOrVideoInGallery(image: image)
                        }
                        if isFromDoneTap{
                            guard let storyCamVC = R.storyboard.storyCameraViewController.storyCameraViewController() else { return }
                            storyCamVC.isfromPicsArt = true
                            self.navigationController?.pushViewController(storyCamVC, animated: true)
                        }
                    } else {
                        if type == .more {
                            self.shareWithActivity(url:nil,image:image)
                        }else{
                            SocialShareVideo.shared.sharePhoto(image: image, socialType: type, referType: self.referType)
                        }
                        
                    }
                }
            case let .video(_, asset):
                videoExportedURL = nil
                if let exportURL = videoExportedURL, !isDownload, !isSettingsChange {
                    DispatchQueue.runOnMainThread {
                        if type == .youtube {
                            self.checkYoutubeAuthentication(exportURL)
                        }else if type == .more {
                            self.shareWithActivity(url:exportURL)
                        }else {
                            SocialShareVideo.shared.shareVideo(url: exportURL, socialType: type, referType: self.referType)
                        }
                        self.pauseVideo()
                        self.isVideoPlay = true
                    }
                } else {
                    self.isSettingsChange = false
                    if type == .more {
                        guard let asset = currentVideoAsset else { return }

                        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
                            print("Could not create AVAssetExportSession")
                            return
                        }

                        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                    let outputURL = documentsURL.appendingPathComponent("\(UUID().uuidString).mp4")

                        exportSession.outputURL = outputURL
                        exportSession.outputFileType = AVFileType.mp4
                        exportSession.shouldOptimizeForNetworkUse = true

                        exportSession.exportAsynchronously {
                            print("***************")
                            print(outputURL)
                            print("***************")
                            DispatchQueue.main.async {
                                self.shareWithActivity(url:outputURL)
                            }
                        }

                    } else {
                        self.exportViewWithURL(asset, type: type) { [weak self] url in
                            guard let `self` = self else { return }
                            
                            if let exportURL = url {
                                self.videoExportedURL = exportURL
                                if isDownload {
                                    DispatchQueue.runOnMainThread {
                                        self.saveImageOrVideoInGallery(exportURL: exportURL)
                                        if isFromDoneTap{
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                    }
                                } else {
                                    DispatchQueue.runOnMainThread {
                                        self.socialShareExportURL = exportURL
                                        if type == .youtube {
                                            self.checkYoutubeAuthentication(exportURL)
                                        }else if type == .more {
                                            self.shareWithActivity(url:exportURL)
                                        } else {
                                            SocialShareVideo.shared.shareVideo(url: exportURL, socialType: type, referType: self.referType)
                                        }
                                        self.pauseVideo()
                                        self.isVideoPlay = true
                                    }
                                }
                            }else{
                                if isFromDoneTap{
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func checkYoutubeAuthentication(_ url: URL) {
        if GoogleManager.shared.isUserLogin {
            self.getUserToken(url)
        } else {
            GoogleManager.shared.login(controller: self, complitionBlock: { [weak self] (userData, error) in
                guard let `self` = self else {
                    return
                }
                self.getUserToken(url)
            }) { (_, _) in
                
            }
        }
    }
    
    func getUserToken(_ url: URL) {
        GoogleManager.shared.getUserToken { [weak self] (token) in
            guard let `self` = self else {
                return
            }
            guard let token = token else {
                return
            }
            self.dismiss(animated: true, completion: {
                if let youTubeUploadVC = R.storyboard.youTubeUpload.youTubeUploadViewController() {
                    youTubeUploadVC.videoUrl = url
                    youTubeUploadVC.token = token
                    let navYouTubeUpload = UINavigationController(rootViewController: youTubeUploadVC)
                    navYouTubeUpload.navigationBar.isHidden = true
                    if let visibleViewController = Utils.appDelegate?.window?.visibleViewController() {
                        visibleViewController.present(navYouTubeUpload, animated: true)
                    }
                }
            })
        }
    }
    
    func downloadViewGesture() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureRecognizer(_:)))
        downloadView.isUserInteractionEnabled = true
        longPressGestureRecognizer.minimumPressDuration = 0.5
        downloadView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc internal func handleLongPressGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            downloadAllImageVideo()
        default:
            break
        }
    }
    
    func downloadAllImageVideo() {
        let dispatchGroup = DispatchGroup()
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        let exportQueue = DispatchQueue(label: "com.queue.videoQueue")
        
        for (index, storyEditor) in storyEditors.enumerated() {
            dispatchGroup.enter()
            exportQueue.async {
                switch storyEditor.type {
                case .image:
                    DispatchQueue.runOnMainThread {
                        if let image = self.storyEditors[index].updatedThumbnailImage() {
                            self.saveImageOrVideoInGallery(image: image)
                            dispatchGroup.leave()
                        }
                    }
                case let .video(_, asset):
                    DispatchQueue.runOnMainThread {
                        self.exportViewWithURL(asset, index: self.storyEditors.count > 1 ? index : nil) { [weak self] url in
                            guard let `self` = self else { return }
                            if let exportURL = url {
                                self.videoExportedURL =  exportURL
                                DispatchQueue.runOnMainThread {
                                    self.saveImageOrVideoInGallery(exportURL: exportURL)
                                    dispatchSemaphore.signal()
                                    dispatchGroup.leave()
                                }
                            }
                        }
                    }
                    dispatchSemaphore.wait()
                }
            }
        }
        
        dispatchGroup.notify(queue: exportQueue, execute: {
            print("Download All Story")
        })
    }
    
    func mergeImageAndTextWatermark(image: UIImage? = nil) {
        if let saveImage = image {
            UIGraphicsBeginImageContextWithOptions(imgFastestEverWatermark.bounds.size, false, 0)
            imgFastestEverWatermark.drawHierarchy(in: imgFastestEverWatermark.bounds, afterScreenUpdates: true)
            let imageWithFatestWatermark = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            UIGraphicsBeginImageContextWithOptions(userNameLabelWatermark.bounds.size, false, 0)
            userNameLabelWatermark.drawHierarchy(in: userNameLabelWatermark.bounds, afterScreenUpdates: true)
            let imageWithUsernameWatermark = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            UIGraphicsBeginImageContextWithOptions(imgQuickCamWaterMark.bounds.size, false, 0)
            imgQuickCamWaterMark.drawHierarchy(in: imgQuickCamWaterMark.bounds, afterScreenUpdates: true)
            let imageWithQuickCamWatermark = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            //crate a uiimage from the current context and save it to camera roll.
            UIGraphicsBeginImageContextWithOptions(saveImage.size, false, 0)
            saveImage.draw(in: CGRect(x: 0, y: 0,
                                      width: saveImage.size.width, height: saveImage.size.height))
            
            if self.isFastesteverWatermarkShow {
                let fastestWaterMarkFrame = CGRect(x: imgFastestEverWatermark.frame.origin.x, y: imgFastestEverWatermark.frame.origin.y - imgFastestEverWatermark.frame.height, width: imgFastestEverWatermark.frame.width, height: imgFastestEverWatermark.frame.height)
                
                imageWithFatestWatermark?.draw(in: fastestWaterMarkFrame)
            }
            
            let usernameWaterMarkFrame = CGRect(x: userNameLabelWatermark.frame.origin.x, y: userNameLabelWatermark.frame.origin.y - userNameLabelWatermark.frame.height - 25, width: userNameLabelWatermark.frame.width, height: userNameLabelWatermark.frame.height)
            
            if self.isAppIdentifierWatermarkShow {
                let quickCamWaterMarkFrame = CGRect(x: imgQuickCamWaterMark.frame.origin.x, y: imgQuickCamWaterMark.frame.origin.y - imgQuickCamWaterMark.frame.height, width: imgQuickCamWaterMark.frame.width, height: imgQuickCamWaterMark.frame.height)
                
                imageWithUsernameWatermark?.draw(in: usernameWaterMarkFrame)
                imageWithQuickCamWatermark?.draw(in: quickCamWaterMarkFrame)
            }
            if self.isPublicDisplaynameWatermarkShow {
                imageWithUsernameWatermark?.draw(in: usernameWaterMarkFrame)
            }
            
            let exportImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            UIImageWriteToSavedPhotosAlbum(exportImage ?? UIImage(), nil, nil, nil)
        }
    }
    
    func saveImageOrVideoInGallery(image: UIImage? = nil, exportURL: URL? = nil) {
        let album = SCAlbum.shared
        album.albumName = "\(Constant.Application.displayName) - \(R.string.localizable.outtakes())"
        
        if let saveImage = image {
            album.save(image: saveImage) { (isSuccess) in
                if isSuccess {
                    DispatchQueue.runOnMainThread { [weak self] in
                        guard let `self` = self else { return }
                        self.view.makeToast(R.string.localizable.photoSaved())
                    }
                } else {
                    DispatchQueue.runOnMainThread { [weak self] in
                        guard let `self` = self else { return }
                        self.view.makeToast(R.string.localizable.pleaseGivePhotosAccessFromSettingsToSaveShareImageOrVideo())
                    }
                }
            }
        } else if let exportURL = exportURL {
            album.saveMovieToLibrary(movieURL: exportURL, completion: { (isSuccess) in
                if isSuccess {
                    DispatchQueue.runOnMainThread { [weak self] in
                        guard let `self` = self else { return }
                        self.view.makeToast(R.string.localizable.videoSaved())
                    }
                } else {
                    DispatchQueue.runOnMainThread { [weak self] in
                        guard let `self` = self else { return }
                        self.view.makeToast(R.string.localizable.pleaseGivePhotosAccessFromSettingsToSaveShareImageOrVideo())
                    }
                }
            })
        }
    }
    
    @IBAction func closeShareClicked(_ sender: UIButton) {
        shareViewHeight.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
            self.blurView.isHidden = true
        })
    }
    
    @IBAction func btnShowHideEditOptionsClick(_ sender: AnyObject) {
        Defaults.shared.callHapticFeedback(isHeavy: false)
        hideSocialMediaShareView(isHidden: true)
        if Defaults.shared.isShowAllPopUpChecked == true {
            hideToolTipView(isHide: Defaults.shared.isToolTipHide)
        } else if !Defaults.shared.isToolTipHide {
            hideToolTipView(isHide: Defaults.shared.isToolTipHide)
        } else {
            isViewEditMode = !isViewEditMode
        }
    }
    
    @objc private func backgroundViewDidTap() {
        popupVC.dismiss()
    }
    
    @IBAction func btnSocialMediaBackClick(_ sender: UIButton) {
        self.socialShareExportURL = nil
        self.socialMediaMainView.isHidden = true
    }
    
    @IBAction func btnSocialMediaDoneClick(_ sender: UIButton) {
        if Defaults.shared.isShowAllPopUpChecked == true {
            self.hideShowDiscardVideoPopup(shouldShow: true)
        } else if Defaults.shared.isDiscardVideoPopupHide == false {
            self.hideShowDiscardVideoPopup(shouldShow: true)
        } else {
            Defaults.shared.postViralCamModel = nil
            if isPic2ArtApp || cameraMode == .pic2Art {
                if let controllers = navigationController?.viewControllers,
                    controllers.count > 0 {
                    for controller in controllers {
                        if let storyCameraVC = controller as? StoryCameraViewController {
                            navigationController?.popToViewController(storyCameraVC, animated: true)
                            return
                        }
                    }
                }
            }
            navigationController?.popViewController(animated: true)
            Defaults.shared.callHapticFeedback(isHeavy: false)
        }
    }
    
    @IBAction func btnSocialMediaShareClick(_ sender: UIButton) {
        self.socialMediaMainView.isHidden = true
        if Defaults.shared.appMode == .free, !(sender.tag == 3) {
            showAlertForUpgradeSubscription()
        } else {
            if SocialShare(rawValue: sender.tag) ?? SocialShare.facebook == .storiCam {
                guard let socialshareVC = R.storyboard.socialCamShareVC.socialCamShareVC() else {
                    return
                }
                
                socialshareVC.btnStoryPostClicked = { [weak self] (selectedIndex) in
                    guard let `self` = self else { return }
                    self.popupVC.dismiss {
                        if selectedIndex == 0 {
                            self.shareSocialMedia(type: .storiCam)
                        } else {
                            self.shareSocialMedia(type: .storiCamPost)
                        }
                    }
                }
                popupVC = STPopupController(rootViewController: socialshareVC)
                popupVC.style = .formSheet
                popupVC.navigationBarHidden = true
                popupVC.transitionStyle = .fade
                popupVC.containerView.roundCorners(corners: .allCorners, radius: 20)
                popupVC.backgroundView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundViewDidTap)))
                popupVC.present(in: self)
            } else {
                if sender.tag == 5 {
                    self.isSettingsChange = true
                    self.isTiktokShare = true
                } else if isTiktokShare {
                    self.isSettingsChange = true
                    self.isTiktokShare = false
                }
                self.shareSocialMedia(type: SocialShare(rawValue: sender.tag) ?? SocialShare.facebook)
                self.view.makeToast(R.string.localizable.linkIsCopiedToClipboard())
                if let channelId = Defaults.shared.currentUser?.channelId {
                    UIPasteboard.general.string = "\(R.string.localizable.checkOutThisCoolNewAppQuickCam()) \(websiteUrl)/\(channelId)"
                }
            }
        }
    }
    
    @IBAction func playPauseButtonClick(_ sender: UIButton) {
        isVideoPlay = !isVideoPlay
        sender.isSelected ? playVideo() : pauseVideo()
    }
    
    func playVideo() {
        guard !isVideoPlay else {
            return
        }
       
        storyEditors[currentStoryIndex].play()
        playPauseButton.isSelected = false
        nativePlayerPlayPauseButton.isSelected = playPauseButton.isSelected
        startPlaybackTimeChecker()
        
    }
    
    func pauseVideo() {
        storyEditors[currentStoryIndex].pause()
        playPauseButton.isSelected = true
        nativePlayerPlayPauseButton.isSelected = playPauseButton.isSelected
        stopPlaybackTimeChecker()
    }
    
    @IBAction func continueClicked(_ sender: UIButton) {
        if isSlideShow {
            saveSlideShow(success: { [weak self] (exportURL) in
                guard let `self` = self else {
                    return
                }
                DispatchQueue.runOnMainThread {
                    self.slideShowExportedURL = exportURL
                    self.tableView.reloadData()
                    self.shareCollectionViewHeight.constant = 0
                    self.shareViewHeight.constant = 570 - (145 - self.shareCollectionViewHeight.constant)
                    UIView.animate(withDuration: 0.5, animations: {
                        self.view.layoutIfNeeded()
                        self.blurView.isHidden = false
                    })
                }
            }, failure: { (error) in
                print(error)
            })
        } else {
            _ = storyEditors[currentStoryIndex].updatedThumbnailImage()
            self.shareCollectionView.reloadData()
            self.tableView.reloadData()
            self.shareCollectionViewHeight.constant = self.collectionView.isHidden ? 0 : 145
            shareViewHeight.constant = 570 - (145 - shareCollectionViewHeight.constant)
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                self.blurView.isHidden = false
            })
        }
    }
    
    @IBAction func ssuButtonClicked(sender: UIButton) {
        if isQuickApp {
            isVideoModified = true
            let followMeStoryShareViews = storyEditors[currentStoryIndex].subviews.filter({ return $0 is FollowMeStoryView })
            if followMeStoryShareViews.count != 1 && currentStoryIndex == 0 {
                self.didSelect(type: QuickCam.SSUTagType.profilePicture, waitingListOptionType: nil, socialShareType: nil, screenType: SSUTagScreen.ssutTypes)
                self.isSettingsChange = true
            }
            if !isShowToolTipView {
                
                openActionSheet()
                isShowToolTipView = true
                UserDefaults.standard.set(isShowToolTipView, forKey: "isShowToolTipView")
            }
            
            
        } else {
            if let ssuTagSelectionViewController = R.storyboard.storyCameraViewController.ssuTagSelectionViewController() {
                ssuTagSelectionViewController.delegate = self
                
                let navigation: UINavigationController = UINavigationController(rootViewController: ssuTagSelectionViewController)
                navigation.isNavigationBarHidden = true
                self.present(navigation, animated: true)
                openActionSheet()
            }
        }
    }
    
    func openActionSheet() {
        if Constant.Connectivity.isConnectedToInternet {
            if let selectLinkVC = R.storyboard.storyEditor.selectLinkViewController() {
//                selectLinkVC.modalPresentationStyle = .fullScreen
                selectLinkVC.modalPresentationStyle = .overCurrentContext
                selectLinkVC.storyEditors = storyEditors
                navigationController?.present(selectLinkVC, animated: true, completion: {
                    selectLinkVC.backgroundView.isUserInteractionEnabled = true
                    selectLinkVC.backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backgroundTapped)))
                })
            }
        }
    }
    
    @objc func backgroundTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func fullScreenButtonClicked(sender: UIButton) {
        if isCropped {
            guard let image = self.croppedImage,
                  let croppedUrl = self.croppedUrl else {
                return
            }
            self.isVideoModified = true
            let storyEditor = storyEditors[currentStoryIndex]
            storyEditor.isCropped = false
            storyEditor.replaceMedia(.video(image, AVAsset(url: croppedUrl)))
            nativeVideoPlayerRefresh()
            self.needToExportVideo()
        }
        self.hideCropPopView(isHide: true)
        Defaults.shared.callHapticFeedback(isHeavy: false)
    }
    
    @IBAction func croppedScreenButtonClicked(sender: UIButton) {
        if isCropped {
            guard let image = self.croppedImage,
                  let croppedUrl = self.croppedUrl else {
                return
            }
            self.isVideoModified = true
            let storyEditor = storyEditors[currentStoryIndex]
            storyEditor.isCropped = false
            storyEditor.replaceMedia(.video(image, AVAsset(url: croppedUrl)))
            nativeVideoPlayerRefresh()
            self.needToExportVideo()
        }
        self.hideCropPopView(isHide: true)
        Defaults.shared.callHapticFeedback(isHeavy: false)
    }
    
    @IBAction func doNotShowAgainButtonClicked(sender: UIButton) {
        Defaults.shared.isShowAllPopUpChecked = false
        btnDoNotShowAgain.isSelected = !btnDoNotShowAgain.isSelected
        Defaults.shared.isToolTipHide = !Defaults.shared.isToolTipHide
    }
    
    @IBAction func okayButtonClicked(sender: UIButton) {
        isViewEditMode = !isViewEditMode
        hideToolTipView(isHide: true)
    }
    
    @IBAction func cancelButtonClicked(sender: UIButton) {
        hideToolTipView(isHide: true)
        Defaults.shared.isToolTipHide = false
        btnDoNotShowAgain.isSelected = Defaults.shared.isToolTipHide
    }
    
    @IBAction func watermarkButtonClicked(sender: UIButton) {
        hideWatermarkView(isHide: false)
    }
    
    @IBAction func watermarkViewCloseButtonClicked(sender: UIButton) {
        hideWatermarkView(isHide: true)
    }
    
    @IBAction func fastesteverWatermarkButtonClicked(sender: UIButton) {
        isVideoModified = true
        Defaults.shared.callHapticFeedback(isHeavy: false)
        isFastesteverWatermarkShow = !isFastesteverWatermarkShow
        btnFastesteverWatermark.isSelected = isFastesteverWatermarkShow
        btnSelectFastesteverWatermark.isSelected = isFastesteverWatermarkShow
        Defaults.shared.fastestEverWatermarkSetting = self.isFastesteverWatermarkShow ? .show : .hide
    }
    
    @IBAction func publicDisplaynameButtonClicked(sender: UIButton) {
        isVideoModified = true
        Defaults.shared.callHapticFeedback(isHeavy: false)
        isPublicDisplaynameWatermarkShow = !isPublicDisplaynameWatermarkShow
        btnSelectPublicDisplaynameWatermark.isSelected = isPublicDisplaynameWatermarkShow
        Defaults.shared.publicDisplaynameWatermarkSetting = self.isPublicDisplaynameWatermarkShow ? .show : .hide
        if (Defaults.shared.appIdentifierWatermarkSetting == .show){
            Defaults.shared.appIdentifierWatermarkSetting = .hide
            isAppIdentifierWatermarkShow = false
            btnSelectAppIdentifierWatermark.isSelected = isAppIdentifierWatermarkShow
        }
    }
    
    @IBAction func appIdentifierWatermarkButtonClicked(sender: UIButton) {
        isVideoModified = true
        Defaults.shared.callHapticFeedback(isHeavy: false)
        isAppIdentifierWatermarkShow = !isAppIdentifierWatermarkShow
        btnAppIdentifierWatermark.isSelected = isAppIdentifierWatermarkShow
        btnSelectAppIdentifierWatermark.isSelected = isAppIdentifierWatermarkShow
        Defaults.shared.appIdentifierWatermarkSetting = self.isAppIdentifierWatermarkShow ? .show : .hide
        if (Defaults.shared.publicDisplaynameWatermarkSetting == .show){
            Defaults.shared.publicDisplaynameWatermarkSetting = .hide
            isPublicDisplaynameWatermarkShow = false
            btnSelectPublicDisplaynameWatermark.isSelected = isPublicDisplaynameWatermarkShow
        }
    }
    
    @IBAction func madeWithGifButtonClicked(sender: UIButton) {
      /*  if Defaults.shared.appMode == .free {
            if let watermarkSettingsVC = R.storyboard.storyCameraViewController.watermarkSettingsViewController() {
                navigationController?.pushViewController(watermarkSettingsVC, animated: true)
            }
        } else {
            isMadeWithGifShow = !isMadeWithGifShow
            btnSelectedMadeWithGif.isSelected = isMadeWithGifShow
        } */
        Defaults.shared.callHapticFeedback(isHeavy: false)
        isMadeWithGifShow = !isMadeWithGifShow
        btnSelectedMadeWithGif.isSelected = isMadeWithGifShow
        Defaults.shared.madeWithGifSetting = self.isMadeWithGifShow ? .show : .hide
    }
    
    @IBAction func watermarkViewOkayButtonClicked(sender: UIButton) {
        Defaults.shared.callHapticFeedback(isHeavy: false)
        Defaults.shared.fastestEverWatermarkSetting = self.isFastesteverWatermarkShow ? .show : .hide
        Defaults.shared.appIdentifierWatermarkSetting = self.isAppIdentifierWatermarkShow ? .show : .hide
        Defaults.shared.madeWithGifSetting = self.isMadeWithGifShow ? .show : .hide
        self.imgFastestEverWatermark.isHidden = !self.isFastesteverWatermarkShow
        if self.isAppIdentifierWatermarkShow {
            self.imgQuickCamWaterMark.isHidden = !self.isAppIdentifierWatermarkShow
            self.userNameLabelWatermark.isHidden = !self.isAppIdentifierWatermarkShow
        }
        if self.isPublicDisplaynameWatermarkShow {
            self.imgQuickCamWaterMark.isHidden = !self.isAppIdentifierWatermarkShow
            self.userNameLabelWatermark.isHidden = !self.isPublicDisplaynameWatermarkShow
        }
        
        hideWatermarkView(isHide: true)
        callSetUserSetting()
        self.isSettingsChange = true
    }
    
    @IBAction func editTooltipSkipButtonClicked(sender: UIButton) {
        editTooltipView.isHidden = true
    }
    
    @IBAction func editTooltipTapView(_ sender: UITapGestureRecognizer) {
        editTooltipCount += 1
        if let imgEditTooltipCount = imgEditTooltip?.count {
            for imageCount in 0...imgEditTooltipCount - 1 {
                if editTooltipCount == imageCount {
                    if imageCount == imgEditTooltipCount - 1 {
                        btnSkipEditTooltip.isHidden = true
                    }
                    imgEditTooltip?[imageCount].alpha = 1
                    lblEditTooltip.text = editTooltipText[imageCount]
                } else {
                    imgEditTooltip?[imageCount].alpha = 0
                }
            }
            if editTooltipCount == imgEditTooltipCount {
                editTooltipView.isHidden = true
            }
        }
    }
    
    @IBAction func doNotShowDiscardVideoButtonClicked(_ sender: UIButton) {
        btnDoNotShowDiscardVideo.isSelected = !btnDoNotShowDiscardVideo.isSelected
        Defaults.shared.isShowAllPopUpChecked = !btnDoNotShowDiscardVideo.isSelected
        isDiscardVideoPopupHide = !isDiscardVideoPopupHide
        Defaults.shared.isDiscardVideoPopupHide = isDiscardVideoPopupHide
    }
    
    @IBAction func discardVideoYesButtonClicked(_ sender: UIButton) {
        hideShowDiscardVideoPopup(shouldShow: false)
        Defaults.shared.postViralCamModel = nil
        if isPic2ArtApp || cameraMode == .pic2Art {
            if let controllers = navigationController?.viewControllers,
                controllers.count > 0 {
                for controller in controllers {
                    if let storyCameraVC = controller as? StoryCameraViewController {
                        //navigationController?.popToViewController(storyCameraVC, animated: true)
                        guard let storyCamVC = R.storyboard.storyCameraViewController.storyCameraViewController() else { return }
                        storyCamVC.isfromPicsArt = true
                        self.navigationController?.pushViewController(storyCamVC, animated: true)
                        return
                    }
                }
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func discardVideoNoButtonClicked(_ sender: UIButton) {
        hideShowDiscardVideoPopup(shouldShow: false)
    }
    
    @IBAction func okayButtonSaveVideoClicked(sender: UIButton) {
        DispatchQueue.main.async {
            self.hideSaveVideoPopupView(isHide: true)
        }
    }
    
    @IBAction func cancelButtonSaveVideoClicked(sender: UIButton) {
        hideSaveVideoPopupView(isHide: true)
    }
    
    func hideSaveVideoPopupView(isHide: Bool) {
        saveVideoPopupView.isHidden = isHide
    }
}

extension StoryEditorViewController: DragAndDropCollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !isSlideShow, collectionView == slideShowCollectionView {
            return 0
        } else if collectionView == slideShowCollectionView {
            return selectedSlideShowMedias.count
        } else if collectionView == self.nativePlayercollectionView {
            return displayKeyframeImages.count
        }
        return storyEditors.count
    }
     
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == slideShowCollectionView {
            guard let storyEditorCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.slideShowStoryCell.identifier, for: indexPath) as? StoryEditorCell else {
                fatalError("Cell with identifier \(R.reuseIdentifier.slideShowStoryCell.identifier) not Found")
            }
            
            switch selectedSlideShowMedias[indexPath.item].type {
            case let .image(image):
                storyEditorCell.imageView.image = image
                storyEditorCell.deleteButton.isHidden = image == UIImage()
                storyEditorCell.deleteButton.tag = indexPath.item
            default:
                break
            }
            storyEditorCell.deleteSlideshowImageHandler = { [weak self] index in
                guard let `self` = self else { return }
                self.selectedSlideShowMedias[index] = StoryEditorMedia(type: .image(UIImage()))
                self.slideShowCollectionView.reloadData()
            }
            return storyEditorCell
        } else if collectionView == shareCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.shareStoryCollectionViewCell.identifier, for: indexPath) as? ShareStoryCollectionViewCell else {
                fatalError("cell with identifier '\(R.reuseIdentifier.shareStoryCollectionViewCell.identifier)' not found")
            }
            let storyEditor = storyEditors[indexPath.item]
            cell.storyImageView.image = storyEditor.thumbnailImage
            cell.storyImageView.layer.borderWidth = storyEditor.isHidden ? 0 : 3
            cell.checkMarkView.isHidden = storyEditor.isHidden
            return cell
        } else if collectionView == self.nativePlayercollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.keyframePickerCollectionViewCell, for: indexPath) else {
                return UICollectionViewCell()
            }
            if !displayKeyframeImages.isEmpty {
                cell.keyframeImage = displayKeyframeImages[indexPath.row]
            }
            return cell
        } else {
            guard let storyEditorCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.storyEditorCell.identifier, for: indexPath) as? StoryEditorCell else {
                fatalError("Cell with identifier \(R.reuseIdentifier.storyEditorCell.identifier) not Found")
            }
            
            let storyEditor = storyEditors[indexPath.item]
            
//            let currentVideoAssest = Float(currentVideoAsset?.duration.seconds ?? 0.0)
            guard let _currentVideoAsset = medias[safe: indexPath.item]?.type else {
                return storyEditorCell
            }
            
            if isTrim == true {
                guard let newIndex = medias[safe: indexPath.item]?.storyIndex else {
                    return storyEditorCell
                }
                
                storyEditorCell.thumbnailNumberLabel.text = "\(newIndex)"
            } else {
                storyEditorCell.thumbnailNumberLabel.text = "\(indexPath.item + 1)"
            }
           
            var avAsset: AVAsset?
            switch _currentVideoAsset {
            case .image:
                break
            case let .video(_, asset):
                avAsset = asset
            }
            let seconds = Float(avAsset?.duration.seconds ?? 0.00)
            let videoLenght = seconds
            storyEditorCell.thumbnailTimeLabel.text = String(format: "%.1f", videoLenght)
            
             //String(format: "%s", avAsset?.duration.seconds)
            storyEditorCell.imageView.image = storyEditor.thumbnailImage
            storyEditorCell.imageView.cornerRadiusV = 5
            storyEditorCell.imageView.layer.borderColor = storyEditor.isHidden ? UIColor.white.cgColor : R.color.appPrimaryColor()?.cgColor
            storyEditorCell.isHidden = false
            
            if let draggingPathOfCellBeingDragged = self.collectionView.draggingPathOfCellBeingDragged {
                if draggingPathOfCellBeingDragged.item == indexPath.item {
                    storyEditorCell.isHidden = true
                }
            }
            
            return storyEditorCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView != slideShowCollectionView && collectionView != nativePlayercollectionView else {
            return
        }
        for editor in storyEditors {
            editor.isHidden = true
        }
        
        self.socialShareExportURL = nil
        self.needToExportVideo()
        if storyEditors.count > 1 {
            isSagmentSelection = true
        }else{
            isSagmentSelection = false
        }
        
        storyEditors[indexPath.item].isHidden = false
        currentStoryIndex = indexPath.item
        print(currentStoryIndex)
        storyEditors[currentStoryIndex].isMuted = isCurrentAssetMuted
        setGestureViewForShowHide(view: storyEditors[currentStoryIndex])
        hideOptionIfNeeded()
        _ = storyEditors[currentStoryIndex].updatedThumbnailImage()
        nativeVideoPlayerRefresh()
        isVideoPlay ? pauseVideo() : playVideo()
        self.collectionView.reloadData()
        self.shareCollectionView.reloadData()
        self.tableView.reloadData()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == shareCollectionView {
            return CGSize(width: 85.0,
                          height: 116.0)
        } else if collectionView == nativePlayercollectionView {
            return CGSize(width: 67, height: collectionView.frame.size.height)
        }
        return CGSize(width: 45.0,
                      height: collectionView.frame.height)

    }
    
    func collectionView(_ collectionView: UICollectionView, indexPathForDataItem dataItem: AnyObject) -> IndexPath? {
        guard let data = dataItem as? StoryEditorView,
            let index = self.storyEditors.firstIndex(where: { $0 == data }) else {
            return nil
        }
        return IndexPath(item: index, section: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, dataItemForIndexPath indexPath: IndexPath) -> AnyObject {
        return storyEditors[indexPath.item]
    }
    
    func collectionView(_ collectionView: UICollectionView, moveDataItemFromIndexPath from: IndexPath, toIndexPath to: IndexPath) {
        if !isSlideShow {
            let fromDataItem = storyEditors[from.item]
            storyEditors.remove(at: from.item)
            storyEditors.insert(fromDataItem, at: to.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, insertDataItem dataItem: AnyObject, atIndexPath indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, deleteDataItemAtIndexPath indexPath: IndexPath) -> Void {
    }
    
    func collectionView(_ collectionView: UICollectionView, cellIsDraggableAtIndexPath indexPath: IndexPath) -> Bool {
        startDraggingIndex = indexPath.row
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? StoryEditorCell else { return false }
        cell.imageView.layer.borderColor = R.color.appPrimaryColor()?.cgColor
        return (collectionView != slideShowCollectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveAt indexPath: IndexPath) -> Bool {
        print(indexPath.row)
        return !isSlideShow
    }
    
    func collectionView(_ collectionView: UICollectionView, startDrag dataItem: AnyObject, atIndexPath indexPath: IndexPath) {
        guard collectionView != slideShowCollectionView else {
            return
        }
        for editor in storyEditors {
            editor.isHidden = true
        }
        
        storyEditors[indexPath.item].isHidden = false
        currentStoryIndex = indexPath.item
        deleteView.isHidden = false
        hideOptionIfNeeded()
    }
    
    func collectionView(_ collectionView: UICollectionView, stopDrag dataItem: AnyObject, atIndexPath indexPath: IndexPath?, sourceRect rect: CGRect) {
        if indexPath?.item != nil {
            medias.rearrange(from: startDraggingIndex!, to: indexPath!.item)
        }
        if deleteView.frame.contains(rect.center) {
            if isSlideShow,
                storyEditors.count == 3 {
                self.showAlert(alertMessage: R.string.localizable.minimumThreeImagesRequiredForSlideshowVideo())
                return
            } else if storyEditors.count == 1 {
                return
            }
            storyEditors[currentStoryIndex].removeFromSuperview()
            storyEditors.remove(at: currentStoryIndex)
            if !(storyEditors.count > currentStoryIndex) {
                currentStoryIndex -= 1
            }
            for editor in storyEditors {
                editor.isHidden = true
            }
            storyEditors[currentStoryIndex].isHidden = false
            hideOptionIfNeeded()
        } else {
            if isSlideShow,
                let storyEditorView = dataItem as? StoryEditorView,
                let indexPath = indexPath {
                var imageData: [UIImage] = []
                for media in selectedSlideShowMedias {
                    if case let .image(image) = media.type,
                        image != UIImage() {
                        imageData.append(image)
                    }
                }
                var minimumValue: Int = 10
                switch Defaults.shared.appMode {
                case .basic:
                    minimumValue = 10
                case .advanced:
                    minimumValue = 20
                case .professional:
                    minimumValue = 20
                default:
                    minimumValue = 10
                }
                
                guard imageData.count < minimumValue else {
                    self.showAlert(alertMessage: R.string.localizable.upgradeToVersionToUploadMoreImageInSlideshow())
                    return
                }
                selectedSlideShowMedias[indexPath.item] = StoryEditorMedia(type: .image(storyEditorView.updatedThumbnailImage() ?? UIImage()))
            }
            for (index, editor) in storyEditors.enumerated() {
                if !editor.isHidden {
                    currentStoryIndex = index
                    break
                }
            }
        }
        deleteView.isHidden = true
        collectionView.reloadData()
    }
    
}

extension StoryEditorViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard storyEditors.count > 0, !isSlideShow else {
            return ShareOption.options.count
        }
        switch storyEditors[currentStoryIndex].type {
        case .image:
            return ShareOption.options.count - 2
        default:
            return ShareOption.options.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.shareOptionTableViewCell.identifier, for: indexPath) as? ShareOptionTableViewCell else {
            fatalError("cell with identifier '\(R.reuseIdentifier.shareOptionTableViewCell.identifier)' not found")
        }
        cell.configureCell(ShareOption.options[indexPath.row])
        return cell
    }
}

extension StoryEditorViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.shareSocialMedia(type: SocialShare(rawValue: indexPath.row) ?? SocialShare.facebook)
    }
}

extension StoryEditorViewController {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == nativePlayercollectionView {
            guard let asset = currentVideoAsset else {
                return
            }
            let videoTrackLength = 67 * displayKeyframeImages.count
            var position = scrollView.contentOffset.x + UIScreen.main.bounds.size.width / 2
            if position < 0 {
                cursorContainerViewCenterConstraint.constant = -position
            } else if position > CGFloat(videoTrackLength) {
                cursorContainerViewCenterConstraint.constant = CGFloat(videoTrackLength) - position
            }
            position = max(position, 0)
            position = min(position, CGFloat(videoTrackLength))
            
            let percent = position / CGFloat(videoTrackLength)
            var currentSecond = asset.duration.seconds * Double(percent)
            currentSecond = max(currentSecond, 0)
            currentSecond = min(currentSecond, asset.duration.seconds)
     
            if !currentSecond.isNaN {
                cursorContainerViewController.seconds = currentSecond
                let currentTime = CMTimeMakeWithSeconds(currentSecond, preferredTimescale: asset.duration.timescale)
                if currentTime.seconds >= 0 && !currentSecond.isNaN {
                    if !storyEditors[currentStoryIndex].isPlaying {
                        storyEditors[currentStoryIndex].seekTime = currentTime
                    }
                }
            }
        }
    }
    
    @objc func onPlaybackTimeChecker() {
        guard let asset = currentVideoAsset,
            !storyEditors[currentStoryIndex].currentTime.seconds.isNaN,
            !asset.duration.seconds.isNaN,
            asset.duration.seconds != 0 else {
                return
        }
        self.videoPlayerPlayback(to: storyEditors[currentStoryIndex].currentTime, asset: asset)
    }
    
     func playbackTimechecker(sliderValue:Float? = nil) {
        guard let asset = currentVideoAsset,
            !storyEditors[currentStoryIndex].currentTime.seconds.isNaN,
            !asset.duration.seconds.isNaN,
            asset.duration.seconds != 0 else {
                return
        }
         self.videoPlayerPlayback(to: storyEditors[currentStoryIndex].currentTime, asset: asset,sliderValue:sliderValue)
    }
    
    func videoPlayerPlayback(to time: CMTime, asset: AVAsset,sliderValue:Float? = nil) {
        let percent = CMTimeGetSeconds(time) / asset.duration.seconds
        let videoTrackLength = 67 * displayKeyframeImages.count
        let position = CGFloat(videoTrackLength) * CGFloat(percent) - UIScreen.main.bounds.size.width / 2
        nativePlayercollectionView.contentOffset = CGPoint(x: position, y: nativePlayercollectionView.contentOffset.y)
        cursorContainerViewController.seconds = CMTimeGetSeconds(time)
        
        var timeSeconds = time.seconds
        if let seconds = sliderValue{
            timeSeconds = Double(seconds)
        }
        let (_, progressTimeS) =
            Utils.secondsToHoursMinutesSeconds(Int(Float(timeSeconds).roundToPlaces(places: 0)))
        let progressTimeMiliS = Utils.secondsToMiliseconds(timeSeconds)
        let (_, totalTimeS) = Utils.secondsToHoursMinutesSeconds(Int(Float(asset.duration.seconds).roundToPlaces(places: 0)))
        let totalTimeMiliS = Utils.secondsToMiliseconds(asset.duration.seconds)
       
        if let val = sliderValue{
               self.storyProgressBar.currentTime = TimeInterval(val)
//            self.videoProgressBar.currentTime = Float(val)
               self.videoProgressBar.value = Float(val)
               print(val)
        }else{
               self.storyProgressBar.currentTime = time.seconds
//            self.videoProgressBar.currentTime = Float(time.seconds)
               self.videoProgressBar.value = Float(time.seconds)
         }
      //  self.lblStoryTime.text = "\(progressTimeM):\(progressTimeS) / \(totalTimeM):\(totalTimeS)"
        
        if totalTimeMiliS == 0 {
            self.lblStoryTime.text = "\(progressTimeS):\(progressTimeMiliS) / \(totalTimeS):0"
        } else {
            self.lblStoryTime.text = "\(progressTimeS):\(progressTimeMiliS) / \(totalTimeS):\(totalTimeMiliS)"
        }
        
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
    
    func loadData() {
        if let asset = currentVideoAsset {
            let imageGenerator = KeyframeImageGenerator()
            imageGenerator.generateDefaultSequenceOfImages(from: asset) { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.displayKeyframeImages.removeAll()
                self.displayKeyframeImages.append(contentsOf: $0)
                self.nativePlayercollectionView.reloadData()
            }
            self.storyProgressBar.duration = asset.duration.seconds
            self.videoProgressBar.maximumValue = Float(asset.duration.seconds)
            self.storyProgressBar.delegate = self
//            self.videoProgressBar.delegate = self
        }
    }
    
    func configUI() {
        nativePlayercollectionView.alwaysBounceHorizontal = true
        nativePlayercollectionView.contentInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.size.width / 2, bottom: 0, right: UIScreen.main.bounds.size.width / 2)
        cursorContainerViewController.seconds = 0
    }
    
    func nativeVideoPlayerRefresh() {
        if self.currentVideoAsset != nil {
            self.loadData()
            self.configUI()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String(describing: KeyframePickerCursorVC.self) {
            self.cursorContainerViewController = segue.destination as? KeyframePickerCursorVC
        }
    }
    
}

extension StoryEditorViewController: ProgressViewDelegate {
    func finishProgress(_ progressView: ProgressView) {
        
    }
    
    func seekPlayerToTime(currentTime: TimeInterval) {
        guard let asset = currentVideoAsset else {
            return
        }
        let currentTime = CMTimeMakeWithSeconds(currentTime, preferredTimescale: asset.duration.timescale)
        storyEditors[currentStoryIndex].seekTime = currentTime
        self.onPlaybackTimeChecker()
    }
    
    func pausePlayer() {
        storyEditors[currentStoryIndex].pause()
    }
    
    func resumePlayer() {
        storyEditors[currentStoryIndex].isPlaying ? pauseVideo() : playVideo()
    }
}

extension StoryEditorViewController: PlayerControlViewDelegate {
   
    func sliderTouchBegin(_ sender: UISlider) {
        pauseVideo()
    }
    
    func sliderTouchEnd(_ sender: UISlider) {
        playVideo()
    }
    
    func sliderValueChange(_ sender: UISlider) {
        guard let asset = currentVideoAsset else {
            return
        }
        let currentTime = CMTimeMakeWithSeconds(Float64(sender.value), preferredTimescale: asset.duration.timescale)
        storyEditors[currentStoryIndex].seekTime = currentTime
        self.playbackTimechecker(sliderValue:sender.value)
//        self.videoProgressBar.currentTime = sender.value
        self.videoProgressBar.value = sender.value
        self.storyProgressBar.currentTime = TimeInterval(sender.value)
    }
    
}

extension StoryEditorViewController: CropViewControllerDelegate {
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, croppedURL: URL,croppedBGcolor:UIColor) {
        if case let StoryEditorType.video(image, _) = storyEditors[self.currentStoryIndex].type {
            isCropped = true
            self.croppedBGcolor = croppedBGcolor
            changeCroppedMediaFrame(image: image, croppedUrl: croppedURL)
            hideCropPopView(isHide: false)
        }
    }
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage,croppedBGcolor:UIColor) {
        storyEditors[currentStoryIndex].replaceMedia(.image(cropped))
        self.croppedBGcolor = croppedBGcolor
    }
    
}

extension StoryEditorViewController: PixelEditViewControllerDelegate {
    
    func pixelEditViewController(_ controller: PixelEditViewController, didEndEditing editingStack: EditingStack) {
        self.editingStack = editingStack
        let image = editingStack.makeRenderer().render(resolution: .full)
        storyEditors[currentStoryIndex].replaceMedia(.image(image))
        controller.dismiss(animated: true, completion: nil)
    }
    
    func pixelEditViewControllerDidCancelEditing(in controller: PixelEditViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}

extension StoryEditorViewController: SSUTagSelectionDelegate {
    
    func didSelect(type: SSUTagType?, waitingListOptionType: SSUWaitingListOptionType?, socialShareType: SocialShare?, screenType: SSUTagScreen) {
        switch screenType {
        case .ssutTypes:
            switch type {
            case .viralCam:
                storyEditors[currentStoryIndex].addReferLinkView(type: .viralCam)
            case .pic2art:
                storyEditors[currentStoryIndex].addReferLinkView(type: .pic2art)
            case .timeSpeed:
                storyEditors[currentStoryIndex].addReferLinkView(type: .timespeed)
            case .boomiCam:
                storyEditors[currentStoryIndex].addReferLinkView(type: .boomicam)
            case .fastCam:
                storyEditors[currentStoryIndex].addReferLinkView(type: .fastcam)
            case .soccerCam:
                storyEditors[currentStoryIndex].addReferLinkView(type: .soccercam)
            case .socialCam:
                storyEditors[currentStoryIndex].addReferLinkView(type: .socialCam)
            case .futbolCam:
                storyEditors[currentStoryIndex].addReferLinkView(type: .futbolcam)
            case .snapCam:
                storyEditors[currentStoryIndex].addReferLinkView(type: .snapcam)
            case .speedCam:
                storyEditors[currentStoryIndex].addReferLinkView(type: .speedcam)
            case .quickCam:
                storyEditors[currentStoryIndex].addReferLinkView(type: .quickcam)
            case .viralCamLite:
                storyEditors[currentStoryIndex].addReferLinkView(type: .viralCamLite)
            case .fastCamLite:
                storyEditors[currentStoryIndex].addReferLinkView(type: .fastCamLite)
            case .quickCamLite:
                storyEditors[currentStoryIndex].addReferLinkView(type: .quickCamLite)
            case .speedCamLite:
                storyEditors[currentStoryIndex].addReferLinkView(type: .speedcamLite)
            case.snapCamLite:
                storyEditors[currentStoryIndex].addReferLinkView(type: .snapCamLite)
            case.socialScreenRecorder:
                storyEditors[currentStoryIndex].addReferLinkView(type: .socialScreenRecorder)
            case .quickApp:
                storyEditors[currentStoryIndex].addReferLinkView(type: .quickCamLite)
            case .profilePicture:
                storyEditors[currentStoryIndex].addReferLinkView(type: .profilePicture)
            default:
                storyEditors[currentStoryIndex].addReferLinkView(type: .socialScreenRecorder)
            }
        case .ssutWaitingList:
            storyEditors[currentStoryIndex].addReferLinkView(type: .socialCam)
        default: break
        }
        self.needToExportVideo()
    }
}

extension StoryEditorViewController: ImageCropperDelegate {
    
    public func didEndCropping(croppedImage: UIImage?) {
        guard let image = croppedImage else {
            return
        }
        storyEditors[currentStoryIndex].addSticker(StorySticker(image: image, type: .image))
    }
    
}

extension StoryEditorViewController: StoryEditorViewDelegate {
    func didChangeEditing(isTyping: Bool) {
        isTyping ? hideToolBar(hide: true, hideColorSlider: true) : hideToolBar(hide: false)
    }
    
    func needToExportVideo() {
        videoExportedURL = nil
    }
}

extension StoryEditorViewController: SpecificBoomerangDelegate {
    
    func didBoomerang(_ url: URL) {
        if case let StoryEditorType.video(image, _) = storyEditors[self.currentStoryIndex].type {
            storyEditors[currentStoryIndex].replaceMedia(.video(image, AVAsset(url: url)))
            nativeVideoPlayerRefresh()
            self.needToExportVideo()
        }
    }
    
}
// Video Social Share
extension StoryEditorViewController {
    
    func shareSocialMedia(type: SocialShare) {
        if let exporturl = socialShareExportURL{
            DispatchQueue.runOnMainThread {
                if type == .youtube {
                    self.checkYoutubeAuthentication(exporturl)
                }else if type == .more {
                    self.shareWithActivity(url:exporturl)
                }else {
                    SocialShareVideo.shared.shareVideo(url: exporturl, socialType: type, referType: self.referType)
                }
                self.pauseVideo()
                self.isVideoPlay = true
            }
        }else{
            referType = storyEditors[currentStoryIndex].referType
            imageVideoExport(isDownload: false, type: type)
        }
        
    }
    
    func exportViewWithURL(_ asset: AVAsset, type: SocialShare = .facebook, index: Int? = nil, completionHandler: @escaping (_ url: URL?) -> Void) {
        let storyIndex: Int = (isSagmentSelection) ? self.currentStoryIndex : index ?? self.currentStoryIndex
        let storyEditor = storyEditors[storyIndex]
        let exportSession = StoryAssetExportSession()
        
        DispatchQueue.runOnMainThread {
            if let loadingView = self.loadingView {
                loadingView.progressView.setProgress(to: Double(0), withAnimation: true)
                loadingView.shouldDescriptionTextShow = true
                if let multipleIndex = index {
                    loadingView.completedExportTotal = "\(multipleIndex+1) / \(self.storyEditors.count)"
                    loadingView.showTotalCount = true
                } else {
                    loadingView.showTotalCount = false
                }
                loadingView.show(on: self.view, completion: {
                    loadingView.cancelClick = { _ in
                        exportSession.cancelExporting()
                        loadingView.hide()
                    }
                })
            }
        }
        
        if let filter = storyEditor.selectedFilter,
            filter.name != "" {
            exportSession.filter = filter.ciFilter
        }
        exportSession.isMute = storyEditor.isMuted
        exportSession.socialShareType = type
        exportSession.isCropped = isCropped
        exportSession.croppedBGcolor = croppedBGcolor
        storyEditors[currentStoryIndex].isCropped ? (storyEditors[currentStoryIndex].storySwipeableFilterView.imageContentMode = .scaleAspectFill) : (storyEditors[currentStoryIndex].storySwipeableFilterView.imageContentMode = .scaleAspectFit)
        storyEditors[currentStoryIndex].isCropped ? (exportSession.imageContentMode = .scaleAspectFit) : (exportSession.imageContentMode = .scaleAspectFit)
        exportSession.overlayImage = storyEditor.toVideoImage()
        exportSession.inputTransformation = storyEditor.imageTransformation
        exportSession.export(for: asset, progress: { [weak self] progress in
            guard let `self` = self else { return }
            print("New progress \(progress)")
            DispatchQueue.runOnMainThread {
                if let loadingView = self.loadingView {
                    loadingView.progressView.setProgress(to: Double(progress), withAnimation: true)
                }
            }
            }, completion: { [weak self] exportedURL in
                guard let `self` = self else { return }
                DispatchQueue.runOnMainThread {
                    if let loadingView = self.loadingView {
                        loadingView.hide()
                    }
                }
                if let url = exportedURL {
                    completionHandler(url)
                } else {
                    let alert = UIAlertController.Style
                        .alert
                        .controller(title: "",
                                    message: R.string.localizable.exportingFail(),
                                    actions: [UIAlertAction(title: R.string.localizable.oK(), style: .default, handler: nil)])
                    self.present(alert, animated: true, completion: nil)
                }
        })
    }
    
    func saveSlideShow(success: @escaping ((URL) -> Void), failure: @escaping ((Error) -> Void)) {
        var imageData: [UIImage] = []
        for media in selectedSlideShowMedias {
            if case let .image(image) = media.type,
                image != UIImage() {
                imageData.append(image)
            }
        }
        guard imageData.count > 2 else {
            self.showAlert(alertMessage: R.string.localizable.minimumThreeImagesRequiredForSlideshowVideo())
            failure(SecurityError.minimumThreeImagesRequiredForSlideshowVideo)
            return
        }
        self.showLoadingView()
        VideoGenerator.current.fileName = String.fileName
        VideoGenerator.current.shouldOptimiseImageForVideo = true
        VideoGenerator.current.videoDurationInSeconds = Double(imageData.count)*1.5
        VideoGenerator.current.maxVideoLengthInSeconds = Double(imageData.count)*1.5
        VideoGenerator.current.videoBackgroundColor = ApplicationSettings.appBlackColor
        VideoGenerator.current.scaleWidth = 720
        VideoGenerator.current.scaleHeight = 1280
        
        var audioUrls: [URL] = []
        if let url = slideShowAudioURL {
            audioUrls = [url]
        }
        
        VideoGenerator.current.generate(withImages: imageData,
                                        andAudios: audioUrls,
                                        andType: .singleAudioMultipleImage, { [weak self] progress in
                                            guard let `self` = self else { return }
                                            DispatchQueue.runOnMainThread {
                                                if let loadingView = self.loadingView {
                                                    let progressCompleted = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
                                                    loadingView.progressView.setProgress(to: Double(progressCompleted), withAnimation: true)
                                                }
                                            }
            }, success: { [weak self] url in
                guard let `self` = self else { return }
                self.hideLoadingView()
                success(url)
            }, failure: { [weak self] error in
                guard let `self` = self else { return }
                self.hideLoadingView()
                failure(error)
        })
    }
    
    func showLoadingView() {
        DispatchQueue.runOnMainThread {
            if let loadingView = self.loadingView {
                loadingView.progressView.setProgress(to: Double(0), withAnimation: true)
                loadingView.shouldDescriptionTextShow = true
                loadingView.shouldCancelShow = true
                loadingView.show(on: self.view, completion: {
                    
                })
            }
        }
    }
    
    func hideLoadingView() {
        DispatchQueue.runOnMainThread {
            if let loadingView = self.loadingView {
                loadingView.hide()
            }
        }
    }
    
    func shareWithActivity(url:URL? = nil, image:UIImage? = nil) {
    
        var activityItems = [Any]()
        if let videoURL = url{
            activityItems.append(videoURL)
        }
        if let img = image{
            activityItems.append(img)
        }
        
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

        activityController.popoverPresentationController?.sourceView = self.view
        activityController.popoverPresentationController?.sourceRect = self.view.frame

        self.present(activityController, animated: true, completion: nil)
    }
}

enum SecurityError: Error {
    case minimumThreeImagesRequiredForSlideshowVideo
}

// MARK: - UIGestureRecognizerDelegate
extension StoryEditorViewController: UIGestureRecognizerDelegate {
    
    func setGestureViewForShowHide(view: UIView) {
        let focusTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleFocusTapGestureRecognizer(_:)))
        focusTapGestureRecognizer.delegate = self
        focusTapGestureRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(focusTapGestureRecognizer)
    }
    
    @objc func handleFocusTapGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if btnShowHideEditImage.isSelected {
            isViewEditMode = !isViewEditMode
        }
    }
    
}

extension StoryEditorViewController {
    
    func setUserSettings(appWatermark: Int? = 1, fastesteverWatermark: Int? = 2, faceDetection: Bool? = false, guidelineThickness: Int? = 3, guidelineTypes: Int? = 3, guidelinesShow: Bool? = false, iconPosition: Bool? = false, supportedFrameRates: [String]?, videoResolution: Int? = 1, watermarkOpacity: Int? = 30, guidelineActiveColor: String?, guidelineInActiveColor: String?) {
        ProManagerApi.setUserSettings(appWatermark: appWatermark ?? 1, fastesteverWatermark: fastesteverWatermark ?? 2, faceDetection: faceDetection ?? false, guidelineThickness: guidelineThickness ?? 3, guidelineTypes: guidelineTypes ?? 3, guidelinesShow: guidelinesShow ?? false, iconPosition: iconPosition ?? false, supportedFrameRates: supportedFrameRates ?? [], videoResolution: videoResolution ?? 1, watermarkOpacity: watermarkOpacity ?? 30, guidelineActiveColor: guidelineActiveColor ?? "", guidelineInActiveColor: guidelineInActiveColor ?? "").request(Result<UserSettingsResult>.self).subscribe(onNext: { response in
            if response.status != ResponseType.success {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: (rx.disposeBag))
    }
    
    func callSetUserSetting() {
        let sharedModel = Defaults.shared
        setUserSettings(appWatermark: sharedModel.appIdentifierWatermarkSetting.rawValue, fastesteverWatermark: sharedModel.fastestEverWatermarkSetting.rawValue, faceDetection: sharedModel.enableFaceDetection, guidelineThickness: sharedModel.cameraGuidelineThickness.rawValue, guidelineTypes: sharedModel.cameraGuidelineTypes.rawValue, guidelinesShow: sharedModel.enableGuildlines, iconPosition: sharedModel.swapeContols, supportedFrameRates: sharedModel.supportedFrameRates, videoResolution: sharedModel.videoResolution.rawValue, watermarkOpacity: sharedModel.waterarkOpacity, guidelineActiveColor: CommonFunctions.hexStringFromColor(color: sharedModel.cameraGuidelineActiveColor), guidelineInActiveColor: CommonFunctions.hexStringFromColor(color: sharedModel.cameraGuidelineInActiveColor))
    }
    
}
extension RangeReplaceableCollection where Indices: Equatable {
    mutating func rearrange(from: Index, to: Index) {
        precondition(from != to && indices.contains(from) && indices.contains(to), "invalid indices")
        insert(remove(at: from), at: to)
    }
}
