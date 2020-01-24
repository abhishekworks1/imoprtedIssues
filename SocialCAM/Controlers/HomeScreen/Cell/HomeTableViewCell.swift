//
//  HomeTableViewCell.swift
//  SocialCAM
//
//  Created by Viraj Patel on 23/01/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet var lblTitle: UILabel?
    @IBOutlet var btnNext: UIButton?

    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func btnNextClicked(sender: Any?) {

    }

}
