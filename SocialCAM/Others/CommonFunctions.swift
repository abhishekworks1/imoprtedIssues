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
    
    static func setAppLogo(imgLogo: UIImageView) {
        #if VIRALCAMAPP
        imgLogo.image = R.image.viralcamrgb()
        #elseif SOCCERCAMAPP || FUTBOLCAMAPP
        imgLogo.image = R.image.soccercamWatermarkLogo()
        #elseif QUICKCAMAPP
        imgLogo.image = R.image.quickcamWatermarkLogo()
        #elseif SNAPCAMAPP
        imgLogo.image = R.image.snapcamWatermarkLogo()
        #elseif SPEEDCAMAPP
        imgLogo.image = R.image.speedcamWatermarkLogo()
        #elseif TIMESPEEDAPP
        imgLogo.image = R.image.timeSpeedWatermarkLogo()
        #elseif FASTCAMAPP
        imgLogo.image = R.image.fastcamWatermarkLogo()
        #elseif BOOMICAMAPP
        imgLogo.image = R.image.boomicamWatermarkLogo()
        #elseif VIRALCAMLITEAPP
        imgLogo.image = R.image.viralcamLiteWatermark()
        #elseif FASTCAMLITEAPP
        imgLogo.image = R.image.fastcamLiteWatermarkLogo()
        #elseif QUICKCAMLITEAPP || QUICKAPP
        imgLogo.image = R.image.quickcamWatermarkLogo()
        #elseif SPEEDCAMLITEAPP
        imgLogo.image = R.image.speedcamliteSplashLogo()
        #elseif SNAPCAMLITEAPP
        imgLogo.image = R.image.snapcamliteSplashLogo()
        #elseif RECORDERAPP
        imgLogo.image = R.image.socialScreenRecorderWatermarkLogo()
        #else
        imgLogo.image = R.image.pic2artWatermarkLogo()
        #endif
    }
    
}
