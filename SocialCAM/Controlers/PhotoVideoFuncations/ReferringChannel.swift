//
//  ReferringChannel.swift
//  SocialCAM
//
//  Created by Meet Mistry on 20/10/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation

class ReferringChannel {
    
    var name: String
    var settings: [StorySetting]
    var settingsType: SettingsMode
    
    init(name: String, settings: [StorySetting], settingsType: SettingsMode) {
        self.name = name
        self.settings = settings
        self.settingsType = settingsType
    }
    
    static var referring = [
        StorySettings(name: "", settings: [StorySetting(name: R.string.localizable.referringChannelName(), selected: false)], settingsType: .referringChannelName)
    ]
}
