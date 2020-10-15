//
//  CalculatorCustomLabel.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 15/10/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit

class CalculatorCustomLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textAlignment = .center
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.blue.cgColor
        self.layer.backgroundColor = UIColor.blue.withAlphaComponent(0.2).cgColor
        self.layer.cornerRadius = 5
    }
    
}
