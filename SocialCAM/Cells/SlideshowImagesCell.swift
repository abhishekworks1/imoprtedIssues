//
//  SlideshowImagesCell.swift
//  ProManager
//
//  Created by Viraj Patel on 21/08/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

class SlideshowImagesCell: UICollectionViewCell {
    
    @IBOutlet weak var imagesView: UIView!
    @IBOutlet weak var custImage: UIImageView!
    @IBOutlet weak var borderImage: UIImageView!
    @IBOutlet var btnImageClose: UIButton!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    
}
