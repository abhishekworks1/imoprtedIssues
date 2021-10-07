//
//  SocialMediaProfileSettings.swift
//  SocialCAM
//
//  Created by Nilisha Gupta on 06/09/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation

class SocialMediaProfileSettings {
    
    var name: String
    var settings: [SocialPlatformListSetting]
    var settingsType: ProfileSocialShare
    
    init(name: String, settings: [SocialPlatformListSetting], settingsType: ProfileSocialShare) {
        self.name = name
        self.settings = settings
        self.settingsType = settingsType
    }
    //#NO_RESOURCE_FOUND_BOOMI
//    static var storySettings = [SocialMediaProfileSettings(name: "", settings: [SocialPlatformListSetting(name: R.string.localizable.gallery(), image: R.image.gallerySocialShare())], settingsType: .gallery),
//                                SocialMediaProfileSettings(name: "", settings: [SocialPlatformListSetting(name: R.string.localizable.camera(), image: R.image.cameraSocialShare())], settingsType: .camera),
//                                SocialMediaProfileSettings(name: "", settings: [SocialPlatformListSetting(name: R.string.localizable.snapchat(), image: R.image.snapchatSocialShare())], settingsType: .snapchat),
//                                SocialMediaProfileSettings(name: "", settings: [SocialPlatformListSetting(name: R.string.localizable.youtube(), image: R.image.youtubeSocialShare())], settingsType: .youTube),
//                                SocialMediaProfileSettings(name: "", settings: [SocialPlatformListSetting(name: R.string.localizable.twitter(), image: R.image.twitterSocialShare())], settingsType: .twitter),
//                                SocialMediaProfileSettings(name: "", settings: [SocialPlatformListSetting(name: R.string.localizable.facebook(), image: R.image.facebookSocialShare())], settingsType: .facebook)]
    
        static var storySettings = [SocialMediaProfileSettings(name: "", settings: [SocialPlatformListSetting(name: R.string.localizable.gallery(), image: R.image.moodJPG())], settingsType: .gallery),
                                    SocialMediaProfileSettings(name: "", settings: [SocialPlatformListSetting(name: R.string.localizable.camera(), image: R.image.moodJPG())], settingsType: .camera),
                                    SocialMediaProfileSettings(name: "", settings: [SocialPlatformListSetting(name: R.string.localizable.snapchat(), image: R.image.moodJPG())], settingsType: .snapchat),
                                    SocialMediaProfileSettings(name: "", settings: [SocialPlatformListSetting(name: R.string.localizable.youtube(), image: R.image.moodJPG())], settingsType: .youTube),
                                    SocialMediaProfileSettings(name: "", settings: [SocialPlatformListSetting(name: R.string.localizable.twitter(), image: R.image.moodJPG())], settingsType: .twitter),
                                    SocialMediaProfileSettings(name: "", settings: [SocialPlatformListSetting(name: R.string.localizable.facebook(), image: R.image.moodJPG())], settingsType: .facebook)]
    
}
