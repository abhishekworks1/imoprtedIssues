//
//  StroyCameraViewController+CollectionView.swift
//  SocialCAM
//
//  Created by Viraj Patel on 05/12/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit

// MARK: UICollectionViewDataSource
extension StoryCameraViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var isShow = false
        if recordingType == .slideshow || recordingType == .collage {
            if takenSlideShowImages.count >= 1 {
                isShow = true
            } else {
                isShow = true
            }
            self.deleteView.isHidden = true
            self.stopMotionCollectionView.isUserInteractionEnabled = true
            return takenSlideShowImages.count
        }
        if takenVideoUrls.count >= 1 {
            isShow = false
        } else {
            isShow = true
        }
        
        self.deleteView.isHidden = isShow
        self.stopMotionCollectionView.isUserInteractionEnabled = isShow
        return takenVideoUrls.count
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.imageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let borderColor: CGColor! = ApplicationSettings.appWhiteColor.cgColor
        let borderWidth: CGFloat = 3
        
        cell.imagesStackView.tag = indexPath.row
        
        var images = [SegmentVideo]()
        
        if recordingType == .slideshow || recordingType == .collage {
            images = [SegmentVideo(segmentVideos: takenSlideShowImages[indexPath.row])]
        } else {
            for video in takenVideoUrls[(indexPath as NSIndexPath).row].videos {
                images.append(video)
            }
        }
        
        let views = cell.imagesStackView.subviews
        for view in views {
            cell.imagesStackView.removeArrangedSubview(view)
        }
        
        cell.lblSegmentCount.text = String(indexPath.row + 1)
        
        for imageName in images {
            let mainView = UIView.init(frame: CGRect(x: 0, y: 3, width: 41, height: 52))
            
            let imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 41, height: 52))
            imageView.image = imageName.image
            imageView.contentMode = .scaleToFill
            imageView.clipsToBounds = true
            mainView.addSubview(imageView)
            cell.imagesStackView.addArrangedSubview(mainView)
        }
        
        cell.imagesView.layer.cornerRadius = 5
        cell.imagesView.layer.borderWidth = borderWidth
        cell.imagesView.layer.borderColor = borderColor
        
        if let kdCollectionView = stopMotionCollectionView {
            if let draggingPathOfCellBeingDragged = kdCollectionView.draggingPathOfCellBeingDragged {
                if draggingPathOfCellBeingDragged.item == indexPath.item {
                    draggingCell = indexPath
                }
            }
        }
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension StoryCameraViewController: UICollectionViewDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: collectionViewStackVIew))! {
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.stopMotionCollectionView {
            if self.recordingType == .custom {
                if self.takenVideoUrls.count >= 1 {
                    let character = self.takenVideoUrls[indexPath.row]
                    let player = AVPlayer(url: character.url!)
                    let vc = AVPlayerViewController()
                    vc.player = player
                    self.present(vc, animated: true) {
                        vc.player?.play()
                    }
                }
            }
        }
    }
}

// MARK: KDDragAndDropCollectionViewDataSource
extension StoryCameraViewController: KDDragAndDropCollectionViewDataSource {
    
    // MARK: KDDragAndDropCollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, dataItemForIndexPath indexPath: IndexPath) -> AnyObject {
        return takenVideoUrls[indexPath.item]
    }
    
    func collectionView(_ collectionView: UICollectionView, insertDataItem dataItem: AnyObject, atIndexPath indexPath: IndexPath) {
        if let di = dataItem as? SegmentVideos {
            takenVideoUrls.insert(di, at: indexPath.item)
        }
    }
    func collectionView(_ collectionView: UICollectionView, deleteDataItemAtIndexPath indexPath: IndexPath) {
        takenVideoUrls.remove(at: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, moveDataItemFromIndexPath from: IndexPath, toIndexPath to: IndexPath) {
        if isDisableResequence {
            return
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, indexPathForDataItem dataItem: AnyObject) -> IndexPath? {
        
        guard let candidate = dataItem as? SegmentVideos else { return nil }
        
        for (index, item) in takenVideoUrls.enumerated() {
            if candidate.id != item.id {
                continue
            }
            return IndexPath(item: index, section: 0)
        }
        
        return nil
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellIsDraggableAtIndexPath indexPath: IndexPath) -> Bool {
        if recordingType == .custom {
            return true
        }
        return false
    }
    
    public func collectionViewEdgesAndScroll(_ collectionView: UICollectionView, rect: CGRect) {
        
        if isDisableResequence {
            let newrect = rect.origin.y + collectionViewStackVIew.frame.origin.y
            let newrectData = CGRect.init(x: rect.origin.x + 20, y: newrect, width: rect.width, height: rect.height)
            
            let checkframeDelete = deleteView.frame
            
            if checkframeDelete.intersects(newrectData) == true {
                UIView.animate(withDuration: 0.1, animations: { [weak self] () -> Void in
                    guard let strongSelf = self else { return }
                    strongSelf.setStickerObject(view: strongSelf.deleteView)
                })
            } else {
                self.setDeleteFrame(view: deleteView)
            }
        }
    }
    
    public func collectionViewLastEdgesAndScroll(_ collectionView: UICollectionView, rect: CGRect) {
        if isDisableResequence {
            let newrect = rect.origin.y + collectionViewStackVIew.frame.origin.y
            let newrectData = CGRect.init(x: rect.origin.x + 20, y: newrect, width: rect.width, height: rect.height)
            if deleteView.frame.intersects(newrectData) {
                if draggingCell != nil {
                    self.totalDurationOfOneSegment = totalDurationOfOneSegment - self.getDurationOf(videoPath: takenVideoUrls[draggingCell!.item].url!)
                    let album = SCAlbum.shared
                    album.albumName = "\(Constant.Application.displayName) – Recycle"
                    album.saveMovieToLibrary(movieURL: takenVideoUrls[draggingCell!.item].url!)
                    DispatchQueue.main.async {
                        self.takenVideoUrls.remove(at: self.draggingCell!.item)
                        self.stopMotionCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    // Delegate for highlighting Delete Button
    func setStickerObject(view: UIView) {
        UIView.animate(withDuration: 0.2) { () -> Void in
            view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
        
    }
    
    // Delegate for delete button Normal Position
    func setDeleteFrame(view: UIView) {
        UIView.animate(withDuration: 0.2) { () -> Void in
            view.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
}
