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

class StoryEditorMedia: CustomStringConvertible {
    
    var id: String
    var type: StoryEditorType

    init(type: StoryEditorType) {
        self.id = UUID().uuidString
        self.type = type
    }
    
}

class StoryEditorCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class StoryEditorViewController: UIViewController {
    
    @IBOutlet weak var editToolBarView: UIView!
    @IBOutlet weak var downloadView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!

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
    @IBOutlet weak var timeSpeedOptionView: UIView! {
        didSet {
            self.timeSpeedOptionView.isHidden = true
        }
    }
    @IBOutlet weak var pic2ArtOptionView: UIView!
    @IBOutlet weak var cropOptionView: UIView!
    @IBOutlet weak var editOptionView: UIView!
    @IBOutlet weak var applyFilterOptionView: UIView!

    @IBOutlet weak var soundButton: UIButton!
    
    @IBOutlet weak var collectionView: DragAndDropCollectionView!
    @IBOutlet weak var slideShowCollectionView: DragAndDropCollectionView!
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var deleteView: UIView!

    public var medias = [StoryEditorMedia]()
    public var selectedSlideShowMedias = [StoryEditorMedia]()

    private var storyEditors: [StoryEditorView] = []

    private var currentStoryIndex = 0
    
    private var editingStack: EditingStack?
        
    private var dragAndDropManager: DragAndDropManager?
    
    private var slideShowAudioURL: URL?
    
    public var isSlideShow: Bool = false

    private var colorSlider: ColorSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFilterViews()
        selectedSlideShowMedias = (0...7).map({ _ in StoryEditorMedia(type: .image(UIImage())) })
        var collectionViews: [UIView] = [collectionView]
        if isSlideShow {
            collectionViews.append(slideShowCollectionView)
        }
        self.dragAndDropManager = DragAndDropManager(canvas: self.view,
                                                     collectionViews: collectionViews)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = false
        storyEditors[currentStoryIndex].play()
    }

    func setupFilterViews() {
        setupColorSlider()
        for (index, type) in medias.enumerated() {
            let storyEditorView = StoryEditorView(frame: mediaImageView.frame,
                                                  type: type.type,
                                                  contentMode: .scaleAspectFit,
                                                  deleteView: deleteView,
                                                  undoView: undoButton)
            
            view.insertSubview(storyEditorView, aboveSubview: mediaImageView)

            storyEditorView.center = mediaImageView.center
            storyEditorView.filters = StoryFilter.filters

            if index > 0 {
                storyEditorView.isHidden = true
            }
            storyEditors.append(storyEditorView)
        }
        collectionView.reloadData()
        hideOptionIfNeeded()
    }
    
    func setupColorSlider() {
        colorSlider = ColorSlider(orientation: .vertical, previewSide: .left)
        colorSlider.addTarget(self, action: #selector(colorSliderValueChanged(_:)), for: UIControl.Event.valueChanged)
        view.insertSubview(colorSlider, aboveSubview: undoButton)
        let colorSliderHeight = CGFloat(175)
        colorSlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorSlider.centerXAnchor.constraint(equalTo: undoButton.centerXAnchor),
            colorSlider.topAnchor.constraint(equalTo: undoButton.bottomAnchor, constant: 10),
            colorSlider.widthAnchor.constraint(equalToConstant: 15),
            colorSlider.heightAnchor.constraint(equalToConstant: colorSliderHeight),
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
        self.editOptionView.isHidden = !isImage
        self.applyFilterOptionView.isHidden = !isImage
        self.pic2ArtOptionView.isHidden = !isImage

        self.soundOptionView.isHidden = isImage
        self.trimOptionView.isHidden = isImage
        self.timeSpeedOptionView.isHidden = isImage
        
        self.slideShowCollectionView.isHidden = !isSlideShow
        self.addMusicOptionView.isHidden = !isSlideShow
    }
    
    func hideToolBar(hide: Bool) {
        editToolBarView.isHidden = hide
        downloadView.isHidden = hide
        backButton.isHidden = hide
        deleteView.isHidden = hide
        collectionView.isHidden = hide
        slideShowCollectionView.isHidden = !isSlideShow ? true : hide
        doneButton.isHidden = !hide
        colorSlider.isHidden = !hide
    }
    
}

extension StoryEditorViewController: StickerDelegate {
    
    func didSelectSticker(_ sticker: StorySticker) {
        storyEditors[currentStoryIndex].addSticker(sticker)
    }
    
}

extension StoryEditorViewController {
    
    func openStoryEditor(segementedVideos: [SegmentVideos], isSlideShow: Bool = false) {
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
        storyEditorViewController.medias = medias
        self.navigationController?.pushViewController(storyEditorViewController, animated: false)
//        self.removeData()
    }

    
    @IBAction func decorClicked(_ sender: UIButton) {
        guard let stickerViewController = R.storyboard.storyEditor.stickerViewController() else {
            return
        }
        stickerViewController.delegate = self
        present(stickerViewController, animated: true, completion: nil)
    }
    
    @IBAction func textClicked(_ sender: UIButton) {
        storyEditors[currentStoryIndex].startTextEditing()
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
        let soundIcon = storyEditors[currentStoryIndex].isMuted ? R.image.storySoundOff() : R.image.storySoundOn()
        soundButton.setImage(soundIcon, for: .normal)
    }
    
    @IBAction func trimClicked(_ sender: UIButton) {
        
    }

    @IBAction func timeSpeedClicked(_ sender: UIButton) {
        var avAsset: AVAsset?
        switch storyEditors[currentStoryIndex].type {
        case .image:
            break
        case let .video(_, asset):
            avAsset = asset
            break
        }
        guard let currentAsset = avAsset, currentAsset.duration.seconds > 2.0 else {
            let alert = UIAlertController.Style
                .alert
                .controller(title: "",
                            message: "Minimum two seconds video required to change speed",
                            actions: [UIAlertAction(title: "OK", style: .default, handler: nil)])
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard let histroGramVC = R.storyboard.photoEditor.histroGramVC() else {
            return
        }
        storyEditors[currentStoryIndex].pause()
        histroGramVC.currentAsset = currentAsset
        histroGramVC.completionHandler = { [weak self] url in
            guard let `self` = self else {
                return
            }
            if case let StoryEditorType.video(image, _) = self.storyEditors[self.currentStoryIndex].type {
                self.storyEditors[self.currentStoryIndex].replaceMedia(.video(image, AVAsset(url: url)))
            }
        }
        self.navigationController?.pushViewController(histroGramVC, animated: true)
    }
    
    @IBAction func pic2ArtClicked(_ sender: UIButton) {
        guard let styleTransferVC = R.storyboard.photoEditor.styleTransferVC() else {
            return
        }
        storyEditors[currentStoryIndex].pause()
        switch storyEditors[currentStoryIndex].type {
        case let .image(image):
            styleTransferVC.type = .image(image: image)
        case .video:
            break
        }
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
        storyEditors[currentStoryIndex].pause()
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
    
    @IBAction func undoDrawClicked(_ sender: Any) {
        storyEditors[currentStoryIndex].undoDraw()
    }
    
    @IBAction func backClicked(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneClicked(_ sender: UIButton) {
        storyEditors[currentStoryIndex].endDrawing()
        storyEditors[currentStoryIndex].endTextEditing()
        hideToolBar(hide: false)
    }

    @IBAction func downloadClicked(_ sender: UIButton) {
        var imageData: [UIImage] = []
        
        for media in selectedSlideShowMedias {
            switch media.type {
            case let .image(image):
                if image != UIImage() {
                    imageData.append(image)
                }
            default: break
            }
        }
        
        VideoGenerator.current.fileName = String.fileName
        VideoGenerator.current.shouldOptimiseImageForVideo = true
        VideoGenerator.current.videoDurationInSeconds = Double(imageData.count)*1.5
        VideoGenerator.current.maxVideoLengthInSeconds = Double(imageData.count)*1.5
        VideoGenerator.current.videoBackgroundColor = ApplicationSettings.appBlackColor
        VideoGenerator.current.scaleWidth = 720
        VideoGenerator.current.scaleHeight = 1280
        
        VideoGenerator.current.generate(withImages: imageData, andAudios: slideShowAudioURL != nil ? [slideShowAudioURL!] : [] , andType: .singleAudioMultipleImage, { [weak self] progress in
            print(progress)
        }, success: { [weak self] url in
            DispatchQueue.main.async {
                let player = AVPlayer(url: url)
                let vc = AVPlayerViewController()
                vc.player = player
                self?.present(vc, animated: true) {
                    vc.player?.play()
                }
            }
        }, failure: { [weak self] error in
        
        })

    }
    
}

extension StoryEditorViewController: DragAndDropCollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == slideShowCollectionView {
            return selectedSlideShowMedias.count
        }
        return storyEditors.count
    }
     
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == slideShowCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SlideShowStoryCell", for: indexPath) as! StoryEditorCell

            switch selectedSlideShowMedias[indexPath.item].type {
            case let .image(image):
                cell.imageView.image = image
            default:
                break
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryEditorCell", for: indexPath) as! StoryEditorCell

            let storyEditor = storyEditors[indexPath.item]
            cell.imageView.image = storyEditor.thumbnailImage
            cell.imageView.layer.borderWidth = storyEditor.isHidden ? 0 : 3
            cell.isHidden = false
            if let draggingPathOfCellBeingDragged = self.collectionView.draggingPathOfCellBeingDragged {
                if draggingPathOfCellBeingDragged.item == indexPath.item {
                    cell.isHidden = true
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView != slideShowCollectionView else {
            return
        }
        for editor in storyEditors {
            editor.isHidden = true
        }
        storyEditors[indexPath.item].isHidden = false
        currentStoryIndex = indexPath.item
        hideOptionIfNeeded()
        _ = storyEditors[currentStoryIndex].updatedThumbnailImage()
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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
        if !isSlideShow,
            let data = dataItem as? StoryEditorView {
            storyEditors.insert(data, at: indexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, deleteDataItemAtIndexPath indexPath: IndexPath) -> Void {
        if !isSlideShow {
            storyEditors.remove(at: indexPath.item)
        }
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
    
    func collectionView(_ collectionView: UICollectionView, stopDrag dataItem: AnyObject, atIndexPath indexPath: IndexPath) {
        if isSlideShow,
            let storyEditorView = dataItem as? StoryEditorView {
            selectedSlideShowMedias[indexPath.item] = StoryEditorMedia(type: .image(storyEditorView.updatedThumbnailImage() ?? UIImage()))
        }
    }
    
}

extension StoryEditorViewController: CropViewControllerDelegate {
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, croppedURL: URL) {
        if case let StoryEditorType.video(image, _) = storyEditors[self.currentStoryIndex].type {
            storyEditors[currentStoryIndex].replaceMedia(.video(image, AVAsset(url: croppedURL)))
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

extension StoryEditorViewController: ImageCropperDelegate {
    
    public func didEndCropping(croppedImage: UIImage?) {
        guard let image = croppedImage else {
            return
        }
        storyEditors[currentStoryIndex].addSticker(StorySticker(image: image, type: .image))
    }
    
}
