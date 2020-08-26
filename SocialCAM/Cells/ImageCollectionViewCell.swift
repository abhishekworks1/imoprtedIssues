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
    public var leftTopView: UIView = {
        let leftTopView = UIImageView.init(image: R.image.trim_leftWhite())
        leftTopView.frame = .zero
        leftTopView.tag = 0
        leftTopView.translatesAutoresizingMaskIntoConstraints = false
        leftTopView.isUserInteractionEnabled = true
        leftTopView.isHidden = true
        return leftTopView
    }()
    
    public var rightTopView: UIView = {
        let rightTopView = UIImageView.init(image: R.image.trim_rightWhite())
        rightTopView.frame = .zero
        rightTopView.tag = 1
        rightTopView.isHidden = true
        rightTopView.translatesAutoresizingMaskIntoConstraints = false
        rightTopView.isUserInteractionEnabled = true
        return rightTopView
    }()
    
    var isEditMode: Bool = false {
        didSet {
            self.rightTopView.isHidden = !isEditMode
            self.leftTopView.isHidden = !isEditMode
            self.trimmerView.isLeftRightViewTapable = isEditMode
            self.trimmerView.isHidden = !isEditMode
            self.imagesView.isHidden = isEditMode
            self.imagesStackView.isHidden = isEditMode
            self.lblVideoDuration.isHidden = !isEditMode
        }
    }
    
    var isHandleMode: Bool = false {
        didSet {
            if isHandleMode {
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
        
        addSubview(leftTopView)
        addSubview(rightTopView)
        
        let leftTopViewWidthAnchor = leftTopView.widthAnchor
            .constraint(equalToConstant: 23)
        let leftTopViewHeightAnchor = leftTopView.heightAnchor
            .constraint(equalToConstant: 23)
        let leftTopViewTopAnchor = leftTopView.topAnchor
            .constraint(equalTo: topAnchor, constant: 0)
        let leftTopViewLeadingAnchor = leftTopView.leadingAnchor
            .constraint(equalTo: self.trimmerView.leadingAnchor, constant: 0)
        
        let rightTopViewWidthAnchor = rightTopView.widthAnchor
            .constraint(equalToConstant: 23)
        let rightTopViewHeightAnchor = rightTopView.heightAnchor
            .constraint(equalToConstant: 23)
        let rightTopViewTopAnchor = rightTopView.topAnchor
            .constraint(equalTo: topAnchor, constant: 0)
        let rightTopViewLeadingAnchor = rightTopView.trailingAnchor
            .constraint(equalTo: self.trimmerView.trailingAnchor, constant: 0)
        
        NSLayoutConstraint.activate([
            leftTopViewWidthAnchor,
            leftTopViewHeightAnchor,
            leftTopViewTopAnchor,
            leftTopViewLeadingAnchor])
        NSLayoutConstraint.activate([
            rightTopViewWidthAnchor,
            rightTopViewHeightAnchor,
            rightTopViewTopAnchor,
            rightTopViewLeadingAnchor])
        
        let leftTapPanGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleLeftRightTap))
        leftTopView.addGestureRecognizer(leftTapPanGesture)
        
        let rightTapPanGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleLeftRightTap))
        rightTopView.addGestureRecognizer(rightTapPanGesture)
    }
    
    @objc func handleLeftRightTap(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        
        let isLeftGesture = (view == leftTopView)
        if self.trimmerView.isHideLeftRightView { return }
        if isLeftGesture {
            self.trimmerView.currentLeadingConstraint = self.trimmerView.trimViewLeadingConstraint.constant
        } else {
            self.trimmerView.currentTrailingConstraint = self.trimmerView.trimViewTrailingConstraint.constant
        }
        DispatchQueue.main.async {
            self.trimmerView.layoutIfNeeded()
            self.trimmerView.layoutSubviews()
        }
        if isLeftGesture {
            self.trimmerView.updateLeadingHandleConstraint()
        } else {
            guard let minDistance = self.trimmerView.minimumDistanceBetweenDraggableViews
                else { return }
            let maxConstraint = (self.bounds.width
                - (self.trimmerView.draggableViewWidth * 2)
                - minDistance) - self.trimmerView.trimViewLeadingConstraint.constant
            let newPosition = max((self.trimmerView.trimViewWidthContraint.constant - ((self.trimmerView.frame.width - self.trimmerView.trimViewLeadingConstraint.constant) - self.trimmerView.timePointerViewLeadingAnchor.constant)), -maxConstraint)
            self.trimmerView.trimViewTrailingConstraint.constant = newPosition
        }
        
        DispatchQueue.main.async {
            self.trimmerView.layoutIfNeeded()
            self.trimmerView.layoutSubviews()
        }
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
