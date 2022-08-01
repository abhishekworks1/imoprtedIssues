//
//  HalfModalTransitioningDelegate.swift
//  HalfModalPresentationController
//
//  Created by Martin Normark on 17/01/16.
//  Copyright © 2016 martinnormark. All rights reserved.
//

import UIKit

public struct BottomPopupConstants {
    static let kDefaultHeight = UIScreen.main.bounds.size.height / 2
    static let kDefaultTopCornerRadius = CGFloat(10.0)
    static let kDefaultPresentDuration = 0.5
    static let kDefaultDismissDuration = 0.5
    static let dismissInteractively = true
    static let kDimmingViewDefaultAlphaValue: CGFloat = 0.5
}

class HalfModalTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var viewController: UIViewController
    var presentingViewController: UIViewController
    var interactionController: HalfModalInteractiveTransition
    
    var interactiveDismiss = true
    var height: CGFloat?
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?
    
    init(viewController: UIViewController, presentingViewController: UIViewController) {
        self.viewController = viewController
        self.presentingViewController = presentingViewController
        self.interactionController = HalfModalInteractiveTransition(viewController: self.viewController, withView: self.presentingViewController.view, presentingViewController: self.presentingViewController)
        
        super.init()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HalfModalTransitionAnimator(type: .Dismiss)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfModalPresentationController(presentedViewController: presented, presenting: presenting, usingHeight: getPopupHeight(), andDimmingViewAlpha: getDimmingViewAlpha())
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if interactiveDismiss {
            return self.interactionController
        }
        
        return nil
    }
    
    open func getPopupHeight() -> CGFloat {
        return height ?? BottomPopupConstants.kDefaultHeight
    }
    
    open func getPopupTopCornerRadius() -> CGFloat {
        return topCornerRadius ?? BottomPopupConstants.kDefaultTopCornerRadius
    }
    
    open func getPopupPresentDuration() -> Double {
        return presentDuration ?? BottomPopupConstants.kDefaultPresentDuration
    }
    
    open func getPopupDismissDuration() -> Double {
        return dismissDuration ?? BottomPopupConstants.kDefaultDismissDuration
    }
    
    open func getDimmingViewAlpha() -> CGFloat {
        return BottomPopupConstants.kDimmingViewDefaultAlphaValue
    }
}

extension UIViewController { }
