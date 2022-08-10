//
//  QuickStartOptionDetailViewController.swift
//  QuickCam
//
//  Created by Jasmin Patel on 23/06/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit
import SafariServices
import WebKit

class QuickStartOptionDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var backButtonHeaderView: UIView!
    @IBOutlet weak var quickCamHeaderView: UIView!
    @IBOutlet weak var tryNowButton: UIButton!
    @IBOutlet weak var subscribeNowButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var webview: WKWebView!

    @IBOutlet weak var incomeGoalConfirmPopupView: UIView!
    @IBOutlet weak var btnDoNotShowAgainincomeGoalConfirmPopup: UIButton!
    
//    var selectedOption: QuickStartOptionable = QuickStartOption.CreateContentOption.quickCamCamera
//    var selectedQuickStartMenu: QuickStartOption = .createContent
    var selectedQuickStartCategory: QuickStartCategory?
    var selectedQuickStartItem: QuickStartCategoryContent?
    
    var guidTimerDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = selectedQuickStartItem?.title
        if let attributedString = try? NSAttributedString(htmlString: selectedQuickStartItem?.content ?? "", font: UIFont.systemFont(ofSize: 17)) {
            descriptionLabel.attributedText = attributedString
        } else {
            descriptionLabel.text = selectedQuickStartItem?.content ?? ""
        }
        let headerString = "<head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></head>"
        webview.loadHTMLString(headerString + (selectedQuickStartItem?.content ?? ""), baseURL: nil)
//        backButtonHeaderView.isHidden = selectedOption.isFirstStep
//        quickCamHeaderView.isHidden = !selectedOption.isFirstStep
        headerTitleLabel.text = selectedQuickStartCategory?.label ?? ""
        tryNowButton.isHidden = !(selectedQuickStartCategory?.Items?.last == selectedQuickStartItem)
        doneButton.isHidden = !(selectedQuickStartCategory?.Items?.last == selectedQuickStartItem)
        if (selectedQuickStartItem?.title == "Income Goal Calculator" || selectedQuickStartItem?.title == "Invite Wizard") {
            tryNowButton.isHidden = false
            if selectedQuickStartItem?.title == "Invite Wizard" {
                tryNowButton.setTitle("Try Invite Wizard Now", for: .normal)
            } else {
                tryNowButton.setTitle("Try Calculator Now", for: .normal)
            }
        } else {
            if selectedQuickStartCategory?.catId == "create_engaging_content" {
                tryNowButton.setTitle("Try QuickCam Camera Now", for: .normal)
            } else if selectedQuickStartCategory?.catId == "make_money_referring_quickCam" {
                tryNowButton.setTitle("Try Invite Wizard Now", for: .normal)
            } else if selectedQuickStartCategory?.catId == "mobile_dashboard" {
                tryNowButton.setTitle("Try Mobile Dashboard Now", for: .normal)
            } else {
                tryNowButton.setTitle("Try Now", for: .normal)
            }
        }
        subscribeNowButton.isHidden = !tryNowButton.isHidden
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        switch selectedQuickStartMenu {
//        case .createContent:
//            var options = Defaults.shared.createContentOptions
//            options.append(selectedOption.rawValue)
//            Defaults.shared.createContentOptions = Array(Set(options))
//        case .mobileDashboard:
//            var options = Defaults.shared.mobileDashboardOptions
//            options.append(selectedOption.rawValue)
//            Defaults.shared.mobileDashboardOptions = Array(Set(options))
//        case .makeMoney:
//            var options = Defaults.shared.makeMoneyOptions
//            options.append(selectedOption.rawValue)
//            Defaults.shared.makeMoneyOptions = Array(Set(options))
//        }
        selectedQuickStartItem?.isread = true
        var categories = Defaults.shared.quickStartCategories ?? []
        for category in categories {
            for item in category.Items ?? [] {
                if item == selectedQuickStartItem {
                    item.isread = true
                }
            }
            let completed = !((category.Items?.filter({ return !($0.isread ?? false) }).count ?? 0) > 0)
            category.completed = completed
            if selectedQuickStartCategory == category {
                selectedQuickStartCategory?.completed = completed
            }
        }
        Defaults.shared.quickStartCategories = categories
        UserSync.shared.readQuickStartCategories(id: selectedQuickStartItem?._id ?? "")
    }
    
//    func quickStartOption(for rawValue: Int) -> QuickStartOptionable? {
//        switch selectedQuickStartMenu {
//        case .createContent:
//            return QuickStartOption.CreateContentOption(rawValue: rawValue)
//        case .mobileDashboard:
//            return QuickStartOption.MobileDashboardOption(rawValue: rawValue)
//        case .makeMoney:
//            return QuickStartOption.MakeMoneyOption(rawValue: rawValue)
//        }
//        if selectedQuickStartCategory?.catId == "create_engaging_content" {
//            if  {
//
//            }
//
//        } else if selectedQuickStartCategory?.catId == "make_money_referring_quickCam" {
//            if let index = selectedQuickStartCategory?.Items?.firstIndex(where: { return $0 == selectedQuickStartItem }) {
//
//            }
//        } else {
//            if let index = selectedQuickStartCategory?.Items?.firstIndex(where: { return $0 == selectedQuickStartItem }) {
//
//            }
//        }
//    }
    
    @IBAction func didTapOnNextStep(_ sender: UIButton) {
        guard let index = selectedQuickStartCategory?.Items?.firstIndex(where: { return $0 == selectedQuickStartItem }),
              let quickStartDetail = R.storyboard.onBoardingView.quickStartOptionDetailViewController() else {
            return
        }
        quickStartDetail.selectedQuickStartItem = selectedQuickStartCategory?.Items?[index + 1]
        quickStartDetail.selectedQuickStartCategory = selectedQuickStartCategory
        navigationController?.pushViewController(quickStartDetail, animated: true)
    }
    
    @IBAction func didTapOnPreviousStep(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapOnDoneStep(_ sender: UIButton) {
        
        if let completed = selectedQuickStartCategory?.completed, completed {
            let greatVC: GreatViewController = R.storyboard.onBoardingView.greatViewController()!
            greatVC.greatViewDelegate = self
            greatVC.categoryString = selectedQuickStartCategory?.label
            greatVC.guidTimerDate = guidTimerDate
            greatVC.modalPresentationStyle = .overCurrentContext
            present(greatVC, animated: true, completion: nil)
        } else {
            if let viewController = navigationController?.viewControllers.first(where: { return $0 is OnBoardingViewController }) {
                navigationController?.popToViewController(viewController, animated: true)
            }
        }
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
        if selectedQuickStartCategory?.catId == "create_engaging_content" {
            Defaults.shared.isSignupLoginFlow = true
            if let storySettingsVC = R.storyboard.storyCameraViewController.storyCameraViewController() {
                storySettingsVC.isFromCameraParentView = true
                navigationController?.pushViewController(storySettingsVC, animated: true)
            }
        } else if selectedQuickStartCategory?.catId == "make_money_referring_quickCam" {
            if selectedQuickStartItem?.title == "Income Goal Calculator" {
                openPotentialIncomeCalculator()
//                if let token = Defaults.shared.sessionToken {
//                    let urlString = "\(websiteUrl)/p-calculator-2?token=\(token)&redirect_uri=\(redirectUri)"
//                    guard let url = URL(string: urlString) else {
//                        return
//                    }
//                    let safariVC = SFSafariViewController(url: url)
//                    present(safariVC, animated: true, completion: nil)
//                }
            } else {
                let hasAllowAffiliate = Defaults.shared.currentUser?.isAllowAffiliate ?? false
                if hasAllowAffiliate {
                    self.setNavigation()
                } else {
                    guard let makeMoneyReferringVC = R.storyboard.onBoardingView.makeMoneyReferringViewController() else { return }
                    navigationController?.pushViewController(makeMoneyReferringVC, animated: true)
                }
            }
        } else {
            let storySettingsVC = R.storyboard.storyCameraViewController.storySettingsVC()!
            navigationController?.pushViewController(storySettingsVC, animated: true)
        }
    }
    
    @IBAction func incomeGoalConfirmConfirmPopupOkButtonClicked(_ sender: UIButton) {
        if let token = Defaults.shared.sessionToken {
             let urlString = "\(websiteUrl)/p-calculator-2?token=\(token)&redirect_uri=\(redirectUri)"
             guard let url = URL(string: urlString) else {
                 return
             }
             presentSafariBrowser(url: url)
         }
        incomeGoalConfirmPopupView.isHidden = true
    }
   
    func presentSafariBrowser(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
    
    func openPotentialIncomeCalculator(){
        if Defaults.shared.isShowAllPopUpChecked == true && Defaults.shared.isDoNotShowAgainOpenIncomeGoalPopup == false {
             incomeGoalConfirmPopupView.isHidden = false
            btnDoNotShowAgainincomeGoalConfirmPopup.isSelected = Defaults.shared.isDoNotShowAgainOpenIncomeGoalPopup
            self.view.bringSubviewToFront(incomeGoalConfirmPopupView)
          //  lblQuickLinkTooltipView.text = R.string.localizable.quickLinkTooltip(R.string.localizable.businessCenter(), Defaults.shared.currentUser?.channelId ?? "")
        }else{
        if let token = Defaults.shared.sessionToken {
             let urlString = "\(websiteUrl)/p-calculator-2?token=\(token)&redirect_uri=\(redirectUri)"
             guard let url = URL(string: urlString) else {
                 return
             }
             presentSafariBrowser(url: url)
         }
        }
    }
    
    @IBAction func doNotShowAgainIncomeGoalOpenPopupClicked(_ sender: UIButton) {
        btnDoNotShowAgainincomeGoalConfirmPopup.isSelected = !btnDoNotShowAgainincomeGoalConfirmPopup.isSelected
        Defaults.shared.isShowAllPopUpChecked = false
        Defaults.shared.isDoNotShowAgainOpenIncomeGoalPopup = btnDoNotShowAgainincomeGoalConfirmPopup.isSelected
       
    }
    @IBAction func didTapCloseButtonIncomeGoal(_ sender: UIButton) {
        incomeGoalConfirmPopupView.isHidden = true
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
