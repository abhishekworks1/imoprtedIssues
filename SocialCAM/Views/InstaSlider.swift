//
//  InstaSlider.swift
//  InstaSlider
//
//  Created by Viraj Patel on 18/06/18.
//

import Foundation
import UIKit

public typealias CurrentCellCallBack = ((_ index: Int, _ currentModes: CameraModes) -> Void)

open class InstaSlider: UIView {
    
    open var backgroundImage: UIImageView?
    
    var collectionView: UICollectionView!
    var cellId = "collectionCell"
    open var bottomImage: UIImage? = UIImage() {
        didSet {
            backgroundImage?.image = bottomImage
        }
    }
    
    open var cellTextColor: UIColor = UIColor.black
    open var selectedCellTextColor: UIColor = UIColor.white
    
    open var stringArray: [CameraModes] = [] {
        didSet {
            self.configureCollectionView()
        }
    }
    
    private var collectionViewLayout: HorizontalFlowLayout!
    
    open var selectCell: Int = 0 {
        didSet {
            if selectedCell == selectCell {
                return
            }
            selectedCell = selectCell
            DispatchQueue.runOnMainThread {
                self.collectionView.selectItem(at: IndexPath(item: self.selectCell, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
                if (self.currentCell != nil) {
                    self.currentCell!(self.selectCell, self.stringArray[self.selectCell])
                }
            }
        }
    }
    
    var selectedCell: Int! = 0
    
    open var currentCell: CurrentCellCallBack?
    
    open var isScrollEnable: CurrentCellCallBack?
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.ratioWidth, height: 64))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        self.layoutSubviews()
        self.layoutIfNeeded()
        collectionViewInitialization()
    }
    
    func collectionViewInitialization() {
        // Initialization code
        backgroundColor = UIColor.clear
//        backgroundImage = UIImageView(frame: CGRect.init(x: (self.bounds.minX), y: (self.bounds.maxY) - 37, width: UIScreen.ratioWidth, height: 37))
//        backgroundImage?.contentMode = .scaleAspectFit
//        let image = bottomImage
//        backgroundImage?.image = image
//        if let anImage = backgroundImage {
//            self.addSubview(anImage)
//        }
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        self.collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionViewLayout = HorizontalFlowLayout.configureLayout(collectionView: self.collectionView, itemSize: CGSize.init(width: 110, height: self.collectionView.frame.height/2), minimumLineSpacing: 2)
        
        self.collectionView.collectionViewLayout = collectionViewLayout
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.isPagingEnabled = false
        self.collectionView.register(CollectionViewCustomCell.self, forCellWithReuseIdentifier: cellId)
        self.collectionView.backgroundColor = UIColor.clear
        self.addSubview(self.collectionView)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        collectionViewInitialization()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundImage?.frame = CGRect.init(x: self.bounds.minX, y: self.bounds.maxY - 37, width: self.bounds.width, height: 37)
        self.collectionView?.frame = bounds
    }
    
    // MARK: - ConfigureCollectionView
    
    func configureCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func findCenterIndex(scrollView: UIScrollView) {
        let collectionOrigin = collectionView!.bounds.origin
        let collectionWidth = collectionView!.bounds.width
        var centerPoint: CGPoint!
        var newX: CGFloat!
        if collectionOrigin.x > 0 {
            newX = collectionOrigin.x + collectionWidth / 2
            centerPoint = CGPoint(x: newX, y: collectionOrigin.y)
        } else {
            newX = collectionOrigin.x + collectionWidth / 2
            centerPoint = CGPoint(x: newX, y: collectionOrigin.y)
        }
        //let index = collectionView!.indexPathForItem(at: centerPoint)

        // for linear collectionview
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)

        let index = collectionView!.indexPathForItem(at: visiblePoint)
        let cells = collectionView!.cellForItem(at: IndexPath.init(item: 0, section: 0)) as? CollectionViewCustomCell
        
        if(index != nil) {
            for cell in self.collectionView.visibleCells {
                guard let currentCell = cell as? CollectionViewCustomCell else {
                    return
                }
                currentCell.label.textColor = cellTextColor
            }
            
            let cell = collectionView.cellForItem(at: index!) as? CollectionViewCustomCell
            if(cell != nil) {
                selectedCell = collectionView.indexPath(for: cell!)?.item
                cell!.label.textColor = selectedCellTextColor
                if (self.currentCell != nil) {
                    self.currentCell!((index?.row)!, self.stringArray[(index!.row)])
                }
            }
        } else if(cells != nil) {
            let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
            for cellView in self.collectionView.visibleCells {
                let currentCell = cellView as? CollectionViewCustomCell
                currentCell!.label.textColor = cellTextColor
                
                if(currentCell == cells! && (selectedCell == 0 || selectedCell == 1) && actualPosition.x > 0) {
                    selectedCell = collectionView.indexPath(for: cells!)?.item
                    cells!.label.textColor = selectedCellTextColor
                    
                }
            }
        }
    }

    func isScrollViewScroll(scrollView: UIScrollView) {
        let collectionOrigin = collectionView!.bounds.origin
        let collectionWidth = collectionView!.bounds.width
        var centerPoint: CGPoint!
        var newX: CGFloat!
        if collectionOrigin.x > 0 {
            newX = collectionOrigin.x + collectionWidth / 2
            centerPoint = CGPoint(x: newX, y: collectionOrigin.y)
        } else {
            newX = collectionOrigin.x + collectionWidth / 2
            centerPoint = CGPoint(x: newX, y: collectionOrigin.y)
        }
        
        let index = collectionView!.indexPathForItem(at: centerPoint)
        
        if(index != nil) {
            if (self.isScrollEnable != nil) {
                self.isScrollEnable!((index?.row)!, self.stringArray[(index!.row)])
            }
        }
    }
}

extension InstaSlider: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stringArray.count
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let kCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? CollectionViewCustomCell else {
            fatalError("Unable to find cell with '\(cellId)' reuseIdentifier")
        }
        
        kCell.label.text = self.stringArray[indexPath.item].name
        kCell.tag = indexPath.row
        kCell.layer.shouldRasterize = true
        kCell.layer.rasterizationScale = UIScreen.main.scale
        //kCell.backgroundColor = .red
        
        if self.stringArray[indexPath.item].recordingType != CameraMode.basicCamera{
            if Defaults.shared.appMode == .free{
                kCell.imageView.isHidden = false
                kCell.imageView.image = R.image.ic_lock()
            }else{
                kCell.imageView.isHidden = true
            }
        }
        
        
        
        if(self.selectedCell != nil) {
            if(indexPath.item == self.selectedCell) {
                kCell.label.textColor = selectedCellTextColor
            } else {
                kCell.label.textColor = cellTextColor
            }
        }
        
        return kCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 110, height: self.collectionView.frame.height/2)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isScrollViewScroll(scrollView: scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.findCenterIndex(scrollView: scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.findCenterIndex(scrollView: scrollView)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let rect = collectionView.layoutAttributesForItem(at: indexPath)?.frame
        collectionView.scrollRectToVisible(rect!, animated: true)
    }
}

class CollectionViewCustomCell: UICollectionViewCell {
    
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let imageView: UIImageView = {
        let imegeView = UIImageView()
        imegeView.backgroundColor = .clear
        imegeView.translatesAutoresizingMaskIntoConstraints = false
        return imegeView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
    }
    
    func addViews() {
        backgroundColor = UIColor.clear
        addSubview(label)
        
        
     // label.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
      //label.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        
        if isBoomiCamApp{
            addSubview(imageView)
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
            imageView.leftAnchor.constraint(equalTo: label.rightAnchor, constant: 2).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addViews()
    }
}
