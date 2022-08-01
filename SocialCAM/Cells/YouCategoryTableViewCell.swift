//
//  YouCategoryTableViewCell.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 13/03/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import UIKit

class YouCategoryTableViewCell: UITableViewCell {
    
    @IBOutlet var lblTitle: UILabel?
    
    var category: YouCategory? {
        didSet {
            if let title = category?.snippet?.title {
                lblTitle?.text = title
            }
            
        }
    }
}
