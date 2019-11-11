//
//  MMPresentAnimator.swift
//  Pods
//
//  Created by Millman YANG on 2017/4/25.
//
//

import UIKit

public class MMPlayerPresentAnimator: NSObject , UIViewControllerTransitioningDelegate{
    public typealias T = MMPlayerPresentConfig
    public var config:T?
    
    unowned let base:UIViewController
    var transition: UIViewControllerAnimatedTransitioning?
    public init(_ base: UIViewController) {
        self.base = base
        super.init()
        base.modalPresentationStyle = .custom
        base.transitioningDelegate = self
    }
    
    public func pass<T: MMPlayerPassViewPresentConfig>(setting: (_ config: T)->Void) {
        self.config = MMPlayerPassViewPresentConfig()
        setting(self.config! as! T)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        (self.transition as? MMPlayerBasePresentTransition)?.isPresent = false
        return self.transition
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transition = self.transition(config: config, isPresent: true ,source: source)
        return self.transition
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return self.presentationController(config: config, forPresented: presented, presenting: presenting)
    }
    
    fileprivate func transition(config:T? ,isPresent:Bool ,source: UIViewController?) -> UIViewControllerAnimatedTransitioning? {
        
        if let c = config {
            switch c {
            case let c as MMPlayerPassViewPresentConfig:
                let pass = MMPlayerPassViewPresentTransition(config: c, isPresent: isPresent)
                pass.source = source
                c.source = source
                return pass
            default: break
            }
        }
        return nil
    }
    
    fileprivate func presentationController(config:T? , forPresented presented: UIViewController, presenting: UIViewController?) -> UIPresentationController? {
        
        if let c = config {
            switch c {
            case let c as MMPlayerPassViewPresentConfig:
                return MMPlayerPassViewPresentatinController(presentedViewController: presented, presenting: presenting, config: c)

            default: break
            }
        }
        
        return nil
    }
}
