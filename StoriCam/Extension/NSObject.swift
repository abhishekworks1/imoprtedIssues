//
//  NSObject.swift
//  ProManager
//
//  Created by Viraj Patel on 24/09/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

extension NSObject {
    
    @nonobjc public static var className: String {
        return NSStringFromClass(self).components(separatedBy: ".").last! as String
    }
    
    @nonobjc public var className: String {
        return type(of: self).className
    }
    
    public static func runAfterDelay(delayMSec: Int, closure:@escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(delayMSec), execute: closure)
    }
    
    public static func runOnMainThread(closure: @escaping () -> Void) {
        DispatchQueue.main.async(execute: closure)
    }
}
