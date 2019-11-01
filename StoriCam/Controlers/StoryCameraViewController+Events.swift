//
//  StoryCameraViewController+Events.swift
//  StoriCam
//
//  Created by Viraj Patel on 05/11/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit

extension StoryCameraViewController {
    
    // MARK: IBActions
    
    @IBAction func muteButtonClicked(_ sender: Any) {
        isMute = !isMute
        setupMuteUI()
        Defaults.shared.isMicOn = !isMute
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
        }) { (finished) in
            blurView.removeFromSuperview()
            self.flipButton.isSelected = !self.flipButton.isSelected
            self.currentCameraPosition = (self.currentCameraPosition == .front) ? .back : .front
            self.setCameraPositionUI()
            Defaults.shared.cameraPosition = self.currentCameraPosition.rawValue
        }
    }
    
    @IBAction func btnShowHideEditOptionsClick(_ sender: AnyObject) {
        btnShowHide.isSelected = !btnShowHide.isSelected
        hideControls = !hideControls
    }
    
    @IBAction func changeFPSButtonCliked(sender: UIButton) {
        let supportedFrameRate = NextLevel.shared.getAllSupportedFrameRate(dimensions: CMVideoDimensions(width: 1920, height: 1080))
       
        BasePopOverMenu
            .showForSender(sender: fpsView,
                           with: supportedFrameRate,
                           withSelectedName : "\(Int(selectedFPS))",
                           done: { (selectedIndex) -> () in
                            debugPrint("SelectedIndex :\(selectedIndex)")
                            let selectedFrameRate = supportedFrameRate[selectedIndex]
                            self.selectedFPS = Float(selectedFrameRate)!
                            self.nextLevel.updateDeviceFormat(withFrameRate: CMTimeScale(self.selectedFPS),
                                                              dimensions: CMVideoDimensions(width: 1920, height: 1080))
                            
            }) {
                
        }
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
                openPhotoEditorForSlideShow()
            } else if recordingType == .collage {
                if takenSlideShowImages.count <= 0 {
                    self.showAlert(alertMessage: R.string.localizable.minimumOneImagesRequiredForCollageMaker())
                    return
                }
                self.openCollageMakerForCollage()
            } else if recordingType == .custom {
                if takenVideoUrls.count <= 0 {
                    self.showAlert(alertMessage: R.string.localizable.minimumOneVideoRequired())
                    return
                }
                self.totalDurationOfOneSegment = 0.0
                self.circularProgress.animate(toAngle: 0, duration: 0, completion: nil)
                self.openPhotoEditorForVideo()
            } else {
                
                let upgradeViewController = R.storyboard.storyCameraViewController.upgradeViewController()!
                
                navigationController?.pushViewController(upgradeViewController, animated: true)
            }
        } else {
            closeButton.isSelected = !closeButton.isSelected
        }
    }
    
    @IBAction func onUploadsClick(_ sender: Any) {
        if let storyUploadVC = R.storyboard.storyCameraViewController.storyUploadVC() {
            storyUploadVC.firstModalPersiontage = firstPercentage
            storyUploadVC.firstModalUploadCompletedSize = firstUploadCompletedSize
            navigationController?.pushViewController(storyUploadVC, animated: true)
        }
    }
    
    @IBAction func onCloseTimerView(_ sender: UIButton) {
        selectTimersView.isHidden = true
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
        let storySettingsVC = R.storyboard.storyCameraViewController.storySettingsOptionsVC()!
        storySettingsVC.firstPercentage = firstPercentage
        storySettingsVC.firstUploadCompletedSize = firstUploadCompletedSize
        navigationController?.pushViewController(storySettingsVC, animated: true)
    }
    
    @IBAction func timerButtonClicked(_ sender: UIButton) {
        guard !nextLevel.isRecording else {
            return
        }
        guard !isCountDownStarted else {
            return
        }
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
