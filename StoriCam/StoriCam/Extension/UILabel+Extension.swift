//
//  UILabel+Extension.swift
//  ProManager
//
//  Created by Viraj Patel on 17/09/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    func applyGradientWith(startColor: UIColor, middleColor: UIColor? = nil, endColor: UIColor) {
        guard let gradientColor = self.text?.getGradientColorFor(startColor: startColor, middleColor: middleColor, endColor: endColor, font: self.font ?? UIFont.systemFont(ofSize: 25)) else {
            return
        }
        self.textColor = gradientColor
    }
    
    func getImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
