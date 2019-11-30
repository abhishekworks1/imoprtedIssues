//
//  DrawTextEditView.swift
//  DrawKit
//
//  Created by Viraj Patel on 19/03/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

internal protocol DrawTextEditViewDelegate: class {
    /// Called whenever the DrawTextEditView ends text editing (keyboard entry) mode.
    ///
    /// - Parameter text: The new text string after editing
    func DrawTextEditViewFinishedEditing(withText text: String?)
    
    func DrawTextEditViewWillEditing(withText text: String?)
}

internal class DrawTextEditView: UIView {
    
    /// The delegate of the DrawTextEditView, which receives an update when the DrawTextEditView is finished editing text, with the revised `text`.
    weak var delegate: DrawTextEditViewDelegate?
    
    /// Whether or not the DrawTextEditView is actively in edit mode. This property controls whether or not the keyboard is displayed and the DrawTextEditView is visible.
    ///
    /// - Note: Set the DrawViewController state to DrawViewStateEditingText to turn on editing mode in DrawTextEditView.
    var isEditing = false {
        didSet { updateIsEditing(isEditing) }
    }
    
    /// The text string the DrawTextEditView is currently displaying.
    ///
    /// - Note: Set textString in DrawViewController to control or read this property.
    var textString: String {
        set { textView.text = newValue }
        get { return textView.text }
    }
    
    /// The color of the text displayed in the DrawTextEditView.
    ///
    /// - Note: Set textColor in DrawViewController to control this property.
    var textColor: UIColor = ApplicationSettings.appWhiteColor {
        didSet { updateTextColor(textColor) }
    }
    
    /// The font of the text displayed in the DrawTextEditView.
    ///
    /// - Note: Set font in DrawViewController to control this property.
    var font = UIFont.durationBookRegular ?? UIFont.systemFont(ofSize: 90) {
        didSet { updateFont(font) }
    }
    
    /// The alignment of the text displayed in the DrawTextEditView.
    ///
    /// - Note: Set textAlignment in DrawViewController to control this property.
    var textAlignment: NSTextAlignment {
        get { return textView.textAlignment }
        set { textView.textAlignment = newValue }
    }
    
    /// The view insets of the text displayed in the DrawTextEditView.
    ///
    /// - Note: Set textEditingInsets in DrawViewController to control this property.
    var textEditingInsets: UIEdgeInsets = .zero {
        didSet { updateTextEditingInsets(textEditingInsets) }
    }
    
    lazy var textView: ReSizeFontTextView = {
        let txtView = ReSizeFontTextView(frame: CGRect.zero)
        txtView.font = self.font
        txtView.placeHolder = "Type Something..."
        txtView.isScrollEnabled = true
        txtView.textAlignment = .center
        txtView.backgroundColor = ApplicationSettings.appClearColor
        txtView.isResizableFont = false
        
        txtView.keyboardType = .default
        txtView.returnKeyType = .done
        txtView.textContainer.maximumNumberOfLines = 0
        txtView.clipsToBounds = false
        txtView.delegate = self
        txtView.translatesAutoresizingMaskIntoConstraints = false
        return txtView
    }()
    
    fileprivate let textContainer: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate var textContainerBottomConstraint: NSLayoutConstraint?
    fileprivate var textViewLayoutConstraints: [NSLayoutConstraint]?
    
    var fontState: FontViewState = .default
    
    // MARK: - Init
    
    private func commonInit() {
        self.backgroundColor = ApplicationSettings.appClearColor
        self.isUserInteractionEnabled = false
        textContainer.isHidden = true
        
        // Add subviews.
        self.addSubview(textContainer)
        textContainer.pinEdgesToSuperview(edges: [.left, .right])
        
        textContainer.pinTopToViewsTop(self, padding: UIApplication.shared.windows[0].safeAreaInsets.top + 60)
        textContainerBottomConstraint = textContainer.pinBottomToSuperview(100, priority: UILayoutPriority.init(750))
        
        textContainer.addSubview(textView)
        updateTextEditingInsets(.zero)
        
        // Add notification listeners.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardFrameDidChange(notification:)),
            name: UIResponder.keyboardDidChangeFrameNotification,
            object: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    deinit {
        delegate = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    // Notification handling
    
    func updateUI() {
        setNeedsDisplay()
        if self.textView.isResizableFont {
            self.textView.updateTextFont()
        }
        
        self.textView.attributedStringSet(underline: fontState == .default ? false : false)
        delegate?.DrawTextEditViewWillEditing(withText: self.textView.text)
        if !self.textView.text.isEmpty {
            self.textView.placeHolder = nil
        } else {
            self.textView.placeHolder = "Type Something..."
        }
    }
    
    @objc func keyboardFrameDidChange(notification: Notification) {
        textContainer.layer.removeAllAnimations()
        let keyboardRectEnd = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        textContainerBottomConstraint?.constant = -keyboardRectEnd.height - 76
        UIView.animate(withDuration: 0, animations: {
            self.updateUI()
        }) { (_) in
            
        }
    }
    
    // Property updates
    
    func clearText() {
        textString = ""
        textView.text = ""
        textView.placeHolder = "Type Something..."
    }
    
    func updateText(_ text: String?) {
        textView.text = text
    }
    
    fileprivate func updateTextEditingInsets(_ inset: UIEdgeInsets) {
        if let textViewLayoutConstraints = textViewLayoutConstraints {
            for constraint in textViewLayoutConstraints {
                textView.removeConstraint(constraint)
            }
        }
        textView.pinEdgesToSuperview(edges: [.left, .right])
        textViewLayoutConstraints = textView.pinEdgesToSuperview(edges: [.all], padding: inset)
        textView.layoutIfNeeded()
    }
    
    func updateFont(_ font: UIFont) {
        textView.font = font
    }
    
    func updateTextColor(_ color: UIColor) {
        textView.textColor = color
    }
    
    func updateIsEditing(_ isEditing: Bool) {
        textContainer.isHidden = !isEditing
        self.isUserInteractionEnabled = isEditing
        if isEditing {
            textView.becomeFirstResponder()
            textView.layoutIfNeeded()
        } else {
            self.backgroundColor = ApplicationSettings.appClearColor
            textView.resignFirstResponder()
            delegate?.DrawTextEditViewFinishedEditing(withText: textString)
        }
    }
}

// MARK: - UITextViewDelegate

extension DrawTextEditView: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        setNeedsDisplay()
        if self.textView.isResizableFont {
            self.textView.updateTextFont()
        }
        
        self.textView.attributedStringSet(underline: fontState == .default ? false : false)
        delegate?.DrawTextEditViewWillEditing(withText: self.textView.text)
        if !self.textView.text.isEmpty {
            self.textView.placeHolder = nil
        } else {
            self.textView.placeHolder = "Type Something..."
        }
    }
    
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
