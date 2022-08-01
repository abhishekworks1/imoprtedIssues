//
//  PackageSuggesstionTableViewCell.swift
//  ProManager
//
//  Created by Steffi Pravasi on 26/07/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit

class PackageSuggesstionTableViewCell: UITableViewCell {

    @IBOutlet var channelNameLbl: UILabel!
    @IBOutlet var addToCartBtn: UIButton!
    var buttonAction: ((UIButton) -> Void)?
    
    @IBAction func addToCartBtnClicked(_ sender: UIButton) {
        self.buttonAction?(sender)
        
    }
    
}
