//
//  PhotoEditiorViewController+CollectionView.swift
//  StoriCam
//
//  Created by Viraj Patel on 04/11/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit

// MARK: UICollectionViewDataSource

extension PhotoEditorViewController: UICollectionViewDataSource, KDDragAndDropCollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.stopMotionCollectionView {
            if currentCamaraMode == .slideshow {
                let filteredImages = self.selectedSlideShowImages.filter { return ($0 != nil) }
                if filteredImages.count > 0 {
                    coverImageView.image = filteredImages[0]?.image
                }
            }
            return videoUrls.count
        } else if collectionView == self.collectionView {
            return _displayKeyframeImages.count
        } else if collectionView == self.slideShowCollectionView {
            return selectedSlideShowImages.count
        }
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.slideShowCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.slideshowImagesCell.identifier, for: indexPath) as? SlideshowImagesCell else {
                fatalError("Unable to find cell with '\(R.nib.slideshowImagesCell.identifier)' reuseIdentifier")
            }
            return cell
        } else if collectionView == self.stopMotionCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.imageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell else {
                fatalError("Unable to find cell with '\(R.nib.imageCollectionViewCell.identifier)' reuseIdentifier")
            }
            
            var borderColor = ApplicationSettings.appClearColor.cgColor
            var borderWidth: CGFloat = 0
            
            if (currentCamaraMode != .slideshow && self.currentPage == indexPath.row) || videoUrls[indexPath.row].isSelected {
                borderColor = ApplicationSettings.appPrimaryColor.cgColor
                borderWidth = 3
                cell.lblVideoersiontag.isHidden = false
            } else {
                borderColor = ApplicationSettings.appWhiteColor.cgColor
                borderWidth = 3
                cell.lblVideoersiontag.isHidden = true
                self.setDeleteFrame(view: cell)
            }
            
            
            cell.isHidden = false
            
            cell.imagesStackView.tag = indexPath.row
            
            let images = videoUrls[(indexPath as NSIndexPath).row].videos
            
            let views = cell.imagesStackView.subviews
            for view in views {
                cell.imagesStackView.removeArrangedSubview(view)
            }
            
            if isOriginalSequence {
                cell.lblSegmentCount.text = "\(indexPath.row + 1)"
            } else {
                cell.lblSegmentCount.text = videoUrls[(indexPath as NSIndexPath).row].numberOfSegementtext
            }
            
            if currentCamaraMode != .slideshow && self.currentPage == indexPath.row {
                if videoUrls[(indexPath as NSIndexPath).row].isCombineOneVideo {
                    
                    let mainView = UIView.init(frame: CGRect(x: 0, y: 3, width: Double(41 * 1.2), height: Double(cell.imagesView.frame.height * 1.18)))
                    
                    let imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: Double(41 * 1.2), height: Double(cell.imagesView.frame.height * 1.18)))
                    imageView.image = images.first?.image
                    imageView.contentMode = .scaleToFill
                    imageView.clipsToBounds = true
                    mainView.addSubview(imageView)
                    cell.imagesStackView.addArrangedSubview(mainView)
                    let item = self.videoUrls[self.currentPage].currentAsset
                    cell.loadAsset(item!)
                    
                    if isEditMode, let item = item {
                        
                        self.scPlayer?.setItemBy(item)
                        
                        cell.trimmerView.isHidden = false
                    }
                    else {
                        cell.trimmerView.isHidden = true
                    }
                }
                else {
                    for imageName in images {
                        let mainView = UIView.init(frame: CGRect(x: 0, y: 3, width: Double(41 * 1.2), height: Double(cell.imagesView.frame.height * 1.18)))
                        
                        let imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: Double(41 * 1.2), height: Double(cell.imagesView.frame.height * 1.18)))
                        imageView.image = imageName.image
                        imageView.contentMode = .scaleToFill
                        imageView.clipsToBounds = true
                        mainView.addSubview(imageView)
                        cell.imagesStackView.addArrangedSubview(mainView)
                    }
                    let item = self.videoUrls[self.currentPage].currentAsset
                    cell.loadAsset(item!)
                    if isEditMode, let item = item {
                        self.scPlayer?.setItemBy(item)
                        cell.trimmerView.isHidden = false
                    }
                    else {
                        cell.trimmerView.isHidden = true
                    }
                }
            }
            else {
                if videoUrls[(indexPath as NSIndexPath).row].isCombineOneVideo {
                    let mainView = UIView.init(frame: CGRect(x: 0, y: 3, width: 41, height: 52))
                    
                    let imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 41, height: 52))
                    imageView.image = images[0].image
                    imageView.contentMode = .scaleToFill
                    imageView.clipsToBounds = true
                    mainView.addSubview(imageView)
                    cell.imagesStackView.addArrangedSubview(mainView)
                } else {
                    if videoUrls[indexPath.row].isSelected {
                        for imageName in images {
                            let mainView = UIView.init(frame: CGRect(x: 0, y: 3, width: Double(41 * 1.2), height: Double(cell.imagesView.frame.height * 1.18)))
                            
                            let imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: Double(41 * 1.2), height: Double(cell.imagesView.frame.height * 1.18)))
                            imageView.image = imageName.image
                            imageView.contentMode = .scaleToFill
                            imageView.clipsToBounds = true
                            mainView.addSubview(imageView)
                            cell.imagesStackView.addArrangedSubview(mainView)
                        }
                        
                    } else {
                        for imageName in images {
                            let mainView = UIView.init(frame: CGRect(x: 0, y: 3, width: 41, height: 52))
                            let imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 41, height: 52))
                            imageView.image = imageName.image
                            imageView.contentMode = .scaleToFill
                            imageView.clipsToBounds = true
                            mainView.addSubview(imageView)
                            cell.imagesStackView.addArrangedSubview(mainView)
                        }
                    }
                }
                cell.trimmerView.isHidden = true
            }
            
            cell.imagesView.layer.cornerRadius = 5
            cell.imagesView.layer.borderWidth = borderWidth
            cell.imagesView.layer.borderColor = borderColor
            
            if let kdCollectionView = stopMotionCollectionView {
                if let draggingPathOfCellBeingDragged = kdCollectionView.draggingPathOfCellBeingDragged
                {
                    if draggingPathOfCellBeingDragged.item == indexPath.item {
                        cell.isHidden = true
                        draggingCell = indexPath
                    }
                }
            }
            
            return cell
        } else if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KeyframePickerCollectionViewCell", for: indexPath) as! KeyframePickerCollectionViewCell
            if _displayKeyframeImages.count != 0 {
                cell.keyframeImage = _displayKeyframeImages[indexPath.row]
            }
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    // MARK : KDDragAndDropCollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, dataItemForIndexPath indexPath: IndexPath) -> AnyObject {
        return videoUrls[indexPath.item]
    }
    
    public func collectionView(_ collectionView: UICollectionView, insertDataItem dataItem: AnyObject, atIndexPath indexPath: IndexPath) -> Void {
        
        if let di = dataItem as? SegmentVideos {
            videoUrls.insert(di, at: indexPath.item)
        }
        
    }
    public func collectionView(_ collectionView: UICollectionView, deleteDataItemAtIndexPath indexPath: IndexPath) -> Void {
        
        videoUrls.remove(at: indexPath.item)
        
    }
    
    func getUndo(index: Int) -> (()->Void) {
        return { () -> Void in
            self.videoUrls.remove(at: index)
        }
    }
    func getRedo(model: SegmentVideos, index: Int) -> (()->Void) {
        return { () -> Void in
            self.videoUrls.insert(model, at: index)
        }
    }
    
    func registerNewData(data: SegmentVideos, index: Int) {
        undoMgr.add(undo: getUndo(index: index), redo: getRedo(model: data, index: index))
    }
    
    func getDeleteUndo(model: SegmentVideos, data: Int) -> (()->Void) {
        return { () -> Void in
            self.videoUrls.insert(model, at: data)
        }
    }
    
    func getDeleteRedo(data: Int) -> (()->Void) {
        return { () -> Void in
            self.videoUrls.remove(at: data)
        }
    }
    
    func registerDeleteData(model: SegmentVideos, data: Int) {
        undoMgr.add(undo: getDeleteUndo(model: model, data: data), redo: getDeleteUndo(model: model, data: data))
        
    }
    
    func getNullDeleteUndo(model: SegmentVideos, data: Int) -> (()->Void) {
        return { () -> Void in
            
        }
    }
    
    func registerNullDeleteData(model: SegmentVideos, data: Int) {
        undoMgr.add(undo: getNullDeleteUndo(model: model, data: data), redo: getNullDeleteUndo(model: model, data: data))
    }
    
    public func collectionView(_ collectionView: UICollectionView, moveDataItemFromIndexPath from: IndexPath, toIndexPath to: IndexPath) -> Void {
        
        if isDisableResequence {
            return
        }
        
        if isMovable && !isDisableResequence {
            let videourl: SegmentVideos = videoUrls[from.item]
            let model = self.videoUrls[from.item]
            let modelTo = self.videoUrls[to.item]
            registerDeleteData(model: model, data: from.item)
            videoUrls.remove(at: from.item)
            registerNewData(data: modelTo, index: to.item)
            videoUrls.insert(videourl, at: to.item)
        }
        
        if fromCell == nil
        {
            if let kdCollectionView = collectionView as? KDDragAndDropCollectionView {
                if let draggingPathOfCellBeingDragged = kdCollectionView.draggingPathOfCellBeingDragged
                {
                    fromCell = draggingPathOfCellBeingDragged
                }
            }
        }
        lastMargeCell = to
        rearrangedView.isHidden = false
        
        if let kdCollectionView = collectionView as? KDDragAndDropCollectionView {
            if kdCollectionView.draggingPathOfCellBeingDragged != nil {
                if self.draggingCell != nil {
                    if !isMovable {
                        for visible in kdCollectionView.visibleCells {
                            self.setDeleteFrame(view: visible)
                        }
                        if draggingCell != to {
                            if let cell = kdCollectionView.cellForItem(at: to) {
                                self.setStickerObject(view: cell)
                            }
                        }
                    }
                    if to.item != self.currentPlayVideo {
                        self.selectedItem = to.row
                        self.currentPlayVideo = to.row
                        self.currentPage = self.currentPlayVideo
                    }
                }
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, indexPathForDataItem dataItem: AnyObject) -> IndexPath? {
        
        guard let candidate = dataItem as? SegmentVideos else { return nil }
        
        for (i, item) in videoUrls.enumerated() {
            if candidate.id != item.id {
                continue
            }
            return IndexPath(item: i, section: 0)
        }
        
        return nil
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellIsDraggableAtIndexPath indexPath: IndexPath) -> Bool {
        if self.thumbHeight.constant == 0.0 {
            return true
        }
        return false
    }
    
    public func collectionViewEdgesAndScroll(_ collectionView: UICollectionView, rect: CGRect) {
        
        let newrect = rect.origin.y + collectionView.frame.origin.y
        let newrectData = CGRect.init(x: rect.origin.x, y: newrect, width: rect.width, height: rect.height)
        
        if isDisableResequence {
            
            let checkframeDelete = CGRect.init(x: photoSegmentDeleteView.frame.origin.x, y: photoSegmentDeleteView.frame.origin.y, width: photoSegmentDeleteView.frame.width, height: photoSegmentDeleteView.frame.height)
            
            if checkframeDelete.intersects(newrectData) == true {
                UIView.animate(withDuration: 0.1, animations: { [weak self] () -> Void in
                    guard let strongSelf = self else { return }
                    strongSelf.setStickerObject(view: strongSelf.photoSegmentDeleteView)
                })
            }
            else {
                self.setDeleteFrame(view: photoSegmentDeleteView)
            }
            return
        }
        if currentCamaraMode != .slideshow {
            deleteView.isHidden = false
        }
        
        if !isMovable || currentCamaraMode == .slideshow {
            guard let currentPlayer = self.scPlayer else { return }
            currentPlayer.pause()
            stopPlaybackTimeChecker()
            return
        }
        
        if deleterectFrame!.intersects(newrectData) == true {
            self.setDeleteFrame(view: storyView)
            self.setDeleteFrame(view: outtakesView)
            self.setDeleteFrame(view: notesView)
            self.setDeleteFrame(view: chatView)
            self.setDeleteFrame(view: feedView)
            self.setDeleteFrame(view: youTubeView)
            UIView.animate(withDuration: 0.1, animations: { [weak self] () -> Void in
                guard let strongSelf = self else { return }
                strongSelf.setStickerObject(view: strongSelf.deleteView)
            })
        }
        else if outtakesFrame!.intersects(newrectData) == true {
            self.setDeleteFrame(view: deleteView)
            self.setDeleteFrame(view: notesView)
            self.setDeleteFrame(view: chatView)
            self.setDeleteFrame(view: feedView)
            self.setDeleteFrame(view: storyView)
            self.setDeleteFrame(view: youTubeView)
            UIView.animate(withDuration: 0.1, animations: { [weak self] () -> Void in
                guard let strongSelf = self else { return }
                strongSelf.setStickerObject(view: strongSelf.outtakesView)
            })
        }
        else if notesFrame!.intersects(newrectData) == true {
            self.setDeleteFrame(view: deleteView)
            self.setDeleteFrame(view: outtakesView)
            self.setDeleteFrame(view: chatView)
            self.setDeleteFrame(view: feedView)
            self.setDeleteFrame(view: storyView)
            self.setDeleteFrame(view: youTubeView)
            UIView.animate(withDuration: 0.1, animations: { [weak self] () -> Void in
                guard let strongSelf = self else { return }
                strongSelf.setStickerObject(view: strongSelf.notesView)
            })
        }
        else if chatFrame!.intersects(newrectData) == true {
            self.setDeleteFrame(view: deleteView)
            self.setDeleteFrame(view: outtakesView)
            self.setDeleteFrame(view: notesView)
            self.setDeleteFrame(view: feedView)
            self.setDeleteFrame(view: storyView)
            self.setDeleteFrame(view: youTubeView)
            UIView.animate(withDuration: 0.1, animations: { [weak self] () -> Void in
                guard let strongSelf = self else { return }
                strongSelf.setStickerObject(view: strongSelf.chatView)
            })
        }
        else if feedFrame!.intersects(newrectData) == true {
            self.setDeleteFrame(view: deleteView)
            self.setDeleteFrame(view: outtakesView)
            self.setDeleteFrame(view: notesView)
            self.setDeleteFrame(view: chatView)
            self.setDeleteFrame(view: storyView)
            self.setDeleteFrame(view: youTubeView)
            UIView.animate(withDuration: 0.1, animations: { [weak self] () -> Void in
                guard let strongSelf = self else { return }
                strongSelf.setStickerObject(view: strongSelf.feedView)
            })
        }
        else if storyFrame!.intersects(newrectData) == true {
            self.setDeleteFrame(view: deleteView)
            self.setDeleteFrame(view: outtakesView)
            self.setDeleteFrame(view: notesView)
            self.setDeleteFrame(view: chatView)
            self.setDeleteFrame(view: feedView)
            self.setDeleteFrame(view: youTubeView)
            UIView.animate(withDuration: 0.1, animations: { [weak self] () -> Void in
                guard let strongSelf = self else { return }
                strongSelf.setStickerObject(view: strongSelf.storyView)
            })
        }
        else if youtubeFrame!.intersects(newrectData) == true {
            self.setDeleteFrame(view: deleteView)
            self.setDeleteFrame(view: outtakesView)
            self.setDeleteFrame(view: notesView)
            self.setDeleteFrame(view: chatView)
            self.setDeleteFrame(view: feedView)
            self.setDeleteFrame(view: storyView)
            UIView.animate(withDuration: 0.1, animations: { [weak self] () -> Void in
                guard let strongSelf = self else { return }
                strongSelf.setStickerObject(view: strongSelf.youTubeView)
            })
        }
        else {
            self.setDeleteFrame(view: deleteView)
            self.setDeleteFrame(view: outtakesView)
            self.setDeleteFrame(view: notesView)
            self.setDeleteFrame(view: chatView)
            self.setDeleteFrame(view: feedView)
            self.setDeleteFrame(view: storyView)
            self.setDeleteFrame(view: youTubeView)
            self.setDeleteFrame(view: photoSegmentDeleteView)
        }
        
        guard let currentPlayer = self.scPlayer else { return }
        currentPlayer.pause()
        stopPlaybackTimeChecker()
    }
    
    public func collectionViewLastEdgesAndScroll(_ collectionView: UICollectionView, rect: CGRect) {
        let newrect = rect.origin.y + collectionView.frame.origin.y
        let newrectData = CGRect.init(x: rect.origin.x, y: newrect, width: rect.width, height: rect.height)
        
        if !isMovable {
            if self.lastMargeCell != self.draggingCell {
                stopMotionCollectionView.isUserInteractionEnabled = false
                segmentEditOptionView.isHidden = true
                segmentEditOptionButton.isHidden = true
                segmentTypeMergeView.isHidden = false
            }
            else
            {
                DispatchQueue.main.async {
                    guard let player = self.scPlayer else { return }
                    player.isPlaying ? player.play() : nil
                    self.startPlaybackTimeChecker()
                }
            }
            if currentCamaraMode == .slideshow {
                segmentTypeMergeView.isHidden = true
            }
            return
        }
        
        if currentCamaraMode == .slideshow {
            segmentTypeMergeView.isHidden = true
        }
        
        if deleterectFrame!.intersects(newrectData) == true && currentCamaraMode != .slideshow {
            if let kdCollectionView = collectionView as? KDDragAndDropCollectionView {
                
                if let draggingPathOfCellBeingDragged = kdCollectionView.draggingPathOfCellBeingDragged {
                    if draggingCell != nil {
                        if draggingPathOfCellBeingDragged.item == draggingCell!.item {
                            let album = SCAlbum.shared
                            album.albumName = "\(Constant.Application.displayName) – Recycle"
                            album.saveMovieToLibrary(movieURL: videoUrls[draggingPathOfCellBeingDragged.item].url!)
                            let model = self.videoUrls[draggingPathOfCellBeingDragged.row]
                            registerNullDeleteData(model: model, data: draggingPathOfCellBeingDragged.row)
                            registerDeleteData(model: model, data: draggingPathOfCellBeingDragged.row)
                            videoUrls.remove(at: draggingPathOfCellBeingDragged.row)
                            if videoUrls.count == 0 {
                                self.navigationController?.popViewController(animated: true)
                            } else {
                                self.currentPlayVideo = -1
                                self.connVideoPlay()
                            }
                        }
                    }
                }
            }
        }
        else if outtakesFrame!.intersects(newrectData) {
            if currentCamaraMode == .slideshow {
                return
            }
            if let kdCollectionView = collectionView as? KDDragAndDropCollectionView {
                if let draggingPathOfCellBeingDragged = kdCollectionView.draggingPathOfCellBeingDragged {
                    if draggingCell != nil {
                        if draggingPathOfCellBeingDragged.item == draggingCell!.item {
                            selectedVideoUrlSave = videoUrls[draggingPathOfCellBeingDragged.item]
                            outtakesView.isUserInteractionEnabled = false
                            if currentCamaraMode == .slideshow {
                                self.saveImage(exportType: .outtakes, image: selectedVideoUrlSave!.image!)
                            } else {
                                self.saveButtonTapped()
                            }
                            videoUrls.remove(at: draggingPathOfCellBeingDragged.item)
                            self.currentPlayVideo = -1
                            self.connVideoPlay()
                        }
                    }
                }
            }
        }
        else if notesFrame!.intersects(newrectData) {
            if currentCamaraMode == .slideshow {
                return
            }
            if let kdCollectionView = collectionView as? KDDragAndDropCollectionView {
                if let draggingPathOfCellBeingDragged = kdCollectionView.draggingPathOfCellBeingDragged {
                    if draggingCell != nil {
                        if draggingPathOfCellBeingDragged.item == draggingCell!.item {
                            selectedVideoUrlSave = videoUrls[draggingPathOfCellBeingDragged.item]
                            if currentCamaraMode == .slideshow {
                                self.saveImage(exportType: .notes, image: selectedVideoUrlSave!.image!)
                            } else {
                                self.notesButtonClicked(notesView!)
                            }
                        }
                    }
                }
            }
        }
        else if chatFrame!.intersects(newrectData) {
            if currentCamaraMode == .slideshow {
                return
            }
            if let kdCollectionView = collectionView as? KDDragAndDropCollectionView {
                if let draggingPathOfCellBeingDragged = kdCollectionView.draggingPathOfCellBeingDragged {
                    if draggingCell != nil {
                        if draggingPathOfCellBeingDragged.item == draggingCell!.item {
                            selectedVideoUrlSave = videoUrls[draggingPathOfCellBeingDragged.item]
                            if currentCamaraMode == .slideshow {
                                self.saveImage(exportType: .chat, image: selectedVideoUrlSave!.image!)
                            } else {
                                self.messageClicked(chatView!)
                            }
                        }
                    }
                }
            }
        }
        else if feedFrame!.intersects(newrectData) {
            if currentCamaraMode == .slideshow {
                return
            }
            if let kdCollectionView = collectionView as? KDDragAndDropCollectionView {
                if let draggingPathOfCellBeingDragged = kdCollectionView.draggingPathOfCellBeingDragged {
                    if draggingCell != nil {
                        if draggingPathOfCellBeingDragged.item == draggingCell!.item {
                            selectedVideoUrlSave = videoUrls[draggingPathOfCellBeingDragged.item]
                            if currentCamaraMode == .slideshow {
                                self.saveImage(exportType: .feed, image: selectedVideoUrlSave!.image!)
                            } else {
                                self.btnPostToFeedClick(feedView!)
                            }
                        }
                    }
                }
            }
        }
        else if storyFrame!.intersects(newrectData) {
            if currentCamaraMode == .slideshow {
                return
            }
            if let kdCollectionView = collectionView as? KDDragAndDropCollectionView {
                if let draggingPathOfCellBeingDragged = kdCollectionView.draggingPathOfCellBeingDragged {
                    if draggingCell != nil {
                        if draggingPathOfCellBeingDragged.item == draggingCell!.item {
                            selectedVideoUrlSave = videoUrls[draggingPathOfCellBeingDragged.item]
                            if currentCamaraMode == .slideshow {
                                self.saveImage(exportType: .story, image: selectedVideoUrlSave!.image!)
                            } else {
                                self.continueButtonPressed(storyView!)
                            }
                        }
                    }
                }
            }
        }
        else if youtubeFrame!.intersects(newrectData) {
            if currentCamaraMode == .slideshow {
                return
            }
            if let kdCollectionView = collectionView as? KDDragAndDropCollectionView {
                if let draggingPathOfCellBeingDragged = kdCollectionView.draggingPathOfCellBeingDragged {
                    if draggingCell != nil {
                        if draggingPathOfCellBeingDragged.item == draggingCell!.item {
                            selectedVideoUrlSave = videoUrls[draggingPathOfCellBeingDragged.item]
                            self.uploadToYouTubeClicked(youTubeView!)
                        }
                    }
                }
            }
        }
        else {
            let checkframeDelete = CGRect.init(x: photoSegmentDeleteView.frame.origin.x, y: photoSegmentDeleteView.frame.origin.y, width: photoSegmentDeleteView.frame.width, height: photoSegmentDeleteView.frame.height)
            if checkframeDelete.intersects(newrectData) == true {
                if draggingCell != nil {
                    if let draggingPathOfCellBeingDragged = draggingCell {
                        let album = SCAlbum.shared
                        album.albumName = "\(Constant.Application.displayName) – Recycle"
                        let model = self.videoUrls[draggingPathOfCellBeingDragged.row]
                        album.save(image: model.image!)
                        
                        registerNullDeleteData(model: model, data: draggingPathOfCellBeingDragged.row)
                        registerDeleteData(model: model, data: draggingPathOfCellBeingDragged.row)
                        videoUrls.remove(at: draggingPathOfCellBeingDragged.row)
                        
                        self.currentPlayVideo = -1
                        self.connVideoPlay()
                        return
                    }
                }
            }
            
            for view in photosView {
                let checkframe = CGRect.init(x: view.frame.origin.x, y: view.frame.origin.y + photosStackView.frame.origin.y - 5, width: view.frame.width, height: view.frame.height)
                if checkframe.intersects(newrectData) == true {
                    if let kdCollectionView = collectionView as? KDDragAndDropCollectionView {
                        if kdCollectionView.draggingPathOfCellBeingDragged != nil {
                            if draggingCell != nil {
                                if let draggingPathOfCellBeingDragged = draggingCell {
                                    
                                    let selectedVideoUrlSave = videoUrls[draggingPathOfCellBeingDragged.item]
                                    
                                    let nilCount = self.selectedSlideShowImages.filter({ (segmentVideo) -> Bool in
                                        return (segmentVideo == nil)
                                    })
                                    
                                    if nilCount.count == 3 {
                                        
                                        let alert = UIAlertController(title: Constant.Application.displayName, message: "Upgrade to Pro version to upload more than 3 image in slideshow.", preferredStyle: UIAlertController.Style.alert)
                                        let upgradeToPrime = UIAlertAction(title: "Upgrade to Prime", style: .default, handler: { (a) in
                                        })
                                        let upgradeToContent = UIAlertAction(title: "Upgrade to content creator", style: .default, handler: { (a) in
                                            
                                        })
                                        let remindMeLater = UIAlertAction(title: "Remind me later", style: .default, handler: { (a) in
                                            
                                        })
                                        alert.addAction(upgradeToPrime)
                                        alert.addAction(upgradeToContent)
                                        alert.addAction(remindMeLater)
                                        self.present(alert, animated: true, completion: nil)
                                        
                                        return
                                    }
                                    
                                    for btn in btnImageClose {
                                        if btn.tag == view.tag {
                                            
                                            let selectedVideo = self.selectedSlideShowImages[btn.tag - 1]
                                            for video in videoUrls {
                                                if selectedVideo?.id == video.id {
                                                    video.isSelected = false
                                                }
                                            }
                                            
                                            self.selectedSlideShowImages.remove(at: btn.tag - 1)
                                            self.selectedSlideShowImages.insert(selectedVideoUrlSave, at: btn.tag - 1)
                                            btnImageClose[view.tag - 1].isHidden = false
                                            
                                            self.stopMotionCollectionView.reloadData()
                                        }
                                    }
                                    
                                    let allSegment = self.selectedSlideShowImages.filter({ (segmentVideo) -> Bool in
                                        return (segmentVideo != nil)
                                    })
                                    if allSegment.count < 2 {
                                        enableSaveButtons(false, alpha: 0.5)
                                    }
                                    else {
                                        enableSaveButtons(true, alpha: 1.0)
                                    }
                                    
                                    switch view.tag {
                                    case 1:
                                        custImage1.image = selectedVideoUrlSave.image
                                        break
                                    case 2:
                                        custImage2.image = selectedVideoUrlSave.image
                                        break
                                    case 3:
                                        custImage3.image = selectedVideoUrlSave.image
                                        break
                                    case 4:
                                        custImage4.image = selectedVideoUrlSave.image
                                        break
                                    case 5:
                                        custImage5.image = selectedVideoUrlSave.image
                                        break
                                    case 6:
                                        custImage6.image = selectedVideoUrlSave.image
                                        break
                                    default:
                                        break
                                    }
                                    
                                    selectedVideoUrlSave.isSelected = true
                                }
                            }
                        }
                    }
                    break
                }
            }
        }
        DispatchQueue.main.async {
            guard let player = self.scPlayer else { return }
            player.isPlaying ? player.play() : nil
            self.startPlaybackTimeChecker()
        }
    }
}
