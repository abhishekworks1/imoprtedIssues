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
    @IBOutlet weak var lblVideoersiontag: UILabel!
    @IBOutlet weak var trimmerView: TrimmerView!
    
    static let identifier = "ImageCollectionViewCell"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        trimmerView?.isHidden = true
    }
    
    func loadAsset(_ asset: AVAsset) {
        trimmerView.layoutIfNeeded()
        trimmerView.minVideoDurationAfterTrimming = 3.0
        trimmerView.thumbnailsView.asset = asset
        trimmerView.rightImage = UIImage.init(named: "cut_handle_icon")
        trimmerView.leftImage = UIImage.init(named: "cut_handle_icon")
        trimmerView.thumbnailsView.isReloadImages = true
        trimmerView.layoutIfNeeded()
    }
    
    func hideLeftRightHandle() {
        trimmerView.isHideLeftRightView = true
    }
    
}
