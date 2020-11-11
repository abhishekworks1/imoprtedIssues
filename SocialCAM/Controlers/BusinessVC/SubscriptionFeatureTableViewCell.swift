//
//  SubscriptionFeatureTableViewCell.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 11/11/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit

class SubscriptionFeatureTableViewCell: UITableViewCell {

    @IBOutlet weak var lblDescription: UILabel!
    
    func setData(description: String) {
        self.lblDescription.text = description
    }

}
