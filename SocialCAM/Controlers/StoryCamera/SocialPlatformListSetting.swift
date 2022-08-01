//
//  SocialPlatformListSetting.swift
//  SocialCAM
//
//  Created by Nilisha Gupta on 06/09/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation

class SocialPlatformListSetting {
    
    var name: String
    var image: UIImage?
    var selectedImage: UIImage?
    
    init(name: String, image: UIImage? = UIImage(), selectedImage: UIImage? = UIImage()) {
        self.name = name
        self.image = image
        self.selectedImage = selectedImage
    }
    
}
