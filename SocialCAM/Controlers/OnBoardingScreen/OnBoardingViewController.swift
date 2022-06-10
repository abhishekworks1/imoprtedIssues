//
//  OnBoardingViewController.swift
//  SocialCAM
//
//  Created by Siddharth on 09/06/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class OnBoardingViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
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
            present(makeMoneyReferringVC, animated: true)
        }
    }
    
    
    @IBAction func createContent(_ sender: UIButton) {
        Defaults.shared.isSignupLoginFlow = true
        let rootViewController: UIViewController? = R.storyboard.pageViewController.pageViewController()
        Utils.appDelegate?.window?.rootViewController = rootViewController
    }
    
}

extension OnBoardingViewController {
    
    func setupView() {
        if let user = Defaults.shared.currentUser {
            self.welcomeLabel.text = " Welcome \(String(describing: user.username!)), to QuickCam, the next level smart phone camera app for making money! \nThe perfect global economic crisis antidote!!"
        }
    }
    
    func setNavigation() {
        if let userImageURL = Defaults.shared.currentUser?.profileImageURL , !userImageURL.isEmpty {
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
