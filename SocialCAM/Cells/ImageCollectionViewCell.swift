//
//  TimeCell.swift
//  ProManager
//
//  Created by Viraj Patel on 21/05/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imagesView: UIView!
    @IBOutlet weak var imagesStackView: UIStackView!
    @IBOutlet weak var lblSegmentCount: UILabel!
    @IBOutlet weak var lblVideoDuration: UILabel!
    @IBOutlet weak var lblVideoersiontag: UILabel!
    @IBOutlet weak var trimmerView: TrimmerView!
    
    var isEditMode: Bool = false {
        didSet {
            if isEditMode {
                self.trimmerView.isHidden = false
                self.imagesView.isHidden = true
                self.imagesStackView.isHidden = true
                self.lblVideoDuration.isHidden = false
            } else {
                self.trimmerView.isHidden = true
                self.imagesView.isHidden = false
                self.imagesStackView.isHidden = false
                self.lblVideoDuration.isHidden = true
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        trimmerView?.isHidden = true
    }
    
    func loadAsset(_ asset: AVAsset) {
        trimmerView.layoutIfNeeded()
        trimmerView.minVideoDurationAfterTrimming = 3.0
        trimmerView.thumbnailsView.asset = asset
        trimmerView.rightImage = R.image.cut_handle_icon()
        trimmerView.leftImage = R.image.cut_handle_icon()
        trimmerView.thumbnailsView.isReloadImages = true
        trimmerView.layoutIfNeeded()
    }
    
    func videoPlayerPlayback(to time: CMTime, asset: AVAsset) {
        let (progressTimeM, progressTimeS) = Utils.secondsToHoursMinutesSeconds(Int(Float(time.seconds).roundToPlaces(places: 0)))
        let (totalTimeM, totalTimeS) = Utils.secondsToHoursMinutesSeconds(Int(Float(asset.duration.seconds).roundToPlaces(places: 0)))
        self.lblVideoDuration.text = "\(progressTimeM):\(progressTimeS) / \(totalTimeM):\(totalTimeS)"
    }
    
    func hideLeftRightHandle() {
        trimmerView.isHideLeftRightView = true
    }
    
}
