//
//  SystemSettingsCell.swift
//  SocialCAM
//
//  Created by Meet Mistry on 29/07/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit

enum SystemSettingType {
    case showAllPopUps
    case skipYoutubeLogin
    case saveVideoAfterRecording
    case muteRecordingSlowMotion
    case muteRecordingFastMotion
    case milestonesReached
}

class SystemSettingsCell: UITableViewCell {
    
    // MARK: - Outlets Declaration
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var btnSelectShowAllPopup: UIButton!
    @IBOutlet weak var btnHelpTooltip: UIButton!
    @IBOutlet weak var selectButtonLeadingConstraint: NSLayoutConstraint!
    
    // MARK: - Varable Declaration
    var systemSettingType: SystemSettingType = .showAllPopUps {
        didSet {
            if systemSettingType == .showAllPopUps {
                title.text = R.string.localizable.showAllPopups()
                btnSelectShowAllPopup.isSelected = Defaults.shared.isShowAllPopUpChecked
            } else if systemSettingType == .skipYoutubeLogin {
                title.text = R.string.localizable.skipYoutubeLogin()
                btnSelectShowAllPopup.isSelected = Defaults.shared.isSkipYoutubeLogin
            } else if systemSettingType == .saveVideoAfterRecording {
                title.text = R.string.localizable.saveVideoAfterRecording()
                btnHelpTooltip.isHidden = true
                btnSelectShowAllPopup.isSelected = Defaults.shared.isVideoSavedAfterRecording
            } else if systemSettingType == .muteRecordingFastMotion {
                title.text = R.string.localizable.muteWhileRecordingInFastMotion()
                btnHelpTooltip.isHidden = true
                btnSelectShowAllPopup.isSelected = Defaults.shared.muteOnFastMotion
            } else if systemSettingType == .muteRecordingSlowMotion {
                title.text = R.string.localizable.muteWhileRecordingInSlowMotion()
                btnHelpTooltip.isHidden = true
                btnSelectShowAllPopup.isSelected = Defaults.shared.muteOnSlowMotion
            } else if systemSettingType == .milestonesReached {
                title.text = R.string.localizable.milestonesReached()
                selectButtonLeadingConstraint.constant = 34
                btnSelectShowAllPopup.isSelected = Defaults.shared.milestonesReached
            }
        }
    }
        
    // MARK: - View Life cycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Action Methods
    @IBAction func btnSystemSettingTaped(_ sender: UIButton) {
        if systemSettingType == .showAllPopUps {
            Defaults.shared.isShowAllPopUpChecked = !btnSelectShowAllPopup.isSelected
            btnSelectShowAllPopup.isSelected = !btnSelectShowAllPopup.isSelected
            Defaults.shared.isDoNotShowAgainBusinessCenterClicked = !btnSelectShowAllPopup.isSelected
            Defaults.shared.isDoNotShowAgainVidPlayClicked = !btnSelectShowAllPopup.isSelected
            Defaults.shared.isLoginTooltipHide = !btnSelectShowAllPopup.isSelected
            Defaults.shared.isDiscardVideoPopupHide = !btnSelectShowAllPopup.isSelected
            Defaults.shared.isToolTipHide = !btnSelectShowAllPopup.isSelected
        } else if systemSettingType == .skipYoutubeLogin {
            Defaults.shared.isSkipYoutubeLogin = !btnSelectShowAllPopup.isSelected
            btnSelectShowAllPopup.isSelected = !btnSelectShowAllPopup.isSelected
        } else if systemSettingType == .saveVideoAfterRecording {
            Defaults.shared.isVideoSavedAfterRecording = !btnSelectShowAllPopup.isSelected
            btnSelectShowAllPopup.isSelected = !btnSelectShowAllPopup.isSelected
        } else if systemSettingType == .muteRecordingSlowMotion {
            Defaults.shared.muteOnSlowMotion = !btnSelectShowAllPopup.isSelected
            btnSelectShowAllPopup.isSelected = !btnSelectShowAllPopup.isSelected
        } else if systemSettingType == .muteRecordingFastMotion {
            Defaults.shared.muteOnFastMotion = !btnSelectShowAllPopup.isSelected
            btnSelectShowAllPopup.isSelected = !btnSelectShowAllPopup.isSelected
        } else if systemSettingType == .milestonesReached {
            Defaults.shared.milestonesReached = !btnSelectShowAllPopup.isSelected
            btnSelectShowAllPopup.isSelected = !btnSelectShowAllPopup.isSelected
        }
    }
}
