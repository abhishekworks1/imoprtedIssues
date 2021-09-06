//
//  EditProfileSocialShareViewController.swift
//  SocialCAM
//
//  Created by Nilisha Gupta on 02/09/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit

enum ProfileSocialShare: Int {
    case gallery = 0
    case camera
    case instagram
    case snapchat
    case youTube
    case twitter
    case facebook
}

class EditProfileSocialShareViewController: UIViewController {
    
    // MARK: - Outlets Declaration
    @IBOutlet weak var socialShareTableView: UITableView!
    @IBOutlet weak var lblSocialSharePopup: UILabel!
    @IBOutlet weak var socialSharePopupView: UIView!
    @IBOutlet weak var backgroundUpperView: UIView!
    @IBOutlet weak var cancelView: UIView!
    
    // MARK: - Variable Declarations
    var editProfilePicVC = EditProfilePicViewController()
    var socialType: ProfileSocialShare?
    var delegate: SharingSocialTypeDelegate?
    var socialLogins = Defaults.shared.socialPlatforms
    
    // MARK: - View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.socialShareTableView.isUserInteractionEnabled = true
    }
    
    func showHidePopupView(socialType: ProfileSocialShare) {
        dismiss(animated: true) {
            self.delegate?.shareSocialType(socialType: socialType)
        }
    }
    
    // MARK: - Action Methods
    @IBAction func btnYesTapped(_ sender: UIButton) {
        dismiss(animated: true) {
            if let socialType = self.socialType {
                self.delegate?.shareSocialType(socialType: socialType)
            }
        }
    }
    
    @IBAction func btnNoTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnCancelTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}

// MARK: - Table View DataSource
extension EditProfileSocialShareViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SocialMediaProfileSettings.storySettings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SocialMediaProfileSettings.storySettings[section].settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: SelectLinkCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.selectLinkCell.identifier) as? SelectLinkCell else {
            fatalError("\(R.reuseIdentifier.selectLinkCell.identifier) Not Found")
        }
        
        let settingTitle = SocialMediaProfileSettings.storySettings[indexPath.section]
        let setting = settingTitle.settings[indexPath.row]
        cell.lblLinkName.text = setting.name
        cell.imgLinkIcon.image = setting.image
        if let socialLogins = Defaults.shared.socialPlatforms {
            for socialType in socialLogins {
                if socialType == setting.name.lowercased() {
                    cell.imgSocialCheckmark.isHidden = false
                    cell.imgSocialCheckmark.image = R.image.socialShareCheckMark()
                }
            }
        }
        return cell
    }
}

// MARK: - Table View Delegate
extension EditProfileSocialShareViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.storySettingsHeader.identifier) as? StorySettingsHeader else {
            fatalError("StorySettingsHeader Not Found")
        }
        headerView.title.isHidden = true
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingTitle = SocialMediaProfileSettings.storySettings[indexPath.section]
        let type = settingTitle.settingsType
        switch type {
        case .gallery:
            dismiss(animated: true) {
                self.delegate?.shareSocialType(socialType: .gallery)
            }
        case .camera:
            dismiss(animated: true) {
                self.delegate?.shareSocialType(socialType: .camera)
            }
        case .instagram:
            self.showHidePopupView(socialType: .instagram)
        case .snapchat:
            self.showHidePopupView(socialType: .snapchat)
        case .youTube:
            self.showHidePopupView(socialType: .youTube)
        case .twitter:
            self.showHidePopupView(socialType: .twitter)
        case .facebook:
            self.showHidePopupView(socialType: .facebook)
        }
    }
    
}
