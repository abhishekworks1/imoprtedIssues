//
//  Date.swift
//  ProManager
//
//  Created by Viraj Patel on 17/09/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    
    func dateString(_ format: String = "MMM-dd-YYYY, hh:mm a") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func dateByAddingYears(_ dYears: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = dYears
        return Calendar.current.date(byAdding: dateComponents, to: self)!
    }
    
    static func dateComponentFrom(second: Double) -> DateComponents {
        let interval = TimeInterval(second)
        let date1 = Date()
        let date2 = Date(timeInterval: interval, since: date1)
        let calendar = Calendar.current
        
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday], from: date1, to: date2)
        components.calendar = calendar
        return components
    }
    
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
    
    func asString(style: DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = style
        dateFormatter.timeStyle = style
        return dateFormatter.string(from: self)
    }
    
    func timeAgoSinceDate(numericDates: Bool) -> String {
        let calendar = Calendar.current
        let now = Date()
        let earliest = (now as NSDate).earlierDate(self)
        let latest = (earliest == now) ? self : now
        let components: DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute, NSCalendar.Unit.hour, NSCalendar.Unit.day, NSCalendar.Unit.weekOfYear, NSCalendar.Unit.month, NSCalendar.Unit.year, NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
        
        if components.year! >= 2 {
            if numericDates {
                return "\(components.year!)y"
            } else {
                return "\(components.year!) years ago"
            }
            
        } else if components.year! >= 1 {
            if numericDates {
                return "1y"
            } else {
                return "Last year"
            }
        } else if components.month! >= 2 {
            if numericDates {
                return "\(components.month!)mo"
            } else {
                return "\(components.month!) months ago"
            }
        } else if components.month! >= 1 {
            if numericDates {
                return "1mo"
            } else {
                return "Last month"
            }
        } else if components.weekOfYear! >= 2 {
            if numericDates {
                return "\(components.weekOfYear!)w"
            } else {
                return "\(components.weekOfYear!) weeks ago"
            }
        } else if components.weekOfYear! >= 1 {
            if numericDates {
                return "1w"
            } else {
                return "Last week"
            }
        } else if components.day! >= 2 {
            if numericDates {
                return "\(components.day!)d"
            } else {
                return "\(components.day!) days ago"
            }
        } else if components.day! >= 1 {
            if numericDates {
                return "1d"
            } else {
                return "Yesterday"
            }
        } else if components.hour! >= 2 {
            if numericDates {
                return "\(components.hour!)h"
            } else {
                return "\(components.hour!) hours ago"
            }
        } else if components.hour! >= 1 {
            if numericDates {
                return "1h"
            } else {
                return "1 hour ago"
            }
        } else if components.minute! >= 2 {
            if (numericDates) {
                return "\(components.minute!)m"
            } else {
                return "\(components.minute!) minutes ago"
            }
        } else if components.minute! >= 1 {
            if numericDates {
                return "1m"
            } else {
                return "1 minute ago"
            }
        } else if components.second! >= 3 {
            if numericDates {
                return "\(components.second!)s"
            } else {
                return "\(components.second!) second ago"
            }
        } else {
            if numericDates {
                return "1s"
            } else {
                return "Just now"
            }
        }
    }
    
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    
}
