//
//  TipOfTheDaySettingCell.swift
//  SocialCAM
//
//  Created by Sanjaysinh Chauhan on 08/09/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

enum TipOfTheDay: Int {
    case beginner = 0
    case intermediate
    case advanced
    
    var description: String {
        switch self {
        case .beginner:
            return "Beginner"
        case .intermediate:
            return "Intermediate"
        case .advanced:
            return "Advanced"
        }
    }
}

class TipOfTheDaySettingCell: UITableViewCell {

    @IBOutlet weak var btnSelectedToD: UIButton!
    @IBOutlet weak var lblTipOftheDaylevel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        btnSelectedToD.setImage(R.image.settings_radio_selected(), for: .selected)
        btnSelectedToD.setImage(R.image.settings_radio_deselected(), for: .normal)
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(storySetting: StorySetting) {
        self.lblTipOftheDaylevel.text = storySetting.name
        
                
        let tipOfthDayType = TipOfTheDay(rawValue: Defaults.shared.selectedTipOfTheLevel)
        
        if tipOfthDayType?.description == storySetting.name {
            self.btnSelectedToD.isSelected = true
        } else {
            self.btnSelectedToD.isSelected = false
        }
    }
    
}
