//
//  BadgesCollectionViewCell.swift
//  SocialCAM
//
//  Created by Siddharth on 05/09/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class BadgesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var badgeNameLabel: UILabel!
    @IBOutlet weak var badgeDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    func setUpbadgesViewForLoad(badgesDetails: GetBadges) {
        badgeImageView.image = badgesDetails.badgesImage
        badgeNameLabel.text = badgesDetails.badgeName
    }
    
}
