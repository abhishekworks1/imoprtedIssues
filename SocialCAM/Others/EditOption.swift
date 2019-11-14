//
//  EditOption.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 16/02/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

class EditSettings: NSCopying {
    var minimumValue: Float
    var value: Float
    var maximumValue: Float
    var pivotValue: Float
    var isPositive: Bool

    init(minimumValue: Float, value: Float, maximumValue: Float, pivotValue: Float, isPositive: Bool = true) {
        self.minimumValue = minimumValue
        self.value = value
        self.maximumValue = maximumValue
        self.pivotValue = pivotValue
        self.isPositive = isPositive
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copyObj = EditSettings(minimumValue: minimumValue, value: value, maximumValue: maximumValue, pivotValue: pivotValue, isPositive: isPositive)
        return copyObj
    }
}


class EditOption: NSCopying {
    var name: String
    var image: UIImage
    var configString: String
    var editSettings: EditSettings
    var range: String

    init(name: String, image: UIImage, configString: String, editSettings: EditSettings, range: String = "") {
        self.name = name
        self.image = image
        self.configString = configString
        self.editSettings = editSettings
        self.range = range
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = EditOption(name: name, image: image.copy() as? UIImage ?? UIImage(), configString: configString, editSettings: (editSettings.copy() as? EditSettings)! , range: range)
        return copy
    }

    static var editOptions = defaultEditOptions.map {
        $0.copy() as! EditOption
    }

}

let defaultEditOptions = [EditOption(name: "Adjust",
                                     image: #imageLiteral(resourceName: "ico_adjust"),
                                     configString: "@adjust",
                                     editSettings: EditSettings(minimumValue: 0.0, value: 0.5, maximumValue: 1, pivotValue: 0.0)),
                          EditOption(name: "Brightness",
                                     image: #imageLiteral(resourceName: "ico_brightness"),
                                     configString: "@adjust brightness ",
                                     editSettings: EditSettings(minimumValue: -1.0, value: 0.0, maximumValue: 1.0, pivotValue: 0.0)),
                          EditOption(name: "Contrast",
                                     image: #imageLiteral(resourceName: "ico_contrast"),
                                     configString: "@adjust contrast ",
                                     editSettings: EditSettings(minimumValue: 0.4, value: 1.0, maximumValue: 1.6, pivotValue: 1.0)),
                          EditOption(name: "Saturation",
                                     image: #imageLiteral(resourceName: "ico_saturation"),
                                     configString: "@adjust saturation ",
                                     editSettings: EditSettings(minimumValue: 0.0, value: 1.0, maximumValue: 2.0, pivotValue: 1.0)),
                          EditOption(name: "Sharpen",
                                     image: #imageLiteral(resourceName: "ico_sharpen"),
                                     configString: "@adjust sharpen ",
                                     editSettings: EditSettings(minimumValue: 0.0, value: 0.0, maximumValue: 5.0, pivotValue: 0.0),
                                     range: "2 "),
                          EditOption(name: "Shadows",
                                     image: #imageLiteral(resourceName: "ico_shadows"),
                                     configString: "@adjust shadowhighlight ",
                                     editSettings: EditSettings(minimumValue: -100, value: 0.0, maximumValue: 100, pivotValue: 0.0),
                                     range: " 0 "),
                          EditOption(name: "Highlights",
                                     image: #imageLiteral(resourceName: "ico_hightlights"),
                                     configString: "@adjust shadowhighlight 0 ",
                                     editSettings: EditSettings(minimumValue: -100, value: 0.0, maximumValue: 100, pivotValue:  0.0)),
                          EditOption(name: "Vignette",
                                     image: #imageLiteral(resourceName: "ico_vignette"),
                                     configString: "@vignette ",
                                     editSettings: EditSettings(minimumValue: 0.0, value: 1.0, maximumValue: 1.0, pivotValue: 1.0, isPositive: false),
                                     range: " 0.9 "),
                          EditOption(name: "Exposure",
                                     image: #imageLiteral(resourceName: "ico_warmth"),
                                     configString: "@adjust exposure ",
                                     editSettings: EditSettings(minimumValue: 0, value: 0.0, maximumValue: 1, pivotValue: 0.0))
    
                          ]


//  EditOption(name: "Tilt Shift",
//           image: #imageLiteral(resourceName: "ico_tiltShift"),
//           configString: "@tilt ",
//           editSettings: EditSettings(minimumValue: 0.0, value: 0.5, maximumValue: 1, pivotValue: 0.0))
//  EditOption(name: "Warmth",
//           image: #imageLiteral(resourceName: "ico_warmth"),
//           configString: "@curve ",
//           editSettings: EditSettings(minimumValue: 0.0, value: 0.5, maximumValue: 1, pivotValue: 0.0)),
//  "@adjust exposure 0.98 ",
//  "@adjust shadowhighlight -200 200 ",
//  "@adjust sharpen 10 1.5 ",
//  "@adjust colorbalance 0.99 0.52 -0.31 ",
//  "@adjust level 0.66 0.23 0.44 ",
