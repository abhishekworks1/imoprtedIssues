//
//  ForgotPasswordViewController.swift
//  SocialCAM
//
//  Created by Nilisha Gupta on 08/02/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    
    // MARK: - Outlets Declaration
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var sentEmailView: UIView!
    @IBOutlet weak var resetPasswordStatusView: UIView!
    @IBOutlet weak var lblResetPassword: UILabel!
    @IBOutlet weak var lblResetPasswordInfo: UILabel!
    @IBOutlet weak var btnResetPassword: UIButton!
    @IBOutlet weak var emailAddressView: UIView!
    @IBOutlet weak var resetPasswordlblHeight: NSLayoutConstraint!
    @IBOutlet weak var resetPasswordViewHeight: NSLayoutConstraint!
    @IBOutlet weak var emailLogo: UIButton!
    @IBOutlet weak var userNotFoundLabel: UILabel!
    @IBOutlet weak var borderView: BorderView!
    @IBOutlet weak var btnNotReceivedMail: UIButton!
    @IBOutlet weak var btnNotReceivedHeight: NSLayoutConstraint!
    
    // MARK: - Variables
    var isLoginNow: Bool = false
    var isResendLink: Bool = false
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup UI Methods
    private func setupUI() {
        blurView.isHidden = true
        sentEmailView.isHidden = true
        btnNotReceivedMail.isHidden = true
        txtEmail.delegate = self
        #if SOCIALCAMAPP
        imgLogo.image = R.image.socialCamSplashLogo()
        #elseif VIRALCAMAPP
        imgLogo.image = R.image.viralcamrgb()
        #elseif SOCCERCAMAPP || FUTBOLCAMAPP
        imgLogo.image = R.image.soccercamWatermarkLogo()
        #elseif QUICKCAMAPP
        imgLogo.image = R.image.ssuQuickCam()
        #elseif SNAPCAMAPP
        imgLogo.image = R.image.snapcamWatermarkLogo()
        #elseif SPEEDCAMAPP
        imgLogo.image = R.image.ssuSpeedCam()
        #elseif TIMESPEEDAPP
        imgLogo.image = R.image.timeSpeedWatermarkLogo()
        #elseif FASTCAMAPP
        imgLogo.image = R.image.ssuFastCam()
        #elseif BOOMICAMAPP
        imgLogo.image = R.image.boomicamWatermarkLogo()
        #elseif VIRALCAMLITEAPP
        imgLogo.image = R.image.viralcamLiteWatermark()
        #elseif FASTCAMLITEAPP
        imgLogo.image = R.image.ssuFastCamLite()
        #elseif QUICKCAMLITEAPP
        imgLogo.image = R.image.ssuQuickCamLite()
        #elseif SPEEDCAMLITEAPP
        imgLogo.image = R.image.speedcamLiteSsu()
        #elseif SNAPCAMLITEAPP
        imgLogo.image = R.image.snapcamliteSplashLogo()
        #elseif RECORDERAPP
        imgLogo.image = R.image.socialScreenRecorderWatermarkLogo()
        #else
        imgLogo.image = R.image.pic2artWatermarkLogo()
        #endif
    }
    
    func setEmailSentView(isSuccess: Bool) {
        blurView.isHidden = !isSuccess
        sentEmailView.isHidden = !isSuccess
    }
    
    func resendLinkView() {
        imgLogo.image = R.image.emailSentLogo()
        isLoginNow = true
        btnNotReceivedMail.isHidden = false
        resetPasswordStatusView.isHidden = false
        emailAddressView.isHidden = true
        lblResetPassword.text = R.string.localizable.passwordResetSuccessfull()
        lblResetPasswordInfo.text = R.string.localizable.passwordChangedSuccessfullyMessage()
        btnNotReceivedHeight.constant = 19
        btnNotReceivedMail.isUserInteractionEnabled = true
        resetPasswordlblHeight.constant = 25
        resetPasswordViewHeight.constant = 25
        btnResetPassword.setTitle(R.string.localizable.loginNow(), for: .normal)
    }
    
    func setTextErrorView(isError: Bool) {
        userNotFoundLabel.isHidden = !isError
        isError ? emailLogo.setImage(R.image.iconfinderErrorProblemAlert(), for: .normal) : emailLogo.setImage(R.image.email(), for: .normal)
        if isError {
            borderView.borderColor = R.color.textFieldBorderErrorColor()
            borderView.borderWidth = 1
        } else {
            borderView.borderWidth = 0
        }
    }
    
    // MARK: - Action Methods
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnResetPasswordClicked(_ sender: UIButton) {
        if isLoginNow {
            self.navigationController?.popViewController(animated: true)
        } else {
            guard let emailText = txtEmail.text else {
                return
            }
            let email = emailText.trimmingCharacters(in: .whitespacesAndNewlines)
            if email.isEmpty {
                self.showAlert(alertMessage: R.string.localizable.pleaseEnterEmail())
                return
            }
            emailLogin(emailText)
        }
    }
    
    @IBAction func btnOkayClicked(_ sender: UIButton) {
        setEmailSentView(isSuccess: false)
        resendLinkView()
    }
    
    @IBAction func btnNotReceiveMailClicked(_ sender: UIButton) {
        btnNotReceivedMail.isUserInteractionEnabled = false
        btnResetPassword.setTitle(R.string.localizable.resendLink(), for: .normal)
        isLoginNow = false
        isResendLink = true
        lblResetPassword.text = R.string.localizable.passwordRequestSent()
        lblResetPasswordInfo.text = R.string.localizable.checkEmailMessage()
    }
    
}

// MARK: - API Configuration
extension ForgotPasswordViewController {
    
    func emailLogin(_ userName: String) {
        UIApplication.checkInternetConnection()
        self.showHUD()
        ProManagerApi.forgotPassword(username: userName).request(CalculatorConfigurationModel.self).subscribe(onNext: { (response) in
            self.dismissHUD()
            if response.status == ResponseType.success {
                self.setEmailSentView(isSuccess: true)
                self.setTextErrorView(isError: false)
            } else {
                self.setTextErrorView(isError: true)
            }
        }, onError: { error in
            self.dismissHUD()
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
    
}

// MARK: - TextField Delegate
extension ForgotPasswordViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.isEmpty ?? false) {
            setTextErrorView(isError: !(textField.text?.isEmpty ?? false))
        }
    }
    
}
