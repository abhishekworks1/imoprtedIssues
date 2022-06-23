//
//  OnBoardingViewController.swift
//  SocialCAM
//
//  Created by Siddharth on 09/06/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

protocol QuickStartOptionable {
    var title: String { get }
    var description: String { get }
    var isLastStep: Bool { get }
    var isFirstStep: Bool { get }
    var rawValue: Int { get }
}

enum QuickStartOption {
    
    case createContent
    case mobileDashboard
    case makeMoney
    
    func option(for rawValue: Int) -> QuickStartOptionable? {
        switch self {
        case .createContent:
            return CreateContentOption(rawValue: rawValue)
        case .mobileDashboard:
            return MobileDashboardOption(rawValue: rawValue)
        case .makeMoney:
            return MakeMoneyOption(rawValue: rawValue)
        }
    }
    
    enum CreateContentOption: Int, QuickStartOptionable {
        var title: String {
            switch self {
            case .quickCamCamera:
                return "QuickCam Camera"
            case .fastSlowEditor:
                return "Fast & Slow Motion Recording"
            case .quickieVideoEditor:
                return "Quickie Video Editor"
            case .bitmojis:
                return "Bitmojis"
            case .socialMediaSharing:
                return "Social Media Sharing"
            }
        }
        
        var description: String {
            switch self {
            case .quickCamCamera:
                return ""
            case .fastSlowEditor:
                return ""
            case .quickieVideoEditor:
                return ""
            case .bitmojis:
                return ""
            case .socialMediaSharing:
                return ""
            }
        }
        
        var isLastStep: Bool {
            return self == .socialMediaSharing
        }
        
        var isFirstStep: Bool {
            return self == .quickCamCamera
        }

        case quickCamCamera = 0
        case fastSlowEditor
        case quickieVideoEditor
        case bitmojis
        case socialMediaSharing
    }

    enum MobileDashboardOption: Int, QuickStartOptionable {
        var title: String {
            switch self {
            case .notifications:
                return "Notifications"
            case .howItWorks:
                return "How it Works"
            case .cameraSettings:
                return "Camera Settings"
            case .subscriptions:
                return "Subscription"
            case .checkForUpdates:
                return "Check Updates"
            }
        }
        
        var description: String {
            switch self {
            case .notifications:
                return ""
            case .howItWorks:
                return ""
            case .cameraSettings:
                return ""
            case .subscriptions:
                return ""
            case .checkForUpdates:
                return ""
            }
        }
        
        var isLastStep: Bool {
            return self == .checkForUpdates
        }
        
        var isFirstStep: Bool {
            return self == .notifications
        }
        
        case notifications = 0
        case howItWorks
        case cameraSettings
        case subscriptions
        case checkForUpdates
    }

    enum MakeMoneyOption: Int, QuickStartOptionable {
        var title: String {
            switch self {
            case .referralCommissionProgram:
                return "Referral Commissions Program"
            case .textEmailInviter:
                return "TextInviter™ & EmailInviter™"
            case .socialQRCodeShare:
                return "SocialSharing™ & QRCodeShare™"
            case .contactManagerTools:
                return "Contact Management Tools"
            case .fundraising:
                return "Great for Fundraising"
            }
            
        }
        
        var description: String {
            switch self {
            case .referralCommissionProgram:
                return ""
            case .textEmailInviter:
                return ""
            case .socialQRCodeShare:
                return ""
            case .contactManagerTools:
                return ""
            case .fundraising:
                return ""
            }
        }
        
        var isLastStep: Bool {
            return self == .fundraising
        }
        
        var isFirstStep: Bool {
            return self == .referralCommissionProgram
        }

        case referralCommissionProgram = 0
        case textEmailInviter
        case socialQRCodeShare
        case contactManagerTools
        case fundraising
    }
}

class OnBoardingViewController: UIViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var centerPlaceholderView: NSLayoutConstraint!
    @IBOutlet weak var heightPlaceholderView: NSLayoutConstraint!
    @IBOutlet weak var foundingMemberImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var subscriptionStatusLabel: UILabel!
    @IBOutlet weak var createContentStepIndicatorView: StepIndicatorView!
    @IBOutlet weak var mobileDashboardStepIndicatorView: StepIndicatorView!
    @IBOutlet weak var makeMoneyStepIndicatorView: StepIndicatorView!

    var showPopUpView: Bool = true
    var shouldShowFoundingMemberView: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for option in Defaults.shared.createContentOptions {
            createContentStepIndicatorView.finishedStep = option
        }
        for option in Defaults.shared.mobileDashboardOptions {
            mobileDashboardStepIndicatorView.finishedStep = option
        }
        for option in Defaults.shared.makeMoneyOptions {
            makeMoneyStepIndicatorView.finishedStep = option
        }
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
    
    @IBAction func didTapOnCreateContentSteps(_ sender: UIButton) {
        guard let option = QuickStartOption.createContent.option(for: sender.tag),
              let quickStartDetail = R.storyboard.onBoardingView.quickStartOptionDetailViewController() else {
            return
        }
        var options = Defaults.shared.createContentOptions
        options.append(option.rawValue)
        Defaults.shared.createContentOptions = Array(Set(options))
        quickStartDetail.selectedOption = option
        quickStartDetail.selectedQuickStartMenu = .createContent
        navigationController?.pushViewController(quickStartDetail, animated: true)
    }
    
    @IBAction func didTapOnMobileDashboardSteps(_ sender: UIButton) {
        guard let option = QuickStartOption.mobileDashboard.option(for: sender.tag),
              let quickStartDetail = R.storyboard.onBoardingView.quickStartOptionDetailViewController() else {
            return
        }
        var options = Defaults.shared.mobileDashboardOptions
        options.append(option.rawValue)
        Defaults.shared.mobileDashboardOptions = Array(Set(options))
        quickStartDetail.selectedOption = option
        quickStartDetail.selectedQuickStartMenu = .mobileDashboard
        navigationController?.pushViewController(quickStartDetail, animated: true)
    }
    
    @IBAction func didTapOnMakeMoneySteps(_ sender: UIButton) {
        guard let option = QuickStartOption.makeMoney.option(for: sender.tag),
              let quickStartDetail = R.storyboard.onBoardingView.quickStartOptionDetailViewController() else {
            return
        }
        var options = Defaults.shared.makeMoneyOptions
        options.append(option.rawValue)
        Defaults.shared.makeMoneyOptions = Array(Set(options))
        quickStartDetail.selectedOption = option
        quickStartDetail.selectedQuickStartMenu = .makeMoney
        navigationController?.pushViewController(quickStartDetail, animated: true)
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
