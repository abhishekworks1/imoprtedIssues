//
//  PreviewViewController.swift
//  SocialCAM
//
//  Created by Viraj Patel on 03/06/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit

class PreviewViewController: UIViewController {
    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var captionLabel: UILabel!
    @IBOutlet private var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var footerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet open var playerView: PlayerView?
    
    var imageAsset: ImageAsset?
    
    @objc open var player: AVPlayer? = nil {
        didSet {
            if self.player == nil {
                self.playerView?.playerLayer.player = nil
            } else {
                self.playerView?.playerLayer.player = self.player
            }
            self.playerView?.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    @objc func stopPlay() {
        if let player = self.player {
            player.pause()
            self.player = nil
        }
    }
    
    private func playVideo(asset: ImageAsset?) {
        self.stopPlay()
        guard let asset = asset, let phAsset = asset.asset else { return }
        if asset.assetType == .video {
            _ = ImagesLibrary.shared.videoAsset(asset: phAsset, completionBlock: { (playerItem, _) in
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self, self.player == nil else { return }
                    let player = AVPlayer(playerItem: playerItem)
                    self.player = player
                    self.player?.play()
                    self.player?.isMuted = false
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageWidth = CGFloat(imageAsset?.fullResolutionImage?.size.width ?? 1.0)
        var imageHeight = CGFloat(imageAsset?.fullResolutionImage?.size.height ?? 1.0)
        
        if imageHeight < 400 {
            imageHeight = 400
        }
        imageView.image = imageAsset?.fullResolutionImage
        
        let contentWidth = CGFloat(UIScreen.main.bounds.size.width - 20)
        
        let contentHeight: CGFloat = CGFloat(contentWidth * imageHeight) / CGFloat(imageWidth + headerViewHeightConstraint.constant + footerViewHeightConstraint.constant)
        contentSizeInPopup = CGSize(width: contentWidth, height: contentHeight)
        playVideo(asset: imageAsset)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.popupController?.navigationBarHidden = true
    }
    
}
