//
//  OnBoardingViewController.swift
//  SocialCAM
//
//  Created by Siddharth on 09/06/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class OnBoardingViewController: UIViewController {

    var showPopUpView: Bool = true
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var popupView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    

    @IBAction func didTapMakeMoneyClick(_ sender: UIButton) {
        let hasAllowAffiliate = Defaults.shared.currentUser?.isAllowAffiliate ?? false
        if hasAllowAffiliate {
            self.setNavigation()
        } else {
            guard let makeMoneyReferringVC = R.storyboard.onBoardingView.makeMoneyReferringViewController() else { return }
            navigationController?.pushViewController(makeMoneyReferringVC, animated: true)
        }
    }
    
    
    @IBAction func createContent(_ sender: UIButton) {
        Defaults.shared.isSignupLoginFlow = true
        let rootViewController: UIViewController? = R.storyboard.pageViewController.pageViewController()
        Utils.appDelegate?.window?.rootViewController = rootViewController
    }
    
    @IBAction func didTapMobileDashboardClick(_ sender: UIButton) {
        let rootViewController: UIViewController? = R.storyboard.pageViewController.pageViewController()
        if let pageViewController = rootViewController as? PageViewController,
           let navigationController = pageViewController.pageControllers.first as? UINavigationController,
           let settingVC = R.storyboard.storyCameraViewController.storySettingsVC() {
            navigationController.viewControllers.append(settingVC)
        }
        Utils.appDelegate?.window?.rootViewController = rootViewController
    }
    
    @IBAction func didTapCloseClick(_ sender: UIButton) {
        popupView.isHidden = true
    }
    
}

extension OnBoardingViewController {
    
    func setupView() {
        popupView.isHidden = !self.showPopUpView
        if let user = Defaults.shared.currentUser {
//            self.welcomeLabel.text = " Welcome \(String(describing: user.username!)), to QuickCam, the next level smart phone camera app for making money! \nThe perfect global economic crisis antidote!!"
        }
    }
    
    func setNavigation() {
        if let userImageURL = Defaults.shared.currentUser?.profileImageURL , !userImageURL.isEmpty, userImageURL != "undefined" {
            if let contactWizardController = R.storyboard.contactWizardwithAboutUs.contactImportVC() {
                contactWizardController.isFromOnboarding = true
                navigationController?.pushViewController(contactWizardController, animated: true)
            }
        } else {
            if let editProfileController = R.storyboard.refferalEditProfile.refferalEditProfileViewController() {
                editProfileController.isFromOnboarding = true
                navigationController?.pushViewController(editProfileController, animated: true)
            }
        }
    }
    
}
