//
//  SettingScreenTableViewCell.swift
//  SocialCAM
//
//  Created by Siddharth on 22/04/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class SettingScreenTableViewCell: UITableViewCell {
    @IBOutlet weak var imageIconView: UIImageView!
    @IBOutlet weak var titleNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
