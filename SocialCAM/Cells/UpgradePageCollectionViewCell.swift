//
//  UpgradePageCollectionViewCell.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 20/06/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import FSPagerView

class UpgradePageCollectionViewCell: FSPagerViewCell {
    @IBOutlet var viewTitle: UIView!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblNumberOfChannel: UILabel!
    var primumTuple: PrimumTuple? {
        didSet {
            if let primumTuple = self.primumTuple {
                self.viewTitle.backgroundColor = primumTuple.color
                self.lblPrice.text = primumTuple.price
                self.lblNumberOfChannel.text = primumTuple.channel
            }
        }
    }
}
