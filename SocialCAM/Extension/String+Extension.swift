//
//  StringExtension.swift
//  ProManager
//
//  Created by Viraj Patel on 16/09/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

extension Dictionary {
    var json: String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? nil
        } catch {
            return nil
        }
    }
    
    func dict2json() -> String? {
        return json
    }
}

extension String {
  
    var lastPathComponent: String {
        get {
            return (self as NSString).lastPathComponent
        }
    }
    
    var stringByDeletingPathExtension: String {
        get {
            return (self as NSString).deletingPathExtension
        }
    }
    
    func toMIMETypeFromExt() -> String? {
        let ext = self.replacingOccurrences(of: ".", with: "").lowercased()
        if let audio = toAudioMIMEType(ext) {
            return audio
        }
        if let image = toImageMIMEType(ext) {
            return image
        }
        if let video = toVideoMIMEType(ext) {
            return video
        }
        return nil
    }
    
    private func toAudioMIMEType(_ ext: String) -> String? {
        switch ext {
        case "au":
            return "audio/basic"
        case "snd":
            return "audio/basic"
        case "mid":
            return "audio/mid"
        case "rmi":
            return "audio/mid"
        case "mp3":
            return "audio/mpeg"
        case "aif":
            return "audio/x-aiff"
        case "aifc":
            return "audio/x-aiff"
        case "aiff":
            return "audio/x-aiff"
        case "m3u":
            return "audio/x-mpegurl"
        case "ra":
            return "audio/x-pn-realaudio"
        case "ram":
            return "audio/x-pn-realaudio"
        case "wav":
            return "audio/x-wav"
        default:
            return nil
        }
    }
    
    private func toImageMIMEType(_ ext: String) -> String? {
        switch ext {
        case "bmp":
            return "image/bmp"
        case "cod":
            return "image/cis-cod"
        case "gif":
            return "image/gif"
        case "ief":
            return "image/ief"
        case "jpe":
            return "image/jpeg"
        case "jpeg":
            return "image/jpeg"
        case "jpg":
            return "image/jpeg"
        case "jfif":
            return "image/pipeg"
        case "svg":
            return "image/svg+xml"
        case "tif":
            return "image/tiff"
        case "tiff":
            return "image/tiff"
        case "ras":
            return "image/x-cmu-raster"
        case "cmx":
            return "image/x-cmx"
        case "ico":
            return "image/x-icon"
        case "pnm":
            return "image/x-portable-anymap"
        case "pbm":
            return "image/x-portable-bitmap"
        case "pgm":
            return "image/x-portable-graymap"
        case "ppm":
            return "image/x-portable-pixmap"
        case "rgb":
            return "image/x-rgb"
        case "xbm":
            return "image/x-xbitmap"
        case "xpm":
            return "image/x-xpixmap"
        case "xwd":
            return "image/x-xwindowdump"
        default:
            return nil
        }
    }
    
    private func toVideoMIMEType(_ ext: String) -> String? {
        switch ext {
        case "mp2":
            return "video/mpeg"
        case "mpa":
            return "video/mpeg"
        case "mpe":
            return "video/mpeg"
        case "mpeg":
            return "video/mpeg"
        case "mpg":
            return "video/mpeg"
        case "mpv2":
            return "video/mpeg"
        case "mp4":
            return "video/mp4"
        case "mov":
            return "video/quicktime"
        case "qt":
            return "video/quicktime"
        case "lsf":
            return "video/x-la-asf"
        case "lsx":
            return "video/x-la-asf"
        case "asf":
            return "video/x-ms-asf"
        case "asr":
            return "video/x-ms-asf"
        case "asx":
            return "video/x-ms-asf"
        case "avi":
            return "video/x-msvideo"
        case "movie":
            return "video/x-sgi-movie"
        default:
            return nil
        }
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    var hexToData: Data? {
        var hex = self
        var data = Data()
        while(!hex.isEmpty) {
            if let subIndex = hex.index(hex.startIndex, offsetBy: 2, limitedBy: hex.endIndex) {
                let newChar = String(hex[..<subIndex])
                hex = String(hex[subIndex...])
                var ch: UInt32 = 0
                Scanner(string: newChar).scanHexInt32(&ch)
                var char = UInt8(ch)
                data.append(&char, count: 1)
            }
        }
        return data
    }
    
    var pathComponents: [String] {
        return components(separatedBy: "/")
    }
    
    func image(newSize: CGSize = CGSize(width: 18, height: 18)) -> UIImage? {
        let size = newSize
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func lastCharAtLocation(range: NSRange) -> String? {
        let lastString = (self as NSString).substring(to: range.location)
        if let ch = lastString.last {
            let chSTr = String.init(describing: ch)
            return chSTr
        }
        return nil
    }
    
    func trimStr() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func trimString() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func image() -> UIImage? {
        let size = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    var floatValue: Float {
        return (self as NSString).floatValue
    }
    
    var json: [String: Any]? {
        do {
            let jsonData = self.data(using: .utf8)
            let dictionary = try JSONSerialization.jsonObject(with: jsonData!, options: [])
            return dictionary as? [String: Any] ?? [:]
        } catch {
            return nil
        }
    }
    
    func json2dict() -> [String: Any]? {
        return json
    }
    
    public func isImageType() -> Bool {
        // image formats which you want to check
        let imageFormats = ["jpg", "png", "gif"]
        
        if URL(string: self) != nil {
            
            let extensi = (self as NSString).pathExtension
            
            return imageFormats.contains(extensi)
        }
        return false
    }
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox.height
    }
    
    func alertAction(style: UIAlertAction.Style = .default, handler: AlertActionHandler? = nil) -> UIAlertAction {
        return UIAlertAction(title: self, style: style, handler: handler)
    }
    
    func utcDateFromString() -> Date {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormat.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormat.date(from: self) ?? Date()
    }
    func isoDateFromString() -> Date {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormat.calendar = Calendar(identifier: .iso8601)
        dateFormat.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormat.date(from: self) ?? Date()
    }
    func fromUTCToLocalDateTime() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = R.string.localizable.yyyyMMDdTHHMmSsSSSZ()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        var formattedString = self.replacingOccurrences(of: "Z", with: "")
        if let lowerBound = formattedString.range(of: ".")?.lowerBound {
            formattedString = "\(formattedString[..<lowerBound])"
        }

        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.date(from: self) ?? Date()
    }
    
    subscript (indexChar: Int) -> Character {
        return self[index(startIndex, offsetBy: indexChar)]
    }
    
    subscript (indexChar: Int) -> String {
        return String(self[indexChar] as Character)
    }
    
    var youTubeId: String? {
        get {
            let pattern =  "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
            let regex: NSRegularExpression? = try? NSRegularExpression.init(pattern: pattern, options: .caseInsensitive)
            let matchs: NSTextCheckingResult? = regex?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count))
            if let match = matchs {
                let vRange = match.range
                let substringForFirstMatch = (self as NSString).substring(with: vRange)
                return substringForFirstMatch
            } else {
                return nil
            }
        }
    }
    
    static func random(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
    
    static var fileName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "yyyyMMddHHmmssSSS"
        return dateFormatter.string(from: Date())
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func getGradientColorFor(startColor: UIColor, middleColor: UIColor? = UIColor.yellow, endColor: UIColor, font: UIFont) -> UIColor? {
        
        var startColorRed: CGFloat = 0
        var startColorGreen: CGFloat = 0
        var startColorBlue: CGFloat = 0
        var startAlpha: CGFloat = 0
        
        if !startColor.getRed(&startColorRed, green: &startColorGreen, blue: &startColorBlue, alpha: &startAlpha) {
            return nil
        }
        
        var middeleColorRed: CGFloat = 0
        var middeleColorGreen: CGFloat = 0
        var middeleColorBlue: CGFloat = 0
        var middeleColorAlpha: CGFloat = 0
        
        if let cMiddleColor = middleColor {
            if !cMiddleColor.getRed(&middeleColorRed, green: &middeleColorGreen, blue: &middeleColorBlue, alpha: &middeleColorAlpha) {
                return nil
            }
        }
        
        var endColorRed: CGFloat = 0
        var endColorGreen: CGFloat = 0
        var endColorBlue: CGFloat = 0
        var endAlpha: CGFloat = 0
        
        if !endColor.getRed(&endColorRed, green: &endColorGreen, blue: &endColorBlue, alpha: &endAlpha) {
            return nil
        }
        
        let gradientText = self
        
        let name = NSAttributedString.Key.font
        let textSize = gradientText.size(withAttributes: [name: font])
        let width = textSize.width
        let height = textSize.height
        
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        UIGraphicsPushContext(context)
        
        var numLocations: size_t = 2
        var locations: [CGFloat] = [0.0, 1.0]
        var components: [CGFloat] = [startColorRed, startColorGreen, startColorBlue, startAlpha, endColorRed, endColorGreen, endColorBlue, endAlpha]
        if middleColor != nil {
            numLocations = 3
            locations = [0.0, 0.5, 1.0]
            components = [startColorRed, startColorGreen, startColorBlue, startAlpha, endColorRed, endColorGreen, endColorBlue, endAlpha, middeleColorRed, middeleColorGreen, middeleColorBlue, middeleColorAlpha]
        }
        let rgbColorspace = CGColorSpaceCreateDeviceRGB()
        let glossGradient = CGGradient(colorSpace: rgbColorspace, colorComponents: components, locations: locations, count: numLocations)
        let topCenter = CGPoint.zero
        let bottomCenter = CGPoint(x: textSize.width, y: 0)
        context.drawLinearGradient(glossGradient!, start: topCenter, end: bottomCenter, options: CGGradientDrawingOptions.drawsBeforeStartLocation)
        
        UIGraphicsPopContext()
        
        guard let gradientImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        UIGraphicsEndImageContext()
        
        return UIColor(patternImage: gradientImage)
    }
    
}
