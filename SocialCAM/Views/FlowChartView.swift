//
//  FlowChartView.swift
//  VideoSpeeder
//
//  Created by Jasmin Patel on 13/02/19.
//  Copyright © 2019 Simform. All rights reserved.
//

import Foundation
import UIKit

class DashedLineView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addDashedLine()
    }
    
    private func addDashedLine() {
        _ = layer.sublayers?.filter({ $0.name == "DashedTopLine" }).map({ $0.removeFromSuperlayer() })
        backgroundColor = ApplicationSettings.appClearColor
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "DashedTopLine"
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        shapeLayer.fillColor = ApplicationSettings.appClearColor.cgColor
        shapeLayer.strokeColor = ApplicationSettings.appWhiteColor.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [4, 4]
        
        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: frame.width, y: 0))
        shapeLayer.path = path
        
        layer.addSublayer(shapeLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class FlowDotView: UIView {
    
    public var speedLabel: UILabel
    public var speedValue: Int = 1 {
        didSet {
            speedLabel.text = "\(speedValue)x"
        }
    }
    
    override init(frame: CGRect) {
        speedLabel = UILabel.init(frame: CGRect.init(origin: CGPoint.zero, size: frame.size))
        super.init(frame: frame)
        setupLabel()
        self.addSubview(speedLabel)
        setupLayer()
    }
    
    private func setupLabel() {
        self.speedLabel.layer.cornerRadius = frame.width/2
        self.speedLabel.textAlignment = .center
        self.speedLabel.textColor = ApplicationSettings.appBlackColor
        self.speedLabel.font = UIFont.systemFont(ofSize: 12)
        self.speedLabel.text = "\(speedValue)x"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayer() {
        self.layer.cornerRadius = self.frame.width/2
        self.backgroundColor = UIColor.yellow
        self.dropBackgroundColorShadow()
    }
    
    public func dropBackgroundColorShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = self.backgroundColor?.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 9
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
}

class VideoSpeedPoint: CustomStringConvertible {
    
    var xValue: CGFloat
    var yValue: CGFloat
    var value: Int
    
    init(xValue: CGFloat, yValue: CGFloat, value: Int) {
        self.xValue = xValue
        self.yValue = yValue
        self.value = value
    }
    
    var description: String {
        return "\n======\n========\nx: \(xValue)\ny: \(yValue)\nvalue: \(value)"
    }
    
}

class VideoSpeedValue: CustomStringConvertible {
    
    var duration: Double
    var value: Int
    
    init(duration: Double, value: Int) {
        self.duration = duration
        self.value = value
    }
    
    var description: String {
        return "\n======\n========\nduration: \(duration)\nvalue: \(value)"
    }
    
}

protocol FlowChartViewDelegate: class {
    func didStartDragging()
    func didStopDragging()
    func shouldAddPoint() -> Bool
    func didAddPoint()
    func longPressOnPoint(view: FlowDotView)
    func didExceedMaximumNumberOfSpeedPoint()
}

extension FlowChartViewDelegate {
    func didExceedMaximumNumberOfSpeedPoint() { }
}

class FlowChartView: UIView {
    fileprivate var firstDotView: FlowDotView?
    fileprivate var lastDotView: FlowDotView?
    private var dotViews: [FlowDotView] = []
    private var centerLineView: DashedLineView?
    
    private var maxValue: Int = 5
    private var middlePartValue: Int = 3
    private let dotViewWidth: CGFloat = 30
    
    // Gradient background
    private var maskLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()
    // Gradient curve line
    private let pathMaskLayer = CAShapeLayer()
    private var pathGradiantLayer = CAGradientLayer()
    
    public weak var delegate: FlowChartViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        // add center Line
        centerLineView = DashedLineView(frame: CGRect(x: 0,
                                                      y: self.frame.height/2,
                                                      width: self.frame.width,
                                                      height: 1))
        self.addSubview(centerLineView!)
        
        // add first and last dot view
        firstDotView = FlowDotView(frame: CGRect(origin: CGPoint(x: 0, y: self.frame.height/2 - dotViewWidth/2),
                                                 size: CGSize(width: dotViewWidth, height: dotViewWidth)))
        firstDotView?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:))))
        self.addSubview(firstDotView!)
        
        lastDotView = FlowDotView(frame: CGRect(origin: CGPoint(x: self.frame.width - dotViewWidth,
                                                                y: self.frame.height/2 - dotViewWidth/2),
                                                size: CGSize(width: dotViewWidth,
                                                             height: dotViewWidth)))
        lastDotView?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:))))
        self.addSubview(lastDotView!)
        
        dotViews.append(firstDotView!)
        dotViews.append(lastDotView!)
        
        // for add new dot view
        let longPressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPressGesture(_:)))
        longPressGesture.minimumPressDuration = 0.5
        self.addGestureRecognizer(longPressGesture)
        
        setNeedsDisplay()
    }
    
    fileprivate func addDotViewAt(_ origin: CGPoint) {
        let dotView = FlowDotView(frame: CGRect(origin: origin, size: CGSize(width: dotViewWidth, height: dotViewWidth)))
        dotView.center = origin
        dotView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:))))
        let longPressGestureDotView = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPressGestureForPoint(_:)))
        longPressGestureDotView.minimumPressDuration = 0.5
        dotView.addGestureRecognizer(longPressGestureDotView)
        self.addSubview(dotView)
        // scale view
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
        let previouTransform = dotView.transform
        UIView.animate(withDuration: 0.2,
                       animations: {
                        dotView.transform = dotView.transform.scaledBy(x: 3.0, y: 3.0)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.2) {
                            dotView.transform  = previouTransform
                        }
        })
        dotViews.append(dotView)
        checkYValue(yValue: origin.y, for: dotView)
        setNeedsDisplay()
    }
    
    fileprivate func checkYValue(yValue: CGFloat, for view: FlowDotView) {
        let totalPart = self.frame.height
        let maxValuePart = totalPart/CGFloat(maxValue)
        var bgColor = UIColor.yellow
        var value = 1
        for index in 0..<maxValue {
            if yValue >= maxValuePart*CGFloat(index),
                yValue <= maxValuePart*CGFloat(index+1) {
                if index+1 > middlePartValue {
                    bgColor = .red
                    value = -(index+maxValue)/middlePartValue
                } else if index+1 < middlePartValue {
                    bgColor = .green
                    value = -(index-middlePartValue)
                }
                break
            }
        }
        view.speedValue = value
        view.backgroundColor = bgColor
        view.dropBackgroundColorShadow()
    }
   
    func removeDotView(view: FlowDotView) {
        let index = dotViews.firstIndex { (dotView) -> Bool in
            return dotView == view
        }
        if let index = index {
            dotViews.remove(at: index)
        }
        view.removeFromSuperview()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        dotViews = dotViews.sorted(by: { (dotView1, dotView2) -> Bool in
            return dotView1.center.x < dotView2.center.x
        })
        var points = [CGPoint]()
        for dotView in dotViews {
            points.append(dotView.center)
        }
        if let curvePath = self.getCurvePath(for: points) {
            // Gradient background in curve path
            let gradientColors = [UIColor.init(red: 19/255.0, green: 66/255.0, blue: 88/255.0, alpha: 1.0).withAlphaComponent(0.8).cgColor,
                                  UIColor.init(red: 40/255.0, green: 135/255.0, blue: 155/255.0, alpha: 1.0).withAlphaComponent(0.8).cgColor]
            maskLayer.strokeColor = ApplicationSettings.appClearColor.cgColor
            maskLayer.fillColor = ApplicationSettings.appBlackColor.cgColor
            
            gradientLayer.frame = self.bounds
            gradientLayer.mask = maskLayer
            gradientLayer.colors = gradientColors
            gradientLayer.locations = [NSNumber(value: 0.0),
                                       NSNumber(value: 0.95)]
            
            if gradientLayer.superlayer == nil {
                self.layer.insertSublayer(gradientLayer, at: 0)
            }
            
            let gradientPath = UIBezierPath(cgPath: curvePath.cgPath)
            gradientPath.addLine(to: CGPoint(x: self.frame.width, y: points.last!.y))
            gradientPath.addLine(to: CGPoint(x: self.frame.width, y: 0))
            gradientPath.addLine(to: CGPoint(x: 0, y: 0))
            gradientPath.addLine(to: CGPoint(x: 0, y: points.first!.y))
            gradientPath.addLine(to: points.first!)
            
            maskLayer.path = gradientPath.cgPath
            
            // Gradient curve line
            pathMaskLayer.fillColor = nil
            pathMaskLayer.strokeColor = ApplicationSettings.appBlackColor.cgColor
            pathMaskLayer.lineWidth = 3.0
            pathMaskLayer.fillRule = CAShapeLayerFillRule.evenOdd
            pathMaskLayer.path =  curvePath.cgPath
            
            pathGradiantLayer.frame = self.bounds
            pathGradiantLayer.mask = pathMaskLayer
            pathGradiantLayer.colors = [UIColor.green.cgColor,
                                        UIColor.yellow.cgColor,
                                        UIColor.red.cgColor]
            pathGradiantLayer.locations = [NSNumber(value: 0.0),
                                           NSNumber(value: 0.45),
                                           NSNumber(value: 0.95)]
            
            if pathGradiantLayer.superlayer == nil {
                self.layer.insertSublayer(pathGradiantLayer, at: 1)
            }
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews as [UIView] {
            if !subview.isHidden && subview.alpha > 0 && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return super.point(inside: point, with: event)
    }
    
    private func getCurvePath(for points: [CGPoint]) -> UIBezierPath? {
        guard !points.isEmpty else {
            return nil
        }
        let path = UIBezierPath()
        let firstIndex = 1
        let lastIndex = points.count
        var currentPoint = points[0]
        var newPoint = CGPoint.zero

        path.move(to: currentPoint)
        
        for index in stride(from: firstIndex, to: lastIndex, by: 1) {
            var controlPointPre: CGPoint = .zero
            var controlPointSub: CGPoint = .zero
            
            newPoint = points[index]
            
            let midPoint = CGPoint(x: (currentPoint.x + newPoint.x)/2.0,
                                   y: (currentPoint.y + newPoint.y)/2.0)
            
            if currentPoint.y > newPoint.y {
                let yValue =  currentPoint.y > midPoint.y ? currentPoint.y : midPoint.y
                let xValue = (currentPoint.x + midPoint.x)/2.0
                controlPointPre = CGPoint(x: xValue, y: yValue)
                
                let y1 = midPoint.y > newPoint.y ? newPoint.y : midPoint.y
                let x1 = (midPoint.x + newPoint.x)/2.0
                controlPointSub = CGPoint(x: x1, y: y1)
            } else {
                let y1 = currentPoint.y > midPoint.y ? midPoint.y : currentPoint.y
                let x1 = (currentPoint.x + midPoint.x)/2.0
                controlPointPre = CGPoint(x: x1, y: y1)
                
                let yValue =  midPoint.y > newPoint.y ? midPoint.y : newPoint.y
                let xValue = (midPoint.x + newPoint.x)/2.0
                controlPointSub = CGPoint(x: xValue, y: yValue)
            }
            
            path.addCurve(to: newPoint,
                          controlPoint1: controlPointPre,
                          controlPoint2: controlPointSub)
            
            currentPoint = newPoint
        }
        return path
    }
    
    public func getSpeedValues() -> [VideoSpeedPoint] {
        var speedValues = [VideoSpeedPoint]()
        for dotView in dotViews {
            speedValues.append(VideoSpeedPoint(xValue: dotView.center.x,
                                               yValue: dotView.center.y,
                                               value: dotView.speedValue))
        }
        return speedValues
    }
}
// MARK: Handle Gesture
extension FlowChartView {
    @objc fileprivate func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            delegate?.didStartDragging()
        }
        if gesture.state == .began || gesture.state == .changed {
            let translation = gesture.translation(in: self)
            var convertedPoint = CGPoint(x: gesture.view!.center.x + translation.x, y: gesture.view!.center.y + translation.y)
            if gesture.view! == firstDotView! || gesture.view! == lastDotView! {
                convertedPoint = CGPoint(x: gesture.view!.center.x, y: gesture.view!.center.y + translation.y)
            }
            if convertedPoint.x < 15 || convertedPoint.y < 0 {
                return
            }
            if convertedPoint.x > self.bounds.width - 15 || convertedPoint.y > self.bounds.height {
                return
            }
            gesture.view!.center = convertedPoint
            gesture.setTranslation(CGPoint.zero, in: self)
            if let dView = gesture.view as? FlowDotView {
                checkYValue(yValue: convertedPoint.y, for: dView)
            }
        }
        if gesture.state == .ended {
            delegate?.didStopDragging()
        }
        setNeedsDisplay()
    }
    
    @objc fileprivate func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        guard let shouldAddPoint = delegate?.shouldAddPoint(),
            shouldAddPoint else {
                delegate?.didExceedMaximumNumberOfSpeedPoint()
                return
        }
        if gesture.state == .began {
            let locationPoint = gesture.location(in: self)
            print(locationPoint)
            addDotViewAt(locationPoint)
            gesture.isEnabled = false
            gesture.isEnabled = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                self.delegate?.didAddPoint()
            }
        }
    }
    
    @objc fileprivate func handleLongPressGestureForPoint(_ gesture: UILongPressGestureRecognizer) {
        guard let dotView = gesture.view as? FlowDotView else {
            return
        }
        if gesture.state == .began {
            gesture.isEnabled = false
            gesture.isEnabled = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                self.delegate?.longPressOnPoint(view: dotView)
            }
        }
    }
}
