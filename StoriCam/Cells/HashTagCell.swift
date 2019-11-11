//
//  HashTagCell.swift
//  ProManager
//
//  Created by Steffi Pravasi on 11/09/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit

class HashTagCell: UITableViewCell {

    @IBOutlet var hashTagName: PLabel!
    @IBOutlet var hashTagSubname: PLabel!
    @IBOutlet var hashTagCount: UILabel!
    @IBOutlet var hashTagSet: UILabel!
    
    func setData(name: String, subName: Int, set: String, count: Int) {
        hashTagName.text = name
        hashTagSubname.text = "\(subName) #’s"
        hashTagSet.text = set
        hashTagCount.text = String(count)
    }
}
