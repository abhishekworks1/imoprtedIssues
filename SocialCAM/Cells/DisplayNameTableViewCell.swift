//
//  DisplayNameTableViewCell.swift
//  SocialCAM
//
//  Created by Nilisha Gupta on 06/10/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit

enum DisplayNameType: Int {
    case publicDisplayName = 0
    case privateDisplayName
}

protocol DisplayTooltiPDelegate: class {
    func displayTooltip(index: Int)
}

class DisplayNameTableViewCell: UITableViewCell {
    
    // MARK: - Outlets declaration
    @IBOutlet weak var lblDisplayNameType: UILabel!
    @IBOutlet weak var txtDisplaName: UITextField!
    @IBOutlet weak var btnDisplayNameTooltipIcon: UIButton!
    weak var displayTooltipDelegate: DisplayTooltiPDelegate?
    
    // MARK: - Variables declaration
    var displayNameType: DisplayNameType = .publicDisplayName {
        didSet {
            if displayNameType == .publicDisplayName {
                self.lblDisplayNameType.text = R.string.localizable.publicDisplayName()
                self.txtDisplaName.placeholder = R.string.localizable.publicDisplayName()
                self.txtDisplaName.text = Defaults.shared.publicDisplayName
            } else if displayNameType == .privateDisplayName {
                self.lblDisplayNameType.text = R.string.localizable.privateDisplayName()
                self.txtDisplaName.placeholder = R.string.localizable.privateDisplayName()
                self.txtDisplaName.text = Defaults.shared.privateDisplayName
            }
        }
    }
    
    // MARK: - Life cycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func btnTooltipTapped(_ sender: UIButton) {
        displayTooltipDelegate?.displayTooltip(index: sender.tag)
    }
}
