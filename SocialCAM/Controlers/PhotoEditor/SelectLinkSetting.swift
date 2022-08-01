//
//  SelectLinkSetting.swift
//  SocialCAM
//
//  Created by Meet Mistry on 24/08/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation

class SelectLinkSetting {
    var name: String
    var image: UIImage?
    
    init(name: String, image: UIImage? = UIImage()) {
        self.name = name
        self.image = image
    }
}
