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
    case autoSaveAfterEditing
    case muteRecordingSlowMotion
    case muteRecordingFastMotion
    case milestonesReached
    case mutehapticFeedbackOnSpeedSelection
    case autoSavePic2Art
    case onboarding
    case openingScreen
    case quickCamCamera
    case mobileDashboard
}

enum OnboardingReferral: String {
    case OpeningScreen = "Opening Screen"
    case QuickCamera    = "QuickCam Camera"
    case MobileDashboard        = "Mobile Dashboard"
    
    var description: String {
            return self.rawValue
        }

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
            selectButtonLeadingConstraint.constant = 19
            title.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            btnSelectShowAllPopup.isHidden = false
            
            btnSelectShowAllPopup.setImage(R.image.checkBoxActive(), for: .selected)
            btnSelectShowAllPopup.setImage(R.image.checkBoxInActive(), for: .normal)

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
            } else if systemSettingType == .autoSaveAfterEditing {
                title.text = R.string.localizable.autoSaveAfterEditing()
                btnHelpTooltip.isHidden = true
                btnSelectShowAllPopup.isSelected = Defaults.shared.isVideoSavedAfterEditing
            } else if systemSettingType == .autoSavePic2Art {
                title.text = R.string.localizable.autoSavePic2Art()
                btnHelpTooltip.isHidden = true
                btnSelectShowAllPopup.isSelected = Defaults.shared.isAutoSavePic2Art
            } else if systemSettingType == .muteRecordingFastMotion {
                title.text = R.string.localizable.muteWhileRecordingInFastMotion()
                btnHelpTooltip.isHidden = true
                btnSelectShowAllPopup.isSelected = Defaults.shared.muteOnFastMotion
            } else if systemSettingType == .muteRecordingSlowMotion {
                title.text = R.string.localizable.muteWhileRecordingInSlowMotion()
                btnHelpTooltip.isHidden = true
                btnSelectShowAllPopup.isSelected = Defaults.shared.muteOnSlowMotion
            } else if systemSettingType == .milestonesReached {
                title.text = R.string.localizable.badgeEarned()
                btnSelectShowAllPopup.isSelected = Defaults.shared.milestonesReached
            } else if systemSettingType == .mutehapticFeedbackOnSpeedSelection {
                btnHelpTooltip.isHidden = true
                title.text = R.string.localizable.muteHapticFeedback()
                btnSelectShowAllPopup.isSelected = Defaults.shared.isMutehapticFeedbackOnSpeedSelection
            } else if systemSettingType == .onboarding {
                title.font = UIFont.boldSystemFont(ofSize: 17)
                title.text = "Default Opening Screen"
                selectButtonLeadingConstraint.constant = -11
                btnSelectShowAllPopup.isHidden = true
            } else if systemSettingType == .openingScreen {
                title.text = "Opening Screen"
                selectButtonLeadingConstraint.constant = 30
                btnSelectShowAllPopup.setImage(R.image.settings_radio_selected(), for: .selected)
                btnSelectShowAllPopup.setImage(R.image.settings_radio_deselected(), for: .normal)
                btnSelectShowAllPopup.isSelected = Defaults.shared.onBoardingReferral == OnboardingReferral.OpeningScreen.rawValue
            } else if systemSettingType == .quickCamCamera {
                title.text = "QuickCam Camera"
                selectButtonLeadingConstraint.constant = 30
                btnSelectShowAllPopup.setImage(R.image.settings_radio_selected(), for: .selected)
                btnSelectShowAllPopup.setImage(R.image.settings_radio_deselected(), for: .normal)
                btnSelectShowAllPopup.isSelected = Defaults.shared.onBoardingReferral == OnboardingReferral.QuickCamera.rawValue
            } else if systemSettingType == .mobileDashboard {
                title.text = "Mobile Dashboard"
                selectButtonLeadingConstraint.constant = 30
                btnSelectShowAllPopup.setImage(R.image.settings_radio_selected(), for: .selected)
                btnSelectShowAllPopup.setImage(R.image.settings_radio_deselected(), for: .normal)
                btnSelectShowAllPopup.isSelected = Defaults.shared.onBoardingReferral == OnboardingReferral.MobileDashboard.rawValue
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
            Defaults.shared.isEditProfileDiscardPopupChecked = !btnSelectShowAllPopup.isSelected
            if Defaults.shared.isShowAllPopUpChecked {
                Defaults.shared.isDoNotShowAgainOpenBusinessCenterPopup = false
            }
            
            (self.parentViewController as? SystemSettingsViewController)?.systemSettingsTableView.reloadData()
            
        } else if systemSettingType == .skipYoutubeLogin {
            Defaults.shared.isSkipYoutubeLogin = !btnSelectShowAllPopup.isSelected
            btnSelectShowAllPopup.isSelected = !btnSelectShowAllPopup.isSelected
        } else if systemSettingType == .saveVideoAfterRecording {
            Defaults.shared.isVideoSavedAfterRecording = !btnSelectShowAllPopup.isSelected
            btnSelectShowAllPopup.isSelected = !btnSelectShowAllPopup.isSelected
        } else if systemSettingType == .autoSaveAfterEditing {
            Defaults.shared.isVideoSavedAfterEditing = !btnSelectShowAllPopup.isSelected
            btnSelectShowAllPopup.isSelected = !btnSelectShowAllPopup.isSelected
        } else if systemSettingType == .autoSavePic2Art {
            Defaults.shared.isAutoSavePic2Art = !btnSelectShowAllPopup.isSelected
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
        } else if systemSettingType == .mutehapticFeedbackOnSpeedSelection {
            Defaults.shared.isMutehapticFeedbackOnSpeedSelection = !btnSelectShowAllPopup.isSelected
            btnSelectShowAllPopup.isSelected = !btnSelectShowAllPopup.isSelected
        } else if systemSettingType == .openingScreen {
            Defaults.shared.onBoardingReferral = OnboardingReferral.OpeningScreen.description
            (self.parentViewController as? SystemSettingsViewController)?.systemSettingsTableView.reloadData()
        } else if systemSettingType == .quickCamCamera {
            Defaults.shared.onBoardingReferral = OnboardingReferral.QuickCamera.description
            (self.parentViewController as? SystemSettingsViewController)?.systemSettingsTableView.reloadData()
        } else if systemSettingType == .mobileDashboard {
            Defaults.shared.onBoardingReferral = OnboardingReferral.MobileDashboard.description
            (self.parentViewController as? SystemSettingsViewController)?.systemSettingsTableView.reloadData()
        }
        
    }
}
