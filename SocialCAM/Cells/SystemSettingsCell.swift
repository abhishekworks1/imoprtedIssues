//
//  SystemSettingsCell.swift
//  SocialCAM
//
//  Created by Meet Mistry on 29/07/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit

enum SystemSettingType: String {
    case showAllPopUps = "Show All Popups"
    case skipYoutubeLogin
    case saveVideoAfterRecording
    case autoSaveAfterEditing
    case autoSavePic2ArtOriginalPhoto
    case muteRecordingSlowMotion
    case muteRecordingFastMotion
    case milestonesReached
    case mutehapticFeedbackOnSpeedSelection
    case autoSavePic2Art
    case onboarding
    case welcomeScreen = "Welcome Screen"
    case quickMenu = "QuickStart Guide"
    case quickCamCamera = "QuickCam Camera"
    case mobileDashboard = "Mobile Dashboard"
    case hapticNone = "None"
    case hapticAll = "All"
    case hapticSome = "Some"
    case hapticFeedBack = "Haptic Feedback"
    
    var description : String {
        switch self {
        // Use Internationalization, as appropriate.
        case .welcomeScreen: return "Welcome Screen"
        case .quickMenu: return "QuickStart Guide"
        case .quickCamCamera: return "QuickCam Camera"
        case .mobileDashboard: return "Mobile Dashboard"
        case .hapticFeedBack: return "Haptic Feedback"
        case .showAllPopUps: "Show All Popups"
        case .skipYoutubeLogin:
            break
        case .saveVideoAfterRecording:
            break
        case .autoSaveAfterEditing:
            break
        case .autoSavePic2ArtOriginalPhoto:
            break
        case .muteRecordingSlowMotion:
            break
        case .muteRecordingFastMotion:
            break
        case .milestonesReached:
            break
        case .mutehapticFeedbackOnSpeedSelection:
            break
        case .autoSavePic2Art:
            break
        case .onboarding:
            break
        case .hapticNone:
            return "None"
        case .hapticAll:
            return "All"
        case .hapticSome:
            return "Some"
        }
        return ""
      }
}

enum OnboardingReferral: String {
    case welcomeScreen = "Welcome Screen"
    case QuickMenu = "QuickStart Guide"
    case QuickCamera = "QuickCam Camera"
    case MobileDashboard = "Mobile Dashboard"
    
    var description: String {
        return self.rawValue
    }
    
}

class SystemSettingsCell: UITableViewCell {
    
    // MARK: - Outlets Declaration
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var btnSelectShowAllPopup: UIButton!
    @IBOutlet weak var btnHelpTooltip: UIButton!
    @IBOutlet weak var selectButtonLeadingConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var imageViewLock: UIImageView?
    @IBOutlet weak var btnLock: UIButton?
    
    @IBOutlet weak var btnSystemSetting: UIButton?
    
    // MARK: - Varable Declaration
    var systemSettingType: SystemSettingType = .showAllPopUps {
        didSet {
            selectButtonLeadingConstraint?.constant = 19
//            title.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            btnSelectShowAllPopup.isHidden = false
            
            btnSelectShowAllPopup.setImage(R.image.checkBoxActive(), for: .selected)
            btnSelectShowAllPopup.setImage(R.image.checkBoxInActive(), for: .normal)
            self.btnLock?.isHidden = true
            self.imageViewLock?.isHidden = true
            self.btnSystemSetting?.isUserInteractionEnabled = false
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
            } else if systemSettingType == .autoSavePic2ArtOriginalPhoto {
                title.text = R.string.localizable.autoSavePic2ArtOriginalPhoto()
                btnHelpTooltip.isHidden = true
                btnSelectShowAllPopup.isSelected = Defaults.shared.isAutoSavePic2ArtOriginalPhoto
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
                title.textColor = R.color.appBlackColor()
                title.text = "Default Opening Screen"
//                selectButtonLeadingConstraint?.constant = -15
                btnSelectShowAllPopup.isHidden = true
            } else if systemSettingType == .welcomeScreen {
                title.text = "Welcome Screen"
                selectButtonLeadingConstraint?.constant = 30
                btnSelectShowAllPopup.setImage(R.image.settings_radio_selected(), for: .selected)
                btnSelectShowAllPopup.setImage(R.image.settings_radio_deselected(), for: .normal)
                btnSelectShowAllPopup.isSelected = Defaults.shared.onBoardingReferral == OnboardingReferral.welcomeScreen.rawValue
                
                btnSelectShowAllPopup.isUserInteractionEnabled = false
            } else if systemSettingType == .quickMenu {
                title.text = "QuickStart Guide"
                selectButtonLeadingConstraint?.constant = 30
                btnSelectShowAllPopup.setImage(R.image.settings_radio_selected(), for: .selected)
                btnSelectShowAllPopup.setImage(R.image.settings_radio_deselected(), for: .normal)
                btnSelectShowAllPopup.isSelected = Defaults.shared.onBoardingReferral == OnboardingReferral.QuickMenu.rawValue
                
                btnSelectShowAllPopup.isUserInteractionEnabled = false
            } else if systemSettingType == .quickCamCamera {
                title.text = "QuickCam Camera"
                selectButtonLeadingConstraint?.constant = 30
                btnSelectShowAllPopup.setImage(R.image.settings_radio_selected(), for: .selected)
                btnSelectShowAllPopup.setImage(R.image.settings_radio_deselected(), for: .normal)
                btnSelectShowAllPopup.isSelected = Defaults.shared.onBoardingReferral == OnboardingReferral.QuickCamera.rawValue
                self.btnLock?.isHidden = !self.isSubscriptionTrialOrExpired()
                
                btnSelectShowAllPopup.isUserInteractionEnabled = false
            } else if systemSettingType == .mobileDashboard {
                title.text = "Mobile Dashboard"
                selectButtonLeadingConstraint?.constant = 30
                btnSelectShowAllPopup.setImage(R.image.settings_radio_selected(), for: .selected)
                btnSelectShowAllPopup.setImage(R.image.settings_radio_deselected(), for: .normal)
                btnSelectShowAllPopup.isSelected = Defaults.shared.onBoardingReferral == OnboardingReferral.MobileDashboard.rawValue
                self.btnLock?.isHidden = !self.isSubscriptionTrialOrExpired()
                
                btnSelectShowAllPopup.isUserInteractionEnabled = false
                
            } else if systemSettingType == .hapticFeedBack {
                title.font = UIFont.boldSystemFont(ofSize: 17)
                title.textColor = R.color.appPrimaryColor()
                title.text = R.string.localizable.hapticFeedback()
                btnSelectShowAllPopup.setImage(R.image.iconWaterMarkOpacity(), for: .normal)
//                selectButtonLeadingConstraint?.constant = 5
            } else if systemSettingType == .hapticAll {
                title.text = R.string.localizable.all()
                selectButtonLeadingConstraint?.constant = 30
                btnSelectShowAllPopup.setImage(R.image.settings_radio_selected(), for: .selected)
                btnSelectShowAllPopup.setImage(R.image.settings_radio_deselected(), for: .normal)
                btnSelectShowAllPopup.isSelected = Defaults.shared.allowHaptic == HapticSetting.all.rawValue
            } else if systemSettingType == .hapticSome {
                title.text = R.string.localizable.some()
                selectButtonLeadingConstraint?.constant = 30
                btnSelectShowAllPopup.setImage(R.image.settings_radio_selected(), for: .selected)
                btnSelectShowAllPopup.setImage(R.image.settings_radio_deselected(), for: .normal)
                btnSelectShowAllPopup.isSelected = Defaults.shared.allowHaptic == HapticSetting.some.rawValue
            }  else if systemSettingType == .hapticNone {
                title.text = R.string.localizable.none()
                selectButtonLeadingConstraint?.constant = 30
                btnSelectShowAllPopup.setImage(R.image.settings_radio_selected(), for: .selected)
                btnSelectShowAllPopup.setImage(R.image.settings_radio_deselected(), for: .normal)
                btnSelectShowAllPopup.isSelected = Defaults.shared.allowHaptic == HapticSetting.none.rawValue
            }
        }
    }
        
    // MARK: - View Life cycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell() {
        self.btnLock?.isHidden = true
        self.imageViewLock?.isHidden = true
        self.btnSystemSetting?.isUserInteractionEnabled = false
    }
    
    func configureCellForSection(storySetting: StorySetting) {
        
        switch storySetting.name {
        case SystemSettingType.welcomeScreen.description:
            self.systemSettingType = .welcomeScreen
        case SystemSettingType.quickMenu.description:
            self.systemSettingType = .quickMenu
        case SystemSettingType.quickCamCamera.description:
            self.systemSettingType = .quickCamCamera
        case SystemSettingType.mobileDashboard.description:
            self.systemSettingType = .mobileDashboard
        case SystemSettingType.hapticAll.description:
            self.systemSettingType = .hapticAll
        case SystemSettingType.hapticSome.description:
            self.systemSettingType = .hapticSome
        case SystemSettingType.hapticNone.description:
            self.systemSettingType = .hapticNone
        default:
            self.systemSettingType = .welcomeScreen
        }
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
        } else if systemSettingType == .autoSavePic2ArtOriginalPhoto {
            Defaults.shared.isAutoSavePic2ArtOriginalPhoto = !btnSelectShowAllPopup.isSelected
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
        } else if systemSettingType == .welcomeScreen {
            Defaults.shared.onBoardingReferral = OnboardingReferral.welcomeScreen.description
            (self.parentViewController as? SystemSettingsViewController)?.systemSettingsTableView.reloadData()
        } else if systemSettingType == .quickMenu {
            Defaults.shared.onBoardingReferral = OnboardingReferral.QuickMenu.description
            (self.parentViewController as? SystemSettingsViewController)?.systemSettingsTableView.reloadData()
        } else if systemSettingType == .quickCamCamera {
            Defaults.shared.onBoardingReferral = OnboardingReferral.QuickCamera.description
        } else if systemSettingType == .mobileDashboard {
            Defaults.shared.onBoardingReferral = OnboardingReferral.MobileDashboard.description
        }
        
    }
    
    func isSubscriptionTrialOrExpired() -> Bool {
        
        if let subscriptionStatusValue = Defaults.shared.currentUser?.subscriptionStatus {
            if (subscriptionStatusValue == "free" || subscriptionStatusValue == "expired") {
                return true
            }
        }
        return false
    }
    
    func updateAppSettings() {
        
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
        } else if systemSettingType == .autoSavePic2ArtOriginalPhoto {
            Defaults.shared.isAutoSavePic2ArtOriginalPhoto = !btnSelectShowAllPopup.isSelected
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
        } else if systemSettingType == .welcomeScreen {
            Defaults.shared.onBoardingReferral = OnboardingReferral.welcomeScreen.description
        } else if systemSettingType == .quickMenu {
            Defaults.shared.onBoardingReferral = OnboardingReferral.QuickMenu.description
        } else if systemSettingType == .quickCamCamera {
            Defaults.shared.onBoardingReferral = OnboardingReferral.QuickCamera.description
        } else if systemSettingType == .mobileDashboard {
            Defaults.shared.onBoardingReferral = OnboardingReferral.MobileDashboard.description
        }else if systemSettingType == .hapticAll{
            Defaults.shared.allowHaptic = HapticSetting.all.rawValue
        } else if systemSettingType == .hapticSome{
            Defaults.shared.allowHaptic = HapticSetting.some.rawValue
        } else if systemSettingType == .hapticNone{
            Defaults.shared.allowHaptic = HapticSetting.none.rawValue
        }
    }
}
