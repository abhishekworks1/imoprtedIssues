//
//  PhotoEditiorViewController+Delegates.swift
//  SocialCAM
//
//  Created by Viraj Patel on 04/11/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import SCRecorder
import GooglePlacePicker
import URLEmbeddedView

extension PhotoEditorViewController: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        let rotation = atan2(textView.transform.b, textView.transform.a)
        if rotation == 0 {
            let oldFrame = textView.frame
            let sizeToFit = textView.sizeThatFits(CGSize(width: oldFrame.width, height: CGFloat.greatestFiniteMagnitude))
            textView.frame.size = CGSize(width: oldFrame.width, height: sizeToFit.height)
        }
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        isTyping = true
        lastTextViewTransform =  textView.transform
        lastTextViewTransCenter = textView.center
        lastTextViewFont = textView.font!
        activeTextView = textView
        textView.superview?.bringSubviewToFront(textView)
        textView.font = UIFont(name: "Helvetica", size: 30)
        UIView.animate(withDuration: 0.3,
                       animations: {
                        textView.transform = CGAffineTransform.identity
                        textView.center = CGPoint(x: UIScreen.main.bounds.width / 2,
                                                  y: UIScreen.main.bounds.height / 5)
        }, completion: nil)
        
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        guard lastTextViewTransform != nil && lastTextViewTransCenter != nil && lastTextViewFont != nil
            else {
                return
        }
        activeTextView = nil
        textView.font = self.lastTextViewFont!
        UIView.animate(withDuration: 0.3,
                       animations: {
                        textView.transform = self.lastTextViewTransform!
                        textView.center = self.lastTextViewTransCenter!
        }, completion: nil)
    }
    
}

extension PhotoEditorViewController: StickersViewControllerDelegate {
    
    func stickersViewDidDisappear() {
        
        stickersVCIsVisible = false
        hideToolbar(hide: false)
        self.canvasImageView.isUserInteractionEnabled = true
    }
    
    func didSelectView(view: UIView) {
        self.removeStickersView()
        
        view.center = canvasImageView.center
        self.canvasImageView.addSubview(view)
        // Gestures
        addGestures(view: view)
    }
    
    func didSelectImage(sticker: StorySticker) {
        
        switch sticker.type {
        case .image:
            self.removeStickersView()
            
            let imageView = UIImageView(image: sticker.image)
            imageView.contentMode = .scaleAspectFit
            imageView.frame.size = CGSize(width: 150, height: 150)
            imageView.center = canvasImageView.center
            
            self.canvasImageView.addSubview(imageView)
            addGestures(view: imageView)
        case .youtube:
            let objSerach = R.storyboard.youTube.youTubeViewController()
            objSerach?.shareHandler = { [weak self] (url, hash, title, channelId) in
                guard let `self` = self else { return }
                self.youTubeHashtags = hash
                if let hashtags = self.youTubeHashtags,
                    !hashtags.isEmpty {
                    var tags = [String]()
                    for hashtag in hashtags {
                        tags.append("#\(hashtag)")
                    }
                    self.youTubeHashtags = tags
                }
                OGDataProvider.shared.fetchOGData(urlString: url) { [weak self] ogData, error in
                    guard let `self` = self else { return }
                    if let _ = error {
                        return
                    }
                    let youtubeUrl = ogData.sourceUrl?.absoluteString
                    if let youId = youtubeUrl?.youTubeId {
                        self.youTubeData = ["videoUrl": youtubeUrl ?? "", "videoId": youId]
                        if let chId = channelId {
                            self.youTubeData?["channelId"] = chId
                        }
                        if let thumbUrl = ogData.imageUrl?.absoluteString {
                            self.youTubeData?["previewThumb"] = thumbUrl
                            if let title = ogData.pageTitle {
                                self.youTubeData?["title"] = title
                            }
                        }
                    }
                }
                self.removeStickersView()
                let tagView = self.addTagViewFor(title ?? url, type: StoryTagType.youtube)
                let tag = self.setUpStoryTagFor(tagView: tagView,
                                                tagType: StoryTagType.youtube,
                                                tagText: title ?? url)
                tag.videoId = url.youTubeId ?? ""
                if let youtubeTagIndex = self.storyTags.firstIndex(where: { $0.tag.tagType == StoryTagType.youtube.rawValue }) {
                    self.storyTags[youtubeTagIndex].view.removeFromSuperview()
                    self.storyTags[youtubeTagIndex] = BaseStoryTag(view: tagView, tag: tag)
                } else {
                    self.storyTags.append(BaseStoryTag(view: tagView, tag: tag))
                }
            }
            self.navigationController?.pushViewController(objSerach!, animated: true)
        case .location:
            self.removeStickersView()
            openPlacePickerView()
        case .mension:
            self.removeStickersView()
            addMensionTypeView()
        case .hashtag:
            let hashTags = self.storyTags.filter { $0.tag.tagType == StoryTagType.hashtag.rawValue }
            self.removeStickersView()
            if hashTags.count == 3 {
                let limitExceededAlert = UIAlertController.Style
                    .alert
                    .controller(title: "",
                                message: "You can add maximum three hashtags.",
                                actions: ["OK".alertAction()])
                self.present(limitExceededAlert, animated: true, completion: nil)
            } else {
                self.addHashtagTypeView()
            }
        case .camera:
            self.removeStickersView()
            self.addCameraView()
        case .day:
            self.removeStickersView()
            self.addDayTag()
        case .time(let date):
            self.removeStickersView()
            self.addTimeTag(for: date)
        case .weather(let temperature):
            self.removeStickersView()
            addWeatherTag(for: temperature)
        case .askQuestion(let type):
            self.removeStickersView()
            switch type {
            case AskQuestionType.slider.rawValue:
                addSliderQuestionView()
            case AskQuestionType.poll.rawValue:
                addPollQuestionView()
            case AskQuestionType.normal.rawValue:
                addAskQuestionView()
            default:
                break
            }
        case .emoji:
            break
        }
        
    }
    
    func addMensionTypeView() {
        self.mensionCollectionViewDelegate.mensions = []
        self.mensionCollectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.isTagTyping = true
            self.hideToolbar(hide: true)
            self.doneTagEditButton.isHidden = false
            self.currentTagView = self.addMentionTagView()
        }
    }
    
    func addHashtagTypeView() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.hideToolbar(hide: true)
            self.doneTagEditButton.isHidden = false
            self.currentTagView = self.addHashtagTagView()
        }
    }
    
    func addHashtagTagView() -> StoryTagView {
        let tagView = StoryTagView.init(tagType: StoryTagType.hashtag)
        
        addTransparentView()
        self.canvasImageView.addSubview(tagView)
        
        tagView.translatesAutoresizingMaskIntoConstraints = false
        
        tagView.centerXAnchor.constraint(equalTo: self.canvasImageView.centerXAnchor, constant: 0).isActive = true
        tagView.centerYAnchor.constraint(equalTo: self.canvasImageView.centerYAnchor, constant: 0).isActive = true
        tagView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        tagView.startEdit()
        
        return tagView
    }
    
    func addTransparentView() {
        let trasparentView = TrasparentTagView(frame: self.canvasImageView.frame)
        trasparentView.backgroundColor = ApplicationSettings.appBlackColor.withAlphaComponent(0.3)
        trasparentView.isUserInteractionEnabled = true
        self.canvasImageView.addSubview(trasparentView)
    }
    
    func addMentionTagView() -> StoryTagView {
        let tagView = StoryTagView.init(tagType: StoryTagType.mension)
        
        tagView.searchHandler = { text in
            guard !text.isEmpty else {
                self.mensionCollectionViewDelegate.mensions = []
                self.mensionCollectionView.reloadData()
                return
            }
            ProManagerApi
                .tagUserSearch(user: Defaults.shared.currentUser?.id ?? "",
                               channelName: text)
                .request(ResultArray<Channel>.self)
                .subscribe(onNext: { (channels) in
                    self.mensionCollectionViewDelegate.mensions = channels.result ?? []
                    self.mensionCollectionView.reloadData()
                }, onError: { (_) in
                }).disposed(by: self.rx.disposeBag)
        }
        addTransparentView()
        self.canvasImageView.addSubview(tagView)
        tagView.translatesAutoresizingMaskIntoConstraints = false
        
        tagView.centerXAnchor.constraint(equalTo: self.canvasImageView.centerXAnchor, constant: 0).isActive = true
        tagView.centerYAnchor.constraint(equalTo: self.canvasImageView.centerYAnchor, constant: 0).isActive = true
        tagView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        tagView.startEdit()
        
        return tagView
    }
    
    func addSliderQuestionView() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.hideToolbar(hide: true)
            self.doneTagEditButton.isHidden = false
            let queViews = self.canvasImageView.allSubViewsOf(type: StorySliderQueView.self)
            if !queViews.isEmpty {
                let queView = queViews[0]
                queView.translatesAutoresizingMaskIntoConstraints = false
                queView.transform = .identity
                queView.startEdit()
                self.removeGestures(view: queView)
                self.currentTagView = queView
            } else {
                let tagView = self.sliderQueView()
                let tag = self.setUpStoryTagFor(tagView: tagView,
                                                tagType: StoryTagType.slider,
                                                tagText: "")
                self.storyTags.append(BaseStoryTag(view: tagView, tag: tag))
                self.currentTagView = tagView
            }
            self.isQuestionTyping = true
            
        }
        
    }
    
    func sliderQueView() -> StorySliderQueView {
        let sView = StorySliderQueView.init()
        self.addTransparentView()
        self.canvasImageView.addSubview(sView)
        sView.backgroundColor = ApplicationSettings.appWhiteColor
        sView.translatesAutoresizingMaskIntoConstraints = false
        
        sView.centerXAnchor.constraint(equalTo: self.canvasImageView.centerXAnchor, constant: 0).isActive = true
        sView.topAnchor.constraint(equalTo: self.canvasImageView.topAnchor, constant: 100).isActive = true
        sView.widthAnchor.constraint(equalTo: self.canvasImageView.widthAnchor, multiplier: 0.6).isActive = true
        sView.startEdit()
        return sView
    }
    
    func removeGestures(view: UIView) {
        guard let gestures = view.gestureRecognizers else {
            return
        }
        for gesture in gestures {
            view.removeGestureRecognizer(gesture)
        }
    }
    
    func addAskQuestionView() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.hideToolbar(hide: true)
            self.doneTagEditButton.isHidden = false
            let queViews = self.canvasImageView.allSubViewsOf(type: StoryAskQuestionView.self)
            if !queViews.isEmpty {
                let queView = queViews[0]
                queView.translatesAutoresizingMaskIntoConstraints = false
                queView.transform = .identity
                queView.startEdit()
                self.removeGestures(view: queView)
                self.currentTagView = queView
            } else {
                let tagView = self.askQueView()
                let tag = self.setUpStoryTagFor(tagView: tagView,
                                                tagType: StoryTagType.askQuestion,
                                                tagText: "")
                self.storyTags.append(BaseStoryTag(view: tagView, tag: tag))
                self.currentTagView = tagView
            }
            
        }
        
    }
    
    func askQueView() -> StoryAskQuestionView {
        let sView = StoryAskQuestionView.init()
        self.addTransparentView()
        self.canvasImageView.addSubview(sView)
        sView.translatesAutoresizingMaskIntoConstraints = false
        sView.centerXAnchor.constraint(equalTo: self.canvasImageView.centerXAnchor, constant: 0).isActive = true
        sView.topAnchor.constraint(equalTo: self.canvasImageView.topAnchor, constant: 100).isActive = true
        sView.widthAnchor.constraint(equalTo: self.canvasImageView.widthAnchor, multiplier: 0.6).isActive = true
        sView.startEdit()
        return sView
    }
    
    func addPollQuestionView() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.hideToolbar(hide: true)
            self.doneTagEditButton.isHidden = false
            let queViews = self.canvasImageView.allSubViewsOf(type: StoryPollQueView.self)
            if !queViews.isEmpty {
                let queView = queViews[0]
                queView.translatesAutoresizingMaskIntoConstraints = false
                queView.transform = .identity
                queView.updateOptionsColors()
                queView.startEdit()
                self.removeGestures(view: queView)
                self.currentTagView = queView
            } else {
                let tagView = self.pollQueView()
                let tag = self.setUpStoryTagFor(tagView: tagView,
                                                tagType: StoryTagType.poll,
                                                tagText: "")
                self.storyTags.append(BaseStoryTag(view: tagView, tag: tag))
                self.currentTagView = tagView
            }
        }
    }
    
    func pollQueView() -> StoryPollQueView {
        let sView = StoryPollQueView.init()
        self.addTransparentView()
        self.canvasImageView.addSubview(sView)
        sView.backgroundColor = ApplicationSettings.appClearColor
        sView.translatesAutoresizingMaskIntoConstraints = false
        sView.centerXAnchor.constraint(equalTo: self.canvasImageView.centerXAnchor, constant: 0).isActive = true
        sView.topAnchor.constraint(equalTo: self.canvasImageView.topAnchor, constant: 100).isActive = true
        sView.widthAnchor.constraint(equalTo: self.canvasImageView.widthAnchor, multiplier: 0.6).isActive = true
        sView.startEdit()
        sView.layoutIfNeeded()
        sView.updateOptionsColors()
        return sView
    }
    
    func addTimeTag(for date: Date) {
        let aView = BaseTimeTagView.init(date: date)
        aView.backgroundColor = ApplicationSettings.appClearColor
        self.canvasImageView.addSubview(aView)
        aView.translatesAutoresizingMaskIntoConstraints = false
        aView.centerXAnchor.constraint(equalTo: self.canvasImageView.centerXAnchor).isActive = true
        aView.centerYAnchor.constraint(equalTo: self.canvasImageView.centerYAnchor).isActive = true
        aView.layoutIfNeeded()
        aView.translatesAutoresizingMaskIntoConstraints = true
        self.addGestures(view: aView)
        aView.center = self.canvasImageView.center
    }
    
    func addDayTag() {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let dayString = formatter.string(from: Date())
        let tagView = StoryTagView.init(tagType: .youtube, isImage: false)
        self.canvasImageView.addSubview(tagView)
        tagView.translatesAutoresizingMaskIntoConstraints = false
        // apply constraint
        tagView.centerXAnchor.constraint(equalTo: self.canvasImageView.centerXAnchor, constant: 0).isActive = true
        tagView.centerYAnchor.constraint(equalTo: self.canvasImageView.centerYAnchor, constant: 0).isActive = true
        tagView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        tagView.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.width - 10).isActive = true
        // set text
        tagView.text = dayString
        tagView.translatesAutoresizingMaskIntoConstraints = true
        tagView.completeEdit()
        self.addGestures(view: tagView)
        tagView.center = self.canvasImageView.center
    }
    
    func addCameraView() {
        
        let cameraView = CameraView.instanceFromNib()
        self.canvasImageView.addSubview(cameraView)
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        // apply constraint
        cameraView.centerXAnchor.constraint(equalTo: self.canvasImageView.centerXAnchor, constant: 0).isActive = true
        cameraView.centerYAnchor.constraint(equalTo: self.canvasImageView.centerYAnchor, constant: 0).isActive = true
        cameraView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        cameraView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        // set text
        cameraView.setup()
        cameraView.translatesAutoresizingMaskIntoConstraints = true
        cameraView.cameraClick = { image in
            
        }
        self.addGestures(view: cameraView)
        cameraView.center = self.canvasImageView.center
    }
    
    func addWeatherTag(for temperature: String) {
        let aView = WeatherTagView.init(temperature: temperature)
        aView.backgroundColor = ApplicationSettings.appClearColor
        self.canvasImageView.addSubview(aView)
        aView.translatesAutoresizingMaskIntoConstraints = false
        aView.centerXAnchor.constraint(equalTo: self.canvasImageView.centerXAnchor).isActive = true
        aView.centerYAnchor.constraint(equalTo: self.canvasImageView.centerYAnchor).isActive = true
        aView.layoutIfNeeded()
        aView.translatesAutoresizingMaskIntoConstraints = true
        self.addGestures(view: aView)
        aView.center = self.canvasImageView.center
    }
    
    func openPlacePickerView() {
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }
    
}
// MARK: GMSPlacePickerViewControllerDelegate

extension PhotoEditorViewController: GMSPlacePickerViewControllerDelegate {
    
    public func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        addLocationTagView(place)
        viewController.dismiss(animated: true, completion: nil)
    }
    
    public func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func addLocationTagView(_ place: GMSPlace) {
        let tagView = addTagViewFor(place.name ?? "", type: StoryTagType.location)
        let tag = setUpStoryTagFor(tagView: tagView,
                                   tagType: StoryTagType.location,
                                   tagText: place.name ?? "")
        tag.latitude = place.coordinate.latitude
        tag.longitude = place.coordinate.longitude
        tag.placeId = place.placeID
        
        if let locationIndex = storyTags.firstIndex(where: { $0.tag.tagType == StoryTagType.location.rawValue }) {
            storyTags[locationIndex].view.removeFromSuperview()
            storyTags.remove(at: locationIndex)
        }
        storyTags.append(BaseStoryTag(view: tagView, tag: tag))
    }
}

extension PhotoEditorViewController: CollageMakerVCDelegate {
    
    func didSelectImage(image: UIImage) {
        self.image = image
        self.openPhotoEditorForImage(image)
    }
    
    func openPhotoEditorForImage(_ image: UIImage) {
        let photoEditor = getPhotoEditor()
        photoEditor.image = image
        if let navController = self.navigationController {
            let newVC = photoEditor
            var stack = navController.viewControllers
            stack.remove(at: stack.count - 1)
            stack.insert(newVC, at: stack.count)
            navController.setViewControllers(stack, animated: false)
        }
    }
    
    func getPhotoEditor(storiType: StoriType = .default) -> PhotoEditorViewController {
        guard let photoEditor = R.storyboard.photoEditor.photoEditorViewController() else {
            fatalError("PhotoEditorViewController Not Found")
        }
        photoEditor.storiCamType = storiCamType
        photoEditor.storiType = storyRePost ? .shared : storiType
        photoEditor.storySelectionDelegate = storySelectionDelegate
        return photoEditor
    }
}

extension PhotoEditorViewController: SelectHashtagDelegate {
    
    func didSelectHashtags(_ visibleHashtags: [String], hiddenHashtags: [String]) {
        let storyHashtags = self.storyTags.filter { $0.tag.tagType == StoryTagType.hashtag.rawValue }
        for storyTag in storyHashtags {
            storyTag.view.removeFromSuperview()
        }
        self.storyTags = self.storyTags.filter { $0.tag.tagType != StoryTagType.hashtag.rawValue }
        for var visibleHashtag in visibleHashtags {
            if !visibleHashtag.isEmpty {
                visibleHashtag.remove(at: visibleHashtag.startIndex)
            }
            let tagView = self.addTagViewFor(visibleHashtag, type: StoryTagType.hashtag)
            let storyHashtag = setUpStoryTagFor(tagView: tagView,
                                                tagType: StoryTagType.hashtag,
                                                tagText: visibleHashtag)
            self.storyTags.append(BaseStoryTag(view: tagView, tag: storyHashtag))
        }
        self.hiddenHashtags = hiddenHashtags
    }
    
}

extension PhotoEditorViewController: PixelEditViewControllerDelegate {
    
    func pixelEditViewController(_ controller: PixelEditViewController, didEndEditing editingStack: EditingStack) {
        self.editingStack = editingStack
        let image = editingStack.makeRenderer().render(resolution: .full)
        self.image = image
        filterSwitcherView?.setImageBy(image)
        controller.dismiss(animated: true) {
            
        }
    }
    
    func pixelEditViewControllerDidCancelEditing(in controller: PixelEditViewController) {
        controller.dismiss(animated: true) {
            
        }
    }
    
}

extension PhotoEditorViewController: LocationUpdateProtocol {
    func locationDidUpdateToLocation(location: CLLocation) {
        lat = "\(location.coordinate.latitude)"
        long = "\(location.coordinate.longitude)"
        saveAddressFor(location)
        getCurrentWeather()
    }
    
    func getCurrentWeather() {
        ProManagerApi
            .getWeather(lattitude: lat, longitude: long)
            .request(BaseWeather.self)
            .subscribe(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                if let temp = response.main?.temp {
                    Defaults.shared.currentTemperature = "\(temp)"
                    self.temperature = "\(temp)"
                }
            }, onError: { (_) in
            }).disposed(by: rx.disposeBag)
    }
    
    func saveAddressFor(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, _) in
            guard let strongSelf = self else { return }
            if let placeMarks = placemarks {
                let placemark = placeMarks.first
                _ = placemark?.subThoroughfare
                _ = placemark?.subLocality
                let street = placemark?.thoroughfare
                strongSelf.address = street ?? ""
            }
        }
    }
}

extension PhotoEditorViewController: SketchViewDelegate {
    
    public func drawView(_ view: SketchView, didEndDrawUsingTool tool: AnyObject) {
        undoButton.isHidden = !view.canUndo()
    }
    
}

extension PhotoEditorViewController: StorySwipeableFilterViewDelegate {
    func swipeableFilterView(_ swipeableFilterView: StorySwipeableFilterView, didScrollTo filter: StoryFilter?) {
        filterNameLabel.isHidden = false
        self.filterNameLabel.text = self.filterSwitcherView?.selectedFilter?.name
        self.filterNameLabel.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.filterNameLabel.alpha = 1
        }, completion: { (isCompleted) in
            if isCompleted {
                UIView.animate(withDuration: 0.3, delay: 1, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
                    self.filterNameLabel.alpha = 0
                }, completion: { (_) in
                    
                })
            }
        })
    }
}

extension PhotoEditorViewController: StoryPlayerDelegate {
    
    func player(_ player: StoryPlayer, didPlay currentTime: CMTime, loopsCount: Int) {
        self.stopMotionCollectionView.reloadData()
    }
    
    func playerDidEnd() {
        DispatchQueue.main.async {
            if !self.videoUrls.isEmpty {
                if self.videoUrls.count <= self.currentPage {
                    if !self.videoUrls[self.currentPage].isSelected {
                        self.currentPlayVideo += 1
                        
                        if self.currentPlayVideo == self.videoUrls.count {
                            self.currentPlayVideo = 0
                        }
                        self.currentPage = self.currentPlayVideo
                        self.stopMotionCollectionView.reloadData()
                        self.stopMotionCollectionView.layoutIfNeeded()
                        self.stopMotionCollectionView.setNeedsLayout()
                        
                        if !self.videoUrls.isEmpty {
                            let item = self.videoUrls[self.currentPlayVideo].currentAsset
                            if let item = item {
                                self.scPlayer?.setItemBy(item)
                            }
                            if let itemSegment = item {
                                self.scPlayer?.setItemBy(itemSegment)
                                self.asset = itemSegment
                                
                                self.loadData()
                                self.configUI()
                                
                                self.segmentedProgressBar.duration = itemSegment.duration.seconds
                            }
                            
                            self.coverImageView.image = self.videoUrls[self.currentPlayVideo].image
                        }
                        if let cell: ImageCollectionViewCell = self.stopMotionCollectionView.cellForItem(at: IndexPath.init(row: self.currentPage, section: 0)) as? ImageCollectionViewCell {
                            
                            guard let startTime = cell.trimmerView.startTime else {
                                return
                            }
                            
                            self.scPlayer?.seek(to: startTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
                            
                            cell.trimmerView.seek(to: startTime)
                            cell.trimmerView.resetTimePointer()
                        }
                    }
                }
                
            }
        }
    }
    
    func player(_ player: StoryPlayer, didReachEndFor item: AVPlayerItem) {
        self.playerDidEnd()
    }
    
}

extension PhotoEditorViewController: DNDDragSourceDelegate, DNDDropTargetDelegate {
    
    public func draggingView(for operation: DNDDragOperation) -> UIView? {
        let dragView: UIView = representationImageAtPoint(operation.dragSourceView)!
        dragView.transform = CGAffineTransform.identity
        dragView.alpha = 0.0
        dragView.layer.cornerRadius = 5
        UIView.animate(withDuration: 0.25, animations: {
            dragView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            dragView.alpha = 0.75
        })
        return dragView
    }
    
    public func dragOperationWillCancel(_ operation: DNDDragOperation) {
        operation.removeDraggingView()
    }
    
    public func dragOperation(_ operation: DNDDragOperation, didDropInDropTarget target: UIView) {
        operation.removeDraggingView()
        
        let selectedVideoUrl = self.selectedSlideShowImages[operation.dragSourceView.tag - 1]
        
        if target == photoSegmentDeleteView {
            let button = UIButton.init()
            button.tag = operation.dragSourceView.tag
            self.btnPhotosCloseTapped(button)
            
            for btn in btnImageClose {
                if btn.tag == operation.dragSourceView.tag {
                    btnImageClose[btn.tag - 1].isHidden = true
                }
            }
        } else if target == chatView {
            self.saveImage(exportType: .chat, image: selectedVideoUrl!.image!)
        } else if target == feedView {
            self.saveImage(exportType: .feed, image: selectedVideoUrl!.image!)
        }
        
        self.setDeleteFrame(view: target)
        
        operation.removeDraggingViewAnimated(withDuration: 0.2, animations: { draggingView in
            draggingView.alpha = 0.0
            draggingView.center = operation.convert(operation.draggingView.center, from: self.view)
        })
    }
    
    public func representationImageAtPoint(_ view: UIView) -> UIView? {
        let imageView = UIImageView(image: view.snapshotData())
        imageView.frame = custImage1.frame
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        return imageView
    }
    
    public func dragOperation(_ operation: DNDDragOperation, didEnterDropTarget target: UIView) {
        UIView.animate(withDuration: 0.1, animations: { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            strongSelf.setStickerObject(view: target)
        })
    }
    
    public func dragOperation(_ operation: DNDDragOperation, didLeaveDropTarget target: UIView) {
        self.setDeleteFrame(view: target)
    }
    
}

extension PhotoEditorViewController {
    // Delegate for highlighting Delete Button
    func setStickerObject(view: UIView) {
        UIView.animate(withDuration: 0.2) { () -> Void in
            view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
        
    }
    
    // Delegate for delete button Normal Position
    func setDeleteFrame(view: UIView) {
        UIView.animate(withDuration: 0.2) { () -> Void in
            view.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    func hideToolbar(hide: Bool) {
        topToolbar.isHidden = hide
        topGradient.isHidden = hide
        bottomToolbar.isHidden = (storiCamType == .chat || storiCamType == .feed) ? true : hide
        bottomGradient.isHidden = hide
        editOptionsToolBar.isHidden = hide
    }
}

extension PhotoEditorViewController: HashTagViewControllerDelegate {
    
    func didHashTagSelectView(view: UIView) {
        tagVC.dismiss(animated: true, completion: nil)
    }
    
    func didHashTagSelectImage(image: UIImage) {
        tagVC.dismiss(animated: true, completion: nil)
    }
    
    func hashTagViewDidDisappear() {
        stickersVCIsVisible = false
        hideToolbar(hide: false)
    }
    
}

extension PhotoEditorViewController: MensionDelegate {
    
    func didSelectUser(user: Channel) {
        guard let tagView = self.currentTagView as? StoryTagView else {
            return
        }
        tagView.selectedMension = user
        tagView.text = user.channelId
        self.doneTagEditButtonTapped(Any.self)
        
    }
}

extension PhotoEditorViewController: EmojiDelegate {
    
    func didSelectEmoji(emoji: String) {
        if let queTagView = self.currentTagView as? StorySliderQueView {
            DispatchQueue.main.async {
                queTagView.slider.emojiText = emoji
            }
        }
    }
    
}

extension PhotoEditorViewController: ThumbSelectorViewDelegate {
    
    public func didChangeThumbPosition(_ imageTime: CMTime) {
        scPlayer?.seek(to: imageTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        coverImageView.image = thumbSelectorView.thumbView.image
        
        if !isImageCellSelect {
            let image = thumbSelectorView.thumbView.image ?? UIImage()
            
            videoUrls[self.currentPage].image = image
            videoUrls[self.currentPage].thumbTime = imageTime
        }
        
        isImageCellSelect = false
        coverImageView.image = videoUrls[self.currentPage].image
        
        DispatchQueue.main.async {
            self.stopMotionCollectionView.reloadData()
            self.stopMotionCollectionView.layoutIfNeeded()
            self.stopMotionCollectionView.setNeedsLayout()
        }
    }
}

extension PhotoEditorViewController: ImageCropperDelegate {
    public func didEndCropping(croppedImage: UIImage?) {
        guard let image = croppedImage else {
            return
        }
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame.size = CGSize(width: 150, height: 150)
        imageView.center = canvasImageView.center
        self.canvasImageView.addSubview(imageView)
        addGestures(view: imageView)
    }
}

extension PhotoEditorViewController: CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, updatedVideoSegments: [SegmentVideos]) {
        videoUrls = updatedVideoSegments
        currentPlayVideo = currentPage - 1
        connVideoPlay()
        dummyView.transform = .identity
        dummyView.frame = self.storyRect
        setTransformationInFilterSwitcherView()
    }
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage) {
        self.image = cropped
        self.filterSwitcherView?.setImageBy(cropped)
        self.dummyView.transform = .identity
        self.dummyView.frame = self.storyRect
        self.setTransformationInFilterSwitcherView()
    }
}

extension PhotoEditorViewController {
    
    func addKeyboardStateObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func removeKeyboardStateObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        if isTyping {
            doneButton.setImage(#imageLiteral(resourceName: "storyType"), for: UIControl.State.normal)
            doneButtonView.isHidden = false
            colorSlider?.isHidden = false
            colorSlider?.color = activeTextView?.textColor ?? ApplicationSettings.appWhiteColor
            hideToolbar(hide: true)
        }
        if isTagTyping {
            mensionPickerView.isHidden = false
        }
        if isQuestionTyping {
            emojiPickerView.isHidden = false
        }
        videoCoverView.isHidden = true
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        isTyping = false
        doneButtonView.isHidden = true
        hideToolbar(hide: false)
        isTagTyping = false
        isQuestionTyping = false
        videoCoverView.isHidden = !(videoUrl != nil || !self.videoUrls.isEmpty)
    }
    
    @objc func keyboardWillChangeFrame(_ notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.mensionPickerViewBottomConstraint?.constant = 0.0
                self.emojiPickerViewBottomConstraint?.constant = 0.0
            } else {
                self.mensionPickerViewBottomConstraint?.constant = endFrame?.size.height ?? 0.0
                self.emojiPickerViewBottomConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
}

