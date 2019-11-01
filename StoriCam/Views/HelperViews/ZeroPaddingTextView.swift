//
//  ZeroPaddingTextView.swift
//  ProManager
//
//  Created by Viraj Patel on 18/04/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class ZeroPaddingTextView: UITextView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
    
}
