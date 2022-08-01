//
//  HeaderViewTableViewCell.swift
//  ProManager
//
//  Created by Steffi Pravasi on 30/07/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit

class HeaderViewTableViewCell: UITableViewCell {

    @IBOutlet var channelNameLbl: UILabel!
    
    @IBOutlet var editPackageBtn: UIButton!
    @IBOutlet var costOfChannelLbl: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    var buttonAction: ((Any) -> Void)?
    
    @IBAction func editBtnClicked(_ sender: Any) {
        self.buttonAction?(sender)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  
    func setCollectionViewDataSourceDelegate <D: UICollectionViewDataSource & UICollectionViewDelegate>
        (dataSourceDelegate: D, forRow row: Int) {
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
        self.collectionView.reloadData()
        collectionView.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
