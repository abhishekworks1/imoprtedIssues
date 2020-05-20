//
//  StorySettingsVC.swift
//  ProManager
//
//  Created by Jasmin Patel on 21/06/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import GoogleSignIn

enum SettingsMode: Int {
    case subscriptions = 0
    case socialLogins
    case faceDetection
    case swapeContols
    case cameraSettings
    case socialConnections
    case channelManagement
    case socialLogout
    case logout
    case controlcenter
    case video
    case appInfo
}

class StorySetting {
    var name: String
    var selected: Bool
    var image: UIImage?
    var selectedImage: UIImage?
    
    init(name: String, selected: Bool, image: UIImage? = UIImage(), selectedImage: UIImage? = UIImage()) {
        self.name = name
        self.selected = selected
        self.image = image
        self.selectedImage = selectedImage
    }
}

class StorySettings {
    
    var name: String
    var settings: [StorySetting]
    var settingsType: SettingsMode
    
    init(name: String, settings: [StorySetting], settingsType: SettingsMode) {
        self.name = name
        self.settings = settings
        self.settingsType = settingsType
    }
    
    static var storySettings = [StorySettings(name: R.string.localizable.subscriptions(),
                                              settings: [StorySetting(name: R.string.localizable.free(),
                                                                      selected: true),
                                                         StorySetting(name: R.string.localizable.basic(),
                                                                      selected: false),
                                                         StorySetting(name: R.string.localizable.advanced(),
                                                                      selected: true),
                                                         StorySetting(name: R.string.localizable.professional(),
                                                                      selected: true)], settingsType: .subscriptions),
//                                StorySettings(name: "",
//                                    settings: [StorySetting(name: "Face Detection", selected: false)], settingsType: .faceDetection),
//                                StorySettings(name: "",
//                                              settings: [StorySetting(name: "Change positions of\nMute,switching camera", selected: false)], settingsType: .swapeContols),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: "Camera Settings", selected: false)], settingsType: .cameraSettings),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.socialConnections(), selected: false)], settingsType: .socialConnections),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.channelManagement(), selected: false)], settingsType: .channelManagement),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.logout(), selected: false)], settingsType: .logout),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.controlCenter(), selected: false)], settingsType: .controlcenter),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: "\(Constant.Application.displayName) v \(Constant.Application.appVersion) (Build \(Constant.Application.appBuildNumber))", selected: false)], settingsType: .appInfo)]
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.storySettingsCell.identifier, for: indexPath) as? StorySettingsCell else {
            fatalError("\(R.reuseIdentifier.storySettingsCell.identifier) Not Found")
        }
        let settingTitle = StorySettings.storySettings[indexPath.section]
        let settings = settingTitle.settings[indexPath.row]
        cell.settingsName.text = settings.name
        cell.detailButton.isHidden = true
        cell.settingsName.textColor = R.color.appBlackColor()
        if settingTitle.settingsType == .controlcenter || settingTitle.settingsType == .logout || settingTitle.settingsType == .socialLogout || settingTitle.settingsType == .socialConnections || settingTitle.settingsType == .channelManagement || settingTitle.settingsType == .appInfo || settingTitle.settingsType == .video || settingTitle.settingsType == .cameraSettings{
            if settingTitle.settingsType == .appInfo {
                #if DEBUG
                cell.settingsName.textColor = R.color.appPrimaryColor()
                #endif
            }
            cell.onOffButton.isHidden = true
        } else if settingTitle.settingsType == .socialLogins {
            cell.onOffButton.isHidden = true
            cell.onOffButton.isSelected = false
            cell.socialImageView?.isHidden = false
            cell.socialImageView?.image = cell.onOffButton.isSelected ? settings.selectedImage : settings.image
            
            let socialLogin: SocialLogin = SocialLogin(rawValue: indexPath.row) ?? .facebook
            self.socialLoadProfile(socialLogin: socialLogin) { [weak cell] (userName, socialId) in
                guard let cell = cell else {
                    return
                }
                DispatchQueue.runOnMainThread {
                    cell.settingsName.text = userName
                    cell.onOffButton.isSelected = true
                    cell.socialImageView?.image = cell.onOffButton.isSelected ? settings.selectedImage : settings.image
                }
            }
        } else if settingTitle.settingsType == .subscriptions {
            cell.onOffButton.isHidden = false
            if indexPath.row == Defaults.shared.appMode.rawValue {
                cell.onOffButton.isSelected = true
            } else {
                cell.onOffButton.isSelected = false
            }
        } else if settingTitle.settingsType == .faceDetection {
            cell.onOffButton.isHidden = false
            cell.onOffButton.isSelected = Defaults.shared.enableFaceDetection
        } else if settingTitle.settingsType == .swapeContols {
            cell.onOffButton.isHidden = false
            cell.onOffButton.isSelected = Defaults.shared.swapeContols
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.storySettingsHeader.identifier) as? StorySettingsHeader else {
            fatalError("StorySettingsHeader Not Found")
        }
        let settingTitle = StorySettings.storySettings[section]
        if settingTitle.settingsType == .controlcenter || settingTitle.settingsType == .logout || settingTitle.settingsType == .socialLogout || settingTitle.settingsType == .socialConnections || settingTitle.settingsType == .channelManagement || settingTitle.settingsType == .faceDetection || settingTitle.settingsType == .swapeContols || settingTitle.settingsType == .appInfo || settingTitle.settingsType == .video {
            headerView.title.isHidden = true
        } else {
            headerView.title.isHidden = false
        }
        headerView.title.text = settingTitle.name
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let settingTitle = StorySettings.storySettings[section]
        if settingTitle.settingsType == .controlcenter || settingTitle.settingsType == .logout || settingTitle.settingsType == .socialLogout || settingTitle.settingsType == .socialConnections || settingTitle.settingsType == .channelManagement || settingTitle.settingsType == .faceDetection || settingTitle.settingsType == .swapeContols || settingTitle.settingsType == .appInfo || settingTitle.settingsType == .video || settingTitle.settingsType == .cameraSettings {
            return 24
        } else {
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingTitle = StorySettings.storySettings[indexPath.section]
        if settingTitle.settingsType == .controlcenter {
            if let baseUploadVC = R.storyboard.storyCameraViewController.baseUploadVC() {
                navigationController?.pushViewController(baseUploadVC, animated: true)
            }
        } else if settingTitle.settingsType == .video {
            if let viralCamVideos = R.storyboard.viralCamVideos.viralCamVideos() {
                navigationController?.pushViewController(viralCamVideos, animated: true)
            }
        } else if settingTitle.settingsType == .cameraSettings {
            if let storySettingsVC = R.storyboard.storyCameraViewController.storySettingsOptionsVC() {
                navigationController?.pushViewController(storySettingsVC, animated: true)
            }
        } else if settingTitle.settingsType == .logout {
            viralCamLogout()
        } else if settingTitle.settingsType == .socialLogout {
            logoutUser()
        } else if settingTitle.settingsType == .socialLogins {
            let socialLogin: SocialLogin = SocialLogin(rawValue: indexPath.row) ?? .facebook
            socialLoginLogout(socialLogin: socialLogin) { [weak self] (isLogin) in
                guard let `self` = self else {
                    return
                }
                #if VIRALCAMAPP
                if socialLogin == .storiCam, !isLogin {
                    if let loginNav = R.storyboard.loginViewController.loginNavigation() {
                        Defaults.shared.clearData()
                        Utils.appDelegate?.window?.rootViewController = loginNav
                        return
                    }
                } else if isLogin {
                    var socialPlatform: String = "facebook"
                    switch socialLogin {
                    case .twitter:
                        socialPlatform = "twitter"
                    case .instagram:
                        socialPlatform = "instagram"
                    case .snapchat:
                        socialPlatform = "snapchat"
                    case .youtube:
                        socialPlatform = "google"
                    default:
                        break
                    }
                    self.socialLoadProfile(socialLogin: socialLogin) { [weak self] (socialName, socialId) in
                        guard let `self` = self else {
                            return
                        }
                        self.connectSocial(socialPlatform: socialPlatform, socialId: socialId ?? "", socialName: socialName ?? "")
                    }
                }
                #endif
                DispatchQueue.runOnMainThread {
                    StorySettings.storySettings[indexPath.section].settings[socialLogin.rawValue].selected = isLogin
                    self.settingsTableView.reloadData()
                }
            }
        } else if settingTitle.settingsType == .subscriptions {
            guard Defaults.shared.appMode.rawValue != indexPath.row else {
                return
            }
            self.enableMode(appMode: AppMode(rawValue: indexPath.row) ?? .free)
        } else if settingTitle.settingsType == .faceDetection {
            Defaults.shared.enableFaceDetection = !Defaults.shared.enableFaceDetection
            self.settingsTableView.reloadData()
        } else if settingTitle.settingsType == .swapeContols {
            Defaults.shared.swapeContols = !Defaults.shared.swapeContols
            self.settingsTableView.reloadData()
        } else if settingTitle.settingsType == .channelManagement {
            let chVc = R.storyboard.preRegistration.channelListViewController()
            chVc?.remainingPackageCountForOthers = Defaults.shared.currentUser?.remainingOtherUserPackageCount ?? 0
            self.navigationController?.pushViewController(chVc!, animated: true)
        } else if settingTitle.settingsType == .socialConnections {
            if let addSocialConnectionViewController = R.storyboard.socialConnection.addSocialConnectionViewController() {
                navigationController?.pushViewController(addSocialConnectionViewController, animated: true)
            }
        }
    }
    
    func viralCamLogout() {
        let objAlert = UIAlertController(title: Constant.Application.displayName, message: R.string.localizable.areYouSureYouWantToLogout(), preferredStyle: .alert)
        let actionlogOut = UIAlertAction(title: R.string.localizable.logout(), style: .default) { (_: UIAlertAction) in
            StoriCamManager.shared.logout()
            TwitterManger.shared.logout()
            GoogleManager.shared.logout()
            FaceBookManager.shared.logout()
            InstagramManager.shared.logout()
            SnapKitManager.shared.logout { _ in
                
            }
            self.settingsTableView.reloadData()
            if let loginNav = R.storyboard.loginViewController.loginNavigation() {
                Defaults.shared.clearData()
                Utils.appDelegate?.window?.rootViewController = loginNav
            }
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .default) { (_: UIAlertAction) in }
        objAlert.addAction(actionlogOut)
        objAlert.addAction(cancelAction)
        self.present(objAlert, animated: true, completion: nil)
    }
    
    func connectSocial(socialPlatform: String, socialId: String, socialName: String) {
        self.showHUD()
        ProManagerApi.connectSocial(socialPlatform: socialPlatform, socialId: socialId, socialName: socialName).request(Result<SocialUserConnect>.self).subscribe(onNext: { (response) in
            self.dismissHUD()
            if response.status != ResponseType.success {
                UIApplication.showAlert(title: Constant.Application.displayName, message: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            self.dismissHUD()
            
            print(error)
        }, onCompleted: {
            
        }).disposed(by: rx.disposeBag)
    }
    
    func socialLoadProfile(socialLogin: SocialLogin, completion: @escaping (String?, String?) -> ()) {
        switch socialLogin {
        case .facebook:
            if FaceBookManager.shared.isUserLogin {
                FaceBookManager.shared.loadUserData { (userModel) in
                    completion(userModel?.userName, userModel?.userId)
                }
            }
        case .twitter:
            if TwitterManger.shared.isUserLogin {
                TwitterManger.shared.loadUserData { (userModel) in
                    completion(userModel?.userName, userModel?.userId)
                }
            }
        case .instagram:
            if InstagramManager.shared.isUserLogin {
                if let userModel = InstagramManager.shared.profileDetails {
                    completion(userModel.username, userModel.id)
                }
            }
        case .snapchat:
            if SnapKitManager.shared.isUserLogin {
                SnapKitManager.shared.loadUserData { (userModel) in
                    completion(userModel?.userName, userModel?.userId)
                }
            }
        case .youtube:
            if GoogleManager.shared.isUserLogin {
                GoogleManager.shared.loadUserData { (userModel) in
                    completion(userModel?.userName, userModel?.userId)
                }
            }
        case .storiCam:
            if StoriCamManager.shared.isUserLogin {
                StoriCamManager.shared.loadUserData { (userModel) in
                    completion(userModel?.userName, userModel?.userId)
                }
            }
        }
    }
    
    func socialLoginLogout(socialLogin: SocialLogin, completion: @escaping (Bool) -> ()) {
        switch socialLogin {
        case .facebook:
            if !FaceBookManager.shared.isUserLogin {
                FaceBookManager.shared.login(controller: self, loginCompletion: { (_, _) in
                    completion(true)
                }) { (_, _) in
                    completion(false)
                }
            } else {
                FaceBookManager.shared.logout()
                completion(false)
            }
        case .twitter:
            if !TwitterManger.shared.isUserLogin {
                TwitterManger.shared.login { (_, _) in
                    completion(true)
                }
            } else {
                TwitterManger.shared.logout()
                completion(false)
            }
        case .instagram:
            if !InstagramManager.shared.isUserLogin {
                let loginViewController: WebViewController = WebViewController()
                loginViewController.delegate = self
                self.present(loginViewController, animated: true) {
                    completion(true)
                }
            } else {
                InstagramManager.shared.logout()
                completion(false)
            }
        case .snapchat:
            if !SnapKitManager.shared.isUserLogin {
                SnapKitManager.shared.login(viewController: self) { (isLogin, error) in
                    if !isLogin {
                        DispatchQueue.main.async {
                            self.showAlert(alertMessage: error ?? "")
                        }
                    }
                    completion(isLogin)
                }
            } else {
                SnapKitManager.shared.logout { _ in
                    completion(false)
                }
            }
        case .youtube:
            if !GoogleManager.shared.isUserLogin {
                GoogleManager.shared.login(controller: self, complitionBlock: { (_, _) in
                    completion(true)
                }) { (_, _) in
                    completion(false)
                }
            } else {
                GoogleManager.shared.logout()
                completion(false)
            }
        case .storiCam:
            if !StoriCamManager.shared.isUserLogin {
                StoriCamManager.shared.login(controller: self) { (_, _) in
                    StoriCamManager.shared.delegate = self
                }
            } else {
                StoriCamManager.shared.logout()
                completion(false)
            }
        }
    }
    
    func enableMode(appMode: AppMode) {
        var message: String? = ""
        let placeholder: String? = R.string.localizable.enterYourUniqueCodeToEnableBasicMode()
        let proModeCode: String? = Constant.Application.proModeCode
        var successMessage: String? = ""
        switch appMode {
        case .free:
            message = R.string.localizable.areYouSureYouWantToEnableFree()
            successMessage = R.string.localizable.freeModeIsEnabled()
        case .basic:
            message = R.string.localizable.areYouSureYouWantToEnableBasic()
            successMessage = R.string.localizable.basicModeIsEnabled()
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
                #if DEBUG
                textField.text = proModeCode
                #endif
                textField.placeholder = placeholder
            }
        }
        
        let actionSave = UIAlertAction(title: R.string.localizable.oK(), style: .default) { ( _: UIAlertAction) in
            if appMode != .free {
                if let textField = objAlert.textFields?[0],
                    textField.text!.count > 0, textField.text?.lowercased() != proModeCode {
                    self.view.makeToast(R.string.localizable.pleaseEnterValidCode())
                    return
                }
            }
            Defaults.shared.appMode = appMode
            StorySettings.storySettings[0].settings[appMode.rawValue].selected = true
            self.settingsTableView.reloadData()
            AppEventBus.post("changeMode")
            self.navigationController?.popViewController(animated: true)
            Utils.appDelegate?.window?.makeToast(successMessage)
            
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .default) { (_: UIAlertAction) in }
        objAlert.addAction(actionSave)
        objAlert.addAction(cancelAction)
        self.present(objAlert, animated: true, completion: nil)
    }
    
    func logoutUser() {
        let objAlert = UIAlertController(title: Constant.Application.displayName, message: R.string.localizable.areYouSureYouWantToLogout(), preferredStyle: .alert)
        let actionlogOut = UIAlertAction(title: R.string.localizable.logout(), style: .default) { (_: UIAlertAction) in
            TwitterManger.shared.logout()
            GoogleManager.shared.logout()
            FaceBookManager.shared.logout()
            InstagramManager.shared.logout()
            SnapKitManager.shared.logout { _ in
                self.settingsTableView.reloadData()
            }
            self.settingsTableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .default) { (_: UIAlertAction) in }
        objAlert.addAction(actionlogOut)
        objAlert.addAction(cancelAction)
        self.present(objAlert, animated: true, completion: nil)
    }
}

extension StorySettingsVC: InstagramLoginViewControllerDelegate, ProfileDelegate {
   
    func profileDidLoad(profile: ProfileDetailsResponse) {
        self.settingsTableView.reloadData()
    }
    
    func profileLoadFailed(error: Error) {
        
    }
   
    func instagramLoginDidFinish(accessToken: String?, error: Error?) {
        if accessToken != nil {
            InstagramManager.shared.delegate = self
            InstagramManager.shared.loadProfile()
        }
    }
}

extension StorySettingsVC: StoriCamManagerDelegate {
    func loginDidFinish(user: User?, error: Error?) {
        self.settingsTableView.reloadData()
    }
}
