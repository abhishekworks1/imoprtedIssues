//
//  OnboardingTableViewCell.swift
//  SocialCAM
//
//  Created by Sanjaysinh Chauhan on 10/06/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class OnboardingTableViewCell: UITableViewCell {

    @IBOutlet weak var imgRadioSelection: UIImageView!
    
    @IBOutlet weak var lblOnboardingText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
