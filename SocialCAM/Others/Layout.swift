//
//  Layout.swift
//  NexTo
//
//  Created by Jasmin Patel on 17/10/16.
//  Copyright © 2016 Jasmin Patel. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class LayoutConstraint: NSLayoutConstraint {
    @IBInspectable
    var isResize: Bool = false {
        didSet {
            if UIDevice.current.userInterfaceIdiom != .pad {
                if self.isResize {
                    switch firstAttribute {
                    case .top, .bottom, .height:
                        self.constant *= UIScreen.main.bounds.size.height/667
                    case .leading, .trailing, .width:
                        self.constant *= UIScreen.main.bounds.size.width/375
                    default:
                        break
                    }
                }
            }
        }
    }
}
