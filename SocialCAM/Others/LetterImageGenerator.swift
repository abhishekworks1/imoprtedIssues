//
//  LetterImageGenerator.swift
//  SocialCAM
//
//  Created by Viraj Patel on 07/10/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit

class LetterImageGenerator: NSObject {
    class func imageWith(name: String) -> UIImage? {
        var size: CGSize
        var textSize: CGFloat
        if name.count >= 27, name.count <= 30 {
            textSize = 22
        } else if name.count >= 21, name.count <= 26 {
            textSize = 25
        } else {
            textSize = 30
        }
        size = name.size(withAttributes:[.font: UIFont.boldSystemFont(ofSize: textSize)])
        let frame = CGRect(x: 0, y: 0, width: size.width, height: 50)
        let nameLabel = UILabel(frame: frame)
        nameLabel.textAlignment = .left
        nameLabel.backgroundColor = .clear
        nameLabel.textColor = .white
        nameLabel.font = UIFont.boldSystemFont(ofSize: textSize)
        nameLabel.text = name
        UIGraphicsBeginImageContext(frame.size)
        if let currentContext = UIGraphicsGetCurrentContext() {
            nameLabel.layer.render(in: currentContext)
            let nameImage = UIGraphicsGetImageFromCurrentImageContext()
            return nameImage
        }
        return nil
    }
}
