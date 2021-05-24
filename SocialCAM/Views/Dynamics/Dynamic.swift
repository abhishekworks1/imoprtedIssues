//
//  Dynamic.swift
//  myASMR
//
//  Created by Nilisha Gupta on 25/05/21.
//  Copyright © 2020 Simform Solutions. All rights reserved.
//

class Dynamic<T> {
    
    // MARK: - Typealias
    typealias Listener = (T) -> ()
    
    // MARK: - Vars & Lets
    var listener: Listener?
    var value: T {
        didSet {
            self.fire()
        }
    }
    
    // MARK: - Initialization
    init(_ v: T) { // swiftlint:disable:this identifier_name
        value = v
    }
    
    // MARK: - Public func
    func bind(_ listener: Listener?) {
        self.listener = listener
    }
    
    func bindAndFire(_ listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
    
    // MARK: -
    internal func fire() {
        self.listener?(value)
    }
    
}
