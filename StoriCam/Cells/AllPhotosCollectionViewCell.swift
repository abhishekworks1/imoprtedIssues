//
//  AllPhotosCollectionViewCell.swift
//  ProManager
//
//  Created by Viraj Patel on 13/06/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import PhotosUI
import Rswift

open class AllPhotosCollectionViewCell: UICollectionViewCell {
    private var observer: NSObjectProtocol?
    @IBOutlet open var imageView: UIImageView?
    @IBOutlet open var playerView: PlayerView?
    @IBOutlet open var livePhotoView: PHLivePhotoView?
    @IBOutlet open var liveBadgeImageView: UIImageView?
    @IBOutlet open var durationView: UIView?
    @IBOutlet open var videoIconImageView: UIImageView?
    @IBOutlet open var durationLabel: UILabel?
    @IBOutlet open var indicator: UIActivityIndicatorView?
    @IBOutlet open var selectedView: UIView?
    @IBOutlet open var selectedHeight: NSLayoutConstraint?
    @IBOutlet open var orderLabel: UILabel?
    @IBOutlet open var orderBgView: UIView?

    var configure = PhotosPickerConfigure() {
        didSet {
            self.selectedView?.layer.borderColor = self.configure.selectedRedColor.cgColor
            self.orderBgView?.backgroundColor = self.configure.selectedColor
            self.videoIconImageView?.image = self.configure.videoIcon
        }
    }

    @objc open var isCameraCell = false

    open var duration: TimeInterval? {
        didSet {
            guard let duration = self.duration else { return }
            self.selectedHeight?.constant = -10
            self.durationLabel?.text = timeFormatted(timeInterval: duration)
        }
    }

    @objc open var player: AVPlayer? = nil {
        didSet {
            if self.configure.autoPlay == false { return }
            if self.player == nil {
                self.playerView?.playerLayer.player = nil
            } else {
                self.playerView?.playerLayer.player = self.player
            }
        }
    }

    @objc open var selectedAsset: Bool = false {
        willSet(newValue) {
            self.selectedView?.isHidden = !newValue
            self.durationView?.backgroundColor = newValue ? self.configure.selectedRedColor : UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
            if !newValue {
                self.orderLabel?.text = ""
            }
        }
    }

    @objc open func timeFormatted(timeInterval: TimeInterval) -> String {
        let seconds: Int = lround(timeInterval)
        var hour: Int = 0
        var minute: Int = Int(seconds / 60)
        let second: Int = seconds % 60
        if minute > 59 {
            hour = minute / 60
            minute = minute % 60
            return String(format: "%d:%d:%02d", hour, minute, second)
        } else {
            return String(format: "%d:%02d", minute, second)
        }
    }

    @objc open func popScaleAnim() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
    }
    
    @objc func stopPlay() {
        if let player = self.player {
            player.pause()
            self.player = nil
        }
    }

    deinit {
        print("deinit AllPhotosCollectionViewCell")
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        self.playerView?.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.livePhotoView?.isHidden = true
        self.selectedView?.isHidden = true
        self.selectedView?.layer.borderWidth = 10
        self.selectedView?.layer.cornerRadius = 15
        self.orderBgView?.layer.cornerRadius = 2
        self.videoIconImageView?.image = self.configure.videoIcon
    }

    override open func prepareForReuse() {
        super.prepareForReuse()
        stopPlay()
        self.durationView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        self.selectedHeight?.constant = 10
        self.selectedAsset = false
    }
}
