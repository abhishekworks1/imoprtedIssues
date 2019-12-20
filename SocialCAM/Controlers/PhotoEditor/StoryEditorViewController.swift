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

class StoryEditorMedia: CustomStringConvertible {
    
    var id: String
    var type: StoryEditorType
    var isSelected: Bool
    
    init(type: StoryEditorType, isSelected: Bool = false) {
        self.id = UUID().uuidString
        self.type = type
        self.isSelected = isSelected
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
                        image: R.image.icoTikToK())
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
    @IBOutlet weak var shareCollectionView: UICollectionView!
    
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
    
    private var loadingView: LoadingView? = LoadingView.instanceFromNib()
    
    private var slideShowExportedURL: URL?
    
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
        }
        guard let currentAsset = avAsset, currentAsset.duration.seconds > 2.0 else {
            self.showAlert(alertMessage: R.string.localizable.minimumTwoSecondsVideoRequiredToChangeSpeed())
           
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
        if isSlideShow {
            saveSlideShow(success: { [weak self] (exportURL) in
                guard let `self` = self else {
                    return
                }
                DispatchQueue.runOnMainThread {
                    self.slideShowExportedURL = exportURL
                    let album = SCAlbum.shared
                    album.albumName = "\(Constant.Application.displayName) - \(R.string.localizable.outtakes())"
                    album.saveMovieToLibrary(movieURL: exportURL)
                    self.view.makeToast(R.string.localizable.videoSaved(), duration: 2.0, position: .bottom)
                }
            }) { (error) in
                print(error)
            }
        } else {
            switch storyEditors[currentStoryIndex].type {
            case .image:
                if let image = storyEditors[currentStoryIndex].updatedThumbnailImage() {
                    let album = SCAlbum.shared
                    album.albumName = "\(Constant.Application.displayName) - \(R.string.localizable.outtakes())"
                    album.save(image: image)
                    self.view.makeToast(R.string.localizable.photoSaved(), duration: 2.0, position: .bottom)
                }
            case let .video(_, asset):
                self.exportViewWithURL(asset) { url in
                    if let exportURL = url {
                        DispatchQueue.runOnMainThread {
                            let album = SCAlbum.shared
                            album.albumName = "\(Constant.Application.displayName) - \(R.string.localizable.outtakes())"
                            album.saveMovieToLibrary(movieURL: exportURL)
                            self.view.makeToast(R.string.localizable.videoSaved(), duration: 2.0, position: .bottom)
                        }
                    }
                }
            }

        }
    }
    
    @IBAction func closeShareClicked(_ sender: UIButton) {
        shareViewHeight.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
            self.blurView.isHidden = true
        })
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
                    self.shareViewHeight.constant = 570 - 145
                    UIView.animate(withDuration: 0.5, animations: {
                        self.view.layoutIfNeeded()
                        self.blurView.isHidden = false
                    })
                }
            }) { (error) in
                print(error)
            }
        } else {
            _ = storyEditors[currentStoryIndex].updatedThumbnailImage()
            self.shareCollectionView.reloadData()
            self.tableView.reloadData()
            self.shareCollectionViewHeight.constant = 145
            shareViewHeight.constant = 570
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                self.blurView.isHidden = false
            })
        }
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
        } else {
            guard let storyEditorCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.storyEditorCell.identifier, for: indexPath) as? StoryEditorCell else {
                fatalError("Cell with identifier \(R.reuseIdentifier.storyEditorCell.identifier) not Found")
            }
            let storyEditor = storyEditors[indexPath.item]
            storyEditorCell.imageView.image = storyEditor.thumbnailImage
            storyEditorCell.imageView.layer.borderWidth = storyEditor.isHidden ? 0 : 3
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
        self.collectionView.reloadData()
        self.shareCollectionView.reloadData()
        self.tableView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == shareCollectionView {
            return CGSize(width: 85.0,
                          height: 116.0)
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


// Video Social Share
extension StoryEditorViewController {
    
    func shareSocialMedia(type: SocialShare) {
        if isSlideShow {
            if let url = slideShowExportedURL {
                SocialShareVideo.shared.shareVideo(url: url, socialType: type)
            }
        } else {
            switch storyEditors[currentStoryIndex].type {
            case .image:
                SocialShareVideo.shared.sharePhoto(image: storyEditors[currentStoryIndex].thumbnailImage ?? UIImage(), socialType: type)
            case let .video(_, asset):
                self.exportViewWithURL(asset) { url in
                    if let exportURL = url {
                        DispatchQueue.runOnMainThread {
                            SocialShareVideo.shared.shareVideo(url: exportURL, socialType: type)
                        }
                    }
                }
            }
        }
    }
    
    func exportViewWithURL(_ asset: AVAsset, completionHandler: @escaping (_ url: URL?) -> Void) {
        let storyEditor = storyEditors[currentStoryIndex]
        let exportSession = StoryAssetExportSession()
        
        DispatchQueue.runOnMainThread {
            if let loadingView = self.loadingView {
                loadingView.progressView.setProgress(to: Double(0), withAnimation: true)
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
