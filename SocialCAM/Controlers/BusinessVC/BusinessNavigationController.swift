//
//  BusinessNavigationController.swift
//  SocialCAM
//
//  Created by Viraj Patel on 01/07/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation

class BusinessNavigationController: UINavigationController, UINavigationControllerDelegate {
    override func viewDidLoad() {
        delegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            if traitCollection.userInterfaceStyle == .light {
                return .lightContent
            } else {
                return .darkContent
            }
        } else {
            return .lightContent
        }
    }
    
    func enableScroll() {
        if viewControllers.count > 1 {
            self.parentPageViewController?.isScrollEnabled = false
        } else {
            self.parentPageViewController?.isScrollEnabled = true
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        enableScroll()
    }
    
}
