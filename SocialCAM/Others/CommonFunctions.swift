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
    
    static func hexStringFromColor(color: UIColor) -> String {
        let components = color.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        print(hexString)
        return hexString
    }
    
    static func getDateInSpecificFormat(dateInput: String, dateOutput: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = R.string.localizable.yyyyMMDdTHHMmSsSSSZ()
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = dateOutput
        if let date = dateFormatterGet.date(from: dateInput) {
            return dateFormatterPrint.string(from: date)
        } else {
            return R.string.localizable.thereWasAnErrorDecodingTheString()
        }
    }
    
    static func getCurrentDate(dateOutput: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = R.string.localizable.yyyyMMDdHHMmSs()
        let myString = formatter.string(from: Date())
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = dateOutput
        let currentDate = formatter.string(from: yourDate!)
        return currentDate
    }
    
}
