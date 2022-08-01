//
//  GrowingTextView.swift
//  Pods
//
//  Created by Kenneth Tsang on 17/2/2016.
//  Copyright (c) 2016 Kenneth Tsang. All rights reserved.
//
import Foundation
import UIKit

@objc public protocol GrowingTextViewDelegate: UITextViewDelegate {
    @objc optional func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat)
    @objc optional func textViewDidDelete(_ textView: GrowingTextView)
}

@IBDesignable open class GrowingTextView: UITextView {

    @IBInspectable open var leftMargin: CGFloat = 0 {
        didSet {
            if leftMargin > 0 {
                textContainerInset = UIEdgeInsets.init(top: 5, left: leftMargin, bottom: 5, right: leftMargin)
            }
        }
    }
    
    // Maximum length of text. 0 means no limit.
    @IBInspectable open var maxLength: Int = 0

    // Trim white space and newline characters when end editing. Default is true
    @IBInspectable open var trimWhiteSpaceWhenEndEditing: Bool = true

    // Minimum height of the textview
    @IBInspectable open var minHeight: CGFloat = CGFloat(0)

    // Maximm height of the textview
    @IBInspectable open var maxHeight: CGFloat = CGFloat(0)

    // Placeholder properties
    // Need to set both placeHolder and placeHolderColor in order to show placeHolder in the textview
    @IBInspectable open var placeHolder: NSString? {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable open var placeHolderColor: UIColor = UIColor(white: 0.8, alpha: 1.0) {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable open var placeHolderLeftMargin: CGFloat = 5 {
        didSet {
            setNeedsDisplay()
        }
    }

    override open var text: String! {
        didSet {
            setNeedsDisplay()
        }
    }

    fileprivate var heightConstraint: NSLayoutConstraint?

    // Initialize
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    open override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 30)
    }

    func associateConstraints() {
        // iterate through all text view's constraints and identify
        // height,from: https://github.com/legranddamien/MBAutoGrowingTextView
        for constraint in self.constraints {
            if constraint.firstAttribute == .height {
                if constraint.relation == .equal {
                    self.heightConstraint = constraint
                }
            }
        }
    }

    // Listen to UITextView notification to handle trimming, placeholder and maximum length
    fileprivate func commonInit() {
        self.contentMode = .redraw
        associateConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidEndEditing), name: UITextView.textDidEndEditingNotification, object: self)
    }

    // Remove notification observer when deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // Calculate height of textview
    private var oldText = ""
    private var oldWidth = CGFloat(0)
    
    override open func layoutSubviews() {
        super.layoutSubviews()

        if text == oldText && oldWidth == bounds.width {
            return
        }
        oldText = text
        oldWidth = bounds.width

        let size = sizeThatFits(CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude))
        var height = size.height

        // Constrain minimum height
        height = minHeight > 0 ? max(height, minHeight) : height

        // Constrain maximum height
        height = maxHeight > 0 ? min(height, maxHeight) : height

        self.frame.size.height = height

        if heightConstraint == nil {
            heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height)
            addConstraint(heightConstraint!)
        }

        if height != heightConstraint?.constant {
            self.heightConstraint!.constant = height
            scrollRangeToVisible(NSRange(location: 0, length: 0))
            if let delegate = delegate as? GrowingTextViewDelegate {
                delegate.textViewDidChangeHeight?(self, height: height)
            }
        }
    }
    
    func getHeight() -> CGFloat? {
        return self.frame.size.height + (textContainerInset.top + textContainerInset.bottom)
    }

    // Show placeholder
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        if text.isEmpty && attributedText.string.isEmpty {
            guard let placeHolder = placeHolder else { return }
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textAlignment

            var attributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.foregroundColor: placeHolderColor,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
            let height = (placeHolder as String).height(withConstrainedWidth: (frame.size.width - textContainerInset.left - textContainerInset.right), font: self.font!)

            let rect = CGRect(x: textContainerInset.left + placeHolderLeftMargin,
                              y: textContainerInset.top,
                              width: frame.size.width - textContainerInset.left - textContainerInset.right,
                              height: max(height, frame.size.height))

            if let font = font {
                attributes[NSAttributedString.Key.font] = font
            }

            placeHolder.draw(in: rect, withAttributes: attributes)
            self.heightConstraint!.constant = (height + textContainerInset.top + textContainerInset.bottom)
        }
    }

    // Trim white space and new line characters when end editing.
    @objc func textDidEndEditing(notification: Notification) {
        if let notificationObject = notification.object as? GrowingTextView {
            if notificationObject === self {
                if trimWhiteSpaceWhenEndEditing {
                    text = text?.trimmingCharacters(in: .whitespacesAndNewlines)
                    setNeedsDisplay()
                }
            }
        }
    }

    // Limit the length of text
    @objc func textDidChange(notification: Notification) {
        if let notificationObject = notification.object as? GrowingTextView {
            if notificationObject === self {
                if maxLength > 0 && text.count > maxLength {
                    let endIndex = text.index(text.startIndex, offsetBy: maxLength)
                    text = text.substring(to: endIndex)
                    undoManager?.removeAllActions()
                }
                setNeedsDisplay()
            }
        }
    }

    override open func deleteBackward() {
        super.deleteBackward()
        if let deleteH = (delegate as? GrowingTextViewDelegate)?.textViewDidDelete {
            deleteH(self)
        }
    }
}
