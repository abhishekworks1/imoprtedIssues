//
//  SubscriptionVC.swift
//  SocialCAM
//
//  Created by Viraj Patel on 01/07/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit
import UIKit

class SubscriptionSettings {
    
    var name: String
    var settings: [StorySetting]
    var settingsType: SettingsMode
    var isCollapsible: Bool {
        return true
    }
    var isCollapsed = false
    
    init(name: String, settings: [StorySetting], settingsType: SettingsMode) {
        self.name = name
        self.settings = settings
        self.settingsType = settingsType
    }
    
    static var storySettings = [StorySettings(name: R.string.localizable.subscriptions(),
                                              settings: [StorySetting(name: R.string.localizable.free(),
                                                                      selected: true),
                                                         StorySetting(name: (isLiteApp ? R.string.localizable.basicLite() :  R.string.localizable.basic()),
                                                                      selected: false),
                                                         StorySetting(name: R.string.localizable.advanced(),
                                                                      selected: true),
                                                         StorySetting(name: R.string.localizable.professional(),
                                                                      selected: true)], settingsType: .subscriptions)]
}

class SubscriptionVC: UIViewController {
    
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

extension SubscriptionVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SubscriptionSettings.storySettings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if SubscriptionSettings.storySettings[section].settingsType == .subscriptions {
            let item = SubscriptionSettings.storySettings[section]
            guard item.isCollapsible else {
                return SubscriptionSettings.storySettings[section].settings.count
            }
            if item.isCollapsed {
                return 0
            } else {
                return item.settings.count
            }
        }
        
        return SubscriptionSettings.storySettings[section].settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.storySettingsCell.identifier, for: indexPath) as? StorySettingsCell else {
            fatalError("\(R.reuseIdentifier.storySettingsCell.identifier) Not Found")
        }
        let settingTitle = SubscriptionSettings.storySettings[indexPath.section]
        let settings = settingTitle.settings[indexPath.row]
        cell.settingsName.text = settings.name
        cell.detailButton.isHidden = true
        cell.settingsName.textColor = R.color.appBlackColor()
        if settingTitle.settingsType == .subscriptions {
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
        guard let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.storySettingsHeader.identifier) as? StorySettingsHeader else {
            fatalError("StorySettingsHeader Not Found")
        }
        let settingTitle = SubscriptionSettings.storySettings[section]
        if settingTitle.settingsType != .subscriptions && settingTitle.settingsType != .appInfo {
            headerView.title.isHidden = true
        } else {
            headerView.title.isHidden = false
        }
        headerView.section = section
        headerView.delegate = self
        if settingTitle.settingsType == .subscriptions {
            headerView.collapsed = settingTitle.isCollapsed
            headerView.arrowLabel?.isHidden = false
            if Defaults.shared.appMode == .basic {
                headerView.title.text = settingTitle.name + " - \(Defaults.shared.appMode.description) Lite"
            } else {
                headerView.title.text = settingTitle.name + " - \(Defaults.shared.appMode.description)"
            }
        } else {
            headerView.title.text = settingTitle.name
            headerView.arrowLabel?.isHidden = true
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let settingTitle = SubscriptionSettings.storySettings[section]
        if settingTitle.settingsType == .subscriptions {
            return 60
        } else {
            return 24
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingTitle = SubscriptionSettings.storySettings[indexPath.section]
        if settingTitle.settingsType == .subscriptions {
            guard Defaults.shared.appMode.rawValue != indexPath.row else {
                return
            }
            self.enableMode(appMode: AppMode(rawValue: indexPath.row) ?? .free)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isLiteApp && (indexPath.row == 3 || indexPath.row == 2) {
            return 0
        }
        return UITableView.automaticDimension
    }
    
    func enableMode(appMode: AppMode) {
        var message: String? = ""
        let placeholder: String? = R.string.localizable.activationCode()
        var proModeCode: String? = Constant.Application.proModeCode
        #if PIC2ARTAPP
        switch appMode {
        case .professional:
            proModeCode = Constant.Application.pic2artProModeCode
        default:
            break
        }
        #endif
        var successMessage: String? = ""
        switch appMode {
        case .free:
            message = R.string.localizable.areYouSureYouWantToEnableFree()
            successMessage = R.string.localizable.freeModeIsEnabled()
        case .basic:
            if isLiteApp {
                message = R.string.localizable.enterTheCodeToActivateBasicLite()
                successMessage = R.string.localizable.basicLiteModeIsEnabled()
            } else {
                message = R.string.localizable.areYouSureYouWantToEnableBasic()
                successMessage = R.string.localizable.basicModeIsEnabled()
            }
        case .advanced:
            message = R.string.localizable.areYouSureYouWantToEnableAdvanced()
            successMessage = R.string.localizable.advancedModeIsEnabled()
        default:
            message = R.string.localizable.areYouSureYouWantToEnableProfessional()
            successMessage = R.string.localizable.professionalModeIsEnabled()
        }
        
        let objAlert = UIAlertController(title: Constant.Application.displayName, message: message, preferredStyle: .alert)
        if appMode != .free {
            objAlert.addTextField { (textField: UITextField) -> Void in
                if isDebug {
                    textField.text = proModeCode
                }
                textField.placeholder = placeholder
            }
        }
        
        let actionSave = UIAlertAction(title: R.string.localizable.oK(), style: .default) { ( _: UIAlertAction) in
            if appMode != .free {
                guard let textField = objAlert.textFields?.first,
                    textField.text?.count ?? 0 > 0 else {
                    Utils.customaizeToastMessage(title: R.string.localizable.pleaseEnterValidCode(), toastView: self.view)
                    return
                }
                if textField.text?.lowercased() != proModeCode {
                    Utils.customaizeToastMessage(title: R.string.localizable.pleaseEnterValidCode(), toastView: self.view)
                    return
                }
            }
            Defaults.shared.appMode = appMode
            SubscriptionSettings.storySettings[0].settings[appMode.rawValue].selected = true
            self.settingsTableView.reloadData()
            AppEventBus.post("changeMode")
            self.navigationController?.popViewController(animated: true)
            //Utils.appDelegate?.window?.makeToast(successMessage)
            Utils.appDelegate?.window?.currentController?.showAlert(alertMessage: successMessage ?? "")
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .default) { (_: UIAlertAction) in }
        objAlert.addAction(cancelAction)
        objAlert.addAction(actionSave)
        self.present(objAlert, animated: true, completion: nil)
    }
    
}

extension SubscriptionVC: HeaderViewDelegate {
    func toggleSection(header: StorySettingsHeader, section: Int) {
        let settingTitle = SubscriptionSettings.storySettings[section]
        if settingTitle.isCollapsible {

            // Toggle collapse
            let collapsed = !settingTitle.isCollapsed
            settingTitle.isCollapsed = collapsed
            self.settingsTableView?.reloadData()
        }
    }
}
