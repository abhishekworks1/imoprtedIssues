//
//  ShareSocialMediaCell.swift
//  SocialCAM
//
//  Created by Sanjaysinh Chauhan on 23/08/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class ShareSocialMediaCell: UICollectionViewCell {

    @IBOutlet weak var btnSocialShareEnable: UIButton!
    @IBOutlet weak var imgSocialMediaIcon: UIImageView!
    @IBOutlet weak var lblSocialMediaName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btnSocialShareEnable.isUserInteractionEnabled = false
    }

    func configureCell() {
        
    }
}
