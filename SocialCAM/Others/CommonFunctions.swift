//
//  CommonFunctions.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 15/10/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit

struct CommonFunctions {
    
    static func getFormattedNumberString(number: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = isLiteApp ? numberFormatter.string(from: NSNumber(value: number)) : numberFormatter.string(from: NSNumber(value: Int(number)))
        return formattedNumber ?? ""
    }
    
    static func getFormattedNumberString(number: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value: number))
        return formattedNumber ?? ""
    }
}
