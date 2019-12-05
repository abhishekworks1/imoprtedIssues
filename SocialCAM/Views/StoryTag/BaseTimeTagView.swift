//
//  TimeTagView.swift
//  ProManager
//
//  Created by Jasmin Patel on 10/12/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

enum DateStringType {
    case hour
    case minute
    case ampm
}

class TransparentHalfHoleOverlayView: UIView {
    
    lazy var holeView: UIView = {
        let halfFrame = CGRect(x: 0,
                               y: self.frame.height/2 - 2,
                               width: self.frame.width,
                               height: 4)
        let hView = UIView(frame: halfFrame)
        return hView
    }()
    
    // MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)            // Ensures to use the current background color to set the filling color
        
        self.backgroundColor?.setFill()
        UIRectFill(rect)
        
        let layer = CAShapeLayer()
        let path = CGMutablePath()
        
        // Make hole in view's overlay
        // NOTE: Here, instead of using the transparentHoleView UIView we could use a specific CFRect location instead...
        path.addRect(holeView.frame)
        path.addRect(bounds)
        
        layer.path = path
        layer.fillRule = CAShapeLayerFillRule.evenOdd
        self.layer.mask = layer
    }
    
    override func layoutSubviews () {
        super.layoutSubviews()
    }
    
    // MARK: - Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

class TimeTagView: UIView {
    
    private var date: Date?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(for date: Date) {
        self.init(frame: CGRect.zero)
        self.date = date
        setupViews()
    }
    
    func labelFor(text: String, textAlignment: NSTextAlignment, fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = ApplicationSettings.appWhiteColor
        label.font = UIFont.boldSystemFont(ofSize: fontSize)
        label.textAlignment = textAlignment
        return label
    }
    
    func dateStringFor(type: DateStringType, for date: Date) -> String {
        let formatter = DateFormatter()
        switch type {
        case .hour:
            formatter.dateStyle = .none
            formatter.timeStyle = .full
            formatter.dateFormat = "hh"
        case .minute:
            formatter.dateFormat = "mm"
        case .ampm:
            formatter.dateFormat = "a"
        }
        return formatter.string(from: date)
    }
    
    func setupViews() {
        let label = labelFor(text: "\(dateStringFor(type: .hour, for: self.date ?? Date())):\(dateStringFor(type: DateStringType.minute, for: self.date ?? Date()))", textAlignment: .left, fontSize: 45)
        addSubview(label)
        
        let slabel = labelFor(text: "\(dateStringFor(type: .ampm, for: self.date ?? Date()))", textAlignment: .right, fontSize: 15)
        addSubview(slabel)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        slabel.translatesAutoresizingMaskIntoConstraints = false
        
        slabel.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8).isActive = true
        slabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 5).isActive = true
        slabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class DigitTimeTagView: TransparentHalfHoleOverlayView {
    
    private var date: Date?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(for date: Date) {
        self.init(frame: CGRect.zero)
        self.date = date
        setupViews()
    }
    
    func labelFor(text: String, textAlignment: NSTextAlignment, fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = ApplicationSettings.appWhiteColor
        label.font = UIFont.boldSystemFont(ofSize: fontSize)
        label.textAlignment = textAlignment
        return label
    }
    
    func dateStringFor(type: DateStringType, for date: Date) -> String {
        let formatter = DateFormatter()
        switch type {
        case .hour:
            formatter.dateStyle = .none
            formatter.timeStyle = .full
            formatter.dateFormat = "hh"
        case .minute:
            formatter.dateFormat = "mm"
        case .ampm:
            formatter.dateFormat = "a"
        }
        return formatter.string(from: date)
    }
    
    func getDigitView() -> UIView {
        let firstView = UIView()
        firstView.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
        firstView.clipsToBounds = true
        firstView.layer.cornerRadius = 5.0
        return firstView
    }
    
    func stackViewWith(spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = spacing
        return stackView
    }
    
    func setupViews() {
        let firstDigitView = getDigitView()
        
        let label = labelFor(text: dateStringFor(type: .hour, for: self.date ?? Date())[0], textAlignment: .right, fontSize: 50)
        if label.text == "0" {
            label.isHidden = true
        }
        firstDigitView.addSubview(label)
        
        let slabel = labelFor(text: dateStringFor(type: .ampm, for: self.date ?? Date()), textAlignment: .left, fontSize: 10)
        firstDigitView.addSubview(slabel)
        
        firstDigitView.translatesAutoresizingMaskIntoConstraints = false
        firstDigitView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.trailingAnchor.constraint(equalTo: firstDigitView.trailingAnchor, constant: -5).isActive = true
        label.topAnchor.constraint(equalTo: firstDigitView.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: firstDigitView.bottomAnchor).isActive = true
        
        slabel.translatesAutoresizingMaskIntoConstraints = false
        
        slabel.leadingAnchor.constraint(equalTo: firstDigitView.leadingAnchor, constant: 5).isActive = true
        slabel.bottomAnchor.constraint(equalTo: firstDigitView.bottomAnchor, constant: -5).isActive = true
        
        let firstView2 = getDigitView()
        
        let label2 = labelFor(text: dateStringFor(type: .hour, for: self.date ?? Date())[1], textAlignment: .center, fontSize: 50)
        
        firstView2.addSubview(label2)
        
        firstView2.translatesAutoresizingMaskIntoConstraints = false
        firstView2.widthAnchor.constraint(equalToConstant: 40).isActive = true
        label2.translatesAutoresizingMaskIntoConstraints = false
        
        label2.leadingAnchor.constraint(equalTo: firstView2.leadingAnchor).isActive = true
        label2.trailingAnchor.constraint(equalTo: firstView2.trailingAnchor).isActive = true
        label2.topAnchor.constraint(equalTo: firstView2.topAnchor).isActive = true
        label2.bottomAnchor.constraint(equalTo: firstView2.bottomAnchor).isActive = true
        
        let firstView3 = getDigitView()
        
        let label3 = labelFor(text: dateStringFor(type: .minute, for: self.date ?? Date())[0], textAlignment: .center, fontSize: 50)
        
        firstView3.addSubview(label3)
        firstView3.translatesAutoresizingMaskIntoConstraints = false
        firstView3.widthAnchor.constraint(equalToConstant: 40).isActive = true
        label3.translatesAutoresizingMaskIntoConstraints = false
        
        label3.leadingAnchor.constraint(equalTo: firstView3.leadingAnchor).isActive = true
        label3.trailingAnchor.constraint(equalTo: firstView3.trailingAnchor).isActive = true
        label3.topAnchor.constraint(equalTo: firstView3.topAnchor).isActive = true
        label3.bottomAnchor.constraint(equalTo: firstView3.bottomAnchor).isActive = true
        
        let firstView4 = getDigitView()
        
        let label4 = labelFor(text: dateStringFor(type: .minute, for: self.date ?? Date())[1], textAlignment: .center, fontSize: 50)
        
        firstView4.addSubview(label4)
        firstView4.translatesAutoresizingMaskIntoConstraints = false
        firstView4.widthAnchor.constraint(equalToConstant: 40).isActive = true
        label4.translatesAutoresizingMaskIntoConstraints = false
        
        label4.leadingAnchor.constraint(equalTo: firstView4.leadingAnchor).isActive = true
        label4.trailingAnchor.constraint(equalTo: firstView4.trailingAnchor).isActive = true
        label4.topAnchor.constraint(equalTo: firstView4.topAnchor).isActive = true
        label4.bottomAnchor.constraint(equalTo: firstView4.bottomAnchor).isActive = true
        
        let stackView1 = stackViewWith(spacing: 4)
        stackView1.addArrangedSubview(firstDigitView)
        stackView1.addArrangedSubview(firstView2)
        
        let stackView2 = stackViewWith(spacing: 4)
        stackView2.addArrangedSubview(firstView3)
        stackView2.addArrangedSubview(firstView4)
        
        let stackView = stackViewWith(spacing: 8)
        
        stackView.addArrangedSubview(stackView1)
        stackView.addArrangedSubview(stackView2)
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class AnalogClockHand: UIView {
    // MARK: Public Properties
    
    /// The color of the the hand instance
    var color: UIColor?
    /// The width of the hand instance
    var handWidth: CGFloat = 0.0
    /// The length of the hand instance
    var length: CGFloat = 0.0
    /// The length on the short side of the hand instance.
    var offsetLength: CGFloat = 0.0
    /// Is there a shadow behind the hand
    var shadowEnabled = false
    // The degree the hand should be rotated by.
    var degree: Float = 0.0
    
    var borderWidth: CGFloat = 0.0
    var graduationOffset: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = ApplicationSettings.appClearColor
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        // the frame needs to be drawn as if it is in a cartesian plane,
        // with the center of rotation at what is thought of as (0, 0) and
        // the far end to the top of the center, this way when we rotate
        // the view, it will look correct.
        
        let center: CGPoint = self.center
        
        // point that is the top of the hand (closes to the edge of the clock)
        let top = CGPoint(x: center.x, y: center.y - length)
        
        // point at the bottom of the hand, a total distance offsetLength away from
        // the center of rotation.
        let bottom = CGPoint(x: center.x, y: center.y)
        
        // draw the line from the bottom to the top that has line width self.width.
        let path = UIBezierPath()
        path.lineWidth = handWidth
        path.move(to: bottom)
        path.addLine(to: top)
        color?.set() // sets teh color of the hand to be the color of the path
        path.stroke()
        
    }
    
    func setHandDegree(_ degree: Float) {
        setHandDegree(degree, animated: false)
    }
    
    func setHandDegree(_ degree: Float, animated: Bool) {
        self.degree = degree
        let transform = CGAffineTransform(rotationAngle: CGFloat(self.degree * .pi / 180))
        
        if animated {
            // animate for one second (default best time to animate - for a second hand
            // it will take exactly 1 second to move, and for the other hands it doesn't
            // really matter how long it takes to move.
            UIView.animate(withDuration: 1.0, animations: {
                self.transform = transform
            })
        } else {
            self.transform = transform
        }
    }
    
}

class AnalogClockView: UIView {
    
    public var faceBackgroundColor: UIColor = UIColor.gray.withAlphaComponent(0.4)
    public var faceBackgroundAlpha: CGFloat = 1.0
    
    public var borderColor: UIColor = ApplicationSettings.appWhiteColor
    public var borderWidth: CGFloat = 1.0
    public var borderAlpha: CGFloat = 1.0
    
    public var hubColor: UIColor = ApplicationSettings.appWhiteColor
    public var hubAlpha: CGFloat = 1.0
    public var hubRadius: CGFloat = 3.0
    
    public var graduationColor: UIColor = ApplicationSettings.appWhiteColor
    public var graduationAlpha: CGFloat = 1.0
    public var graduationWidth: CGFloat = 1.0
    public var graduationLength: CGFloat = 5.0
    public var graduationOffset: CGFloat = 10.0
    
    public var digitColor = ApplicationSettings.appWhiteColor
    public var digitFont = UIFont.helveticaNeuethin ?? UIFont.systemFont(ofSize: 17)
    public var digitOffset: CGFloat = 0.0
    
    var hourHand: AnalogClockHand?
    var minuteHand: AnalogClockHand?
    var secondHand: AnalogClockHand?
    
    var hours = 10
    var minutes = 10
    var seconds = 0
    
    var hourHandColor = ApplicationSettings.appWhiteColor
    var hourHandAlpha: CGFloat = 1.0
    var hourHandWidth: CGFloat = 4
    var hourHandLength: CGFloat = 30
    var hourHandOffsideLength: CGFloat = 10
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addHandViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addHandViews()
    }
    
    func degrees(fromHour hour: Int, andMinutes minutes: Int) -> Float {
        let degrees = Float((hour * 30) + (minutes / 10) * 6)
        return degrees
    }
    
    func degrees(fromMinutes minutes: Int) -> Float {
        let degrees = Float(minutes * 6)
        return degrees
    }
    
    func setClockTo(_ time: Date, animated: Bool) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh"
        let currentHour = dateFormatter.string(from: time)
        dateFormatter.dateFormat = "mm"
        let currentMinute = dateFormatter.string(from: time)
        dateFormatter.dateFormat = "ss"
        let currentSecond = dateFormatter.string(from: time)
        
        hours = Int(currentHour) ?? 10
        minutes = Int(currentMinute) ?? 10
        seconds = Int(currentSecond) ?? 0
        
        minuteHand?.setHandDegree(degrees(fromMinutes: minutes), animated: animated)
        hourHand?.setHandDegree(degrees(fromHour: hours, andMinutes: minutes), animated: true)
        secondHand?.setHandDegree(degrees(fromMinutes: seconds), animated: true)
    }
    
    func addHandViews() {
        hourHand = AnalogClockHand(frame: bounds)
        hourHand?.degree = degrees(fromHour: hours, andMinutes: minutes)
        hourHand?.color = hourHandColor
        hourHand?.alpha = hourHandAlpha
        hourHand?.handWidth = hourHandWidth
        hourHand?.length = hourHandLength
        hourHand?.offsetLength = hourHandOffsideLength
        
        minuteHand = AnalogClockHand(frame: bounds)
        minuteHand?.degree = degrees(fromMinutes: minutes)
        minuteHand?.color = hourHandColor
        minuteHand?.alpha = hourHandAlpha
        minuteHand?.handWidth = hourHandWidth*0.75
        minuteHand?.length = hourHandLength*1.5
        minuteHand?.offsetLength = hourHandOffsideLength*2
        if let hourHand = hourHand, let minuteHand = minuteHand {
            addSubview(hourHand)
            addSubview(minuteHand)
        }
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // CLOCK'S FACE
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.addEllipse(in: rect)
        ctx?.setFillColor(faceBackgroundColor.cgColor)
        ctx?.setAlpha(faceBackgroundAlpha)
        ctx?.fillPath()
        
        // CLOCK'S BORDER
        ctx?.addEllipse(in: CGRect(x: rect.origin.x + borderWidth/2,
                                   y: rect.origin.y + borderWidth/2,
                                   width: rect.size.width - borderWidth,
                                   height: rect.size.height - borderWidth))
        ctx?.setStrokeColor(borderColor.cgColor)
        ctx?.setAlpha(borderAlpha)
        ctx?.setLineWidth(borderWidth)
        ctx?.strokePath()
        
        // HUB
        ctx?.setFillColor(hubColor.cgColor)
        ctx?.setAlpha(hubAlpha)
        let center = CGPoint(x: frame.size.width/2,
                             y: frame.size.height/2)
        ctx?.addArc(center: CGPoint(x: center.x, y: center.y),
                    radius: hubRadius,
                    startAngle: 0,
                    endAngle: 2*CGFloat.pi,
                    clockwise: false)
        ctx?.fillPath()
        
        // CLOCK'S GRADUATION
        for index in 0..<60 {
            
            let P1 = CGPoint(x: (frame.size.width/2 + ((frame.size.width - borderWidth*2 - graduationOffset) / 2) * cos((6 * CGFloat(index))*(CGFloat.pi/180) - ((CGFloat.pi/2)))),
                             y: frame.size.width/2 + ((frame.size.width - borderWidth*2 - graduationOffset) / 2) * sin((6*CGFloat(index))*(CGFloat.pi/180) - (CGFloat.pi/2)))
            
            let P2 = CGPoint(x: frame.size.width/2 + ((frame.size.width - borderWidth*2 - graduationOffset - graduationLength) / 2) * cos((6*CGFloat(index))*(CGFloat.pi/180) - (CGFloat.pi/2)),
                             y: frame.size.width/2 + ((frame.size.width - borderWidth*2 - graduationOffset - graduationLength) / 2) * sin((6 * CGFloat(index))*(CGFloat.pi/180) - (CGFloat.pi/2)))
            
            let shapeLayer = CAShapeLayer()
            let path1 = UIBezierPath()
            shapeLayer.path = path1.cgPath
            path1.lineWidth = graduationWidth
            path1.move(to: P1)
            path1.addLine(to: P2)
            path1.lineCapStyle = .square
            graduationColor.set()
            path1.stroke(with: .normal, alpha: graduationAlpha)
            
        }
        
        // DIGIT DRAWING
        let markingDistanceFromCenter = rect.size.width/2 - digitFont.lineHeight/4 - 5 + digitOffset
        
        let offset: CGFloat = 4
        
        for index in 0..<12 {
            
            let hourNumber = "\("\(index + 1 < 10 ? " " : "")")\(index + 1)"
            
            let labelX = center.x + (markingDistanceFromCenter - digitFont.lineHeight/2) * cos((CGFloat.pi/180) * CGFloat((CGFloat(index) + offset)) * 30 + CGFloat.pi)
            
            let labelY = center.y + -1 * (markingDistanceFromCenter - digitFont.lineHeight/2) * sin((CGFloat.pi/180) * (CGFloat(index)+offset) * 30)
            
            hourNumber.draw(in: CGRect(x: labelX - digitFont.lineHeight / 2.0,
                                       y: labelY - digitFont.lineHeight / 2.0,
                                       width: digitFont.lineHeight,
                                       height: digitFont.lineHeight),
                            
                            withAttributes: [NSAttributedString.Key.foregroundColor: digitColor,
                                             NSAttributedString.Key.font: digitFont])
            
        }
    }
    
}

class BaseTimeTagView: BaseStoryTagView {
    
    var date: Date?
    
    convenience init(date: Date) {
        self.init(frame: CGRect.zero)
        self.date = date
        onFirstTap()
    }
    
    func refreshLayout() {
        let timeViews = self.subviews.filter({ $0 is DigitTimeTagView || $0 is TimeTagView || $0 is AnalogClockView })
        for view in timeViews {
            view.removeFromSuperview()
        }
    }
    
    override func onTapWith(_ tapCount: Int) {
        super.onTapWith(tapCount)
        if self.tapCount % 3 == 1 {
            onFirstTap()
        } else if self.tapCount % 3 == 2 {
            onSecondTap()
        } else if self.tapCount % 3 == 0 {
            onThirdTap()
        }
    }
    
    func onFirstTap() {
        refreshLayout()
        let aView = DigitTimeTagView.init(for: self.date ?? Date())
        aView.backgroundColor = ApplicationSettings.appClearColor
        self.insertSubview(aView, at: 0)
        aView.translatesAutoresizingMaskIntoConstraints = false
        aView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        aView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        aView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        aView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        aView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func onSecondTap() {
        refreshLayout()
        let aView = AnalogClockView.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 150, height: 150)))
        aView.setClockTo(self.date ?? Date(), animated: false)
        aView.backgroundColor = ApplicationSettings.appClearColor
        self.insertSubview(aView, at: 0)
        aView.translatesAutoresizingMaskIntoConstraints = false
        aView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        aView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        aView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        aView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        aView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        aView.widthAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func onThirdTap() {
        refreshLayout()
        let aView = TimeTagView.init(for: self.date ?? Date())
        aView.backgroundColor = ApplicationSettings.appClearColor
        self.insertSubview(aView, at: 0)
        aView.translatesAutoresizingMaskIntoConstraints = false
        aView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        aView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        aView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        aView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        aView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}
