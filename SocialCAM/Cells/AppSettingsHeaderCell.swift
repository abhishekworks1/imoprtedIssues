//
//  AppSettingsHeaderCell.swift
//  SocialCAM
//
//  Created by Sanjaysinh Chauhan on 18/08/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class AppSettingsHeaderCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnExpandCollaps: UIButton!
    var section: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapHeader)))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell() {
        
    }
    
    @objc private func didTapHeader() {
//        delegate?.toggleSection(header: self, section: section)
    }
}
