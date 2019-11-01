//
//  PickerViewCell.swift
//  CollageView
//
//  Created by Viraj Patel on 11/03/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

class PickerViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var borderLayer: UIView!
    @IBOutlet weak var selectView: UIView!
    @IBOutlet weak var numLbl: UILabel!
    
    var isCellSelected : Bool = false {
        didSet {
            self.selectView.isHidden = !self.isCellSelected
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func initialize() {
        borderLayer.backgroundColor = ApplicationSettings.appClearColor
        borderLayer.layer.borderColor = UIColor.gray.cgColor
        borderLayer.layer.borderWidth = 3.0
    }
}
