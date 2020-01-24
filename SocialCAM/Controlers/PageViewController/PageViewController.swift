//
//  PageViewController.swift
//  SocialCAM
//
//  Created by Viraj Patel on 23/01/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import Pageboy

class PageViewController: PageboyViewController {
    let pageControllers: [UIViewController] = {
        var viewControllers = [UIViewController]()
        if let cameraNavVC = R.storyboard.storyCameraViewController.storyCameraViewNavigationController() {
            cameraNavVC.navigationBar.isHidden = true
            viewControllers.append(cameraNavVC)
        }
        if let homeVC = R.storyboard.homeScreen.homeTabBarController() {
            viewControllers.append(homeVC)
        }
        return viewControllers
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bounces = true
        dataSource = self
        delegate = self
        self.isInfiniteScrollEnabled = true
        reloadData()
    }
    
    @objc func nextPage(_ sender: UIBarButtonItem) {
        scrollToPage(.next, animated: true)
    }
    
    @objc func previousPage(_ sender: UIBarButtonItem) {
        scrollToPage(.previous, animated: true)
    }

}

// MARK: PageboyViewControllerDataSource
extension PageViewController: PageboyViewControllerDataSource {
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return pageControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return pageControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        switch Defaults.shared.openingScreen {
        case .camera:
            return PageboyViewController.Page.at(index: 0)
        case .dashboard:
            return PageboyViewController.Page.at(index: 1)
        }
    }
    
}

// MARK: PageboyViewControllerDelegate

extension PageViewController: PageboyViewControllerDelegate {
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController,
                               willScrollToPageAt index: Int,
                               direction: PageboyViewController.NavigationDirection,
                               animated: Bool) {
       
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController,
                               didScrollTo position: CGPoint,
                               direction: PageboyViewController.NavigationDirection,
                               animated: Bool) {
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController,
                               didScrollToPageAt index: Int,
                               direction: PageboyViewController.NavigationDirection,
                               animated: Bool) {
        DispatchQueue.main.async {
            if index == 1 {
                UIApplication.shared.keyWindow?.windowLevel = UIWindow.Level.statusBar
            } else {
                UIApplication.shared.keyWindow?.windowLevel = UIWindow.Level.normal
            }
        }
      
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController,
                               didReloadWith currentViewController: UIViewController,
                               currentPageIndex: PageboyViewController.PageIndex) {
        
    }
    
}
