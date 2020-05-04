//
//  SignUpStepOneViewController.swift
//  ViralCam
//
//  Created by Viraj Patel on 26/03/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import SkyFloatingLabelTextField
import RxCocoa
import RxSwift
import NSObject_Rx

enum SignUpStep :Int {
    case stepOne = 1
    case stepTwo = 2
    case stepThree = 3
    case stepFour = 4
}

class SignUpStepOneViewController: UIViewController {
    
    // MARK :-- IBOutlets ---
    @IBOutlet var txtEmail : SkyFloatingLabelTextField!
    @IBOutlet var txtPassWord : SkyFloatingLabelTextField!
    @IBOutlet var txtChannel : SkyFloatingLabelTextField!
    @IBOutlet var txtBirthdate : SkyFloatingLabelTextField!
    @IBOutlet var txtChannelTitle : SkyFloatingLabelTextField!
    @IBOutlet var txtRefChannel : SkyFloatingLabelTextField!
    @IBOutlet var imgViewCheck : UIImageView!
    @IBOutlet var lblCount : PLabel!
    @IBOutlet var viewChannelBox : UIView!
    @IBOutlet var viewBirthdate : UIView!
    @IBOutlet var lblChannel : PLabel!
    @IBOutlet var viewPassWord : UIView!
    @IBOutlet var btnHidePassWord : PButton!
    
    @IBOutlet weak var imgLogo: UIImageView!
    // MARK :-- iVars ---
    
    weak var delegate: LoginViewControllerDelegate?
    var refereUserId: String!
    var isRefChannel: Bool = false
    var isRefChannelRefresh: Bool = true
    var isChannel: Bool = false
    var isEmail: Bool = false
    var isBusiness: Bool = false
    var isSocial: Bool = false
    var socialDict: [String:Any]?
    var dropDownMenu: DropDownMenu?
    
    // MARK : ---  View Life Cycle Methods ----
    
    deinit {
        print("Deinit \(self.description)")
    }

    @objc func tapGesture(_ recognizer: UITapGestureRecognizer) {
        DateTimePicker.selectDate(maxDate: Date()) { [weak self] (selectedDate) in
            // TODO: Your implementation for date
            guard let `self` = self else {
                return
            }
            self.txtBirthdate.text = selectedDate.dateString("MM-dd-YYYY")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isBusiness =  false
        
        #if VIRALCAMAPP
        imgLogo.image = R.image.viralcamrgb()
        #endif
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture(_:)))
        viewBirthdate.addGestureRecognizer(tapGesture)
        self.txtBirthdate.isUserInteractionEnabled = false
          
        AppEventBus.onMainThread(self, name: "channelName") { [weak self] (result) in
            guard let `self` = self else {
                return
            }
            if let refereUserId = result?.object as? String {
                self.refereUserId = refereUserId
                self.txtRefChannel.text = refereUserId
                self.isRefChannel = true
            }
        }    
        
        if let refereId = self.refereUserId {
            self.txtRefChannel.text = refereId
            self.isRefChannel = true
        }
        self.setColorTextField(views: [txtEmail,
                                       txtPassWord,
                                       txtRefChannel])
        
        dropDownMenu = DropDownMenu(view: self.txtRefChannel, menuItems: nil)
        dropDownMenu?.hidesOnSelection = true
        
        let isRefExist = self.txtRefChannel?.rx.text.orEmpty.filter{ $0.count > 3}.throttle(0.5, scheduler:MainScheduler.instance).distinctUntilChanged().flatMapLatest( { (channel: String) -> Observable<ResultArray<Channel>> in
            if self.isRefChannelRefresh {
                self.showHUD()
            }
            return ProManagerApi
                .search(channel: channel)
                .request(ResultArray<Channel>.self)
        })
        
        isRefExist?.subscribe(onNext: { response in
            self.dismissHUD()
            if response.status == ResponseType.success {
                let channels: [Channel] = response.result!
                var menuItems: [DropDownMenuItem] = []
                for item in channels {
                    let menuItem: DropDownMenuItem? = DropDownMenuItem(title: item.channelId)
                    guard let item = menuItem else {
                        return
                    }
                    menuItems.append(item)
                }
                if menuItems.count == 0 {
                    self.isRefChannel = false
                    self.isRefChannelRefresh = true
                }
                self.dropDownMenu?.setMenuItems(menuItems)
                self.dropDownMenu?.hide()
                self.dropDownMenu?.show { dropDownMenu, menuItem, index in
                    self.txtRefChannel.text = channels[index].channelId
                    self.refereUserId = channels[index].id
                    self.isRefChannel = true
                    self.isRefChannelRefresh = true
                }
                print("true")
                self.isRefChannel = false
            } else {
                print("false")
                self.isRefChannel = true
            }
        }, onError: { (error:Error) in
            self.dismissHUD()
            print("false")
            self.viewChannelBox.isHidden = true
        }, onCompleted: {
            
        }).disposed(by: rx.disposeBag)
        
        let isEmailExist = self.txtEmail?.rx.text.orEmpty.filter {
            return $0.isValidEmail()
        }.throttle(0.5, scheduler:MainScheduler.instance).distinctUntilChanged().flatMapLatest({ (channel:String) -> Observable<Result<User>> in
            return  ProManagerApi
                .verifyChannel(channel: channel, type: "email")
                .request(Result<User>.self)
        })
        
        isEmailExist?.subscribe(onNext: { user in
            if user.status == ResponseType.success {
                print("true")
                self.isEmail = true
            } else {
                print("false")
                self.isEmail = false
            }
        }, onError: { (error:Error) in
            print("false")
            self.isEmail = false
        }, onCompleted: {
            
        }).disposed(by: rx.disposeBag)
        
        self.lblCount.text = "\(String(describing: self.txtChannel.text?.count ?? 0))/25"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    // MARK : ---  Action Methods ---
    
    @IBAction func btnShowHidePassWordClicked(sender:Any) {
        self.txtPassWord.isSecureTextEntry = !self.txtPassWord.isSecureTextEntry
        if self.txtPassWord.isSecureTextEntry == true {
            self.btnHidePassWord.setImage(R.image.hidePassword(), for: .normal)
        } else {
            self.btnHidePassWord.setImage(R.image.showPassword(), for: .normal)
        }
    }
    
    @IBAction func btnNextClicked(_ sender:Any) {
        guard let email = txtEmail.text,
            let password = txtPassWord.text,
            let birthdate = txtBirthdate.text,
            let refChannel = txtRefChannel.text else {
                return
        }
        if email.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            self.showAlert(alertMessage: R.string.localizable.pleaseEnterEmail())
        } else if !email.isValidEmail() {
            self.showAlert(alertMessage: R.string.localizable.pleaseEnterValidEmail())
        } else if !self.isEmail {
            self.showAlert(alertMessage: R.string.localizable.emailAlreadyExist())
        } else if password.isEmpty {
            self.showAlert(alertMessage: R.string.localizable.pleaseEnterPassword())
        } else if birthdate.isEmpty {
            self.showAlert(alertMessage: R.string.localizable.pleaseSelectBirthdate())
        } else if refChannel.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            self.showAlert(alertMessage: R.string.localizable.pleaseEnterTheNameOfYourReferringChannelIfYouDoNotHaveOneUseTheSearchFeatureToFindAChannelToUse())
        } else if !self.isRefChannel {
            self.showAlert(alertMessage: R.string.localizable.referringChannelDoesNotExist())
        } else {
            self.showHUD()
            var socialId: String? = nil
            var provider: String? = nil
            if self.isSocial {
                socialId = self.socialDict?["socialId"] as? String
                provider = self.socialDict?["provider"] as? String
            }
            ProManagerApi.signUp(email: email, password: password, channel: email, refChannel: refChannel, isBusiness: isBusiness, socialId: socialId, provider: provider, channelName: email, refferId: self.refereUserId,deviceToken: "", birthDate: birthdate).request(Result<User>.self).subscribe(onNext: { result in
                self.dismissHUD()
                if result.status == ResponseType.success {
                    Defaults.shared.sessionToken = result.sessionToken
                    Defaults.shared.currentUser = result.result
                    CurrentUser.shared.setActiveUser(result.result)
                    ApplicationSettings.shared.postURl = ""
                    ApplicationSettings.shared.coverUrl = ""
                    self.emailConfirm(email: email)
                    self.dismiss(animated: false) {
                        self.delegate?.loginDidFinish(user: Defaults.shared.currentUser, error: nil, fromSignup: false)
                    }
                } else {
                    self.dismissHUD()
                    self.showAlert(alertMessage: result.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
                }
            }, onError: { error in
                self.dismissHUD()
            }, onCompleted:{
                
            }).disposed(by: rx.disposeBag)
        }
    }
    
    @IBAction func btnSearchClicked(_ sender:Any?) {
        self.dropDownMenu?.hide()
        let searchChannelViewController = R.storyboard.loginViewController.searchChannelViewController()
        searchChannelViewController?.ChanelHandler = { chanel in
            self.txtRefChannel.text = chanel.channelId
            self.isRefChannel = true
            self.refereUserId = chanel.id
            self.isRefChannelRefresh = false
        }
        self.navigationController?.pushViewController(searchChannelViewController!, animated: true)
    }
    
    @IBAction func btnBusinessClicked(_ sender : Any) {
        self.isBusiness = !self.isBusiness
    }
    
    func setColorTextField(views : [SkyFloatingLabelTextField]) {
        for textField in views {
            textField.titleColor = ApplicationSettings.appPrimaryColor
            textField.selectedTitleColor = ApplicationSettings.appPrimaryColor
        }
    }
    
    func emailConfirm(email: String) {
        ProManagerApi.confirmEmail(userId: (Defaults.shared.currentUser?.id)!, email: email).request(Result<PromanagerData>.self).subscribe(onNext: { result in
            
        }, onError: { (error) in
            
        }, onCompleted: {
            
        }).disposed(by: rx.disposeBag)
    }
    
}

extension SignUpStepOneViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if txtEmail == textField {
            textField.resignFirstResponder()
            txtPassWord.becomeFirstResponder()
        } else if txtPassWord == textField {
            txtPassWord.resignFirstResponder()
            txtRefChannel.becomeFirstResponder()
        } else if txtRefChannel == textField {
            txtRefChannel.resignFirstResponder()
        } else if txtChannel == textField {
            txtChannel.resignFirstResponder()
            txtChannelTitle.becomeFirstResponder()
        } else if txtChannelTitle == textField {
            DispatchQueue.main.async {
                self.txtChannelTitle.resignFirstResponder()
                self.txtEmail.becomeFirstResponder()
            }
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtChannel {
            let specialCharacterRegEx  = "^[a-zA-Z0-9_]*$"
            let texttest2 = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
            let  specialresult = texttest2.evaluate(with: string)
            if !specialresult {
                return false
            }
            let txt = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            
            if txt.count < 4 {
                self.viewChannelBox.isHidden = true
                self.lblCount.textColor = UIColor.red
                self.isChannel = false
            } else {
                self.lblCount.textColor = ApplicationSettings.appPrimaryColor
            }
            self.lblCount.text = "\(txt.count)/25"
            if txt.count >= 25 {
                return false
            }
        } else if txtRefChannel == textField {
            let specialCharacterRegEx  = "^[a-zA-Z0-9_]*$"
            let texttest2 = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
            let  specialresult = texttest2.evaluate(with: string)
            if !specialresult {
                return false
            }
            let txt = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            if txt.count < 4 {
                self.isRefChannel = false
            }
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
}
