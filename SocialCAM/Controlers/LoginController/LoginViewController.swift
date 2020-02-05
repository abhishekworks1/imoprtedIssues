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
import Crashlytics

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
    func loginDidFinish(user: User?, error: Error?)
}

class LoginViewController: UIViewController, UIGestureRecognizerDelegate {
    // MARK: Properites
    var parentId: String = ""
    // MARK: IBOutlets
    @IBOutlet var txtEmail: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var txtPassword: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var btnHidePassWord: PButton!
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var logoLable: UILabel!
    weak var delegate: LoginViewControllerDelegate?
    
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtEmail.iconFont = UIFont.fontAwesome(ofSize: 12, style: .solid)
        txtEmail.iconText = String.fontAwesomeIcon(name: .check)
        txtPassword.iconFont = UIFont.fontAwesome(ofSize: 12, style: .solid)
        txtPassword.iconText = String.fontAwesomeIcon(name: .lock)
        setColorTextField(views: [txtEmail, txtPassword])
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
    
    // MARK: IBActions
    @IBAction func btnCloseClicked(_ sender: UIButton) {
        self.dismiss(animated: true)
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
            if responce.status == ResponseType.success {
                Defaults.shared.sessionToken = responce.sessionToken
                Defaults.shared.currentUser = responce.result
                CurrentUser.shared.setActiveUser(responce.result)
                Answers.logLogin(withMethod: nil, success: 1, customAttributes: ["id": CurrentUser.shared.activeUser?.username ?? ""])
                CurrentUser.shared.createNewReferrerChannelURL { (_, _) -> Void in

                }
                
                let parentId = Defaults.shared.currentUser?.parentId ?? Defaults.shared.currentUser?.id
                Defaults.shared.parentID = parentId
                
                self.doLogin()
                self.delegate?.loginDidFinish(user: Defaults.shared.currentUser, error: nil)
                self.dismiss(animated: true)
            } else {
                self.showAlert(alertMessage: responce.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            print(error)
        }, onCompleted: {
            print("Compl")
        }).disposed(by: rx.disposeBag)
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
    
    @IBAction func btnShowHidePassWordClicked(sender: Any) {
        self.txtPassword.isSecureTextEntry = !self.txtPassword.isSecureTextEntry
        if self.txtPassword.isSecureTextEntry == true {
            self.btnHidePassWord.setImage(R.image.hidePassword(), for: .normal)
        } else {
            self.btnHidePassWord.setImage(R.image.showPassword(), for: .normal)
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
