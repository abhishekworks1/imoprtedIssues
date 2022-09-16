//
//  HelpSettingsViewController.swift
//  SocialCAM
//
//  Created by Nilisha Gupta on 14/06/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit

class HelpSettings {
    
    var name: String
    var settings: [StorySetting]
    var settingsType: SettingsMode
    
    init(name: String, settings: [StorySetting], settingsType: SettingsMode) {
        self.name = name
        self.settings = settings
        self.settingsType = settingsType
    }
    
    static var helpSettings = [
        StorySettings(name: "",
                      settings: [StorySetting(name: R.string.localizable.quickCamCamera(), selected: false)], settingsType: .instruction),
        StorySettings(name: "",
                      settings: [StorySetting(name: R.string.localizable.pic2Art(), selected: false)], settingsType: .pic2Art),
        StorySettings(name: "",
                      settings: [StorySetting(name: R.string.localizable.videoEditor(), selected: false)], settingsType: .edit)
    ]
}

class HelpSettingsViewController: UIViewController {
    
    // MARK: - Outlets Declaration
    @IBOutlet weak var helpSettingsTableView: UITableView!
    
    // MARK: - View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        helpSettingsTableView.tableHeaderView = UIView(frame: frame)
    }
    
    deinit {
        print("Deinit \(self.description)")
    }
    
    // MARK: - Action Methods
    @IBAction func onBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - Table View DataSource
extension HelpSettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return HelpSettings.helpSettings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let settingTitle = HelpSettings.helpSettings[section]
        return settingTitle.settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let helpSettingsCell: HelpSettingsCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.helpSettingsCell.identifier) as? HelpSettingsCell else {
            fatalError("\(R.reuseIdentifier.helpSettingsCell.identifier) Not Found")
        }
        let settingTitle = HelpSettings.helpSettings[indexPath.section]
        let settings = settingTitle.settings[indexPath.row]
        helpSettingsCell.title.text = settings.name
        
        if settingTitle.settingsType == .instruction {
            helpSettingsCell.imgSettingIcon.image = R.image.quickCakHelp()
        } else if settingTitle.settingsType == .pic2Art {
            helpSettingsCell.imgSettingIcon.image = R.image.pic2ArtHelp()
        } else if settingTitle.settingsType == .edit {
            helpSettingsCell.imgSettingIcon.image = R.image.editHelp()
        }
            
        return helpSettingsCell
    }
    
}

// MARK: - Table View Delegate
extension HelpSettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.storySettingsHeader.identifier) as? StorySettingsHeader else {
            fatalError("StorySettingsHeader Not Found")
        }
        headerView.title.isHidden = true
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingTitle = HelpSettings.helpSettings[indexPath.section]
        if settingTitle.settingsType == .instruction {
            if let tooltipViewController = R.storyboard.loginViewController.tooltipViewController() {
                tooltipViewController.pushFromSettingScreen = true
                tooltipViewController.isCameraGif = true
                navigationController?.pushViewController(tooltipViewController, animated: true)
            }
        } else if settingTitle.settingsType == .pic2Art {
            if let tooltipViewController = R.storyboard.loginViewController.tooltipViewController() {
                tooltipViewController.pushFromSettingScreen = true
                tooltipViewController.isPic2ArtGif = true
                navigationController?.pushViewController(tooltipViewController, animated: true)
            }
        } else if settingTitle.settingsType == .edit {
            if let tooltipViewController =  R.storyboard.loginViewController.tooltipViewController() {
                tooltipViewController.pushFromSettingScreen = true
                tooltipViewController.isEditScreenTooltip = true
                navigationController?.pushViewController(tooltipViewController, animated: true)
            }
        } else if settingTitle.settingsType == .quickLink {
            if let tooltipViewController = R.storyboard.loginViewController.tooltipViewController() {
                tooltipViewController.pushFromSettingScreen = true
                tooltipViewController.isQuickLinkTooltip = true
                navigationController?.pushViewController(tooltipViewController, animated: true)
            }
        }
    }
    
}
