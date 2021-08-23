//
//  YourAffiliateLink.swift
//  SocialCAM
//
//  Created by Meet Mistry on 24/08/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation

class YourAffiliateLink {
    var name: String
    var settings: [AffiliateSetting]
    var type: Type
    
    init(name: String, settings: [AffiliateSetting], type: Type) {
        self.name = name
        self.settings = settings
        self.type = type
    }
    
    static var yourAffiliteLinks = [YourAffiliateLink]()
}
