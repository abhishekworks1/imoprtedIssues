//
//  BaseLineView.swift
//  CollageView
//
//  Created by Viraj Patel on 11/03/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

enum BaseLineViewMoveType: Int {
    case leftRight
    case upDown
}

class BaseLineView: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    var id: Int = 0
    var moveType: BaseLineViewMoveType = .leftRight
    var baseLC: NSLayoutConstraint?
    
}
