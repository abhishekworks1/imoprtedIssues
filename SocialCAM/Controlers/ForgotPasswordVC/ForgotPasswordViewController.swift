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
    @IBOutlet weak var emailNotReceivedLblHeight: NSLayoutConstraint!
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        blurView.isHidden = true
        sentEmailView.isHidden = true
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
    
    // MARK: - Action Methods
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnResetPasswordClicked(_ sender: UIButton) {
        blurView.isHidden = false
        sentEmailView.isHidden = false
    }
    
    @IBAction func btnOkayClicked(_ sender: UIButton) {
        blurView.isHidden = true
        sentEmailView.isHidden = true
        imgLogo.image = R.image.emailSentLogo()
        resetPasswordStatusView.isHidden = false
        emailAddressView.isHidden = true
        lblResetPassword.text = R.string.localizable.passwordRequestSent()
        lblResetPasswordInfo.text = R.string.localizable.checkEmailMessage()
        emailNotReceivedLblHeight.constant = 19
        resetPasswordlblHeight.constant = 25
        resetPasswordViewHeight.constant = 25
    }
    
}
