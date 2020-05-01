//
//  CameraNavigationController.swift
//  SocialCAM
//
//  Created by Viraj Patel on 23/01/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import Pageboy

extension UIViewController {
    var parentPageViewController: PageboyViewController? {
        var parentPageVC = self.parent
        while parentPageVC != nil {
            parentPageVC = parentPageVC?.parent
            if let viewController = parentPageVC as? PageboyViewController {
                return viewController
            }
        }
        return nil
    }
}

class StoryCameraViewNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    func enableScroll() {
        if viewControllers.count > 1 {
            self.parentPageViewController?.isScrollEnabled = false
        } else {
            #if VIRALCAMAPP
            self.parentPageViewController?.isScrollEnabled = true
            #else
            self.parentPageViewController?.isScrollEnabled = BackgroundManager.shared.imageURLs.count == 0 ? false : true
            #endif
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        enableScroll()
    }
}
