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
    
    
    var callback : ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblName.text = "Great Job \(Defaults.shared.currentUser?.firstName ?? "") 👍🏻"
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
        businessDashbardConfirmPopupView.isHidden = false
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
        self.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func ContinueAction(_ sender: Any) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: StorySettingsVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    @IBAction func businessDahboardConfirmPopupOkButtonClicked(_ sender: UIButton) {
        
        if let token = Defaults.shared.sessionToken {
//            let urlString = "\(websiteUrl)/redirect?token=\(token)"
            let urlString = "\(websiteUrl)/share-wizard"
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
    
}