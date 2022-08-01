//
//  HomeNavigaionController.swift
//  SocialCAM
//
//  Created by Viraj Patel on 22/01/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation

class HomeNavigationController: UINavigationController, UINavigationControllerDelegate {
    override func viewDidLoad() {
        delegate = self
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
