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
    case supportedFrameRates
    case swapeContols
    case cameraSettings
    case socialConnections
    case channelManagement
    case socialLogout
    case logout
    case controlcenter
    case video
    case appInfo
    case appStartScreen
    case guidelineType
    case guidelineTickness
    case guidelineColor
    case guildlines
    case termsAndConditions
    case privacyPolicy
    case watermarkAlpha30 = 30
    case watermarkAlpha50 = 50
    case watermarkAlpha80 = 80
    case subscription
    case goToWebsite
    case watermarkSettings
    case fatesteverWatermark
    case applIdentifierWatermark
    case videoResolution
    case applicationSurvey
    case instruction
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
                                                         StorySetting(name: R.string.localizable.basic(),
                                                                      selected: false),
                                                         StorySetting(name: R.string.localizable.advanced(),
                                                                      selected: true),
                                                         StorySetting(name: R.string.localizable.professional(),
                                                                      selected: true)], settingsType: .subscriptions),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.cameraSettings(), selected: false)], settingsType: .cameraSettings),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.watermark(), selected: false)], settingsType: .watermarkSettings),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.subscription(), selected: false)], settingsType: .subscription),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.goToWebsite(), selected: false)], settingsType: .goToWebsite),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.applicationSurvey(), selected: false)], settingsType: .applicationSurvey),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.instruction(), selected: false)], settingsType: .instruction),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.logout(), selected: false)], settingsType: .logout)]
}

class StorySettingsVC: UIViewController {
    
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var lblAppInfo: UILabel!
    @IBOutlet weak var imgAppLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblAppInfo.text = "\(Constant.Application.displayName) - \(Constant.Application.appVersion)(\(Constant.Application.appBuildNumber))"
        setupUI()
    }
    
    deinit {
        print("Deinit \(self.description)")
    }
    
    // MARK: - Setup UI Methods
    private func setupUI() {
        #if SOCIALCAMAPP
        imgAppLogo.image = R.image.socialCamSplashLogo()
        #elseif VIRALCAMAPP
        imgAppLogo.image = R.image.viralcamrgb()
        #elseif SOCCERCAMAPP || FUTBOLCAMAPP
        imgAppLogo.image = R.image.soccercamWatermarkLogo()
        #elseif QUICKCAMAPP
        imgAppLogo.image = R.image.ssuQuickCam()
        #elseif SNAPCAMAPP
        imgAppLogo.image = R.image.snapcamWatermarkLogo()
        #elseif SPEEDCAMAPP
        imgAppLogo.image = R.image.ssuSpeedCam()
        #elseif TIMESPEEDAPP
        imgAppLogo.image = R.image.timeSpeedWatermarkLogo()
        #elseif FASTCAMAPP
        imgAppLogo.image = R.image.ssuFastCam()
        #elseif BOOMICAMAPP
        imgAppLogo.image = R.image.boomicamWatermarkLogo()
        #elseif VIRALCAMLITEAPP
        imgAppLogo.image = R.image.viralcamLiteWatermark()
        #elseif FASTCAMLITEAPP
        imgAppLogo.image = R.image.ssuFastCamLite()
        #elseif QUICKCAMLITEAPP
        imgAppLogo.image = R.image.ssuQuickCamLite()
        #elseif SPEEDCAMLITEAPP
        imgAppLogo.image = R.image.speedcamLiteSsu()
        #elseif SNAPCAMLITEAPP
        imgAppLogo.image = R.image.snapcamliteSplashLogo()
        #elseif RECORDERAPP
        imgAppLogo.image = R.image.socialScreenRecorderWatermarkLogo()
        #else
        imgAppLogo.image = R.image.pic2artWatermarkLogo()
        #endif
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnLegalDetailsTapped(_ sender: UIButton) {
        guard let legalVc = R.storyboard.legal.legalViewController() else { return }
        legalVc.isTermsAndConditions = (sender.tag == 0)
        self.navigationController?.pushViewController(legalVc, animated: true)
    }
    
}

extension StorySettingsVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return StorySettings.storySettings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if StorySettings.storySettings[section].settingsType == .subscriptions {
            let item = StorySettings.storySettings[section]
            guard item.isCollapsible else {
                return StorySettings.storySettings[section].settings.count
            }
            
            if item.isCollapsed {
                return 0
            } else {
                return item.settings.count
            }
        }
        
        return StorySettings.storySettings[section].settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.appOpenSettingsCell.identifier, for: indexPath) as? AppOpenSettingsCell, StorySettings.storySettings[indexPath.section].settingsType == .appStartScreen {
            #if PIC2ARTAPP || SOCIALCAMAPP || VIRALCAMAPP || SOCCERCAMAPP || FUTBOLCAMAPP || QUICKCAMAPP || VIRALCAMLITEAPP || VIRALCAMLITEAPP || FASTCAMLITEAPP || QUICKCAMLITEAPP || SPEEDCAMLITEAPP || SNAPCAMLITEAPP
            cell.dashBoardView.isHidden = true
            #else
            cell.dashBoardView.isHidden = false
            #endif
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.storySettingsCell.identifier, for: indexPath) as? StorySettingsCell else {
            fatalError("\(R.reuseIdentifier.storySettingsCell.identifier) Not Found")
        }
        let settingTitle = StorySettings.storySettings[indexPath.section]
        let settings = settingTitle.settings[indexPath.row]
        cell.settingsName.text = settings.name
        cell.detailButton.isHidden = true
        cell.settingsName.textColor = R.color.appBlackColor()
        if settingTitle.settingsType == .controlcenter || settingTitle.settingsType == .logout || settingTitle.settingsType == .socialLogout || settingTitle.settingsType == .socialConnections || settingTitle.settingsType == .channelManagement || settingTitle.settingsType == .appInfo || settingTitle.settingsType == .video || settingTitle.settingsType == .cameraSettings || settingTitle.settingsType == .termsAndConditions || settingTitle.settingsType == .privacyPolicy || settingTitle.settingsType == .subscription || settingTitle.settingsType == .goToWebsite || settingTitle.settingsType == .watermarkSettings || settingTitle.settingsType == .applicationSurvey || settingTitle.settingsType == .instruction {
            if settingTitle.settingsType == .appInfo {
                cell.settingsName.textColor = R.color.appPrimaryColor()
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
            headerView.title.text = settingTitle.name + " - \(Defaults.shared.appMode.description)"
        } else {
            headerView.title.text = settingTitle.name
            headerView.arrowLabel?.isHidden = true
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let settingTitle = StorySettings.storySettings[section]
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
            logoutWithKeycloak()
        } else if settingTitle.settingsType == .socialLogout {
            logoutUser()
        } else if settingTitle.settingsType == .socialLogins {
            let socialLogin: SocialLogin = SocialLogin(rawValue: indexPath.row) ?? .facebook
            socialLoginLogout(socialLogin: socialLogin) { [weak self] (isLogin) in
                guard let `self` = self else {
                    return
                }
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
        } else if settingTitle.settingsType == .termsAndConditions || settingTitle.settingsType == .privacyPolicy {
            guard let legalVc = R.storyboard.legal.legalViewController() else { return }
            legalVc.isTermsAndConditions = settingTitle.settingsType == .termsAndConditions
            self.navigationController?.pushViewController(legalVc, animated: true)
        } else if settingTitle.settingsType == .subscription {
            if let subscriptionVC = R.storyboard.subscription.subscriptionContainerViewController() {
                navigationController?.pushViewController(subscriptionVC, animated: true)
            }
        } else if settingTitle.settingsType == .goToWebsite {
            guard let url = URL(string: websiteUrl) else { return }
            UIApplication.shared.open(url)
        } else if settingTitle.settingsType == .applicationSurvey {
            guard let url = URL(string: Constant.URLs.applicationSurveyURL) else { return }
            UIApplication.shared.open(url)
        } else if settingTitle.settingsType == .watermarkSettings {
            if let watermarkSettingsVC = R.storyboard.storyCameraViewController.watermarkSettingsViewController() {
                navigationController?.pushViewController(watermarkSettingsVC, animated: true)
            }
        } else if settingTitle.settingsType == .instruction {
            if let tooltipViewController = R.storyboard.loginViewController.tooltipViewController() {
                tooltipViewController.pushFromSettingScreen = true
                navigationController?.pushViewController(tooltipViewController, animated: true)
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
            if #available(iOS 13.0, *) {
                AppleSignInManager.shared.logout()
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
    
    func logoutWithKeycloak() {
        ProManagerApi.logoutKeycloak.request(Result<EmptyModel>.self).subscribe(onNext: { (response) in
            if response.status == ResponseType.success {
                self.viralCamLogout()
            } else {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
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
        case .apple:
            if #available(iOS 13.0, *) {
                if AppleSignInManager.shared.isUserLogin {
                    AppleSignInManager.shared.loadUserData { (userModel) in
                        completion(userModel?.userName, userModel?.userId)
                    }
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
        case .apple:
            if #available(iOS 13.0, *) {
                if !AppleSignInManager.shared.isUserLogin {
                    AppleSignInManager.shared.login(controller: self, complitionBlock: { _, _  in
                        completion(true)
                    }) { _, _  in
                        completion(false)
                    }
                } else {
                    AppleSignInManager.shared.logout()
                    completion(false)
                }
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
                if isDebug {
                    textField.text = proModeCode
                }
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
            if #available(iOS 13.0, *) {
                AppleSignInManager.shared.logout()
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

class ScreenSelectionView: UIView {
    @IBOutlet var viewSelection: UIView?
    var isSelected: Bool? {
        didSet {
            viewSelection?.isHidden = !(isSelected ?? false)
        }
    }
    var selectionHandler: (() -> Void)?
    
    @IBAction func btnClicked(_sender: Any) {
        self.isSelected = true
        if let handler = selectionHandler {
            handler()
        }
    }
    
}
extension StorySettingsVC: HeaderViewDelegate {
    func toggleSection(header: StorySettingsHeader, section: Int) {
        let settingTitle = StorySettings.storySettings[section]
        if settingTitle.isCollapsible {

            // Toggle collapse
            let collapsed = !settingTitle.isCollapsed
            settingTitle.isCollapsed = collapsed
            self.settingsTableView?.reloadData()
        }
    }
}
