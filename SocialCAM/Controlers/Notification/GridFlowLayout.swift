//
//  GridFlowLayout.swift
//  SocialCAM
//
//  Created by Viraj Patel on 08/10/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation

class GridFlowLayout: UICollectionViewFlowLayout {
    let itemHeight: CGFloat = (UIScreen.main.bounds.size.height * 300)
    let itemWidth: CGFloat = (UIScreen.main.bounds.size.width)
    
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    /*
     Sets up the layout for the collectionView. 1pt distance between each cell and 1pt distance between each row plus use a vertical layout
     */
    
    func setupLayout() {
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = .horizontal
        self.invalidateLayout()
    }
    
    /// here we define the width of each cell, creating a 2 column layout. In case you would create 3 columns, change the number 2 to 3
 
    
    override var itemSize: CGSize {
        set {
            self.itemSize = CGSize(width: itemWidth, height: 440)
        }
        get {
            return CGSize(width: itemWidth, height: 440)
        }
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return collectionView!.contentOffset
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}

extension UICollectionView {
    var visibleCurrentCellIndexPath: IndexPath? {
        for cell in self.visibleCells {
            let indexPath = self.indexPath(for: cell)
            return indexPath
        }
        
        return nil
    }
}
