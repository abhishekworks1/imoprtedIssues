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
    
    var pageControllers: [UIViewController] = {
        var viewControllers = [UIViewController]()
        if let cameraNavVC = R.storyboard.storyCameraViewController.storyCameraViewNavigationController() {
            cameraNavVC.navigationBar.isHidden = true
            viewControllers.append(cameraNavVC)
        }
        #if PIC2ARTAPP || SOCIALCAMAPP || VIRALCAMAPP || SOCCERCAMAPP || FUTBOLCAMAPP || SNAPCAMAPP
        if let homeVC = R.storyboard.homeScreen.homeTabBarController() {
            viewControllers.append(homeVC)
        }
        #endif
        if let viralToolsVC = R.storyboard.storyCameraViewController.businessNavigationController() {
            viralToolsVC.navigationBar.isHidden = true
            viewControllers.append(viralToolsVC)
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
        changeBackgroundImage()
        AppEventBus.onMainThread(self, name: "ReloadBanner") { [weak self] _ in
            guard let `self` = self else {
                return
            }
            self.changeBackgroundImage()
        }
    }
    
    @objc func nextPage(_ sender: UIBarButtonItem) {
        scrollToPage(.next, animated: true)
    }
    
    @objc func previousPage(_ sender: UIBarButtonItem) {
        scrollToPage(.previous, animated: true)
    }
    
    func changeBackgroundImage() {
        for imageString in BackgroundManager.shared.imageURLs {
            let viewController = UIViewController()
            let imageView = UIImageView.init(frame: viewController.view.frame)
            imageView.setImageFromURL(imageString, placeholderImage: nil)
            imageView.contentMode = .scaleToFill
            viewController.view.addSubview(imageView)
            pageControllers.append(viewController)
        }
        reloadData()
        
        self.isScrollEnabled = true
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
        case .chat:
            return PageboyViewController.Page.at(index: 2)
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
                if let homeTabBarController = pageboyViewController.findViewController(viewcontrollers: self.pageControllers, type: HomeTabBarController()) {
                    homeTabBarController.splashAmination()
                }
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
