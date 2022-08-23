//
//  NotificationSettingCell.swift
//  SocialCAM
//
//  Created by Sanjaysinh Chauhan on 22/08/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class NotificationSettingCell: UITableViewCell {

    @IBOutlet weak var txtNumberOfSignup: UITextField!
    @IBOutlet weak var txtCameraAppSubscription: UITextField!
    
    @IBOutlet weak var txtBusinessDashboard: UITextField!
    
    @IBOutlet weak var btnBadgeEarnedCheckmark: UIButton!
    
    var objReferralNotification: GetReferralNotificationModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.updateTextFieldUI(textField: self.txtNumberOfSignup)
        self.updateTextFieldUI(textField: self.txtCameraAppSubscription)
        self.updateTextFieldUI(textField: self.txtBusinessDashboard)
        btnBadgeEarnedCheckmark.setImage(R.image.checkBoxInActive(), for: .normal)
        btnBadgeEarnedCheckmark.setImage(R.image.checkBoxActive(), for: .selected)
        self.selectionStyle = .none
    }
    
    func updateTextFieldUI(textField: UITextField) {
        textField.keyboardType = .numberPad
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 4.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell() {
        
        guard let numberOfUserText = self.objReferralNotification?.customSignupNumber else {
            return
        }
        guard let betweenCameraAppSubscription = self.objReferralNotification?.betweenCameraAppSubscription else {
            return
        }
        guard let betweenBusinessDashboardSubscription = self.objReferralNotification?.betweenBusinessDashboardSubscription else {
            return
        }
        guard let isBadgeEarned = self.objReferralNotification?.onReferralEarnSocialBadge else {
            return
        }
        self.txtNumberOfSignup.text = "\(numberOfUserText)"
        self.txtCameraAppSubscription.text = "\(betweenCameraAppSubscription)"
        self.txtBusinessDashboard.text = "\(betweenBusinessDashboardSubscription)"
        self.btnBadgeEarnedCheckmark.isSelected = isBadgeEarned
        
    }
    
    @IBAction func badgeEarnedAction(_ sender: UIButton) {
        Defaults.shared.milestonesReached = !sender.isSelected
        sender.isSelected = !sender.isSelected
    }
}
