//
//  AccountSettingsViewController.swift
//  SocialCAM
//
//  Created by Meet Mistry on 03/08/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit

class AccountSettings {
    
    var name: String
    var settings: [StorySetting]
    var settingsType: SettingsMode
    
    init(name: String, settings: [StorySetting], settingsType: SettingsMode) {
        self.name = name
        self.settings = settings
        self.settingsType = settingsType
    }
    
    static var accountSettings = [
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.referringChannelName(), selected: false)], settingsType: .referringChannelName),
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.subscription(), selected: false)], settingsType: .subscription),
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.skipYoutubeLogin(), selected: false)], settingsType: .skipYoutubeLogin),
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.deleteAccount(), selected: false)], settingsType: .deleteAccount)
    ]
}

class AccountSettingsViewController: UIViewController {
    
    // MARK: - Outlets Declaration
    @IBOutlet weak var accountSettingsTableView: UITableView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var lblPopup: UILabel!
    @IBOutlet weak var doubleButtonStackView: UIStackView!
    @IBOutlet weak var singleButtonSttackView: UIStackView!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accountSettingsTableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if Defaults.shared.isSkipYoutubeLogin == false {
            if GoogleManager.shared.isUserLogin {
                GoogleManager.shared.logout()
            }
        }
    }
    
    func showHideButtonView(isHide: Bool) {
        self.singleButtonSttackView.isHidden = isHide
        self.doubleButtonStackView.isHidden = !isHide
    }
    
    // MARK: - Action Method
    @IBAction func onBackPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func onYesPressed(_ sender: UIButton) {
        self.deleteUserAccount()
    }
    @IBAction func onNoPressed(_ sender: UIButton) {
        popupView.isHidden = true
    }
    @IBAction func onOkPressed(_ sender: UIButton) {
        popupView.isHidden = true
        if let subscriptionVC = R.storyboard.subscription.subscriptionContainerViewController() {
            navigationController?.pushViewController(subscriptionVC, animated: true)
        }
    }
}

// MARK: - Table View DataSource
extension AccountSettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return AccountSettings.accountSettings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let settingTitle = AccountSettings.accountSettings[section]
        if settingTitle.settingsType == .skipYoutubeLogin {
            return 1
        } else {
            return settingTitle.settings.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let accountSettingsCell: AccountSettingsCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.accountSettingsCell.identifier) as? AccountSettingsCell else {
            fatalError("\(R.reuseIdentifier.accountSettingsCell.identifier) Not Found")
        }
        
        let settingTitle = AccountSettings.accountSettings[indexPath.section]
        let settings = settingTitle.settings[indexPath.row]
        accountSettingsCell.title.text = settings.name
        
        if settingTitle.settingsType == .referringChannelName {
            if let refferingChannel = Defaults.shared.currentUser?.refferingChannel {
                accountSettingsCell.title.text = R.string.localizable.referringChannel(refferingChannel)
            }
        } else if settingTitle.settingsType == .deleteAccount {
            accountSettingsCell.title.textColor = R.color.labelError()
        } else if settingTitle.settingsType == .skipYoutubeLogin {
            guard let systemSettingsCell: SystemSettingsCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.systemSettingsCell.identifier) as? SystemSettingsCell else {
                fatalError("\(R.reuseIdentifier.systemSettingsCell.identifier) Not Found")
            }
            if settingTitle.settingsType == .skipYoutubeLogin {
                systemSettingsCell.systemSettingType = .skipYoutubeLogin
            }
            return systemSettingsCell
        }
        
        return accountSettingsCell
    }
}

// MARK: - Table View Delegate
extension AccountSettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.storySettingsHeader.identifier) as? StorySettingsHeader else {
            fatalError("StorySettingsHeader Not Found")
        }
        headerView.title.isHidden = true
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let settingTitle = AccountSettings.accountSettings[section]
        if settingTitle.settingsType == .deleteAccount {
            return 40
        } else {
            return 20
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingTitle = AccountSettings.accountSettings[indexPath.section]
        if settingTitle.settingsType == .subscription {
            if Defaults.shared.allowFullAccess == true {
                lblPopup.text = R.string.localizable.freeDuringBetaTest()
                showHideButtonView(isHide: false)
                popupView.isHidden = false
            } else {
                if let subscriptionVC = R.storyboard.subscription.subscriptionContainerViewController() {
                    navigationController?.pushViewController(subscriptionVC, animated: true)
                }
            }
        } else if settingTitle.settingsType == .deleteAccount {
            lblPopup.text = R.string.localizable.areYouSureYouWantToDeactivateYourAccount()
            showHideButtonView(isHide: true)
            popupView.isHidden = false
        }
    }
    
    func deleteUserAccount() {
        ProManagerApi.userDelete.request(Result<EmptyModel>.self).subscribe(onNext: { (response) in
            if response.status == ResponseType.success {
                StoriCamManager.shared.logout()
                TwitterManger.shared.logout()
                GoogleManager.shared.logout()
                FaceBookManager.shared.logout()
                InstagramManager.shared.logout()
                SnapKitManager.shared.logout { _ in
                
                }
                if #available(iOS 13.0, *) {
                    AppleSignInManager.shared.logout()
                }
                self.accountSettingsTableView.reloadData()
                if let loginNav = R.storyboard.loginViewController.loginNavigation() {
                    Defaults.shared.clearData(isDeleteAccount: true)
                    Utils.appDelegate?.window?.rootViewController = loginNav
                }
            } else {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
            self.popupView.isHidden = true
        }, onError: { error in
            self.popupView.isHidden = true
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
}
