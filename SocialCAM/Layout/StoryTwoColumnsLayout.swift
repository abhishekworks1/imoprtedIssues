//
//  StoryTwoColumnsLayout.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 06/09/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

class StoryTwoColumnsLayout: UICollectionViewLayout {
    fileprivate var cache = [IndexPath: UICollectionViewLayoutAttributes]()
    fileprivate var cellPadding: CGFloat = 4
    fileprivate var contentHeight: CGFloat = 0
    var oldBound: CGRect!
    let numberOfColumns: Int = 2
    var cellHeight: CGFloat = 255
    
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        super.prepare()
        contentHeight = 0
        cache.removeAll(keepingCapacity: true)
        guard cache.isEmpty == true, let collectionView = collectionView else {
            return
        }
        if collectionView.numberOfSections == 0 {
            return
        }
       
        let cellWidth = contentWidth / CGFloat(numberOfColumns)
        cellHeight = cellWidth / 720 * 1220
        var xOffset = [CGFloat]()
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * cellWidth)
        }
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            var newheight = cellHeight
            if column == 0 {
             newheight = ((yOffset[column + 1] - yOffset[column]) > cellHeight * 0.3) ? cellHeight : (cellHeight * 0.90)
            }
            
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: cellWidth, height: newheight)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache[indexPath] = (attributes)
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + newheight
            if column >= (numberOfColumns - 1) {
                column = 0
            } else {
                column = column + 1
            }

        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        // Loop through the cache and look for items in the rect
        visibleLayoutAttributes = cache.values.filter({ (attributes) -> Bool in
            return attributes.frame.intersects(rect)
        })
        print(visibleLayoutAttributes)
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath]
    }
    
}
