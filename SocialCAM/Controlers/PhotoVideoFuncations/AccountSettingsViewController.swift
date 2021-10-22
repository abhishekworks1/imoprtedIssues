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
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.publicDisplayName(), selected: false)], settingsType: .publicDisplayName),
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.privateDisplayName(), selected: false)], settingsType: .privateDisplayName),
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.deleteAccount(Constant.Application.displayName), selected: false)], settingsType: .deleteAccount)
    ]
}

class AccountSettingsViewController: UIViewController {
    
    // MARK: - Outlets Declaration
    @IBOutlet weak var accountSettingsTableView: UITableView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var lblPopup: UILabel!
    @IBOutlet weak var doubleButtonStackView: UIStackView!
    @IBOutlet weak var singleButtonSttackView: UIStackView!
    @IBOutlet weak var displayNameTooltipView: UIView!
    @IBOutlet weak var lblDisplayNameTooltip: UILabel!
    
    // MARK: - Variable Declarations
    var isDisplayNameChange = false
    private lazy var storyCameraVC = StoryCameraViewController()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accountSettingsTableView.reloadData()
    }
    
    func showHideButtonView(isHide: Bool) {
        self.singleButtonSttackView.isHidden = isHide
        self.doubleButtonStackView.isHidden = !isHide
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.isDisplayNameChange = true
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
    @IBAction func onDonePressed(_ sender: UIButton) {
        if isDisplayNameChange {
            self.showHUD()
            self.editDisplayName()
        } else {
            self.view.makeToast(R.string.localizable.noChangesMade())
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func onDisplayNameOkPressed(_ sender: UIButton) {
        self.displayNameTooltipView.isHidden = true
    }
}

// MARK: - Table View DataSource
extension AccountSettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return AccountSettings.accountSettings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let settingTitle = AccountSettings.accountSettings[section]
        return settingTitle.settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let accountSettingsCell: AccountSettingsCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.accountSettingsCell.identifier) as? AccountSettingsCell else {
            fatalError("\(R.reuseIdentifier.accountSettingsCell.identifier) Not Found")
        }
        
        let settingTitle = AccountSettings.accountSettings[indexPath.section]
        let settings = settingTitle.settings[indexPath.row]
        accountSettingsCell.title.text = settings.name
        
        if settingTitle.settingsType == .referringChannelName {
            guard let referringChannelNameCell: ReferringChannelNameCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.referringChannelNameCell.identifier) as? ReferringChannelNameCell else {
                return accountSettingsCell
            }
            referringChannelNameCell.lblReferringChannelTitle.text = R.string.localizable.referringChannelName()
            if let name = Defaults.shared.currentUser?.refferingChannel {
                referringChannelNameCell.lblChannelName.text = R.string.localizable.referringChannel(name)
            }
            if let userImageUrl = Defaults.shared.currentUser?.refferedBy?.profileImageURL {
                referringChannelNameCell.userImageView.layer.cornerRadius = referringChannelNameCell.userImageView.bounds.width / 2
                referringChannelNameCell.userImageView.sd_setImage(with: URL.init(string: userImageUrl), placeholderImage: ApplicationSettings.userPlaceHolder)
            } else {
                referringChannelNameCell.userImageView.layer.cornerRadius = referringChannelNameCell.userImageView.bounds.width / 2
                referringChannelNameCell.userImageView.sd_setImage(with: URL.init(string: ""), placeholderImage: ApplicationSettings.userPlaceHolder)
            }
            if let socialPlatForms = Defaults.shared.referredByData?.socialPlatforms {
                referringChannelNameCell.imgSocialMediaBadge.isHidden = socialPlatForms.count != 4
            }
            return referringChannelNameCell
        } else if settingTitle.settingsType == .deleteAccount {
            accountSettingsCell.title.textColor = R.color.labelError()
            accountSettingsCell.imgSettingIcon.image = R.image.iconAccountDelete()
        } else if settingTitle.settingsType == .publicDisplayName || settingTitle.settingsType == .privateDisplayName {
            guard let displayNameCell: DisplayNameTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.displayNameTableViewCell.identifier) as? DisplayNameTableViewCell else {
                return accountSettingsCell
            }
            displayNameCell.txtDisplaName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            displayNameCell.btnDisplayNameTooltipIcon.tag = indexPath.section
            displayNameCell.displayTooltipDelegate = self
            if settingTitle.settingsType == .publicDisplayName {
                displayNameCell.displayNameType = .publicDisplayName
            } else if settingTitle.settingsType == .privateDisplayName {
                displayNameCell.displayNameType = .privateDisplayName
            }
            return displayNameCell
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
        } else if settingTitle.settingsType == .referringChannelName {
            return 10
        } else {
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return AccountSettings.accountSettings[section].settingsType == .referringChannelName ? 10.0 : 1.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let settingTitle = AccountSettings.accountSettings[indexPath.section]
        if settingTitle.settingsType == .referringChannelName {
            return 60
        } else if settingTitle.settingsType == .publicDisplayName || settingTitle.settingsType == .privateDisplayName {
            return 94
        } else {
            return 40
        }
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
        } else if settingTitle.settingsType == .referringChannelName {
            if let userDetailsVC = R.storyboard.notificationVC.userDetailsVC() {
                MIBlurPopup.show(userDetailsVC, on: self)
            }
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
    
    func editDisplayName() {
        var publicDisplayName = ""
        var privateDisplayName = ""
        if let cell = self.accountSettingsTableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? DisplayNameTableViewCell {
            publicDisplayName = cell.txtDisplaName.text ?? ""
        }
        if let cell = self.accountSettingsTableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DisplayNameTableViewCell {
            privateDisplayName = cell.txtDisplaName.text ?? ""
        }
        ProManagerApi.editDisplayName(publicDisplayName: publicDisplayName, privateDisplayName: privateDisplayName).request(Result<EmptyModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            if response.status == ResponseType.success {
                self.storyCameraVC.syncUserModel { _ in
                    self.navigationController?.popViewController(animated: true)
                }
            }
            self.dismissHUD()
        }, onError: { error in
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
}

extension AccountSettingsViewController: DisplayTooltiPDelegate {
    
    func displayTooltip(index: Int) {
        self.displayNameTooltipView.isHidden = false
        if index == 0 {
            self.lblDisplayNameTooltip.text = R.string.localizable.publicDisplayNameTooltip()
        } else if index == 1 {
            self.lblDisplayNameTooltip.text = R.string.localizable.privateDisplayNameTooltip()
        }
    }
}
