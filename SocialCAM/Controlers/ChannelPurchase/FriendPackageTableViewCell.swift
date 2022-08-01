//
//  FriendPackageTableViewCell.swift
//  ProManager
//
//  Created by Steffi Pravasi on 18/09/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit

class FriendPackageTableViewCell: UITableViewCell {

    @IBOutlet var selectedView: UIView!
    @IBOutlet var packageNameLbl: UILabel!
    @IBOutlet var numOfChannelsLbl: UILabel!
    @IBOutlet var packageChargeLbl: UILabel!
    var buttonAction: ((Any) -> Void)?
    
    @IBAction func btnClicked(_ sender: Any) {
        self.buttonAction?(sender)
        
    }
    func setData(name: String, amount: Int, numberChannels: Int) {
        packageNameLbl.text = name
        packageChargeLbl.text = "$\(amount).00"
        numOfChannelsLbl.text = String(numberChannels)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
