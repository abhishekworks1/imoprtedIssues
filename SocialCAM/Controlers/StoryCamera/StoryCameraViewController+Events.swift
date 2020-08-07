//
//  StoryCameraViewController+Events.swift
//  SocialCAM
//
//  Created by Viraj Patel on 05/11/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit

extension StoryCameraViewController {
    
    // MARK: IBActions
    @IBAction func muteButtonClicked(_ sender: Any) {
        if isShowMuteButton {
            isMute = !isMute
            setupMuteUI()
            Defaults.shared.isMicOn = isMute
        }
    }
    
    @IBAction func enableCameraButtonClicked(_ sender: Any) {
        let authStatusCamera = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatusCamera {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [weak self] (result) in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    if result && ApplicationSettings.isMicrophoneEnabled {
                        strongSelf.initCamera()
                        strongSelf.startCapture()
                        strongSelf.blurView.isHidden = true
                        strongSelf.enableAccessView.isHidden = true
                    }
                    strongSelf.changePermissionButtonColor()
                }
                
            })
        case .denied, .restricted:
            print("denied")
            ApplicationSettings.openAppSettingsUrl()
        case .authorized:
            if ApplicationSettings.isMicrophoneEnabled {
                self.initCamera()
                self.startCapture()
                self.blurView.isHidden = true
                self.enableAccessView.isHidden = true
            }
            self.changePermissionButtonColor()
        default: break
        }
    }
    
    @IBAction func enableMicrophoneButtonClicked(_ sender: Any) {
        let authStatusCamera = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        switch authStatusCamera {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (result) in
                DispatchQueue.main.async {
                    if result && ApplicationSettings.isCameraEnabled {
                        self.initCamera()
                        self.startCapture()
                        self.blurView.isHidden = true
                        self.enableAccessView.isHidden = true
                    }
                    self.changePermissionButtonColor()
                }
            })
        case .denied, .restricted:
            print("denied")
            ApplicationSettings.openAppSettingsUrl()
        case .authorized:
            if ApplicationSettings.isCameraEnabled {
                self.initCamera()
                self.startCapture()
                self.blurView.isHidden = true
                self.enableAccessView.isHidden = true
            }
            self.changePermissionButtonColor()
        default: break
        }
    }
    
    @IBAction func flashButtonClicked(_ sender: Any) {
        switch flashMode {
        case .on:
            flashMode = .off
        case .off:
            flashMode = .auto
        case .auto:
            flashMode = .on
        @unknown default:
            flashMode = .off
        }
        self.setupFlashUI()
        Defaults.shared.flashMode = flashMode.rawValue
    }
    
    @IBAction func outTakeButtonClicked(_ sender: Any) {
        let photoPickerVC = PhotosPickerViewController()
        photoPickerVC.isPic2ArtApp = isPic2ArtApp
        photoPickerVC.isTimeSpeedApp = isTimeSpeedApp
        photoPickerVC.isBoomiCamApp = isBoomiCamApp
        photoPickerVC.isFastCamApp = isFastCamApp
        photoPickerVC.currentCamaraMode = recordingType
        photoPickerVC.delegate = self
        self.navigationController?.present(photoPickerVC, animated: true, completion: nil)
    }
    
    @IBAction func flipButtonClicked(_ sender: Any) {
        let blurView = UIVisualEffectView(frame: previewView?.bounds ?? self.view.bounds)
        blurView.effect = UIBlurEffect.init(style: .light)
        previewView?.addSubview(blurView)
        UIView.transition(with: previewView ?? self.view,
                          duration: 0.8,
                          options: .transitionFlipFromBottom,
                          animations: {
                            self.nextLevel.flipCaptureDevicePosition()
        }, completion: { (_) in
            blurView.removeFromSuperview()
            self.flipButton.isSelected = !self.flipButton.isSelected
            self.currentCameraPosition = (self.currentCameraPosition == .front) ? .back : .front
            self.setCameraPositionUI()
            Defaults.shared.cameraPosition = self.currentCameraPosition.rawValue
        })
    }
    
    @IBAction func btnShowHideEditOptionsClick(_ sender: AnyObject) {
        btnShowHide.isSelected = !btnShowHide.isSelected
        hideControls = !hideControls
    }
    
    @IBAction func changeFPSButtonCliked(sender: UIButton) {
        sender.isEnabled = false
        let supportedFrameRate = NextLevel.shared.getAllSupportedFrameRate(dimensions: CMVideoDimensions(width: 1280, height: 720))
        guard supportedFrameRate.count > 0 else {
            sender.isEnabled = true
            return
        }
        BasePopConfiguration.shared.backgoundTintColor = R.color.appWhiteColor()!
        BasePopConfiguration.shared.menuWidth = 120
        BasePopConfiguration.shared.showCheckMark = .checkmark
        BasePopOverMenu
            .showForSender(sender: fpsView,
                           with: supportedFrameRate,
                           withSelectedName: Defaults.shared.selectedFrameRates ?? "30",
                done: { (selectedIndex) -> Void in
                    debugPrint("SelectedIndex :\(selectedIndex)")
                    let selectedFrameRate = supportedFrameRate[selectedIndex]
                    self.selectedFPS = Float(selectedFrameRate)!
                    self.nextLevel.updateDeviceFormat(withFrameRate: CMTimeScale(self.selectedFPS),
                                                      dimensions: CMVideoDimensions(width: 1280, height: 720))
                    sender.isEnabled = true
            }, cancel: {
                sender.isEnabled = true
            })
    }
    
    @IBAction func btnDoneClick(sender: UIButton) {
        guard !nextLevel.isRecording else {
            return
        }
        if sender.tag == 1 {
            if recordingType == .slideshow {
                if takenSlideShowImages.count < 3 {
                    self.showAlert(alertMessage: R.string.localizable.minimumThreeImagesRequiredForSlideshowVideo())
                    return
                }
                self.openStoryEditor(segementedVideos: takenSlideShowImages, isSlideShow: true)
            } else if recordingType == .collage {
                if takenSlideShowImages.isEmpty {
                    self.showAlert(alertMessage: R.string.localizable.minimumOneImagesRequiredForCollageMaker())
                    return
                }
                self.openCollageMakerForCollage()
            } else if recordingType == .custom {
                if takenVideoUrls.isEmpty {
                    self.showAlert(alertMessage: R.string.localizable.minimumOneVideoRequired())
                    return
                }
                self.totalDurationOfOneSegment = 0.0
                self.circularProgress.animate(toAngle: 0, duration: 0, completion: nil)
                self.openStoryEditor(segementedVideos: takenVideoUrls)
            } else {
                
                let upgradeViewController = R.storyboard.storyCameraViewController.upgradeViewController()!
                
                navigationController?.pushViewController(upgradeViewController, animated: true)
            }
        } else {
            closeButton.isSelected = !closeButton.isSelected
        }
    }
    
    @IBAction func onUploadsClick(_ sender: Any) {
        if let storyUploadVC = R.storyboard.storyCameraViewController.baseUploadVC() {
            storyUploadVC.firstModalPersiontage = firstPercentage
            storyUploadVC.firstModalUploadCompletedSize = firstUploadCompletedSize
            
            navigationController?.pushViewController(storyUploadVC, animated: true)
        }
    }
    
    @IBAction func onCloseTimerView(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.isUserTimerValueChange = true
            self.selectTimersView.isHidden = true
            if self.timerValueView.isHidden {
                self.timerValueView.isHidden = !self.isUserTimerValueChange
            }
        }
        switch timerType {
        case .timer:
            selectedTimerValue = SelectedTimer(value: timerOptions[timerPicker.currentSelectedIndex], selectedRow: timerPicker.currentSelectedIndex)
            self.selectedTimerValue.saveWithKey(key: "selectedTimerValue")
            if selectedTimerValue.selectedRow == 0 {
                timerValue = 0
            } else {
                timerValue = Int(selectedTimerValue.value) ?? 0
                if photoTimerValue > 0 {
                    photoTimerValue = 0
                    selectedPhotoTimerValue = SelectedTimer(value: photoTimerOptions[0],
                                                            selectedRow: 0)
                    self.selectedPhotoTimerValue.saveWithKey(key: "selectedPhotoTimerValue")
                }
            }
        case .pauseTimer:
            selectedPauseTimerValue = SelectedTimer(value: pauseTimerOptions[timerPicker.currentSelectedIndex], selectedRow: timerPicker.currentSelectedIndex)
            self.selectedPauseTimerValue.saveWithKey(key: "selectedPauseTimerValue")
            if selectedPauseTimerValue.selectedRow == 0 {
                pauseTimerValue = 0
            } else {
                pauseTimerValue = Int(selectedPauseTimerValue.value) ?? 0
            }
        case .segmentLength:
            selectedSegmentLengthValue = SelectedTimer(value: segmentLengthOptions[timerPicker.currentSelectedIndex], selectedRow: timerPicker.currentSelectedIndex)
            self.selectedSegmentLengthValue.saveWithKey(key: "selectedSegmentLengthValue")
            if let segmentLenghValue = Int(selectedSegmentLengthValue.value) {
                if recordingType == .custom || recordingType == .boomerang {
                    recordingType = .normal
                }
                videoSegmentSeconds = CGFloat(segmentLenghValue)
                segmentLengthSelectedLabel.text = selectedSegmentLengthValue.value
            }
        case .photoTimer:
            selectedPhotoTimerValue = SelectedTimer(value: photoTimerOptions[timerPicker.currentSelectedIndex], selectedRow: timerPicker.currentSelectedIndex)
            self.selectedPhotoTimerValue.saveWithKey(key: "selectedPhotoTimerValue")
            if selectedPhotoTimerValue.selectedRow == 0 {
                photoTimerValue = 0
            } else {
                photoTimerValue = Int(selectedPhotoTimerValue.value) ?? 0
                if timerValue > 0 {
                    timerValue = 0
                    selectedTimerValue = SelectedTimer(value: timerOptions[0],
                                                       selectedRow: 0)
                    self.selectedTimerValue.saveWithKey(key: "selectedTimerValue")
                }
            }
            if (timerValue > 0 || photoTimerValue > 0) && self.recordingType != .capture {
                self.recordingType = .normal
            }
        }
        pauseTimerSelectedLabel.text = selectedPauseTimerValue.value
        timerSelectedLabel.text = selectedTimerValue.value
        photoTimerSelectedLabel.text = selectedPhotoTimerValue.value
        if ((timerValue > 0) || (photoTimerValue > 0)) && self.recordingType != .capture {
            self.recordingType = .normal
        }
    }
    
    @IBAction func onTimerClick(_ sender: UIButton) {
        switch timerType {
        case .timer:
            selectedTimerValue = SelectedTimer(value: timerOptions[timerPicker.currentSelectedIndex], selectedRow: timerPicker.currentSelectedIndex)
            self.selectedTimerValue.saveWithKey(key: "selectedTimerValue")
            if selectedTimerValue.selectedRow == 0 {
                timerValue = 0
            } else {
                timerValue = Int(selectedTimerValue.value) ?? 0
                if photoTimerValue > 0 {
                    photoTimerValue = 0
                    selectedPhotoTimerValue = SelectedTimer(value: photoTimerOptions[0],
                                                            selectedRow: 0)
                    self.selectedPhotoTimerValue.saveWithKey(key: "selectedPhotoTimerValue")
                }
            }
        case .pauseTimer:
            selectedPauseTimerValue = SelectedTimer(value: pauseTimerOptions[timerPicker.currentSelectedIndex], selectedRow: timerPicker.currentSelectedIndex)
            self.selectedPauseTimerValue.saveWithKey(key: "selectedPauseTimerValue")
            if selectedPauseTimerValue.selectedRow == 0 {
                pauseTimerValue = 0
            } else {
                pauseTimerValue = Int(selectedPauseTimerValue.value) ?? 0
            }
        case .segmentLength:
            selectedSegmentLengthValue = SelectedTimer(value: segmentLengthOptions[timerPicker.currentSelectedIndex], selectedRow: timerPicker.currentSelectedIndex)
            self.selectedSegmentLengthValue.saveWithKey(key: "selectedSegmentLengthValue")
            if let segmentLenghValue = Int(selectedSegmentLengthValue.value) {
                if recordingType == .custom || recordingType == .boomerang {
                    recordingType = .normal
                }
                videoSegmentSeconds = CGFloat(segmentLenghValue)
                segmentLengthSelectedLabel.text = selectedSegmentLengthValue.value
            }
        case .photoTimer:
            selectedPhotoTimerValue = SelectedTimer(value: photoTimerOptions[timerPicker.currentSelectedIndex], selectedRow: timerPicker.currentSelectedIndex)
            self.selectedPhotoTimerValue.saveWithKey(key: "selectedPhotoTimerValue")
            if selectedPhotoTimerValue.selectedRow == 0 {
                photoTimerValue = 0
            } else {
                photoTimerValue = Int(selectedPhotoTimerValue.value) ?? 0
                if timerValue > 0 {
                    timerValue = 0
                    selectedTimerValue = SelectedTimer(value: timerOptions[0],
                                                       selectedRow: 0)
                    self.selectedTimerValue.saveWithKey(key: "selectedTimerValue")
                }
            }
        }
        
        sender.isSelected = !sender.isSelected
        timerType = TimerType(rawValue: sender.tag) ?? TimerType.timer
        timerPicker.reloadPickerView()
        switch timerType {
        case .timer:
            
            deSelectButtonWith([pauseTimerSelectionButton,
                                segmentLengthSelectionButton,
                                photoTimerSelectionButton])
            timerSelectionLabel.isHidden = false
            hideLabels([pauseTimerSelectionLabel,
                        segmentLengthSelectionLabel,
                        photoTimerSelectionLabel])
            timerPicker.selectRow(selectedTimerValue.selectedRow, animated: true)
            
        case .pauseTimer:
            deSelectButtonWith([timerSelectionButton,
                                segmentLengthSelectionButton,
                                photoTimerSelectionButton])
            pauseTimerSelectionLabel.isHidden = false
            hideLabels([timerSelectionLabel,
                        segmentLengthSelectionLabel,
                        photoTimerSelectionLabel])
            timerPicker.selectRow(selectedPauseTimerValue.selectedRow, animated: true)
            
        case .segmentLength:
            deSelectButtonWith([pauseTimerSelectionButton,
                                timerSelectionButton,
                                photoTimerSelectionButton])
            segmentLengthSelectionLabel.isHidden = false
            hideLabels([pauseTimerSelectionLabel,
                        timerSelectionLabel,
                        photoTimerSelectionLabel])
            
            timerPicker.selectRow(selectedSegmentLengthValue.selectedRow, animated: true)
            
        case .photoTimer:
            
            deSelectButtonWith([timerSelectionButton,
                                segmentLengthSelectionButton,
                                pauseTimerSelectionButton])
            photoTimerSelectionLabel.isHidden = false
            hideLabels([timerSelectionLabel,
                        segmentLengthSelectionLabel,
                        pauseTimerSelectionLabel])
            timerPicker.selectRow(selectedPhotoTimerValue.selectedRow, animated: true)
            
        }
    }
    
    @IBAction func effectButtonClicked(_ sender: UIButton) {
        if isShowEffectCollectionView {
            hidenCollectionView()
            isShowEffectCollectionView = false
        } else {
            showCollectionView()
            isShowEffectCollectionView = true
        }
    }
    
    @IBAction func onStorySettings(_ sender: Any) {
        let storySettingsVC = R.storyboard.storyCameraViewController.storySettingsVC()!
        navigationController?.pushViewController(storySettingsVC, animated: true)
    }
    
    @IBAction func timerButtonClicked(_ sender: UIButton) {
        guard !nextLevel.isRecording else {
            return
        }
        guard !isCountDownStarted else {
            return
        }
        photoTimerView.isHidden = isViralcamLiteApp || isFastcamLiteApp || isQuickCamLiteApp
        view.bringSubviewToFront(selectTimersView)
        selectTimersView.isHidden = false
        timerPicker.reloadPickerView()
        switch timerType {
        case .timer:
            deSelectButtonWith([pauseTimerSelectionButton,
                                segmentLengthSelectionButton,
                                photoTimerSelectionButton])
            timerPicker.selectRow(selectedTimerValue.selectedRow, animated: true)
        case .pauseTimer:
            deSelectButtonWith([timerSelectionButton,
                                segmentLengthSelectionButton,
                                photoTimerSelectionButton])
            timerPicker.selectRow(selectedPauseTimerValue.selectedRow, animated: true)
        case .segmentLength:
            deSelectButtonWith([pauseTimerSelectionButton,
                                timerSelectionButton,
                                photoTimerSelectionButton])
            timerPicker.selectRow(selectedSegmentLengthValue.selectedRow, animated: true)
        case .photoTimer:
            deSelectButtonWith([timerSelectionButton,
                                segmentLengthSelectionButton,
                                pauseTimerSelectionButton])
            timerPicker.selectRow(selectedPhotoTimerValue.selectedRow, animated: true)
        }
    }
    
    @IBAction func zoomSliderValueChanged(_ sender: Any) {
        nextLevel.videoZoomFactor = zoomSlider.value
    }
    
}

// MARK: StoryUploadDelegate
extension StoryCameraViewController: StoryUploadDelegate {
    
    func didUpdateBytes(_ progress: Double, _ totalFile: Double, _ storyData: StoryData) {
        firstUploadCompletedSize = progress
    }
    
    func didCompletedStory() {
        reloadUploadViewData()
    }
    
    func didChangeThumbImage(_ image: UIImage) {
        DispatchQueue.main.async {
            self.storyUploadImageView?.image = image
        }
    }
    
    func didUpdateProgress(_ progress: Double) {
        DispatchQueue.main.async {
            var percentage = progress
            if percentage > 100.0 {
                percentage = 100.0
            }
            self.firstPercentage = percentage
            self.lblStoryPercentage.text = "\(Int(percentage * 100))%"
        }
    }
    
    func didChangeStoryCount(_ storyCount: String) {
        DispatchQueue.main.async {
            if storyCount == "" {
                self.storyUploadView.isHidden = true
                self.storyUploadView.alpha = 0
            } else {
                self.lblStoryCount.text = storyCount
                self.storyUploadView.isHidden = false
                self.storyUploadView.alpha = 1
            }
        }
    }
    
    func reloadUploadViewData() {
        var storyUploads: [StoryData] = []
        for storyUploadData in storyUploadManager.getStoryUploadDataNotCompleted() {
            for storyData in storyUploadData.storyData?.allObjects as? [StoryData] ?? [] {
                if !storyData.isCompleted {
                    storyUploads.append(storyData)
                }
            }
        }
        self.storyUploadView.isHidden = (storyUploads.isEmpty)
    }
}

// MARK: PickerViewDelegate
extension StoryCameraViewController: PickerViewDelegate {
    
    public func pickerViewHeightForRows(_ pickerView: PickerView) -> CGFloat {
        return 134.0
    }
    
    public func pickerView(_ pickerView: PickerView, didSelectRow row: Int, index: Int) {
        print(index)
    }
    
    public func pickerView(_ pickerView: PickerView, styleForLabel label: UILabel, highlighted: Bool) {
        
        if timerType == .segmentLength {
            pickerView.selectionTitle.text = R.string.localizable.seconds()
        } else {
            if pickerView.currentSelectedRow == 0 {
                pickerView.selectionTitle.text = ""
            } else {
                pickerView.selectionTitle.text = R.string.localizable.seconds()
            }
        }
        
        label.font = R.font.sfuiTextBold(size: 35 * UIScreen.main.bounds.width/414)
        
        if highlighted {
            label.textColor = ApplicationSettings.appWhiteColor
        } else {
            label.textColor = ApplicationSettings.appWhiteColor.withAlphaComponent(0.75)
        }
        
    }
    
    public func pickerView(_ pickerView: PickerView, viewForRow row: Int, index: Int, highlighted: Bool, reusingView view: UIView?) -> UIView? {
        return nil
    }
    
}

// MARK: PickerViewDataSource
extension StoryCameraViewController: PickerViewDataSource {
    
    public func pickerViewNumberOfRows(_ pickerView: PickerView) -> Int {
        switch timerType {
        case .timer:
            return timerOptions.count
        case .pauseTimer:
            return pauseTimerOptions.count
        case .segmentLength:
            var segmentLength: [String] = []
            var maximumItem = "240"
            switch Defaults.shared.appMode {
            case .free:
                maximumItem = "30"
            case .basic:
                maximumItem = "60"
            case .advanced:
                maximumItem = "180"
            default:
                break
            }
            for segmentItem in segmentLengthOptions {
                segmentLength.append(segmentItem)
                if segmentItem == maximumItem {
                    break
                }
            }
            return segmentLength.count
        case .photoTimer:
            return photoTimerOptions.count
        }
    }
    
    public func pickerView(_ pickerView: PickerView, titleForRow row: Int, index: Int) -> String {
        
        switch timerType {
        case .timer:
            return timerOptions[index]
        case .pauseTimer:
            return pauseTimerOptions[index]
        case .segmentLength:
            return segmentLengthOptions[index]
        case .photoTimer:
            return photoTimerOptions[index]
        }
        
    }
}

extension StoryCameraViewController: OuttakesTakenDelegate {
    func didTakeOuttakes(_ message: String) {
        self.view.makeToast(message, duration: 2.0, position: .bottom)
    }
}

extension StoryCameraViewController: CollageMakerVCDelegate {
    
    func didSelectImage(image: UIImage) {
        if isPic2ArtApp {
            let editor = self.storyEditor(images: [image])
            self.navigationController?.pushViewController(editor, animated: true)
        } else {
            self.openStoryEditor(images: [image])
        }
    }
}

extension StoryCameraViewController: CountdownViewDelegate {
    
    func capturePhoto() {
        if isTimeSpeedApp || isFastCamApp || isViralcamLiteApp || isFastcamLiteApp || isQuickCamLiteApp {
            return
        }
        self.photoTapGestureRecognizer?.isEnabled = false
        self.addFlashView()
        NextLevel.shared.torchMode = flashMode
        let when = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: when, execute: {
            AudioServicesPlaySystemSound(1108)
            NextLevel.shared.capturePhotoFromVideo()
        })
    }
    
    func addFlashView() {
        guard self.flashMode == .on, self.currentCameraPosition == .front else { return }
        self.flashView = UIView(frame: self.previewView?.bounds ?? self.view.bounds)
        self.flashView?.backgroundColor = .white
        previewView?.addSubview(self.flashView ?? UIView())
        self.currentBrightness = UIScreen.main.brightness
        UIScreen.main.brightness = 1.0
    }
    
    func removeFlashView() {
        guard self.flashMode == .on, self.currentCameraPosition == .front else { return }
        for view in (previewView?.subviews ?? []) {
            if view == self.flashView {
                view.removeFromSuperview()
                UIScreen.main.brightness = self.currentBrightness
            }
        }
    }
    
    func countdownFinished(_ view: CountdownView?) {
        isCountDownStarted = false
        sfCountdownView.stop()
        sfCountdownView.isHidden = true
        self.view.sendSubviewToBack(self.sfCountdownView)
        if photoTimerValue > 0 {
            if self.recordingType != .capture {
                recordingType = .photoTimer
            }
            capturePhoto()
        } else {
            isRecording = true
            if self.recordingType != .capture {
                recordingType = .timer
                self.startRecording()
            } else {
                capturePhoto()
            }
        }
    }
}

extension StoryCameraViewController: SpecificBoomerangDelegate {
    
    func didBoomerang(_ url: URL) {
        guard let storyEditorViewController = R.storyboard.storyEditor.storyEditorViewController() else {
            fatalError("PhotoEditorViewController Not Found")
        }
        var medias: [StoryEditorMedia] = []
        
        medias.append(StoryEditorMedia(type: .video(AVAsset(url: url).thumbnailImage() ?? UIImage(), AVAsset(url: url))))
        
        let tiktokShareViews = self.baseView.subviews.filter({ return $0 is TikTokShareView })
        if tiktokShareViews.count > 0 {
            storyEditorViewController.referType = .tiktokShare
        }
        storyEditorViewController.isBoomerang = (self.recordingType == .boomerang)
        storyEditorViewController.medias = medias
        storyEditorViewController.isSlideShow = false
        self.navigationController?.pushViewController(storyEditorViewController, animated: false)
        self.removeData()
    }
    
}
