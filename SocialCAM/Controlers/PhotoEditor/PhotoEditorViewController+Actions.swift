//
//  PhotoEditiorViewController+Actions.swift
//  SocialCAM
//
//  Created by Viraj Patel on 04/11/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import SCRecorder
import SwiftVideoGenerator
import MobileCoreServices

extension PhotoEditorViewController {
    
    @IBAction func btnShowHideSegmentEditOption(_ sender: UIButton) {
        segmentEditOptionView.isHidden = !sender.isSelected
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnChangeSpeedWithHistroGramClick(_ sender: AnyObject) {
        let mergeSession = SCRecordSession.init()
        for segementModel in videoUrls[currentPage].videos {
            let segment = SCRecordSessionSegment(url: segementModel.url!, info: nil)
            mergeSession.addSegment(segment)
        }
        let currentAsset = mergeSession.assetRepresentingSegments()
        guard currentCamaraMode != .boomerang else {
            let alert = UIAlertController.Style
                .alert
                .controller(title: "",
                            message: "This feature not available for boomerang video.",
                            actions: [UIAlertAction(title: "OK", style: .default, handler: nil)])
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard currentAsset.duration.seconds > 2.0 else {
            let alert = UIAlertController.Style
                .alert
                .controller(title: "",
                            message: "Minimum two seconds video required to change speed",
                            actions: [UIAlertAction(title: "OK", style: .default, handler: nil)])
            self.present(alert, animated: true, completion: nil)
            return
        }
        let histroGramVC = R.storyboard.photoEditor.histroGramVC()
        histroGramVC?.videoSegments = videoUrls
        histroGramVC?.currentAsset = currentAsset
        histroGramVC?.currentIndex = currentPage
        histroGramVC?.doneHandler = { [weak self] updatedSegments in
            guard let strongSelf = self else {
                return
            }
            strongSelf.videoUrls = updatedSegments
            strongSelf.currentPlayVideo = strongSelf.currentPage - 1
            strongSelf.connVideoPlay()
        }
        self.navigationController?.pushViewController(histroGramVC!, animated: true)
    }
    
    @IBAction func addHashtagButtonTapped(_ sender: Any) {
        guard let selectHashtagVC = R.storyboard.photoEditor.selectStoryHashtagVC() else {
            return
        }
        let storyHashtags = self.storyTags.filter { $0.tag.tagType == StoryTagType.hashtag.rawValue }
        var hashtags = [String]()
        for storyHashtag in storyHashtags {
            hashtags.append("#\(storyHashtag.tag.tagText)")
        }
        selectHashtagVC.selectedVisibleHashtags = hashtags
        var hiddenhashtags = [String]()
        for hiddentag in self.hiddenHashtags {
            hiddenhashtags.append("#\(hiddentag)")
        }
        selectHashtagVC.selectedHiddenHashtags = hiddenhashtags
        selectHashtagVC.selectHashtagDelegate = self
        
        let navigationController = UINavigationController(rootViewController: selectHashtagVC)
        navigationController.setNavigationBarHidden(true, animated: false)
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        view.endEditing(true)
        self.setView(view: selectStoryTimeView, hidden: true)
        colorSlider?.isHidden = true
        doneButtonView.isHidden = true
        undoButton.isHidden = true
        mensionPickerView.isHidden = true
        canvasImageView.isUserInteractionEnabled = true
        sketchView?.isUserInteractionEnabled = false
        hideToolbar(hide: false)
        isDrawing = false
    }
    
    @IBAction func horizontalFlipTapped(_ sender: AnyObject) {
        horizontalFlipButton.isSelected = !horizontalFlipButton.isSelected
        if let image = self.image {
            self.image = image.flippedImage(isHorizontal: true)
            filterSwitcherView?.setImageBy(self.image!)
        }
    }
    
    func flipOrientation(_ orientation: UIImage.Orientation) -> UIImage.Orientation {
        var imageOrientation: UIImage.Orientation = UIImage.Orientation.downMirrored
        switch orientation {
        case UIImageOrientation.down:
            imageOrientation = UIImage.Orientation.up
        case UIImageOrientation.downMirrored:
            imageOrientation = UIImage.Orientation.upMirrored
        case UIImageOrientation.left:
            imageOrientation = UIImage.Orientation.right
        case UIImageOrientation.leftMirrored:
            imageOrientation = UIImage.Orientation.rightMirrored
        case UIImageOrientation.right:
            imageOrientation = UIImage.Orientation.left
        case UIImageOrientation.rightMirrored:
            imageOrientation = UIImage.Orientation.leftMirrored
        case UIImageOrientation.up:
            imageOrientation = UIImage.Orientation.down
        case UIImageOrientation.upMirrored:
            imageOrientation = UIImage.Orientation.downMirrored
        default:
            break
        }
        return imageOrientation
    }
    
    @IBAction func verticalFlipTapped(_ sender: AnyObject) {
        verticalFlipButton.isSelected = !verticalFlipButton.isSelected
        if let img = image {
            
            var orientation = UIImage.Orientation.right
            
            if verticalFlipButton.isSelected {
                if horizontalFlipButton.isSelected {
                    orientation = UIImage.Orientation.rightMirrored
                } else {
                    orientation = UIImage.Orientation.left
                }
            } else {
                if horizontalFlipButton.isSelected {
                    orientation = UIImage.Orientation.leftMirrored
                } else {
                    orientation = UIImage.Orientation.right
                }
            }
            
            let mirrorImage = UIImage(cgImage: img.cgImage!, scale: 1.0, orientation: orientation)
            filterSwitcherView?.setImageBy(mirrorImage)
        }
        
    }
    
    // MARK: Bottom Toolbar
    @IBAction func resequenceButtonTapped(_ sender: AnyObject) {
        resequenceButton.isSelected = !resequenceButton.isSelected
        if resequenceButton.isSelected {
            resequenceLabel.text = "Rearranged"
        } else {
            resequenceLabel.text = "Original"
        }
        isOriginalSequence = !isOriginalSequence
        self.stopMotionCollectionView.reloadData()
        
    }
    
    @IBAction func mergeButtonTapped(_ sender: AnyObject) {
        mergeButton.isSelected = !mergeButton.isSelected
        isMovable = !isMovable
    }
    
    @IBAction func combineButtonTapped(_ sender: AnyObject) {
        guard !combineButton.isSelected else {
            return
        }
        combineButton.isSelected = !combineButton.isSelected
        DispatchQueue.main.async {
            if self.videoUrls.count == 1 {
                return
            }
            var urls: [SegmentVideos] = []
            for video in self.videoUrls {
                urls.append(video)
            }
            self.registerCombineAllData(data: urls)
            self.registerCombineAllData(data: urls)
            
            for (index, _) in self.videoUrls.enumerated() {
                if index != 0 {
                    self.videoUrls[0].numberOfSegementtext = "\(self.videoUrls[0].numberOfSegementtext!) - \(self.videoUrls[index].numberOfSegementtext!)"
                    let videos = self.videoUrls[index].videos
                    self.videoUrls[0].videos.append(contentsOf: videos)
                }
            }
            
            self.videoUrls.first!.currentAsset = SegmentVideos.getRecordSession(videoModel: self.videoUrls.first!.videos)
            
            let tempFirstSegment = self.videoUrls.first
            self.videoUrls.removeAll()
            self.videoUrls.append(tempFirstSegment!)
            self.currentPlayVideo = -1
            self.connVideoPlay()
        }
    }
    
    func getCombineUndo(data: [SegmentVideos]) -> (() -> Void) {
        return { () -> Void in
            self.videoUrls.removeAll()
            for video in data {
                self.videoUrls.append(video)
            }
        }
    }
    
    func registerCombineAllData(data: [SegmentVideos]) {
        undoMgr.add(undo: getCombineUndo(data: data), redo: getCombineUndo(data: data))
    }
    
    @IBAction func btnPausePlayClick(_ sender: AnyObject) {
        pausePlayButton.isSelected = !pausePlayButton.isSelected
        if let player = self.scPlayer {
            player.isPlaying ? player.pause() : player.play()
        }
    }
    
    @IBAction func btnTrimClick(_ sender: AnyObject) {
        let trimVC: TrimEditorViewController = R.storyboard.photoEditor.trimEditorViewController()!
        var urls: [SegmentVideos] = []
        for video in self.videoUrls {
            urls.append(video)
        }
        trimVC.videoUrls = urls
        trimVC.doneHandler = { [weak self] urls in
            guard let strongSelf = self else {
                return
            }
            let videourls: [SegmentVideos] = urls!
            strongSelf.videoUrls.removeAll()
            strongSelf.videoUrls = videourls
            strongSelf.currentPlayVideo = -1
            strongSelf.connVideoPlay()
        }
        self.navigationController?.pushViewController(trimVC, animated: true)
    }
    
    @IBAction func undoSButtonTapped(_ sender: AnyObject) {
        undoMgr.undo()
        undoMgr.undo()
        DispatchQueue.main.async {
            self.combineButton.isSelected = false
            self.stopMotionCollectionView.reloadData()
        }
    }
    
    @IBAction func resetButtonTapped(_ sender: AnyObject) {
        if undoMgr.canUndo() {
            undoMgr.removeAll()
            combineButton.isSelected = false
            videoUrls.removeAll()
            mergeButton.isSelected = false
            isMovable = true
            
            videoUrls = videoResetUrls
            self.currentPlayVideo = -1
            self.connVideoPlay()
        }
    }
    
    @IBAction func btnShowHideEditOptionsClick(_ sender: AnyObject) {
        if !isViewEditMode {
            isDeleteShoworNot = deleteView.isHidden
            
            isEditOptionsToolBarShoworNot = editOptionsToolBar.isHidden
            isPhotosStackViewShoworNot = photosStackView.isHidden
            
            isSegmentEditOptionViewShoworNot = segmentEditOptionView.isHidden
            isVideoCoverViewShoworNot = videoCoverView.isHidden
        }
        isViewEditMode = !isViewEditMode
    }
    
    @IBAction func filtersButtonClicked(_ sender: Any) {
        guard currentCamaraMode != .boomerang else {
            let alert = UIAlertController.Style
                .alert
                .controller(title: "",
                            message: "This feature is not available for boomerang video.",
                            actions: [UIAlertAction(title: "OK", style: .default, handler: nil)])
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard let styleTransferVC = R.storyboard.photoEditor.styleTransferVC() else {
            return
        }
        if let image = self.image {
            styleTransferVC.type = .image(image: image)
        } else {
            styleTransferVC.type = .video(videoSegments: videoUrls, index: currentPage)
        }
        styleTransferVC.doneHandler = { [weak self] data, currentMode in
            guard let strongSelf = self else {
                return
            }
            if let updatedSegments = data as? [SegmentVideos] {
                if strongSelf.image != nil {
                    if currentMode == 1 {
                        strongSelf.didSelectSlideShow(images: updatedSegments)
                        return
                    } else {
                        DispatchQueue.main.async {
                            if let collageMakerVC = R.storyboard.collageMaker.collageMakerVC() {
                                collageMakerVC.assets = updatedSegments
                                collageMakerVC.delegate = self
                                strongSelf.navigationController?.pushViewController(collageMakerVC, animated: true)
                            }
                        }
                        return
                    }
                } else {
                    strongSelf.videoUrls = updatedSegments
                    strongSelf.playerDidEnd()
                }
            } else if let filteredImage = data as? UIImage {
                strongSelf.image = filteredImage
                strongSelf.filterSwitcherView?.setImageBy(filteredImage)
            }
        }
        self.scPlayer?.pause()
        self.navigationController?.pushViewController(styleTransferVC, animated: true)
        
    }
    
    func didSelectSlideShow(images: [SegmentVideos]) {
        self.videoUrls = images
        self.openPhotoEditorForImage(images)
    }
    
    func openPhotoEditorForImage(_ videoUrls: [SegmentVideos]) {
        let photoEditor = getPhotoEditor()
        photoEditor.videoUrls = videoUrls
        photoEditor.currentCamaraMode = .slideshow
        
        if let navController = self.navigationController {
            let newVC = photoEditor
            var stack = navController.viewControllers
            stack.remove(at: stack.count - 1)       // remove StyleTransferVC
            stack.remove(at: stack.count - 1)       // remove PhotoEditorViewController
            stack.insert(newVC, at: stack.count) // add the new one
            navController.setViewControllers(stack, animated: false) // boom!
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        doneButtonTapped(sender)
    }
    
    @IBAction func stickersButtonTapped(_ sender: Any) {
        addStickersViewController()
    }
    
    @IBAction func drawButtonTapped(_ sender: Any) {
        isDrawing = true
        if let sketchView = self.sketchView {
            undoButton.isHidden = !sketchView.canUndo()
        }
        doneButton.setImage(R.image.storyDraw(), for: UIControl.State.normal)
        doneButtonView.isHidden = false
        
        colorSlider?.isHidden = false
        colorSlider?.color = sketchView?.lineColor ?? ApplicationSettings.appWhiteColor
        hideToolbar(hide: true)
        sketchView?.isUserInteractionEnabled = true
    }
    
    @IBAction func textButtonTapped(_ sender: Any) {
        isTyping = true
        let textView = UITextView(frame: CGRect(x: 0, y: canvasImageView.center.y,
                                                width: UIScreen.main.bounds.width, height: 30))
        textView.tintColor = ApplicationSettings.appWhiteColor
        textView.textAlignment = .center
        textView.font = UIFont(name: "Helvetica", size: 30)
        textView.textColor = textColor
        textView.layer.shadowColor = ApplicationSettings.appBlackColor.cgColor
        textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        textView.layer.shadowOpacity = 0.2
        textView.layer.shadowRadius = 1.0
        textView.layer.backgroundColor = ApplicationSettings.appClearColor.cgColor
        textView.autocorrectionType = .no
        textView.backgroundColor = ApplicationSettings.appClearColor
        textView.isScrollEnabled = false
        textView.tag = textViews.count
        textView.delegate = self
        self.canvasImageView.addSubview(textView)
        addGestures(view: textView)
        textView.becomeFirstResponder()
        textViews.append(textView)
    }
    
    @IBAction func segmentBeforeMergeButtonTapped(_ sender: AnyObject) {
        mergeVideo(isBefore: true)
    }
    
    @IBAction func segmentAfterMergeButtonTapped(_ sender: AnyObject) {
        mergeVideo(isBefore: false)
    }
    
    func registerReplaceNewData(data: SegmentVideos, index: Int) {
        undoMgr.add(undo: getReplaceRedo(model: data, index: index), redo: getReplaceRedo(model: data, index: index))
    }
    
    func registerReplaceDeleteData(data: SegmentVideos, index: Int) {
        undoMgr.add(undo: getReplace(model: data, index: index), redo: getReplace(model: data, index: index))
    }
    
    func getReplace(model: SegmentVideos, index: Int) -> (() -> Void) {
        return { () -> Void in
            self.videoUrls.insert(model, at: index)
        }
    }
    
    func getReplaceRedo(model: SegmentVideos, index: Int) -> (() -> Void) {
        return { () -> Void in
            self.videoUrls.remove(at: index)
            self.videoUrls.insert(model, at: index)
        }
    }
    
    func mergeVideo(isBefore: Bool) {
        DispatchQueue.main.async {
            if self.lastMargeCell != self.draggingCell {
                let _: SegmentVideos = self.videoUrls[self.draggingCell!.item]
                
                let model = self.videoUrls[self.lastMargeCell!.row]
                let modelDrag = self.videoUrls[self.draggingCell!.row]
                
                self.registerReplaceNewData(data: model, index: self.lastMargeCell!.row)
                self.registerReplaceDeleteData(data: modelDrag, index: self.draggingCell!.row)
                
                if isBefore {
                    self.videoUrls[self.lastMargeCell!.row].numberOfSegementtext = "\(self.videoUrls[self.draggingCell!.row].numberOfSegementtext!) - \(self.videoUrls[self.lastMargeCell!.row].numberOfSegementtext!)"
                } else {
                    self.videoUrls[self.lastMargeCell!.row].numberOfSegementtext = "\(self.videoUrls[self.lastMargeCell!.row].numberOfSegementtext!) - \(self.videoUrls[self.draggingCell!.row].numberOfSegementtext!)"
                }
                
                for videosItem in self.videoUrls[self.draggingCell!.row].videos {
                    if isBefore {
                        self.videoUrls[self.lastMargeCell!.row].videos.insert(videosItem, at: 0)
                    } else {
                        self.videoUrls[self.lastMargeCell!.row].videos.append(videosItem)
                    }
                }
                
                self.videoUrls[self.lastMargeCell!.row].currentAsset = SegmentVideos.getRecordSession(videoModel:
                    self.videoUrls[self.lastMargeCell!.row].videos)
                
                self.videoUrls.remove(at: self.draggingCell!.row)
            }
            
            self.currentPlayVideo = -1
            self.connVideoPlay()
            self.segmentTypeMergeView.isHidden = true
            self.segmentEditOptionView.isHidden = false
            self.stopMotionCollectionView.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func undoButtonTapped(_ sender: Any) {
        sketchView?.undo()
        guard let sketchView = self.sketchView else {
            return
        }
        undoButton.isHidden = !sketchView.canUndo()
    }
    
    @IBAction func editImageTapped(_ sender: UIButton) {
        var controller: PixelEditViewController!
        if editingStack != nil {
            controller = PixelEditViewController.init(editingStack: editingStack!)
        } else {
            if let image = self.image {
                controller = PixelEditViewController.init(image: image)
            }
        }
        if controller != nil {
            controller.delegate = self
            let navigationController = UINavigationController(rootViewController: controller)
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Button Actions
    
    @IBAction func onPlay(_ sender: AnyObject) {
        if playButton.isSelected {
            scPlayer?.pause()
            stopPlaybackTimeChecker()
            playButton.isSelected = false
        } else {
            guard let player = self.scPlayer else { return }
            player.play()
            startPlaybackTimeChecker()
            playButton.isSelected = true
        }
    }
    
    @IBAction func onPause(_ sender: AnyObject) {
        scPlayer?.pause()
        playButton.isHidden = false
        pauseButton.isHidden = true
    }
    
    @IBAction func btnPhotosCloseTapped(_ sender: UIButton) {
        sender.isHidden = true
        
        let selectedVideoUrlSave = self.selectedSlideShowImages[sender.tag - 1]
        
        self.selectedSlideShowImages.remove(at: sender.tag - 1)
        self.selectedSlideShowImages.insert(nil, at: sender.tag - 1)
        
        for video in videoUrls {
            var count = 0
            if selectedVideoUrlSave?.videos[0].id == video.videos[0].id {
                for videos in selectedSlideShowImages {
                    if selectedVideoUrlSave?.videos[0].id == videos?.videos[0].id {
                        count += 1
                    }
                }
                if count == 0 {
                    video.isSelected = false
                }
            }
        }
        
        self.stopMotionCollectionView.reloadData()
        
        let allSegment = self.selectedSlideShowImages.filter({ (segmentVideo) -> Bool in
            return (segmentVideo != nil)
        })
        
        if allSegment.count < 2 {
            enableSaveButtons(false, alpha: 0.5)
        } else {
            enableSaveButtons(true, alpha: 1.0)
        }
        
        let slideShowCount = self.selectedSlideShowImages.filter({ (segmentVideo) -> Bool in
            return (segmentVideo != nil)
        })
        
        coverImageView.image = !slideShowCount.isEmpty ? slideShowCount.first??.image : UIImage()
        
        switch sender.tag {
        case 1:
            custImage1.image = nil
        case 2:
            custImage2.image = nil
        case 3:
            custImage3.image = nil
        case 4:
            custImage4.image = nil
        case 5:
            custImage5.image = nil
        case 6:
            custImage6.image = nil
        default:
            break
        }
    }
    
    @IBAction func soundButtonTapped(_ sender: Any) {
        isMute = !isMute
        if isMute {
            soundButton.setImage(R.image.storySoundOff(), for: UIControl.State.normal)
        } else {
            soundButton.setImage(R.image.storySoundOn(), for: UIControl.State.normal)
        }
        self.scPlayer?.isMuted = isMute
    }
    
    @IBAction func addNewMusicButtonTapped(_ sender: Any) {
        let addNewMusicVC = R.storyboard.photoEditor.musicPickerVC()!
        addNewMusicVC.selectedURL = self.selectedUrl
        addNewMusicVC.finishAddMusicBlock = { [weak self] (fileUrl, success) in
            guard let aSelf = self else { return }
            if success {
                aSelf.selectedUrl = fileUrl
                aSelf.addNewMusicButton.tintColor = ApplicationSettings.appPrimaryColor
                aSelf.addNewMusicLabel.textColor = ApplicationSettings.appPrimaryColor
            } else {
                aSelf.selectedUrl = nil
                aSelf.addNewMusicButton.tintColor = ApplicationSettings.appWhiteColor
                aSelf.addNewMusicLabel.textColor = ApplicationSettings.appWhiteColor
            }
        }
        
        self.navigationController?.pushViewController(addNewMusicVC, animated: true)
    }
    
    @IBAction func storyTimeButtonTapped(_ sender: Any) {
        doneButton.setImage(#imageLiteral(resourceName: "storyTimerWithTick"), for: UIControl.State.normal)
        doneButtonView.isHidden = false
        if storyTimeLabel.text == "∞" {
            storyTimePickerView.selectRow(10, animated: false)
        } else {
            storyTimePickerView.selectRow((Int(storyTimeLabel.text ?? "1") ?? 1) - 1, animated: false)
        }
        self.setView(view: selectStoryTimeView, hidden: false)
    }
    @IBAction func filterAddNewClick(_ sender: UIButton) {
        if let filteredImage = self.filterSwitcherView?.renderedUIImage() {
            sender.startPulse(with: ApplicationSettings.appPrimaryColor, animation: YGPulseViewAnimationType.radarPulsing)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                sender.stopPulse()
            }
            sender.press(completion: { (_) in
                
            })
            
            self.image = filteredImage
            self.filterSwitcherView?.setImageBy(filteredImage)
            self.filterSwitcherView?.scroll(to: self.filterSwitcherView!.filters![0], animated: false)
            self.dummyView.transform = .identity
            self.dummyView.frame = self.storyRect
            self.setTransformationInFilterSwitcherView()
            
        }
    }
    
    @IBAction func cropButtonClicked(_ sender: Any) {
        var cropViewController: CropViewController
        if let image = self.image {
            cropViewController = CropViewController(image: image)
        } else {
            let mergeSession = SCRecordSession.init()
            for segementModel in videoUrls[currentPage].videos {
                let segment = SCRecordSessionSegment(url: segementModel.url!, info: nil)
                mergeSession.addSegment(segment)
            }
            let currentAsset = mergeSession.assetRepresentingSegments()
            cropViewController = CropViewController(avAsset: currentAsset)
        }
        cropViewController.delegate = self
        cropViewController.videoSegments = videoUrls
        cropViewController.currentIndex = currentPage
        cropViewController.modalPresentationStyle = .fullScreen
        present(cropViewController, animated: true)
    }
    
    @IBAction func maskButtonClicked(_ sender: Any) {
        guard let imageCropperVC = R.storyboard.photoEditor.imageCropperVC() else {
            return
        }
        if let image = self.image {
            imageCropperVC.image = image
        } else {
            imageCropperVC.image = self.filterSwitcherView?.toImage()
        }
        imageCropperVC.delegate = self
        self.navigationController?.pushViewController(imageCropperVC, animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        if let _ = self.storyId, publish == PublishMode.unPublish.rawValue, !storyRePost {
            let alert = UIAlertController(title: "Conform", message: "Do you want to save unPublish Image/Video?", preferredStyle: .actionSheet)
            
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: handleUnPublishSave)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: handleDismiss)
            alert.addAction(yesAction)
            alert.addAction(cancelAction)
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = CGRect.init(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
            
            self.present(alert, animated: true, completion: nil)
        } else {
            switch self.storiCamType {
            case .shareYoutube, .shareFeed, .shareStory: UIApplication.shared.delegate?.window??.makeToast(R.string.localizable.retake())
            case .replyStory:
                break
            default:
                break
            }
            self.dismiss()
        }
    }
    
    func handleUnPublishSave(alertAction: UIAlertAction!) {
        saveToCameraRoll(false)
    }
    
    func handleDismiss(alertAction: UIAlertAction!) {
        self.dismiss()
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        let youtubeTags = self.storyTags.filter { $0.tag.tagType == StoryTagType.youtube.rawValue }
        if !youtubeTags.isEmpty {
            createPostAPICall()
        } else {
            storyButtonAction()
        }
    }
    
    func createPostAPICall() {
        var pData: CreatePostData?
        if case StoriCamType.shareYoutube(let postData) = self.storiCamType {
            pData = postData
        } else if let yData = self.youTubeData {
            pData = CreatePostData(type: "youtube",
                                   text: "",
                                   isChekedIn: false,
                                   userID: Defaults.shared.currentUser?.id ?? "",
                                   mediaData: nil,
                                   youTubeData: yData,
                                   wallTheme: nil,
                                   albumId: nil,
                                   checkedInData: nil,
                                   hashTags: self.youTubeHashtags,
                                   privacy: "Public",
                                   friendExcept: nil,
                                   friendsOnly: nil,
                                   feelingType: nil,
                                   feelings: nil,
                                   previewUrlData: nil)
            
        }
        guard let postData = pData else {
            storyButtonAction()
            return
        }
        self.showHUD()
        self.storyExportLabel.text = "0/1"
        ProManagerApi.writePost(type: postData.type,
                                text: postData.text,
                                isChekedIn: postData.isChekedIn,
                                user: postData.userID,
                                media: postData.mediaData,
                                youTubeData: postData.youTubeData,
                                wallTheme: postData.wallTheme,
                                albumId: postData.albumId,
                                checkedIn: postData.checkedInData,
                                hashTags: postData.hashTags,
                                privacy: postData.privacy,
                                friendExcept: postData.friendExcept,
                                friendsOnly: postData.friendsOnly,
                                feelingType: postData.feelingType,
                                feelings: postData.feelings,
                                previewUrlData: postData.previewUrlData, tagChannelAry: nil)
            .request(Result<Posts>.self)
            .subscribe(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                self.dismissHUD()
                self.storyExportLabel.text = "1/1"
                guard response.result != nil else {
                    return
                }
                if response.status == ResponseType.success,
                    let postId = response.result?.id {
                    if let youtubeTagIndex = self.storyTags.firstIndex(where: { $0.tag.tagType == StoryTagType.youtube.rawValue }) {
                        self.storyTags[youtubeTagIndex].tag.postId = postId
                    }
                    self.storyButtonAction()
                } else {
                    self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
                }
                }, onError: { [weak self] error in
                    guard let `self` = self else { return }
                    self.dismissHUDWithError(error.localizedDescription)
            }).disposed(by: rx.disposeBag)
    }
    
    @IBAction func outtakesMediaTapped(_ sender: Any) {
        saveButtonTapped(isOuttake: true)
    }
    
    @IBAction func notesButtonClicked(_ sender: Any) {
        saveButtonTapped(isOuttake: false)
    }
    
    func saveButtonTapped(isOuttake: Bool) {
        if image != nil && currentCamaraMode != .slideshow {
            let album = SCAlbum.shared
            album.albumName = isOuttake ? "\(Constant.Application.displayName) - Outtakes" :  "\(Constant.Application.displayName) - Notes"
            album.save(image: canvasView.toImage())
            if isOuttake {
                outtakesDelegate?.didTakeOuttakes("Outtakes saved.")
            } else {
                outtakesDelegate?.didTakeOuttakes("Notes saved.")
            }
            self.dismiss()
        } else if currentCamaraMode == .slideshow {
            self.saveSlideShow(exportType: isOuttake ? SlideShowExportType.outtakes : SlideShowExportType.notes,
                               success: { [weak self] url in
                                guard let `self` = self else { return }
                                self.exportedURL = url
                                self.saveVideo(exportType: isOuttake ? SlideShowExportType.outtakes : SlideShowExportType.notes, url: url)
                },
                               failure: { _ in
                                
            })
        } else {
            isOuttake ? saveToCameraRoll(true, false) : saveToCameraRoll(false, true)
        }
    }
    
    func storyButtonAction() {
        if currentCamaraMode == .slideshow {
            self.saveSlideShow(exportType: SlideShowExportType.story,
                               success: { [weak self] url in
                                guard let `self` = self else { return }
                                self.saveVideo(exportType: SlideShowExportType.story, url: url)
                },
                               failure: { error in
                                print(error)
            })
            
            return
        }
        
        let album = SCAlbum.shared
        album.albumName = "\(Constant.Application.displayName)"
        if image != nil {
            let image = self.canvasView.toImage()
            album.save(image: image)
            var storyTime = "3.0"
            let fileName = String.fileName + FileExtension.jpg.rawValue
            let data = image.jpegData(compressionQuality: 1.0)
            let url = Utils.getLocalPath(fileName)
            try? data?.write(to: url)
            let internalStoryTags = getTags()
            if !internalStoryTags.isEmpty {
                storyTime = "6.0"
            }
            if let storyId = self.storyId, !storyRePost {
                let loadingView = LoadingView.instanceFromNib()
                loadingView.shouldCancelShow = true
                loadingView.loadingViewShow = true
                loadingView.show(on: view)
                Utils.uploadImage(imgName: fileName, img: image, callBack: { url -> Void in
                    self.publish = PublishMode.publish.rawValue
                    loadingView.hide()
                    self.editStory(storyId, storyURL: url, thumbURL: nil)
                })
                return
            }
            let storyData = InternalStoryData(address: self.address, duration: storyTime, lat: self.lat, long: self.long, thumbTime: 0.0, type: "image", url: url.absoluteString, userId: Defaults.shared.currentUser?.id ?? "", watermarkURL: "", isMute: false, filterName: nil, exportedUrls: [""], hiddenHashtags: self.hiddenHashtags.joined(separator: " "), tags: internalStoryTags)
            storyData.storiType = storyRePost ? .shared : self.storiType
            _ = StoryDataManager.shared.createStoryUploadData([storyData])
            StoryDataManager.shared.startUpload()
            self.dismiss()
        } else {
            if let _ = self.storyId, !storyRePost {
                publish = PublishMode.publish.rawValue
            }
            saveToCameraRoll(false)
            if self.selectedVideoUrlSave != nil {
                self.scPlayer?.isMuted = true
                self.dismiss()
            }
        }
    }
    
    @IBAction func btnSocialShareClick(_ sender: UIButton) {
        var menuOptions: [UIImage] = [R.image.icoFacebook()!, R.image.icoInstagram()!, R.image.icoSnapchat()!, R.image.icoTwitter()!]
        var menuOptionsString: [String] = ["", "", "", ""]
        if image == nil {
            menuOptions.append(R.image.icoYoutube()!)
            menuOptionsString.append("")
        }
        menuOptions.append(R.image.icoTikToK()!)
        menuOptionsString.append("")
        
        BasePopConfiguration.shared.backgoundTintColor = R.color.lightBlackColor()!
        BasePopConfiguration.shared.menuWidth = 35
        BasePopConfiguration.shared.showCheckMark = .none
        BasePopOverMenu
            .showForSender(sender: sender, with: menuOptionsString, menuImageArray: menuOptions, done: { [weak self] (selectedIndex) in
                guard let `self` = self else { return }
                self.shareSocialMedia(type: SocialShare(rawValue: selectedIndex) ?? SocialShare.facebook)
                }, cancel: {
            })
    }
    
    @IBAction func btnSocialMediaShareClick(_ sender: UIButton) {
        self.shareSocialMedia(type: SocialShare(rawValue: sender.tag) ?? SocialShare.facebook)
    }
    
    func shareSocialMedia(type: SocialShare) {
        if currentCamaraMode == .slideshow {
            if let exportURL = exportedURL {
                DispatchQueue.runOnMainThread {
                    SocialShareVideo.shared.shareVideo(url: exportURL, socialType: type)
                }
            }
            else {
                self.saveSlideShow(exportType: SlideShowExportType.feed,
                                   success: { [weak self] exportURL in
                                    guard let `self` = self else { return }
                                    self.exportedURL = exportURL
                                    SocialShareVideo.shared.shareVideo(url: exportURL, socialType: type)
                    },
                                   failure: { error in
                                    print(error)
                })
            }
            return
        }
        
        if image != nil {
            SocialShareVideo.shared.sharePhoto(image: canvasView.toImage(), socialType: type)
        } else if exportedURL != nil {
            if let exportURL = exportedURL {
                DispatchQueue.runOnMainThread {
                    SocialShareVideo.shared.shareVideo(url: exportURL, socialType: type)
                }
            }
        } else {
            let recordSession = SCRecordSession()
            if let url = selectedVideoUrlSave {
                for segementModel in url.videos {
                    let segment = SCRecordSessionSegment(url: segementModel.url!, info: nil)
                    recordSession.addSegment(segment)
                }
            } else {
                for url in self.videoUrls {
                    for segementModel in url.videos {
                        let segment = SCRecordSessionSegment(url: segementModel.url!, info: nil)
                        recordSession.addSegment(segment)
                    }
                }
            }
            self.exportViewWithURL(recordSession.assetRepresentingSegments()) { [weak self] url in
                guard let `self` = self else { return }
                if let exportURL = url {
                    self.exportedURL = exportURL
                    DispatchQueue.runOnMainThread {
                        SocialShareVideo.shared.shareVideo(url: exportURL, socialType: type)
                    }
                }
            }
        }
    }
    
    func uploadYoutube() {
        guard image == nil else { return }
        if currentCamaraMode == .slideshow {
            saveSlideShow(exportType: SlideShowExportType.chat,
                          success: { [weak self] url in
                            guard let `self` = self else { return }
                            DispatchQueue.runOnMainThread {
                                if let youTubeUploadVC = R.storyboard.youTubeUpload.youTubeUploadViewController() {
                                    youTubeUploadVC.videoUrl = url
                                    self.navigationController?.pushViewController(youTubeUploadVC, animated: true)
                                }
                            }
                },
                          failure: { _ in
                            
            })
            
            return
        } else if let url = selectedVideoUrlSave {
            let recordSession = SCRecordSession()
            for segementModel in url.videos {
                let segment = SCRecordSessionSegment(url: segementModel.url!, info: nil)
                recordSession.addSegment(segment)
            }
            self.exportViewWithURL(recordSession.assetRepresentingSegments(), completionHandler: { [weak self]  (url) in
                guard let `self` = self else { return }
                if let exportURL = url {
                    DispatchQueue.main.async {
                        if let youTubeUploadVC = R.storyboard.youTubeUpload.youTubeUploadViewController() {
                            youTubeUploadVC.videoUrl = exportURL
                            self.navigationController?.pushViewController(youTubeUploadVC, animated: true)
                        }
                    }
                }
            })
        } else {
            let recordSession = SCRecordSession()
            for url in self.videoUrls {
                for segementModel in url.videos {
                    let segment = SCRecordSessionSegment(url: segementModel.url!, info: nil)
                    recordSession.addSegment(segment)
                }
            }
            self.exportViewWithURL(recordSession.assetRepresentingSegments(), completionHandler: { [weak self] (url) in
                guard let `self` = self else { return }
                if let exportURL = url {
                    DispatchQueue.main.async {
                        if let youTubeUploadVC = R.storyboard.youTubeUpload.youTubeUploadViewController() {
                            youTubeUploadVC.videoUrl = exportURL
                            self.navigationController?.pushViewController(youTubeUploadVC, animated: true)
                        }
                    }
                }
            })
        }
    }
    
    @IBAction func btnPostToFeedClick(_ sender: Any) {
        
    }
    
    @IBAction func messageClicked(_ sender: Any) {
        
    }
    
    @IBAction func uploadToYouTubeClicked(_ sender: Any) {
        
    }
    
    @IBAction func setCoverClicked(_ sender: Any) {
        if thumbHeight.constant == 0.0 {
            guard let player = self.scPlayer else { return }
            player.pause()
            player.seek(to: CMTime.zero)
            
            self.segmentedProgressBar.pauseProgress()
            let mergeSession = SCRecordSession.init()
            for segementModel in videoUrls[currentPage].videos {
                let segment = SCRecordSessionSegment(url: segementModel.url!, info: nil)
                mergeSession.addSegment(segment)
            }
            self.thumbSelectorView.asset = mergeSession.assetRepresentingSegments()
            
            self.thumbSelectorView.delegate = self
            thumbHeight.constant = 55.0
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            guard let player = self.scPlayer else { return }
            !pausePlayButton.isSelected ? player.play() : nil
            
            self.segmentedProgressBar.startProgress()
            thumbHeight.constant = 0.0
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
    @IBAction func saveImageVideoButtonTapped(_ sender: Any) {
        if image != nil && currentCamaraMode != .slideshow {
            let album = SCAlbum.shared
            album.albumName = "\(Constant.Application.displayName) - \(R.string.localizable.outtakes())"
            album.save(image: canvasView.toImage())
            self.view.makeToast(R.string.localizable.photoSaved(), duration: 2.0, position: .bottom)
        } else if currentCamaraMode == .slideshow {
            if let exportURL = exportedURL {
                DispatchQueue.runOnMainThread {
                    self.saveVideo(exportType: SlideShowExportType.outtakes, url: exportURL)
                }
            }
            else {
                self.saveSlideShow(exportType: SlideShowExportType.feed,
                                   success: { [weak self] exportURL in
                                    guard let `self` = self else { return }
                                    self.exportedURL = exportURL
                                    self.saveVideo(exportType: SlideShowExportType.outtakes, url: exportURL)
                    },
                                   failure: { error in
                                    print(error)
                })
            }
        } else {
            saveToCameraRoll(true, false)
        }
    }
    
    @IBAction func doneTagEditButtonTapped(_ sender: Any) {
        hideToolbar(hide: false)
        doneTagEditButton.isHidden = true
        mensionPickerView.isHidden = true
        emojiPickerView.isHidden = true
        self.removeTransparentView()
        if let tView = self.currentTagView as? StoryTagView,
            (tView.text?.trim.count ?? 0) > 0 {
            tView.translatesAutoresizingMaskIntoConstraints = true
            tView.completeEdit()
            self.addGestures(view: tView)
            tView.center = self.canvasImageView.center
            if let mension = tView.selectedMension {
                let tag = setUpStoryTagFor(tagView: tView,
                                           tagType: StoryTagType.mension,
                                           tagText: mension.channelId ?? "")
                tag.userId = mension.id
                tag.userProfileURL = mension.profileImageURL
                storyTags.append(BaseStoryTag(view: tView, tag: tag))
            } else {
                let tag = setUpStoryTagFor(tagView: tView,
                                           tagType: StoryTagType.hashtag,
                                           tagText: tView.text ?? "")
                storyTags.append(BaseStoryTag(view: tView, tag: tag))
            }
        } else if let queView = currentTagView as? StorySliderQueView {
            queView.sliderValue = 0
            queView.translatesAutoresizingMaskIntoConstraints = true
            queView.completeEdit()
            self.addGestures(view: queView)
            queView.center = self.canvasImageView.center
        } else if let queView = currentTagView as? StoryAskQuestionView {
            queView.translatesAutoresizingMaskIntoConstraints = true
            queView.completeEdit()
            self.addGestures(view: queView)
            queView.center = self.canvasImageView.center
        } else if let queView = currentTagView as? StoryPollQueView {
            queView.translatesAutoresizingMaskIntoConstraints = true
            queView.completeEdit()
            self.addGestures(view: queView)
            queView.center = self.canvasImageView.center
        } else {
            currentTagView?.removeFromSuperview()
        }
        currentTagView = nil
    }
    
    func removeTransparentView() {
        let trasparentViews = self.canvasImageView.subViews(type: TrasparentTagView.self)
        for view in trasparentViews {
            view.removeFromSuperview()
        }
    }
    
    func saveToCameraRoll(_ isOuttakes: Bool = true, _ isNotes: Bool = false) {
        self.videos = []
        if !isOuttakes && !isNotes {
            if self.selectedVideoUrlSave == nil {
                var internalStoryData = [InternalStoryData]()
                
                let isCombineSegments = !Defaults.shared.isCombineSegments
                
                if !isCombineSegments {
                    if self.videoUrls.count > 1 {
                        for (index, _) in self.videoUrls.enumerated() {
                            if index != 0 {
                                self.videoUrls[0].numberOfSegementtext = "\(self.videoUrls[0].numberOfSegementtext!) - \(self.videoUrls[index].numberOfSegementtext!)"
                                
                                for (_, item) in self.videoUrls[index].videos.enumerated() {
                                    self.videoUrls[0].videos.append(item)
                                }
                            }
                        }
                        
                        self.videoUrls[0].currentAsset = SegmentVideos.getRecordSession(videoModel: self.videoUrls[0].videos)
                        
                        let tempFirstSegment = self.videoUrls.first
                        self.videoUrls.removeAll()
                        self.videoUrls.append(tempFirstSegment!)
                    }
                }
                
                if let storyId = self.storyId, !storyRePost {
                    
                    let loadingView = LoadingView.instanceFromNib()
                    loadingView.shouldCancelShow = true
                    loadingView.loadingViewShow = true
                    loadingView.show(on: view)
                    
                    let mergeSession = SCRecordSession.init()
                    for segementModel in self.videoUrls.first!.videos {
                        let segment = SCRecordSessionSegment(url: segementModel.url!, info: nil)
                        mergeSession.addSegment(segment)
                    }
                    
                    self.exportViewWithURL(mergeSession.assetRepresentingSegments()) { [weak self] url in
                        guard let strongSelf = self else { return }
                        
                        if let exportURL = url {
                            let fileName = String.fileName + ".mp4"
                            if let imgThumb = UIImage.getThumbnailFrom(videoUrl: exportURL) {
                                let resizeImg = imgThumb.resizeImage(newWidth: 180)
                                let thumbName = "thumb" + fileName.replacingOccurrences(of: ".mp4", with: FileExtension.jpg.rawValue)
                                Utils.uploadImage(imgName: thumbName,
                                                  img: resizeImg,
                                                  callBack: { url1 -> Void in
                                                    if let videoData = try? Data(contentsOf: exportURL,
                                                                                 options: Data.ReadingOptions.alwaysMapped) {
                                                        Utils.uploadVideo(videoName: fileName,
                                                                          videoData: videoData,
                                                                          progressBlock: { _ in
                                                                            
                                                        },
                                                                          callBack: { url in
                                                                            loadingView.hide()
                                                                            strongSelf.editStory(storyId, storyURL: url, thumbURL: url1)
                                                        })
                                                    }
                                })
                            }
                            
                        }
                    }
                    return
                }
                
                for url in videoUrls {
                    var urls = [String]()
                    for segementModel in url.videos {
                        urls.append(segementModel.url?.absoluteString ?? "")
                    }
                    let fileName = String.fileName + FileExtension.png.rawValue
                    let data = self.canvasView.toVideoImage().pngData()
                    let watermarkURL = Utils.getLocalPath(fileName)
                    try? data?.write(to: watermarkURL)
                    
                    if let scFilter = self.filterSwitcherView?.selectedFilter?.ciFilter.copy() as? CIFilter {
                        var filterName = scFilter.name
                        if scFilter.name == "CIColorCube",
                            let lutImagePath = self.filterSwitcherView?.selectedFilter?.path {
                            filterName = lutImagePath
                        }
                        let internalStoryTags = getTags()
                        let storyData = InternalStoryData(address: self.address, duration: "", lat: self.lat, long: self.long, thumbTime: url.thumbTime!.seconds, type: "video", url: "", userId: Defaults.shared.currentUser?.id ?? "", watermarkURL: watermarkURL.absoluteString, isMute: self.isMute, filterName: filterName, exportedUrls: urls, hiddenHashtags: self.hiddenHashtags.joined(separator: " "), tags: internalStoryTags)
                        let tx = self.dummyView.frame.origin.x*100 / self.filterSwitcherView!.frame.size.width
                        let ty = self.dummyView.frame.origin.y*100 / self.filterSwitcherView!.frame.size.height
                        
                        let scaleX = sqrt(pow(dummyView.transform.a, 2) + pow(dummyView.transform.c, 2))
                        let scaleY = sqrt(pow(dummyView.transform.b, 2) + pow(dummyView.transform.d, 2))
                        
                        let rotation = atan2(self.dummyView.transform.b, self.dummyView.transform.a)
                        
                        storyData.videotx = Double(tx)
                        storyData.videoty = Double(ty)
                        storyData.videoScaleX = Double(scaleX)
                        storyData.videoScaleY = Double(scaleY)
                        storyData.videoRotation = Double(rotation)
                        storyData.hasTransformation = true
                        storyData.storiType = storyRePost ? .shared : self.storiType
                        internalStoryData.append(storyData)
                    }
                }
                
                _ = StoryDataManager.shared.createStoryUploadData(internalStoryData)
                StoryDataManager.shared.startUpload()
                
                self.dismiss()
                
            } else if let url = self.selectedVideoUrlSave {
                var internalStoryData = [InternalStoryData]()
                
                var urls = [String]()
                for segementModel in url.videos {
                    urls.append(segementModel.url?.absoluteString ?? "")
                }
                let fileName = String.fileName + FileExtension.png.rawValue
                let data = self.canvasView.toVideoImage().pngData()
                let watermarkURL = Utils.getLocalPath(fileName)
                try? data?.write(to: watermarkURL)
                
                if let scFilter = self.filterSwitcherView?.selectedFilter?.ciFilter.copy() as? CIFilter {
                    var filterName = scFilter.name
                    if scFilter.name == "CIColorCube",
                        let lutImagePath = self.filterSwitcherView?.selectedFilter?.path {
                        filterName = lutImagePath
                    }
                    let internalStoryTags = getTags()
                    let storyData = InternalStoryData(address: self.address, duration: "", lat: self.lat, long: self.long, thumbTime: url.thumbTime!.seconds, type: "video", url: "", userId: Defaults.shared.currentUser?.id ?? "", watermarkURL: watermarkURL.absoluteString, isMute: self.isMute, filterName: filterName, exportedUrls: urls, hiddenHashtags: self.hiddenHashtags.joined(separator: " "), tags: internalStoryTags)
                    let tx = self.dummyView.frame.origin.x*100 / self.filterSwitcherView!.frame.size.width
                    let ty = self.dummyView.frame.origin.y*100 / self.filterSwitcherView!.frame.size.height
                    
                    let scaleX = sqrt(pow(dummyView.transform.a, 2) + pow(dummyView.transform.c, 2))
                    let scaleY = sqrt(pow(dummyView.transform.b, 2) + pow(dummyView.transform.d, 2))
                    
                    let rotation = atan2(self.dummyView.transform.b, self.dummyView.transform.a)
                    storyData.videotx = Double(tx)
                    storyData.videoty = Double(ty)
                    storyData.videoScaleX = Double(scaleX)
                    storyData.videoScaleY = Double(scaleY)
                    storyData.videoRotation = Double(rotation)
                    storyData.hasTransformation = true
                    storyData.storiType = storyRePost ? .shared : self.storiType
                    internalStoryData.append(storyData)
                }
                
                _ = StoryDataManager.shared.createStoryUploadData(internalStoryData)
                StoryDataManager.shared.startUpload()
                
            }
            return
        }
        
        let exportGroup = DispatchGroup()
        let exportQueue = DispatchQueue(label: "exportFilterQueue")
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        
        if let url = self.selectedVideoUrlSave {
            exportQueue.async {
                exportGroup.enter()
                self.exportVideo(segmentVideos: url, isOuttakes, isNotes) { (_) in
                    dispatchSemaphore.signal()
                    exportGroup.leave()
                }
                
                dispatchSemaphore.wait()
            }
        } else {
            if isOuttakes {
                self.outtakesExportLabel.text = "0/\(self.videoUrls.count)"
            } else if isNotes {
                self.notesExportLabel.text = "0/\(self.videoUrls.count)"
            } else {
                self.storyExportLabel.text = "0/\(self.videoUrls.count)"
            }
            
            exportQueue.async {
                for (index, url) in self.videoUrls.enumerated() {
                    exportGroup.enter()
                    DispatchQueue.runOnMainThread {
                        self.exportVideo(segmentVideos: url, isOuttakes, isNotes, index: index) { (_) in
                            dispatchSemaphore.signal()
                            exportGroup.leave()
                        }
                    }
                    dispatchSemaphore.wait()
                }
            }
        }
        
        exportGroup.notify(queue: exportQueue) {
            DispatchQueue.runOnMainThread {
                if self.selectedVideoUrlSave == nil && self.storyId == nil {
                    if isOuttakes {
                        self.view.makeToast(R.string.localizable.videoSaved(), duration: 2.0, position: .bottom)
                    }
                } else {
                    self.outtakesView.isUserInteractionEnabled = true
                    self.selectedVideoUrlSave = nil
                    self.outtakesProgress.updateProgress(0)
                    self.notesProgress.updateProgress(0)
                    self.postStoryProgress.updateProgress(0)
                }
            }
            
        }
    }
    
    func exportVideo(segmentVideos: SegmentVideos, _ isOuttakes: Bool = true, _ isNotes: Bool = false, index: Int = 0, completionHandler: @escaping (_ url: Bool?) -> Void) {
        
        let mergeSession = SCRecordSession.init()
        for segementModel in segmentVideos.videos {
            let segment = SCRecordSessionSegment(url: segementModel.url!, info: nil)
            mergeSession.addSegment(segment)
        }
        self.exportViewWithURL(mergeSession.assetRepresentingSegments()) { [weak self] url in
            guard let strongSelf = self else { return }
            if let exportURL = url {
                
                let album = SCAlbum.shared
                if isOuttakes {
                    album.albumName = "\(Constant.Application.displayName) - \(R.string.localizable.outtakes())"
                    DispatchQueue.main.async {
                        strongSelf.outtakesExportLabel.text = "\(index+1)/\(strongSelf.videoUrls.count)"
                    }
                } else if isNotes {
                    album.albumName = "\(Constant.Application.displayName) - \(R.string.localizable.notes())"
                    DispatchQueue.main.async {
                        strongSelf.notesExportLabel.text = "\(index+1)/\(strongSelf.videoUrls.count)"
                    }
                } else {
                    album.albumName = "\(Constant.Application.displayName)"
                    DispatchQueue.main.async {
                        strongSelf.storyExportLabel.text = "\(index+1)/\(strongSelf.videoUrls.count)"
                    }
                }
                
                if let storyId = strongSelf.storyId, !strongSelf.storyRePost {
                    let fileName = String.fileName + ".mp4"
                    
                    if let imgThumb = UIImage.getThumbnailFrom(videoUrl: exportURL) {
                        strongSelf.showHUD()
                        let resizeImg = imgThumb.resizeImage(newWidth: 180)
                        let thumbName = "thumb" + fileName.replacingOccurrences(of: ".mp4", with: FileExtension.jpg.rawValue)
                        Utils.uploadImage(imgName: thumbName,
                                          img: resizeImg,
                                          callBack: { url1 -> Void in
                                            if let videoData = try? Data(contentsOf: exportURL,
                                                                         options: Data.ReadingOptions.alwaysMapped) {
                                                Utils.uploadVideo(videoName: fileName,
                                                                  videoData: videoData,
                                                                  progressBlock: { _ in
                                                                    
                                                },
                                                                  callBack: { url in
                                                                    strongSelf.editStory(storyId, storyURL: url, thumbURL: url1)
                                                })
                                            }
                        })
                    }
                } else {
                    album.saveMovieToLibrary(movieURL: exportURL)
                }
                if !isOuttakes && !isNotes {
                    do {
                        try strongSelf.videoUrls[(strongSelf.draggingCell?.row)!].image!.compressImage(300, completion: { [weak self] (image, _) in
                            guard let strongSelf = self else { return }
                            let avPlayer = AVPlayer(url: exportURL)
                            if let duration = avPlayer.currentItem?.asset.duration {
                                let video = FilterImage(url: exportURL, index: 0)
                                video.thumbImage = image
                                video.thumbTime = duration
                                strongSelf.videos.append(video)
                            }
                        })
                    } catch {
                        
                    }
                }
                completionHandler(true)
            }
            
        }
    }
    
    func exportViewWithURL(_ asset: AVAsset, completionHandler: @escaping (_ url: URL?) -> Void) {
        
        let exportSession = StoryAssetExportSession()
        
        DispatchQueue.runOnMainThread {
            if let loadingView = self.loadingView {
                loadingView.progressView.setProgress(to: Double(0), withAnimation: true)
                loadingView.show(on: self.view, completion: {
                    loadingView.cancelClick = { [weak self] _ in
                        guard let `self` = self else { return }
                        DispatchQueue.runOnMainThread {
                            self.outtakesExportLabel.text = ""
                            self.notesExportLabel.text = ""
                        }
                        exportSession.cancelExporting()
                        loadingView.hide()
                    }
                })
            }
        }
        
        if let filter = self.filterSwitcherView?.selectedFilter,
            filter.name != "" {
            exportSession.filter = filter.ciFilter
        }
        exportSession.isMute = isMute
        exportSession.overlayImage = canvasView.toVideoImage()
        let tx = self.dummyView.frame.origin.x*100 / self.filterSwitcherView!.frame.size.width
        let ty = self.dummyView.frame.origin.y*100 / self.filterSwitcherView!.frame.size.height
        
        let scaleX = sqrt(pow(dummyView.transform.a, 2) + pow(dummyView.transform.c, 2))
        let scaleY = sqrt(pow(dummyView.transform.b, 2) + pow(dummyView.transform.d, 2))
        
        let rotation = atan2(self.dummyView.transform.b, self.dummyView.transform.a)
        
        exportSession.inputTransformation = StoryImageView.ImageTransformation(tx: tx, ty: ty, scaleX: scaleX, scaleY: scaleY, rotation: rotation)
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
    
    func editStory(_ storyId: String, storyURL: String, thumbURL: String?) {
        let loadingView = LoadingView.instanceFromNib()
        loadingView.shouldCancelShow = true
        loadingView.loadingViewShow = true
        loadingView.show(on: view)
        let storyTagsSet = getTags()
        
        var storyTagDict: [[String: Any]]?
        var storyHashTags: [String]?
        if let storyTags = Array(storyTagsSet) as? [InternalStoryTag] {
            for tag in storyTags {
                var tagDict = [
                    "tagType": tag.tagType,
                    "tagFontSize": tag.tagFontSize,
                    "tagHeight": tag.tagHeight,
                    "tagWidth": tag.tagWidth,
                    "centerX": tag.centerX,
                    "centerY": tag.centerY,
                    "scaleX": tag.scaleX,
                    "scaleY": tag.scaleY,
                    "rotation": tag.rotation,
                    "tagText": tag.tagText,
                    "Latitude": tag.latitude ,
                    "Longitude": tag.longitude ,
                    "themeType": tag.themeType,
                    "videoId": tag.videoId,
                    "userProfileURL": tag.userProfileURL ?? "",
                    "hasRatio": UIScreen.haveRatio
                    ] as [String: Any]
                if let postID = tag.postId {
                    tagDict["postId"] = postID
                }
                if let storyID = tag.storyID {
                    tagDict["storyId"] = storyID
                }
                if let tagUserId = tag.userId {
                    tagDict["userId"] = tagUserId
                }
                if let placeId = tag.placeId {
                    tagDict["placeId"] = placeId
                }
                if let playlistId = tag.playlistId {
                    tagDict["playListId"] = playlistId
                }
                if let sliderTag = tag.sliderTag,
                    let sliderTagDict = sliderTag.json2dict() {
                    tagDict["sliderTag"] = sliderTagDict
                }
                if let askQuestionTag = tag.askQuestionTag,
                    let askQuestionTagDict = askQuestionTag.json2dict() {
                    tagDict["askQuestionTag"] = askQuestionTagDict
                }
                if let pollTag = tag.pollTag,
                    let pollTagDict = pollTag.json2dict() {
                    tagDict["pollTag"] = pollTagDict
                }
                if storyTagDict == nil {
                    storyTagDict = [tagDict]
                } else {
                    storyTagDict?.append(tagDict)
                }
                if tag.tagType == StoryTagType.hashtag.rawValue {
                    if storyHashTags == nil {
                        storyHashTags = ["#\(tag.tagText)"]
                    } else {
                        storyHashTags?.append("#\(tag.tagText)")
                    }
                }
            }
        }
        
        for hiddenHashtag in self.hiddenHashtags {
            if storyHashTags == nil {
                storyHashTags = [hiddenHashtag]
            } else {
                storyHashTags?.append(hiddenHashtag)
            }
        }
        
        ProManagerApi
            .editStory(storyId: storyId, storyURL: storyURL, duration: nil, type: nil, storiType: nil, user: Defaults.shared.currentUser?.id ?? "", thumb: thumbURL, lat: nil, long: nil, address: nil, tags: storyTagDict, hashtags: storyHashTags, publish: publish)
            .request(ResultArray<Channel>.self)
            .subscribe(onNext: { (_) in
                AppEventBus.post("ReloadStoryAfterPost", sender: self)
                self.dismissHUD()
                loadingView.hide()
                self.dismiss()
            }, onError: { (_) in
            }).disposed(by: self.rx.disposeBag)
    }
    
    func saveSlideShow(exportType: SlideShowExportType, success: @escaping ((URL) -> Void), failure: @escaping ((Error) -> Void)) {
        
        DispatchQueue.runOnMainThread {
            if let loadingView = self.loadingView {
                loadingView.progressView.setProgress(to: Double(0), withAnimation: true)
                loadingView.shouldCancelShow = true
                loadingView.show(on: self.view, completion: {
                    
                })
            }
        }
        
        let slideShowImages = self.selectedSlideShowImages.filter({ (segmentVideo) -> Bool in
            return (segmentVideo != nil)
        })
        guard !slideShowImages.isEmpty else {
            return
        }
        
        var imageData: [UIImage] = []
        for segmentVideo in self.selectedSlideShowImages {
            if segmentVideo != nil {
                if let img = segmentVideo?.image {
                    imageData.append(img)
                }
            }
        }
        
        let allSegment = self.selectedSlideShowImages.filter({ (segmentVideo) -> Bool in
            return (segmentVideo != nil)
        })
        
        var savedSlideShowImages: [SegmentVideos] = []
        
        for segmentVideo in self.videoUrls {
            var isExist = false
            for allUrl in allSegment {
                if segmentVideo.id == allUrl?.id {
                    isExist = true
                    break
                }
            }
            
            if !isExist {
                savedSlideShowImages.append(segmentVideo)
            }
            
        }
        
        for segmentVideo in savedSlideShowImages {
            let album = SCAlbum.shared
            album.albumName = "\(Constant.Application.displayName) - \(R.string.localizable.outtakes())"
            if let img = segmentVideo.image {
                album.save(image: img)
            }
        }
        
        switch exportType {
        case .outtakes:
            self.outtakesExportLabel.text = "0/1"
        case .notes:
            self.notesExportLabel.text = "0/1"
        case .chat:
            self.chatExportLabel.text = "0/1"
        case .feed:
            self.feedExportLabel.text = "0/1"
        case .story:
            self.storyExportLabel.text = "0/1"
        case .sendChat:
            break
        }
        
        VideoGenerator.current.fileName = String.fileName
        VideoGenerator.current.shouldOptimiseImageForVideo = true
        VideoGenerator.current.videoDurationInSeconds = Double(imageData.count)*1.5
        VideoGenerator.current.maxVideoLengthInSeconds = Double(imageData.count)*1.5
        VideoGenerator.current.videoBackgroundColor = ApplicationSettings.appBlackColor
        VideoGenerator.current.scaleWidth = 720
        VideoGenerator.current.scaleHeight = 1280
        
        VideoGenerator.current.generate(withImages: imageData, andAudios: self.selectedUrl != nil ? [self.selectedUrl!] : [], andType: .singleAudioMultipleImage, { [weak self] progress in
            guard let `self` = self else { return }
            DispatchQueue.runOnMainThread {
                if let loadingView = self.loadingView {
                    let progressCompleted = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
                    loadingView.progressView.setProgress(to: Double(progressCompleted), withAnimation: true)
                }
            }
            }, success: { [weak self] url in
                guard let `self` = self else { return }
                if let loadingView = self.loadingView {
                    loadingView.hide()
                }
                success(url)
            }, failure: { [weak self] error in
                guard let `self` = self else { return }
                if let loadingView = self.loadingView {
                    loadingView.hide()
                }
                failure(error)
        })
    }
    
    func saveVideo(exportType: SlideShowExportType, url: URL) {
        var thumbImage: UIImage?
        
        for segmentVideo in self.selectedSlideShowImages {
            if segmentVideo != nil {
                if let img = segmentVideo?.image {
                    if thumbImage == nil {
                        thumbImage = img
                    }
                }
            }
        }
        
        var mediaArray: [FilterImage] = []
        
        let album = SCAlbum.shared
        switch exportType {
        case .outtakes:
            album.albumName = "\(Constant.Application.displayName) - \(R.string.localizable.outtakes())"
            album.saveMovieToLibrary(movieURL: url)
            DispatchQueue.runOnMainThread {
                self.view.makeToast(R.string.localizable.videoSaved(), duration: 2.0, position: .bottom)
            }
        case .notes:
            album.albumName = "\(Constant.Application.displayName) - \(R.string.localizable.notes())"
            album.saveMovieToLibrary(movieURL: url)
            DispatchQueue.runOnMainThread {
                self.view.makeToast(R.string.localizable.videoSaved(), duration: 2.0, position: .bottom)
            }
        case .chat:
            DispatchQueue.main.async {
                self.chatExportLabel.text = "1/1"
            }
        case .feed:
            DispatchQueue.main.async {
                self.feedExportLabel.text = "1/1"
                let video = FilterImage(url: url, index: 0)
                video.thumbImage = thumbImage
                mediaArray.append(video)
            }
        case .story:
            let videoSegment = AVAsset.init(url: url)
            
            let urls = [url.absoluteString]
            let fileName = String.fileName + FileExtension.png.rawValue
            let data = self.canvasView.toVideoImage().pngData()
            
            let watermarkURL = Utils.getLocalPath(fileName)
            try? data?.write(to: watermarkURL)
            var internalStoryData = [InternalStoryData]()
            
            if let scFilter = self.filterSwitcherView?.selectedFilter?.ciFilter.copy() as? CIFilter {
                var filterName = scFilter.name
                if scFilter.name == "CIColorCube",
                    let lutImagePath = self.filterSwitcherView?.selectedFilter?.path {
                    filterName = lutImagePath
                }
                let internalStoryTags = getTags()
                let storyData = InternalStoryData(address: self.address, duration: "\(videoSegment.duration.seconds)", lat: self.lat, long: self.long, thumbTime: 1.0, type: "slideshow", url: "", userId: Defaults.shared.currentUser?.id ?? "", watermarkURL: watermarkURL.absoluteString, isMute: self.isMute, filterName: filterName, exportedUrls: urls, hiddenHashtags: self.hiddenHashtags.joined(separator: " "), tags: internalStoryTags)
                storyData.storiType = self.storiType
                internalStoryData.append(storyData)
            }
            
            _ = StoryDataManager.shared.createStoryUploadData(internalStoryData)
            
            StoryDataManager.shared.startUpload()
            
            self.dismiss()
        case .sendChat:
            break
        }
    }
    
    func saveImage(exportType: SlideShowExportType, image: UIImage) {
        var thumbImage: UIImage?
        
        for segmentVideo in self.selectedSlideShowImages {
            if segmentVideo != nil {
                if let img = segmentVideo?.image {
                    if thumbImage == nil {
                        thumbImage = img
                    }
                }
            }
        }
        
        let album = SCAlbum.shared
        switch exportType {
        case .outtakes:
            album.albumName = "\(Constant.Application.displayName) - Outtakes"
            album.save(image: image)
            self.outtakesDelegate?.didTakeOuttakes("Outtakes saved.")
            self.dismiss()
        case .notes:
            album.albumName = "\(Constant.Application.displayName) - Notes"
            album.save(image: image)
            self.outtakesDelegate?.didTakeOuttakes("Notes saved.")
            self.dismiss()
        case .chat:
            break
        case .feed:
            break
        case .story:
            let image = self.canvasView.toImage()
            album.save(image: image)
            var storyTime = "3.0"
            
            let fileName = String.fileName + FileExtension.jpg.rawValue
            let data = image.jpegData(compressionQuality: 1.0)
            let url = Utils.getLocalPath(fileName)
            try? data?.write(to: url)
            let internalStoryTags = getTags()
            if !internalStoryTags.isEmpty {
                storyTime = "6.0"
            }
            let storyData = InternalStoryData(address: self.address, duration: storyTime, lat: self.lat, long: self.long, thumbTime: 0.0, type: "image", url: url.absoluteString, userId: Defaults.shared.currentUser?.id ?? "", watermarkURL: "", isMute: false, filterName: nil, exportedUrls: [""], hiddenHashtags: self.hiddenHashtags.joined(separator: " "), tags: internalStoryTags)
            storyData.storiType = storyRePost ? .shared : self.storiType
            _ = StoryDataManager.shared.createStoryUploadData([storyData])
            StoryDataManager.shared.startUpload()
            self.dismiss()
        case .sendChat:
            break
        }
    }
}

extension PhotoEditorViewController {
    @objc func longTap(_ recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == .began else { return }
        btnChannelClicked()
    }
    
    func btnChannelClicked() {
        
    }
    
    func configureMensionCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        mensionCollectionView.collectionViewLayout = layout
        mensionCollectionViewDelegate = MensionCollectionViewDelegate()
        mensionCollectionViewDelegate.mensionDelegate = self
        mensionCollectionView.delegate = mensionCollectionViewDelegate
        mensionCollectionView.dataSource = mensionCollectionViewDelegate
        
        mensionCollectionView.register(
            UINib(resource: R.nib.mensionCollectionViewCell),
            forCellWithReuseIdentifier: R.nib.mensionCollectionViewCell.identifier)
    }
    
    func configureEmojiCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (UIScreen.width - 20)/8,
                                 height: (UIScreen.width - 20)/8)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        emojiCollectionView.collectionViewLayout = layout
        emojiCollectionView.isPagingEnabled = true
        emojiCollectionViewDelegate = EmojiCollectionViewDelegate()
        emojiCollectionViewDelegate.emojiDelegate = self
        emojiCollectionView.register(
            UINib(resource: R.nib.queSliderCollectionViewCell),
            forCellWithReuseIdentifier: R.nib.queSliderCollectionViewCell.identifier)
        emojiCollectionView.delegate = emojiCollectionViewDelegate
        emojiCollectionView.dataSource = emojiCollectionViewDelegate
        
    }
    
    func setupExistingTags() {
        switch self.storiCamType {
        case .shareYoutube(let postData):
            if let youtubeData = postData.youTubeData {
                let tagView = self.addTagViewFor(youtubeData["title"] as? String ?? "", type: StoryTagType.youtube)
                let youTubeTag = setUpStoryTagFor(tagView: tagView,
                                                  tagType: StoryTagType.youtube,
                                                  tagText: youtubeData["title"] as? String ?? "")
                youTubeTag.videoId = youtubeData["videoId"] as? String ?? ""
                self.storyTags.append(BaseStoryTag(view: tagView, tag: youTubeTag))
            }
        case .shareFeed(let postID):
            let tagView = self.addTagViewFor("View Post", type: StoryTagType.feed)
            let feedTag = setUpStoryTagFor(tagView: tagView,
                                           tagType: StoryTagType.feed,
                                           tagText: "View Post")
            feedTag.postId = postID
            self.storyTags.append(BaseStoryTag(view: tagView, tag: feedTag))
        case .shareStory(let storyID):
            let tagView = self.addTagViewFor("View Story", type: StoryTagType.story)
            let storytag = setUpStoryTagFor(tagView: tagView,
                                            tagType: StoryTagType.story,
                                            tagText: "View Story")
            storytag.storyID = storyID
            self.storyTags.append(BaseStoryTag(view: tagView, tag: storytag))
        case .replyStory(let question, let answer):
            let replyAskQueView = AskQuestionReplyView()
            replyAskQueView.questionText = question
            replyAskQueView.answerText = answer
            self.canvasImageView.addSubview(replyAskQueView)
            
            replyAskQueView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                replyAskQueView.centerXAnchor.constraint(equalTo: self.canvasImageView.centerXAnchor, constant: 0),
                replyAskQueView.centerYAnchor.constraint(equalTo: self.canvasImageView.centerYAnchor, constant: 0),
                replyAskQueView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.7)
            ])
            replyAskQueView.layoutIfNeeded()
            replyAskQueView.updateColors()
            self.addGestures(view: replyAskQueView)
        default:
            break
        }
    }
    
    func addTagViewFor(_ text: String, type: StoryTagType) -> StoryTagView {
        let tagView = StoryTagView.init(tagType: type)
        self.canvasImageView.addSubview(tagView)
        tagView.translatesAutoresizingMaskIntoConstraints = false
        // apply constraint
        tagView.centerXAnchor.constraint(equalTo: self.canvasImageView.centerXAnchor, constant: 0).isActive = true
        tagView.centerYAnchor.constraint(equalTo: self.canvasImageView.centerYAnchor, constant: 0).isActive = true
        tagView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        tagView.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.width - 10).isActive = true
        // set text
        tagView.text = text
        tagView.translatesAutoresizingMaskIntoConstraints = true
        tagView.completeEdit()
        self.addGestures(view: tagView)
        tagView.center = self.canvasImageView.center
        return tagView
    }
    
    func setUpStoryTagFor(tagView: BaseStoryTagView, tagType: StoryTagType, tagText: String) -> InternalStoryTag {
        return InternalStoryTag(tagType: tagType.rawValue,
                                tagFontSize: 20.0,
                                tagHeight: Float(tagView.height),
                                tagWidth: Float(tagView.width),
                                centerX: Float(tagView.xGlobalCenterPoint),
                                centerY: Float(tagView.yGlobalCenterPoint),
                                scaleX: Float(tagView.scaleXValue),
                                scaleY: Float(tagView.scaleYValue),
                                rotation: Float(tagView.rotationValue),
                                tagText: tagText,
                                latitude: 0,
                                longitude: 0,
                                themeType: StoryTagState.white.rawValue,
                                videoId: "")
    }
    
    func getPosition(from time: CMTime, cell: ImageCollectionViewCell, index: IndexPath) -> CGFloat? {
        if let cell: ImageCollectionViewCell = self.stopMotionCollectionView.cellForItem(at: IndexPath.init(row: self.currentPage, section: 0)) as? ImageCollectionViewCell {
            let asset = self.videoUrls[self.currentPage].currentAsset
            let timeRatio = CGFloat(time.value) * CGFloat(asset!.duration.timescale) /
                (CGFloat(time.timescale) * CGFloat(asset!.duration.value))
            return timeRatio * cell.bounds.width
        }
        return 0
    }
    
    func addGestures(view: UIView) {
        // Gestures
        view.isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(PhotoEditorViewController.panGesture(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(PhotoEditorViewController.pinchGesture(_:)))
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self,
                                                                    action: #selector(PhotoEditorViewController.rotationGesture))
        rotationGestureRecognizer.delegate = self
        view.addGestureRecognizer(rotationGestureRecognizer)
        
        if view is CameraView {
            
        } else {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PhotoEditorViewController.tapGesture(_:)))
            view.addGestureRecognizer(tapGesture)
        }
        
    }
}
