//
//  ShareOnSocialMediaSettingsCell.swift
//  SocialCAM
//
//  Created by Sanjaysinh Chauhan on 24/08/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class ShareOnSocialMediaSettingsCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var objSocialShareitems: [StorySetting]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(R.nib.shareSocialMediaCell)
        self.layoutCells()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell() {
        
    }
    
    func layoutCells() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 5.0
        layout.minimumLineSpacing = 5.0
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.size.width - 20)/2, height: 50.0)
//        layout.itemSize = CGSize(width: (UIScreen.mainScreen().bounds.size.width - 40)/2, height: ((UIScreen.mainScreen().bounds.size.width - 40)/3))
        collectionView!.collectionViewLayout = layout
    }
    
    
    
}

extension ShareOnSocialMediaSettingsCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.objSocialShareitems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let setting = self.objSocialShareitems[indexPath.row]
        guard let shareSocialMediaCell: ShareSocialMediaCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.shareSocialMediaCell.identifier, for: indexPath) as? ShareSocialMediaCell else {
            fatalError("\(R.reuseIdentifier.shareSocialMediaCell.identifier) Not Found")
        }
        shareSocialMediaCell.lblSocialMediaName.text = setting.name
        shareSocialMediaCell.btnSocialShareEnable.setImage(R.image.checkBoxInActive(), for: .normal)
        shareSocialMediaCell.btnSocialShareEnable.setImage(R.image.checkBoxActive(), for: .selected)
        
        shareSocialMediaCell.btnSocialShareEnable.isSelected = setting.selected
        shareSocialMediaCell.imgSocialMediaIcon.image = setting.image
        
        let locale = Locale.current
        
        if setting.name == SocialMediaApps.tikTok.description {
            if locale.regionCode?.lowercased() == "in" {
                shareSocialMediaCell.btnSocialShareEnable.isSelected = false
            }
        } else if setting.name == SocialMediaApps.chingari.description {
            if locale.regionCode?.lowercased() != "in" {
                shareSocialMediaCell.btnSocialShareEnable.isSelected = false
            }
        }
        return shareSocialMediaCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let setting = self.objSocialShareitems[indexPath.row]
        setting.selected = !setting.selected
        
        let locale = Locale.current
        
        switch setting.name {
        case SocialMediaApps.tikTok.description:
            Defaults.shared.isTikTokSharingEnabled = setting.selected
            
            if locale.regionCode?.lowercased() == "in" {
                setting.selected = false
                Defaults.shared.isTikTokSharingEnabled = false
            }
        case SocialMediaApps.instagram.description:
            Defaults.shared.isInstagramSharingEnabled = setting.selected
        case SocialMediaApps.snapChat.description:
            Defaults.shared.isSnapChatSharingEnabled = setting.selected
        case SocialMediaApps.facebook.description:
            Defaults.shared.isFacebookSharingEnabled = setting.selected
        case SocialMediaApps.youtube.description:
            Defaults.shared.isYoutubeSharingEnabled = setting.selected
        case SocialMediaApps.twitter.description:
            Defaults.shared.isTwitterSharingEnabled = setting.selected
        case SocialMediaApps.chingari.description:
            Defaults.shared.isChingariSharingEnabled = setting.selected
            if locale.regionCode?.lowercased() != "in" {
                setting.selected = false
                Defaults.shared.isTikTokSharingEnabled = false
            }
        default:
            Defaults.shared.isTikTokSharingEnabled = setting.selected
        }
        
        collectionView.reloadData()
    }
    
    
}
