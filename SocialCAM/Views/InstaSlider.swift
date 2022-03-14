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
    
   // open var cellTextColor: UIColor = UIColor(red:130.0, green: 130.0, blue: 230.0, alpha: 1)
    open var cellTextColor: UIColor = UIColor.yellow
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
        self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.ratioWidth, height: 50))
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
        collectionViewLayout = HorizontalFlowLayout.configureLayout(collectionView: self.collectionView, itemSize: CGSize.init(width: 90, height: self.collectionView.frame.height/2), minimumLineSpacing: 0)
        
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
                currentCell.label.makeLabelOpaque()
               // currentCell.label.textColor = cellTextColor
                currentCell.label.textColor = UIColor(hex:"ebebeb")
                currentCell.label.font = UIFont.systemFont(ofSize: 15)
            }
            
            let cell = collectionView.cellForItem(at: index!) as? CollectionViewCustomCell
            if(cell != nil) {
                selectedCell = collectionView.indexPath(for: cell!)?.item
                cell!.label.textColor = selectedCellTextColor
                cell!.label.font = UIFont.systemFont(ofSize: 17)
                //print("**SelectedC1 \(cell!.label.text)")
                Defaults.shared.callHapticFeedback(isHeavy: false)
                if (self.currentCell != nil) {
                    self.currentCell!((index?.row)!, self.stringArray[(index!.row)])
                }
            }
        } else if(cells != nil) {
            let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
            for cellView in self.collectionView.visibleCells {
                let currentCell = cellView as? CollectionViewCustomCell
                currentCell!.label.makeLabelOpaque()
              //  currentCell!.label.textColor = cellTextColor
                currentCell!.label.textColor = UIColor(hex:"ebebeb")
                currentCell!.label.font = UIFont.systemFont(ofSize: 15)
                if(currentCell == cells! && (selectedCell == 0 || selectedCell == 1) && actualPosition.x > 0) {
                    selectedCell = collectionView.indexPath(for: cells!)?.item
                    cells!.label.textColor = selectedCellTextColor
                    cells!.label.font = UIFont.systemFont(ofSize: 17)
                    //print("**SelectedC2 \(cells!.label.text)")
                }
            }
        }
    }
    func findCenterIndexWhileScrolling(scrollView: UIScrollView) {
        // for linear collectionview
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)

        let index = collectionView!.indexPathForItem(at: visiblePoint)
        
        if(index != nil) {
            for cell in self.collectionView.visibleCells {
                guard let currentCell = cell as? CollectionViewCustomCell else {
                    return
                }
                currentCell.label.makeLabelOpaque()
               // currentCell.label.textColor = cellTextColor
                currentCell.label.textColor = UIColor(hex:"ebebeb")
                currentCell.label.font = UIFont.systemFont(ofSize: 15)
            }
            
            let cell = collectionView.cellForItem(at: index!) as? CollectionViewCustomCell
            if(cell != nil) {
                cell!.label.textColor = selectedCellTextColor
                cell!.label.font = UIFont.systemFont(ofSize: 17)
                //print("**SelectedC1 \(cell!.label.text)")
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
        if(self.selectedCell != nil) {
            if(indexPath.item == self.selectedCell) {
                kCell.label.textColor = selectedCellTextColor
                kCell.label.font = UIFont.systemFont(ofSize: 17)
            } else {
                kCell.label.makeLabelOpaque()
               // kCell.label.textColor = cellTextColor
                kCell.label.textColor = UIColor(hex:"ebebeb")
                kCell.label.font = UIFont.systemFont(ofSize: 15)
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
    
    // while scrolling this delegate is being called so you may now check which direction your scrollView is being scrolled to
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.findCenterIndexWhileScrolling(scrollView: scrollView)
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
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
    }
    
    func addViews() {
        backgroundColor = UIColor.clear
        addSubview(label)
        
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        label.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addViews()
    }
}
extension UILabel{
    func makeLabelOpaque(){
        self.textColor = .white
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 0.5
        self.backgroundColor = .clear
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: -0.5)
        self.textAlignment = .center
        self.numberOfLines = 1
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
