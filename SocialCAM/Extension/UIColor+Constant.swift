//
//  UIColor+Extension.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 20/11/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    @nonobjc public static let startColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1)
    @nonobjc public static let endColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1)

    @nonobjc public static let gray153 = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1) // no name in zepline
    @nonobjc public static let gray79 = UIColor(red: 79/255, green: 79/255, blue: 79/255, alpha: 1)    // no name in zepline
    @nonobjc public static let gray3937 = UIColor(red: 39/255, green: 37/255, blue: 37/255, alpha: 1) // no name in zepline
    @nonobjc public static let gray85 = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1)  // no name in zepline
    @nonobjc public static let gray227 = UIColor(red: 227/255, green: 227/255, blue: 227/255, alpha: 1) // no name in zepline
    @nonobjc public static let green651175 = UIColor(red: 65/255, green: 117/255, blue: 5/255, alpha: 1) // no name in zepline
    @nonobjc public static let gray90 = UIColor(red: 90.0/255, green: 90.0/255, blue: 90.0/255, alpha: 1)  // no name in zepline
    @nonobjc public static let gray181 = UIColor(red: 181.0/255, green: 181.0/255, blue: 181.0/255, alpha: 1) // no name inside Zepline
    @nonobjc public static let black66 = UIColor(red: 66.0/255, green: 66.0/255, blue: 65.0/255, alpha: 1.0) // no name in side Zepline
    @nonobjc public static let tagTxtNormal = UIColor(red: 25.0/255, green: 32.0/255, blue: 46.0/255, alpha: 1)
    @nonobjc public static let squashTwo = UIColor(red: 245.0/255.0, green: 166.0/255.0, blue: 35.0/255.0, alpha: 1)
    @nonobjc public static let seafoamBlue60 = UIColor(red: 110/255.0, green: 201/255.0, blue: 201/255.0, alpha: 0.8)
    @nonobjc public static let bubbleBackground = UIColor.init(red: 231/255, green: 231/255, blue: 235/255, alpha: 1.0)
   
    class func hex (_ hexStr: NSString, alpha: CGFloat) -> UIColor {
        
        let realHexStr = hexStr.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: realHexStr as String)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let rValue = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let gValue = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let bValue = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red: rValue, green: gValue, blue: bValue, alpha: alpha)
        } else {
            print("invalid hex string", terminator: "")
            return ApplicationSettings.appWhiteColor
        }
    }
    
    var isLight: Bool {
        var white: CGFloat = 0
        getWhite(&white, alpha: nil)
        return white > 0.5
    }
    
    class func gradientColorFrom(colors: [UIColor], and size: CGSize, isVertical: Bool = false) -> UIColor? {
        var colorComponents: [CGFloat] = []
        var numOfLocations = 0
        for color in colors {
            var colorRed: CGFloat = 0
            var colorGreen: CGFloat = 0
            var colorBlue: CGFloat = 0
            var colorAlpha: CGFloat = 0
            if color.getRed(&colorRed, green: &colorGreen, blue: &colorBlue, alpha: &colorAlpha) {
                colorComponents.append(colorRed)
                colorComponents.append(colorGreen)
                colorComponents.append(colorBlue)
                colorComponents.append(colorAlpha)
                numOfLocations += 1
            }
        }
        
        let width = size.width
        let height = size.height
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        UIGraphicsPushContext(context)
        
        let glossGradient: CGGradient?
        let rgbColorspace: CGColorSpace?
        var locations: [CGFloat] = [0.0, 1.0]
        
        if numOfLocations > 2 {
            let numParts: CGFloat = CGFloat(numOfLocations - 1)
            let partValue: CGFloat = CGFloat(1/numParts)
            locations = []
            var totalPartValue: CGFloat = 0.0
            for _ in 0..<numOfLocations {
                locations.append(totalPartValue)
                totalPartValue = partValue + totalPartValue
            }
        }
        
        rgbColorspace = CGColorSpaceCreateDeviceRGB()
        glossGradient = CGGradient(colorSpace: rgbColorspace!,
                                   colorComponents: colorComponents,
                                   locations: locations,
                                   count: numOfLocations)
        
        let topCenter = CGPoint.zero
        let bottomPoint = isVertical ? CGPoint(x: 0, y: size.height) : CGPoint(x: size.width, y: 0)
        let bottomCenter = bottomPoint
        
        context.drawLinearGradient(glossGradient!, start: topCenter, end: bottomCenter, options: CGGradientDrawingOptions.drawsBeforeStartLocation)
        
        UIGraphicsPopContext()
        
        guard let gradientImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        UIGraphicsEndImageContext()
        
        return UIColor(patternImage: gradientImage)
    }
    
    func rgbtoGrayScale() -> UIColor {
        var rValue: CGFloat = 0, gValue: CGFloat = 0, bValue: CGFloat=0, aValue: CGFloat=0
        _ = self.getRed(&rValue, green: &gValue, blue: &bValue, alpha: &aValue)
        let xValue = (0.3 * rValue + 0.59 * gValue + 0.11 * bValue)
        let newcolor = UIColor(red: xValue, green: xValue, blue: xValue, alpha: aValue)
        return newcolor
    }
    
    static func randomColorForIndex(index: Int) -> UIColor {
        let colors = [UIColor(red: 255.0/255.0, green: 159.0/255.0, blue: 0.0/255.0, alpha: 1),
                      UIColor(red: 83.0/255.0, green: 184.0/255.0, blue: 255.0/255.0, alpha: 1),
                      UIColor(red: 82.0/255.0, green: 152.0/255.0, blue: 63.0/255.0, alpha: 1),
                      UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 67.0/255.0, alpha: 1),
                      UIColor(red: 255.0/255.0, green: 201.0/255.0, blue: 0.0/255.0, alpha: 1),
                      UIColor(red: 208.0/255.0, green: 2.0/255.0, blue: 27.0/255.0, alpha: 1),
                      UIColor(red: 2.0/255.0, green: 252.0/255.0, blue: 196.0/255.0, alpha: 1)
                      ]
        return colors[index % colors.count]
    }
    
    open class var checkmarkGrayColor: UIColor {
        return UIColor(red: 145/255, green: 151/255, blue: 163/255, alpha: 1.0)
    }
    
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let aValue, rValue, gValue, bValue: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (aValue, rValue, gValue, bValue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (aValue, rValue, gValue, bValue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (aValue, rValue, gValue, bValue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (aValue, rValue, gValue, bValue) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(rValue) / 255, green: CGFloat(gValue) / 255, blue: CGFloat(bValue) / 255, alpha: CGFloat(aValue) / 255)
    }
    
    func toHexString() -> String {
        var rValue: CGFloat = 0
        var gValue: CGFloat = 0
        var bValue: CGFloat = 0
        var aValue: CGFloat = 0
        
        getRed(&rValue, green: &gValue, blue: &bValue, alpha: &aValue)
        
        let rgb: Int = (Int)(rValue*255)<<16 | (Int)(gValue*255)<<8 | (Int)(bValue*255)<<0
        
        return String(format: "#%06x", rgb)
    }
    
}
