//
//  ReferSuccessVC.swift
//  SocialCAM
//
//  Created by ideveloper5 on 12/04/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class ReferSuccessVC: UIViewController {

    @IBOutlet weak var lblName: UILabel!
    var callback : ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblName.text = "Great Job \(Defaults.shared.currentUser?.firstName ?? "")👍🏻"
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
}
