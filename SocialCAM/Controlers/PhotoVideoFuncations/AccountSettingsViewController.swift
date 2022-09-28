//
//  AccountSettingsViewController.swift
//  SocialCAM
//
//  Created by Meet Mistry on 03/08/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit
import Alamofire

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
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.pleaseEnterEmail(), selected: false)], settingsType: .email),
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.displayName(), selected: false)], settingsType: .publicDisplayName),
        StorySettings(name: "", settings: [StorySetting(name: "Channel Name Display", selected: false)], settingsType: .channelDisplayName),
        StorySettings(name: "", settings: [StorySetting(name: "Delete my account?", selected: false)], settingsType: .deleteAccount)
    ]
    //StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.privateDisplayName(), selected: false)], settingsType: .privateDisplayName), // Hide Private name for boomicam
}

class AccountSettingsViewController: UIViewController, DisplayTooltiPDelegate {
    
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
    var easyTipView: EasyTipView?
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accountSettingsTableView.reloadData()
        self.setupEasyTipView()
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
            Utils.customaizeToastMessage(title: R.string.localizable.noChangesMade(), toastView: self.view)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func onDisplayNameOkPressed(_ sender: UIButton) {
        self.displayNameTooltipView.isHidden = true
    }
    
    func setupEasyTipView() {
        var preferences = EasyTipView.Preferences()
        preferences.drawing.font = UIFont.systemFont(ofSize: 12)
        preferences.drawing.textAlignment = .left
        preferences.drawing.foregroundColor = UIColor.white
        preferences.drawing.backgroundColor = UIColor(red: 0, green: 125/255, blue: 255/255, alpha: 1.0)
        preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.left
        EasyTipView.globalPreferences = preferences
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
            accountSettingsCell.imgSettingIcon.image = R.image.storyDelete()?.withRenderingMode(.alwaysTemplate)
            accountSettingsCell.imgSettingIcon.tintColor = R.color.labelError()
        } else if settingTitle.settingsType == .publicDisplayName || settingTitle.settingsType == .privateDisplayName || settingTitle.settingsType == .email || settingTitle.settingsType == .channelDisplayName {
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
            }else if settingTitle.settingsType == .email {
                displayNameCell.displayNameType = .emailAddress
            } else if settingTitle.settingsType == .channelDisplayName {
                displayNameCell.displayNameType = .channelDisplayName
            }
            displayNameCell.txtDisplaName.alpha = settingTitle.settingsType == .email ? 0.5 : 1
            displayNameCell.txtDisplaName.isUserInteractionEnabled = !(settingTitle.settingsType == .email)
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
        } else if settingTitle.settingsType == .publicDisplayName || settingTitle.settingsType == .privateDisplayName || settingTitle.settingsType == .email || settingTitle.settingsType == .channelDisplayName {
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
            lblPopup.text = "Are you sure you want to delete your account?"
            showHideButtonView(isHide: true)
            popupView.isHidden = false
        } else if settingTitle.settingsType == .referringChannelName {
            if let userDetailsVC = R.storyboard.notificationVC.userDetailsVC() {
                MIBlurPopup.show(userDetailsVC, on: self)
            }
        }
    }
    
    func removeDeviceToken() {
        if let deviceToken = Defaults.shared.deviceToken {
            ProManagerApi.removeToken(deviceToken: deviceToken).request(Result<RemoveTokenModel>.self).subscribe(onNext: { [weak self] (response) in
                guard let `self` = self else {
                    return
                }
                if response.status != ResponseType.success {
                    self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
                }
            }, onError: { error in
                self.showAlert(alertMessage: error.localizedDescription)
            }, onCompleted: {
            }).disposed(by: rx.disposeBag)
        }
    }
    
    func deleteUserAccount() {
        let path = API.shared.baseUrlV2 + "user/me"
        let headerWithToken : HTTPHeaders =  ["Content-Type": "application/json",
                                              "userid": Defaults.shared.currentUser?.id ?? "",
                                              "deviceType": "1",
                                              "platformType": "ios",
                                              "x-access-token": Defaults.shared.sessionToken ?? ""]
        let request = AF.request(path, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headerWithToken, interceptor: nil)
        request.responseDecodable(of: TipOfDayResponse.self) {(resposnse) in
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
            self.removeDeviceToken()
            if let loginNav = R.storyboard.loginViewController.loginNavigation() {
               // Defaults.shared.clearData()
                Utils.appDelegate?.window?.rootViewController = loginNav
            }
        }
        
//        ProManagerApi.userDelete.request(Result<EmptyModel>.self).subscribe(onNext: { (response) in
//            if response.status == ResponseType.success {
//                StoriCamManager.shared.logout()
//                TwitterManger.shared.logout()
//                GoogleManager.shared.logout()
//                FaceBookManager.shared.logout()
//                InstagramManager.shared.logout()
//                SnapKitManager.shared.logout { _ in
//
//                }
//                if #available(iOS 13.0, *) {
//                    AppleSignInManager.shared.logout()
//                }
//                self.accountSettingsTableView.reloadData()
//                if let loginNav = R.storyboard.loginViewController.loginNavigation() {
//                    Defaults.shared.clearData(isDeleteAccount: true)
//                    Utils.appDelegate?.window?.rootViewController = loginNav
//                }
//            } else {
//                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
//            }
//            self.popupView.isHidden = true
//        }, onError: { error in
//            self.popupView.isHidden = true
//            self.showAlert(alertMessage: error.localizedDescription)
//        }, onCompleted: {
//        }).disposed(by: self.rx.disposeBag)
    }
    
    func editDisplayName() {
        var publicDisplayName = ""
        var privateDisplayName = ""
        var emailAddress = ""
        if let cell = self.accountSettingsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? DisplayNameTableViewCell {
            emailAddress = cell.txtDisplaName.text ?? ""
        }
        if let cell = self.accountSettingsTableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? DisplayNameTableViewCell {
            publicDisplayName = cell.txtDisplaName.text ?? ""
        }
//        if let cell = self.accountSettingsTableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DisplayNameTableViewCell {
//            privateDisplayName = cell.txtDisplaName.text ?? ""
//        }
        ProManagerApi.editDisplayName(publicDisplayName: publicDisplayName, privateDisplayName: privateDisplayName).request(Result<EmptyModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            if response.status == ResponseType.success {
                self.storyCameraVC.syncUserModel { _ in
                    Utils.customaizeToastMessage(title: "Account updated.", toastView: self.view)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        // Do whatever you want
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            self.dismissHUD()
        }, onError: { error in
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
}

extension AccountSettingsViewController {
    
    func displayTooltip(index: Int, cell: DisplayNameTableViewCell) {
        self.displayNameTooltipView.isHidden = true
//        self.easyTipView?.dismiss()
        if index == 0 {
            self.showEasyTipView(string: R.string.localizable.emailTooltip(), forview: cell.btnDisplayNameTooltipIcon, superView: cell.contentView)
            
        }else if index == 1 {
            
            self.showEasyTipView(string: R.string.localizable.publicDisplayNameTooltip(), forview: cell.btnDisplayNameTooltipIcon, superView: cell.contentView)
            
        } else if index == 2 {
            
            self.showEasyTipView(string: R.string.localizable.channelDisplayNameTooltip(), forview: cell.btnDisplayNameTooltipIcon, superView: cell.contentView)
        }
    }
    func displayTextAlert(string:String, cell: DisplayNameTableViewCell){
        self.showAlert(alertMessage: string)
    }
    
    func showEasyTipView(string: String, forview: UIView, superView: UIView) {
        if self.easyTipView != nil {
            self.easyTipView?.dismiss()
        }
        self.easyTipView = EasyTipView(text: string)
        
        self.easyTipView!.show(animated: true, forView: forview, withinSuperview: superView)
    }
}

extension AccountSettingsViewController:EasyTipViewDelegate {
    
    func easyTipViewDidTap(_ tipView: EasyTipView) {
        tipView.dismiss()
    }
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        
    }
}
