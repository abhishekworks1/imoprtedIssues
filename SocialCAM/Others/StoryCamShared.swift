//
//  StoryCamShared.swift
//  ProManager
//
//  Created by Viraj Patel on 23/10/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit
import TGPControls

extension TGPDiscreteSlider {
    var speedType: VideoSpeedType {
        set { }
        get {
            switch value {
            case 0:
                return .slow(scaleFactor: 3.0)
            case 1:
                return .slow(scaleFactor: 2.0)
            case 2:
                return .normal
            case 3:
                return .fast(scaleFactor: 2.0)
            case 4:
                return .fast(scaleFactor: 3.0)
            case 5:
                return .fast(scaleFactor: 4.0)
            default:
                return .normal
            }
        }
    }
}
