//
//  PaymentTableViewCell.swift
//  ProManager
//
//  Created by Steffi Pravasi on 31/07/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit

class PaymentTableViewCell: UITableViewCell {

    @IBOutlet var checkBtn: CheckButton!
    @IBOutlet var paymentLbl: UILabel!
    @IBOutlet var paymentMethodImgVw: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
