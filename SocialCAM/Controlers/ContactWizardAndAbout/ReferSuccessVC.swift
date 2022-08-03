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

    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var businessDashboardStackView: UIStackView!
//    @IBOutlet weak var businessDashboardButton: UIButton!
    @IBOutlet weak var businessDashbardConfirmPopupView: UIView!
    @IBOutlet weak var btnDoNotShowAgainBusinessConfirmPopup: UIButton!
    var isFromOnboarding = false
    
    var callback : ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblName.text = "Great Job 👍🏻"//\(Defaults.shared.currentUser?.firstName ?? "") "
        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
            } else if controller.isKind(of: QuickStartOptionDetailViewController.self) {
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
