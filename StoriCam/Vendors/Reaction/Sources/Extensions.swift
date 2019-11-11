/*
 * Reactions
 *
 * Copyright 2016-present Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

import Foundation
import UIKit

extension Sequence where Iterator.Element: Hashable {
    /// Returns uniq elements in the sequence by keeping the order.
    func uniq() -> [Iterator.Element] {
        var alreadySeen: [Iterator.Element: Bool] = [:]
        
        return filter { alreadySeen.updateValue(true, forKey: $0) == nil }
    }
}



extension String {
    
    func replacing(_ pattern: String, withTemplate: String) throws -> String {
        let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        return  regex.stringByReplacingMatches(in: self, options: [], range: NSRange(0..<self.utf16.count), withTemplate: withTemplate)
        
    }
}

extension UILabel {
    
    func setAtribText(str:String){
        
        let regex = try! NSRegularExpression(pattern: "::@([^\\s]+?)::", options: [])
        
        let result1 = try? str.replacing("::@([^\\s]+?)::", withTemplate: "@$1")
        
        print(result1!)
        
        let matches = regex.matches(in: str, options: [], range: NSRange(location: 0, length: str.count))
        print(matches)
        
        let atributedtext = NSMutableAttributedString(string:result1!)
        var count = 1
        
        for m in matches {
            print("start:")
            print(m.range.location - count + 1)
            print("end:")
            print(m.range.length - 4)
            let rang = NSMakeRange(m.range.location - count + 1, m.range.length - 4)
            atributedtext.setAttributes([NSAttributedString.Key.foregroundColor:ApplicationSettings.appPrimaryColor],range:rang)
            count = count + 4
            
        }
        self.attributedText = atributedtext
    }
    
}

extension NSObject {
    func checkStorageFull()->Bool{
        if DiskStatus.freeDiskSpaceInBytes <= 205 * 1024 * 1024 {
            return true
        }else{
            return false
        }
    }
    
}

extension UIViewController {
    
    var isModal: Bool {
        if self.presentingViewController != nil {
            return true
        } else if let presentedVC = self.navigationController?.presentingViewController?.presentedViewController,
            let navVC = self.navigationController,
            presentedVC == navVC  {
            return true
        } else if self.tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        return false
    }
    
}

extension Timer {
    class func schedule(delay: TimeInterval, handler:  ((Timer?) -> Void)!) -> Timer {
        let fireDate = delay + CFAbsoluteTimeGetCurrent()
        
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0, 0, 0, handler)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, CFRunLoopMode.commonModes)
        return timer!
    }
    
    class func schedule(repeatInterval interval: TimeInterval, handler:  ((Timer?) -> Void)!) -> Timer {
        let fireDate = interval + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, interval, 0, 0, handler)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, CFRunLoopMode.commonModes)
        return timer!
    }
}

extension Date {
    static func datePhraseRelativeToToday(from date: Date, islastSeen: Bool) -> String {
        
        // Don't use the current date/time. Use the end of the current day
        // (technically 0h00 the next day). Apple's calculation of
        // doesRelativeDateFormatting niavely depends on this start date.
        guard let todayEnd = dateEndOfToday() else {
            return ""
        }
        let calendar = Calendar.autoupdatingCurrent
        let units = Set([Calendar.Component.year,
                         Calendar.Component.month,
                         Calendar.Component.weekOfMonth,
                         Calendar.Component.day])
        let difference = calendar.dateComponents(units, from: date, to: todayEnd)
        guard let year = difference.year,
            let month = difference.month,
            let week = difference.weekOfMonth,
            let day = difference.day else {
                return ""
        }
        let timeAgo = NSLocalizedString("%@ ago", comment: "x days ago")
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale.autoupdatingCurrent
            formatter.dateStyle = .medium
            formatter.doesRelativeDateFormatting = true
            return formatter
        }()
        if year > 0 {
            // sample output: "Jan 23, 2014"
            return dateFormatter.string(from: date)
        } else if month > 0 {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .brief // sample output: "1mth"
            formatter.allowedUnits = .month
            guard let timePhrase = formatter.string(from: difference) else {
                return ""
            }
            if islastSeen == false {
                return dateFormatter.string(from: date)
            }
            return String(format: timeAgo, timePhrase)
        } else if week > 0 {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .brief // sample output: "2wks"
            formatter.allowedUnits = .weekOfMonth
            guard let timePhrase = formatter.string(from: difference) else {
                return ""
            }
            if islastSeen == false {
                return dateFormatter.string(from: date)
            }
            return String(format: timeAgo, timePhrase)
        } else if day > 1 {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .abbreviated // sample output: "3d"
            formatter.allowedUnits = .day
            guard let timePhrase = formatter.string(from: difference) else {
                return ""
            }
            if islastSeen == false {
                return dateFormatter.string(from: date)
            }
            return String(format: timeAgo, timePhrase)
        } else {
            // sample output: "Yesterday" or "Today"
            return dateFormatter.string(from: date)
        }
    }
    
    static func dateEndOfToday() -> Date? {
        let calendar = Calendar.autoupdatingCurrent
        let now = Date()
        let todayStart = calendar.startOfDay(for: now)
        var components = DateComponents()
        components.day = 1
        let todayEnd = calendar.date(byAdding: components, to: todayStart)
        return todayEnd
    }
}

