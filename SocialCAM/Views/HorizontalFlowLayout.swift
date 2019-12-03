//
//  HorizontalFlowLayout.swift
//  InstaSlider
//
//  Created by Viraj Patel on 18/06/18.
//

import Foundation
import UIKit

class CircularCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {

  var anchorPoint = CGPoint(x: 0.3, y: 0.5)

  var angle: CGFloat = 0 {
      didSet {
        zIndex = Int(angle*1000000)
        transform = CGAffineTransform(rotationAngle: angle)
      }
  }
  
  override func copy(with zone: NSZone? = nil) -> Any {
    guard let copiedAttributes: CircularCollectionViewLayoutAttributes = super.copy(with: zone) as? CircularCollectionViewLayoutAttributes else {
        return super.copy(with: zone)
    }
    copiedAttributes.anchorPoint = self.anchorPoint
    copiedAttributes.angle = self.angle
    return copiedAttributes
  }
}

class HorizontalFlowLayout: UICollectionViewFlowLayout {
    
    private var lastCollectionViewSize: CGSize = CGSize.zero
    var scalingOffset: CGFloat = 155
  var minimumScaleFactor: CGFloat = 0.85
    var scaleItems: Bool = true
    var needsZoom = true
    var needsDial = true
    var currentIndex: Int?
    var angleAtExtreme: CGFloat {
      return collectionView!.numberOfItems(inSection: 0) > 0 ? -CGFloat(collectionView!.numberOfItems(inSection: 0)-1)*anglePerItem : 0
    }

    var angle: CGFloat {
        return angleAtExtreme*collectionView!.contentOffset.x/(collectionViewContentSize.width - collectionView!.bounds.width)
    }

  override func prepare() {
    super.prepare()
    let centerX = collectionView!.contentOffset.x + (collectionView!.frame.width/2.0)
    let anchorPointY = ((itemSize.height/2.0) + radius)/itemSize.height

    let theta = atan2(collectionView!.frame.width/2.0, radius + (itemSize.height/2.0) - (collectionView!.frame.height/2.0)) //1

    var startIndex = 0
    var endIndex = collectionView!.numberOfItems(inSection: 0) - 1

    if (angle < -theta) {
        startIndex = Int(floor((-theta - angle)/anglePerItem))
    }

    endIndex = min(endIndex, Int(ceil((theta - angle)/anglePerItem)))

    if (endIndex < startIndex) {
        endIndex = 0
        startIndex = 0
    }
    attributesList = (startIndex...endIndex).map { (index) -> CircularCollectionViewLayoutAttributes in
      let attributes = CircularCollectionViewLayoutAttributes(forCellWith: NSIndexPath(item: index, section: 0) as IndexPath)
        attributes.size = self.itemSize
        attributes.center = CGPoint(x: centerX, y: self.collectionView!.frame.midY)
        attributes.angle = self.angle + (self.anglePerItem*CGFloat(index))
        attributes.anchorPoint = CGPoint(x: 0.5, y: anchorPointY)
        return attributes
    }
  }
  
  var attributesList = [CircularCollectionViewLayoutAttributes]()
  
    var radius: CGFloat = 320 {
        didSet {
            invalidateLayout()
        }
    }

    var anglePerItem: CGFloat {
      return 0.35
    }
  
    static func configureLayout(collectionView: UICollectionView, itemSize: CGSize, minimumLineSpacing: CGFloat) -> HorizontalFlowLayout {
        
        let layout = HorizontalFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = minimumLineSpacing
        layout.itemSize = itemSize
        
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionView.collectionViewLayout = layout
        
        return layout
    }
    
    override  func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        
        if self.collectionView == nil {
            return
        }
        
        let currentCollectionViewSize = self.collectionView!.bounds.size
        
        if !currentCollectionViewSize.equalTo(self.lastCollectionViewSize) {
            self.configureInset()
            self.lastCollectionViewSize = currentCollectionViewSize
        }
    }
    
    private func configureInset() {
        if self.collectionView == nil {
            return
        }
        
        let inset = self.collectionView!.bounds.size.width / 2 - self.itemSize.width / 2
      self.collectionView!.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        self.collectionView!.contentOffset = CGPoint.init(x: -inset, y: 0)
        
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        if self.collectionView == nil {
            return proposedContentOffset
        }
        
        let collectionViewSize = self.collectionView!.bounds.size
        let proposedRect = CGRect.init(x: proposedContentOffset.x, y: 0, width: collectionViewSize.width, height: collectionViewSize.height)
        
        let layoutAttributes = self.layoutAttributesForElements(in: proposedRect)
        
        if layoutAttributes == nil {
            return proposedContentOffset
        }
        
        var candidateAttributes: UICollectionViewLayoutAttributes?
        let proposedContentOffsetCenterX = proposedContentOffset.x + collectionViewSize.width / 2
        
        for attributes: UICollectionViewLayoutAttributes in layoutAttributes! {
            if attributes.representedElementCategory != .cell {
                continue
            }
            
            if candidateAttributes == nil {
                candidateAttributes = attributes
                continue
            }
            
          if abs(attributes.center.x - proposedContentOffsetCenterX) < abs(candidateAttributes!.center.x - proposedContentOffsetCenterX) {
                candidateAttributes = attributes
            }
        }
        
        if candidateAttributes == nil {
            return proposedContentOffset
        }
        
        var newOffsetX = candidateAttributes!.center.x - self.collectionView!.bounds.size.width / 2
        
        let offset = newOffsetX - self.collectionView!.contentOffset.x
        
        if (velocity.x < 0 && offset > 0) || (velocity.x > 0 && offset < 0) {
            let pageWidth = self.itemSize.width + self.minimumLineSpacing
            newOffsetX += velocity.x > 0 ? pageWidth : -pageWidth
        }
        
        return CGPoint.init(x: newOffsetX, y: proposedContentOffset.y)
    }
  
    override class var layoutAttributesClass: AnyClass {
        return CircularCollectionViewLayoutAttributes.self
    }
  
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
  
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
      
      if !self.scaleItems || self.collectionView == nil {
            return super.layoutAttributesForElements(in: rect)
        }
        
        let superAttributes = super.layoutAttributesForElements(in: rect)
        
        if superAttributes == nil {
            return nil
        }
        
        let contentOffset = self.collectionView!.contentOffset
        let size = self.collectionView!.bounds.size
        
        let visibleRect = CGRect.init(x: contentOffset.x, y: contentOffset.y, width: size.width, height: size.height)
        let visibleCenterX = visibleRect.midX
        
        var newAttributesArray = [CircularCollectionViewLayoutAttributes]()
      
        for (_, attributes) in superAttributes!.enumerated() {
            guard let newAttributes = attributes.copy() as? CircularCollectionViewLayoutAttributes else {
                return nil
            }
            newAttributesArray.append(newAttributes)
            let distanceFromCenter = visibleCenterX - newAttributes.center.x
            let absDistanceFromCenter = min(abs(distanceFromCenter), self.scalingOffset)
            let scale = absDistanceFromCenter * (self.minimumScaleFactor - 1) / self.scalingOffset + 1
            if(needsDial) {
                if(scale < 1) {
                    var mFrame = newAttributes.frame
                    mFrame.origin.y = (scale * 0.3) * abs(distanceFromCenter)
                    newAttributes.frame = mFrame
                    newAttributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
                    
                } else {
                    var mFrame = newAttributes.frame
                    mFrame.origin.y = scale * abs(distanceFromCenter)
                    newAttributes.frame = mFrame
                    newAttributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
                }
            } else {
                newAttributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
            }
        }
        
        return newAttributesArray
    }
}
