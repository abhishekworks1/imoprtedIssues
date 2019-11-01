//
//  MensionCollectionViewDelegate.swift
//  ProManager
//
//  Created by Jasmin Patel on 27/11/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit

class MensionCollectionViewDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    weak var mensionDelegate: MensionDelegate?
    /**
     Array of mensions that will show while typing
     */
    var mensions: [Channel] = []
    
    override init() {
        super.init()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mensions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        mensionDelegate?.didSelectUser(user: mensions[indexPath.row])
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MensionCollectionViewCell", for: indexPath) as? MensionCollectionViewCell else {
            fatalError("Unable to find cell with 'MensionCollectionViewCell' reuseIdentifier")
        }
        cell.userChannelName.text = mensions[indexPath.row].channelId
        cell.userImageView.setImageFromURL( mensions[indexPath.row].profileImageURL, placeholderImage: ApplicationSettings.userPlaceHolder, indicatorStyle: UIActivityIndicatorView.Style.gray)
        return cell
    }
    
}
