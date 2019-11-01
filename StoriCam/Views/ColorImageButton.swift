//
//  ColorImageButton.swift
//  StoriCam
//
//  Created by Viraj Patel on 01/11/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class ColorImageButton: UIButton {
    var indexPath: IndexPath!
    var isSelBtn: Bool!
    var fontSize: CGFloat = -1
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var isRounded: Bool = false {
        didSet {
            if isRounded {
                layer.cornerRadius = self.frame.size.width / 2.0
                layer.masksToBounds = (self.frame.size.width / 2.0) > 0
            }
        }
    }
    
    @IBInspectable var isChangeBackgroundColor: Bool = true {
        didSet {
            if isChangeBackgroundColor {
                self.backgroundColor = ApplicationSettings.appWhiteColor
            }
            else {
                self.backgroundColor = ApplicationSettings.appClearColor
            }
        }
    }
    
    @IBInspectable var isSelectedChange: Bool = false {
        didSet {
            if isSelectedChange {
                self.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
                let origImage = self.image(for: .selected)
                let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                self.setImage(tintedImage, for: .selected)
                self.tintColor = imageTintColor
                if isSelected && self.frame.size.width == self.frame.size.height  {
                    
                    self.backgroundColor = ApplicationSettings.appWhiteColor
                }
                else {
                    self.backgroundColor = ApplicationSettings.appClearColor
                }
            }
            else if self.frame.size.width == self.frame.size.height
            {
                self.backgroundColor = ApplicationSettings.appClearColor
            }
        }
    }
    
    @IBInspectable var imageTintColor: UIColor? = ApplicationSettings.appPrimaryColor {
        didSet {
            self.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
            let origImage = self.imageView?.image
            let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            self.setImage(tintedImage, for: UIControl.State())
            self.tintColor = imageTintColor
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
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isRounded {
            layer.cornerRadius = self.frame.size.width / 2.0
            layer.masksToBounds = (self.frame.size.width / 2.0) > 0
        }
     
        if self.frame.size.width == self.frame.size.height
        {
            if isChangeBackgroundColor {
                self.backgroundColor = ApplicationSettings.appWhiteColor
            }
        }
        
        if !isSelectedChange {
            imageTintColor = ApplicationSettings.appPrimaryColor
        }
        else {
            isSelectedChange = true
        }
        
    }
}
