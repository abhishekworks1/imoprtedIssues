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
    weak var delegate: HeaderViewDelegate?
    
    var collapsed: Bool = false {
        didSet {
            btnExpandCollaps?.rotate(collapsed ? 0.0 : .pi)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btnExpandCollaps.isUserInteractionEnabled = false
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapHeader)))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell() {
        
    }
    
    @objc private func didTapHeader() {
        delegate?.toggleSection(header: self, section: section)
    }
}
