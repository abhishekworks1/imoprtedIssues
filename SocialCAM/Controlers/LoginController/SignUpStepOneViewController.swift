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
    @IBOutlet weak var viewPasswordRules: UIView!
    @IBOutlet var txtEmail: SkyFloatingLabelTextField!
    @IBOutlet var txtPassWord: SkyFloatingLabelTextField!
    @IBOutlet var txtChannel: SkyFloatingLabelTextField!
    @IBOutlet var txtBirthdate: SkyFloatingLabelTextField!
    @IBOutlet var txtChannelTitle: SkyFloatingLabelTextField!
    @IBOutlet var txtRefChannel: SkyFloatingLabelTextField!
    @IBOutlet var imgViewCheck: UIImageView!
    @IBOutlet var lblCount: PLabel!
    @IBOutlet var viewChannelBox: UIView!
    @IBOutlet var viewBirthdate: UIView!
    @IBOutlet var lblChannel: PLabel!
    @IBOutlet var viewPassWord: UIView!
    @IBOutlet var btnHidePassWord: PButton!
    @IBOutlet weak var imgSpecialCharactersValidation: UIImageView!
    @IBOutlet weak var imgNumberValidation: UIImageView!
    @IBOutlet weak var imgCapitalValidation: UIImageView!
    @IBOutlet weak var imgLengthValidation: UIImageView!
    var profileImg: String?
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var lblChannelNameError: PLabel!
    @IBOutlet weak var lblEmailError: PLabel!
    @IBOutlet weak var lblPasswordError: PLabel!
    
    // MARK :-- iVars ---
    
    weak var delegate: LoginViewControllerDelegate?
    var refereUserId: String!
    var isRefChannel: Bool = false
    var isRefChannelRefresh: Bool = true
    var isChannel: Bool = false
    var isEmail: Bool = false
    var isBusiness: Bool = false
    var isSocial: Bool = false
    var socialDict: [String: Any]?
    let dropDownMenu = DropDown()
    var isPasswordValid: Bool = false
    var isCharUpperCase: Bool = false
    
    // MARK: - ---  View Life Cycle Methods ----
    
    deinit {
        print("Deinit \(self.description)")
    }
    
    @objc func tapGesture(_ recognizer: UITapGestureRecognizer) {
        DateTimePicker.selectDate(maxDate: Date() - 13) { [weak self] (selectedDate) in
            guard let `self` = self else {
                return
            }
            self.txtBirthdate.text = selectedDate.dateString("MM-dd-YYYY")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isBusiness = false
        
        imgLogo.image = R.image.uploadProfileImage()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture(_:)))
        viewBirthdate.addGestureRecognizer(tapGesture)
        self.txtBirthdate.isUserInteractionEnabled = false
        
        if socialDict != nil {
            if let provider: String = self.socialDict?["provider"] as? String {
                self.showAlert(alertMessage: "\(provider) login successfully.")
            }
            
            if let providerEmail = self.socialDict?["socialEmail"] as? String {
                txtEmail.text = providerEmail
            }
            
            if let profileImg = ApplicationSettings.shared.postURL {
                imgLogo.setImageFromURL(profileImg)
            }
        }
        
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
        
        setupDefaultDropDown()
        setColorTextField(views: [txtChannel, txtEmail, txtPassWord, txtRefChannel])
        setupChannel()
        setupRefChannel()
        setupEmailField()
        
        self.lblCount.text = "\(String(describing: self.txtChannel.text?.count ?? 0))/\(Constant.Value.maxChannelName)"
    }
    
    func setupDefaultDropDown() {
        DropDown.setupDefaultAppearance()
        dropDownMenu.cellNib = UINib(nibName: "MyCell", bundle: nil)
        dropDownMenu.anchorView = txtRefChannel
        dropDownMenu.topOffset = CGPoint(x: 0, y: -50)
        dropDownMenu.direction = .top
    }
    
    func setupChannel() {
        let isExistChannel = self.txtChannel?.rx.text.orEmpty.filter { $0.count > 6}.throttle(0.5, scheduler: MainScheduler.instance).distinctUntilChanged().flatMapLatest( { (channel: String) -> Observable<Result<User>> in
            return ProManagerApi
                .verifyChannel(channel: channel, type: "channelId")
                .request(Result<User>.self)
        })
        isExistChannel?.subscribe(onNext: { user in
            if user.status == ResponseType.success {
                self.isChannel = true
            } else {
                self.isChannel = false
                self.dismissHUDWithError(R.string.localizable.channelNameAlreadyExist())
            }
        }, onError: { _ in
            self.showAlert(alertMessage: R.string.localizable.somethingWentWrongPleaseTryAgainLater())
        }, onCompleted: {
        }).disposed(by: rx.disposeBag)
    }
    
    func setupRefChannel() {
        let isRefExist = self.txtRefChannel?.rx.text.orEmpty.filter { $0.count > 3}.throttle(0.5, scheduler: MainScheduler.instance).distinctUntilChanged().flatMapLatest( { (channel: String) -> Observable<ResultArray<Channel>> in
            if self.isRefChannelRefresh {
                self.showHUD()
            }
            return ProManagerApi
                .search(channel: channel, channelId: "")
                .request(ResultArray<Channel>.self)
        })
        
        isRefExist?.subscribe(onNext: { response in
            self.dismissHUD()
            if response.status == ResponseType.success {
                let channels: [Channel] = response.result!
                var menuItems: [DropDownMenuItem] = []
                var dataSource: [String] = []
                for item in channels {
                    let menuItem: DropDownMenuItem? = DropDownMenuItem(title: item.channelId)
                    guard let menuItemData = menuItem else {
                        return
                    }
                    menuItems.append(menuItemData)
                    guard let channelId = item.channelId else {
                        return
                    }
                    dataSource.append(channelId)
                }
                if menuItems.count == 0 {
                    self.isRefChannel = false
                    self.isRefChannelRefresh = true
                }
                
                self.dropDownMenu.dataSource = dataSource
                
                // Action triggered on selection
                self.dropDownMenu.selectionAction = { [weak self] (index, item) in
                    self!.txtRefChannel.text = channels[index].channelId
                    self!.refereUserId = channels[index].id
                    self!.isRefChannel = true
                    self!.isRefChannelRefresh = true
                }
                self.dropDownMenu.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
                    guard let cell = cell as? MyCell else { return }
                    cell.logoImageView.setImageFromURL(channels[index].profileImageURL, placeholderImage: R.image.userBitmoji())
                }
                self.dropDownMenu.show()
                print("true")
                self.isRefChannel = false
            } else {
                print("false")
                self.isRefChannel = true
            }
        }, onError: { (error: Error) in
            self.dismissHUD()
            print("false")
            self.viewChannelBox.isHidden = true
        }, onCompleted: {
            
        }).disposed(by: rx.disposeBag)
    }
    
    func setupEmailField() {
        let isEmailExist = self.txtEmail?.rx.text.orEmpty.filter {
            return $0.isValidEmail()
        }.throttle(0.5, scheduler: MainScheduler.instance).distinctUntilChanged().flatMapLatest({ (channel:String) -> Observable<Result<User>> in
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    // MARK : ---  Action Methods ---
    
    @IBAction func btnTermsAndConditionsTapped(_ sender: Any) {
        guard let termsAndConditionsVc = R.storyboard.legal.legalViewController() else { return }
        self.navigationController?.pushViewController(termsAndConditionsVc, animated: true)
    }
    
    @IBAction func btnPrivacyPolicyTapped(_ sender: Any) {
        guard let privacyPolicyVc = R.storyboard.legal.legalViewController() else { return }
        privacyPolicyVc.isTermsAndConditions = false
        self.navigationController?.pushViewController(privacyPolicyVc, animated: true)
    }
    
    @IBAction func btnShowHidePassWordClicked(sender:Any) {
        self.txtPassWord.isSecureTextEntry = !self.txtPassWord.isSecureTextEntry
        if self.txtPassWord.isSecureTextEntry == true {
            self.btnHidePassWord.setImage(R.image.hidePassword(), for: .normal)
        } else {
            self.btnHidePassWord.setImage(R.image.showPassword(), for: .normal)
        }
    }
    
    @IBAction func btnNextClicked(_ sender: Any) {
        guard let email = txtEmail.text,
            let password = txtPassWord.text,
            let birthdate = txtBirthdate.text,
            let refChannel = txtRefChannel.text,
            let channel = txtChannel.text else {
                return
        }
        if channel.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            self.showAlert(alertMessage: R.string.localizable.pleaseEnterUniqueChannelName())
        } else if channel.trimmingCharacters(in: .whitespacesAndNewlines).count <= Constant.Value.channelName {
            self.showAlert(alertMessage: R.string.localizable.channelNameMustBeOf1630Characters())
        } else if email.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            self.showAlert(alertMessage: R.string.localizable.pleaseEnterEmail())
        } else if !email.isValidEmail() {
            self.showAlert(alertMessage: R.string.localizable.pleaseEnterValidEmail())
        } else if !self.isEmail {
            self.showAlert(alertMessage: R.string.localizable.emailAlreadyExist())
        } else if password.isEmpty {
            self.showAlert(alertMessage: R.string.localizable.pleaseEnterPassword())
        } else if !isPasswordValid {
            self.showAlert(alertMessage: R.string.localizable.invalidPassword())
        } else if refChannel.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            self.showAlert(alertMessage: R.string.localizable.pleaseEnterTheNameOfYourReferringChannelIfYouDoNotHaveOneUseTheSearchFeatureToFindAChannelToUse())
        } else if !isChannel {
            self.showAlert(alertMessage: R.string.localizable.channelNameAlreadyExist())
        } else {
            self.showHUD()
            var socialId: String? = nil
            var provider: String? = nil
            if self.isSocial {
                socialId = self.socialDict?["socialId"] as? String
                provider = self.socialDict?["provider"] as? String
            }
            var profileImageURL: String?
            if let profileImg = profileImg {
                profileImageURL = profileImg
            } else if profileImg == ApplicationSettings.shared.postURL {
                profileImageURL = profileImg
            }
            ProManagerApi.signUp(email: email, password: password, channel: channel, refChannel: refChannel, isBusiness: isBusiness, socialId: socialId, provider: provider, channelName: channel, refferId: self.refereUserId, deviceToken: "", birthDate: birthdate, profileImageURL: profileImageURL).request(Result<User>.self).subscribe(onNext: { result in
                self.dismissHUD()
                if result.status == ResponseType.success {
                    Defaults.shared.sessionToken = result.sessionToken
                    Defaults.shared.currentUser = result.result
                    CurrentUser.shared.setActiveUser(result.result)
                    ApplicationSettings.shared.postURL = nil
                    ApplicationSettings.shared.coverUrl = nil
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
            }, onCompleted: {
                
            }).disposed(by: rx.disposeBag)
        }
    }
    
    @IBAction func btnSearchClicked(_ sender: Any?) {
        let searchChannelViewController = R.storyboard.loginViewController.searchChannelViewController()
        searchChannelViewController?.ChanelHandler = { chanel in
            self.txtRefChannel.text = chanel.channelId
            self.isRefChannel = true
            self.refereUserId = chanel.id
            self.isRefChannelRefresh = false
        }
        self.navigationController?.pushViewController(searchChannelViewController!, animated: true)
    }
    
    @IBAction func btnProfileImageClicked(_ sender: UIButton) {
        let menuOptionsString: [String] = [R.string.localizable.camera(), R.string.localizable.photoLibrary()]
        
        BasePopConfiguration.shared.backgoundTintColor = R.color.appWhiteColor()!
        BasePopConfiguration.shared.menuWidth = 125
        BasePopConfiguration.shared.showCheckMark = .none
        BasePopOverMenu
            .showForSender(sender: sender, with: menuOptionsString, done: { [weak self] (selectedIndex) in
                guard let `self` = self else { return }
                if selectedIndex == 0 {
                    self.openCamera()
                } else {
                    self.openPhotoLibrary()
                }
                }, cancel: {
            })
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

extension SignUpStepOneViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if txtEmail == textField {
            textField.resignFirstResponder()
            txtPassWord.becomeFirstResponder()
            self.lblEmailError.text = (txtEmail.text?.isValidEmail() ?? false) ? nil : R.string.localizable.pleaseEnterValidEmail()
        } else if txtPassWord == textField {
            txtPassWord.resignFirstResponder()
            txtRefChannel.becomeFirstResponder()
            if let password = txtPassWord.text {
                if password.isEmpty {
                    lblPasswordError.text = R.string.localizable.pleaseEnterPassword()
                } else if !isPasswordValid {
                    lblPasswordError.text = R.string.localizable.invalidPassword()
                } else {
                    lblPasswordError.text = nil
                }
            }
        } else if txtRefChannel == textField {
            txtRefChannel.resignFirstResponder()
        } else if txtChannel == textField {
            txtChannel.resignFirstResponder()
            txtEmail.becomeFirstResponder()
            self.lblChannelNameError.text = (txtChannel.text?.count ?? 0) <= Constant.Value.channelName ? R.string.localizable.minimumCharactersRequired(Constant.Value.channelName.description) : nil
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
            self.viewPasswordRules.isHidden = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.viewPasswordRules.isHidden = (textField != self.txtPassWord)
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
            
            if txt.count <= Constant.Value.channelName {
                self.viewChannelBox.isHidden = true
                self.lblCount.textColor = UIColor.red
                self.isChannel = false
            } else {
                self.lblCount.textColor = ApplicationSettings.appPrimaryColor
            }
            self.lblCount.text = "\(txt.count)/\(Constant.Value.maxChannelName)"
            if txt.count >= Constant.Value.maxChannelName {
                return false
            }
            if (txtChannel.text?.count ?? 0) > Constant.Value.channelName {
                self.lblChannelNameError.text = nil
            }
        } else if txtRefChannel == textField {
            let specialCharacterRegEx  = "^[a-zA-Z0-9_]*$"
            let texttest2 = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
            let  specialresult = texttest2.evaluate(with: string)
            if !specialresult {
                return false
            }
            let txt = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            if txt.count <= Constant.Value.minChannelName {
                self.isRefChannel = false
            }
        } else if textField == self.txtPassWord {
            let text = ((textField.text ?? "" )as NSString).replacingCharacters(in: range, with: string)
            isPasswordValid = self.modifyPasswordRulesView(password: text)
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func modifyPasswordRulesView(password: String) -> Bool {
        let specialCharacterValidation = NSPredicate(format: "SELF MATCHES %@ ", ".*[^A-Za-z0-9].*")
        self.imgSpecialCharactersValidation.image = specialCharacterValidation.evaluate(with: password) ? R.image.passwordValid() : R.image.passwordInvalid()
        let numbersRange = password.rangeOfCharacter(from: .decimalDigits)
        self.imgNumberValidation.image = numbersRange != nil ? R.image.passwordValid() : R.image.passwordInvalid()
        
        for char in password {
            if char.isUppercase {
                self.imgCapitalValidation.image = R.image.passwordValid()
                isCharUpperCase = true
                break
            } else {
                self.imgCapitalValidation.image = R.image.passwordInvalid()
                isCharUpperCase = false
            }
        }
        self.imgLengthValidation.image =   password.length >= 8 ? R.image.passwordValid() : R.image.passwordInvalid()
        if specialCharacterValidation.evaluate(with: password), numbersRange != nil, password.length >= 8, isCharUpperCase {
            return true
        } else {
            return false
        }
    }
    
}

extension SignUpStepOneViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.imagePicker = UIImagePickerController()
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing =  true
            self.imagePicker.delegate = self
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            self.imagePicker = UIImagePickerController()
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing =  true
            self.imagePicker.delegate = self
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        var img: UIImage = UIImage()
        if let imgData = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            img = imgData
        } else if let imgData = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            img = imgData
        }
        self.imgLogo.image = img
        
        Utils.uploadImage(imgName: String.fileName, img: img, callBack: { (url) -> Void? in
            self.profileImg = url
            return nil
        })
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension Date {
    static func -(lhs: Date, rhs: Int) -> Date {
        return Calendar.current.date(byAdding: .year, value: -rhs, to: lhs)!
    }
}
