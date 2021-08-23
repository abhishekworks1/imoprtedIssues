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
    
    // MARK: - Outlets Declaration
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    
    // MARK: - variable Declaration
    weak var delegate: ChangeDataDelegate?
    weak var dismissViewDelegate: DismissViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Action Methods
    @IBAction func btnYesPressed(_ sender: UIButton) {
        btnYes.isSelected = true
        btnNo.isSelected = false
        delegate?.changeTableData()
    }
    
    @IBAction func btnNoPressed(_ sender: UIButton) {
        btnNo.isSelected = true
        btnYes.isSelected = false
        dismissViewDelegate?.dismissView()
    }
}
