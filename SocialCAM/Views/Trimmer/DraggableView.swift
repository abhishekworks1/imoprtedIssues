//
//  DraggableView.swift
//  TrimmerVideo
//
//  Created by Diego Caroli on 24/09/2018.
//  Copyright © 2018 Diego Caroli. All rights reserved.
//

import UIKit

class DraggableView: UIView {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let frame = self.bounds.insetBy(dx: -20, dy: -20)
        return frame.contains(point) ? self : nil
    }
    
}
