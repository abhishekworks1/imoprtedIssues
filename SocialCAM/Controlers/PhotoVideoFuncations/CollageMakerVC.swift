//
//  CollageMakerVC.swift
//  ProManager
//
//  Created by Viraj Patel on 01/03/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit
import Photos

class CollageMakerVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var headerTitleLbl: UILabel!
    @IBOutlet weak var menu01: UIView!
    @IBOutlet weak var menu02: UIView!
    @IBOutlet weak var menu03: UIView!
    @IBOutlet weak var menu04: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var allCollectionView: UIView!
    @IBOutlet weak var bottomHideViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var bottomClickView: UIView!
    
    var selectedImageCell: Int = 0
    weak var delegate: CollageMakerVCDelegate?
    var isFreeFrame = false
    var photoIndex: Int = 0
    var selectedPhotoCount: Int = 0
    var borderWidth: Int = 0
    var movingImageView: UIImageView?
    var collageView: CollageView!
    var movingCell: CollageCell?
    var identity = CGAffineTransform.identity
    var selectedIndex = IndexPath.init(row: 0, section: 0)
    
    fileprivate var collageItems: [CollageViewType] = [.t101, .t201, .t202, .t203, .t204, .t205, .t206, .t207, .t208, .t209, .t301, .t302, .t303, .t304, .t305, .t306, .t307, .t308, .t309, .t310, .t311, .t312, .t313, .t401, .t402, .t403, .t404, .t405, .t406, .t407, .t408, .t501, .t502, .t503, .t504, .t505, .t506, .t601, .t602, .t801, .t802]
    fileprivate var collageImagesItems: [UIImage] = [R.image.t101() ?? UIImage(),
                                                      R.image.t201() ?? UIImage(),
                                                      R.image.t202() ?? UIImage(),
                                                      R.image.t203() ?? UIImage(),
                                                      R.image.t204() ?? UIImage(),
                                                      R.image.t205() ?? UIImage(),
                                                      R.image.t206() ?? UIImage(),
                                                      R.image.t207() ?? UIImage(),
                                                      R.image.t208() ?? UIImage(),
                                                      R.image.t209() ?? UIImage(),
                                                      R.image.t301() ?? UIImage(),
                                                      R.image.t302() ?? UIImage(),
                                                      R.image.t303() ?? UIImage(),
                                                      R.image.t304() ?? UIImage(),
                                                      R.image.t305() ?? UIImage(),
                                                      R.image.t306() ?? UIImage(),
                                                      R.image.t307() ?? UIImage(),
                                                      R.image.t308() ?? UIImage(),
                                                      R.image.t309() ?? UIImage(),
                                                      R.image.t310() ?? UIImage(),
                                                      R.image.t311() ?? UIImage(),
                                                      R.image.t312() ?? UIImage(),
                                                      R.image.t313() ?? UIImage(),
                                                      R.image.t401() ?? UIImage(),
                                                      R.image.t402() ?? UIImage(),
                                                      R.image.t403() ?? UIImage(),
                                                      R.image.t404() ?? UIImage(),
                                                      R.image.t405() ?? UIImage(),
                                                      R.image.t406() ?? UIImage(),
                                                      R.image.t407() ?? UIImage(),
                                                      R.image.t408() ?? UIImage(),
                                                      R.image.t501() ?? UIImage(),
                                                      R.image.t502() ?? UIImage(),
                                                      R.image.t503() ?? UIImage(),
                                                      R.image.t504() ?? UIImage(),
                                                      R.image.t505() ?? UIImage(),
                                                      R.image.t506() ?? UIImage(),
                                                      R.image.t601() ?? UIImage(),
                                                      R.image.t602() ?? UIImage(),
                                                      R.image.t801() ?? UIImage(),
                                                      R.image.t802() ?? UIImage()]
    
    public var assets: [SegmentVideos] = []
    public var selectedItemArray: [SegmentVideos] = []
    fileprivate var selectedItemSet = Set<SegmentVideos>()
    fileprivate var selectedImageArray = [UIImage]()
    
    var collageType: CollageViewType = .t301
    var currentModeType: CurrentMode = .frames
    var collageRatio: CGFloat = 1.0
    
    deinit {
        print("Deinit \(self.description)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        
        imageCollectionView.isHidden = true
        collectionView.isHidden = false
        
        menu01.isHidden = collectionView.isHidden
        menu02.isHidden = imageCollectionView.isHidden
        
        bottomClickView.isHidden = false
        allCollectionView.isHidden = true
        
        self.selectedImageArray.removeAll()
        self.selectedItemArray = Array(self.assets).sorted { (first, second) -> Bool in
            return first.uploadTime < second.uploadTime
        }
        
        for sitem in self.selectedItemArray {
            self.selectedImageArray.append(sitem.image ?? UIImage())
        }
        
        menu01.layer.borderColor = UIColor.darkGray.cgColor
        menu01.backgroundColor = ApplicationSettings.appClearColor
        menu01.layer.borderWidth = 1.0
        
        menu02.layer.borderColor = UIColor.darkGray.cgColor
        menu02.backgroundColor = ApplicationSettings.appClearColor
        menu02.layer.borderWidth = 1.0
        
        menu03.layer.borderColor = UIColor.darkGray.cgColor
        menu03.backgroundColor = ApplicationSettings.appClearColor
        menu03.layer.borderWidth = 1.0
        
        menu04.layer.borderColor = UIColor.darkGray.cgColor
        menu04.backgroundColor = ApplicationSettings.appClearColor
        menu04.layer.borderWidth = 1.0
        
        var index: Int = 0
        
        switch selectedItemArray.count {
        case 1:
            index = 0
        case 2:
            index = 1
        case 3:
            index = 10
        case 4:
            index = 23
        case 5:
            index = 31
        case 6:
            index = Defaults.shared.appMode == .free || Defaults.shared.appMode == .basic ? 31 : 37
        case 7, 8:
            index = Defaults.shared.appMode == .free || Defaults.shared.appMode == .basic ? 31 : 39
        default:
            index = Defaults.shared.appMode == .free || Defaults.shared.appMode == .basic ? 31 : 39
        }
        
        if Defaults.shared.appMode == .free || Defaults.shared.appMode == .basic {
            collageImagesItems.removeLast(4)
        }
        
        collectViewSet(index: index)
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.1 //seconds
        lpgr.delegate = self
        imageCollectionView.addGestureRecognizer(lpgr)
        collectionView.reloadData()
    }
    
    fileprivate func setupLayout() {
        let layout = self.collectionView.collectionViewLayout as? UPCarouselFlowLayout
        layout?.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: 0.1)
        collectionView.register(R.nib.frameCollectionViewCell)
        
        let imageCollectionViewLayout = self.imageCollectionView.collectionViewLayout as? UPCarouselFlowLayout
        imageCollectionViewLayout?.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: 0.1)
        imageCollectionView.register(R.nib.imageCollectionViewCell)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnLayoutChangeClick(_ sender: Any) {
        currentModeType = .frames
        imageCollectionView.isHidden = true
        collectionView.isHidden = false
        menu01.isHidden = collectionView.isHidden
        menu02.isHidden = imageCollectionView.isHidden
        self.collectionView.reloadData()
    }
    
    @IBAction func btnImagesClick(_ sender: Any) {
        currentModeType = .photos
        imageCollectionView.isHidden = false
        collectionView.isHidden = true
        menu01.isHidden = collectionView.isHidden
        menu02.isHidden = imageCollectionView.isHidden
        self.imageCollectionView.reloadData()
    }
    
    @IBAction func btnBottomBarClicked(_ sender: Any) {
        bottomClickView.isHidden = true
        allCollectionView.isHidden = false
    }
    
    @IBAction func btnDoneLayoutImages(_ sender: Any) {
        bottomClickView.isHidden = false
        allCollectionView.isHidden = true
    }
    
    @IBAction func btnSaveClick(_ sender: Any) {
        
        for cell in collageView.collageCells {
            cell.isSelected = false
        }
        
        var image = containerView.toImage()
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        image = image.resizeImageWith(newSize: CGSize.init(width: 720, height: 1280))
        self.navigationController?.popViewController(animated: false)
        delegate?.didSelectImage(image: image)
    }
    
    @IBAction func btnRotateClick(_ sender: Any) {
        for cell in collageView.collageCells {
            if let image = cell.photoView.photoImage.image?.imageRotated(on: 90) {
                cell.photoView.setPhoto(img: image)
            }
        }
    }
    
    @IBAction func btnBackClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func handleLongPress(_ longRecognizer: UILongPressGestureRecognizer?) {
        
        let locationPointInCollection: CGPoint = longRecognizer?.location(in: imageCollectionView) ?? CGPoint.zero
        let locationPointInView: CGPoint = longRecognizer?.location(in: view) ?? CGPoint.zero
        
        if longRecognizer?.state == .began {
            let indexPathOfMovingCell: IndexPath? = imageCollectionView.indexPathForItem(at: locationPointInCollection)
            photoIndex = indexPathOfMovingCell?.row ?? 0
            let image = self.selectedItemArray[photoIndex].image
            
            let frame = CGRect(x: locationPointInView.x, y: locationPointInView.y, width: 150.0, height: 150.0)
            movingImageView = UIImageView(frame: frame)
            movingImageView?.image = image
            movingImageView?.center = locationPointInView
            movingImageView?.layer.borderWidth = 5.0
            movingImageView?.layer.borderColor = ApplicationSettings.appWhiteColor.cgColor
            view.addSubview(movingImageView!)
        }
        
        if longRecognizer?.state == .changed {
            movingImageView?.center = locationPointInView
        }
        
        if longRecognizer?.state == .ended {
            let frameRelativeToParentCollageFrame: CGRect = collageView.convert(collageView.bounds, to: view)
            if frameRelativeToParentCollageFrame.contains(movingImageView?.center ?? CGPoint.zero) {
                if isFreeFrame {
                    let originInCollageView: CGPoint = collageView.convert(movingImageView?.center ?? CGPoint.zero, from: view)
                    let width: Float = Float((collageView.bounds.size.width - 5) / 2)
                    
                    let cell01 = CollageCell.init(id: collageView.subviews.count + 1)
                    cell01.frame = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(width))
                    cell01.translatesAutoresizingMaskIntoConstraints = true
                    cell01.center = originInCollageView
                    //cell01.delegate = self
                    
                    let image = self.selectedItemArray[photoIndex].image
                    cell01.photoView.setPhoto(img: image ?? UIImage())
                    
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(detectTap(_:)))
                    cell01.addGestureRecognizer(tapGesture)
                    
                    let doubleTap = UITapGestureRecognizer(target: self, action: #selector(detectDoubleTap(_:)))
                    doubleTap.numberOfTapsRequired = 2
                    cell01.addGestureRecognizer(doubleTap)
                    
                    let pan = UIPanGestureRecognizer(target: self, action: #selector(self.moveImage(inCollage:)))
                    pan.delegate = self
                    cell01.addGestureRecognizer(pan)
                    
                    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(scale))
                    let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotate))
                    
                    pinchGesture.delegate = self
                    rotationGesture.delegate = self
                    
                    cell01.addGestureRecognizer(pinchGesture)
                    cell01.addGestureRecognizer(rotationGesture)
                    cell01.layer.borderWidth = 20
                    cell01.layer.borderColor = ApplicationSettings.appClearColor.cgColor
                    
                    collageView.addSubview(cell01)
                    movingImageView?.removeFromSuperview()
                } else {
                    for indexView in collageView.subviews.reversed() {
                        if let cell = indexView as? CollageCell {
                            let tmpScroll = cell
                            let frameRelativeToParent = tmpScroll.convert(tmpScroll.bounds, to: view)
                            if frameRelativeToParent.contains(movingImageView?.center ?? CGPoint.zero) {
                                let image = self.selectedItemArray[photoIndex].image ?? UIImage()
                                tmpScroll.photoView.setPhoto(img: image)
                                self.selectedImageArray[cell.id - 1] = image
                                movingImageView?.removeFromSuperview()
                                break
                            }
                        }
                    }
                }
            } else {
                movingImageView?.removeFromSuperview()
            }
        }
    }
}

// MARK: UICollectionViewDataSource
extension CollageMakerVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if currentModeType == .frames && collectionView == self.collectionView {
            return collageImagesItems.count
        } else if currentModeType == .photos && collectionView == self.imageCollectionView {
            return selectedItemArray.count
        }
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if currentModeType == .frames && collectionView == self.collectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.frameCollectionViewCell.identifier, for: indexPath) as? FrameCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            if selectedIndex == indexPath {
                cell.frameImageView.image = collageImagesItems[indexPath.row].withImageTintColor(ApplicationSettings.appPrimaryColor)
            } else {
                cell.frameImageView.image = collageImagesItems[indexPath.row]
            }
            
            return cell
        } else if currentModeType == .photos && collectionView == self.imageCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.imageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let borderColor: CGColor! = ApplicationSettings.appBlackColor.cgColor
            let borderWidth: CGFloat = 3
            
            cell.imagesStackView.tag = indexPath.row
            
            var images = [SegmentVideos]()
            
            images = [selectedItemArray[indexPath.row]]
            
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
            
            return cell
        } else {
            return UICollectionViewCell.init(reuseIdentifier: "cell")
        }
    }
    
}

// MARK: UICollectionViewDelegate
extension CollageMakerVC: UICollectionViewDelegate {
    
    func collectViewSet(index: Int) {
        self.view.layoutIfNeeded()
        
        let indexPath = IndexPath.init(row: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .right, animated: false)
        
        let collageItem = self.collageItems[index]
        selectedIndex = IndexPath.init(row: index, section: 0)
        collageType = collageItem
        collageView = collageItem.getInstance
        let len = self.containerView.frame.size.width * 0.9
        let size = CGSize(width: len, height: len * self.collageRatio)
        
        collageView.frame = CGRect(x: (self.containerView.frame.size.width - size.width) / 2.0, y: (self.containerView.frame.size.height - size.height) / 2.0, width: size.width, height: size.height)
        collageView.translatesAutoresizingMaskIntoConstraints = false
        for view in self.containerView.subviews {
            view.removeFromSuperview()
        }
        collageView.delegate = self
        self.containerView.addSubview(collageView)
        
        let lc01 = NSLayoutConstraint(item: collageView!, attribute: .centerX, relatedBy: .equal, toItem: self.containerView, attribute: .centerX, multiplier: 1, constant: 0)
        let lc02 = NSLayoutConstraint(item: collageView!, attribute: .centerY, relatedBy: .equal, toItem: self.containerView, attribute: .centerY, multiplier: 1, constant: 0)
        let lc03 = NSLayoutConstraint(item: collageView!, attribute: .width, relatedBy: .equal, toItem: self.containerView, attribute: .width, multiplier: 1.0, constant: 0)
        let lc04 = NSLayoutConstraint(item: collageView!, attribute: .height, relatedBy: .equal, toItem: self.containerView, attribute: .height, multiplier: self.collageRatio, constant: 0)
        NSLayoutConstraint.activate([ lc01, lc02, lc03, lc04])
        collageView.layoutIfNeeded()
        collageView.layoutSubviews()
        collageView.setPhotos(photos: self.selectedImageArray)
        
        if collageType == .t404 {
            collageView.setViewHaxa(isRoundedHex: true)
        } else if collageType == .t405 {
            collageView.setViewHaxa()
        } else if self.collageType == .t602 {
            collageView.cornerRedius(views: collageView.collageCells)
        } else if self.collageType == .t304 {
            collageView.setHeartView(indexItem: 3)
        } else if self.collageType == .t406 {
            collageView.setTransferentView(isLargeSize: true)
        } else if self.collageType == .t206 {
            collageView.setHeartView(indexItem: 2)
        } else if self.collageType == .t309 {
            collageView.cornerRedius(views: [collageView.collageCells[2]])
            self.collageView.addBorder(cell: self.collageView.collageCells[2], val: 3)
        } else if self.collageType == .t313 {
            collageView.setHaxa(cell: collageView.collageCells[2])
        } else if self.collageType == .t506 {
            collageView.cornerRedius(views: [self.collageView.collageCells[4]])
            collageView.addBorder(cell: self.collageView.collageCells[4], val: 3)
        } else if self.collageType == .t308 || self.collageType == .t310 || self.collageType == .t303 {
            self.collageView.addBorder(cell: self.collageView.collageCells[2], val: 3)
        } else if self.collageType == .t504 {
            collageView.addBorder(cell: self.collageView.collageCells[4], val: 3)
        } else if self.collageType == .t205 || self.collageType == .t207 {
            collageView.addBorder(cell: self.collageView.collageCells[1], val: 3)
        }
        
        if collageType != .t405 {
            collageView.updateMargin(val: 2.0)
            collageView.updatePadding(val: 2.0)
        }
        
        isFreeFrame = collageType == .t101 ? true : false
        
        print("final Rect: \(view.frame)")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if currentModeType == .frames {
            selectedIndex = indexPath
            collectViewSet(index: indexPath.row)
            collectionView.reloadData()
        }
    }
}

extension CollageMakerVC: DrawViewDelegate {
    
    func didSelectImage(image: UIImage) {
        for cell in collageView.collageCells {
            if cell.id == selectedImageCell {
                cell.photoView.setPhoto(img: image)
            }
        }
    }
    
}

extension CollageMakerVC: CollageViewDelegate {
    func didSelectBlankCell(cellId: Int) {
        selectedImageCell = cellId
        DispatchQueue.main.async {
            if let drawingContainerView = R.storyboard.collageMaker.drawViewController() {
                drawingContainerView.delegateImage = self
                self.navigationController?.pushViewController(drawingContainerView, animated: true)
            }
        }
    }
    
    func didSelectCell(cellId: Int) {
        
    }
    
    @objc func detectTap(_ gesture: UITapGestureRecognizer) {
        let locationPointInView: CGPoint? = gesture.location(in: collageView)
        if let view = gesture.view as? CollageCell {
            for allView in collageView.subviews {
                if let cell = allView as? CollageCell {
                    let frameRelativeToParent = cell.convert(cell.bounds, to: collageView)
                    if cell.id == view.id {
                        if frameRelativeToParent.contains(locationPointInView ?? .zero) {
                            movingCell = cell
                            collageView.bringSubviewToFront(movingCell!)
                            print(cell.id)
                        }
                    }
                }
            }
        }
    }
    
    @objc func detectDoubleTap(_ gesture: UITapGestureRecognizer) {
        if let view = gesture.view as? CollageCell {
            view.removeFromSuperview()
        }
    }
    
    @objc func scale(_ gesture: UIPinchGestureRecognizer) {
        if let view = gesture.view as? CollageCell {
            switch gesture.state {
            case .began:
                identity = view.transform
            case .changed, .ended:
                view.transform = identity.scaledBy(x: gesture.scale, y: gesture.scale)
                view.layoutSubviews()
                view.photoView.layoutSubviews()
            case .cancelled:
                break
            default:
                break
            }
        }
    }
    
    @objc func rotate(_ gesture: UIRotationGestureRecognizer) {
        if let view = gesture.view as? CollageCell {
            view.transform = view.transform.rotated(by: gesture.rotation)
            
            view.layoutSubviews()
            view.photoView.layoutSubviews()
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func moveImage(inCollage gesture: UIPanGestureRecognizer?) {
        let locationPointInView: CGPoint? = gesture?.location(in: collageView)
        let locationPointInSuperView: CGPoint? = gesture?.location(in: view)
        if gesture?.state == .began {
            if let view = gesture?.view as? CollageCell {
                for allView in collageView.subviews {
                    if let cell = allView as? CollageCell {
                        let frameRelativeToParent = cell.convert(cell.bounds, to: collageView)
                        if cell.id == view.id {
                            if frameRelativeToParent.contains(locationPointInView ?? .zero) {
                                movingCell = cell //(UIImageView*)i;
                                collageView.bringSubviewToFront(movingCell!)
                            }
                        }
                    }
                }
            }
        }
        if gesture?.state == .changed {
            let frameRelativeToParent: CGRect = (movingCell?.convert((movingCell?.bounds)!, to: collageView))!
            if frameRelativeToParent.contains(locationPointInView ?? .zero) {
                movingCell!.center = locationPointInView ?? .zero
            }
        }
        if gesture?.state == .ended {
            let frameRelativeToParent: CGRect = collageView.convert(collageView.bounds, to: view)
            if !frameRelativeToParent.contains(locationPointInSuperView ?? .zero) {
                movingCell?.removeFromSuperview()
                for allView in collageView.subviews {
                    if let cell = allView as? CollageCell {
                        let frameRelativeToParent = cell.convert(cell.bounds, to: collageView)
                        if frameRelativeToParent.contains(locationPointInView ?? .zero) {
                            cell.isUserInteractionEnabled = true
                            
                        }
                    }
                }
            }
        }
    }
}
