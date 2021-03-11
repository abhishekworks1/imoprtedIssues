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
        let size = name.size(withAttributes:[.font: UIFont.boldSystemFont(ofSize: 40)])
        let frame = CGRect(x: 0, y: 0, width: size.width, height: 50)
        let nameLabel = UILabel(frame: frame)
        nameLabel.textAlignment = .left
        nameLabel.backgroundColor = .clear
        nameLabel.textColor = .white
        if name.count >= 27, name.count <= 30 {
            nameLabel.font = UIFont.boldSystemFont(ofSize: 28)
        } else if name.count >= 21, name.count <= 26 {
            nameLabel.font = UIFont.boldSystemFont(ofSize: 30)
        } else {
            nameLabel.font = UIFont.boldSystemFont(ofSize: 40)
        }
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
