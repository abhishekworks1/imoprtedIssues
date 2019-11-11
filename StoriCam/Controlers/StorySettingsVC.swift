//
//  StorySettingsVC.swift
//  ProManager
//
//  Created by Jasmin Patel on 21/06/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit

class StorySetting {
    
    var name: String
    var selected: Bool
    
    init(name: String, selected: Bool) {
        self.name = name
        self.selected = selected
    }
    
}

class StorySettings {
    
    var name: String
    var settings: [StorySetting]
    
    init(name: String, settings: [StorySetting]) {
        self.name = name
        self.settings = settings
    }
    
    static var storySettings = [StorySettings(name: "Set Privacy",
                                              settings: [StorySetting(name: "Public",
                                                                      selected: false),
                                                         StorySetting(name: "Friends",
                                                                      selected: true),
                                                         StorySetting(name: "Friends except",
                                                                      selected: false),
                                                         StorySetting(name: "Specific friends",
                                                                      selected: false),
                                                         StorySetting(name: "Only me",
                                                                      selected: false)]),
                                StorySettings(name: "Allow message  Replies",
                                              settings: [StorySetting(name: "Off",
                                                                      selected: false),
                                                         StorySetting(name: "From People I Follow",
                                                                      selected: true),
                                                         StorySetting(name: "From Everyone",
                                                                      selected: false)]),
                                StorySettings(name: "Saving",
                                              settings: [StorySetting(name: "Saving to archive",
                                                                      selected: false),
                                                         StorySetting(name: "Save to gallery",
                                                                      selected: true)]),
                                StorySettings(name: "Sharing",
                                              settings: [StorySetting(name: "Allow Sharing",
                                                                      selected: false),
                                                         StorySetting(name: "From People I Follow",
                                                                      selected: true),
                                                         StorySetting(name: "From Everyone",
                                                                      selected: false)]),
                                StorySettings(name: "Share with Channel",
                                              settings: [StorySetting(name: "Select",
                                                                      selected: false)]),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: "Mirror image",
                                                                      selected: true)]),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: "Combine Segment",selected: false)]),
                                StorySettings(name: "",
                                              settings: [StorySetting(name: "Publish",selected: false)])]
    
}

class StorySettingsVC: UIViewController {
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension StorySettingsVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return StorySettings.storySettings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StorySettings.storySettings[section].settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StorySettingsCell", for: indexPath) as? StorySettingsCell else {
            fatalError("StorySettingsCell Not Found")
        }
        let settings = StorySettings.storySettings[indexPath.section].settings[indexPath.row]
        cell.settingsName.text = settings.name
        if indexPath.section == 0 || indexPath.section == 4 {
            
            if indexPath.section == 0 {
                if indexPath.row == 2 || indexPath.row == 3 {
                    cell.detailButton.isHidden = false
                } else {
                    cell.detailButton.isHidden = true
                }
            } else {
                cell.detailButton.isHidden = false
            }
            
        } else {
            cell.detailButton.isHidden = true
        }
        if indexPath.section == 4 {
            cell.onOffButton.isHidden = true
        } else {
            cell.onOffButton.isHidden = false
            cell.onOffButton.isSelected = settings.selected
        }
        if indexPath.section == 6 {
            cell.onOffButton.isSelected = Defaults.shared.isCombineSegments
        }
        if indexPath.section == 7 {
            cell.onOffButton.isSelected = Defaults.shared.isPublish
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableCell(withIdentifier: "StorySettingsHeader") as? StorySettingsHeader else {
            fatalError("StorySettingsHeader Not Found")
        }
        if section == 5 {
            headerView.title.isHidden = true
        } else {
            headerView.title.isHidden = false
        }
        if section == 0 || section == StorySettings.storySettings.count - 1 {
            headerView.separator.isHidden = true
        } else {
            headerView.separator.isHidden = false
        }
        
        headerView.title.text = StorySettings.storySettings[section].name
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 5 || section == 6 || section == 7 {
            return 24
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for (index,setting) in StorySettings.storySettings[indexPath.section].settings.enumerated() {
            if indexPath.section == 6 && index == indexPath.row {
                
                setting.selected = !setting.selected
                Defaults.shared.isCombineSegments = setting.selected
                tableView.reloadData()
                return
            }
            if indexPath.section == 7 && index == indexPath.row {
                setting.selected = !setting.selected
                Defaults.shared.isPublish = setting.selected
                tableView.reloadData()
                return
            }
            if index == indexPath.row {
                setting.selected = true
            } else {
                setting.selected = false
            }
        }
        tableView.reloadData()
    }
}
