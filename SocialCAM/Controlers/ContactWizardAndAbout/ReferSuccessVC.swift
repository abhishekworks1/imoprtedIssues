//
//  ReferSuccessVC.swift
//  SocialCAM
//
//  Created by ideveloper5 on 12/04/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit
import SafariServices

class ReferSuccessVC: UIViewController {

    @IBOutlet weak var switchOnOffTitle: UILabel!
    @IBOutlet weak var createContentBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mobileDashBoardBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var referBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var createContentDescriptionLabel: UILabel!
    @IBOutlet weak var createContentTitleLabel1: UILabel!
    @IBOutlet weak var mobileDashBoardDescriptionLabel: UILabel!
    @IBOutlet weak var mobileDashBoardTitleLabel1: UILabel!
    @IBOutlet weak var referMoreDescriptionLabel: UILabel!
    @IBOutlet weak var referMoreTitleLabel1: UILabel!
    @IBOutlet weak var createContentTitleLabel: UILabel!
    @IBOutlet weak var mobileDashBoardTitleLabel: UILabel!
    @IBOutlet weak var referMoreTitleLabel: UILabel!
    @IBOutlet weak var switchOnOffImageView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var businessDashboardStackView: UIStackView!
//    @IBOutlet weak var businessDashboardButton: UIButton!
    @IBOutlet weak var businessDashbardConfirmPopupView: UIView!
    @IBOutlet weak var btnDoNotShowAgainBusinessConfirmPopup: UIButton!
    var isFromOnboarding = false
    
    var callback : ((String) -> Void)?
    var isSwitchOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblName.text = "Great Job 👍🏻"//\(Defaults.shared.currentUser?.firstName ?? "") "
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapSwitchButton(_ sender: UIButton) {
        isSwitchOn = !isSwitchOn
        
        switch isSwitchOn {
        case true:
            switchOnOffTitle.text = "Select the feature to continue"
            switchOnOffImageView.image = R.image.shareSwitchOn()
            referMoreTitleLabel.isHidden = true
            mobileDashBoardTitleLabel.isHidden = true
            createContentTitleLabel.isHidden = true
            
            createContentDescriptionLabel.isHidden = false
            createContentTitleLabel1.isHidden = false
            mobileDashBoardDescriptionLabel.isHidden = false
            mobileDashBoardTitleLabel1.isHidden = false
            referMoreDescriptionLabel.isHidden = false
            referMoreTitleLabel1.isHidden = false
            
            createContentDescriptionLabel.text = "< createContentDescription >"
            mobileDashBoardDescriptionLabel.text = "< mobileDashBoardDescription >"
            referMoreDescriptionLabel.text = "< referMoreDescription >"
            
            createContentBottomConstraint.constant = 15
            mobileDashBoardBottomConstraint.constant = 15
            referBottomConstraint.constant = 15
            
        case false:
            switchOnOffTitle.text = "What would you like to do next?"
            switchOnOffImageView.image = R.image.shareSwitchOff()
            referMoreTitleLabel.isHidden = false
            mobileDashBoardTitleLabel.isHidden = false
            createContentTitleLabel.isHidden = false
            
            createContentDescriptionLabel.isHidden = true
            createContentTitleLabel1.isHidden = true
            mobileDashBoardDescriptionLabel.isHidden = true
            mobileDashBoardTitleLabel1.isHidden = true
            referMoreDescriptionLabel.isHidden = true
            referMoreTitleLabel1.isHidden = true
            
            createContentBottomConstraint.constant = 0
            mobileDashBoardBottomConstraint.constant = 0
            referBottomConstraint.constant = 0
            
        default:
            break
        }
    }
    

    @IBAction func BusinessDashboardAction(_ sender: Any) {
       // openBussinessDashboard()
        let storySettingsVC = R.storyboard.storyCameraViewController.storySettingsVC()!
        navigationController?.pushViewController(storySettingsVC, animated: true)
    }
    @IBAction func ReferMoreAction(_ sender: Any) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: ContactImportVC.self) {
                callback?("navigate to Page1")
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    @IBAction func CreateContentAction(_ sender: Any) {
        if let viewControllers = self.navigationController?.viewControllers
        {
            if viewControllers.contains(where: {
                return $0 is StoryCameraViewController
            })
            {
                navigationController?.popToViewController(ofClass: StoryCameraViewController.self)
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    @IBAction func ContinueAction(_ sender: Any) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: StorySettingsVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            } else if controller.isKind(of: OnBoardingViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
        /*if self.isFromOnboarding {
            let rootViewController: UIViewController? = R.storyboard.pageViewController.pageViewController()
            Utils.appDelegate?.window?.rootViewController = rootViewController
        } else {
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: StorySettingsVC.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }*/
    }
    @IBAction func backAction(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        if viewControllers.count >= 3 {
          self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        } else {
            self.navigationController!.popToRootViewController(animated: true)

        }
    }
    @IBAction func businessDahboardConfirmPopupOkButtonClicked(_ sender: UIButton) {
        
        if let token = Defaults.shared.sessionToken {
//            let urlString = "\(websiteUrl)/redirect?token=\(token)"
            let urlString = "\(websiteUrl)/redirect?token=\(token)"
            guard let url = URL(string: urlString) else {
                return
            }
            presentSafariBrowser(url: url)
        }
        Defaults.shared.callHapticFeedback(isHeavy: false)
        Defaults.shared.addEventWithName(eventName: Constant.EventName.cam_Bdashboard)
        
        businessDashbardConfirmPopupView.isHidden = true
    }
    @IBAction func doNotShowAgainBusinessCenterOpenPopupClicked(_ sender: UIButton) {
        btnDoNotShowAgainBusinessConfirmPopup.isSelected = !btnDoNotShowAgainBusinessConfirmPopup.isSelected
        Defaults.shared.isShowAllPopUpChecked = false
        Defaults.shared.isDoNotShowAgainOpenBusinessCenterPopup = btnDoNotShowAgainBusinessConfirmPopup.isSelected
       
    }
    @IBAction func didTapCloseButtonBusiessDashboard(_ sender: UIButton) {
        businessDashbardConfirmPopupView.isHidden = true
       
    }
    func presentSafariBrowser(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
    func openBussinessDashboard(){
        if Defaults.shared.isShowAllPopUpChecked == true && Defaults.shared.isDoNotShowAgainOpenBusinessCenterPopup == false {
            
          
         //   businessDashbardConfirmPopupView.isHidden = false
         //   btnDoNotShowAgainBusinessConfirmPopup.isSelected = Defaults.shared.isDoNotShowAgainOpenBusinessCenterPopup
//            self.view.bringSubviewToFront(businessDashbardConfirmPopupView)
          //  lblQuickLinkTooltipView.text = R.string.localizable.quickLinkTooltip(R.string.localizable.businessCenter(), Defaults.shared.currentUser?.channelId ?? "")
        }else{
            if let token = Defaults.shared.sessionToken {
                 let urlString = "\(websiteUrl)/redirect?token=\(token)"
                 guard let url = URL(string: urlString) else {
                     return
                 }
                 presentSafariBrowser(url: url)
             }
             Defaults.shared.callHapticFeedback(isHeavy: false,isImportant: true)
             Defaults.shared.addEventWithName(eventName: Constant.EventName.cam_Bdashboard)
        }
    }
}
