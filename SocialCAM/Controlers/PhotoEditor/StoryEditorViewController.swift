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
import ColorSlider

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
    
    @IBOutlet weak var shareCollectionView: UICollectionView!
    
    @IBOutlet weak var editToolBarView: UIView!
    @IBOutlet weak var downloadView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var imgFastestEverWatermark: UIImageView!
    
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
    @IBOutlet weak var storiCamShareView: UIView!
    
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
    @IBOutlet weak var videoProgressBar: VideoSliderView!
    @IBOutlet weak var storyProgressBar: ProgressView!
    @IBOutlet weak var lblStoryTime: UILabel!
    
    @IBOutlet weak var cursorContainerViewCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var ssuTagView: UIView!
    @IBOutlet weak var doneButtonView: UIView!
    @IBOutlet weak var backButtonView: UIView!
    @IBOutlet weak var closeLabel: UILabel!
    @IBOutlet weak var showHideLabel: UILabel!
    @IBOutlet weak var showHideView: UIView!
    @IBOutlet weak var cropPopupBlurView: UIVisualEffectView!
    @IBOutlet weak var croppedAlertView: UIView!
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var btnYoutube: UIButton!
    @IBOutlet weak var btnInstagram: UIButton!
    @IBOutlet weak var btnTwitter: UIButton!
    @IBOutlet weak var btnTiktok: UIButton!
    @IBOutlet weak var btnStoricamShare: UIButton!
    @IBOutlet weak var hideToolTipView: UIView!
    @IBOutlet weak var btnDoNotShowAgain: UIButton!
    @IBOutlet weak var btnFastesteverWatermark: UIButton!
    @IBOutlet weak var btnAppIdentifierWatermark: UIButton!
    @IBOutlet weak var watermarkView: UIView!
    @IBOutlet weak var watermarkOptionsView: UIView!
    @IBOutlet weak var btnSelectFastesteverWatermark: UIButton!
    @IBOutlet weak var btnSelectAppIdentifierWatermark: UIButton!
    @IBOutlet weak var btnMadeWithWatermark: UIButton!
    
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
    private var videoExportedURL: URL?
    
    public var referType: ReferType = .none
    var popupVC: STPopupController = STPopupController()
    var isCropped: Bool = false
    var croppedImage: UIImage?
    var croppedUrl: URL?
    var isHideTapped = false
    var isToolTipHide = false
    var isFastesteverWatermarkShow = false
    var isAppIdentifierWatermarkShow = false
    
    var isViewEditMode: Bool = false {
        didSet {
            editToolBarView.isHidden = isViewEditMode
            downloadView.isHidden = isViewEditMode
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
            socialShareBottomView.isHidden = isViewEditMode
            showHideView.isHidden = isViewEditMode
            watermarkView.isHidden = isViewEditMode
            isHideTapped = isViewEditMode
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setSocialShareView()
        self.imgFastestEverWatermark.isHidden = Defaults.shared.fastestEverWatermarkSetting == .hide
        isFastesteverWatermarkShow = Defaults.shared.fastestEverWatermarkSetting == .show
        btnSelectFastesteverWatermark.isSelected = isFastesteverWatermarkShow
        btnFastesteverWatermark.isSelected = isFastesteverWatermarkShow
        isAppIdentifierWatermarkShow = Defaults.shared.appIdentifierWatermarkSetting == .show
        btnSelectAppIdentifierWatermark.isSelected = isAppIdentifierWatermarkShow
        btnAppIdentifierWatermark.isSelected = isAppIdentifierWatermarkShow
        btnMadeWithWatermark.isUserInteractionEnabled = Defaults.shared.appMode != .free
        btnAppIdentifierWatermark.isUserInteractionEnabled = Defaults.shared.appMode != .free
        if Defaults.shared.appMode == .free {
            btnAppIdentifierWatermark.isSelected = true
            btnSelectAppIdentifierWatermark.isSelected = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
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
            storyEditorView.filters = StoryFilter.filters
            storyEditorView.addTikTokShareViewIfNeeded()
            if index > 0 {
                storyEditorView.isHidden = true
            }
            storyEditors.append(storyEditorView)
        }
        collectionView.reloadData()
        
        if currentVideoAsset != nil {
            self.loadData()
            self.configUI()
        }
        
        hideOptionIfNeeded()
    }
    
    /// Set images for social share buttons
    func setSocialShareView() {
        if Defaults.shared.appMode == .free, isSnapCamLiteApp {
            btnFacebook.setImage(R.image.icoFacebookTransparent(), for: .normal)
            btnYoutube.setImage(R.image.icoYoutubeTransparent(), for: .normal)
            btnInstagram.setImage(R.image.icoInstagramTransparent(), for: .normal)
            btnTwitter.setImage(R.image.icoTwitterTransparent(), for: .normal)
            btnTiktok.setImage(R.image.icoTiktokTransparent(), for: .normal)
        } else {
            btnFacebook.setImage(R.image.icoFacebook(), for: .normal)
            btnYoutube.setImage(R.image.icoYoutube(), for: .normal)
            btnInstagram.setImage(R.image.icoInstagram(), for: .normal)
            btnTwitter.setImage(R.image.icoTwitter(), for: .normal)
            btnTiktok.setImage(R.image.icoTikTok(), for: .normal)
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
            self.storiCamShareView.isHidden = !isAdvanceMode
        } else {
            self.storiCamShareView.isHidden = true
        }
        
        self.editOptionView.isHidden = !isImage
        self.applyFilterOptionView.isHidden = !isImage
        if !isTimeSpeedApp && !isFastCamApp && !isPic2ArtApp && !isViralCamApp && !isQuickCamApp && !isViralCamLiteApp && !isFastCamLiteApp && !isQuickCamLiteApp && !isSnapCamLiteApp && !isSpeedCamApp && !isSpeedCamLiteApp {
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
        
        var videoCount = 0
        for editor in storyEditors {
            if case StoryEditorType.video(_, _) = editor.type {
                videoCount += 1
            }
        }
        
        self.mergeOptionView.isHidden = !(!isImage && (videoCount > 1))
       
        if !isBoomiCamApp && !isFastCamApp && !isViralCamLiteApp && !isFastCamLiteApp && !isQuickCamLiteApp && !isSpeedCamLiteApp && !isSnapCamLiteApp {
            self.timeSpeedOptionView.isHidden = Defaults.shared.appMode != .free ? isImage : true
        } else {
            self.timeSpeedOptionView.isHidden = true
        }
        
        self.slideShowCollectionView.isHidden = !isSlideShow
        self.slideShowPreviewView.isHidden = !isSlideShow
        self.slideShowFillAuto.isHidden = !isSlideShow
        self.addMusicOptionView.isHidden = !isSlideShow
        self.collectionView.isHidden = !(storyEditors.count > 1)
        self.playButtonBottomLayoutConstraint.constant = (storyEditors.count > 1) ? 77 : 10
        self.backgroundCollectionView.isHidden = self.collectionView.isHidden
        
        self.youtubeShareView.isHidden = isImage
        self.tiktokShareView.isHidden = isImage
        self.playPauseButton.isHidden = isImage
        self.progressBarView.isHidden = isImage
    }
         
    func hideToolBar(hide: Bool, hideColorSlider: Bool = false) {
        editToolBarView.isHidden = hide
        downloadView.isHidden = hide
        backButtonView.isHidden = hide
        deleteView.isHidden = hideColorSlider ? true : hide
        collectionView.isHidden = (storyEditors.count > 1) ? hide : true
        slideShowCollectionView.isHidden = !isSlideShow ? true : hide
        slideShowPreviewView.isHidden = !isSlideShow ? true : hide
        self.slideShowFillAuto.isHidden = !isSlideShow ? true : hide
        doneButtonView.isHidden = !hide
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
        let alert = UIAlertController(title: Constant.Application.displayName, message: R.string.localizable.upgradeSubscriptionWarning(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.upgradeNow(), style: .default, handler: { (_) in
            if let subscriptionVC = R.storyboard.subscription.subscriptionContainerViewController() {
                self.navigationController?.pushViewController(subscriptionVC, animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: R.string.localizable.later(), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func hideToolTipView(isHide: Bool) {
        hideToolTipView.isHidden = isHide
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
        cropPopupBlurView.isHidden = isHide
        watermarkOptionsView.isHidden = isHide
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
        guard let bitmojiStickerPickerViewController = R.storyboard.storyEditor.bitmojiStickerPickerViewController() else {
            return
        }
        bitmojiStickerPickerViewController.completionBlock = { [weak self] (string, image) in
            guard let `self` = self else { return }
            guard let stickerImage = image else {
                return
            }
            self.didSelectSticker(StorySticker(image: stickerImage, type: .image))
            self.needToExportVideo()
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
        storyEditors[currentStoryIndex].isMuted = !storyEditors[currentStoryIndex].isMuted
        self.needToExportVideo()
        let soundIcon = storyEditors[currentStoryIndex].isMuted ? R.image.storySoundOff() : R.image.storySoundOn()
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
            
            self.medias.append(contentsOf: self.filteredImagesStory)
            
            for storyEditor in self.storyEditors {
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
        let trimVC: TrimEditorViewController = R.storyboard.videoTrim.trimEditorViewController()!
        
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
            
            self.medias.append(contentsOf: self.filteredImagesStory)
            
            for storyEditor in self.storyEditors {
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
            currentImage = image
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
    }
    
    @IBAction func doneClicked(_ sender: UIButton) {
        storyEditors[currentStoryIndex].endDrawing()
        storyEditors[currentStoryIndex].endTextEditing()
        hideToolBar(hide: false)
    }

    @IBAction func downloadClicked(_ sender: UIButton) {
        referType = storyEditors[currentStoryIndex].referType
        imageVideoExport(isDownload: true)
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
    
    func imageVideoExport(isDownload: Bool = false, type: SocialShare = .facebook) {
        if isSlideShow {
            saveSlideShow(success: { [weak self] (exportURL) in
                guard let `self` = self else {
                    return
                }
                self.slideShowExportedURL = exportURL
                if isDownload {
                    DispatchQueue.runOnMainThread {
                        self.saveImageOrVideoInGallery(exportURL: exportURL)
                    }
                } else {
                    DispatchQueue.runOnMainThread {
                        SocialShareVideo.shared.shareVideo(url: exportURL, socialType: type, referType: self.referType)
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
                        self.saveImageOrVideoInGallery(image: image)
                    } else {
                        SocialShareVideo.shared.sharePhoto(image: image, socialType: type, referType: self.referType)
                    }
                }
            case let .video(_, asset):
                if let exportURL = videoExportedURL, !isDownload {
                    DispatchQueue.runOnMainThread {
                        SocialShareVideo.shared.shareVideo(url: exportURL, socialType: type, referType: self.referType)
                        self.pauseVideo()
                    }
                } else {
                    self.exportViewWithURL(asset) { [weak self] url in
                        guard let `self` = self else { return }
                        if let exportURL = url {
                            self.videoExportedURL =  exportURL
                            if isDownload {
                                DispatchQueue.runOnMainThread {
                                    self.saveImageOrVideoInGallery(exportURL: exportURL)
                                }
                            } else {
                                DispatchQueue.runOnMainThread {
                                    SocialShareVideo.shared.shareVideo(url: exportURL, socialType: type, referType: self.referType)
                                    self.pauseVideo()
                                }
                            }
                        }
                    }
                }
            }
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
        btnDoNotShowAgain.setImage(R.image.hideToolTipCheckMark()?.alpha(0.5), for: .normal)
        if !isToolTipHide {
            hideToolTipView(isHide: isToolTipHide)
        } else {
            isViewEditMode = !isViewEditMode
        }
    }
    
    @objc private func backgroundViewDidTap() {
        popupVC.dismiss()
    }
    
    @IBAction func btnSocialMediaShareClick(_ sender: UIButton) {
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
                self.shareSocialMedia(type: SocialShare(rawValue: sender.tag) ?? SocialShare.facebook)
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
        if isSnapCamLiteApp {
            self.didSelect(type: SnapCam_Lite.SSUTagType.snapCamLite, waitingListOptionType: nil, socialShareType: nil, screenType: SnapCam_Lite.SSUTagScreen.ssutTypes)
        } else {
            if let ssuTagSelectionViewController = R.storyboard.storyCameraViewController.ssuTagSelectionViewController() {
                ssuTagSelectionViewController.delegate = self
                
                let navigation: UINavigationController = UINavigationController(rootViewController: ssuTagSelectionViewController)
                navigation.isNavigationBarHidden = true
                self.present(navigation, animated: true)
            }
        }
    }
    
    @IBAction func fullScreenButtonClicked(sender: UIButton) {
        if isCropped {
            guard let image = self.croppedImage,
                  let croppedUrl = self.croppedUrl else {
                return
            }
            let storyEditor = storyEditors[currentStoryIndex]
            storyEditor.isCropped = false
            storyEditor.replaceMedia(.video(image, AVAsset(url: croppedUrl)))
            nativeVideoPlayerRefresh()
            self.needToExportVideo()
        }
        self.hideCropPopView(isHide: true)
    }
    
    @IBAction func croppedScreenButtonClicked(sender: UIButton) {
        if isCropped {
            guard let image = self.croppedImage,
                  let croppedUrl = self.croppedUrl else {
                return
            }
            let storyEditor = storyEditors[currentStoryIndex]
            storyEditor.isCropped = true
            storyEditor.replaceMedia(.video(image, AVAsset(url: croppedUrl)))
            nativeVideoPlayerRefresh()
            self.needToExportVideo()
        }
        self.hideCropPopView(isHide: true)
    }
    
    @IBAction func doNotShowAgainButtonClicked(sender: UIButton) {
        btnDoNotShowAgain.isSelected = !btnDoNotShowAgain.isSelected
        isToolTipHide = !isToolTipHide
    }
    
    @IBAction func okayButtonClicked(sender: UIButton) {
        isViewEditMode = !isViewEditMode
        hideToolTipView(isHide: true)
    }
    
    @IBAction func cancelButtonClicked(sender: UIButton) {
        hideToolTipView(isHide: true)
        isToolTipHide = false
        btnDoNotShowAgain.isSelected = isToolTipHide
    }
    
    @IBAction func watermarkButtonClicked(sender: UIButton) {
        hideWatermarkView(isHide: false)
    }
    
    @IBAction func watermarkViewCloseButtonClicked(sender: UIButton) {
        hideWatermarkView(isHide: true)
    }
    
    @IBAction func fastesteverWatermarkButtonClicked(sender: UIButton) {
        isFastesteverWatermarkShow = !isFastesteverWatermarkShow
        btnFastesteverWatermark.isSelected = isFastesteverWatermarkShow
        btnSelectFastesteverWatermark.isSelected = isFastesteverWatermarkShow
    }
    
    @IBAction func appIdentifierWatermarkButtonClicked(sender: UIButton) {
        isAppIdentifierWatermarkShow = !isAppIdentifierWatermarkShow
        btnAppIdentifierWatermark.isSelected = isAppIdentifierWatermarkShow
        btnSelectAppIdentifierWatermark.isSelected = isAppIdentifierWatermarkShow
    }
    
    @IBAction func watermarkViewOkayButtonClicked(sender: UIButton) {
        Defaults.shared.fastestEverWatermarkSetting = self.isFastesteverWatermarkShow ? .show : .hide
        Defaults.shared.appIdentifierWatermarkSetting = self.isAppIdentifierWatermarkShow ? .show : .hide
        self.imgFastestEverWatermark.isHidden = !self.isFastesteverWatermarkShow
        hideWatermarkView(isHide: true)
        callSetUserSetting()
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
            storyEditorCell.imageView.image = storyEditor.thumbnailImage
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
        storyEditors[indexPath.item].isHidden = false
        currentStoryIndex = indexPath.item
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
        return CGSize(width: collectionView.frame.height/2.3,
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
        return (collectionView != slideShowCollectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveAt indexPath: IndexPath) -> Bool {
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
        hideOptionIfNeeded()
    }
    
    func collectionView(_ collectionView: UICollectionView, stopDrag dataItem: AnyObject, atIndexPath indexPath: IndexPath?, sourceRect rect: CGRect) {
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
    
    func videoPlayerPlayback(to time: CMTime, asset: AVAsset) {
        let percent = time.seconds / asset.duration.seconds
        let videoTrackLength = 67 * displayKeyframeImages.count
        let position = CGFloat(videoTrackLength) * CGFloat(percent) - UIScreen.main.bounds.size.width / 2
        nativePlayercollectionView.contentOffset = CGPoint(x: position, y: nativePlayercollectionView.contentOffset.y)
        cursorContainerViewController.seconds = time.seconds
        
        let (progressTimeM, progressTimeS) = Utils.secondsToHoursMinutesSeconds(Int(Float(time.seconds).roundToPlaces(places: 0)))
        let (totalTimeM, totalTimeS) = Utils.secondsToHoursMinutesSeconds(Int(Float(asset.duration.seconds).roundToPlaces(places: 0)))
        self.storyProgressBar.currentTime = time.seconds
        self.videoProgressBar.currentTime = Float(time.seconds)
        self.lblStoryTime.text = "\(progressTimeM):\(progressTimeS) / \(totalTimeM):\(totalTimeS)"
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
            self.videoProgressBar.delegate = self
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
        self.onPlaybackTimeChecker()
    }
    
}

extension StoryEditorViewController: CropViewControllerDelegate {
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, croppedURL: URL) {
        if case let StoryEditorType.video(image, _) = storyEditors[self.currentStoryIndex].type {
            isCropped = true
            changeCroppedMediaFrame(image: image, croppedUrl: croppedURL)
            hideCropPopView(isHide: false)
        }
    }
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage) {
        storyEditors[currentStoryIndex].replaceMedia(.image(cropped))
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
        referType = storyEditors[currentStoryIndex].referType
        imageVideoExport(isDownload: false, type: type)
    }
    
    func exportViewWithURL(_ asset: AVAsset, index: Int? = nil, completionHandler: @escaping (_ url: URL?) -> Void) {
        let storyIndex: Int = index ?? self.currentStoryIndex
        let storyEditor = storyEditors[storyIndex]
        let exportSession = StoryAssetExportSession()
        
        DispatchQueue.runOnMainThread {
            if let loadingView = self.loadingView {
                loadingView.progressView.setProgress(to: Double(0), withAnimation: true)
                loadingView.shouldDescriptionTextShow = true
                if let multipleIndex = index {
                    loadingView.completedExportTotal = "\(multipleIndex) / \(self.storyEditors.count)"
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
        storyEditors[currentStoryIndex].isCropped ? (storyEditors[currentStoryIndex].storySwipeableFilterView.imageContentMode = .scaleAspectFill) : (storyEditors[currentStoryIndex].storySwipeableFilterView.imageContentMode = .scaleAspectFit)
        storyEditors[currentStoryIndex].isCropped ? (exportSession.imageContentMode = .scaleAspectFill) : (exportSession.imageContentMode = .scaleAspectFit)
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
    
    func setUserSettings(appWatermark: Int? = 1, fastesteverWatermark: Int? = 1, faceDetection: Bool? = false, guidelineThickness: Int? = 3, guidelineTypes: Int? = 3, guidelinesShow: Bool? = false, iconPosition: Bool? = false, supportedFrameRates: [String]?, videoResolution: Int? = 1, watermarkOpacity: Int? = 30, guidelineActiveColor: String?, guidelineInActiveColor: String?) {
        ProManagerApi.setUserSettings(appWatermark: appWatermark ?? 1, fastesteverWatermark: fastesteverWatermark ?? 1, faceDetection: faceDetection ?? false, guidelineThickness: guidelineThickness ?? 3, guidelineTypes: guidelineTypes ?? 3, guidelinesShow: guidelinesShow ?? false, iconPosition: iconPosition ?? false, supportedFrameRates: supportedFrameRates ?? [], videoResolution: videoResolution ?? 1, watermarkOpacity: watermarkOpacity ?? 30, guidelineActiveColor: guidelineActiveColor ?? "", guidelineInActiveColor: guidelineInActiveColor ?? "").request(Result<UserSettingsResult>.self).subscribe(onNext: { response in
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
