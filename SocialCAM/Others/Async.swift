//
//  Async.swift
//  SocialCAM
//
//  Created by Viraj Patel on 28/11/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

class AsynchronousOperation: Operation {
    
    var _isFinished: Bool = false
    
    override var isFinished: Bool {
        set {
            willChangeValue(forKey: "isFinished")
            _isFinished = newValue
            didChangeValue(forKey: "isFinished")
        }
        
        get {
            return _isFinished
        }
    }
    
    var _isExecuting: Bool = false
    
    override var isExecuting: Bool {
        set {
            willChangeValue(forKey: "isExecuting")
            _isExecuting = newValue
            didChangeValue(forKey: "isExecuting")
        }
        
        get {
            return _isExecuting
        }
    }
    
    override var isAsynchronous: Bool {
        get {
            return true
        }
    }
    
    override func start() {
        if self.isCancelled {
            isFinished = true
        } else {
            isExecuting = false
            main()
        }
    }
    
    override func main() {
        if self.isCancelled {
            isFinished = true
        } else {
            isExecuting = false
            self.execute()
            //Asynchronous logic (eg: n/w calls) with callback {
        }
    }
    
    func execute() {
        
    }
}
