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
        if self.recordingType == .slideshow || self.recordingType == .collage {
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
            slowFastVerticalBar.isHidden = Defaults.shared.appMode == .free
            self.panStartPoint = gestureRecognizer.location(in: self.view)
            self.panStartZoom = CGFloat(nextLevel.videoZoomFactor)
        case .changed:
            
            let translation = gestureRecognizer.location(in: circularProgress)
            circularProgress.center = CGPoint(x: circularProgress.center.x + translation.x - 35,
                                              y: circularProgress.center.y + translation.y - 35)
            
            let newPoint = gestureRecognizer.location(in: self.view)
            
            let zoomEndPoint: CGFloat = self.view.center.y - 50.0
            let maxZoom = 10.0
            var newZoom = CGFloat(maxZoom) - ((zoomEndPoint - newPoint.y) / (zoomEndPoint - self.panStartPoint.y) * CGFloat(maxZoom))
            newZoom += lastZoomFactor
            let minZoom = max(1.0, newZoom)
            nextLevel.videoZoomFactor = Float(minZoom)
            self.zoomSlider.value = Float(minZoom)
            
            let normalPart = (UIScreen.main.bounds.width * CGFloat(90)) / 375
            let screenPart = Int((UIScreen.main.bounds.width - normalPart) / 6)
            
            if recordingType != .boomerang {
                if abs((Int(self.panStartPoint.x) - Int(newPoint.x))) > 28 {
                    var difference = abs((Int(self.panStartPoint.x) - Int(newPoint.x)))
                    if (Int(self.panStartPoint.x) - Int(newPoint.x)) > 0 {
                        difference -= 28
                        if difference > (screenPart*2) {
                            if videoSpeedType != VideoSpeedType.slow(scaleFactor: 4.0) {
                                DispatchQueue.main.async {
                                    if Defaults.shared.appMode != .free {
                                        self.nextLevel.videoConfiguration.timescale = 4
                                        self.setSpeed(type: .slow(scaleFactor: 4.0),
                                                      value: 0,
                                                      text: R.string.localizable.slow4x())
                                    } else {
                                        self.setNormalSpeed()
                                    }
                                }
                            }
                        } else if difference > screenPart {
                            if videoSpeedType != VideoSpeedType.slow(scaleFactor: 3.0) {
                                DispatchQueue.main.async {
                                    if Defaults.shared.appMode != .free {
                                        self.nextLevel.videoConfiguration.timescale = 3
                                        self.setSpeed(type: .slow(scaleFactor: 3.0),
                                                      value: 1,
                                                      text: R.string.localizable.slow3x())
                                    } else {
                                        self.setNormalSpeed()
                                    }
                                }
                            }
                        } else {
                            if videoSpeedType != VideoSpeedType.slow(scaleFactor: 2.0) {
                                DispatchQueue.main.async {
                                    if Defaults.shared.appMode != .free {
                                        self.nextLevel.videoConfiguration.timescale = 2
                                        self.setSpeed(type: .slow(scaleFactor: 2.0),
                                                      value: 2,
                                                      text: R.string.localizable.slow2x())
                                    } else {
                                        self.setNormalSpeed()
                                    }
                                }
                            }
                        }
                    } else {
                        if difference > (screenPart*2) {
                            if videoSpeedType != VideoSpeedType.fast(scaleFactor: 4.0) {
                                DispatchQueue.main.async {
                                    if Defaults.shared.appMode != .free {
                                        self.nextLevel.videoConfiguration.timescale = 1/4
                                        self.setSpeed(type: .fast(scaleFactor: 4.0),
                                                      value: 6,
                                                      text: R.string.localizable.fast4x())
                                    } else {
                                        self.setNormalSpeed()
                                    }
                                }
                            }
                        } else if difference > screenPart {
                            if videoSpeedType != VideoSpeedType.fast(scaleFactor: 3.0) {
                                DispatchQueue.main.async {
                                    if Defaults.shared.appMode != .free {
                                        self.nextLevel.videoConfiguration.timescale = 1/3
                                        self.setSpeed(type: .fast(scaleFactor: 3.0),
                                                      value: 5,
                                                      text: R.string.localizable.fast3x())
                                    } else {
                                        self.setNormalSpeed()
                                    }
                                }
                            }
                        } else {
                            if videoSpeedType != VideoSpeedType.fast(scaleFactor: 2.0) {
                                DispatchQueue.main.async {
                                    if Defaults.shared.appMode != .free {
                                        self.nextLevel.videoConfiguration.timescale = 1/2
                                        self.setSpeed(type: .fast(scaleFactor: 2.0),
                                                      value: 4,
                                                      text: R.string.localizable.fast2x())
                                    } else {
                                        self.setNormalSpeed()
                                    }
                                }
                            }
                        }
                    }
                } else {
                    if !isSpeedChanged {
                        if speedSlider.speedType == .normal {
                            if videoSpeedType != VideoSpeedType.normal {
                                DispatchQueue.main.async {
                                    self.setNormalSpeed()
                                }
                            }
                        }
                    } else {
                        if videoSpeedType != VideoSpeedType.normal {
                            DispatchQueue.main.async {
                                self.setNormalSpeed()
                            }
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
    
    func onStartRecordSetSpeed() {
        switch speedSlider.value {
        case 0:
            nextLevel.videoConfiguration.timescale = 4
            self.speedLabel.text = R.string.localizable.slow4x()
            self.speedLabel.startBlink()
        case 1:
            nextLevel.videoConfiguration.timescale = 3
            self.speedLabel.text = R.string.localizable.slow3x()
            self.speedLabel.startBlink()
        case 2:
            nextLevel.videoConfiguration.timescale = 2
            self.speedLabel.text = R.string.localizable.slow2x()
            self.speedLabel.startBlink()
        case 4:
            nextLevel.videoConfiguration.timescale = 1/2
            self.speedLabel.text = R.string.localizable.fast2x()
            self.speedLabel.startBlink()
        case 5:
            nextLevel.videoConfiguration.timescale = 1/3
            self.speedLabel.text = R.string.localizable.fast3x()
            self.speedLabel.startBlink()
        case 6:
            nextLevel.videoConfiguration.timescale = 1/4
            self.speedLabel.text = R.string.localizable.fast4x()
            self.speedLabel.startBlink()
        default:
            nextLevel.videoConfiguration.timescale = 1
            self.speedLabel.text = ""
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
    
    func setNormalSpeed() {
        self.videoSpeedType = .normal
        self.speedSliderLabels.value = 3
        self.speedSlider.value = 3
        self.speedLabel.text = ""
        self.speedLabel.stopBlink()
        nextLevel.videoConfiguration.timescale = 1
        speedIndicatorViewColorChange()
    }
    
    func speedIndicatorViewColorChange() {
        for view in speedIndicatorView {
            view.lineColor = ApplicationSettings.appOrangeColor
            if view.tag == Int(speedSlider.value) {
                view.lineColor = .red
            }
            view.draw(view.frame)
        }
    }
    
    @objc internal func handlePhotoTapGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        
        if self.recordingType == .custom {
            return
        }
        
        if self.recordingType == .slideshow || self.recordingType == .collage {
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
