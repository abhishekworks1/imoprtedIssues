//
//  AddSocialConnectionViewController.swift
//  SocialCAM
//
//  Created by Jasmin Patel on 13/05/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit
import Foundation

enum SocialConnectionType: CaseIterable {
    case facebook
    case instagram
    case snapchat
    case twitter
    case youtube
    
    var image: UIImage? {
        switch self {
        case .facebook:
            return R.image.icoFacebook()
        case .instagram:
            return R.image.icoInstagram()
        case .snapchat:
            return R.image.icoSnapchat()
        case .twitter:
            return R.image.icoTwitter()
        case .youtube:
            return R.image.icoYoutube()
        }
    }
    
    var color: UIColor? {
        switch self {
        case .facebook:
            return R.color.icoFacebookColor()
        case .instagram:
            return R.color.icoInstagramColor()
        case .snapchat:
            return R.color.icoSnapchatColor()
        case .twitter:
            return R.color.icoTwitterColor()
        case .youtube:
            return R.color.icoYoutubeColor()
        }
    }
}

class SocialUserData {
    var name: String?
    var profileURL: String?
    var type: SocialConnectionType

    init(name: String?, profileURL: String?, type: SocialConnectionType) {
        self.name = name
        self.profileURL = profileURL
        self.type = type
    }
}

class SocialConnectionOption {
    
    var type: SocialConnectionType
    var socialUserData: SocialUserData?
    
    init(type: SocialConnectionType) {
        self.type = type
    }

}

class SocialConnectionCell: UICollectionViewCell {
    
    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var selectionView: UIImageView! {
        didSet {
            selectionView.isHidden = true
        }
    }

    func configure(socialOption: SocialConnectionOption) {
        typeImageView.image = socialOption.type.image
    }
}

class SocialConnectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!

    func configure(socialOption: SocialConnectionOption) {
        baseView.backgroundColor = socialOption.type.color?.withAlphaComponent(0.5)
        typeImageView.image = socialOption.type.image
        userImageView.setImageFromURL(socialOption.socialUserData?.profileURL)
        userNameLabel.text = socialOption.socialUserData?.name
    }
}

class AddSocialConnectionViewController: UIViewController {

    @IBOutlet weak var warningViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var unconnectedView: UIView!
    
    @IBOutlet weak var connectButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var backButton: UIButton!

    lazy var socialOptions: [SocialConnectionOption] = {
        var options: [SocialConnectionOption] = []
        for type in SocialConnectionType.allCases {
            options.append(SocialConnectionOption(type: type))
        }
        return options
    }()
    
    let collectionViewCellWidth: CGFloat = (UIScreen.width - 24)/4
    let warningHeight: CGFloat = 71

    var fromLogin = false

    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.isHidden = fromLogin
        connectButton.isHidden = !fromLogin
        reloadData()
        updateUI()
    }
    
    func updateUI() {
        let isOneSocialConnected = socialOptions.filter({ return $0.socialUserData != nil }).count > 0
        let isOneSocialDisconnected = socialOptions.filter({ return $0.socialUserData == nil }).count > 0
        
        warningViewHeight.constant = isOneSocialConnected ? 0 : warningHeight
        connectButton.alpha = isOneSocialConnected ? 1.0 : 0.7
        connectButton.isEnabled = isOneSocialConnected
        unconnectedView.frame.size.height = isOneSocialConnected ? (isOneSocialDisconnected ? collectionViewCellWidth + 40 : 0) : (collectionViewCellWidth*2 + 40)
    }
    
    func reloadData() {
        for option in socialOptions {
            socialLoadProfile(socialLogin: option.type) { socialUserData in
                if let userData = socialUserData {
                    self.updateSocialOptions(userData: userData)
                }
            }
        }
    }
    
    func updateSocialOptions(userData: SocialUserData) {
        DispatchQueue.runOnMainThread {
            let selectedOptions = self.socialOptions.filter({ return userData.type == $0.type })
            if selectedOptions.count > 0 {
                selectedOptions[0].socialUserData = userData
                self.tableView.reloadData()
                self.collectionView.reloadData()
                self.updateUI()
            }
        }
    }
    
    func socialLoadProfile(socialLogin: SocialConnectionType, completion: @escaping (SocialUserData?) -> ()) {
        switch socialLogin {
        case .facebook:
            if FaceBookManager.shared.isUserLogin {
                FaceBookManager.shared.loadUserData { (userModel) in
                    guard let userData = userModel else {
                        completion(nil)
                        return
                    }
                    completion(SocialUserData(name: userData.userName, profileURL: userData.photoUrl, type: .facebook))
                }
            } else {
                completion(nil)
            }
        case .twitter:
            if TwitterManger.shared.isUserLogin {
                TwitterManger.shared.loadUserData { (userModel) in
                    guard let userData = userModel else {
                        completion(nil)
                        return
                    }
                    completion(SocialUserData(name: userData.userName, profileURL: userData.photoUrl, type: .twitter))
                }
            } else {
                completion(nil)
            }
        case .instagram:
            if InstagramManager.shared.isUserLogin {
                if let userModel = InstagramManager.shared.profileDetails {
                    completion(SocialUserData(name: userModel.username, profileURL: userModel.profilePicUrl, type: .instagram))
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        case .snapchat:
            if SnapKitManager.shared.isUserLogin {
                SnapKitManager.shared.loadUserData { (userModel) in
                    guard let userData = userModel else {
                        completion(nil)
                        return
                    }
                    completion(SocialUserData(name: userData.userName, profileURL: userData.photoUrl, type: .snapchat))
                }
            } else {
                completion(nil)
            }
        case .youtube:
            if GoogleManager.shared.isUserLogin {
                GoogleManager.shared.loadUserData { (userModel) in
                    guard let userData = userModel else {
                        completion(nil)
                        return
                    }
                    completion(SocialUserData(name: userData.userName, profileURL: userData.photoUrl, type: .youtube))
                }
            } else {
                completion(nil)
            }
        }
    }
    
    @IBAction func backClicked(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextClicked(_ sender: UIButton) {
        Utils.appDelegate?.window?.rootViewController = R.storyboard.pageViewController.pageViewController()
    }
    
    func socialLoginLogout(socialLogin: SocialConnectionType, completion: @escaping (Bool) -> ()) {
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
        }
    }

}

extension AddSocialConnectionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return socialOptions.filter({ return $0.socialUserData != nil }).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SocialConnectionTableViewCell", for: indexPath) as! SocialConnectionTableViewCell
        cell.configure(socialOption: socialOptions.filter({ return $0.socialUserData != nil })[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objAlert = UIAlertController(title: Constant.Application.displayName, message: R.string.localizable.areYouSureYouWantToLogout(), preferredStyle: .alert)
        let actionlogOut = UIAlertAction(title: R.string.localizable.logout(), style: .default) { (_: UIAlertAction) in
            let optionType = self.socialOptions.filter({ return $0.socialUserData != nil })[indexPath.row].type
            self.socialLoginLogout(socialLogin: optionType) { [weak self] (isLogin) in
                guard let `self` = self else {
                    return
                }
                DispatchQueue.runOnMainThread {
                    let selectedOptions = self.socialOptions.filter({ return optionType == $0.type })
                    if selectedOptions.count > 0 {
                        selectedOptions[0].socialUserData = nil
                        self.tableView.reloadData()
                        self.collectionView.reloadData()
                        self.updateUI()
                    }
                }
            }
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .default) { (_: UIAlertAction) in }
        objAlert.addAction(actionlogOut)
        objAlert.addAction(cancelAction)
        self.present(objAlert, animated: true, completion: nil)
    }
    
}

extension AddSocialConnectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return socialOptions.filter({ return $0.socialUserData == nil }).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SocialConnectionCell", for: indexPath) as! SocialConnectionCell
        cell.configure(socialOption: socialOptions.filter({ return $0.socialUserData == nil })[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let optionType = socialOptions.filter({ return $0.socialUserData == nil })[indexPath.row].type
        socialLoginLogout(socialLogin: optionType) { [weak self] (isLogin) in
            guard let `self` = self else {
                return
            }
            self.socialLoadProfile(socialLogin: optionType) { socialUserData in
                if let userData = socialUserData {
                    self.updateSocialOptions(userData: userData)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionViewCellWidth, height: collectionViewCellWidth)
    }
    
}

extension AddSocialConnectionViewController: InstagramLoginViewControllerDelegate, ProfileDelegate {
   
    func profileDidLoad(profile: ProfileDetailsResponse) {
        let optionType = SocialConnectionType.instagram
        self.socialLoadProfile(socialLogin: optionType) { socialUserData in
            if let userData = socialUserData {
                self.updateSocialOptions(userData: userData)
            }
        }
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
