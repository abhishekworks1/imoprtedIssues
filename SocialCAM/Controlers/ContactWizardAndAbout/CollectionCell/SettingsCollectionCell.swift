//
//  SettingsCollectionCell.swift
//  SocialCAM
//
//  Created by ideveloper5 on 25/04/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class SettingsCollectionCell: UICollectionViewCell {
     @IBOutlet weak var settingsName: UILabel!
    @IBOutlet weak var socialImageView: UIImageView?
    @IBOutlet weak var countLabel: ColorBGLabel!
    @IBOutlet weak var roundedView: RoundedView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}