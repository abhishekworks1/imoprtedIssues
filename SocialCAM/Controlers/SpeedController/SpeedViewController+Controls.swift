//
//  SpeedViewController+Controls.swift
//  SocialCAM
//
//  Created by Viraj Patel on 09/12/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit
import MobileCoreServices
import MediaPlayer

extension SpeedViewController {
    
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
        let scaledAsset = VideoScaler.shared.scaleVideo(asset: asset, scalerValues: self.scalerValues).0
        guard let mutableAsset = scaledAsset else {
            return
        }
        DispatchQueue.main.async {
            self.isExporting = true
        }
        let loadingView = LoadingView.instanceFromNib()
        loadingView.loadingViewShow = true
        loadingView.shouldCancelShow = false
        loadingView.show(on: self.view)
        
        VideoScaler.shared.exportVideo(scaleComposition: mutableAsset) { [weak self] url in
            guard let `self` = self else {
                return
            }
            DispatchQueue.main.async {
                self.isExporting = false
            }
            loadingView.hide()
            let updatedSegment = SegmentVideos(urlStr: url,
                                               thumbimage: self.videoSegments[self.currentIndex].image,
                                               latitued: nil,
                                               longitued: nil,
                                               placeAddress: nil,
                                               numberOfSegement: self.videoSegments[self.currentIndex].numberOfSegementtext,
                                               videoduration: nil,
                                               combineOneVideo: true)
            self.videoSegments.remove(at: self.currentIndex)
            self.videoSegments.insert(updatedSegment, at: self.currentIndex)
            DispatchQueue.main.async {
                self.doneHandler?(self.videoSegments)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension SpeedViewController {
    
    func startPlaybackTimeChecker() {
        currentDotView = nil
        stopPlaybackTimeChecker()
        btnPlayPause.isSelected = true
    }
    
    func stopPlaybackTimeChecker() {
        btnPlayPause.isSelected = false
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int) {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
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
