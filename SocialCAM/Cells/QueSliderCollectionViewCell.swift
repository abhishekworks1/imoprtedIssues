//
//  QueSliderCollectionViewCell.swift
//  ProManager
//
//  Created by Jasmin Patel on 24/12/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit

class QueSliderCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lblEmoji: UILabel!
     
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lblEmoji.layer.cornerRadius = lblEmoji.bounds.width/2
        lblEmoji.layer.borderWidth = 1.0
    }
    
}
