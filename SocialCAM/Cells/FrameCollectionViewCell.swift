//
//  FrameCollectionViewCell.swift
//  ProManager
//
//  Created by Viraj Patel on 13/03/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

class FrameCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var frameImageView: UIImageView!
     
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
