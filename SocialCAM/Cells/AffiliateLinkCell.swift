//
//  AffiliateLinkCell.swift
//  SocialCAM
//
//  Created by Meet Mistry on 12/08/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit

class AffiliateLinkCell: UITableViewCell {
    
    // MARK: - Outlet Declaration
    @IBOutlet weak var lblAffiliateTitle: UILabel!
    @IBOutlet weak var imgReferredUser: UIImageView!
    @IBOutlet weak var referredUserImgWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var referredUserImgLeadingConstrarint: NSLayoutConstraint!
    @IBOutlet weak var lblReferredCount: UILabel!
    @IBOutlet weak var affiliateViewTopConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
