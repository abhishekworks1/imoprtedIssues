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
    case emailAddress
    case channelDisplayName
}

protocol DisplayTooltiPDelegate: class {
    func displayTooltip(index: Int, cell: DisplayNameTableViewCell)
    func displayTextAlert(string:String, cell: DisplayNameTableViewCell)
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
                self.lblDisplayNameType.text = R.string.localizable.displayName()
                self.txtDisplaName.placeholder = R.string.localizable.displayName()
                self.txtDisplaName.text = Defaults.shared.publicDisplayName
            } else if displayNameType == .privateDisplayName {
                self.lblDisplayNameType.text = R.string.localizable.privateDisplayName()
                self.txtDisplaName.placeholder = R.string.localizable.privateDisplayName()
                self.txtDisplaName.text = Defaults.shared.privateDisplayName
            } else if displayNameType == .emailAddress {
                self.lblDisplayNameType.text = R.string.localizable.emailAddress()
                self.txtDisplaName.placeholder = R.string.localizable.emailAddress()
                self.txtDisplaName.text = Defaults.shared.emailAddress
            } else if displayNameType == .channelDisplayName {
                self.lblDisplayNameType.text = "Channel Name Display"
                self.txtDisplaName.placeholder = "Enter Channel Name Display"
                self.txtDisplaName.text = "@\(Defaults.shared.channelName ?? "")"
            }
            
        }
    }
    
    // MARK: - Life cycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        self.txtDisplaName.delegate = self
    }
    
    @IBAction func btnTooltipTapped(_ sender: UIButton) {
        displayTooltipDelegate?.displayTooltip(index: sender.tag, cell: self)
    }
}
extension DisplayNameTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if displayNameType == .emailAddress{
            guard let email = textField.text else {
                    return
            }
            if email.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
                displayTooltipDelegate?.displayTextAlert(string:R.string.localizable.pleaseEnterEmail(), cell: self)
            } else if !email.isValidEmail() {
                displayTooltipDelegate?.displayTextAlert(string:R.string.localizable.pleaseEnterValidEmail(), cell: self)
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if displayNameType == .channelDisplayName {
            if let text = textField.text,
                       let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange,
                                                                   with: string)
                
                
                Defaults.shared.channelName = String(updatedText.dropFirst())
                       
            }
        }
        
        
        return true
    }
}
