//
//  QuickStartGuideTableViewCell.swift
//  SocialCAM
//
//  Created by Jasmin Patel on 02/09/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class QuickStartGuideTableViewCell: UITableViewCell {

    @IBOutlet weak var optionsStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var goToButton: UIButton!
    @IBOutlet weak var stepper: StepIndicatorView!
    @IBOutlet weak var backgroundImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    

    
}
