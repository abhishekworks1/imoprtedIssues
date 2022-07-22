//
//  QuickStartOptionDetailViewController.swift
//  QuickCam
//
//  Created by Jasmin Patel on 23/06/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit
import SafariServices

class QuickStartOptionDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var backButtonHeaderView: UIView!
    @IBOutlet weak var quickCamHeaderView: UIView!
    @IBOutlet weak var tryNowButton: UIButton!
    @IBOutlet weak var subscribeNowButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var headerTitleLabel: UILabel!

    var selectedOption: QuickStartOptionable = QuickStartOption.CreateContentOption.quickCamCamera
    var selectedQuickStartMenu: QuickStartOption = .createContent
    var guidTimerDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = selectedOption.title
        if let attributedString = try? NSAttributedString(htmlString: selectedOption.description, font: UIFont.systemFont(ofSize: 17)) {
            descriptionLabel.attributedText = attributedString
        } else {
            descriptionLabel.text = selectedOption.description
        }
//        backButtonHeaderView.isHidden = selectedOption.isFirstStep
//        quickCamHeaderView.isHidden = !selectedOption.isFirstStep
        headerTitleLabel.text = selectedQuickStartMenu.titleText
        tryNowButton.isHidden = !selectedOption.isLastStep
        doneButton.isHidden = !selectedOption.isLastStep
        if !selectedOption.hideTryNowButton {
            tryNowButton.isHidden = false
        }
        if !selectedOption.hideTryNowButton {
            if (selectedOption as? QuickStartOption.MakeMoneyOption) == .referralWizard {
                tryNowButton.setTitle("Try Invite Wizard Now", for: .normal)
            } else {
                tryNowButton.setTitle("Try Calculator Now", for: .normal)
            }
        } else {
            if selectedQuickStartMenu == .createContent {
                tryNowButton.setTitle("Try QuickCam Camera Now", for: .normal)
            } else if selectedQuickStartMenu == .makeMoney {
                tryNowButton.setTitle("Try Invite Wizard Now", for: .normal)
            } else {
                tryNowButton.setTitle("Try Now", for: .normal)
            }
        }
        subscribeNowButton.isHidden = !tryNowButton.isHidden
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
        UserSync.shared.setOnboardingUserFlags()
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
        let greatVC: GreatViewController = R.storyboard.onBoardingView.greatViewController()!
        greatVC.greatViewDelegate = self
        greatVC.categoryString = selectedQuickStartMenu.titleText
        greatVC.guidTimerDate = guidTimerDate
        greatVC.modalPresentationStyle = .overCurrentContext
            present(greatVC, animated: true, completion: nil)
//        if let viewController = navigationController?.viewControllers.first(where: { return $0 is OnBoardingViewController }) {
//            navigationController?.popToViewController(viewController, animated: true)
//        }
    }
    
    @IBAction func didTapOnBack(_ sender: UIButton) {
        if let viewController = navigationController?.viewControllers.first(where: { return $0 is OnBoardingViewController }) {
            navigationController?.popToViewController(viewController, animated: true)
        }
    }
    
    @IBAction func didTapOnSubscribeNow(_ sender: UIButton) {
        if let subscriptionVC = R.storyboard.subscription.subscriptionContainerViewController() {
            subscriptionVC.isFromWelcomeScreen = true
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.pushViewController(subscriptionVC, animated: true)
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
            if !selectedOption.hideTryNowButton,
               (selectedOption as? QuickStartOption.MakeMoneyOption)
                != .referralWizard {
                if let token = Defaults.shared.sessionToken {
                    let urlString = "\(websiteUrl)/p-calculator-2?token=\(token)&redirect_uri=\(redirectUri)"
                    guard let url = URL(string: urlString) else {
                        return
                    }
                    let safariVC = SFSafariViewController(url: url)
                    present(safariVC, animated: true, completion: nil)
                }
            } else {
                let hasAllowAffiliate = Defaults.shared.currentUser?.isAllowAffiliate ?? false
                if hasAllowAffiliate {
                    self.setNavigation()
                } else {
                    guard let makeMoneyReferringVC = R.storyboard.onBoardingView.makeMoneyReferringViewController() else { return }
                    navigationController?.pushViewController(makeMoneyReferringVC, animated: true)
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

extension QuickStartOptionDetailViewController: GreatPopupDelegate {
    func greatPopupEvent(isUpgrade: Bool) {
        if isUpgrade {
            if let subscriptionVC = R.storyboard.subscription.subscriptionContainerViewController() {
                subscriptionVC.isFromWelcomeScreen = true
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.pushViewController(subscriptionVC, animated: true)
            }
        } else {
            if let viewController = navigationController?.viewControllers.first(where: { return $0 is OnBoardingViewController }) {
                navigationController?.popToViewController(viewController, animated: true)
            }
        }
    }
}

extension NSAttributedString {
    
    convenience init(htmlString html: String, font: UIFont? = nil) throws {
        let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        let data = html.data(using: .utf8, allowLossyConversion: true)
        guard (data != nil), let fontFamily = font?.familyName, let attr = try? NSMutableAttributedString(data: data!, options: options, documentAttributes: nil) else {
            try self.init(data: data ?? Data(html.utf8), options: options, documentAttributes: nil)
            return
        }
        
        let fontSize: CGFloat? = font == nil ? nil : font!.pointSize
        let range = NSRange(location: 0, length: attr.length)
        attr.enumerateAttribute(.font, in: range, options: .longestEffectiveRangeNotRequired) { attrib, range, _ in
            if let htmlFont = attrib as? UIFont {
                let traits = htmlFont.fontDescriptor.symbolicTraits
                var descrip = htmlFont.fontDescriptor.withFamily(fontFamily)
                
                if (traits.rawValue & UIFontDescriptor.SymbolicTraits.traitBold.rawValue) != 0 {
                    descrip = descrip.withSymbolicTraits(.traitBold)!
                }
                
                if (traits.rawValue & UIFontDescriptor.SymbolicTraits.traitItalic.rawValue) != 0 {
                    descrip = descrip.withSymbolicTraits(.traitItalic)!
                }
                
                attr.addAttribute(.font, value: UIFont(descriptor: descrip, size: fontSize ?? htmlFont.pointSize), range: range)
            }
        }
        
        self.init(attributedString: attr)
    }
}
