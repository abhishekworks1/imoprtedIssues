//
//  ActivateAffiliateLinkCell.swift
//  SocialCAM
//
//  Created by Meet Mistry on 16/08/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit

protocol ChangeDataDelegate: class {
    func changeTableData()
}

protocol DismissViewDelegate: class {
    func dismissView()
}

class ActivateAffiliateLinkCell: UITableViewCell {

    @IBOutlet weak var btnRadioYes: UIImageView!
    @IBOutlet weak var btnRadioNo: UIImageView!
    
    weak var delegate: ChangeDataDelegate?
    weak var dismissViewDelegate: DismissViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    @IBAction func btnYesPressed(_ sender: UIButton) {
        btnRadioYes.image = R.image.radioSelected()
        btnRadioNo.image = R.image.oval()
        Defaults.shared.isAffiliateLinkActivated = true
        delegate?.changeTableData()
    }
    
    @IBAction func btnNoPressed(_ sender: UIButton) {
        btnRadioYes.image = R.image.oval()
        btnRadioNo.image = R.image.radioSelected()
        dismissViewDelegate?.dismissView()
    }
}
