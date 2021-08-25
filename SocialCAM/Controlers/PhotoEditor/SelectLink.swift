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
    
    static var selectLinks = [SelectLink(name: "", linkSettings: [SelectLinkSetting(name: R.string.localizable.quickCam(), image: R.image.iconQuickCam())], linkType: .quickCam),
                              SelectLink(name: "", linkSettings: [SelectLinkSetting(name: R.string.localizable.vidPlay(), image: R.image.iconVidPlay())], linkType: .vidPlay),
                              SelectLink(name: "", linkSettings: [SelectLinkSetting(name: R.string.localizable.newBusinessCenter(), image: R.image.iconBusinessCenter())], linkType: .businessCenter),
                              SelectLink(name: "", linkSettings: [SelectLinkSetting(name: R.string.localizable.enterALink(), image: R.image.iconLink())], linkType: .enterLink),
                              SelectLink(name: "", linkSettings: [SelectLinkSetting(name: R.string.localizable.noLink(), image: R.image.iconNoLink())], linkType: .noLink)
    ]
}
