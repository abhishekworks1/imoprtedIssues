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
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.changePositionsOfMuteSwitchingCamera(), selected: false)], settingsType: .swapeContols),
        StorySettings(name: R.string.localizable.supportedFrameRates(), settings: [StorySetting(name: R.string.localizable.supportedFrameRates(), selected: false)], settingsType: .supportedFrameRates),
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
    
    var firstPercentage: Double = 0.0
    var firstUploadCompletedSize: Double = 0.0
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    deinit {
        print("Deinit \(self.description)")
    }

    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
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
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.storySettingsHeader.identifier) as? StorySettingsHeader else {
            fatalError("StorySettingsHeader Not Found")
        }
        let settingTitle = CameraSettings.storySettings[section]
        if settingTitle.settingsType != .supportedFrameRates {
            headerView.title.isHidden = true
        } else {
            headerView.title.isHidden = false
        }
        headerView.title.text = settingTitle.name
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let settingTitle = CameraSettings.storySettings[section]
        if settingTitle.settingsType != .supportedFrameRates {
            return 1
        } else {
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingTitle = CameraSettings.storySettings[indexPath.section]
        if settingTitle.settingsType == .faceDetection {
            Defaults.shared.enableFaceDetection = !Defaults.shared.enableFaceDetection
            self.settingsTableView.reloadData()
        } else if settingTitle.settingsType == .guildlines {
            Defaults.shared.enableGuildlines = !Defaults.shared.enableGuildlines
            self.settingsTableView.reloadData()
        } else if settingTitle.settingsType == .swapeContols {
            Defaults.shared.swapeContols = !Defaults.shared.swapeContols
            self.settingsTableView.reloadData()
        } else if settingTitle.settingsType == .supportedFrameRates {
            Defaults.shared.selectedFrameRates = Defaults.shared.supportedFrameRates?[indexPath.row]
            self.settingsTableView.reloadData()
        } else if settingTitle.settingsType == .watermarkAlpha30 || settingTitle.settingsType == .watermarkAlpha50 || settingTitle.settingsType == .watermarkAlpha80 {
            Defaults.shared.waterarkOpacity = settingTitle.settingsType.rawValue
            tableView.reloadData()
        }
    }
    
}
