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
    
    init(name: String, settings: [StorySetting]) {
        self.name = name
        self.settings = settings
    }
    
    static var storySettings = [StorySettings(name: R.string.localizable.subscriptions(),
                                              settings: [StorySetting(name: R.string.localizable.free(),
                                                                      selected: true),
                                                         StorySetting(name: R.string.localizable.basic(),
                                                                      selected: false),
                                                         StorySetting(name: R.string.localizable.advanced(),
                                                                      selected: true),
                                                         StorySetting(name: R.string.localizable.professional(),
                                                                      selected: true)]),
                                StorySettings(name: R.string.localizable.socialLogin(),
                                              settings: [StorySetting(name: R.string.localizable.facebook(),
                                                                      selected: false,
                                                                      image: R.image.icoFacebookInActive(),
                                                                      selectedImage: R.image.icoFacebook()),
                                                         StorySetting(name: R.string.localizable.twitter(),
                                                                      selected: false,
                                                                      image: R.image.icoTwitterInActive(),
                                                                      selectedImage: R.image.icoTwitter()),
                                                         StorySetting(name: R.string.localizable.instagram(),
                                                                      selected: false,
                                                                      image: R.image.icoInstagramInActive(),
                                                                      selectedImage: R.image.icoInstagram()),
                                                         StorySetting(name: R.string.localizable.snapchat(),
                                                                      selected: false,
                                                                      image: R.image.icoSnapchatInActive(),
                                                                      selectedImage: R.image.icoSnapchat()),
                                                         StorySetting(name: R.string.localizable.google(),
                                                                      selected: false,
                                                                      image: R.image.icoYoutubeInActive(),
                                                                      selectedImage: R.image.icoYoutube()),
                                                         StorySetting(name: R.string.localizable.storiCam(),
                                                                      selected: false,
                                                                      image: R.image.icoStoriCamInActive(),
                                                                      selectedImage: R.image.icoStoriCam())]),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.logout(), selected: false)]),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: R.string.localizable.controlCenter(), selected: false)])]
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
        let settings = StorySettings.storySettings[indexPath.section].settings[indexPath.row]
        cell.settingsName.text = settings.name
        cell.detailButton.isHidden = true
        if indexPath.section == 2 || indexPath.section == 3 {
            cell.onOffButton.isHidden = true
        } else if indexPath.section == 1 {
            cell.onOffButton.isHidden = true
            cell.onOffButton.isSelected = false
            cell.socialImageView?.isHidden = false
            cell.socialImageView?.image = cell.onOffButton.isSelected ? settings.selectedImage : settings.image
            
            let socialLogin: SocialLogin = SocialLogin(rawValue: indexPath.row) ?? .facebook
            self.socialLoadProfile(socialLogin: socialLogin) { [weak cell] (userName) in
                guard let cell = cell else {
                    return
                }
                DispatchQueue.runOnMainThread {
                    cell.settingsName.text = userName
                    cell.onOffButton.isSelected = true
                    cell.socialImageView?.image = cell.onOffButton.isSelected ? settings.selectedImage : settings.image
                }
            }
        } else {
            if indexPath.row == 1 || indexPath.row == 2 {
                cell.settingsName.isEnabled = false
            }
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
        if section == 2 {
            headerView.title.isHidden = true
        } else {
            headerView.title.isHidden = false
        }
        headerView.title.text = StorySettings.storySettings[section].name
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 || section == 3 {
            return 24
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            if let baseUploadVC = R.storyboard.storyCameraViewController.baseUploadVC() {
                navigationController?.pushViewController(baseUploadVC, animated: true)
            }
        } else if indexPath.section == 2 {
            logoutUser()
        } else if indexPath.section == 1 {
            let socialLogin: SocialLogin = SocialLogin(rawValue: indexPath.row) ?? .facebook
            socialLoginLogout(socialLogin: socialLogin) { [weak self] (isLogin) in
                guard let `self` = self else {
                    return
                }
                DispatchQueue.runOnMainThread {
                    StorySettings.storySettings[indexPath.section].settings[socialLogin.rawValue].selected = isLogin
                    self.settingsTableView.reloadData()
                }
            }
        } else if indexPath.section == 0 {
            guard Defaults.shared.appMode.rawValue != indexPath.row else {
                return
            }
            if indexPath.row == 0 {
                Defaults.shared.appMode = .free
                self.settingsTableView.reloadData()
                UIApplication.shared.setAlternateIconName(R.image.icon2.name) { error in
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
    }
    
    func socialLoadProfile(socialLogin: SocialLogin, completion: @escaping (String?) -> ()) {
        switch socialLogin {
        case .facebook:
            if FaceBookManager.shared.isUserLogin {
                FaceBookManager.shared.loadUserData { (userModel) in
                    completion(userModel?.userName)
                }
            }
        case .twitter:
            if TwitterManger.shared.isUserLogin {
                TwitterManger.shared.loadUserData { (userModel) in
                    completion(userModel?.userName)
                }
            }
        case .instagram:
            if InstagramManager.shared.isUserLogin {
                if let profile = InstagramManager.shared.profileDetails {
                    completion(profile.username)
                }
            }
        case .snapchat:
            if SnapKitManager.shared.isUserLogin {
                SnapKitManager.shared.loadUserData { (userModel) in
                    completion(userModel?.userName)
                }
            }
        case .youtube:
            if GoogleManager.shared.isUserLogin {
                GoogleManager.shared.getUserName { (userName) in
                    completion(userName)
                }
            }
        case .storiCam:
            if StoriCamManager.shared.isUserLogin {
                StoriCamManager.shared.loadUserData { (userName) in
                    completion(userName?.userName)
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
    
    func isProEnable() {
        let objAlert = UIAlertController(title: Constant.Application.displayName, message: R.string.localizable.areYouSureYouWantToEnablePro(), preferredStyle: .alert)
        objAlert.addTextField { (textField: UITextField) -> Void in
            #if DEBUG
            textField.text = Constant.Application.proModeCode
            #endif
            textField.placeholder = R.string.localizable.enterYourUniqueCodeToActivateTheLevel()
        }
        let actionSave = UIAlertAction(title: R.string.localizable.oK(), style: .default) { ( _: UIAlertAction) in
            if let textField = objAlert.textFields?[0],
                textField.text!.count > 0, textField.text?.lowercased() == Constant.Application.proModeCode {
                Defaults.shared.appMode = .professional
                StorySettings.storySettings[0].settings[3].selected = true
                self.settingsTableView.reloadData()
                UIApplication.shared.setAlternateIconName(R.image.icon1.name) { error in
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
            TwitterManger.shared.logout()
            GoogleManager.shared.logout()
            FaceBookManager.shared.logout()
            InstagramManager.shared.logout()
            SnapKitManager.shared.logout { _ in
                self.settingsTableView.reloadData()
            }
            StoriCamManager.shared.logout()
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
