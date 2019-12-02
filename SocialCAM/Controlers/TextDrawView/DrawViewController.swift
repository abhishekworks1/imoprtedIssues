//
//  ViewController.swift
//  DrawKit
//
//  Created by Viraj Patel on 19/03/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import UIKit

protocol DrawViewDelegate: class {
    func didSelectImage(image: UIImage)
}

public protocol DrawViewControllerDelegate: class {
    /// Called whenever the DrawViewController begins or ends text editing (keyboard entry) mode.
    ///
    /// - Parameters:
    ///   - DrawViewController: The draw text view controller.
    ///   - isEditingText: `true` if entering edit (keyboard text entry) mode, `false` if exiting edit mode.
    func DrawViewController(_ DrawViewController: DrawViewController, isEditingText: Bool)
    
    /// Tells the delegate to handle a touchesBegan event on the drawing container.
    ///
    /// - Parameter touchPoint: The point in this view's coordinate system where the touch began.
    func DrawDrawingContainerTouchBegan(at touchPoint: CGPoint)
    
    /// Tells the delegate to handle a touchesMoved event on the drawing container.
    ///
    /// - Parameter touchPoint: The point in this view's coordinate system to which the touch moved.
    func DrawDrawingContainerTouchMoved(to touchPoint: CGPoint)
    
    /// Tells the delegate to handle a touchesEnded event on the drawing container.
    func DrawDrawingContainerTouchEnded()
    
    /// Tells the delegate to handle a touchesBegan event on the text container.
    ///
    /// - Parameter touchPoint: The point in this view's coordinate system where the touch began.
    func DrawTextContainerTouchBegan(at touchPoint: CGPoint)
    
    /// Tells the delegate to handle a touchesMoved event on the text container.
    ///
    /// - Parameter touchPoint: The point in this view's coordinate system to which the touch moved.
    func DrawTextContainerTouchMoved(to touchPoint: CGPoint)
    
    /// Tells the delegate to handle a touchesEnded event on the text container.
    ///
    /// - Parameter touchPoint: The point in this view's coordinate system to which the touch ended.
    func DrawTextContainerTouchEnded(at touchPoint: CGPoint)
}

public enum FontViewState {
    case `default`
    /// The drawing state, where drawing with touch gestures will create colored lines in the view.
    case neon
    /// The text state, where pinch, pan, and rotate gestures will manipulate the displayed text, and a tap gesture will switch to text editing mode.
    case typeWriter
}

public class DrawViewController: UIViewController {
    
    @IBOutlet weak var btnSave: UIButton!
    
    var delegateImage: DrawViewDelegate?
    
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!
    
    let gradientLayer = CAGradientLayer()
    @IBInspectable var startColor: UIColor = UIColor.yellow {
        didSet {
            configure()
        }
    }
    
    @IBInspectable var midColor: UIColor = UIColor.orange {
        didSet {
            configure()
        }
    }
    
    @IBInspectable var endColor: UIColor = UIColor.red {
        didSet {
            configure()
        }
    }
    
    @IBInspectable var direction: UInt = 1 {
        didSet {
            configure()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            configure()
        }
    }
    
    func setup() {
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //        setup()
        //        configure()
    }
    
    func configure() {
        gradientLayer.cornerRadius = cornerRadius
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1 )
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.locations = [0.25, 0.75]
        
        switch direction % 5 {
        case 0:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0 )
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        case 1:
            gradientLayer.startPoint = CGPoint(x: 0, y: 1 )
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        case 2:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0 )
            gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        case 3:
            gradientLayer.startPoint = CGPoint(x: 1, y: 0 )
            gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
            
        default:
            gradientLayer.startPoint = CGPoint(x: 1, y: 0 )
            gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        }
    }
    
    /// The delegate of the DrawViewController instance.
    public weak var delegate: DrawViewControllerDelegate?
    
    /// The state of the DrawViewController. Change the state between `DrawViewState.drawing` and `DrawViewState.text` in response to your own editing controls to toggle between the different modes. Tapping while in `DrawViewState.text` will automatically switch to `DrawViewState.editingText`, and tapping the keyboard's Done button will automatically switch back to `DrawViewState.text`.
    ///
    /// - Note: The DrawViewController's delegate will get updates when it enters and exits text editing mode, in case you need to update your interface to reflect this.
    public var state: DrawViewState = .default {
        didSet { updateState(state, oldValue: oldValue) }
    }
    
    /// The font of the text displayed in the DrawTextView and DrawTextEditView.
    ///
    /// - Note: To change the default size of the font, you must also set the fontSize property to the desired font size.
    public var font: UIFont = UIFont.durationBookRegularSize75 ?? UIFont.systemFont(ofSize: 75) {
        didSet { updateFont(font) }
    }
    
    /// The color of the text displayed in the DrawTextView and the DrawTextEditView.
    public var textColor: UIColor = ApplicationSettings.appBlackColor {
        didSet { updateTextColor(textColor) }
    }
    
    // Text shadow properties.
    public var textShadowColor: UIColor = ApplicationSettings.appBlackColor {
        didSet { updateTextShadowColor(textShadowColor) }
    }
    
    public var textShadowOpacity: CGFloat = 0 {
        didSet { updateTextShadowOpacity(textShadowOpacity) }
    }
    
    public var textShadowOffset: CGSize = .zero {
        didSet { updateTextShadowOffset(textShadowOffset) }
    }
    
    public var textShadowBlurRadius: CGFloat = 0 {
        didSet { updateTextShadowBlurRadius(textShadowBlurRadius) }
    }
    
    /// The text string the DrawTextView and DrawTextEditView are displaying.
    public var textString: String = "" {
        didSet { updateTextString(textString) }
    }
    
    /// The alignment of the text displayed in the DrawTextView, which only applies if fitOriginalFontSizeToViewWidth is true, and the alignment of the text displayed in the DrawTextEditView regardless of other settings.
    public var textAlignment: NSTextAlignment = .center {
        didSet { updateTextAlignment(textAlignment) }
    }
    
    /// Sets the stroke color for drawing. Each drawing path can have its own stroke color.
    public var drawingColor: UIColor = ApplicationSettings.appBlackColor {
        didSet { updateDrawingColor(drawingColor) }
    }
    
    ///Sets the stroke width for drawing if constantStrokeWidth is true, or sets the base strokeWidth for variable drawing paths constantStrokeWidth is false.
    public var drawingStrokeWidth: CGFloat = 0 {
        didSet { updateDrawingStrokeWidth(drawingStrokeWidth) }
    }
    
    /// Set to `true` if you want the stroke width for drawing to be constant, `false` if the stroke width should vary depending on drawing speed.
    public var drawingConstantStrokeWidth: Bool = false {
        didSet { updateIsDrawingConstantStrokeWidth(drawingConstantStrokeWidth) }
    }
    
    /// The view insets of the text displayed in the DrawTextEditView.
    public var textEditingInsets: UIEdgeInsets = .zero {
        didSet { updateTextEditingInsets(textEditingInsets) }
    }
    
    /// The initial insets of the text displayed in the DrawTextView, which only applies if fitOriginalFontSizeToViewWidth is true. If fitOriginalFontSizeToViewWidth is true, then initialTextInsets sets the initial insets of the displayed text relative to the full size of the DrawTextView. The user can resize, move, and rotate the text from that starting position, but the overall proportions of the text will stay the same.
    ///
    /// - Note: This will be ignored if fitOriginalFontSizeToViewWidth is false.
    public var initialTextInsets: UIEdgeInsets = .zero {
        didSet { updateInitialTextInsets(initialTextInsets) }
    }
    
    /// If fitOriginalFontSizeToViewWidth is true, then the text will wrap to fit within the width of the DrawTextView, with the given initialTextInsets, if any. The layout will reflect the textAlignment property as well as the initialTextInsets property. If this is false, then the text will be displayed as a single line, and will ignore any initialTextInsets and textAlignment settings.
    public var fitOriginalFontSizeToViewWidth = true {
        didSet { updateFitOriginalFontSizeToViewWidth(fitOriginalFontSizeToViewWidth) }
    }
    
    public var fontViewState: FontViewState = .default {
        didSet { updateFontState(fontViewState, oldValue: oldValue) }
    }
    
    @IBOutlet weak var textView: DrawTextView!
    @IBOutlet weak var textEditView: DrawTextEditView!
    @IBOutlet weak var drawingContainer: DrawingContainerView!
    
    // Gesture recognizers
    fileprivate var tapRecognizer: UITapGestureRecognizer?
    fileprivate var pinchRecognizer: UIPinchGestureRecognizer?
    fileprivate var rotationRecognizer: UIRotationGestureRecognizer?
    fileprivate var panRecognizer: UIPanGestureRecognizer?
    fileprivate var doubleTapRecognizer: UITapGestureRecognizer?
    
    fileprivate func addGestureRecognizers() {
        pinchRecognizer = UIPinchGestureRecognizer(target: self,
                                                   action: #selector(handlePinchOrRotate(gesture:)))
        rotationRecognizer = UIRotationGestureRecognizer(target: self,
                                                         action: #selector(handlePinchOrRotate(gesture:)))
        panRecognizer = UIPanGestureRecognizer(target: self,
                                               action: #selector(handlePan(gesture:)))
        tapRecognizer = UITapGestureRecognizer(target: self,
                                               action: #selector(handleTap(gesture:)))
        doubleTapRecognizer = UITapGestureRecognizer(target: self,
                                                     action: #selector(handleDoubleTap(gesture:)))
        doubleTapRecognizer?.numberOfTapsRequired = 2
        tapRecognizer?.require(toFail: doubleTapRecognizer!)
        let gestures: [UIGestureRecognizer] = [
            pinchRecognizer!,
            rotationRecognizer!,
            panRecognizer!,
            tapRecognizer!,
            doubleTapRecognizer!
        ]
        
        gestures.forEach {
            $0.delegate = self
            drawingContainer.addGestureRecognizer($0)
        }
    }
    
    // MARK: - Init
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    @IBOutlet weak var btnChangeColor: RoundedButton!
    @IBOutlet weak var btnClose: RoundedButton!
    @IBOutlet weak var btnChangeView: RoundedButton!
    
    // MARK: - View lifecycle
    
    @IBAction func btnBackClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func btnCloseClick(_ sender: Any) {
        self.textEditView.clearText()
        self.textEditView.isEditing = false
        btnClose.isHidden = true
        btnSave.isSelected = false
        self.textView.isHidden = false
    }
    
    @IBAction func btnChangeBGClick(_ sender: Any) {
        defaultBGColorsIndex = defaultBGColorsIndex + 1
        
        if defaultBGColorsIndex >= defaultBGColors.count {
            defaultBGColorsIndex = 0
        }
        
        if fontViewState == .default {
            drawingContainer.backgroundColor = UIColor.gradientColorFrom(colors: modernBGColors[defaultBGColorsIndex], and: self.view.bounds.size) ?? ApplicationSettings.appBlackColor
            self.textView.textColor = defaultFontColors[defaultBGColorsIndex][0]
            self.textEditView.textView.textColor = defaultFontColors[defaultBGColorsIndex][0]
            btnChangeColor.backgroundColor = UIColor.gradientColorFrom(colors: modernBGColors[defaultBGColorsIndex], and: btnChangeColor.bounds.size) ?? ApplicationSettings.appBlackColor
        } else if fontViewState == .neon {
            drawingContainer.backgroundColor = UIColor.gradientColorFrom(colors: defaultBGColors[defaultBGColorsIndex], and: self.view.bounds.size) ?? ApplicationSettings.appBlackColor
            self.textView.textColor = modernFontColors[defaultBGColorsIndex][0]
            self.textEditView.textView.textColor = modernFontColors[defaultBGColorsIndex][0]
            btnChangeColor.backgroundColor = UIColor.gradientColorFrom(colors: defaultBGColors[defaultBGColorsIndex], and: btnChangeColor.bounds.size) ?? ApplicationSettings.appBlackColor
        } else if fontViewState == .typeWriter {
            drawingContainer.backgroundColor = UIColor.gradientColorFrom(colors: typeWritingBGColors[defaultBGColorsIndex], and: self.view.bounds.size) ?? ApplicationSettings.appBlackColor
            self.textView.textColor = typeWritingFontColors[defaultBGColorsIndex][0]
            self.textEditView.textView.textColor = typeWritingFontColors[defaultBGColorsIndex][0]
            btnChangeColor.backgroundColor = UIColor.gradientColorFrom(colors: typeWritingBGColors[defaultBGColorsIndex], and: btnChangeColor.bounds.size) ?? ApplicationSettings.appBlackColor
        }
    }
    
    @IBAction func btnChangeViewClick(_ sender: Any) {
        if state == .editingText {
            // btnSave.isHidden = false
            textView.isHidden = false
            btnClose.isHidden = true
            textEditView.isEditing = false
        } else {
            defaultBGColorsIndex = 0
            if self.fontViewState == .default {
                self.fontViewState = .neon
            } else if self.fontViewState == .neon {
                self.fontViewState = .typeWriter
            } else if self.fontViewState == .typeWriter {
                self.fontViewState = .default
            }
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        drawingContainer.delegate = self
        textView.font = self.font
        textView.textColor = self.textColor
        fontViewState = .typeWriter
        
        textEditView.font = self.font
        textEditView.textColor = self.textColor
        textEditView.delegate = self
        addGestureRecognizers()
        //        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardFrameDidChange(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func btnSaveClick(_ sender: Any) {
        if state == .editingText {
            self.textEditView.isEditing = false
            btnClose.isHidden = true
            btnSave.isSelected = false
            self.textView.isHidden = false
        } else {
            let image = drawingContainer.toImage()
//            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            delegateImage?.didSelectImage(image: image)
            self.navigationController?.popViewController(animated: false)
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            buttonBottomConstraint?.constant -= keyboardSize.size.height
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            buttonBottomConstraint?.constant += keyboardSize.size.height
        }
    }
    
    @objc func keyboardFrameDidChange(notification: Notification) {
        
        let keyboardRectEnd = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        let duration: Double = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        var animationCurve = UIView.AnimationCurve.linear
        if let index = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue,
            let value = UIView.AnimationCurve(rawValue: index) {
            animationCurve = value
        }
        
        buttonBottomConstraint?.constant = -keyboardRectEnd.height - view.safeAreaInsets.bottom
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [UIView.AnimationOptions(rawValue: UInt(animationCurve.rawValue))],
            animations: {
                self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: - Property updates
    
    fileprivate func updateState(_ state: DrawViewState, oldValue: DrawViewState) {
        guard state != oldValue else { return }
        
        if state == .editingText {
            textView.isHidden = true
            textEditView.isEditing = true
        } else {
            textView.isHidden = false
            textEditView.isEditing = false
        }
        
        if state == .editingText {
            delegate?.DrawViewController(self, isEditingText: true)
        }
        
        if state == .text {
            drawingContainer.isMultipleTouchEnabled = true
            tapRecognizer?.isEnabled = true
            panRecognizer?.isEnabled = true
            pinchRecognizer?.isEnabled = true
            rotationRecognizer?.isEnabled = true
        } else {
            drawingContainer.isMultipleTouchEnabled = false
            tapRecognizer?.isEnabled = false
            panRecognizer?.isEnabled = false
            pinchRecognizer?.isEnabled = false
            rotationRecognizer?.isEnabled = false
        }
    }
    
    fileprivate func updateFontState(_ state: FontViewState, oldValue: FontViewState) {
        guard state != oldValue else { return }
        
        setBackground(state)
    }
    
    var defaultBGColors = [[UIColor.init(hexString: "#70117f"), UIColor.init(hexString: "#8f2f9e")],
                           [UIColor.init(hexString: "#d63774"), UIColor.init(hexString: "#e85a90")],
                           [UIColor.init(hexString: "#282628"), UIColor.init(hexString: "#282628")],
                           [UIColor.init(hexString: "#d1cfd1"), UIColor.init(hexString: "#d1cfd1")],
                           [UIColor.init(hexString: "#9b1131"), UIColor.init(hexString: "#211e1f")]]
    
    var defaultFontColors = [[UIColor.init(hexString: "#efe8ea")],
                             [UIColor.init(hexString: "#efe8ea")],
                             [UIColor.init(hexString: "#efe8ea")],
                             [UIColor.init(hexString: "#2b2829")],
                             [UIColor.init(hexString: "#efe8ea")]]
    
    var typeWritingBGColors = [[UIColor.init(hexString: "#efe8ea"), UIColor.init(hexString: "#e0d7d9")],
                               [UIColor.init(hexString: "#474646"), UIColor.init(hexString: "#c6c2c2")],
                               [UIColor.init(hexString: "#e5e497"), UIColor.init(hexString: "#f9f9e3")],
                               [UIColor.init(hexString: "#e5d8b7"), UIColor.init(hexString: "#d6d3cb")],
                               [UIColor.init(hexString: "#590911"), UIColor.init(hexString: "#840f1b")]]
    
    var typeWritingFontColors = [[UIColor.init(hexString: "#2b2829")],
                                 [UIColor.init(hexString: "#efe8ea")],
                                 [UIColor.init(hexString: "#2b2829")],
                                 [UIColor.init(hexString: "#efe8ea")],
                                 [UIColor.init(hexString: "#efe8ea")]]
    
    var modernBGColors = [[UIColor.init(hexString: "#dd9e63"), UIColor.init(hexString: "#b100ed")],
                          [UIColor.init(hexString: "#15bcea"), UIColor.init(hexString: "#8e18dd")],
                          [UIColor.init(hexString: "#ead923"), UIColor.init(hexString: "#e0660f")],
                          [UIColor.init(hexString: "#32e571"), UIColor.init(hexString: "#4ae3f7")],
                          [UIColor.init(hexString: "#590911"), UIColor.init(hexString: "#840f1b")]]
    
    var modernFontColors = [[UIColor.init(hexString: "#efe8ea")],
                            [UIColor.init(hexString: "#efe8ea")],
                            [UIColor.init(hexString: "#efe8ea")],
                            [UIColor.init(hexString: "#efe8ea")],
                            [UIColor.init(hexString: "#efe8ea")]]
    
    var defaultBGColorsIndex = 0
    
    func setBackground(_ state: FontViewState) {
        self.textEditView.fontState = state
        if state == .default {
            self.textView.font = UIFont.courierPrimeItalic ?? UIFont.systemFont(ofSize: 50)
            self.textEditView.textView.font = UIFont.courierPrimeItalic ?? UIFont.systemFont(ofSize: 50)
            self.textEditView.textView.setTextViewWith(self.textEditView.textView.text)
            self.btnChangeView.setTitle("MODERN", for: UIControl.State())
            
            self.textView.textLabel.neonEffectRemove()
            drawingContainer.backgroundColor = UIColor.gradientColorFrom(colors: modernBGColors[defaultBGColorsIndex], and: self.view.bounds.size) ?? ApplicationSettings.appBlackColor
            btnChangeColor.backgroundColor = UIColor.gradientColorFrom(colors: modernBGColors[defaultBGColorsIndex], and: btnChangeColor.bounds.size) ?? ApplicationSettings.appBlackColor
            self.textView.textColor = defaultFontColors[defaultBGColorsIndex][0]
            self.textEditView.textView.textColor = defaultFontColors[defaultBGColorsIndex][0]
        } else if state == .neon {
            self.textView.font = UIFont.linoleoScript ?? UIFont.systemFont(ofSize: 70)
            self.textEditView.textView.font = UIFont.linoleoScript ?? UIFont.systemFont(ofSize: 70)
            self.textEditView.textView.setTextViewWith(self.textEditView.textView.text)
            self.btnChangeView.setTitle("NEON", for: UIControl.State())
            self.textView.textLabel.neonEffectAdd()
            
            drawingContainer.backgroundColor = UIColor.gradientColorFrom(colors: defaultBGColors[defaultBGColorsIndex], and: self.view.bounds.size) ?? ApplicationSettings.appBlackColor
            btnChangeColor.backgroundColor = UIColor.gradientColorFrom(colors: defaultBGColors[defaultBGColorsIndex], and: btnChangeColor.bounds.size) ?? ApplicationSettings.appBlackColor
            self.textView.textColor = modernFontColors[defaultBGColorsIndex][0]
            self.textEditView.textView.textColor = modernFontColors[defaultBGColorsIndex][0]
            
        } else if state == .typeWriter {
            self.textView.font = UIFont.durationBookRegularSize75 ?? UIFont.systemFont(ofSize: 75)
            self.textEditView.textView.font = UIFont.durationBookRegularSize75 ?? UIFont.systemFont(ofSize: 75)
            self.textEditView.textView.setTextViewWith(self.textEditView.textView.text)
            self.btnChangeView.setTitle("TYPEWRITER", for: UIControl.State())
            self.textView.textLabel.neonEffectRemove()
            drawingContainer.backgroundColor = UIColor.gradientColorFrom(colors: typeWritingBGColors[defaultBGColorsIndex], and: self.view.bounds.size) ?? ApplicationSettings.appBlackColor
            btnChangeColor.backgroundColor = UIColor.gradientColorFrom(colors: typeWritingBGColors[defaultBGColorsIndex], and: btnChangeColor.bounds.size) ?? ApplicationSettings.appBlackColor
            self.textView.textColor = typeWritingFontColors[defaultBGColorsIndex][0]
            self.textEditView.textView.textColor = typeWritingFontColors[defaultBGColorsIndex][0]
        }
    }
    
    fileprivate func updateTextString(_ textString: String) {
        textView.textString = textString
        textEditView.textString = textString
        if let text = textView.textString, text.isEmpty {
            textView.textString = "Type Something..."
            btnClose.isHidden = true
            btnSave.isSelected = false
        } else {
            btnClose.isHidden = false
            btnSave.isSelected = true
        }
        
        setBackground(fontViewState)
    }
    
    fileprivate func updateText(_ textString: String) {
        if textString.isEmpty {
            btnClose.isHidden = true
            btnSave.isSelected = false
        } else {
            btnClose.isHidden = false
            btnSave.isSelected = true
        }
    }
    
    fileprivate func updateFont(_ font: UIFont) {
        textView.font = font
        textEditView.font = font
    }
    
    fileprivate func updateTextAlignment(_ alignment: NSTextAlignment) {
        textView.textAlignment = alignment
        textEditView.textAlignment = alignment
    }
    
    fileprivate func updateTextColor(_ color: UIColor) {
        textView.textColor = color
        textEditView.textColor = color
    }
    
    fileprivate func updateTextShadowColor(_ color: UIColor) {
        textView.textLabel.layer.shadowColor = color.cgColor
    }
    
    fileprivate func updateTextShadowOpacity(_ opacity: CGFloat) {
        textView.textLabel.layer.shadowOpacity = Float(opacity)
    }
    
    fileprivate func updateTextShadowOffset(_ offset: CGSize) {
        textView.textLabel.shadowOffset = offset
    }
    
    fileprivate func updateTextShadowBlurRadius(_ radius: CGFloat) {
        textView.textLabel.layer.shadowRadius = radius
    }
    
    fileprivate func updateInitialTextInsets(_ insets: UIEdgeInsets) {
        textView.initialTextInsets = insets
    }
    
    fileprivate func updateTextEditingInsets(_ insets: UIEdgeInsets) {
        textEditView.textEditingInsets = insets
    }
    
    fileprivate func updateFitOriginalFontSizeToViewWidth(_ isFitting: Bool) {
        self.textView.fitOriginalFontSizeToViewWidth = isFitting
        if isFitting {
            textEditView.textAlignment = textAlignment
        } else {
            textEditView.textAlignment = .left
        }
    }
    
    fileprivate func updateDrawingColor(_ color: UIColor) {
        
    }
    
    fileprivate func updateDrawingStrokeWidth(_ strokeWidth: CGFloat) {
        
    }
    
    fileprivate func updateIsDrawingConstantStrokeWidth(_ isConstantWidth: Bool) {
        
    }
}

// MARK: - Undo

extension DrawViewController {
    /// Removes last stroke. A stroke is all paths that have been created from touch down to touch up.
    public func undoLastStroke() {
        
    }
    
    /// Clears all paths from the drawing in and sets the text to an empty string, giving a blank slate.
    public func clearAll() {
        clearDrawing()
        clearText()
    }
    
    /// Clears only the drawing, leaving the text alone.
    public func clearDrawing() {
        
    }
    
    /// Clears only the text, leaving the drawing alone.
    public func clearText() {
        textView.clearText()
    }
}

// MARK: - Gesture handling

extension DrawViewController {
    @objc func handleTap(gesture: UITapGestureRecognizer) {
        // Set to text editing on tap.
        if state != .editingText {
            state = .editingText
        }
    }
    
    @objc func handleDoubleTap(gesture: UITapGestureRecognizer) {
        // Set to text editing on tap.
        if state == .editingText {
            //            textView.isHidden = false
            //            textEditView.isEditing = false
        } else {
            if self.fontViewState == .default {
                self.fontViewState = .neon
            } else if self.fontViewState == .neon {
                self.fontViewState = .typeWriter
            } else if self.fontViewState == .typeWriter {
                self.fontViewState = .default
            }
        }
        
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        textView.handlePan(gesture: gesture)
        
        if state == .text {
            // Forward to text view.
            let location = gesture.location(in: self.textView)
            switch gesture.state {
            case .began:
                delegate?.DrawTextContainerTouchBegan(at: location)
            case .changed:
                delegate?.DrawTextContainerTouchMoved(to: location)
            case .ended, .cancelled:
                delegate?.DrawTextContainerTouchEnded(at: location)
            default: break
            }
        }
    }
    
    @objc func handlePinchOrRotate(gesture: UIGestureRecognizer) {
        textView.handlePinchOrRotate(gesture: gesture)
    }
    
    func btnClick(sender: UIButton) {
        
    }
    
}

// MARK: - DrawDrawingContainerViewDelegate
extension DrawViewController: DrawingContainerViewDelegate {
    func drawingContainerViewTouchBegan(at point: CGPoint) {
        if state == .drawing {
            delegate?.DrawDrawingContainerTouchBegan(at: point)
        }
    }
    
    func drawingContainerViewTouchMoved(to point: CGPoint) {
        if state == .drawing {
            delegate?.DrawDrawingContainerTouchMoved(to: point)
        }
    }
    
    func drawingContainerViewTouchEnded(at point: CGPoint) {
        if state == .drawing {
            delegate?.DrawDrawingContainerTouchEnded()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension DrawViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer {
            return true
        } else {
            return false
        }
    }
}

// MARK: - DrawTextEditViewDelegate

extension DrawViewController: DrawTextEditViewDelegate {
    func DrawTextEditViewWillEditing(withText text: String?) {
        updateText(text ?? "")
    }
    
    func DrawTextEditViewFinishedEditing(withText text: String?) {
        if state == .editingText {
            state = .text
        }
        updateTextString(text ?? "")
        delegate?.DrawViewController(self, isEditingText: false)
    }
}

// MARK: - DrawViewState

public extension DrawViewController {
    enum DrawViewState {
        case `default`
        /// The drawing state, where drawing with touch gestures will create colored lines in the view.
        case drawing
        /// The text state, where pinch, pan, and rotate gestures will manipulate the displayed text, and a tap gesture will switch to text editing mode.
        case text
        /// The text editing state, where the contents of the text string can be edited with the keyboard.
        case editingText
    }
}
