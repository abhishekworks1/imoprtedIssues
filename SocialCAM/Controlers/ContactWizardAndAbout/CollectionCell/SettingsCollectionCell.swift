//
//  SettingsCollectionCell.swift
//  SocialCAM
//
//  Created by ideveloper5 on 25/04/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class SettingsCollectionCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var settingsName: UILabel!
    @IBOutlet weak var socialImageView: UIImageView?
    @IBOutlet weak var imgSubscribeBadge: UIImageView!
    
    @IBOutlet weak var countLabel: ColorBGLabel!
    @IBOutlet weak var roundedView: RoundedView!
    
    
    @IBOutlet weak var iosBadgeView: UIView!
    @IBOutlet weak var iosSheildImageview: UIImageView!
    @IBOutlet weak var iosIconImageview: UIImageView!
    @IBOutlet weak var lbliosDaysRemains: UILabel!
    
    @IBOutlet weak var androidBadgeView: UIView!
    @IBOutlet weak var androidSheildImageview: UIImageView!
    @IBOutlet weak var androidIconImageview: UIImageView!
    @IBOutlet weak var lblandroidDaysRemains: UILabel!
    
    @IBOutlet weak var webBadgeView: UIView!
    @IBOutlet weak var webSheildImageview: UIImageView!
    @IBOutlet weak var webIconImageview: UIImageView!
    @IBOutlet weak var lblwebDaysRemains: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.dropShadowNew()
    }

}
