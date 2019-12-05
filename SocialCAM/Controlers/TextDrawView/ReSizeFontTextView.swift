//
//  ReSizeFontTextView.swift
//  DrawKit
//
//  Created by Viraj Patel on 22/03/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

class ReSizeFontTextView: UITextView {
    
    var placeHolder: String? = R.string.localizable.typeSomething() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var placeholderColor: UIColor = ApplicationSettings.appWhiteColor {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var isResizableFont = false
    
    func setTextViewWith(_ text: String) {
        self.text = text
        setNeedsDisplay()
        if isResizableFont {
            updateTextFont()
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
//        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: self)
        //self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func textDidChange(notification: Notification) {
        setNeedsDisplay()
        if isResizableFont {
            updateTextFont()
        }
    }
    
    func updateTextFont() {
        guard !text.isEmpty,
            bounds.size != CGSize.zero,
            self.font != nil else {
                return
        }
        
        let textViewSize = frame.size
        let fixedWidth = textViewSize.width
        let expectSize = sizeThatFits(CGSize(width: fixedWidth,
                                             height: CGFloat(MAXFLOAT)))
        
        var expectFont = font
        if expectSize.height > textViewSize.height {
            while font!.pointSize > 22.0 && sizeThatFits(CGSize.init(width: fixedWidth, height: CGFloat(MAXFLOAT))).height > textViewSize.height {
                expectFont = font!.withSize(font!.pointSize - 1)
                self.font = expectFont
            }
        } else {
            while sizeThatFits(CGSize.init(width: fixedWidth, height: CGFloat(MAXFLOAT))).height < (textViewSize.height / 2) {
                expectFont = font
                self.font = font!.withSize(font!.pointSize + 1)
            }
            self.font = expectFont
        }
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        if text.isEmpty && attributedText.string.isEmpty {
            guard let placeHolder = placeHolder else { return }
            
            let height = (placeHolder as String).height(withConstrainedWidth: (frame.size.width - textContainerInset.left - textContainerInset.right), font: self.font!)
            
            let rect = CGRect(x: textContainerInset.left,
                              y: textContainerInset.top,
                              width: frame.size.width - textContainerInset.left - textContainerInset.right,
                              height: max(height, frame.size.height))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textAlignment
            
            var attributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.foregroundColor: placeholderColor,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
            
            if let font = font {
                attributes[NSAttributedString.Key.font] = font
            }
            
            (placeHolder as NSString).draw(in: rect, withAttributes: attributes)
        }
    }
    
}

extension ReSizeFontTextView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let char = text.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        if !(isBackSpace == -92),
            textView.textContainer.maximumNumberOfLines == textView.layoutManager.numberOfLines {
            if text == "\n" {
                return false
            }
            return !textView.isLastPoint
        }
        return true
    }
    
}
