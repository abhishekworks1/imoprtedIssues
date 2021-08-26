//
//  SelfSizedTableView.swift
//  SocialCAM
//
//  Created by Meet Mistry on 25/08/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

class SelfSizedTableView: UITableView {
    
    private var maxHeight: CGFloat = 402 {
        didSet {
            if contentSize.height == 225 {
                maxHeight = 240
            }
        }
    }
    
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }
    
    override var intrinsicContentSize: CGSize {
        let height = min(contentSize.height, maxHeight) + 20
        return CGSize(width: contentSize.width, height: height)
    }
}
