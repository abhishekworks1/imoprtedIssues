//
//  QuickStartOptionDetailViewController.swift
//  QuickCam
//
//  Created by Jasmin Patel on 23/06/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class QuickStartOptionDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var backButtonHeaderView: UIView!
    @IBOutlet weak var quickCamHeaderView: UIView!
    @IBOutlet weak var tryNowButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!

    var selectedOption: QuickStartOptionable = QuickStartOption.CreateContentOption.quickCamCamera
    var selectedQuickStartMenu: QuickStartOption = .createContent
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = selectedOption.title
        descriptionLabel.text = selectedOption.description
        backButtonHeaderView.isHidden = selectedOption.isFirstStep
        quickCamHeaderView.isHidden = !selectedOption.isFirstStep
        tryNowButton.isHidden = !selectedOption.isLastStep
        doneButton.isHidden = !selectedOption.isLastStep
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch selectedQuickStartMenu {
        case .createContent:
            var options = Defaults.shared.createContentOptions
            options.append(selectedOption.rawValue)
            Defaults.shared.createContentOptions = Array(Set(options))
        case .mobileDashboard:
            var options = Defaults.shared.mobileDashboardOptions
            options.append(selectedOption.rawValue)
            Defaults.shared.mobileDashboardOptions = Array(Set(options))
        case .makeMoney:
            var options = Defaults.shared.makeMoneyOptions
            options.append(selectedOption.rawValue)
            Defaults.shared.makeMoneyOptions = Array(Set(options))
        }
    }
    
    func quickStartOption(for rawValue: Int) -> QuickStartOptionable? {
        switch selectedQuickStartMenu {
        case .createContent:
            return QuickStartOption.CreateContentOption(rawValue: rawValue)
        case .mobileDashboard:
            return QuickStartOption.MobileDashboardOption(rawValue: rawValue)
        case .makeMoney:
            return QuickStartOption.MakeMoneyOption(rawValue: rawValue)
        }
    }
    
    @IBAction func didTapOnNextStep(_ sender: UIButton) {
        guard let option = quickStartOption(for: selectedOption.rawValue + 1),
              let quickStartDetail = R.storyboard.onBoardingView.quickStartOptionDetailViewController() else {
            return
        }
        quickStartDetail.selectedOption = option
        quickStartDetail.selectedQuickStartMenu = selectedQuickStartMenu
        navigationController?.pushViewController(quickStartDetail, animated: true)
    }
    
    @IBAction func didTapOnPreviousStep(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapOnDoneStep(_ sender: UIButton) {
        if let viewController = navigationController?.viewControllers.first(where: { return $0 is OnBoardingViewController }) {
            navigationController?.popToViewController(viewController, animated: true)
        }
    }
    
    @IBAction func didTapOnBack(_ sender: UIButton) {
        if let viewController = navigationController?.viewControllers.first(where: { return $0 is OnBoardingViewController }) {
            navigationController?.popToViewController(viewController, animated: true)
        }
    }
    
    @IBAction func didTapOnTryNow(_ sender: UIButton) {
        switch selectedQuickStartMenu {
        case .createContent:
            Defaults.shared.isSignupLoginFlow = true
            let rootViewController: UIViewController? = R.storyboard.pageViewController.pageViewController()
            Utils.appDelegate?.window?.rootViewController = rootViewController
        case .mobileDashboard:
            let rootViewController: UIViewController? = R.storyboard.pageViewController.pageViewController()
            if let pageViewController = rootViewController as? PageViewController,
               let navigationController = pageViewController.pageControllers.first as? UINavigationController,
               let settingVC = R.storyboard.storyCameraViewController.storySettingsVC() {
                navigationController.viewControllers.append(settingVC)
            }
            Utils.appDelegate?.window?.rootViewController = rootViewController
        case .makeMoney:
            let hasAllowAffiliate = Defaults.shared.currentUser?.isAllowAffiliate ?? false
            if hasAllowAffiliate {
                self.setNavigation()
            } else {
                guard let makeMoneyReferringVC = R.storyboard.onBoardingView.makeMoneyReferringViewController() else { return }
                navigationController?.pushViewController(makeMoneyReferringVC, animated: true)
            }        }
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
