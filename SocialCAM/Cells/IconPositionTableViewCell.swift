//
//  StorySettingsCell.swift
//  ProManager
//
//  Created by Jasmin Patel on 21/06/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit

class IconPositionTableViewCell: UITableViewCell {

    @IBOutlet weak var imgIconPosition: UIImageView!
    @IBOutlet weak var imgInverseIconPosition: UIImageView!
    @IBOutlet weak var btnIconPosition: UIButton!
    @IBOutlet weak var btnInverseIconPosition: UIButton!
    @IBOutlet weak var imgSettingIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setSelection(isInverseSelected: Defaults.shared.swapeContols)
    }
    
    func setSelection(isInverseSelected: Bool) {
        self.imgIconPosition.image = !isInverseSelected ? R.image.radioSelected() : R.image.radioDeselected()
        self.imgInverseIconPosition.image = isInverseSelected ? R.image.radioSelected() : R.image.radioDeselected()
    }

    @IBAction func btnDefaultIconPositionTapped(_ sender: Any) {
        Defaults.shared.swapeContols = false
        self.setSelection(isInverseSelected: Defaults.shared.swapeContols)
    }
    
    @IBAction func btnInverseIconPositionTapped(_ sender: Any) {
        Defaults.shared.swapeContols = true
        self.setSelection(isInverseSelected: Defaults.shared.swapeContols)
    }
    
}
