//
//  CartTableViewCell.swift
//  ProManager
//
//  Created by Steffi Pravasi on 25/07/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit

class CartTableViewCell: UITableViewCell {

    @IBOutlet var channelPurchasedIndication: UIView!
    @IBOutlet var channelNameLbl: UILabel!
    
    @IBOutlet var deleteBtn: UIButton!
    var buttonAction: ((UIButton) -> Void)?
    
    @IBAction func deleteBtnClicked(_ sender: UIButton) {
        self.buttonAction?(sender)
        
    }
    
}
