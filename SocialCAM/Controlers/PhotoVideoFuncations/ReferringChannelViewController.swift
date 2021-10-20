//
//  ReferringChannelViewController.swift
//  SocialCAM
//
//  Created by Meet Mistry on 20/10/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit

class ReferringChannelViewController: UIViewController {
    
    // MARK: - Outlet Declaration
    @IBOutlet weak var referringChannelTableView: UITableView!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Action Method
    @IBAction func onBackPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARk: - Tableview Datasource
extension ReferringChannelViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ReferringChannel.referring.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let settingsTitle = ReferringChannel.referring[section]
        return settingsTitle.settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let referringChannelNamecell: ReferringChannelNameCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.referringChannelNameCell.identifier) as? ReferringChannelNameCell else {
            fatalError("\(R.reuseIdentifier.referringChannelNameCell.identifier) Not Found")
        }
        referringChannelNamecell.lblReferringChannelTitle.text = R.string.localizable.referringChannelName()
        if let referringName = Defaults.shared.currentUser?.refferingChannel {
            referringChannelNamecell.lblChannelName.text = R.string.localizable.referringChannel(referringName)
        }
        referringChannelNamecell.userImageView.layer.cornerRadius = referringChannelNamecell.userImageView.bounds.width / 2
        if let userImageUrl = Defaults.shared.currentUser?.refferedBy?.profileImageURL {
            referringChannelNamecell.userImageView.sd_setImage(with: URL.init(string: userImageUrl), placeholderImage: ApplicationSettings.userPlaceHolder)
        } else {
            referringChannelNamecell.userImageView.sd_setImage(with: URL.init(string: ""), placeholderImage: ApplicationSettings.userPlaceHolder)

        }
        if let socialPlatforms = Defaults.shared.referredByData?.socialPlatforms {
            socialPlatforms.count == 4 ? (referringChannelNamecell.imgSocialMediaBadge.isHidden = false) : (referringChannelNamecell.imgSocialMediaBadge.isHidden = true)
        }
        
        return referringChannelNamecell
    }
}

// MARK: - Tableview Delegate
extension ReferringChannelViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.storySettingsHeader.identifier) as? StorySettingsHeader else {
            fatalError("StorySettingsHeader Not Found")
        }
        headerView.title.isHidden = true
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let settingTitle = ReferringChannel.referring[section]
        return settingTitle.settingsType == .referringChannelName ? 10 : 5
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return ReferringChannel.referring[section].settingsType == .referringChannelName ? 10.0 : 1.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let settingTitle = ReferringChannel.referring[indexPath.section]
        return settingTitle.settingsType == .referringChannelName ? 60 : 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingTitle = ReferringChannel.referring[indexPath.section]
        if settingTitle.settingsType == .referringChannelName {
            if let userDetailsVC = R.storyboard.notificationVC.userDetailsVC() {
                MIBlurPopup.show(userDetailsVC, on: self)
            }
        }
    }
}
