//
//  Histogram+Controls.swift
//  ProManager
//
//  Created by Viraj Patel on 18/01/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import MobileCoreServices
import MediaPlayer

@IBDesignable
class TriangleView: UIView {
    
    @IBInspectable var fillColor: UIColor = UIColor.red {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var isUpArrow: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.beginPath()
        let minY = isUpArrow ? rect.maxY : rect.minY
        let maxY = isUpArrow ? rect.minY : rect.maxY
        context.move(to: CGPoint(x: rect.minX, y: minY))
        context.addLine(to: CGPoint(x: rect.minX, y: rect.maxY/2.0))
        context.addLine(to: CGPoint(x: rect.maxX/2.0, y: maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY/2.0))
        context.addLine(to: CGPoint(x: rect.maxX, y: minY))
        context.closePath()
        context.setFillColor(fillColor.cgColor)
        context.fillPath()
    }
}

extension HistroGramVC {
    
    @IBAction func changeModeButtonClicked(_ sender: UIButton) {
        currentSpeedMode = SpeedType(rawValue: sender.tag)!
    }
    
    @IBAction func timeSliderClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func showHideHistoGramClicked(_ sender: Any) {
        if btnShowHideHistoGram.isSelected {
            baseChartView.isHidden = false
            progressBar.isHidden = (currentSpeedMode == .flow) ? false : true
            self.view.layoutIfNeeded()
            speedChangeModesView.isHidden = false
            btnShowHideHistoGram.isSelected = false
            playerLayer?.frame = videoView.frame
            self.view.layoutIfNeeded()
        } else {
            baseChartView.isHidden = true
            progressBar.isHidden = true
            self.view.layoutIfNeeded()
            speedChangeModesView.isHidden = true
            btnShowHideHistoGram.isSelected = true
            playerLayer?.frame = videoView.frame
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            if self.btnShowHideHistoGram.transform == .identity {
                self.btnShowHideHistoGram.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 1))
            } else {
                self.btnShowHideHistoGram.transform = .identity
            }
            self.view.layoutIfNeeded()
        })
        
    }
    
    @IBAction func deleteFlowPointButtonClicked(_ sender: Any) {
        guard let dotView = currentDotView else {
            return
        }
        flowChartView?.removeDotView(view: dotView)
        guard let asset = currentAsset else {
            return
        }
        let (mutableAsset, scalerParts) = VideoScaler.shared.scaleVideo(asset: asset, scalerValues: calculateScaleValues())
        if let asset = mutableAsset {
            playerItem = AVPlayerItem.init(asset: asset)
            player?.replaceCurrentItem(with: playerItem)
            videoScalerParts = scalerParts
        }
        player?.play()
        btnPlayPause.isSelected = true
        let seekTime = CMTime.zero
        player?.seek(to: seekTime, completionHandler: { [weak self] _ in
            self?.startPlaybackTimeChecker()
        })
    }
    
    @IBAction func playPauseClicked(_ sender: Any) {
        if btnPlayPause.isSelected {
            player?.pause()
            stopPlaybackTimeChecker()
            btnPlayPause.isSelected = false
        } else {
            player?.play()
            startPlaybackTimeChecker()
            btnPlayPause.isSelected = true
        }
    }
    
    @IBAction func muteBtnClicked(_ sender: Any) {
        isMute = !isMute
        if isMute {
            btnMute.setImage(#imageLiteral(resourceName: "storySoundOff"), for: UIControl.State.normal)
        } else {
            btnMute.setImage(#imageLiteral(resourceName: "storySoundOn"), for: UIControl.State.normal)
        }
        self.player?.isMuted = isMute
    }
    
    @IBAction func doneBtnClicked(_ sender: Any) {
        guard !isExporting, let asset = currentAsset else {
            return
        }
        var scaledAsset: AVMutableComposition? = nil
        switch currentSpeedMode {
        case .flow:
            scaledAsset = VideoScaler.shared.scaleVideo(asset: asset, scalerValues: calculateScaleValues()).0
        case .timeFlow:
            scaledAsset = timeSliderAsset()
        case .cameraSpeed:
            scaledAsset = VideoScaler.shared.scaleVideo(asset: asset, scalerValues: self.scalerValues).0
        default:
            break
        }
        
        guard let mutableAsset = scaledAsset else {
            return
        }
        DispatchQueue.main.async {
            self.isExporting = true
            self.loadingView.loadingViewShow = true
            self.loadingView.shouldCancelShow = true
            self.loadingView.show(on: self.view)
        }
        
        VideoScaler.shared.exportVideo(scaleComposition: mutableAsset) { [weak self] url in
            guard let `self` = self else {
                return
            }
            DispatchQueue.main.async {
                self.isExporting = false
                self.loadingView.hide()
            }
            
            DispatchQueue.main.async {
                self.doneHandler?(self.videoSegments)
                self.navigationController?.popViewController(animated: true)
                if self.videoSegments.count > 0 {
                    let updatedSegment = SegmentVideos(urlStr: url,
                                                       thumbimage: self.videoSegments[self.currentIndex].image,
                                                       numberOfSegement: self.videoSegments[self.currentIndex].numberOfSegementtext,
                                                       combineOneVideo: true)
                    self.videoSegments.remove(at: self.currentIndex)
                    self.videoSegments.insert(updatedSegment, at: self.currentIndex)
                } else {
                    self.completionHandler?(url)
                }
            }
        }
    }
    
    func calculatePoints() -> [[VideoSpeedValue]] {
        guard let asset = currentAsset else {
            return [[]]
        }
        let actualDuration = asset.duration.seconds
        guard let view = flowChartView else {
            return [[]]
        }
        let points = view.getSpeedValues()
        print(points)
        var parts = 0
        var finalRangeValues: [[VideoSpeedValue]] = []
        for (index, point) in points.enumerated() {
            if index != points.count-1 {
                let dx = abs(point.xValue - points[index+1].xValue)
                let baseSeconds = Double(dx)*actualDuration/Double(UIScreen.main.bounds.width-30)
                if ((point.value < 0) && (points[index+1].value < 0)) || ((point.value > 0) && (points[index+1].value > 0)) {
                    print("same sign")
                    var diff = abs(abs(point.value) - abs(points[index+1].value)) + 1
                    if point.value == points[index+1].value {
                        diff = 1
                    }
                    parts += diff
                    let slowToFast = (point.value < points[index+1].value)
                    var rangeValues: [VideoSpeedValue] = []
                    var maxValue = point.value
                    let seconds = baseSeconds/Double(diff)
                    for _ in 0..<diff {
                        rangeValues.append(VideoSpeedValue.init(duration: seconds, value: maxValue))
                        maxValue = slowToFast ? maxValue + 1 : maxValue - 1
                        if maxValue == 1 {
                            maxValue = -1
                        } else if maxValue == -1 {
                            maxValue = 1
                        }
                    }
                    finalRangeValues.append(rangeValues)
                } else {
                    print("diff sign")
                    var diff = abs(point.value) + abs(points[index+1].value) - 1
                    if point.value == points[index+1].value {
                        diff = 1
                    }
                    parts += diff
                    let slowToFast = (point.value < points[index+1].value)
                    var rangeValues: [VideoSpeedValue] = []
                    var maxValue = point.value
                    let seconds = baseSeconds/Double(diff)
                    for _ in 0..<diff {
                        if maxValue == 1 {
                            maxValue = -1
                        } else if maxValue == -1 {
                            maxValue = 1
                        }
                        rangeValues.append(VideoSpeedValue.init(duration: seconds, value: maxValue))
                        maxValue = slowToFast ? maxValue + 1 : maxValue - 1
                    }
                    finalRangeValues.append(rangeValues)
                }
            }
        }
        print(finalRangeValues)
        return finalRangeValues
    }
    
    func calculateScaleValues() -> [VideoScalerValue] {
        let scaleValues = calculatePoints()
        let timeScale: CMTimeScale = 1000000000
        var scalerValues: [VideoScalerValue] = []
        for values in scaleValues {
            for (index, value) in values.enumerated() {
                var scaleDuration = CMTimeMakeWithSeconds(abs(value.duration*Double(value.value)), preferredTimescale: timeScale)
                
                if value.value > 0 {
                    scaleDuration = CMTimeMakeWithSeconds(abs(value.duration/Double(value.value)), preferredTimescale: timeScale)
                }
                print("actualDuration = \(value.duration)")
                print("rate = \(value.value)")
                print("scaleDuration = \(scaleDuration)")
                let startTime = CMTime(seconds: value.duration*Double(index), preferredTimescale: timeScale)
                scalerValues.append(VideoScalerValue(range:
                    CMTimeRange(start: startTime, duration: CMTime(seconds: value.duration, preferredTimescale: timeScale)), duration: scaleDuration, rate: value.value))
            }
        }
        print(scalerValues)
        return scalerValues
    }
}

extension HistroGramVC {
    
    func startPlaybackTimeChecker() {
        deleteFlowPointButton.isHidden = true
        currentDotView = nil
        stopPlaybackTimeChecker()
        btnPlayPause.isSelected = true
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self,
                                                        selector:
            #selector(self.onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }
    
    func stopPlaybackTimeChecker() {
        btnPlayPause.isSelected = false
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
    
    @objc func onPlaybackTimeChecker() {
        if let player = self.player {
            setProgressViewProgress(player: player)
        }
    }
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int) {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func setProgressViewProgress(player: AVPlayer, changeProgressBar: Bool = false) {
        guard let asset = currentAsset else {
            return
        }
        let playBackTime = player.currentTime()
        
        if playBackTime.seconds >= 0 && playBackTime.isNumeric {
            
            var totalTime = 0.0
            var progressTime = 0.0
            
            let currentSecond = (playerItem?.duration.seconds)!
            
            guard currentSecond >= 0 && !currentSecond.isNaN else {
                return
            }
            
            let actualDuration = asset.duration.seconds
            
            totalTime += actualDuration
            let adjustedSeconds = adjustTime(currentTime: playBackTime.seconds)
            progressTime += adjustedSeconds
            
            let (progressTimeM, progressTimeS) = secondsToHoursMinutesSeconds(Int(Float(progressTime).roundToPlaces(places: 0)))
            let (totalTimeM, totalTimeS) = secondsToHoursMinutesSeconds(Int(Float(totalTime).roundToPlaces(places: 0)))
            
            let yourAttributes = [NSAttributedString.Key.foregroundColor: ApplicationSettings.appWhiteColor, NSAttributedString.Key.font: UIFont.sfuiTextRegular]
            
            let finalString =  NSMutableAttributedString(string: "", attributes: yourAttributes as [NSAttributedString.Key: Any])
            
            var progressTimeString = String.init(format: "%02d:%02d", progressTimeM, progressTimeS)
            if currentSpeedMode != .flow {
                progressTimeString = hmsString(from: Float(playBackTime.seconds))
            }
            
            let attributeStr =  NSMutableAttributedString(string: progressTimeString, attributes: yourAttributes as [NSAttributedString.Key: Any])
            finalString.append(attributeStr)
            
            let yourOtherAttributes = [NSAttributedString.Key.foregroundColor: UIColor.blue, NSAttributedString.Key.font: UIFont.sfuiTextRegular]
            
            var totalTimeString = String.init(format: "%02d:%02d", totalTimeM, totalTimeS)
            if currentSpeedMode != .flow {
                totalTimeString = selectedSecondsLabel.text ?? hmsString(from: currentTimeSliderSeconds())
            }

            let partTwo = NSMutableAttributedString(string: ". \(totalTimeString)", attributes: yourOtherAttributes as [NSAttributedString.Key : Any])
            finalString.append(partTwo)
            self.lblShowCurrentTime.text = ""
            self.lblShowCurrentTime.attributedText = finalString
            if !changeProgressBar {
                self.progressBar.center.x = CGFloat(adjustedSeconds)*(UIScreen.main.bounds.width/CGFloat(actualDuration))
            }
        }
        
    }
    
    func adjustTime(currentTime: Double) -> Double {
        var seconds: Double = 0
        for (index, rate) in self.videoScalerParts.enumerated() {
            if index != (self.videoScalerParts.count - 1) {
                if rate.startTime < currentTime && self.videoScalerParts[index+1].startTime < currentTime {
                    if rate.rate > 0 {
                        seconds += (self.videoScalerParts[index+1].startTime - rate.startTime)*Double(abs(rate.rate))
                    } else {
                        seconds += (self.videoScalerParts[index+1].startTime - rate.startTime)/Double(abs(rate.rate))
                    }
                } else if rate.startTime < currentTime {
                    if rate.rate > 0 {
                        seconds += (currentTime - rate.startTime)*Double(abs(rate.rate))
                    } else {
                        seconds += (currentTime - rate.startTime)/Double(abs(rate.rate))
                    }
                }
                
            } else if rate.startTime < currentTime {
                if rate.rate > 0 {
                    seconds += (currentTime - rate.startTime)*Double(abs(rate.rate))
                } else {
                    seconds += (currentTime - rate.startTime)/Double(abs(rate.rate))
                }
            }
        }
        return seconds
    }
    
    func currentTime(adjustedTime: Double) -> Double {
        var originalScaleParts = [VideoScalerPart]()
        var lastStartTime: Double = 0
        for (index, rate) in self.videoScalerParts.enumerated() {
            if index == 0 {
                originalScaleParts.append(VideoScalerPart.init(startTime: 0, rate: rate.rate))
            } else {
                var oStartTime = (rate.startTime - self.videoScalerParts[index-1].startTime)
                if self.videoScalerParts[index-1].rate > 0 {
                    oStartTime *= Double(abs(self.videoScalerParts[index-1].rate))
                } else {
                    oStartTime /= Double(abs(self.videoScalerParts[index-1].rate))
                }
                oStartTime += lastStartTime
                lastStartTime = oStartTime
                originalScaleParts.append(VideoScalerPart.init(startTime: oStartTime, rate: rate.rate))
            }
        }
        var seconds: Double = 0
        for (index, rate) in originalScaleParts.enumerated() {
            if index != (originalScaleParts.count - 1) {
                if rate.startTime < adjustedTime && originalScaleParts[index+1].startTime < adjustedTime {
                    if rate.rate > 0 {
                        seconds += (originalScaleParts[index+1].startTime - rate.startTime)/Double(abs(rate.rate))
                    } else {
                        seconds += (originalScaleParts[index+1].startTime - rate.startTime)*Double(abs(rate.rate))
                    }
                } else if rate.startTime < adjustedTime {
                    if rate.rate > 0 {
                        seconds += (adjustedTime - rate.startTime)/Double(abs(rate.rate))
                    } else {
                        seconds += (adjustedTime - rate.startTime)*Double(abs(rate.rate))
                    }
                }
                
            } else if rate.startTime < adjustedTime {
                if rate.rate > 0 {
                    seconds += (adjustedTime - rate.startTime)/Double(abs(rate.rate))
                } else {
                    seconds += (adjustedTime - rate.startTime)*Double(abs(rate.rate))
                }
            }
        }
        return seconds
    }
    
}
