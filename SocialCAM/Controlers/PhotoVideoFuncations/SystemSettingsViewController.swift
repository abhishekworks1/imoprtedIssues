//
//  SystemSettingsViewController.swift
//  SocialCAM
//
//  Created by Meet Mistry on 28/07/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit
import CoreMedia

class SystemSettings {
    
    var name: String
    var settings: [StorySetting]
    var settingsType: SettingsMode
    
    init(name: String, settings: [StorySetting], settingsType: SettingsMode) {
        self.name = name
        self.settings = settings
        self.settingsType = settingsType
    }
    
    static var systemSettings = [
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.showAllPopups(), selected: false)], settingsType: .showAllPopups),
        
        StorySettings(name: "Default Opening Screen", settings: [StorySetting(name: "Welcome Screen", selected: false), StorySetting(name: "QuickStart Guide", selected: false), StorySetting(name: "QuickCam Camera", selected: false), StorySetting(name: "Mobile Dashboard", selected: false)], settingsType: .onboarding),
        
        
        StorySettings(name: "Haptic Feedback", settings: [
            StorySetting(name: R.string.localizable.all(), selected: false),
            StorySetting(name: R.string.localizable.some(), selected: false),
            StorySetting(name: R.string.localizable.none(), selected: false)], settingsType: .hapticFeedBack),
        ]
}

class SystemSettingsViewController: UIViewController {
    
    // MARK: - Outlets Declaration
    @IBOutlet weak var systemSettingsTableView: UITableView!
    
    // MARK: - View Life Cycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.systemSettingsTableView.register(R.nib.appSettingsHeaderCell)
        self.systemSettingsTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.systemSettingsTableView.reloadData()
    }
    
    func doNotShowAgainAPI() {
        if let cell: SystemSettingsCell = self.systemSettingsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SystemSettingsCell {
            ProManagerApi.doNotShowAgain(isDoNotShowMessage: cell.btnSelectShowAllPopup.isSelected).request(Result<LoginResult>.self).subscribe(onNext: { (response) in
            }, onError: { error in
                self.showAlert(alertMessage: error.localizedDescription)
            }, onCompleted: {
            }).disposed(by: rx.disposeBag)
        }
    }
    
    // MARK: - Action Methods
    @IBAction func onBackPressed(_ sender: UIButton) {
        self.doNotShowAgainAPI()
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - Table View DataSource
extension SystemSettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SystemSettings.systemSettings.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let settingTitle = SystemSettings.systemSettings[section]
        return settingTitle.settings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let systemSettingsCell: SystemSettingsCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.systemSettingsCell.identifier) as? SystemSettingsCell else {
            fatalError("\(R.reuseIdentifier.systemSettingsCell.identifier) Not Found")
        }
        
        systemSettingsCell.configureCell()
        
        let settingTitle = SystemSettings.systemSettings[indexPath.section]
        if settingTitle.settingsType == .showAllPopups {
            systemSettingsCell.systemSettingType = .showAllPopUps
        } else if settingTitle.settingsType == .newSignupsNotificationSetting {
            guard let notificationTypeCell: NotificationTypeCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.notificationTypeCell.identifier) as? NotificationTypeCell else {
                fatalError("\(R.reuseIdentifier.systemSettingsCell.identifier) Not Found")
            }
            notificationTypeCell.notificationType = .newSignups
            return notificationTypeCell
        } else if settingTitle.settingsType == .newSubscriptionNotificationSetting {
            guard let notificationTypeCell: NotificationTypeCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.notificationTypeCell.identifier) as? NotificationTypeCell else {
                fatalError("\(R.reuseIdentifier.systemSettingsCell.identifier) Not Found")
            }
            notificationTypeCell.notificationType = .newSubscriptions
            return notificationTypeCell
        } else if settingTitle.settingsType == .milestoneReachedNotification {
            systemSettingsCell.systemSettingType = .milestonesReached
        } else if settingTitle.settingsType == .checkUpdate {
            systemSettingsCell.title.isHidden = true
            systemSettingsCell.btnSelectShowAllPopup.isHidden = true
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.checkUpdatesTableViewCell.identifier) as? CheckUpdatesTableViewCell else {
                fatalError("\(R.reuseIdentifier.checkUpdatesTableViewCell.identifier) Not Found")
            }
            cell.lblCheckUpdate.text = R.string.localizable.checkUpdates()
            return cell
        } else if settingTitle.settingsType == .onboarding {
            systemSettingsCell.configureCellForSection(storySetting: SystemSettings.systemSettings[indexPath.section].settings[indexPath.row])
        } else if settingTitle.settingsType == .hapticFeedBack {
            systemSettingsCell.configureCellForSection(storySetting: SystemSettings.systemSettings[indexPath.section].settings[indexPath.row])
        }
        
        return systemSettingsCell
    }
}

// MARK: - Table View Delegate
extension SystemSettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        AppSettingHeaderCell
        guard let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.appSettingsHeaderCell.identifier) as? AppSettingsHeaderCell else {
            fatalError("\(R.reuseIdentifier.appSettingsHeaderCell.identifier) Not Found")
        }
        headerView.lblTitle.text = SystemSettings.systemSettings[section].name

        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let settingTitle = SystemSettings.systemSettings[indexPath.section].settings[indexPath.row].name
        let settingType = SystemSettingType(rawValue: settingTitle)

        
        if let systemSettingCell = tableView.cellForRow(at: indexPath) as? SystemSettingsCell {
            if systemSettingCell.isSubscriptionTrialOrExpired() == true {
                
                if settingType == .quickCamCamera || settingType == .mobileDashboard {
                    
                    self.showAlert()
                    return
                }
                
            }
            systemSettingCell.updateAppSettings()
        }
        
        if settingType == .showAllPopUps || settingType == .welcomeScreen || settingType == .quickMenu || settingType == .quickCamCamera || settingType == .mobileDashboard || settingType == .hapticAll || settingType == .hapticSome || settingType == .hapticNone {
            
            tableView.reloadData()
        }
    }
}

extension SystemSettingsViewController {
    
    func showAlert() {
        
        let alert = UIAlertController(title: "QuickCam", message: "You need to have an active subscription to use this feature. Upgrade now?", preferredStyle: .alert)
        let btnLater = UIAlertAction(title: "Later", style: .destructive, handler: nil)
        
        let btnYes = UIAlertAction(title: "Yes", style: .default) { alert in
            if let subscriptionVC = R.storyboard.subscription.subscriptionContainerViewController() {
                
                subscriptionVC.subscriptionDelegate = self
                self.navigationController?.pushViewController(subscriptionVC, animated: true)
            }
        }
        
        alert.addAction(btnLater)
        alert.addAction(btnYes)
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension SystemSettingsViewController: SubscriptionScreenDelegate {
    
    func backFromSubscription() {
        
        print("Function == \(#function) Line === \(#line)")
        self.systemSettingsTableView.reloadData()
    }
}
