//
//  UIView+Image.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

extension UIScreen {
    class var width: CGFloat {
        return UIScreen.main.bounds.width
    }
    class var height: CGFloat {
        return UIScreen.main.bounds.height
    }
    class var haveRatio: Bool {
        return !(UIScreen.height > 736.0)
    }
    class var ratioWidth: CGFloat {
        var width = UIScreen.width
        let height = UIScreen.height
        if !UIScreen.haveRatio {
            width = (height * 375) / 667
        }
        return width
    }
}

extension UIView {
    
    @IBInspectable var cornerRadiusV: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidthV: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColorV: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    func addBottomBorder(_ color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.borderColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        border.borderWidth = width
        self.layer.addSublayer(border)
    }
    
    func originalScaleXValue(for width: CGFloat) -> CGFloat {
        let scaleValue = sqrt(pow(transform.a, 2) + pow(transform.c, 2))
        return scaleValue.ratio / width
    }
    
    func originalScaleYValue(for height: CGFloat) -> CGFloat {
        let scaleValue = sqrt(pow(transform.b, 2) + pow(transform.d, 2))
        return scaleValue.ratio / height
    }
    
    func snapshotData() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    func startBlink(_ duration: TimeInterval = 0.8) {
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: [.allowUserInteraction, .curveEaseInOut, .autoreverse, .repeat],
                       animations: { self.alpha = 0 },
                       completion: nil)
    }
    
    func stopBlink() {
        layer.removeAllAnimations()
        alpha = 1
    }
    
    func parentView<T: UIView>(of type: T.Type) -> T? {
        guard let view = self.superview else {
            return nil
        }
        return (view as? T) ?? view.parentView(of: T.self)
    }
    
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            self.frame.size.width = newValue
        }
    }
    
    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            self.frame.size.height = newValue
        }
    }
    
    class func fromNib<T : UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        // layer.shadowPath = path.cgPath
        layer.shadowColor = ApplicationSettings.appBlackColor.cgColor
        layer.shadowOffset = CGSize(width:0,height:1)
        layer.mask = mask
    }
    
    func dropShadow() {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = ApplicationSettings.appBlackColor.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 5.0
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.insertSubview(blurEffectView, at: 0)
    }
    
    func removeBlurEffect() {
        let blurredEffectViews = self.subviews.filter{ $0 is UIVisualEffectView }
        blurredEffectViews.forEach { blurView in
            blurView.removeFromSuperview()
        }
    }
    
    func addStoryGradientLayer(startColor: UIColor, middleColor: UIColor, endColor: UIColor) {
        let gradient = StoryTagGradientLayer()
        gradient.frame = bounds
        gradient.colors = [startColor.cgColor, middleColor.cgColor, endColor.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.locations = [0.0, 0.5, 1.0]
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func removeStoryGradientLayer() {
        let gradientLayers = self.layer.sublayers?.filter{ $0 is StoryTagGradientLayer }
        gradientLayers?.forEach { gradientLayer in
            gradientLayer.removeFromSuperlayer()
        }
    }
    
    func startShimmering() {
        let light = UIColor(white: 0, alpha: 0.1).cgColor
        let dark = UIColor.yellow.cgColor
        
        let gradient = CAGradientLayer()
        gradient.colors = [dark, light, dark]
        gradient.frame = CGRect(x: -bounds.size.width, y: 0, width: 3 * bounds.size.width, height: bounds.size.height)
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.525) // slightly slanted forward
        gradient.locations = [0.4, 0.5, 0.6]
        layer.mask = gradient
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        
        animation.duration = 1.5
        animation.repeatCount = Float.infinity
        gradient.add(animation, forKey: "shimmer")
    }
    
    func stopShimmering() {
        layer.mask = nil
    }
    
    /// Helper to get pre transform frame
    var originalFrame: CGRect {
        let currentTransform = transform
        transform = .identity
        let originalFrame = frame
        transform = currentTransform
        return originalFrame
    }
    
    /// Helper to get point offset from center
    func centerOffset(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x - center.x, y: point.y - center.y)
    }
    
    /// Helper to get point back relative to center
    func pointRelativeToCenter(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x + center.x, y: point.y + center.y)
    }
    
    /// Helper to get point relative to transformed coords
    func newPointInView(_ point: CGPoint) -> CGPoint {
        // get offset from center
        let offset = centerOffset(point)
        // get transformed point
        let transformedPoint = offset.applying(transform)
        // make relative to center
        return pointRelativeToCenter(transformedPoint)
    }
    
    var newTopLeft: CGPoint {
        return newPointInView(originalFrame.origin)
    }
    
    var newTopRight: CGPoint {
        var point = originalFrame.origin
        point.x += originalFrame.width
        return newPointInView(point)
    }
    
    var newBottomLeft: CGPoint {
        var point = originalFrame.origin
        point.y += originalFrame.height
        return newPointInView(point)
    }
    
    var newBottomRight: CGPoint {
        var point = originalFrame.origin
        point.x += originalFrame.width
        point.y += originalFrame.height
        return newPointInView(point)
    }
    
    /** This is the function to get subViews of a view of a particular type
     */
    func subViews<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        for view in self.subviews {
            if let aView = view as? T{
                all.append(aView)
            }
        }
        return all
    }
    
    
    /** This is a function to get subViews of a particular type from view recursively. It would look recursively in all subviews and return back the subviews of the type T */
    func allSubViewsOf<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        func getSubview(view: UIView) {
            if let aView = view as? T{
                all.append(aView)
            }
            DispatchQueue.main.async {
                guard view.subviews.count>0 else { return }
                view.subviews.forEach{ getSubview(view: $0) }
            }
        }
        getSubview(view: self)
        return all
    }
    
    func sizeToFitCustom() {
        var w: CGFloat = 0,
        h: CGFloat = 0
        for view in subviews {
            if view.frame.origin.x + view.frame.width > w { w = view.frame.origin.x + view.frame.width }
            if view.frame.origin.y + view.frame.height > h { h = view.frame.origin.y + view.frame.height }
        }
        frame.size = CGSize(width: w, height: h)
    }
    
    func hideTagViews(hide: Bool) {
        let sliderQueViews = self.allSubViewsOf(type: BaseQuestionTagView.self)
        for view in sliderQueViews {
            view.isHidden = hide
        }
    }
    
    func toImage() -> UIImage {
        hideTagViews(hide: true)
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let snapshotImageFromMyView = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        hideTagViews(hide: false)
        return snapshotImageFromMyView!
    }
    
    func toVideoImage() -> UIImage {
        hideTagViews(hide: true)
        let image = self.asImage()
        let pngImage = UIImage(data: image.pngData()!)
        hideTagViews(hide: false)
        return pngImage!
    }
    
    func asImage() -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = 0.0
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds, format: format)
        return renderer.image { rendererContext in
            DispatchQueue.main.async {
                self.layer.render(in: rendererContext.cgContext)
            }
        }
    }
    
    func scaleView(scaleXFactor: CGFloat, scaleYFactor: CGFloat) {
        transform = transform.scaledBy(x: scaleXFactor, y: scaleYFactor)
    }
    
    func rotateView(_ angle: CGFloat) {
        transform = transform.rotated(by: angle)
    }
    
    var scaleXValue: CGFloat {
        let scaleValue = sqrt(pow(transform.a, 2) + pow(transform.c, 2))
        return scaleValue.ratio / UIScreen.ratioWidth
    }
    
    var scaleYValue: CGFloat {
        let scaleValue = sqrt(pow(transform.b, 2) + pow(transform.d, 2))
        return scaleValue.ratio / UIScreen.height
    }
    
    var rotationValue: CGFloat {
        return atan2(transform.b, transform.a)
    }
    
    var xGlobalCenterPoint: CGFloat {
        let x = self.center.x
        if !UIScreen.haveRatio {
            return x.ratio / UIScreen.ratioWidth
        }
        return x.ratio / UIScreen.width
    }
    
    var yGlobalCenterPoint: CGFloat {
        return self.center.y.ratio / UIScreen.height
    }
    
    var xGlobalPoint: CGFloat {
        let x = self.frame.origin.x
        return x.ratio / UIScreen.ratioWidth
    }
    
    var yGlobalPoint: CGFloat {
        return self.frame.origin.y.ratio / UIScreen.height
    }
    
    func aspectFitCenterForView(_ center: CGPoint) -> CGPoint {
        return CGPoint(x: (UIScreen.ratioWidth*center.x / 100) + ((UIScreen.width - self.width)/2),
                       y: (self.height*CGFloat(center.y) / 100) + ((UIScreen.height - self.height)/2))
    }
    
    func aspectFitScaleXForView(_ scaleX: CGFloat) -> CGFloat {
        return UIScreen.ratioWidth*scaleX / 100
    }
    
    func aspectFitScaleYForView(_ scaleY: CGFloat) -> CGFloat {
        return self.height*scaleY / 100
    }
    
    @discardableResult func g_pin(on type1: NSLayoutConstraint.Attribute,
                                  view: UIView? = nil, on type2: NSLayoutConstraint.Attribute? = nil,
                                  constant: CGFloat = 0,
                                  priority: Float? = nil) -> NSLayoutConstraint? {
        guard let view = view ?? superview else {
            return nil
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        let type2 = type2 ?? type1
        let constraint = NSLayoutConstraint(item: self, attribute: type1,
                                            relatedBy: .equal,
                                            toItem: view, attribute: type2,
                                            multiplier: 1, constant: constant)
        if let priority = priority {
            constraint.priority = UILayoutPriority(priority)
        }
        
        constraint.isActive = true
        
        return constraint
    }
    
    func g_pinEdges(view: UIView? = nil) {
        g_pin(on: .top, view: view)
        g_pin(on: .bottom, view: view)
        g_pin(on: .left, view: view)
        g_pin(on: .right, view: view)
    }
    
    func g_pin(size: CGSize) {
        g_pin(width: size.width)
        g_pin(height: size.height)
    }
    
    func g_pin(width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width))
    }
    
    func g_pin(height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
    }
    
    func g_pin(greaterThanHeight height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
    }
    
    func g_pinHorizontally(view: UIView? = nil, padding: CGFloat) {
        g_pin(on: .left, view: view, constant: padding)
        g_pin(on: .right, view: view, constant: -padding)
    }
    
    func g_pinUpward(view: UIView? = nil) {
        g_pin(on: .top, view: view)
        g_pin(on: .left, view: view)
        g_pin(on: .right, view: view)
    }
    
    func g_pinDownward(view: UIView? = nil) {
        g_pin(on: .bottom, view: view)
        g_pin(on: .left, view: view)
        g_pin(on: .right, view: view)
    }
    
    func g_pinCenter(view: UIView? = nil) {
        g_pin(on: .centerX, view: view)
        g_pin(on: .centerY, view: view)
    }
    
    /// Find the size of the image, once the parent imageView has been given a contentMode of .scaleAspectFit
    /// Querying the image.size returns the non-scaled size. This helper property is needed for accurate results.
    func aspectFitSize(for size: CGSize) -> CGSize {
        var aspectFitSize = CGSize(width: frame.size.width, height: frame.size.height)
        let newWidth: CGFloat = frame.size.width / size.width
        let newHeight: CGFloat = frame.size.height / size.height

        if newHeight < newWidth {
            aspectFitSize.width = newHeight * size.width
        } else if newWidth < newHeight {
            aspectFitSize.height = newWidth * size.height
        }

        return aspectFitSize
    }

    /// Find the size of the image, once the parent imageView has been given a contentMode of .scaleAspectFill
    /// Querying the image.size returns the non-scaled, vastly too large size. This helper property is needed for accurate results.
    func aspectFillSize(for size: CGSize) -> CGSize {
        var aspectFillSize = CGSize(width: frame.size.width, height: frame.size.height)
        let newWidth: CGFloat = frame.size.width / size.width
        let newHeight: CGFloat = frame.size.height / size.height

        if newHeight > newWidth {
            aspectFillSize.width = newHeight * size.width
        } else if newWidth > newHeight {
            aspectFillSize.height = newWidth * size.height
        }

        return aspectFillSize
    }
}


// NSLayoutConstraint UIView

internal struct ViewEdges: OptionSet {
    let rawValue: Int
    
    static let top    = ViewEdges(rawValue: 1 << 0)
    static let right  = ViewEdges(rawValue: 1 << 1)
    static let bottom = ViewEdges(rawValue: 1 << 2)
    static let left   = ViewEdges(rawValue: 1 << 3)
    
    static let all: ViewEdges = [.top, .right, .bottom, .left]
}

internal extension UIView {
    
    @discardableResult
    func matchHeight(to view: UIView, difference: CGFloat = 0) -> NSLayoutConstraint {
        let heightConstraint = NSLayoutConstraint(item: self,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: view,
                                                  attribute: .height,
                                                  multiplier: 1,
                                                  constant: difference)
        self.superview?.addConstraint(heightConstraint)
        return heightConstraint
    }
    
    @discardableResult
    func matchWidth(to view: UIView, difference: CGFloat = 0) -> NSLayoutConstraint {
        let widthConstraint = NSLayoutConstraint(item: self,
                                                 attribute: .width,
                                                 relatedBy: .equal,
                                                 toItem: view,
                                                 attribute: .width,
                                                 multiplier: 1,
                                                 constant: difference)
        self.superview?.addConstraint(widthConstraint)
        return widthConstraint
    }
    
    @discardableResult
    func addHorizontallyCenteredConstraint(toView view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint {
        let c = NSLayoutConstraint(
            item: self,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: view,
            attribute: NSLayoutConstraint.Attribute.centerX,
            multiplier: 1,
            constant: offset)
        self.superview?.addConstraint(c)
        
        return c
    }
    
    @discardableResult
    func addVerticallyCenteredConstraint(toView view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint {
        let c = NSLayoutConstraint(
            item: self,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerY,
            multiplier: 1,
            constant: offset)
        self.superview?.addConstraint(c)
        
        return c
    }
    
    @discardableResult
    func addHorizontallyCenteredConstraint(_ offset: CGFloat = 0) -> NSLayoutConstraint {
        let c = NSLayoutConstraint(
            item: self,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: self.superview,
            attribute: NSLayoutConstraint.Attribute.centerX,
            multiplier: 1,
            constant: offset)
        self.superview?.addConstraint(c)
        
        return c
    }
    
    @discardableResult
    func addVerticallyCenteredConstraint(_ offset: CGFloat = 0) -> NSLayoutConstraint {
        let c = NSLayoutConstraint(
            item: self,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self.superview,
            attribute: .centerY,
            multiplier: 1,
            constant: offset)
        self.superview?.addConstraint(c)
        
        return c
    }
    
    @discardableResult
    func addHorizontallyAndVerticallyCenteredConstraints(_ offset: CGSize = CGSize.zero) -> [NSLayoutConstraint] {
        let c1 = self.addHorizontallyCenteredConstraint(offset.width)
        let c2 = self.addVerticallyCenteredConstraint(offset.height)
        return [c1, c2]
    }
    
    @discardableResult
    func addFixedWidthConstraint(_ width: CGFloat, priority: UILayoutPriority = UILayoutPriority.required) -> NSLayoutConstraint {
        let c = NSLayoutConstraint(
            item: self,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: width)
        c.priority = priority
        self.addConstraint(c)
        
        return c
    }
    
    @discardableResult
    func addFixedHeightConstraint(_ height: CGFloat) -> NSLayoutConstraint {
        let c = NSLayoutConstraint(
            item: self,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: height)
        self.addConstraint(c)
        
        return c
    }
    
    @discardableResult
    func addFixedSizeConstraint(_ size: CGSize) -> [NSLayoutConstraint] {
        let w = addFixedWidthConstraint(size.width)
        let h = addFixedHeightConstraint(size.height)
        return [w, h]
    }
    
    @discardableResult
    func pinEdgesToSuperview(edges: ViewEdges = .all, padding: UIEdgeInsets = UIEdgeInsets.zero) -> [NSLayoutConstraint] {
        var contraints = [NSLayoutConstraint]()
        if edges.contains(.top) {
            contraints.append(self.pinTopToSuperview(padding.top))
        }
        if edges.contains(.right) {
            contraints.append(self.pinRightToSuperview(padding.right))
        }
        if edges.contains(.bottom) {
            contraints.append(self.pinBottomToSuperview(padding.bottom))
        }
        if edges.contains(.left) {
            contraints.append(self.pinLeftToSuperview(padding.left))
        }
        return constraints
    }
    
    @discardableResult
    func pinTopToSuperview(_ padding: CGFloat = 0, priority: UILayoutPriority = UILayoutPriority.required) -> NSLayoutConstraint {
        let top = NSLayoutConstraint(
            item: self,
            attribute: .top,
            relatedBy: .equal,
            toItem: self.superview,
            attribute: .top,
            multiplier: 1,
            constant: padding)
        top.priority = priority
        self.superview?.addConstraint(top)
        
        return top
    }
    
    @discardableResult
    func pinLeftToSuperview(_ padding: CGFloat = 0, priority: UILayoutPriority = UILayoutPriority.required) -> NSLayoutConstraint {
        let left = NSLayoutConstraint(
            item: self,
            attribute: .left,
            relatedBy: .equal,
            toItem: self.superview,
            attribute: .left,
            multiplier: 1,
            constant: padding)
        left.priority = priority
        self.superview?.addConstraint(left)
        
        return left
    }
    
    @discardableResult
    func pinBottomToSuperview(_ padding: CGFloat = 0, priority: UILayoutPriority = UILayoutPriority.required) -> NSLayoutConstraint {
        let bottom = NSLayoutConstraint(
            item: self,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self.superview,
            attribute: .bottom,
            multiplier: 1,
            constant: -padding)
        self.superview?.addConstraint(bottom)
        
        return bottom
    }
    
    @discardableResult
    func pinRightToSuperview(_ padding: CGFloat = 0, priority: UILayoutPriority = UILayoutPriority.required) -> NSLayoutConstraint {
        let right = NSLayoutConstraint(
            item: self,
            attribute: .right,
            relatedBy: .equal,
            toItem: self.superview,
            attribute: .right,
            multiplier: 1,
            constant: -padding)
        right.priority = priority
        self.superview?.addConstraint(right)
        
        return right
    }
    
    @discardableResult
    func pinRightToViewsLeft(_ view: UIView, padding: CGFloat = 0, priority: UILayoutPriority = UILayoutPriority.required) -> NSLayoutConstraint {
        let right = NSLayoutConstraint(
            item: self,
            attribute: .right,
            relatedBy: .equal,
            toItem: view,
            attribute: .left,
            multiplier: 1,
            constant: padding)
        right.priority = priority
        self.superview?.addConstraint(right)
        return right
    }
    
    @discardableResult
    func pinTopToViewsBottom(_ view: UIView, padding: CGFloat = 0) -> NSLayoutConstraint {
        let top = NSLayoutConstraint(
            item: self,
            attribute: .top,
            relatedBy: .equal,
            toItem: view,
            attribute: .bottom,
            multiplier: 1,
            constant: padding)
        self.superview?.addConstraint(top)
        return top
    }
    
    @discardableResult
    func pinTopToViewsTop(_ view: UIView, padding: CGFloat = 0) -> NSLayoutConstraint {
        let top = NSLayoutConstraint(
            item: self,
            attribute: .top,
            relatedBy: .equal,
            toItem: view,
            attribute: .top,
            multiplier: 1,
            constant: padding)
        self.superview?.addConstraint(top)
        return top
    }
    
    @discardableResult
    func pinBottomToViewsTop(_ view: UIView, padding: CGFloat = 0) -> NSLayoutConstraint {
        let bottom = NSLayoutConstraint(
            item: self,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: view,
            attribute: .top,
            multiplier: 1,
            constant: padding)
        self.superview?.addConstraint(bottom)
        return bottom
    }
    
    @discardableResult
    func pinBottomToViewsBottom(_ view: UIView, padding: CGFloat = 0) -> NSLayoutConstraint {
        let bottom = NSLayoutConstraint(
            item: self,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: view,
            attribute: .bottom,
            multiplier: 1,
            constant: padding)
        self.superview?.addConstraint(bottom)
        return bottom
    }
    
    @discardableResult
    func pinLeftToViewsRight(_ view: UIView, padding: CGFloat = 0, priority: UILayoutPriority = UILayoutPriority.required) -> NSLayoutConstraint {
        let left = NSLayoutConstraint(
            item: self,
            attribute: .left,
            relatedBy: .equal,
            toItem: view,
            attribute: .right,
            multiplier: 1,
            constant: padding)
        self.superview?.addConstraint(left)
        return left
    }
}
