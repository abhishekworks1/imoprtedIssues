//
//  ChanelCell.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 19/05/17.
//  Copyright © 2017 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import SDWebImage

class ChanelCell: UITableViewCell {
    
    @IBOutlet var lblName: PLabel!
    @IBOutlet var lblCategories: PLabel?
    @IBOutlet var lblTags: PLabel?
    @IBOutlet var imgViewProf: UIImageView!
    @IBOutlet var btnFollow: PButton?
    
    var channel: Channel? {
        didSet {
            if let ch = channel {
                self.lblName.text = ch.channelId
                self.lblCategories?.text = ch.categories?.joined(separator: ", ")
                self.lblTags?.text = "\(ch.follower ?? 0) \(R.string.localizable.followers()) / \(ch.following ?? 0) \(R.string.localizable.following())"
                if ch.profileType == ProfilePicType.videoType.rawValue {
                    self.imgViewProf.backgroundColor = ApplicationSettings.appWhiteColor
                    if let p = ch.profileThumbnail {
                        self.imgViewProf.sd_setImage(with: URL.init(string: p) , placeholderImage: ApplicationSettings.userPlaceHolder)
                    } else {
                        self.imgViewProf.image = ApplicationSettings.userPlaceHolder
                    }
                } else {
                    if let p = ch.profileImageURL {
                        self.imgViewProf.sd_setImage(with: URL.init(string: p), placeholderImage: ApplicationSettings.userPlaceHolder)
                    } else {
                        self.imgViewProf.image = ApplicationSettings.userPlaceHolder
                    }
                }
                if ch.isFollowing == true {
                    btnFollow?.backgroundColor = ApplicationSettings.appPrimaryColor
                    btnFollow?.setTitleColor(ApplicationSettings.appWhiteColor, for: .normal)
                    btnFollow?.setTitle(R.string.localizable.following(), for: .normal)
                } else {
                    btnFollow?.backgroundColor = ApplicationSettings.appClearColor
                    btnFollow?.setTitleColor(ApplicationSettings.appPrimaryColor, for: .normal)
                    btnFollow?.setTitle(R.string.localizable.follow(), for: .normal)
                }
                self.selectionStyle = .none
                self.updateConstraintsIfNeeded()
                self.setNeedsUpdateConstraints()
            }
        }
    }

}
