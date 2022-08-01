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
    
    var isFinish: Bool = false
    
    override var isFinished: Bool {
        set {
            willChangeValue(forKey: "isFinished")
            isFinish = newValue
            didChangeValue(forKey: "isFinished")
        }
        
        get {
            return isFinish
        }
    }
    
    var isExecut: Bool = false
    
    override var isExecuting: Bool {
        set {
            willChangeValue(forKey: "isExecuting")
            isExecut = newValue
            didChangeValue(forKey: "isExecuting")
        }
        
        get {
            return isExecut
        }
    }
    
    override var isAsynchronous: Bool {
        get {
            return true
        }
    }
    
    override func start() {
        if self.isCancelled {
            isFinish = true
        } else {
            isExecut = false
            main()
        }
    }
    
    override func main() {
        if self.isCancelled {
            isFinish = true
        } else {
            isExecut = false
            self.execute()
            //Asynchronous logic (eg: n/w calls) with callback {
        }
    }
    
    func execute() {
        
    }
}
