//
//  WatermarkSettingsViewController.swift
//  SocialCAM
//
//  Created by Nilisha Gupta on 07/04/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit

class WatermarkSettings {
    
    var name: String
    var settings: [StorySetting]
    var settingsType: SettingsMode
    
    init(name: String, settings: [StorySetting], settingsType: SettingsMode) {
        self.name = name
        self.settings = settings
        self.settingsType = settingsType
    }
    
    static var watermarkSettings = [
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.fastesteverImage(), selected: false)], settingsType: .fatesteverWatermark),
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.applicationIdentifier(), selected: false)], settingsType: .applIdentifierWatermark)
    ]
}

class WatermarkSettingsViewController: UIViewController {
    
    // MARK: - Outlets Declaration
    @IBOutlet weak var watermarkSettingsTableView: UITableView!
    
    // MARK: - View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.watermarkSettingsTableView.reloadData()
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
    
    // MARK: - Action Methods
    @IBAction func onBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - Table View DataSource
extension WatermarkSettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return WatermarkSettings.watermarkSettings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let settingTitle = WatermarkSettings.watermarkSettings[section]
        return settingTitle.settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let watermarkSettingCell: WatermarkSettingCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.watermarkSettingCell.identifier) as? WatermarkSettingCell else {
            fatalError("\(R.reuseIdentifier.watermarkSettingCell.identifier) Not Found")
        }
        let settingTitle = WatermarkSettings.watermarkSettings[indexPath.section]
        if settingTitle.settingsType == .fatesteverWatermark {
            watermarkSettingCell.watermarkType = .fastestEverWatermark
            if Defaults.shared.appMode == .free {
                watermarkSettingCell.hideWatermarkButton.addTarget(self, action: #selector(goToSubscriptionVC), for: .touchUpInside)
            }
        } else if settingTitle.settingsType == .applIdentifierWatermark {
            watermarkSettingCell.watermarkType = .applicationIdentifier
            if Defaults.shared.appMode == .free {
                watermarkSettingCell.hideWatermarkButton.addTarget(self, action: #selector(goToSubscriptionVC), for: .touchUpInside)
            }
        }
        return watermarkSettingCell
    }
    
}

// MARK: - Table View Delegate
extension WatermarkSettingsViewController: UITableViewDelegate {
    
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
    
}
