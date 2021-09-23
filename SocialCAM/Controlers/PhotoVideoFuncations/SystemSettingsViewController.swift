//
//  SystemSettingsViewController.swift
//  SocialCAM
//
//  Created by Meet Mistry on 28/07/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit

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
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.newSignups(), selected: false)], settingsType: .newSignupsNotificationSetting),
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.milestonesReached(), selected: false)], settingsType: .milestoneReachedNotification),
    ]
}

class SystemSettingsViewController: UIViewController {
    
    // MARK: - Outlets Declaration
    @IBOutlet weak var systemSettingsTableView: UITableView!
    
    // MARK: - View Life Cycle method
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @IBAction func btnOkClicked(_ sender: UIButton) {
        self.setReferralNotification()
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
        }
        return systemSettingsCell
    }
}

// MARK: - Table View Delegate
extension SystemSettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.systemSettingsCell.identifier) as? SystemSettingsCell else {
            fatalError("\(R.reuseIdentifier.systemSettingsCell.identifier) Not Found")
        }
        headerView.title.isHidden = true
        headerView.btnSelectShowAllPopup.isHidden = true
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
}

// MARK: - API Methods
extension SystemSettingsViewController {
    
    func setReferralNotification() {
        var numberOfUsers = 1
        if let cell = self.systemSettingsTableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? NotificationTypeCell, let numberOfUserText = cell.txtNumberOfUsers.text {
            numberOfUsers = Int(numberOfUserText) ?? 1
        }
        let isForEveryone = Defaults.shared.newSignupsNotificationType == .forAllUsers
        ProManagerApi.setReferralNotification(isForEveryone: isForEveryone, customSignupNumber: isForEveryone ? 0 : numberOfUsers).request(Result<GetReferralNotificationModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            if response.status == ResponseType.success {
                Defaults.shared.newSignupsNotificationType = (response.result?.isForEveryone == true) ? .forAllUsers : .forLimitedUsers
                self.navigationController?.popViewController(animated: true)
            } else {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: rx.disposeBag)
    }
    
}
