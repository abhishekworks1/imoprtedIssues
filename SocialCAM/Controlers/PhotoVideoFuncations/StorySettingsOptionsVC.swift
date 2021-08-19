//
//  StorySettingsOptionsVC.swift
//  ProManager
//
//  Created by Jasmin Patel on 27/07/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import GoogleSignIn

class CameraSettings {
    
    var name: String
    var settings: [StorySetting]
    var settingsType: SettingsMode
    
    init(name: String, settings: [StorySetting], settingsType: SettingsMode) {
        self.name = name
        self.settings = settings
        self.settingsType = settingsType
    }
    
    static var storySettings = [
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.faceDetection(), selected: false)], settingsType: .faceDetection),
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.guideline(), selected: false)], settingsType: .guildlines),
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.skipYoutubeLogin(), selected: false)], settingsType: .skipYoutubeLogin),
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.saveVideoAfterRecording(), selected: false)], settingsType: .saveVideoAfterRecording),
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.changePositionsOfMuteSwitchingCamera(), selected: false)], settingsType: .swapeContols),
        StorySettings(name: R.string.localizable.supportedFrameRates(), settings: [StorySetting(name: R.string.localizable.supportedFrameRates(), selected: false)], settingsType: .supportedFrameRates),
        StorySettings(name: "", settings: [StorySetting(name:
            R.string.localizable.videoRecordingResolution(), selected: false)], settingsType: .videoResolution),
        StorySettings(name: R.string.localizable.guidelineTypes(), settings:
            [StorySetting(name: R.string.localizable.free(), selected: true)], settingsType: .guidelineType),
        StorySettings(name: R.string.localizable.guidelineThickness(), settings:
            [StorySetting(name: R.string.localizable.free(), selected: true)], settingsType: .guidelineTickness),
        StorySettings(name: R.string.localizable.guidelineColor(), settings: [StorySetting(name: R.string.localizable.free(), selected: true)], settingsType: .guidelineColor),
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.light(), selected: false)], settingsType: .watermarkAlpha30),
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.medium(), selected: false)], settingsType: .watermarkAlpha50),
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.dark(), selected: false)], settingsType: .watermarkAlpha80)
    ]
}

class StorySettingsOptionsVC: UIViewController {
    
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var skipYTLoginTooltipView: UIView!
    
    var firstPercentage: Double = 0.0
    var firstUploadCompletedSize: Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let sharedModel = Defaults.shared
        setUserSettings(appWatermark: sharedModel.appIdentifierWatermarkSetting.rawValue, fastesteverWatermark: sharedModel.fastestEverWatermarkSetting.rawValue, faceDetection: sharedModel.enableFaceDetection, guidelineThickness: sharedModel.cameraGuidelineThickness.rawValue, guidelineTypes: sharedModel.cameraGuidelineTypes.rawValue, guidelinesShow: sharedModel.enableGuildlines, iconPosition: sharedModel.swapeContols, supportedFrameRates: sharedModel.supportedFrameRates, videoResolution: sharedModel.videoResolution.rawValue, watermarkOpacity: sharedModel.waterarkOpacity, guidelineActiveColor: CommonFunctions.hexStringFromColor(color: sharedModel.cameraGuidelineActiveColor), guidelineInActiveColor: CommonFunctions.hexStringFromColor(color: sharedModel.cameraGuidelineInActiveColor))
        if Defaults.shared.isSkipYoutubeLogin == false {
            if GoogleManager.shared.isUserLogin {
                GoogleManager.shared.logout()
            }
        }
    }
    
    deinit {
        print("Deinit \(self.description)")
    }
    
    @objc func goToSubscriptionVC() {
        if Defaults.shared.videoResolution == .high && Defaults.shared.appMode == .free {
            if let subscriptionVC = R.storyboard.subscription.subscriptionContainerViewController() {
                navigationController?.pushViewController(subscriptionVC, animated: true)
            }
        }
    }
    
    @objc func showYoutubeLoginTooltip() {
        self.skipYTLoginTooltipView.isHidden = false
    }

    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnOkClicked(_ sender: UIButton) {
        self.skipYTLoginTooltipView.isHidden = true
    }
    
}

extension StorySettingsOptionsVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isPic2ArtApp {
            return CameraSettings.storySettings.count - 1
        }
        return CameraSettings.storySettings.count
    }
       
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let settingTitle = CameraSettings.storySettings[section]
        if settingTitle.settingsType == .supportedFrameRates {
            return Defaults.shared.supportedFrameRates?.count ?? 0
        } else if settingTitle.settingsType == .skipYoutubeLogin {
            return 1
        } else {
            return settingTitle.settings.count
        }
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.storySettingsCell.identifier, for: indexPath) as? StorySettingsCell else {
            fatalError("StorySettingsCell Not Found")
        }
        let settingTitle = CameraSettings.storySettings[indexPath.section]
        
        if settingTitle.settingsType == .supportedFrameRates {
            cell.settingsName.text = Defaults.shared.supportedFrameRates?[indexPath.row]
        } else {
            let settings = settingTitle.settings[indexPath.row]
            cell.settingsName.text = settings.name
        }
        
        if settingTitle.settingsType == .faceDetection {
            cell.onOffButton.isSelected = Defaults.shared.enableFaceDetection
        } else if settingTitle.settingsType == .guildlines {
            cell.onOffButton.isSelected = Defaults.shared.enableGuildlines
        } else if settingTitle.settingsType == .swapeContols {
            cell.onOffButton.isSelected = Defaults.shared.swapeContols
            guard let iconPositionCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.iconPositionCell.identifier) else { return cell }
            return iconPositionCell
        } else if settingTitle.settingsType == .guidelineType {
            cell.onOffButton.isSelected = Defaults.shared.swapeContols
            guard let iconPositionCell: GuildlineIconPositionTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.guildlineIconPositionTableViewCell.identifier) as? GuildlineIconPositionTableViewCell else { return cell }
            iconPositionCell.guildline = .type
            return iconPositionCell
        } else if settingTitle.settingsType == .guidelineTickness {
            cell.onOffButton.isSelected = Defaults.shared.swapeContols
            guard let iconPositionCell: GuildlineIconPositionTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.guildlineIconPositionTableViewCell.identifier) as? GuildlineIconPositionTableViewCell else { return cell }
            iconPositionCell.guildline = .thickness
            return iconPositionCell
        } else if settingTitle.settingsType == .guidelineColor {
            cell.onOffButton.isSelected = Defaults.shared.swapeContols
            guard let colorPickCell: ColorPickCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.colorPickCell.identifier) as? ColorPickCell else { return cell }
            return colorPickCell
        }
        else if settingTitle.settingsType == .supportedFrameRates {
            cell.onOffButton.isHidden = false
            if Defaults.shared.selectedFrameRates == cell.settingsName.text {
                cell.onOffButton.isSelected = true
            } else {
                cell.onOffButton.isSelected = false
            }
        } else if settingTitle.settingsType == .watermarkAlpha30 || settingTitle.settingsType == .watermarkAlpha50 || settingTitle.settingsType == .watermarkAlpha80 {
            cell.onOffButton.isSelected = Defaults.shared.waterarkOpacity == settingTitle.settingsType.rawValue
        } else if settingTitle.settingsType == .videoResolution {
            cell.onOffButton.isHidden = true
            guard let videoResolutionCell: VideoResolutionCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.videoResolutionCell.identifier) as? VideoResolutionCell else {
                return cell
            }
            return videoResolutionCell
        } else if settingTitle.settingsType == .skipYoutubeLogin || settingTitle.settingsType == .saveVideoAfterRecording {
            guard let systemSettingsCell: SystemSettingsCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.systemSettingsCell.identifier) as? SystemSettingsCell else {
                fatalError("\(R.reuseIdentifier.systemSettingsCell.identifier) Not Found")
            }
            if settingTitle.settingsType == .skipYoutubeLogin {
                systemSettingsCell.systemSettingType = .skipYoutubeLogin
                systemSettingsCell.btnHelpTooltip.addTarget(self, action: #selector(showYoutubeLoginTooltip), for: .touchUpInside)
            } else if settingTitle.settingsType == .saveVideoAfterRecording {
                systemSettingsCell.systemSettingType = .saveVideoAfterRecording
            }
            return systemSettingsCell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.storySettingsHeader.identifier) as? StorySettingsHeader else {
            fatalError("StorySettingsHeader Not Found")
        }
        let settingTitle = CameraSettings.storySettings[section]
        headerView.userName.isHidden = true
        headerView.userImage.isHidden = true
        if settingTitle.settingsType != .supportedFrameRates {
            headerView.title.isHidden = true
        } else {
            headerView.title.isHidden = false
        }
        headerView.title.text = settingTitle.name
        
        if settingTitle.settingsType == .faceDetection {
            headerView.userImage.isHidden = false
            headerView.userName.isHidden = false
            headerView.title.isHidden = true
            headerView.userImage.layer.cornerRadius = headerView.userImage.bounds.width / 2
            if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
                headerView.userImage.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: ApplicationSettings.userPlaceHolder)
            } else {
                headerView.userImage.image = ApplicationSettings.userPlaceHolder
            }
            headerView.userName.text = R.string.localizable.channelName(Defaults.shared.currentUser?.channelId ?? "")
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let settingTitle = CameraSettings.storySettings[section]
        if settingTitle.settingsType == .supportedFrameRates {
            return 60
        } else if settingTitle.settingsType == .faceDetection {
            return 80
        } else if settingTitle.settingsType == .skipYoutubeLogin || settingTitle.settingsType == .saveVideoAfterRecording {
            return 20
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingTitle = CameraSettings.storySettings[indexPath.section]
        if settingTitle.settingsType == .faceDetection {
            Defaults.shared.enableFaceDetection = !Defaults.shared.enableFaceDetection
            Defaults.shared.isCameraSettingChanged = true
            self.settingsTableView.reloadData()
        } else if settingTitle.settingsType == .guildlines {
            Defaults.shared.enableGuildlines = !Defaults.shared.enableGuildlines
            self.settingsTableView.reloadData()
        } else if settingTitle.settingsType == .swapeContols {
            Defaults.shared.swapeContols = !Defaults.shared.swapeContols
            self.settingsTableView.reloadData()
        } else if settingTitle.settingsType == .supportedFrameRates {
            Defaults.shared.selectedFrameRates = Defaults.shared.supportedFrameRates?[indexPath.row]
            Defaults.shared.isCameraSettingChanged = true
            self.settingsTableView.reloadData()
        } else if settingTitle.settingsType == .watermarkAlpha30 || settingTitle.settingsType == .watermarkAlpha50 || settingTitle.settingsType == .watermarkAlpha80 {
            Defaults.shared.waterarkOpacity = settingTitle.settingsType.rawValue
            tableView.reloadData()
        }
    }
    
}

extension StorySettingsOptionsVC {
    
    func setUserSettings(appWatermark: Int? = 1, fastesteverWatermark: Int? = 2, faceDetection: Bool? = false, guidelineThickness: Int? = 3, guidelineTypes: Int? = 3, guidelinesShow: Bool? = false, iconPosition: Bool? = false, supportedFrameRates: [String]?, videoResolution: Int? = 1, watermarkOpacity: Int? = 30, guidelineActiveColor: String?, guidelineInActiveColor: String?) {
        ProManagerApi.setUserSettings(appWatermark: appWatermark ?? 1, fastesteverWatermark: fastesteverWatermark ?? 2, faceDetection: faceDetection ?? false, guidelineThickness: guidelineThickness ?? 3, guidelineTypes: guidelineTypes ?? 3, guidelinesShow: guidelinesShow ?? false, iconPosition: iconPosition ?? false, supportedFrameRates: supportedFrameRates ?? [], videoResolution: videoResolution ?? 1, watermarkOpacity: watermarkOpacity ?? 30, guidelineActiveColor: guidelineActiveColor ?? "", guidelineInActiveColor: guidelineInActiveColor ?? "").request(Result<UserSettingsResult>.self).subscribe(onNext: { response in
            if response.status == ResponseType.success {
                print(R.string.localizable.success())
            } else {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            print(error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: (rx.disposeBag))
    }
    
}
