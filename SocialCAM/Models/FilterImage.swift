//
//  FilterImage.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 25/10/17.
//  Copyright © 2017 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit
import CoreMedia

class FilterImage: Equatable {
    var duration: String?
   
    var image: UIImage?
    var index: Int = 0
    var effectString: String?
    var thumbImage: UIImage?
    var url: URL?  // for video
    var type: ProMediaType
    var transform: CATransform3D = CATransform3DIdentity
    var lastAngle: CGFloat!
    var lastScale: CGFloat!
    var lastVHScale: CGFloat!
    var lastHVScale: CGFloat!
    var lastXAngle: CGFloat!
    var lastYAngle: CGFloat!
    var lastZAngle: CGFloat!
    var editOptionsArray: [EditOption] = []
    var thumbTime: CMTime?
    
    init(image: UIImage, index: Int) {
        self.image = image
        self.index = index
        self.type = .Image
    }

    init(url: URL, index: Int) {
        self.url = url
        self.index = index
        self.type = .Video
    }
    
}

func == (lhs: FilterImage, rhs: FilterImage) -> Bool {
    return (lhs.type == rhs.type && lhs.image == rhs.image && lhs.index == rhs.index && lhs.url == rhs.url )
}
