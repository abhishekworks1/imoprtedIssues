//
//  ColorRoundedView.swift
//  SocialCAM
//
//  Created by Viraj Patel on 21/04/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

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
