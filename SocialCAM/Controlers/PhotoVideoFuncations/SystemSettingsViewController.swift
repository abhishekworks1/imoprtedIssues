//
//  SystemSettingsViewController.swift
//  SocialCAM
//
//  Created by Meet Mistry on 28/07/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit

class SystemSettings {
    
    var name: String
    var settings: [StorySetting]
    var settingsType: SettingsMode
    
    init(name: String, settings: [StorySetting], settingsType: SettingsMode) {
        self.name = name
        self.settings = settings
        self.settingsType = settingsType
    }
    
    static var systemSettings = [
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.showAllPopups(), selected: false)], settingsType: .showAllPopups)
    ]
}

class SystemSettingsViewController: UIViewController {
    
    // MARK: - Outlets Declaration
    @IBOutlet weak var systemSettingsTableView: UITableView!
    
    // MARK: - View Life Cycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.systemSettingsTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.systemSettingsTableView.reloadData()
    }
    
    // MARK: - Action Methods
    @IBAction func onBackPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Table View DataSource
extension SystemSettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SystemSettings.systemSettings.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let settingTitle = SystemSettings.systemSettings[section]
        return settingTitle.settings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let systemSettingsCell: SystemSettingsCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.systemSettingsCell.identifier) as? SystemSettingsCell else {
            fatalError("\(R.reuseIdentifier.systemSettingsCell.identifier) Not Found")
        }
        
        let settingTitle = SystemSettings.systemSettings[indexPath.section]
        if settingTitle.settingsType == .showAllPopups {
            systemSettingsCell.systemSettingType = .showAllPopUps
        }
        return systemSettingsCell
    }
}

// MARK: - Table View Delegate
extension SystemSettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.systemSettingsCell.identifier) as? SystemSettingsCell else {
            fatalError("\(R.reuseIdentifier.systemSettingsCell.identifier) Not Found")
        }
        headerView.title.isHidden = true
        headerView.btnSelectShowAllPopup.isHidden = true
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
}
