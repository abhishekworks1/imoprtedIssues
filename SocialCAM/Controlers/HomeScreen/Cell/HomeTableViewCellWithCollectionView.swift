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
        return StoryGames.storyGames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return StoryGames.storyGames[section].games.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: GameGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.gameGridCell.identifier, for: indexPath) as? GameGridCell else {
            fatalError("GameGridCell Not Found")
        }
        cell.game = StoryGames.storyGames[indexPath.section].games[indexPath.item]
        return cell
    }
}
