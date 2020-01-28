//
//  StorySettingsVC.swift
//  ProManager
//
//  Created by Jasmin Patel on 21/06/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import GoogleSignIn

class StorySetting {
    var name: String
    var selected: Bool
    
    init(name: String, selected: Bool) {
        self.name = name
        self.selected = selected
    }
}

class StorySettings {
    
    var name: String
    var settings: [StorySetting]
    
    init(name: String, settings: [StorySetting]) {
        self.name = name
        self.settings = settings
    }
    
    static var storySettings = [StorySettings(name: R.string.localizable.mode(),
                                              settings: [StorySetting(name: R.string.localizable.free(),
                                                                      selected: true),
                                                         StorySetting(name: R.string.localizable.basic(),
                                                                      selected: false),
                                                         StorySetting(name: R.string.localizable.advanced(),
                                                                      selected: true),
                                                         StorySetting(name: R.string.localizable.professional(),
                                                                      selected: true)]),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.logout(), selected: false)])]
    
}

class StorySettingsVC: UIViewController {
    
    @IBOutlet weak var settingsTableView: UITableView!
    
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

extension StorySettingsVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return StorySettings.storySettings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StorySettings.storySettings[section].settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StorySettingsCell", for: indexPath) as? StorySettingsCell else {
            fatalError("StorySettingsCell Not Found")
        }
        let settings = StorySettings.storySettings[indexPath.section].settings[indexPath.row]
        cell.settingsName.text = settings.name
        cell.detailButton.isHidden = true
        if indexPath.section == 1 {
            cell.onOffButton.isHidden = true
        } else {
            cell.onOffButton.isHidden = false
            if indexPath.row == Defaults.shared.appMode.rawValue {
                cell.onOffButton.isSelected = true
            } else {
                cell.onOffButton.isSelected = false
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableCell(withIdentifier: "StorySettingsHeader") as? StorySettingsHeader else {
            fatalError("StorySettingsHeader Not Found")
        }
        if section == 1 {
            headerView.title.isHidden = true
        } else {
            headerView.title.isHidden = false
        }
        headerView.title.text = StorySettings.storySettings[section].name
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 24
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            logoutUser()
        }
        guard indexPath.section == 0 && Defaults.shared.appMode.rawValue != indexPath.row else {
            return
        }
        if indexPath.row == 0 {
            Defaults.shared.appMode = .free
            self.settingsTableView.reloadData()
            UIApplication.shared.setAlternateIconName("Icon-2") { error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Success!")
                }
            }
        } else if indexPath.row == 3 {
            isProEnable()
        }
    }
    
    func isProEnable() {
        let objAlert = UIAlertController(title: Constant.Application.displayName, message: R.string.localizable.areYouSureYouWantToEnablePro(), preferredStyle: .alert)
        objAlert.addTextField { (textField: UITextField) -> Void in
            #if DEBUG
            textField.text = Constant.Application.proModeCode
            #endif
            textField.placeholder = R.string.localizable.enterCode()
        }
        let actionSave = UIAlertAction(title: R.string.localizable.oK(), style: .default) { ( _: UIAlertAction) in
            if let textField = objAlert.textFields?[0],
                textField.text!.count > 0, textField.text?.lowercased() == Constant.Application.proModeCode {
                Defaults.shared.appMode = .professional
                StorySettings.storySettings[0].settings[3].selected = true
                self.settingsTableView.reloadData()
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
            self.settingsTableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .default) { (_: UIAlertAction) in }
        objAlert.addAction(actionlogOut)
        objAlert.addAction(cancelAction)
        self.present(objAlert, animated: true, completion: nil)
    }
}
