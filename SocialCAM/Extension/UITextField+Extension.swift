//
//  UITextField+Extension.swift
//  ProManager
//
//  Created by Viraj Patel on 17/09/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
    
    func resolveHashTags() {
        let nsText = NSString(string: self.text)
        let words = nsText.components(separatedBy: CharacterSet(charactersIn: "#ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_").inverted)
        let attrString = NSMutableAttributedString()
        attrString.setAttributedString(self.attributedText)
        
        for word in words {
            if word.count < 3 {
                continue
            }
            
            if word.hasPrefix("#") {
                let matchRange: NSRange = nsText.range(of: word as String)
                let stringifiedWord = word.dropFirst()
                if let firstChar = stringifiedWord.unicodeScalars.first, NSCharacterSet.decimalDigits.contains(firstChar) {
                } else {
                    attrString.addAttribute(NSAttributedString.Key.link,
                                            value: "hash:\(stringifiedWord)",
                        range: matchRange)
                }
            }
        }
        self.attributedText = attrString
    }
    
    var isLastPoint: Bool {
        guard !text.isEmpty,
            let textStorage = layoutManager.textStorage else {
                return false
        }
        let charIndex = textStorage.length - 1
        let glyphIndex = layoutManager.glyphIndexForCharacter(at: charIndex)
        let lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: nil)
        var glyphLoc = layoutManager.location(forGlyphAt: glyphIndex)
        glyphLoc.x += lineRect.minX
        glyphLoc.y += lineRect.minY
        if glyphLoc.x >= (bounds.width - (16 + 10)) && textStorage.size().width > bounds.width {
            return true
        }
        return false
    }
}

extension UITextView {
    
    func makeOutLine(oulineColor: UIColor, foregroundColor: UIColor) {
        let strokeTextAttributes = [
            NSAttributedString.Key.strokeColor as NSString: oulineColor,
            NSAttributedString.Key.foregroundColor: foregroundColor,
            NSAttributedString.Key.strokeWidth: -4.0,
            NSAttributedString.Key.font: self.font as Any
            ] as! [NSAttributedString.Key: Any]
        self.attributedText = NSMutableAttributedString(string: self.text ?? "", attributes: strokeTextAttributes as [NSAttributedString.Key: Any])
    }
    
    func attributedStringSet(underline: Bool = false) {
        if let textString = self.text {
            let style = NSMutableParagraphStyle()
            style.alignment = NSTextAlignment.center
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: self.textColor!, range: NSRange(location: 0, length: attributedString.length))
            attributedString.addAttribute(NSAttributedString.Key.font, value: self.font!, range: NSRange(location: 0, length: attributedString.length))
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: attributedString.length))
            if underline {
                attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
            }
            attributedText = attributedString
        }
    }
    
}

extension UITextField {
    
    func applyGradientWith(startColor: UIColor, middleColor: UIColor? = nil, endColor: UIColor) {
        guard let gradientColor = self.text?.getGradientColorFor(startColor: startColor, middleColor: middleColor, endColor: endColor, font: self.font ?? UIFont.systemFont(ofSize: 25)) else {
            return
        }
        self.textColor = gradientColor
    }
    
    func applyGradientPlaceholderWith(startColor: UIColor, middleColor: UIColor? = nil, endColor: UIColor) {
        guard let gradientColor = self.placeholder?.getGradientColorFor(startColor: startColor, middleColor: middleColor, endColor: endColor, font: self.font ?? UIFont.systemFont(ofSize: 25)) else {
            return
        }
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "",
                                                        attributes: [NSAttributedString.Key.foregroundColor: gradientColor.withAlphaComponent(0.4)])
    }
}
