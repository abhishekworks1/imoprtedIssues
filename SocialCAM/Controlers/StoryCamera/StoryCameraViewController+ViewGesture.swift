//
//  StoryCameraViewController+ViewGesture.swift
//  SocialCAM
//
//  Created by Viraj Patel on 05/12/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit

// MARK: Record Button Gestures
extension StoryCameraViewController: UIGestureRecognizerDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first?.location(in: self.baseView)
        setScrollViewEvent(point: point)
        if !switchingAppView.isHidden {
            blurView.isHidden = true
            switchingAppView.isHidden = true
        } else if !quickLinkTooltipView.isHidden {
            blurView.isHidden = true
            quickLinkTooltipView.isHidden = true
        } else if !businessDashbardConfirmPopupView.isHidden {
            blurView.isHidden = true
            businessDashbardConfirmPopupView.isHidden = true
        }
    }
    
    func setScrollViewEvent(point: CGPoint?) {
        if point != nil {
            if self.speedSliderView.frame.contains(point!) {
                isPageScrollEnable = false
            } else {
                scrollChanges()
            }
        } else {
            scrollChanges()
        }
    }
    
    func scrollChanges() {
        if recordingType == .slideshow || recordingType == .collage {
            if !takenSlideShowImages.isEmpty {
                isPageScrollEnable = false
            } else {
                isPageScrollEnable = true
            }
        } else {
            isPageScrollEnable = !isRecording
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        scrollChanges()
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: self.baseView)
        setScrollViewEvent(point: point)
        return true
    }
    
    @objc internal func handleLongPressGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if self.recordingType == .slideshow || self.recordingType == .collage || self.recordingType == .pic2Art {
            return
        }
        
        if recordingType != .boomerang && recordingType != .custom && recordingType != .capture {
            
            if isCountDownStarted {
                isCountDownStarted = false
                sfCountdownView.stop()
                sfCountdownView.isHidden = true
                recordingType = .normal
                timerValue = 0
                resetCountDown()
                selectedTimerLabel.text = ""
                timerButton.setImage(R.image.storyTimerWithTick(), for: UIControl.State.normal)
            }
            
            if timerValue > 0 || (recordingType == .handsfree || recordingType == .timer) || !sfCountdownView.isHidden {
                return
            }
            
            if timerValue > 0 && !nextLevel.isRecording {
                self.displayCountDown(timerValue)
                return
            }
        }
        
        switch gestureRecognizer.state {
        case .began:
            recordButtonCenterPoint = circularProgress.center
            startRecording()
            onStartRecordSetSpeed()
            isRecording = true
            self.view.bringSubviewToFront(slowFastVerticalBar.superview ?? UIView())
            if recordingType != .basicCamera && Defaults.shared.enableGuildlines {
                slowFastVerticalBar.isHidden = isLiteApp ? false : (Defaults.shared.appMode == .free)
            } else {
                slowFastVerticalBar.isHidden = true
            }
            self.panStartPoint = gestureRecognizer.location(in: self.view)
            self.panStartZoom = CGFloat(nextLevel.videoZoomFactor)
        case .changed:
            let newPoint = gestureRecognizer.location(in: self.view)
            
            let zoomEndPoint: CGFloat = self.view.center.y - 50.0
            let maxZoom = 10.0
            var newZoom = CGFloat(maxZoom) - ((zoomEndPoint - newPoint.y) / (zoomEndPoint - self.panStartPoint.y) * CGFloat(maxZoom))
            newZoom += lastZoomFactor
            let minZoom = max(1.0, newZoom)
            let translation = gestureRecognizer.location(in: circularProgress)
            if (recordingType == .promo) && isLiteApp{
                self.circularProgress.center = CGPoint(x: circularProgress.center.x + translation.x - 35,y: circularProgress.center.y)
            }else{
                self.circularProgress.center = CGPoint(x: circularProgress.center.x + translation.x - 35,y: circularProgress.center.y + translation.y - 35)
            }
            if Defaults.shared.appMode != .free && self.recordingType != .promo {
                nextLevel.videoZoomFactor = Float(minZoom)
            }
            switch Defaults.shared.appMode {
            case .free:
                if videoSpeedType != VideoSpeedType.normal {
                    self.setNormalSpeed(selectedValue: 2)
                }
                //return
            default:
                break
            }
            
            if recordingType == .basicCamera {
                return
            }
            self.zoomSlider.value = Float(minZoom)

            var speedOptions: [StoryCameraSpeedValue] = [.slow3x, .slow2x, .normal, .normal, .fast2x, .fast3x]
            
            if isLiteApp {
                speedOptions = recordingType == .promo ? [.normal, .normal, .normal, .normal, .fast2x, .fast3x] : speedOptions
            } else {
                switch Defaults.shared.appMode {
                case .free, .basic:
                    break
                case .advanced:
                    speedOptions.append(.fast4x)
                    speedOptions.insert(.slow4x, at: 0)
                default:
                    speedOptions.append(contentsOf: [.fast4x, .fast5x])
                    speedOptions.insert(contentsOf: [.slow5x, .slow4x], at: 0)
                }
            }
            
            var currentValue = checkValue(values: speedOptions, newPoint.x)
            
            if recordingType == .fastMotion {
                switch currentValue {
                case .slow2x:
                    currentValue = .normal
                case .slow3x:
                    currentValue = .normal
                case .slow4x:
                    currentValue = .normal
                case .slow5x:
                    currentValue = .normal
                default: break
                }
            }
            
            if isLiteApp {
                var recordingSpeed = VideoSpeedType.normal
                var timeScale: Float64 = 1
                var speedTitle = ""
                var value = 2
                switch currentValue {
                case .slow3x:
                    timeScale = 3
                    recordingSpeed = .slow(scaleFactor: 3.0)
                    speedTitle = R.string.localizable.slow3x()
                    value = 0
                case .slow2x:
                    timeScale = 2
                    recordingSpeed = .slow(scaleFactor: 2.0)
                    speedTitle = R.string.localizable.slow2x()
                    value = 1
                case .normal:
                    timeScale = 1
                    recordingSpeed = .normal
                    self.setNormalSpeed(selectedValue: 2)
                    return
                case .fast2x:
                    timeScale = 1/2
                    recordingSpeed = .fast(scaleFactor: 2.0)
                    value = 3
                    speedTitle = R.string.localizable.fast2x()
                case .fast3x:
                    timeScale = 1/3
                    recordingSpeed = .fast(scaleFactor: 3.0)
                    value = 4
                    speedTitle = R.string.localizable.fast3x()
                default:
                    break
                }
                DispatchQueue.main.async {
                    self.nextLevel.videoConfiguration.timescale = timeScale
                    self.setSpeed(type: recordingSpeed,
                                  value: value,
                                  text: speedTitle)
                }
            } else if recordingType != .boomerang {
                switch currentValue {
                case .slow5x:
                    if videoSpeedType != VideoSpeedType.slow(scaleFactor: 5.0) {
                        DispatchQueue.main.async {
                            self.nextLevel.videoConfiguration.timescale = 5
                            self.setSpeed(type: .slow(scaleFactor: 5.0),
                                          value: 0,
                                          text: R.string.localizable.slow5x())
                        }
                    }
                case .slow4x:
                    if videoSpeedType != VideoSpeedType.slow(scaleFactor: 4.0) {
                        DispatchQueue.main.async {
                            self.nextLevel.videoConfiguration.timescale = 4
                            let value = speedOptions.count % 5 == 0 ? 1 : 0
                            self.setSpeed(type: .slow(scaleFactor: 4.0),
                                          value: value,
                                          text: R.string.localizable.slow4x())
                        }
                    }
                case .slow3x:
                    if videoSpeedType != VideoSpeedType.slow(scaleFactor: 3.0) {
                        DispatchQueue.main.async {
                            self.nextLevel.videoConfiguration.timescale = 3
                            var value = 0
                            if speedOptions.count % 5 == 0 {
                                value = 2
                            } else if speedOptions.count % 4 == 0 {
                                value = 1
                            }
                            self.setSpeed(type: .slow(scaleFactor: 3.0),
                                          value: value,
                                          text: R.string.localizable.slow3x())
                        }
                    }
                case .slow2x:
                    if videoSpeedType != VideoSpeedType.slow(scaleFactor: 2.0) {
                        DispatchQueue.main.async {
                            self.nextLevel.videoConfiguration.timescale = 2
                            var value = 1
                            if speedOptions.count % 5 == 0 {
                                value = 3
                            } else if speedOptions.count % 4 == 0 {
                                value = 2
                            }
                            self.setSpeed(type: .slow(scaleFactor: 2.0),
                                          value: value,
                                          text: R.string.localizable.slow2x())
                        }
                    }
                case .normal:
                    if videoSpeedType != VideoSpeedType.normal {
                        DispatchQueue.main.async {
                            var value = 2
                            if speedOptions.count % 5 == 0 {
                                value = 4
                            } else if speedOptions.count % 4 == 0 {
                                value = 3
                            }
                            self.setNormalSpeed(selectedValue: value)
                        }
                    }
                case .fast2x:
                    if videoSpeedType != VideoSpeedType.fast(scaleFactor: 2.0) {
                        DispatchQueue.main.async {
                            self.nextLevel.videoConfiguration.timescale = 1/2
                            var value = 3
                            if speedOptions.count % 5 == 0 {
                                value = 5
                            } else if speedOptions.count % 4 == 0 {
                                value = 4
                            }
                            self.setSpeed(type: .fast(scaleFactor: 2.0),
                                          value: value,
                                          text: R.string.localizable.fast2x())
                        }
                    }
                case .fast3x:
                    if videoSpeedType != VideoSpeedType.fast(scaleFactor: 3.0) {
                        DispatchQueue.main.async {
                            self.nextLevel.videoConfiguration.timescale = 1/3
                            var value = 4
                            if speedOptions.count % 5 == 0 {
                                value = 6
                            } else if speedOptions.count % 4 == 0 {
                                value = 5
                            }
                            self.setSpeed(type: .fast(scaleFactor: 3.0),
                                          value: value,
                                          text: R.string.localizable.fast3x())
                        }
                    }
                case .fast4x:
                    if videoSpeedType != VideoSpeedType.fast(scaleFactor: 4.0) {
                        DispatchQueue.main.async {
                            self.nextLevel.videoConfiguration.timescale = 1/4
                            var value = 5
                            if speedOptions.count % 5 == 0 {
                                value = 7
                            } else if speedOptions.count % 4 == 0 {
                                value = 6
                            }
                            self.setSpeed(type: .fast(scaleFactor: 4.0),
                                          value: value,
                                          text: R.string.localizable.fast4x())
                        }
                    }
                case .fast5x:
                    if videoSpeedType != VideoSpeedType.fast(scaleFactor: 5.0) {
                        DispatchQueue.main.async {
                            self.nextLevel.videoConfiguration.timescale = 1/5
                            var value = 6
                            if speedOptions.count % 5 == 0 {
                                value = 8
                            } else if speedOptions.count % 4 == 0 {
                                value = 7
                            }
                            self.setSpeed(type: .fast(scaleFactor: 5.0),
                                          value: value,
                                          text: R.string.localizable.fast5x())
                        }
                    }
                }
            }
        case .ended:
            DispatchQueue.main.async {
                self.resetPositionRecordButton()
                self.speedLabel.text = ""
                self.speedLabel.stopBlink()
                if self.recordingType == .boomerang || self.recordingType != .handsfree || self.recordingType == .timer {
                    self.isStopConnVideo = true
                    self.stopRecording()
                }
            }
        case .cancelled:
            break
        case .failed:
            break
        default:
            break
        }
    }
    
    // values = ["-3x", "2x", "1x", "1x", "2x", "3x"]
    func checkValue(values: [StoryCameraSpeedValue], _ pointX: CGFloat) -> StoryCameraSpeedValue {
        let screenPart = UIScreen.main.bounds.width / CGFloat(values.count)
        for (index, value) in values.enumerated() {
            let multiplyValue = index + 1
            var midPoint = (screenPart*CGFloat(multiplyValue))
            if (UIScreen.main.bounds.width / 2) < pointX {
                midPoint -= (screenPart/2)
            } else {
                midPoint += (screenPart/2)
            }
            if pointX < midPoint {
                return value
            } else if values.count - 1 == index, pointX > midPoint {
                return value
            }
        }
        return .normal
    }

    func onStartRecordSetSpeed() {
        var speedOptions: [StoryCameraSpeedValue] = [.slow3x, .slow2x, .normal, .normal, .fast2x, .fast3x]
        switch Defaults.shared.appMode {
        case .free, .basic:
            break
        case .advanced:
            speedOptions.append(.fast4x)
            speedOptions.insert(.slow4x, at: 0)
        default:
            speedOptions.append(contentsOf: [.fast4x, .fast5x])
            speedOptions.insert(contentsOf: [.slow4x, .slow5x], at: 0)
        }
        
        if isLiteApp {
            speedOptions = recordingType == .promo ? [.normal, .normal, .normal, .fast2x, .fast3x] : [.slow3x, .slow2x, .normal, .fast2x, .fast3x]
        }
        
        var value: Float = 1
        var speedText = ""
        if isLiteApp {
            switch speedSlider.value {
            case 0:
                value = 3
                speedText = R.string.localizable.slow3x()
            case 1:
                value = 2
                speedText = R.string.localizable.slow2x()
            case 2:
                value = 1
                speedText = ""
            case 3:
                value = 1/2
                speedText = R.string.localizable.fast2x()
            case 4:
                value = 1/3
                speedText = R.string.localizable.fast3x()
            default:
                break
            }
        } else {
            switch speedSlider.value {
            case 0:
                if speedOptions.count % 5 == 0 {
                    value = self.recordingType == .fastMotion ? 1 : 5
                    speedText = self.recordingType == .fastMotion ? "" : R.string.localizable.slow5x()
                } else if speedOptions.count % 4 == 0 {
                    value = self.recordingType == .fastMotion ? 1 : 4
                    speedText = self.recordingType == .fastMotion ? "" : R.string.localizable.slow4x()
                } else if speedOptions.count % 3 == 0 {
                    value = self.recordingType == .fastMotion ? 1 : 3
                    speedText = self.recordingType == .fastMotion ? "" : R.string.localizable.slow3x()
                }
            case 1:
                if speedOptions.count % 5 == 0 {
                    value = self.recordingType == .fastMotion ? 1 : 4
                    speedText = self.recordingType == .fastMotion ? "" : R.string.localizable.slow4x()
                } else if speedOptions.count % 4 == 0 {
                    value = self.recordingType == .fastMotion ? 1 : 3
                    speedText = self.recordingType == .fastMotion ? "" : R.string.localizable.slow3x()
                } else if speedOptions.count % 3 == 0 {
                    value = self.recordingType == .fastMotion ? 1 : 2
                    speedText = self.recordingType == .fastMotion ? "" : R.string.localizable.slow2x()
                }
            case 2:
                if speedOptions.count % 5 == 0 {
                    value = self.recordingType == .fastMotion ? 1 : 3
                    speedText = self.recordingType == .fastMotion ? "" : R.string.localizable.slow3x()
                } else if speedOptions.count % 4 == 0 {
                    value = self.recordingType == .fastMotion ? 1 : 2
                    speedText = self.recordingType == .fastMotion ? "" : R.string.localizable.slow2x()
                } else if speedOptions.count % 3 == 0 {
                    value = 1
                    speedText = ""
                }
            case 3:
                if speedOptions.count % 5 == 0 {
                    value = self.recordingType == .fastMotion ? 1 : 2
                    speedText = self.recordingType == .fastMotion ? "" : R.string.localizable.slow2x()
                } else if speedOptions.count % 4 == 0 {
                    value = 1
                    speedText = ""
                } else if speedOptions.count % 3 == 0 {
                    value = 1/2
                    speedText = R.string.localizable.fast2x()
                }
            case 4:
                if speedOptions.count % 5 == 0 {
                    value = 1
                    speedText = ""
                } else if speedOptions.count % 4 == 0 {
                    value = 1/2
                    speedText = R.string.localizable.fast2x()
                } else if speedOptions.count % 3 == 0 {
                    value = 1/3
                    speedText = R.string.localizable.fast3x()
                }
            case 5:
                if speedOptions.count % 5 == 0 {
                    value = 1/2
                    speedText = R.string.localizable.fast2x()
                } else if speedOptions.count % 4 == 0 {
                    value = 1/3
                    speedText = R.string.localizable.fast3x()
                } else if speedOptions.count % 3 == 0 {
                    value = 1/4
                    speedText = R.string.localizable.fast4x()
                }
            case 6:
                if speedOptions.count % 5 == 0 {
                    value = 1/3
                    speedText = R.string.localizable.fast3x()
                } else if speedOptions.count % 4 == 0 {
                    value = 1/4
                    speedText = R.string.localizable.fast4x()
                } else if speedOptions.count % 3 == 0 {
                    value = 1/5
                    speedText = R.string.localizable.fast5x()
                }
            case 7:
                if speedOptions.count % 5 == 0 {
                    value = 1/4
                    speedText = R.string.localizable.fast4x()
                } else if speedOptions.count % 4 == 0 {
                    value = 1/5
                    speedText = R.string.localizable.fast5x()
                }
            case 8:
                if speedOptions.count % 5 == 0 {
                    value = 1/5
                    speedText = R.string.localizable.fast5x()
                }
            default:
                break
            }
        }
        
        nextLevel.videoConfiguration.timescale = Float64(value)
        self.speedLabel.text = speedText
        if speedText != "" {
            self.speedLabel.startBlink()
        } else {
            self.speedLabel.stopBlink()
        }
        
        self.view.bringSubviewToFront(self.speedLabel)
        speedIndicatorViewColorChange()
    }
    
    func setSpeed(type: VideoSpeedType, value: Int, text: String) {
        self.videoSpeedType = type
        self.speedSliderLabels.value = UInt(value)
        self.speedSlider.value = CGFloat(value)
        self.isSpeedChanged = true
        self.speedLabel.text = text
        self.speedLabel.startBlink()
        self.view.bringSubviewToFront(self.speedLabel)
        speedIndicatorViewColorChange()
    }
    
    func setNormalSpeed(selectedValue: Int) {
        self.videoSpeedType = .normal
        self.speedSliderLabels.value = UInt(selectedValue)
        self.speedSlider.value = CGFloat(selectedValue)
        self.speedLabel.text = ""
        self.speedLabel.stopBlink()
        nextLevel.videoConfiguration.timescale = 1
        speedIndicatorViewColorChange()
    }
    
    func speedIndicatorViewColorChange() {
        verticalLines.speedIndicatorViewColorChange(index: Int(speedSlider.value))
    }
    
    @objc internal func handlePhotoTapGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        
        if self.recordingType == .custom {
            return
        }
        
        if self.recordingType == .slideshow || self.recordingType == .collage || self.recordingType == .pic2Art {
            capturePhoto()
            return
        }
        
        if recordingType == .boomerang {
            if !isRecording {
                isRecording = true
                startRecording()
            } else {
                self.isStopConnVideo = true
                stopRecording()
            }
            return
        }
        
        if isCountDownStarted {
            isCountDownStarted = false
            sfCountdownView.stop()
            sfCountdownView.isHidden = true
            if pauseTimerValue > 0 && isRecording && (recordingType == .handsfree || recordingType == .timer) {
                DispatchQueue.main.async {
                    self.isStopConnVideo = true
                    self.setupForPreviewScreen()
                }
                return
            } else if timerValue > 0 {
                recordingType = .normal
                timerValue = 0
                resetCountDown()
                selectedTimerLabel.text = ""
                timerButton.setImage(R.image.storyTimerWithTick(), for: UIControl.State.normal)
            } else if photoTimerValue > 0 {
                recordingType = .normal
                photoTimerValue = 0
                resetPhotoCountDown()
                selectedTimerLabel.text = ""
                timerButton.setImage(R.image.storyTimerWithTick(), for: UIControl.State.normal)
            }
        }
        
        if timerValue > 0 && !nextLevel.isRecording {
            self.displayCountDown(timerValue)
            return
        }
        
        if photoTimerValue > 0 && !nextLevel.isRecording {
            self.displayCountDown(photoTimerValue)
            return
        }
        
        if recordingType != .boomerang && recordingType != .handsfree && recordingType != .timer {
            if recordingType == .capture && closeButton.isSelected {
                if !isRecording {
                    isRecording = true
                    startRecording()
                } else {
                    self.isStopConnVideo = true
                    stopRecording()
                }
            } else {
                if !isRecording {
                    capturePhoto()
                }
            }
        } else if recordingType == .handsfree || recordingType == .timer {
            if !isRecording {
                isRecording = true
                onStartRecordSetSpeed()
                startRecording()
            } else {
                self.isStopConnVideo = true
                stopRecording()
            }
        }
    }
    
}

enum StoryCameraSpeedValue: String {
    case slow5x = "-5x"
    case slow4x = "-4x"
    case slow3x = "-3x"
    case slow2x = "-2x"
    case normal = "1x"
    case fast2x = "2x"
    case fast3x = "3x"
    case fast4x = "4x"
    case fast5x = "5x"
}
