//
//  SelectLink.swift
//  SocialCAM
//
//  Created by Meet Mistry on 24/08/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation

class SelectLink {
    
    var name: String
    var linkSettings: [SelectLinkSetting]
    var linkType: LinkMode
    
    init(name: String, linkSettings: [SelectLinkSetting], linkType: LinkMode) {
        self.name = name
        self.linkSettings = linkSettings
        self.linkType = linkType
    }
    
    static var selectLinks = [SelectLink]()
}
