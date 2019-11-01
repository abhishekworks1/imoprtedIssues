//
//  TransparentGradientView.swift
//  ProManager
//
//  Created by Viraj Patel on 23/10/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit
import Gemini
import CoreMedia
import AVFoundation

class TransparentGradientView: UIView {
    
    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }

    open var color: UIColor = ApplicationSettings.appBlackColor.withAlphaComponent(0.75) {
        didSet {
            let gradientLayer = self.layer as? CAGradientLayer
            gradientLayer?.colors = [
                color.cgColor,
                ApplicationSettings.appClearColor.cgColor
            ]
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let gradientLayer = self.layer as? CAGradientLayer
        gradientLayer?.colors = [
            ApplicationSettings.appBlackColor.withAlphaComponent(0.75).cgColor,
            ApplicationSettings.appClearColor.cgColor
        ]
    }
}
