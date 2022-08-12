//
//  LoginViewController.swift
//  SocialCAM
//
//  Created by Viraj Patel on 06/11/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit
import SkyFloatingLabelTextField
import FontAwesome_swift
import Spring
import FirebaseCrashlytics
import FirebaseMessaging

class UpAnimation: SpringView {
        
    override func awakeFromNib() {
        self.animation = "fadeInUp"
        self.curve = "easeOut"
        self.duration =  2.0
        self.animate()
    }
    
}
    
class DownAnimation: SpringImageView {
        
    override func awakeFromNib() {
        self.animation = "fadeInDown"
        self.curve = "easeOut"
        self.duration =  2.0
        self.animate()
    }
    
}

protocol LoginViewControllerDelegate: class {
    func loginDidFinish(user: User?, error: Error?, fromSignup: Bool)
}

class LoginViewController: UIViewController, UIGestureRecognizerDelegate {
    // MARK: Properites
    var parentId: String = ""
    
    // MARK: IBOutlets
    @IBOutlet var txtEmail: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var txtPassword: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var btnHidePassWord: PButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var signUpView: UIView!
    @IBOutlet weak var socialSingUpTitleView: UIView!
    @IBOutlet weak var socialSingUpView: UIView!
    @IBOutlet var btnSignUP: UIButton!
    @IBOutlet weak var logoLable: UILabel!
    @IBOutlet var appleLoginView: UIView!
    @IBOutlet weak var loginTooltip: UIView!
    @IBOutlet weak var lblLoginTooltip: UILabel!
    @IBOutlet weak var doNotShowAgainView: UIView!
    @IBOutlet weak var btnDoNotShowAgain: UIButton!
    @IBOutlet weak var tooltipView: UIView!
    @IBOutlet weak var imgAppLogo: UIImageView!
    @IBOutlet weak var lblAppInfo: UILabel!
    
    weak var delegate: LoginViewControllerDelegate?
    var tapCounter = 0
    var isLoginButtonPressed = false
    var isLoginToolTipHide = false
    let releaseType = Defaults.shared.releaseType
    
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            appleLoginView.isHidden = false
        } else {
            appleLoginView.isHidden = true
        }
        
        #if SOCIALCAMAPP
        headerView.isHidden = true
        signUpView.isHidden = true
        socialSingUpTitleView.isHidden = true
        socialSingUpView.isHidden = true
        #elseif VIRALCAMAPP
        imgLogo.image = R.image.viralcamrgb()
        #elseif SOCCERCAMAPP || FUTBOLCAMAPP
        imgLogo.image = R.image.soccercamWatermarkLogo()
        #elseif QUICKCAMAPP
        imgLogo.image = R.image.quickcamWatermarkLogo()
        #elseif SNAPCAMAPP
        imgLogo.image = R.image.snapcamWatermarkLogo()
        #elseif SPEEDCAMAPP
        imgLogo.image = R.image.speedcamWatermarkLogo()
        #elseif TIMESPEEDAPP
        imgLogo.image = R.image.timeSpeedWatermarkLogo()
        #elseif FASTCAMAPP
        imgLogo.image = R.image.fastcamWatermarkLogo()
        #elseif BOOMICAMAPP
        imgLogo.image = R.image.boomicamWatermarkLogo()
        #elseif VIRALCAMLITEAPP
        imgLogo.image = R.image.viralcamLiteWatermark()
        #elseif FASTCAMLITEAPP
        imgLogo.image = R.image.fastcamLiteWatermarkLogo()
        #elseif QUICKCAMLITEAPP || QUICKAPP
        imgLogo.image = (releaseType == .store) ? R.image.quickCamSplashLogo() : R.image.quickcamliteSplashLogo()
        imgAppLogo.image = (releaseType == .store) ? R.image.ssuQuickCam() : R.image.ssuQuickCamLite()
        #elseif SPEEDCAMLITEAPP
        imgLogo.image = R.image.speedcamliteSplashLogo()
        #elseif SNAPCAMLITEAPP
        imgLogo.image = R.image.snapcamliteSplashLogo()
        #elseif RECORDERAPP
        imgLogo.image = R.image.socialScreenRecorderWatermarkLogo()
        #else
        imgLogo.image = R.image.pic2artWatermarkLogo()
        #endif
        
        txtEmail.iconFont = UIFont.fontAwesome(ofSize: 12, style: .solid)
        txtEmail.iconText = String.fontAwesomeIcon(name: .check)
        txtPassword.iconFont = UIFont.fontAwesome(ofSize: 12, style: .solid)
        txtPassword.iconText = String.fontAwesomeIcon(name: .lock)
        setColorTextField(views: [txtEmail, txtPassword])
        lblAppInfo.text = "\(Constant.Application.displayName) - 1.2(40.\(Constant.Application.appBuildNumber))"
        
        let attributedString = NSMutableAttributedString(string: R.string.localizable.donTHaveAnAccountSignUp(), attributes: [
          .font: UIFont.systemFont(ofSize: 14.0, weight: .medium),
          .foregroundColor: UIColor(white: 116.0 / 255.0, alpha: 1.0),
          .kern: -0.2
        ])
        attributedString.addAttributes([
          .font: UIFont.systemFont(ofSize: 16.0, weight: .semibold),
          .foregroundColor: ApplicationSettings.appPrimaryColor
        ], range: NSRange(location: 23, length: 7))
        btnSignUP.setAttributedTitle(attributedString, for: .normal)
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
         //   delegate.getFCMToken()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setColorTextField(views: [SkyFloatingLabelTextFieldWithIcon]) {
        for textField in views {
            textField.titleColor = ApplicationSettings.appPrimaryColor
            textField.selectedTitleColor = ApplicationSettings.appPrimaryColor
            textField.selectedIconColor = ApplicationSettings.appPrimaryColor
        }
    }
    
    func goToKeycloakWebview(url: String) {
        guard let keycloakAuthViewController = R.storyboard.loginViewController.keycloakAuthViewController() else {
            return
        }
        print(url)
        keycloakAuthViewController.urlString = url
        navigationController?.pushViewController(keycloakAuthViewController, animated: true)
    }
    
    /// Hide and show tooltip
    private func hideShowTooltipView(shouldShow: Bool) {
        self.loginTooltip.isHidden = !shouldShow
        self.tooltipView.isHidden = !shouldShow
    }
    
    // MARK: IBActions
    @IBAction func btnCloseClicked(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnKeyCloakLoginClicked(_ sender: UIButton) {
        self.lblLoginTooltip.text = R.string.localizable.loginTooltip(Constant.Application.displayName)
        self.doNotShowAgainView.isHidden = false
        isLoginButtonPressed = true
        /*if Defaults.shared.isLoginTooltipHide == false {
            self.hideShowTooltipView(shouldShow: true)
        } else { */
            Defaults.shared.callHapticFeedback(isHeavy: false)
            isLoginButtonPressed = false
            
            goToKeycloakWebview(url: "\(keycloakUrl)\(keycloakClientId)\(KeycloakRedirectLink.keycloakRedirectLinkName.lowercased())\(KeycloakRedirectLink.endUrl)\(KeycloakRedirectLink.fromLogin)")
//        }
        Defaults.shared.addEventWithName(eventName: Constant.EventName.click_Login)

    }
    
    @IBAction func btnKeyCloakRegisterClicked(_ sender: UIButton) {
        self.lblLoginTooltip.text = R.string.localizable.registerTooltip(Constant.Application.displayName)
        self.hideShowTooltipView(shouldShow: true)
        self.doNotShowAgainView.isHidden = true
        Defaults.shared.addEventWithName(eventName: Constant.EventName.click_SignUp)

    }
    
    @IBAction func btnOkayClicked(_ sender: UIButton) {
        self.hideShowTooltipView(shouldShow: false)
        let messagesAppURL: String
        if isLoginButtonPressed {
            isLoginButtonPressed = false
            messagesAppURL = "\(keycloakUrl)\(keycloakClientId)\(KeycloakRedirectLink.keycloakRedirectLinkName.lowercased())\(KeycloakRedirectLink.endUrl)\(KeycloakRedirectLink.fromLogin)"
        } else {
            messagesAppURL = "\(keycloakUrl)\(keycloakClientId)\(KeycloakRedirectLink.keycloakRedirectLinkName.lowercased())\(KeycloakRedirectLink.endUrl)\(KeycloakRedirectLink.fromSignup)"
        }
        goToKeycloakWebview(url: messagesAppURL)
    }
    
    @IBAction func btnDoNotShowAgainClicked(_ sender: UIButton) {
        btnDoNotShowAgain.isSelected = !btnDoNotShowAgain.isSelected
        isLoginToolTipHide = !isLoginToolTipHide
        Defaults.shared.isLoginTooltipHide = isLoginToolTipHide
        Defaults.shared.isShowAllPopUpChecked = false
    }
    
    @IBAction func tooltipTapView(_ sender: UITapGestureRecognizer) {
        if !self.loginTooltip.isHidden {
            self.hideShowTooltipView(shouldShow: false)
        }
    }
    
    @IBAction func btnPatentsTapped(_ sender: UIButton) {
        guard let patentsVc = R.storyboard.legal.patentsViewController() else { return }
        self.navigationController?.pushViewController(patentsVc, animated: true)
    }
    
    @IBAction func btnLoginClicked(_ sender: Any?) {
        guard let emailText = txtEmail.text else {
            return
        }
        let email = emailText.trimmingCharacters(in: .whitespacesAndNewlines)
        if email.isEmpty {
           self.showAlert(alertMessage: R.string.localizable.pleaseEnterEmail())
            return
        }
        guard let password = txtPassword.text else {
            return
        }
        if password.isEmpty {
            self.showAlert(alertMessage: R.string.localizable.pleaseEnterPassword())
            return
        }
        emailLogin(email, password: password)
    }

    func emailLogin(_ email: String, password: String) {
        UIApplication.checkInternetConnection()
        self.showHUD()
        ProManagerApi.logIn(email: email, password: password, deviceToken: "").request(Result<User>.self).subscribe(onNext: { (responce) in
            self.dismissHUD()
            print(responce)
            print("advanceGameMode \(String(describing: responce.result?.advanceGameMode))")
            if responce.status == ResponseType.success {
                self.goHomeScreen(responce)
            } else {
                self.showAlert(alertMessage: responce.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            print(error)
        }, onCompleted: {
            print("Compl")
        }).disposed(by: rx.disposeBag)
    }
    
    func socialLoadProfile(socialLogin: SocialLogin, completion: @escaping (LoginUserData?) -> ()) {
        switch socialLogin {
        case .facebook:
            if FaceBookManager.shared.isUserLogin {
                FaceBookManager.shared.loadUserData { (userModel) in
                    completion(userModel)
                }
            }
        case .twitter:
            if TwitterManger.shared.isUserLogin {
                TwitterManger.shared.loadUserData { (userModel) in
                    completion(userModel)
                }
            }
        case .snapchat:
            if SnapKitManager.shared.isUserLogin {
                SnapKitManager.shared.loadUserData { (userModel) in
                    completion(userModel)
                }
            }
        case .youtube:
            if GoogleManager.shared.isUserLogin {
                GoogleManager.shared.loadUserData { (userModel) in
                    completion(userModel)
                }
            }
        case .apple:
            if #available(iOS 13.0, *) {
                if AppleSignInManager.shared.isUserLogin {
                    AppleSignInManager.shared.loadUserData { (userModel) in
                        completion(userModel)
                    }
                }
            }
        default: break
        }
    }
    
    @IBAction func btnSocialLoginClicked(_ sender: UIButton) {
        
        self.socialLogin(SocialLogin(rawValue: sender.tag) ?? .facebook) { isCompleted in
            if isCompleted {
                var provider: String = "facebook"
                switch SocialLogin(rawValue: sender.tag) ?? .facebook {
                case .twitter:
                    provider = "twitter"
                case .instagram:
                    provider = "instagram"
                case .snapchat:
                    provider = "snapchat"
                case .youtube:
                    provider = "google"
                case .apple:
                    provider = "apple"
                default:
                    break
                }
                if SocialLogin(rawValue: sender.tag) ?? .facebook == .instagram {
                    return
                }
                
                for item in SocialLogin.allValues {
                    if SocialLogin(rawValue: sender.tag) ?? .facebook != item {
                        self.socialLogout(socialLogin: item) { _ in
                            
                        }
                    }
                }
                
                self.socialLoadProfile(socialLogin: SocialLogin(rawValue: sender.tag) ?? .facebook) { [weak self] (userModel) in
                    guard let `self` = self, let userData = userModel else {
                        return
                    }
                    self.loginSocial(fname: userData.userName ?? "", email: userData.email, socialId: userData.userId ?? "", provider: provider, profileImageURL: userData.photoUrl, bannerImageURL: nil)
                }
            }
        }
    }
    
    func socialLogout(socialLogin: SocialLogin, completion: @escaping (Bool) -> ()) {
        switch socialLogin {
        case .facebook:
            if FaceBookManager.shared.isUserLogin {
                FaceBookManager.shared.logout()
                completion(false)
            }
        case .twitter:
            DispatchQueue.main.async {
                if TwitterManger.shared.isUserLogin {
                    TwitterManger.shared.logout()
                    completion(false)
                }
            }
        case .instagram:
            if InstagramManager.shared.isUserLogin {
                InstagramManager.shared.logout()
                completion(false)
            }
        case .snapchat:
            if SnapKitManager.shared.isUserLogin {
                SnapKitManager.shared.logout { _ in
                    completion(false)
                }
            }
        case .youtube:
            if GoogleManager.shared.isUserLogin {
                GoogleManager.shared.logout()
                completion(false)
            }
        case .storiCam:
            break
        case .apple:
            if #available(iOS 13.0, *) {
                if AppleSignInManager.shared.isUserLogin {
                    AppleSignInManager.shared.logout()
                    completion(false)
                }
            }
        }
    }
    
    func loginSocial(fname: String, email: String? = nil, socialId: String, provider: String, profileImageURL: String?, bannerImageURL: String?) {
        UIApplication.checkInternetConnection()
        ApplicationSettings.shared.postURL = profileImageURL
        ApplicationSettings.shared.coverUrl = bannerImageURL
        ProManagerApi.socialLogin(socialId: socialId, email: email).request(Result    <User>.self).subscribe(onNext: { (responce) in
            if responce.status == ResponseType.success {
                if responce.message == "Signed Up" {
                    let dict = ["socialEmail": email, "socialId": socialId, "provider": provider]
                    self.performSegue(withIdentifier: "SignUpStep1", sender: dict)
                } else if responce.message == "Logged In" {
                    self.goHomeScreen(responce)
                }
            }
        }, onError:{ error  in
            print(error)
        }, onCompleted: {
            
        }).disposed(by: self.rx.disposeBag)
    }
    
    func socialLogin(_ socialLogin: SocialLogin, completion: @escaping (Bool) -> ()) {
        switch socialLogin {
        case .facebook:
            FaceBookManager.shared.login(controller: self, loginCompletion: { (_, _) in
                completion(true)
            }) { (_, _) in
                completion(false)
            }
        case .twitter:
            TwitterManger.shared.logout()
            TwitterManger.shared.login { (_, _) in
                completion(true)
            }
        case .instagram:
            InstagramManager.shared.logout()
            let loginViewController: WebViewController = WebViewController()
            loginViewController.delegate = self
            self.present(loginViewController, animated: true) {
                completion(true)
            }
        case .snapchat:
            SnapKitManager.shared.logout { (isCompleted) in
                SnapKitManager.shared.login(viewController: self) { (isLogin, error) in
                    if !isLogin {
                        DispatchQueue.main.async {
                            self.showAlert(alertMessage: error ?? "")
                        }
                    }
                    completion(isLogin)
                }
            }
        case .youtube:
            GoogleManager.shared.logout()
            GoogleManager.shared.login(controller: self, complitionBlock: { (_, _) in
                completion(true)
            }) { (_, _) in
                completion(false)
            }
        case .apple:
            if #available(iOS 13.0, *) {
                AppleSignInManager.shared.logout()
                AppleSignInManager.shared.login(controller: self, complitionBlock: { (_, _) in
                    completion(true)
                }) { (_, _) in
                    completion(false)
                }
            }
        default:
            break
        }
    }
    
    func goHomeScreen(_ responce: Result<User>) {
        Defaults.shared.sessionToken = responce.sessionToken
        Defaults.shared.currentUser = responce.result
        CurrentUser.shared.setActiveUser(responce.result)
        Crashlytics.crashlytics().setUserID(CurrentUser.shared.activeUser?.username ?? "")
        CurrentUser.shared.createNewReferrerChannelURL { (_, _) -> Void in

        }
        let parentId = Defaults.shared.currentUser?.parentId ?? Defaults.shared.currentUser?.id
        Defaults.shared.parentID = parentId
        #if !IS_SHAREPOST && !IS_MEDIASHARE && !IS_VIRALVIDS  && !IS_SOCIALVIDS && !IS_PIC2ARTSHARE
        self.goToHomeScreen()
        #endif
        self.doLogin()
        self.delegate?.loginDidFinish(user: Defaults.shared.currentUser, error: nil, fromSignup: false)
        self.dismiss(animated: true)
    }
    
    func newShareURL() {
        let param: [String: Any] = ["deepLinkUrl": CurrentUser.shared.referrerChannelURL ?? ""]
       
        ProManagerApi.updateProfile(param: param).request(Result<User>.self).subscribe(onNext: { response in
            if response.status == ResponseType.success {
                self.dismissHUD()
                Defaults.shared.currentUser = response.result
                CurrentUser.shared.setActiveUser(response.result)
            }
        }, onError: { error in
            print(error.localizedDescription)
        }, onCompleted: {
            
        }).disposed(by: (rx.disposeBag))
    }
    
    func doLogin() {
        ProManagerApi.doLogin(userId: (Defaults.shared.currentUser?.id)!).request(Result<PromanagerData>.self).subscribe { _ in
            
            }.disposed(by: rx.disposeBag)
    }
    
    func goToHomeScreen() {
        #if PIC2ARTAPP || TIMESPEEDAPP || BOOMICAMAPP
        Utils.appDelegate?.window?.rootViewController = R.storyboard.pageViewController.pageViewController()
        #else
        let addSocialConnectionViewController = R.storyboard.socialConnection.addSocialConnectionViewController()
        addSocialConnectionViewController?.fromLogin = true
        Utils.appDelegate?.window?.rootViewController = addSocialConnectionViewController
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        #endif
    }
    
    @IBAction func btnShowHidePassWordClicked(sender: Any) {
        self.txtPassword.isSecureTextEntry = !self.txtPassword.isSecureTextEntry
        if self.txtPassword.isSecureTextEntry == true {
            self.btnHidePassWord.setImage(R.image.hidePassword(), for: .normal)
        } else {
            self.btnHidePassWord.setImage(R.image.showPassword(), for: .normal)
        }
    }
    
    @IBAction func btnForgotClicked(sender: Any) {
        let url = "\(keycloakUrl)\(keycloakForogtPasswordClientId)\(KeycloakRedirectLink.keycloakRedirectLinkName.lowercased())\(KeycloakRedirectLink.endUrl)"
        goToKeycloakWebview(url: url)
        Defaults.shared.callHapticFeedback(isHeavy: false)
        Defaults.shared.addEventWithName(eventName: Constant.EventName.click_forgotpsw)

    }
    
    @IBAction func btnSignUpClicked(sender: Any) {
        guard let signupController = R.storyboard.loginViewController.signUpStepOneViewController() else {
            return
        }
        signupController.delegate = self
        let navigation: UINavigationController = UINavigationController(rootViewController: signupController)
        navigation.isNavigationBarHidden = true
        self.present(navigation, animated: true)
    }
    
    @IBAction func btnTermsAndConditionsTapped(_ sender: Any) {
        Defaults.shared.callHapticFeedback(isHeavy: false)
        guard let termsAndConditionsVc = R.storyboard.legal.legalViewController() else { return }
        self.navigationController?.pushViewController(termsAndConditionsVc, animated: true)
    }
    
    @IBAction func btnPrivacyPolicyTapped(_ sender: Any) {
        Defaults.shared.callHapticFeedback(isHeavy: false)
        guard let privacyPolicyVc = R.storyboard.legal.legalViewController() else { return }
        privacyPolicyVc.isTermsAndConditions = false
        self.navigationController?.pushViewController(privacyPolicyVc, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SignUpStep1" {
            if let dest = segue.destination as? UINavigationController {
                if let dest = dest.viewControllers.first as? SignUpStepOneViewController {
                    dest.delegate = self
                    if let dict = sender as? [String: Any] {
                        dest.isSocial = true
                        dest.socialDict = dict
                    }
                }
            }
            
        }
    }
}

extension LoginViewController: LoginViewControllerDelegate {
    func loginDidFinish(user: User?, error: Error?, fromSignup: Bool) {
        self.dismiss(animated: true) {
            if fromSignup {
                let vc = R.storyboard.socialConnection.addSocialConnectionViewController()
                vc?.fromLogin = true
                let navVC = UINavigationController(rootViewController: vc!)
                navVC.isNavigationBarHidden = true
                Utils.appDelegate?.window?.rootViewController = navVC
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
            } else {
                self.goToHomeScreen()
                self.delegate?.loginDidFinish(user: user, error: error, fromSignup: fromSignup)
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if txtEmail == textField {
            textField.resignFirstResponder()
            txtPassword.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            self.btnLoginClicked(nil)
        }
        return true
    }
    
}

extension LoginViewController: InstagramLoginViewControllerDelegate, ProfileDelegate {
    
    func profileDidLoad(profile: ProfileDetailsResponse) {
        self.loginSocial(fname: profile.username ?? "", email: "", socialId: profile.id ?? "", provider: "instagram", profileImageURL: profile.profilePicUrl, bannerImageURL: nil)
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
