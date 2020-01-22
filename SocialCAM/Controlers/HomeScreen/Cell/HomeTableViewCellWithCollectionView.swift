//
//  HomeTableViewCellWithCollectionView.swift
//  SocialCAM
//
//  Created by Viraj Patel on 23/01/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation

class HomeTableViewCellWithCollectionView: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
   
    @IBOutlet var collectionView: UICollectionView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(R.nib.gameGridCell(), forCellWithReuseIdentifier: R.reuseIdentifier.gameGridCell.identifier)
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.gameGridCell.identifier, for: indexPath) as? GameGridCell else {
            fatalError("GameGridCell Not Found")
        }
        
        if indexPath.row%2 == 0 {
            cell.backgroundColor = UIColor.red
        } else {
            cell.backgroundColor = UIColor.yellow
        }
        return cell
    }
    
    
    
}
