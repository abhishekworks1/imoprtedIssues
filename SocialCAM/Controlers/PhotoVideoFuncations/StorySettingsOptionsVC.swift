//
//  StorySettingsOptionsVC.swift
//  ProManager
//
//  Created by Jasmin Patel on 27/07/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import GoogleSignIn

class StorySettingsOptionsVC: UIViewController {
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    var firstPercentage: Double = 0.0
    var firstUploadCompletedSize: Double = 0.0

    var settingsOptions = [R.string.localizable.professional(), R.string.localizable.logout()]
    
    var settingsOptionsImages = [R.image.icoStoryRecover(), R.image.icoStoryRecover()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    deinit {
        print("Deinit \(self.description)")
    }

    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension StorySettingsOptionsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.storySettingsCell.identifier, for: indexPath) as? StorySettingsCell else {
            fatalError("StorySettingsCell Not Found")
        }
        cell.settingsName.text = settingsOptions[indexPath.row]
        cell.onOffButton.setImage(settingsOptionsImages[indexPath.row], for: UIControl.State.normal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.isProEnable()
        case 1:
            self.logoutUser()
        default:
            break
        }
    }
    
    func isProEnable() {
        let objAlert = UIAlertController(title: Constant.Application.displayName, message: !Defaults.shared.isPro ? R.string.localizable.areYouSureYouWantToEnablePro() : R.string.localizable.areYouSureYouWantToDisablePro(), preferredStyle: .alert)
        if !Defaults.shared.isPro {
            objAlert.addTextField { (textField: UITextField) -> Void in
                textField.placeholder = R.string.localizable.enterCode()
            }
        }
        let actionSave = UIAlertAction(title: R.string.localizable.oK(), style: .default) { ( _: UIAlertAction) in
            if Defaults.shared.isPro {
                Defaults.shared.isPro = !Defaults.shared.isPro
                UIApplication.shared.setAlternateIconName("Icon-1") { error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("Success!")
                    }
                }
                self.navigationController?.popViewController(animated: true)
                return
            }
            if let textField = objAlert.textFields?[0],
                textField.text!.count > 0, textField.text?.lowercased() == Constant.Application.proModeCode {
                Defaults.shared.isPro = !Defaults.shared.isPro
                UIApplication.shared.setAlternateIconName("Icon-2") { error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("Success!")
                    }
                }
                self.navigationController?.popViewController(animated: true)
                return
            }
            self.view.makeToast(R.string.localizable.pleaseEnterValidCode())
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .default) { (_: UIAlertAction) in }
        objAlert.addAction(actionSave)
        objAlert.addAction(cancelAction)
        self.present(objAlert, animated: true, completion: nil)
    }
    
    func logoutUser() {
        let objAlert = UIAlertController(title: Constant.Application.displayName, message: R.string.localizable.areYouSureYouWantToLogout(), preferredStyle: .alert)
        let actionlogOut = UIAlertAction(title: R.string.localizable.logout(), style: .default) { (_: UIAlertAction) in
            TwitterShare.shared.logout()
            GIDSignIn.sharedInstance()?.disconnect()
            SnapKitManager.shared.unlink()
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .default) { (_: UIAlertAction) in }
        objAlert.addAction(actionlogOut)
        objAlert.addAction(cancelAction)
        self.present(objAlert, animated: true, completion: nil)
    }
}
