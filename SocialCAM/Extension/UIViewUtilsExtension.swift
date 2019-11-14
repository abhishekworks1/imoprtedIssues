//
//  UIViewUtilsExtension.swift
//  Swift Shopper
//
//  Created by Ajay.Ghodadra on 03/05/16.
//  Copyright © 2016 Simform. All rights reserved.
//

import Foundation
import UIKit

public let kUIViewPropertyCornerRadiusValue = 0.0
private var kUIViewPropertyCornerRadius = "kUIViewPropertyCornerRadius"

public let kUIViewPropertyBorderColorValue = ApplicationSettings.appClearColor
private var kUIViewPropertyBorderColor = "kUIViewPropertyBorderColor"

public let kUIViewPropertyBorderWidthValue = 0.0
private var kUIViewPropertyBorderWidth = "kUIViewPropertyBorderWidth"

public let kUIViewPropertyBackgroundColorValue = ApplicationSettings.appWhiteColor
private var kUIViewPropertyBackgroundColor = "kUIViewPropertyBackgroundColor"

//public let kUIViewPropertyUserInformationValue as? AnyObject;
//private var kUIViewPropertyUserInformation = "kUIViewPropertyUserInformation"



public extension UIView{
    @IBInspectable var cornerRadiusChat : CGFloat{
        get {
            if let aValue = objc_getAssociatedObject(self, &kUIViewPropertyCornerRadius) as? CGFloat {
                return aValue
            } else {
                return CGFloat(kUIViewPropertyCornerRadiusValue)
            }
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kUIViewPropertyCornerRadius, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var borderColorChat : UIColor{
        get {
            if let aValue = objc_getAssociatedObject(self, &kUIViewPropertyBorderColor) as? UIColor {
                return aValue
            } else {
                return kUIViewPropertyBorderColorValue
            }
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kUIViewPropertyBorderColor, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.layer.borderColor = newValue.cgColor
        }
    }
    
    @IBInspectable var borderWidthChat : CGFloat{
        get {
            if let aValue = objc_getAssociatedObject(self, &kUIViewPropertyBorderWidth) as? CGFloat {
                return aValue
            } else {
                return CGFloat(kUIViewPropertyBorderWidthValue)
            }
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kUIViewPropertyBorderWidth, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.layer.borderWidth = newValue
        }
    }
}
