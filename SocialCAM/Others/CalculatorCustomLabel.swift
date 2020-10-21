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
        self.layer.borderColor = R.color.calculatorButtonColor()?.cgColor
        self.layer.backgroundColor = R.color.calculatorButtonColor()?.withAlphaComponent(0.1).cgColor
        self.layer.cornerRadius = 5
    }
    
}
