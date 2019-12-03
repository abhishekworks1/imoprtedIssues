//
//  UIWindow.swift
//  ProManager
//
//  Created by Jasmin Patel on 20/08/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

extension UIWindow {
   
    func switchRootViewController(_ viewController: UIViewController,
                                  animated: Bool = true,
                                  duration: TimeInterval = 1,
                                  options: UIView.AnimationOptions = .curveEaseInOut,
                                  completion: (() -> Void)? = nil) {
        guard animated else {
            rootViewController = viewController
            return
        }
        
        UIView.transition(with: self, duration: duration, options: options, animations: {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            self.rootViewController = viewController
            UIView.setAnimationsEnabled(oldState)
        }, completion: { _ in
            completion?()
        })
    }
    
    func visibleViewController() -> UIViewController? {
        if let rootViewController: UIViewController  = self.rootViewController {
            return UIWindow.getVisibleViewControllerFrom(rootViewController)
        }
        return nil
    }
    
    class func getVisibleViewControllerFrom(_ viewController: UIViewController) -> UIViewController {
        if viewController.isKind(of: UINavigationController.self) {
            guard let navigationController: UINavigationController = viewController as? UINavigationController else {
                return viewController
            }
            return UIWindow.getVisibleViewControllerFrom(navigationController.visibleViewController!)
        } else if viewController.isKind(of: UITabBarController.self) {
            guard let tabBarController: UITabBarController = viewController as? UITabBarController else {
                return viewController
            }
            return UIWindow.getVisibleViewControllerFrom(tabBarController.selectedViewController!)
        } else {
            guard let presentedViewController: UIViewController = viewController.presentedViewController else {
                return viewController
            }
            return UIWindow.getVisibleViewControllerFrom(presentedViewController)
        }
    }
}
