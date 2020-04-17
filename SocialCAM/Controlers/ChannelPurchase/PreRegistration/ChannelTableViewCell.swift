//
//  ChannelTableViewCell.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 04/07/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import SDWebImage

class ChannelSelectedCell: UITableViewCell {
    
    @IBOutlet var imgParentChannel: UIImageView!
    @IBOutlet var imgSelectedChannel: UIImageView!
    @IBOutlet var imgViewProfile : RoundedImageView!
    @IBOutlet var lblChannelName : UILabel!
    @IBOutlet var selectedView: UIView!
    
    let parentId = Defaults.shared.parentID ?? ""
    
    var user : User? {
        didSet {
            if let user = user {
                if let img = user.profileThumbnail, img != "" {
                    imgViewProfile.sd_setImage(with: URL(string: img), placeholderImage: ApplicationSettings.userPlaceHolder)
                } else if let img = user.profileImageURL, img != "" {
                    imgViewProfile.sd_setImage(with: URL(string: img), placeholderImage: ApplicationSettings.userPlaceHolder)
                } else {
                    imgViewProfile.image = ApplicationSettings.userPlaceHolder
                }
                lblChannelName.text = user.channelId
                if parentId == user.id {
                    imgParentChannel.isHidden = false
                    imgParentChannel.image = R.image.ico_parent_channel_fill_copy()?.withRenderingMode(.alwaysTemplate)
                    imgParentChannel.tintColor = ApplicationSettings.appPrimaryColor
                } else {
                    imgParentChannel.isHidden = true
                }
                if user.id == Defaults.shared.currentUser?.id {
                    selectedView.isHidden = false
                    imgSelectedChannel.image = R.image.checkOn()
                    imgSelectedChannel.setImageWithTintColor(color: ApplicationSettings.appPrimaryColor)
                } else {
                    selectedView.isHidden = true
                    imgSelectedChannel.image = R.image.checkOff()
                }
            } else {
                imgViewProfile.image = ApplicationSettings.userPlaceHolder
                lblChannelName.text = ""
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgViewProfile.backgroundColor = ApplicationSettings.appWhiteColor
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class ChannelTableViewCell: UITableViewCell {
    
    @IBOutlet var imgParentChannel: UIImageView!
    @IBOutlet var imgSelectedChannel: UIImageView!
    @IBOutlet var imgViewProfile : RoundedImageView!
    @IBOutlet var lblChannelName : UILabel!
    @IBOutlet var selectedView: UIView!
    let parentId = Defaults.shared.parentID ?? ""
    
    var user : User? {
        didSet {
            if let user = user {
                if let img = user.profileThumbnail, img != "" {
                    imgViewProfile.sd_setImage(with: URL(string: img), placeholderImage: ApplicationSettings.userPlaceHolder)
                } else if let img = user.profileImageURL, img != "" {
                    imgViewProfile.sd_setImage(with: URL(string: img), placeholderImage: ApplicationSettings.userPlaceHolder)
                } else {
                    imgViewProfile.image = ApplicationSettings.userPlaceHolder
                }
                lblChannelName.text = user.channelId
                if parentId == user.id {
                    imgParentChannel.isHidden = false
                    imgParentChannel.image = R.image.ico_parent_channel_fill_copy()?.withRenderingMode(.alwaysTemplate)
                    imgParentChannel.tintColor = ApplicationSettings.appPrimaryColor
                } else {
                    imgParentChannel.isHidden = true
                }
                if user.id == Defaults.shared.currentUser?.id {
                    selectedView.isHidden = false
                    imgSelectedChannel.image = R.image.checkOn()
                    imgSelectedChannel.setImageWithTintColor(color: ApplicationSettings.appPrimaryColor)
                } else {
                    selectedView.isHidden = true
                    imgSelectedChannel.image = R.image.checkOff()
                }
            }  else {
              imgViewProfile.image = ApplicationSettings.userPlaceHolder
              lblChannelName.text = ""
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        imgViewProfile.backgroundColor = ApplicationSettings.appWhiteColor
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
