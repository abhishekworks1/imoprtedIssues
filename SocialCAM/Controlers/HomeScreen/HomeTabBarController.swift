//
//  HomeTabBarController.swift
//  SocialCAM
//
//  Created by Viraj Patel on 22/01/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation

class HomeTabBarController: UITabBarController {
    
    open var imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.init(x: 0,
                                                            y: -28,
                                                            width: 80,
                                                            height: 80))
        imageView.backgroundColor = ApplicationSettings.appBackgroundColor
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 40
        imageView.image = R.image.tab3()
        return imageView
    }()
    
    var revealingSplashView: RevealingSplashView!
    private var revealingLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        guard let tabBarItems = tabBar.items else { return }
        for tabBarItem in tabBarItems {
            if tabBarItem.tag == 2 {
                guard let contentView = tabBarItem.value(forKey: "view") as? UIView else { continue }
                contentView.addSubview(imageView)
            }
        }
        
        revealingSplashView = RevealingSplashView(iconImage: Constant.Application.appIcon, iconInitialSize: Constant.Application.appIcon.size, backgroundImage: Constant.Application.splashBG)
        self.view.addSubview(revealingSplashView)
        
        revealingSplashView.duration = 2.0
        revealingSplashView.iconColor = UIColor.red
        revealingSplashView.useCustomIconColor = false
        revealingSplashView.animationType = SplashAnimationType.popAndZoomOut
    }
    
    func splashAmination() {
        revealingSplashView.startAnimation() {
            self.revealingLoaded = true
            self.setNeedsStatusBarAppearanceUpdate()
            print("Completed")
        }
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
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
}

extension UITabBarController {
    func orderedTabBarItemViews() -> [UIView] {
        let interactionViews = tabBar.subviews.filter({$0.isUserInteractionEnabled})
        return interactionViews.sorted(by: {$0.frame.minX < $1.frame.minX})
    }
}

extension HomeTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if self.viewControllers?.firstIndex(of: viewController) == 2 {
            print("2")
            return false
        } else {
            print("12345")
            return true
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
}
