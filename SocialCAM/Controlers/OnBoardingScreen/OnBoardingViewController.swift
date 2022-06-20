//
//  OnBoardingViewController.swift
//  SocialCAM
//
//  Created by Siddharth on 09/06/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class OnBoardingViewController: UIViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var centerPlaceholderView: NSLayoutConstraint!
    @IBOutlet weak var heightPlaceholderView: NSLayoutConstraint!
    @IBOutlet weak var foundingMemberImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var subscriptionStatusLabel: UILabel!

    var showPopUpView: Bool = true
    var shouldShowFoundingMemberView: Bool = true

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
        UserSync.shared.syncUserModel { isCompleted in
            if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
                self.userImageView.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: R.image.user_placeholder())
            }
            let isFoundingMember = Defaults.shared.currentUser?.badges?.filter({ return $0.badge?.code == "founding-member" }).count ?? 0 > 0
            if isFoundingMember {
                self.foundingMemberImageView.isHidden = false
                self.centerPlaceholderView.constant = -30
                self.heightPlaceholderView.constant = 211
            } else {
                self.foundingMemberImageView.isHidden = true
                self.centerPlaceholderView.constant = 0
                self.heightPlaceholderView.constant = 110
            }
            self.userNameLabel.text = Defaults.shared.currentUser?.firstName
            if let badgearray = Defaults.shared.currentUser?.badges {
                for parentbadge in badgearray {
                    let badgeCode = parentbadge.badge?.code ?? ""
                    if badgeCode == Badges.SUBSCRIBER_IOS.rawValue {
                        let subscriptionType = parentbadge.meta?.subscriptionType ?? ""
                        let finalDay = Defaults.shared.getCountFromBadge(parentbadge: parentbadge)
                        if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                            if finalDay == "7" {
                                self.subscriptionStatusLabel.text = "Today is the last day of your 7-day free trial. Upgrade now to access these features"
                            } else {
                                var fday = 0
                                if let day = Int(finalDay) {
                                    if day <= 7 && day >= 0
                                    {
                                        fday = 7 - day
                                    }
                                }
                                if fday == 0{
                                    self.subscriptionStatusLabel.text = "Your 7-day free trial period has expired. Upgrade now to access these features."
                                } else {
                                    self.subscriptionStatusLabel.text = "You have \(fday) days left on your free trial. Subscribe now and earn your subscription badge."
                                }
                               
                            }
                        } else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
                            self.subscriptionStatusLabel.text = "Your 7-day free trial is over. Subscribe now to continue using the Basic, Advanced or Premium features."
                        }
                    }
                }
            }
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
