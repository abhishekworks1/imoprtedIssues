//
//  NotificationSettingsViewController.swift
//  SocialCAM
//
//  Created by Viraj Patel on 27/09/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit

class NotificationSettings {
    
    var name: String
    var settings: [StorySetting]
    var settingsType: SettingsMode
    
    init(name: String, settings: [StorySetting], settingsType: SettingsMode) {
        self.name = name
        self.settings = settings
        self.settingsType = settingsType
    }
    
    static var systemSettings = [StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.newSignups(), selected: false)], settingsType: .newSignupsNotificationSetting),
                                 StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.badgeEarned(), selected: false)], settingsType: .milestoneReachedNotification)]
}

class NotificationSettingsViewController: UIViewController {
    
    // MARK: - Outlets Declaration
    @IBOutlet weak var systemSettingsTableView: UITableView!
    
    
    
    // MARK: - View Life Cycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.systemSettingsTableView.reloadData()
        self.getReferralNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.systemSettingsTableView.reloadData()
    }
    
    // MARK: - Action Methods
    @IBAction func onBackPressed(_ sender: UIButton) {
        self.setReferralNotification()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnOkClicked(_ sender: UIButton) {
        self.setReferralNotification()
    }
    
}

// MARK: - Table View DataSource
extension NotificationSettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return NotificationSettings.systemSettings.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let settingTitle = NotificationSettings.systemSettings[section]
        return settingTitle.settings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let systemSettingsCell: SystemSettingsCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.systemSettingsCell.identifier) as? SystemSettingsCell else {
            fatalError("\(R.reuseIdentifier.systemSettingsCell.identifier) Not Found")
        }
        
        let settingTitle = NotificationSettings.systemSettings[indexPath.section]
        if settingTitle.settingsType == .newSignupsNotificationSetting {
            guard let notificationTypeCell: NotificationTypeCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.notificationTypeCell.identifier) as? NotificationTypeCell else {
                fatalError("\(R.reuseIdentifier.systemSettingsCell.identifier) Not Found")
            }
            notificationTypeCell.notificationType = .newSignups
            return notificationTypeCell
        } else if settingTitle.settingsType == .milestoneReachedNotification {
            systemSettingsCell.systemSettingType = .milestonesReached
        }
        return systemSettingsCell
    }
}

// MARK: - Table View Delegate
extension NotificationSettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
}

// MARK: - API Methods
extension NotificationSettingsViewController {
    
    func getReferralNotification() {
        self.showHUD()
        ProManagerApi.getReferralNotification.request(Result<GetReferralNotificationModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            self.dismissHUD()
            if response.status == ResponseType.success {
                if let cell = self.systemSettingsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? NotificationTypeCell, let numberOfUserText = response.result?.customSignupNumber {
                    cell.txtNumberOfUsers.text = "\(numberOfUserText)"
                }
                if let cell = self.systemSettingsTableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? SystemSettingsCell, let onReferralEarnSocialBadge = response.result?.onReferralEarnSocialBadge {
                    Defaults.shared.milestonesReached = onReferralEarnSocialBadge
                    cell.btnSelectShowAllPopup.isSelected = Defaults.shared.milestonesReached
                }
            } else {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            self.dismissHUD()
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: rx.disposeBag)
    }
    
    func setReferralNotification() {
        
        var numberOfUsers = 1
        if let cell = self.systemSettingsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? NotificationTypeCell, let numberOfUserText = cell.txtNumberOfUsers.text {
            numberOfUsers = Int(numberOfUserText) ?? 1
        }
        let isForEveryone = Defaults.shared.newSignupsNotificationType == .forAllUsers
        ProManagerApi.setReferralNotification(isForEveryone: isForEveryone, customSignupNumber: isForEveryone ? 0 : numberOfUsers, betweenCameraAppSubscription: 1, betweenBusinessDashboardSubscription: 1 ,isBadgeEarned: Defaults.shared.milestonesReached).request(Result<GetReferralNotificationModel>.self).subscribe(onNext: { [weak self] (response) in
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
