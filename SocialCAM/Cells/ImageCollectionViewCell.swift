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
    
    @IBOutlet weak var segmentCountLabel: UILabel!
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
    
    func setLayout(indexPath: IndexPath, currentPage: Int, currentAsset: AVAsset, storySegment: [StoryEditorMedia]) {
        var borderColor: CGColor! = ApplicationSettings.appClearColor.cgColor
        var borderWidth: CGFloat = 0
        if currentPage == indexPath.row || storySegment.first!.isSelected {
            borderColor = ApplicationSettings.appBorderColor.cgColor
            borderWidth = 3
            self.lblVideoersiontag.isHidden = false
        } else {
            borderColor = ApplicationSettings.appWhiteColor.cgColor
            borderWidth = 3
            self.lblVideoersiontag.isHidden = true
        }
        self.imagesStackView.tag = indexPath.row
        let views = self.imagesStackView.subviews
        for view in views {
            self.imagesStackView.removeArrangedSubview(view)
        }
        
        self.lblSegmentCount.text = "\(indexPath.row + 1)"
        
        var mainView: UIView = UIView()
        var imageView = UIImageView()
        
        self.imagesView.layer.cornerRadius = 5
        self.imagesView.layer.borderWidth = borderWidth
        self.imagesView.layer.borderColor = borderColor
       
        if currentPage == indexPath.row {
            for (index, _) in storySegment.enumerated() {
                mainView = UIView.init(frame: CGRect(x: 0, y: 3, width: Double(41 * 1.2), height: Double(self.imagesView.frame.height * 1.18)))
                
                imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: Double(41 * 1.2), height: Double(self.imagesView.frame.height * 1.18)))
                guard let thumbImage = currentAsset.thumbnailImage() else {
                    return
                }
                imageView.image = thumbImage
                imageView.contentMode = .scaleToFill
                imageView.clipsToBounds = true
                mainView.addSubview(imageView)
                self.imagesStackView.addArrangedSubview(mainView)
            }
            self.loadAsset(currentAsset)
        } else {
            if !(storySegment.first?.isSelected ?? false) {
                for (index, _) in storySegment.enumerated() {
                    mainView = UIView(frame: CGRect(x: 0, y: 3, width: Double(35), height: Double(imagesView.frame.height)))
                    
                    imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: Double(35), height: Double(imagesView.frame.height)))
                    guard let thumbImage = currentAsset.thumbnailImage() else {
                        return
                    }
                    imageView.image = thumbImage
                    imageView.contentMode = .scaleToFill
                    imageView.clipsToBounds = true
                    mainView.addSubview(imageView)
                    imagesStackView.addArrangedSubview(mainView)
                }
            } else {
                mainView = UIView.init(frame: CGRect(x: 0, y: 3, width: Double(35 * 1.2), height: Double(imagesView.frame.height * 1.18)))
                imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: Double(35 * 1.2), height: Double(imagesView.frame.height * 1.18)))
                guard let thumbImage = currentAsset.thumbnailImage() else {
                    return
                }
                imageView.image = thumbImage
                imageView.contentMode = .scaleToFill
                imageView.clipsToBounds = true
                mainView.addSubview(imageView)
                imagesStackView.addArrangedSubview(mainView)
            }
        }
        self.layoutIfNeeded()
        self.isHidden = false
    }
    
    func setEditLayout(indexPath: IndexPath, currentPage: Int, currentAsset: AVAsset) {
        self.lblVideoersiontag.isHidden = false
       
        let views = self.imagesStackView.subviews
        for view in views {
            self.imagesStackView.removeArrangedSubview(view)
        }
        imagesView.layer.cornerRadius = 5
        imagesView.layer.borderWidth = 3
        imagesView.layer.borderColor = ApplicationSettings.appBorderColor.cgColor
        lblSegmentCount.text = "\(currentPage + 1)"
        lblSegmentCount.isHidden = true
        isEditMode = true
        loadAsset(currentAsset)
        
        self.layoutIfNeeded()
        self.isHidden = false
    }
    func loadColorSizeCutView(){
     
        self.layoutIfNeeded()
    }
    func loadAsset(_ asset: AVAsset) {
        trimmerView.layoutIfNeeded()
        trimmerView.minVideoDurationAfterTrimming = 1.0
        trimmerView.thumbnailsView.asset = asset
        trimmerView.rightImage = R.image.cut_handle_icon()
        trimmerView.leftImage = R.image.cut_handle_icon()
        trimmerView.thumbnailsView.isReloadImages = true
        trimmerView.layoutIfNeeded()
        
        addSubview(leftTopView)
        addSubview(rightTopView)
        
        let leftTopViewWidthAnchor = leftTopView.widthAnchor
            .constraint(equalToConstant: 30)
        let leftTopViewHeightAnchor = leftTopView.heightAnchor
            .constraint(equalToConstant: 30)
        let leftTopViewTopAnchor = leftTopView.topAnchor
            .constraint(equalTo: topAnchor, constant: 125)
        let leftTopViewLeadingAnchor = leftTopView.leadingAnchor
            .constraint(equalTo: self.trimmerView.leadingAnchor, constant: 0)
        
        let rightTopViewWidthAnchor = rightTopView.widthAnchor
            .constraint(equalToConstant: 30)
        let rightTopViewHeightAnchor = rightTopView.heightAnchor
            .constraint(equalToConstant: 30)
        let rightTopViewTopAnchor = rightTopView.topAnchor
            .constraint(equalTo: topAnchor, constant: 125)
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

//    func videoPlayerPlayback(to time: CMTime, asset: AVAsset) {
//        let (progressTimeM, progressTimeS) = Utils.secondsToHoursMinutesSeconds(Int(CMTimeGetSeconds(time)))
//        let progressTimeMiliS = Utils.secondsToMiliseconds(CMTimeGetSeconds(time))
//        let (totalTimeM, totalTimeS) = Utils.secondsToHoursMinutesSeconds(Int(Float(asset.duration.seconds).roundToPlaces(places: 0)))
//        let totalTimeMiliS = Utils.secondsToMiliseconds(asset.duration.seconds)
//        let remainTime = asset.duration.seconds - CMTimeGetSeconds(time)
//        let (remainTimeM, remainTimeS) = Utils.secondsToHoursMinutesSeconds(Int(Float(remainTime).roundToPlaces(places: 0)))
//        let remainTimeMiliS = Utils.secondsToMiliseconds(remainTime)
//        self.lblVideoDuration.text = "\(progressTimeS).\(progressTimeMiliS) / \(remainTimeS).\(remainTimeMiliS)"
//        //\(totalTimeS):\(totalTimeMiliS)"
//    }
    
    func videoPlayerPlayback(to time: CMTime, asset: AVAsset, startPipe: CMTime, endPipe: CMTime) {
        var startT = Double()
        if time == startPipe {
            startT = 0.00
        } else {
            startT = time.seconds - startPipe.seconds
        }
        let (_, progressTimeS) = Utils.secondsToHoursMinutesSeconds(Int(Float(startT).roundToPlaces(places: 0)))
        let progressTimeMiliS = Utils.secondsToMiliseconds(startT)
        let endT = asset.duration.seconds - startPipe.seconds - (asset.duration.seconds - endPipe.seconds)
        let (_, totalTimeS) = Utils.secondsToHoursMinutesSeconds(Int(Float(endT).roundToPlaces(places: 0)))
        let totalTimeMiliS = Utils.secondsToMiliseconds(endT)
        self.lblVideoersiontag.font = UIFont.systemFont(ofSize: 12, weight: .bold)
//        let progressTimeS = startT.rounded(.down)
       
        self.lblVideoDuration.text = "\((progressTimeS > 0) ? progressTimeS : 0).\((progressTimeMiliS > 0) ? progressTimeMiliS : 0) / \(totalTimeS).\(totalTimeMiliS)"

    }
    
    func hideLeftRightHandle() {
        trimmerView.isHideLeftRightView = true
    }
    
}
