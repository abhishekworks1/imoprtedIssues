//
//  StringExtension.swift
//  SwiftLinkPreview
//
//  Created by Leonardo Cardoso on 09/06/2016.
//  Copyright © 2016 leocardz.com. All rights reserved.
//
import Foundation

#if os(iOS) || os(watchOS) || os(tvOS)

import UIKit

#elseif os(OSX)

import Cocoa

#endif

extension String {
    
    // Trim
    var trim: String {
        
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
    }
    
    // Remove extra white spaces
    var extendedTrim: String {
        
        let components = self.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ").trim
        
    }
    
    // Decode HTML entities
    var decoded: String {
        
        let encodedData = self.data(using: String.Encoding.utf8)!
        let attributedOptions: [NSAttributedString.DocumentReadingOptionKey: Any] =
            [
                NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html as AnyObject,
                NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue as AnyObject
        ]
        
        do {
            
            let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
            
            return attributedString.string
            
        } catch _ {
            
            return self
            
        }
        
    }
    
    // Strip tags
    var tagsStripped: String {
        
        return self.deleteTagByPattern(Regex.rawTagPattern)
        
    }
    
    // Delete tab by pattern
    func deleteTagByPattern(_ pattern: String) -> String {
        
        return self.replacingOccurrences(of: pattern, with: "", options: .regularExpression, range: nil)
        
    }
    
    // Replace
    func replace(_ search: String, with: String) -> String {
        
        let replaced: String = self.replacingOccurrences(of: search, with: with)
        
        return replaced.isEmpty ? self : replaced
        
    }
    
    // Substring
    func substring(_ start: Int, end: Int) -> String {
        if end > start {
            return self.substring(with: (self.index(self.startIndex, offsetBy: start) ..< self.index(self.startIndex, offsetBy: end)))
        }
        return ""
        
    }
    func substring(_ range: NSRange) -> String {
        let str = (self as NSString).substring(with: range)
        return str
    }
    
    // Check if it's a valid url
    func isValidURL() -> Bool {
        
        return Regex.test(self, regex: Regex.rawUrlPattern)
        
    }
    
    // Check if url is an image
    func isImage() -> Bool {
        
        return Regex.test(self, regex: Regex.imagePattern)
        
    }
    
}
//Encoding-Decoding
extension String {

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
