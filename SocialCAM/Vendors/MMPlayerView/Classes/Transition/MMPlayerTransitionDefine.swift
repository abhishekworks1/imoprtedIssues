//
//  TransitionDefine.swift
//  ETNews
//
//  Created by Millman YANG on 2017/5/22.
//  Copyright © 2017年 Sen Informatoin co. All rights reserved.
//

import Foundation

public protocol MMPlayerConfig {
    var duration: TimeInterval { get set }
    var passOriginalSuper: UIView? {get set}
    var playLayer: MMPlayerLayer? { get set}
}

public protocol MMPlayerPresentConfig: MMPlayerConfig {
    var margin: CGFloat { get set }
    var shrinkSize: CGSize { get set }
    var dismissGesture: Bool { get }
    var source: UIViewController? { get set }
}

public protocol MMPlayerNavConfig: MMPlayerConfig {
}

public protocol MMPlayerTransitionCompatible {
    associatedtype CompatibleType
    static var mmPlayerTransition: MMPlayerTransition<CompatibleType>.Type { get set }
    
    var mmPlayerTransition: MMPlayerTransition<CompatibleType> { get set }
}

extension MMPlayerTransitionCompatible {
    public static var mmPlayerTransition: MMPlayerTransition<Self>.Type {
        get {
            return MMPlayerTransition<Self>.self
        } set {}
    }
    
    public var mmPlayerTransition: MMPlayerTransition<Self> {
        get {
            return MMPlayerTransition(self)
        } set {}
    }
}

public struct MMPlayerTransition<T> {
    public let base: T
    init(_ base: T) {
        self.base = base
    }
}

extension NSObject: MMPlayerTransitionCompatible { }

@objc public protocol MMPlayerPrsentFromProtocol: MMPlayerFromProtocol {
    
    func presentedView(isShrinkVideo: Bool)
    func dismissViewFromGesture()
}

@objc public protocol MMPlayerFromProtocol {
    var passPlayer: MMPlayerLayer { get }
    func transitionWillStart()
    func transitionCompleted()
    @objc optional func backReplaceSuperView(original: UIView?) -> UIView?
}

@objc public protocol MMPLayerToProtocol {
    var containerView: UIView { get }
    func transitionCompleted(player: MMPlayerLayer)
}
