//
//  StorySliderQueView.swift
//  Story_Hashtags
//
//  Created by Jasmin Patel on 17/12/18.
//  Copyright © 2018 Simform. All rights reserved.
//

import Foundation
import UIKit



class StoryQueTextView: UITextView {
    
    var placeHolder: String? = "Ask A Question..." {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var placeholderColor: UIColor = R.color.quetag_Ice() ?? ApplicationSettings.appLightGrayColor {
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
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: self)
        self.delegate = self
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
            while sizeThatFits(CGSize.init(width: fixedWidth, height: CGFloat(MAXFLOAT))).height < textViewSize.height {
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
            
            var attributes: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.foregroundColor : placeholderColor,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
            
            if let font = font {
                attributes[NSAttributedString.Key.font] = font
            }
            
            (placeHolder as NSString).draw(in: rect, withAttributes: attributes)
        }
    }
    
}

extension StoryQueTextView: UITextViewDelegate {
    
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

@IBDesignable
class IBStoryQueSlider: UISlider {
    
    private enum SliderTrack {
        case minimum
        case maximum
    }
    
    @IBInspectable
    var sliderStartPosition: CGFloat = 20 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var sliderHeight: CGFloat = 10 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var emojiText: String = "😍" {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var minFillColor: UIColor = UIColor.blue {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var maxFillColor: UIColor = ApplicationSettings.appLightGrayColor {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.setMinimumTrackImage(imageForRect(rect: rect, side: .minimum), for: .normal)
        self.setMaximumTrackImage(imageForRect(rect: rect, side: .maximum), for: .normal)
        
        self.setThumbImage(self.imageFor(emojiText), for: .normal)
        self.setThumbImage(self.imageFor(emojiText), for: .highlighted)
    }
    
    private func imageFor(_ text: String) -> UIImage {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 35)
        label.text = text
        label.sizeToFit()
        return label.getImage()
    }
    
    private func imageForRect(rect: CGRect, side: SliderTrack) -> UIImage? {
        // We create an innerRect in which we draw the lines
        let innerRect = rect.insetBy(dx: 1.0, dy: 10.0)
        
        UIGraphicsBeginImageContextWithOptions(innerRect.size, false, 0);
        
        let path = UIBezierPath(roundedRect: CGRect(x: sliderStartPosition, y: (innerRect.height/2) - 3, width: innerRect.width - 40, height: sliderHeight), byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 40, height: 40))
        
        switch side {
        case .minimum:
            minFillColor.setFill()
            path.fill()
        case .maximum:
            maxFillColor.setFill()
            path.fill()
        }
        
        let selectedSide = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero)
        
        UIGraphicsEndImageContext()
        
        return selectedSide
    }
    
}

class StoryQueSlider: UISlider {
    
    var minFillColor = R.color.quetag_darkSkyBlue() ?? UIColor.blue
    
    var maxFillColor = R.color.quetag_lightLavender() ?? ApplicationSettings.appLightGrayColor
    
    var emojiText: String = "😍" {
        didSet {
            updateEmoji()
        }
    }
    
    private enum SliderTrack {
        case minimum
        case maximum
    }
    
    private struct Ratios {
        static let startPosition: CGFloat = 20
        static let bezierHeight: CGFloat = 6
        static let circle: CGFloat = 6
    }
    
    lazy var emojiView: UIImageView = {
        let view = UIImageView.init(image: self.imageFor(self.emojiText))
        view.sizeToFit()
        view.isHidden = true
        return view
    }()
    
    lazy var answerThumb: UIView = {
        let view = UIView()
        view.backgroundColor = ApplicationSettings.appWhiteColor
        view.layer.cornerRadius = 10
        view.layer.borderColor = self.minFillColor.cgColor
        view.layer.borderWidth = 2.0
        view.isUserInteractionEnabled = false
        view.frame.size = CGSize(width: 20, height: 20)
        return view
    }()
    
    var beginTracking: (() -> Swift.Void)? = nil
    
    var endTracking: ((Float) -> Swift.Void)? = nil
    
    private func imageFor(_ text: String) -> UIImage {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 35)
        label.text = text
        label.sizeToFit()
        return label.getImage()
    } 
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(valueChanged(_:)), for: UIControl.Event.valueChanged)
        addSubview(emojiView)
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        scaleEmojiView()
        emojiView.isHidden = false
        beginTracking?()
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        emojiView.isHidden = true
        endTracking?(value)
    }
    
    @objc func valueChanged(_ sender: UISlider) {
        scaleEmojiView()
    }
    
    func scaleEmojiView() {
        let trackRect = self.trackRect(forBounds: bounds)
        var thumbRect = self.thumbRect(forBounds: bounds, trackRect: trackRect, value: value)
        var scaleValue = CGFloat(value)*2
        scaleValue = scaleValue + 1.0
        thumbRect.origin.x = thumbRect.origin.x + 20
        thumbRect.origin.y = thumbRect.origin.y - 20*scaleValue
        emojiView.center = thumbRect.origin
        emojiView.transform = CGAffineTransform(scaleX: scaleValue,
                                                y: scaleValue)
    }
    
    func addAnswerThumb(value: Float) {
        answerThumb.removeFromSuperview()
        insertSubview(answerThumb, belowSubview: self.subviews.last!)
//        addSubview(answerThumb)
        var trackRect = self.trackRect(forBounds: bounds)
        trackRect.size.width = trackRect.width - 20
        trackRect.origin.x = trackRect.origin.x + 20
        let thumbRect = self.thumbRect(forBounds: bounds, trackRect: trackRect, value: value)
        answerThumb.frame.origin = CGPoint(x: thumbRect.origin.x,
                                           y: 11)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.setMinimumTrackImage(imageForRect(rect: rect, side: .minimum), for: .normal)
        self.setMaximumTrackImage(imageForRect(rect: rect, side: .maximum), for: .normal)
        
        self.setThumbImage(self.imageFor(emojiText), for: .normal)
        self.setThumbImage(self.imageFor(emojiText), for: .highlighted)
    }
    
    func updateEmoji() {
        self.setThumbImage(self.imageFor(emojiText), for: .normal)
        self.setThumbImage(self.imageFor(emojiText), for: .highlighted)
        emojiView.image = self.imageFor(emojiText)
        layoutIfNeeded()
    }
    
    private func imageForRect(rect: CGRect, side: SliderTrack) -> UIImage? {
        // We create an innerRect in which we draw the lines
        let innerRect = rect.insetBy(dx: 1.0, dy: 10.0)
        
        UIGraphicsBeginImageContextWithOptions(innerRect.size, false, 0);
        
        let path = UIBezierPath(roundedRect: CGRect(x: Ratios.startPosition, y: (innerRect.height/2) - 3, width: innerRect.width - 40, height: Ratios.bezierHeight), byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 40, height: 40))
        
        switch side {
        case .minimum:
            minFillColor.setFill()
            path.fill()
        case .maximum:
            maxFillColor.setFill()
            path.fill()
        }
        
        let selectedSide = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero)
        
        UIGraphicsEndImageContext()
        
        return selectedSide
    }
    
}

class StorySliderQueView: BaseQuestionTagView {
    
    var startColor: UIColor = R.color.quetag_darkSkyBlue() ?? UIColor.blue
    
    var endColor: UIColor = R.color.quetag_darkSkyBlue() ?? UIColor.blue
    
    lazy var textView: StoryQueTextView = {
        let txtView = StoryQueTextView(frame: CGRect.zero)
        txtView.font = UIFont.systemFont(ofSize: 26)
        txtView.textColor = R.color.quetag_darkSkyBlue() ?? UIColor.blue
        txtView.isScrollEnabled = false
        txtView.textAlignment = .center
        txtView.backgroundColor = ApplicationSettings.appClearColor
        txtView.textContainer.maximumNumberOfLines = 10
        txtView.autocorrectionType = .no
        return txtView
    }()
    
    lazy var slider: StoryQueSlider = {
        return StoryQueSlider()
    }()
    
    var questionText: String {
        get { return textView.text }
        set {
            textView.text = newValue
            textView.setNeedsDisplay()
            layoutIfNeeded()
        }
    }
    
    var sliderValue: Float {
        get { return slider.value }
        set {
            slider.value = newValue
            slider.setNeedsDisplay()
            layoutIfNeeded()
            slider.scaleEmojiView()
            slider.emojiView.isHidden = true
        }
    }
    
    var isAnswerView: Bool = false {
        didSet {
            tapEnable = !isAnswerView
            textView.isUserInteractionEnabled = !isAnswerView
        }
    }
    
    var startUpdateAnswer: (() -> Swift.Void)? = nil
    
    var didUpdateAnswer: ((Float, StoryTags?) -> Swift.Void)? = nil
    
    var storyTag: StoryTags?

    convenience init() {
        self.init(frame: CGRect.zero)
        self.addSubview(textView)
        self.addSubview(slider)
        
        slider.beginTracking = { [weak self] in
            self?.startUpdateAnswer?()
        }
        
        slider.endTracking = { [weak self] value in
            self?.didUpdateAnswer?(value, self?.storyTag)
        }
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        textView.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        slider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        slider.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 10).isActive = true
        self.layoutIfNeeded()
        self.layer.cornerRadius = 10.0
        startEdit()
    }
    
    func completeEdit() {
        self.tapEnable = true
        textView.resignFirstResponder()
        if textView.text.isEmpty {
            textView.placeHolder = nil
        }
    }
    
    func startEdit() {
        self.tapEnable = false
        textView.becomeFirstResponder()
        if textView.text.isEmpty {
            textView.placeHolder = "Ask a question..."
        }
    }
    
    override func onTapWith(_ tapCount: Int) {
        super.onTapWith(tapCount)
        if tapCount % 2 == 0 {
            print("first type")
        } else if tapCount % 2 == 1 {
            print("second type")
        } else if tapCount % 3 == 2 {
            print("third type")
        }
    }
}

extension NSLayoutManager {
    var numberOfLines: Int {
        guard textStorage != nil else { return 0 }
        var count = 0
        enumerateLineFragments(forGlyphRange: NSMakeRange(0, numberOfGlyphs)) { _, _, _, _, _ in
            count += 1
        }
        return count
    }
}
