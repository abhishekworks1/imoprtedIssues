//
//  CustomeView.swift
//  WhereIts
//
//  Created by Jatin Kathrotiya on 09/06/16.
//  Copyright © 2016 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import FLAnimatedImage

@IBDesignable
class BorderView: UIView {
    var ratio: CGFloat = 1
    var gradientLayer: CAGradientLayer?
    var colorset: [CGColor] = [UIColor.startColor.cgColor, UIColor.endColor.cgColor]
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0.1 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    @IBInspectable var shadowColor: UIColor? {
        didSet {
            layer.shadowColor = shadowColor?.cgColor
        }
    }
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    @IBInspectable var shadowOffset: CGSize = CGSize.zero {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    @IBInspectable var shadowRadiaus: CGFloat = 3 {
        didSet {
            layer.shadowRadius = shadowRadiaus
        }
    }
    @IBInspectable var masksToBounds: Bool = false {
        didSet {
            layer.masksToBounds = masksToBounds
        }
    }
    @IBInspectable var startColor: UIColor? {
        didSet {
            colorset[0] = (startColor?.cgColor)!
            if let gl = self.gradientLayer {
                gl.colors = colorset
            }
        }
    }
    @IBInspectable var endColor: UIColor? {
        didSet {
            colorset[1] = (endColor?.cgColor)!
            if let gl = self.gradientLayer {
                gl.colors = colorset
            }
        }
    }
    var startPoint: CGPoint? = CGPoint(x: 0.0, y: 0.5) {
        didSet {
            if let gl = self.gradientLayer {
                gl.startPoint = startPoint!
            }
        }
    }
    var endPoint: CGPoint? = CGPoint(x: 1.0, y: 0.5) {
        didSet {
            if let gl = self.gradientLayer {
                gl.endPoint = endPoint!
            }
        }
    }
    
    @IBInspectable var isChangeBackgroundColor: Bool = false {
        didSet {
            if isChangeBackgroundColor {
                self.backgroundColor = ApplicationSettings.appPrimaryColor
            } else {
                self.backgroundColor = ApplicationSettings.appClearColor
            }
        }
    }
    
    @IBInspectable var hasGridiantLayer: Bool = false {
        didSet {
            if hasGridiantLayer == true {
                if self.gradientLayer == nil {
                    self.gradientLayer = CAGradientLayer()
                }
                self.gradientLayer?.frame = self.bounds
                self.gradientLayer?.colors = colorset
                self.gradientLayer?.locations = [0.0, 0.60]
                self.gradientLayer?.startPoint = startPoint!
                self.gradientLayer?.endPoint = endPoint!
                self.layer.insertSublayer(self.gradientLayer!, at: 0)
                //  self.layer.addSublayer(gradientLayer!)
            } else {
                if let gl = self.gradientLayer {
                    if (self.layer.sublayers?.contains(gl)) == true {
                        gl.removeFromSuperlayer()
                        self.gradientLayer = nil
                    }
                }
            }
        }
    }

    override func layoutSubviews() {
        if ratio == 1 {
            ratio = UIScreen.main.bounds.size.width / 375.0
        }
        layer.cornerRadius = cornerRadius * ratio
        self.gradientLayer?.frame = self.bounds
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // fatalError("init(coder:) has not been implemented")
    }
    
}

@IBDesignable
class RoundedView: UIView {
    var gradientLayer: CAGradientLayer?
    var colorset: [CGColor] = [UIColor.startColor.cgColor, UIColor.endColor.cgColor]
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    @IBInspectable var masksToBounds: Bool = false {
        didSet {
            layer.masksToBounds = masksToBounds
        }
    }
    @IBInspectable var shadowColor: UIColor? {
        didSet {
            layer.shadowColor = shadowColor?.cgColor
        }
    }

    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    @IBInspectable var shadowOffset: CGSize = CGSize.zero {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    @IBInspectable var startColor: UIColor? {
        didSet {
            colorset[0] = (startColor?.cgColor)!
            if let gl = self.gradientLayer {
                gl.colors = colorset
            }
        }
    }
    @IBInspectable var endColor: UIColor? {
        didSet {
            colorset[1] = (endColor?.cgColor)!
            if let gl = self.gradientLayer {
                gl.colors = colorset
            }
        }
    }
    var startPoint: CGPoint? = CGPoint(x: 0.0, y: 0.5) {
        didSet {
            if let gl = self.gradientLayer {
                gl.startPoint = startPoint!
            }
        }
    }
    var endPoint: CGPoint? = CGPoint(x: 1.0, y: 0.5) {
        didSet {
            if let gl = self.gradientLayer {
                gl.endPoint = endPoint!
            }
        }
    }
    @IBInspectable var hasGridiantLayer: Bool = false {
        didSet {
            if hasGridiantLayer == true {
                if self.gradientLayer == nil {
                    self.gradientLayer = CAGradientLayer()
                }
                self.gradientLayer?.frame = self.bounds
                self.gradientLayer?.colors = colorset
                self.gradientLayer?.locations = [0.0, 0.65]
                self.gradientLayer?.startPoint = startPoint!
                self.gradientLayer?.endPoint = endPoint!
                self.layer.insertSublayer(self.gradientLayer!, at: 0)
            } else {
                if let gl = self.gradientLayer {
                    if (self.layer.sublayers?.contains(gl)) == true {
                        gl.removeFromSuperlayer()
                        self.gradientLayer = nil
                    }
                }
            }
        }
    }

    override func layoutSubviews() {
        layer.cornerRadius = self.frame.size.height / 2.0
        self.gradientLayer?.frame = self.bounds
    }
    
}

class PLabel: UILabel {
    var fontSize: CGFloat = -1
    
    override func draw(_ rect: CGRect) {
        let ratio = UIScreen.main.bounds.size.width / 375.0
        if(self.fontSize == -1) {
            self.fontSize = (self.font.pointSize)
        }
        self.font = UIFont(name: self.font.fontName, size: (self.fontSize * ratio))
        super.draw(rect)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let ratio = UIScreen.main.bounds.size.width / 375.0
        if(self.fontSize == -1) {
            self.fontSize = (self.font.pointSize)
        }
        self.font = UIFont(name: self.font.fontName, size: (self.fontSize * ratio))
    }

}

@IBDesignable
class PButton: UIButton {
    var indexPath: IndexPath!
    var isSelBtn: Bool!
    var fontSize: CGFloat = -1
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    @IBInspectable var isRounded: Bool = false {
        didSet {
            if isRounded == true {
                layer.cornerRadius = self.frame.size.height / 2.0
            }

        }
    }
    
    override func draw(_ rect: CGRect) {
        if(self.fontSize == -1) {
            self.fontSize = (self.titleLabel?.font.pointSize)!
        }
        let ratio = UIScreen.main.bounds.size.width / 375.0
        self.titleLabel?.font = UIFont(name: (self.titleLabel?.font.fontName)!, size: (self.fontSize * ratio))
        super.draw(rect)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if(self.fontSize == -1) {
            self.fontSize = (self.titleLabel?.font.pointSize)!
        }
        let ratio = UIScreen.main.bounds.size.width / 375.0
        self.titleLabel?.font = UIFont(name: (self.titleLabel?.font.fontName)!, size: (self.fontSize * ratio))
    }

    @IBInspectable var imageTintColor: UIColor? {
        didSet {
            self.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
            let origImage = self.imageView?.image
            let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            self.setImage(tintedImage, for: UIControl.State())
            self.tintColor = imageTintColor
        }
    }

    @IBInspectable var underLinedText: String? {
        didSet {
            let titleString: NSMutableAttributedString = NSMutableAttributedString(string: underLinedText!)
            titleString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: underLinedText!.count))
            self.setAttributedTitle(titleString, for: UIControl.State())
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if isRounded {
            layer.cornerRadius = self.frame.size.height / 2.0
        }
    }
    
}

class CheckButton: PButton {
   
    var isCheck: Bool = false {
        didSet {
            if isCheck == true {
                self.setImage(R.image.checkOn(), for: UIControl.State())
                self.borderColor = ApplicationSettings.appClearColor
                imageColor = ApplicationSettings.appPrimaryColor
                self.borderWidth = 0.0
                self.clipsToBounds = true
            } else {
                self.setImage(R.image.checkOff(), for: UIControl.State())
                self.isRounded = true
                self.borderColor = UIColor.gray
                self.borderWidth = 0.0
                self.clipsToBounds = true
            }
        }
    }
    
    @IBInspectable var isAllImagesChange: Bool = false {
        didSet {
            self.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
            let origImage = self.imageView?.image
            let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            self.setImage(tintedImage, for: UIControl.State())
            
            if isAllImagesChange {
                self.tintColor = imageTintColor
            }
        }
    }
    
    @IBInspectable var isSelectedChange: Bool = false {
        didSet {
            self.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
            let origImage = self.imageView?.image
            let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            self.setImage(tintedImage, for: isSelectedChange ? .selected : UIControl.State())
         
            if isSelectedChange {
                self.tintColor = imageTintColor
            }
        }
    }
    
    @IBInspectable var imageColor: UIColor? {
        didSet {
            self.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
            let origImage = self.imageView?.image
            let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            self.setImage(tintedImage, for: UIControl.State())
            self.tintColor = imageColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
}

@IBDesignable
class RoundedImageView: FLAnimatedImageView {
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    @IBInspectable var masksToBounds: Bool = false {
        didSet {
            layer.masksToBounds = masksToBounds
        }
    }
    @IBInspectable var shadowColor: UIColor? {
        didSet {
            layer.shadowColor = shadowColor?.cgColor
        }
    }
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    @IBInspectable var shadowOffset: CGSize = CGSize.zero {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }

    override func layoutSubviews() {
        layer.cornerRadius = self.frame.size.height / 2.0
    }
    
}

@IBDesignable class FourSideShadow: UIView {
    
    @IBInspectable var shadowColor: UIColor? {
        didSet {
            layer.shadowColor = shadowColor?.cgColor
        }
    }
    @IBInspectable var shadowOffSet: CGSize = CGSize.zero {
        didSet {
            layer.shadowOffset = shadowOffSet
        }
    }
    @IBInspectable var shadowOpacity: Float = 0.0 {
        didSet {
             layer.shadowOpacity = shadowOpacity
        }
    }
    @IBInspectable var maskToBound: Bool = false {
        didSet {
            layer.masksToBounds = maskToBound
        }
    }
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var shadowRadius: CGFloat = 0.0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    override func layoutSubviews() {
        layer.shadowPath = UIBezierPath(rect: layer.bounds).cgPath
    }
    
    func setup() {
        layer.shadowPath = UIBezierPath(rect: layer.bounds).cgPath
    }
    
}

@IBDesignable class FourSideShadowButton: UIButton {
    
    @IBInspectable var shadowColor: UIColor? {
        didSet {
            layer.shadowColor = shadowColor?.cgColor
        }
    }
    @IBInspectable var shadowOffSet: CGSize = CGSize.zero {
        didSet {
            layer.shadowOffset = shadowOffSet
        }
    }
    @IBInspectable var shadowOpacity: Float = 0.0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    @IBInspectable var maskToBound: Bool = false {
        didSet {
            layer.masksToBounds = maskToBound
        }
    }
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var shadowRadius: CGFloat = 0.0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    @IBInspectable var textData: String = "" {
        didSet {
            self.setTitle(textData, for: .normal)
        }
    }
    
    override func layoutSubviews() {
        layer.shadowPath = UIBezierPath(rect: layer.bounds).cgPath
    }
    
}

@IBDesignable
class ColorButton: UIButton {
    var indexPath: IndexPath!
    var isSelBtn: Bool!
    var fontSize: CGFloat = -1
  
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
   
    @IBInspectable var isChangeBackgroundColor: Bool = true {
        didSet {
            if isChangeBackgroundColor {
                self.backgroundColor = ApplicationSettings.appPrimaryColor
                self.setTitleColor(ApplicationSettings.appWhiteColor, for: UIControl.State())
            } else {
                self.backgroundColor = ApplicationSettings.appClearColor
                self.setTitleColor(ApplicationSettings.appPrimaryColor, for: UIControl.State())
            }
        }
    }
    
    @IBInspectable var isImageColorChange: Bool = false {
        didSet {
            if isImageColorChange {
                self.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
                let origImage = self.imageView?.image
                let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                self.setImage(tintedImage, for: UIControl.State())
                self.tintColor = ApplicationSettings.appPrimaryColor
            }
        }
    }
    
    @IBInspectable var isRounded: Bool = false {
        didSet {
            if isRounded {
                layer.cornerRadius = self.frame.size.height / 2.0
                layer.masksToBounds = (self.frame.size.height / 2.0) > 0
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if(self.fontSize == -1) {
            self.fontSize = (self.titleLabel?.font.pointSize)!
        }
        let ratio = UIScreen.main.bounds.size.width / 375.0
        self.titleLabel?.font = UIFont(name: (self.titleLabel?.font.fontName)!, size: (self.fontSize * ratio))
    }
    
    override func layoutSubviews()           {
        super.layoutSubviews()
        if isRounded {
            layer.cornerRadius = self.frame.size.height / 2.0
            layer.masksToBounds = (self.frame.size.height / 2.0) > 0
        }
        if isChangeBackgroundColor {
            self.backgroundColor = ApplicationSettings.appPrimaryColor
        }
    }
    
}

@IBDesignable
class ColorRoundedView: UIView {
    var gradientLayer: CAGradientLayer?
    var colorset: [CGColor] = [ApplicationSettings.appPrimaryColor.cgColor, ApplicationSettings.appPrimaryColor.cgColor]
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var bgColor: UIColor = ApplicationSettings.appPrimaryColor {
        didSet {
            self.backgroundColor = bgColor
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    @IBInspectable var masksToBounds: Bool = false {
        didSet {
            layer.masksToBounds = masksToBounds
        }
    }
    @IBInspectable var shadowColor: UIColor? {
        didSet {
            layer.shadowColor = shadowColor?.cgColor
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    @IBInspectable var shadowOffset: CGSize = CGSize.zero {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    @IBInspectable var startColor: UIColor? {
        didSet {
            colorset[0] = (startColor?.cgColor)!
            if let gl = self.gradientLayer {
                gl.colors = colorset
            }
        }
    }
    @IBInspectable var endColor: UIColor? {
        didSet {
            colorset[1] = (endColor?.cgColor)!
            if let gl = self.gradientLayer {
                gl.colors = colorset
            }
        }
    }
    var startPoint: CGPoint? = CGPoint(x: 0.0, y: 0.5) {
        didSet {
            
            if let gl = self.gradientLayer {
                gl.startPoint = startPoint!
            }
        }
    }
    var endPoint: CGPoint? = CGPoint(x: 1.0, y: 0.5) {
        didSet {
            if let gl = self.gradientLayer {
                gl.endPoint = endPoint!
            }
        }
    }
    @IBInspectable var hasGridiantLayer: Bool = false {
        didSet {
            if hasGridiantLayer == true {
                if self.gradientLayer == nil {
                    self.gradientLayer = CAGradientLayer()
                }
                self.gradientLayer?.frame = self.bounds
                self.gradientLayer?.colors = colorset
                self.gradientLayer?.locations = [0.0, 0.65]
                self.gradientLayer?.startPoint = startPoint!
                self.gradientLayer?.endPoint = endPoint!
                self.layer.insertSublayer(self.gradientLayer!, at: 0)
            } else {
                if let gl = self.gradientLayer {
                    if (self.layer.sublayers?.contains(gl)) == true {
                        gl.removeFromSuperlayer()
                        self.gradientLayer = nil
                    }
                }
            }
        }
    }
    
    @IBInspectable var isRoundView: Bool = true {
        didSet {
            if !isRoundView {
                layer.cornerRadius = 0
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func layoutSubviews() {
        if isRoundView {
            layer.cornerRadius = self.frame.size.height / 2.0
        }
        
        self.gradientLayer?.frame = self.bounds
        bgColor = ApplicationSettings.appPrimaryColor
    }
}

@IBDesignable
class ColorLabel: UILabel {
    
    @IBInspectable var textTintColor: UIColor? {
        didSet {
            self.textColor = textTintColor
        }
    }
    
    override func draw(_ rect: CGRect) {
        self.textColor = ApplicationSettings.appPrimaryColor
        super.draw(rect)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textColor = ApplicationSettings.appPrimaryColor
    }
    
}

class ColorBGLabel: UILabel {
    
    @IBInspectable var textTintColor: UIColor? = ApplicationSettings.appPrimaryColor {
        didSet {
            setColor()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setColor()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setColor()
    }
    
    func setColor() {
        self.backgroundColor = textTintColor
    }
}

@IBDesignable
class ColorImageView: FLAnimatedImageView {
    
    var isSetImage = false
    
    @IBInspectable var masksToBounds: Bool = false {
        didSet {
            layer.masksToBounds = masksToBounds
        }
    }
    
    @IBInspectable var imageTintColor: UIColor? = ApplicationSettings.appPrimaryColor {
        didSet {
            self.setImageWithTintColor(color: imageTintColor!)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        if !isSetImage {
            self.setImageWithTintColor(color: imageTintColor!)
            isSetImage = !isSetImage
        }
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = ApplicationSettings.appWhiteColor
    }
    
}

@IBDesignable
open class ColorTabBarItem: UITabBarItem {
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
