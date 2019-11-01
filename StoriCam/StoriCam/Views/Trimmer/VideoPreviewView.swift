//
//  VideoPreviewView.swift
//  Pods-Trimmer_Example
//
//  Created by Tiziano Coroneo on 01/10/2018.
//

import UIKit
import AVFoundation

open class VideoPreviewView: UIView {
    
    open lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer()
        layer.frame = self.bounds
        return layer
    }()
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.addSublayer(playerLayer)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        playerLayer.frame = self.bounds
    }
    
    open func setPlayer(_ avPlayer: AVPlayer) {
        self.playerLayer.player = avPlayer
    }
}
