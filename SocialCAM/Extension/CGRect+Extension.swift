//
//  CGRect+Extension.swift
//  ProManager
//
//  Created by Viraj Patel on 16/09/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

extension CGRect {
    
    func multiply(with contentScale: CGFloat) -> CGRect {
        return CGRect(x: origin.x*contentScale,
                      y: origin.y*contentScale,
                      width: size.width*contentScale,
                      height: size.height*contentScale)
    }
    
}

extension Int {
    
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value: self))!
    }
    
}

extension Array {
    
    mutating func g_moveToFirst(_ index: Int) {
        guard index != 0 && index < count else { return }
        
        let item = self[index]
        remove(at: index)
        insert(item, at: 0)
    }
}

extension CGFloat {
    
    func scaleValueFrom(_ value: CGFloat) -> CGFloat {
        return self*value/100
    }
    
    var ratio: CGFloat {
        return 100*self
    }
    var actualHorizontal: CGFloat {
        var x = UIScreen.width*self / 100
        if !UIScreen.haveRatio {
            x = UIScreen.ratioWidth*self / 100
            x -= ((UIScreen.ratioWidth - UIScreen.width) / 2)
        }
        return x
    }
    var actualVertical: CGFloat {
        return UIScreen.height*self / 100
    }
    
}

extension CGAffineTransform {
    var rotationValue: CGFloat {
        return atan2(b, a)
    }
}
