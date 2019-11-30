//
//  SubscribeChannelCell.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 27/02/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import UIKit

class SubscribeChannelCell: UICollectionViewCell {
    @IBOutlet var imgViewChannel: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    var channel: YouTubeSubscription? {
        didSet {
            if let channel =  channel {
                self.configData(channel: channel)
            }
        }
    }
    
    func configData(channel: YouTubeSubscription) {
        if let thumbnail = channel.snippet?.thumbnail {
            self.imgViewChannel.setImageFromURL(thumbnail)
        }
        if let title = channel.snippet?.title {
            self.lblTitle.text = title
        }
    }
    
}
