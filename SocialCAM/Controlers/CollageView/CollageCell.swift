//
//  CollageCell.swift
//  CollageView
//
//  Created by Viraj Patel on 11/03/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

class CollageCell: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    var id: Int = 0
    weak var delegate: CollageCellDelegate?
    var isSelected: Bool = false {
        didSet {
            for lh in self.lineHandles {
                lh.isHidden = !self.isSelected
            }
            self.borderLayer.isHidden = !self.isSelected
        }
    }
    
    var lineHandles: [LineHandleView] = []
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(detectTap(_:)))
        return tapGesture
    }()
    
    private lazy var borderLayer: UIView = {
        let view = UIView(frame: self.bounds)
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ApplicationSettings.appClearColor
        view.isHidden = true
        self.addSubview(view)
        
        let xConst = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let yConst = NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let wConst = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let hConst = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        view.layer.borderColor = ApplicationSettings.appLightGrayColor.cgColor
        view.layer.borderWidth = 3.0
        NSLayoutConstraint.activate([xConst, yConst, wConst, hConst])
        
        return view
    }()
    
    lazy var photoView: PhotoScrollView = {
        
        let view = PhotoScrollView(frame: self.bounds)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        
        let xConst = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let yConst = NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let wConst = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let hConst = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([xConst, yConst, wConst, hConst])
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.id = 10
        _ = self.photoView
        self.translatesAutoresizingMaskIntoConstraints = true
        self.backgroundColor = ApplicationSettings.appLightGrayColor
        self.addGestureRecognizer(self.tapGesture)
        photoView.photoImage.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    convenience init(id: Int) {
        self.init(frame: .zero)
        self.id = id
        _ = self.photoView
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = ApplicationSettings.appLightGrayColor
        self.addGestureRecognizer(self.tapGesture)
        self.clipsToBounds = true
        photoView.photoImage.clipsToBounds = true
    }
    
    func setHandles(handles: [LineHandleView]) {
        self.lineHandles.removeAll()
        self.lineHandles += handles
    }
    
    @objc func detectTap(_ gesture: UITapGestureRecognizer) {
        self.delegate?.didSelectCell(cellId: id)
    }
   
    func drawRoundedBorder(width: CGFloat, height: CGFloat, cornerRadius: Float = 0, lineWidth: CGFloat, sides: Int = 6, type: ShapeType) -> CAShapeLayer {
        let borderLayer = CAShapeLayer()
        let crect = CGRect(x: 0, y: 0, width: width, height: height)
        
        let path = roundedPolygonPathWithRect(square: crect, lineWidth: 0, sides: sides, cornerRadius: cornerRadius, type: type)
        switch type {
        case .heart:
            borderLayer.name = "heartBorderLayer"
            break
        case .hexa:
            borderLayer.name = "hexaBorderLayer"
            break
        case .star:
            borderLayer.name = "starBorderLayer"
            break
        }
        borderLayer.path = path.cgPath
        borderLayer.lineWidth = lineWidth
        borderLayer.strokeColor = ApplicationSettings.appWhiteColor.cgColor
        borderLayer.fillColor = ApplicationSettings.appClearColor.cgColor
        borderLayer.borderWidth = 0
        return borderLayer
    }

    func drawRoundedHex(width: CGFloat, height: CGFloat, cornerRadius: Float = 0, sides: Int = 6, shapeMask: Bool = true, type: ShapeType) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        let crect = CGRect(x: 0, y: 0, width: width, height: height)
       
        let path = roundedPolygonPathWithRect(square: crect, lineWidth: 0, sides: sides, cornerRadius: cornerRadius, type: type)
        switch type {
        case .heart:
            shapeLayer.name = "heart"
        case .hexa:
            shapeLayer.name = "hexa"
        case .star:
            shapeLayer.name = "star"
        }
       
        shapeLayer.path = path.cgPath
        if shapeMask {
            shapeLayer.fillRule = CAShapeLayerFillRule.nonZero
        } else {
            shapeLayer.lineWidth = 4
            shapeLayer.strokeColor = ApplicationSettings.appWhiteColor.cgColor
            shapeLayer.fillColor = ApplicationSettings.appClearColor.cgColor
        }
        return shapeLayer
    }
    
    func roundedPolygonPathWithRect(square: CGRect, lineWidth: Float, sides: Int, cornerRadius: Float, type: ShapeType) -> UIBezierPath {
        let path = UIBezierPath()
        if type == .hexa {
            let scaledWidth = (square.size.width * CGFloat(1))
            let scaledXValue = ((square.size.width) - scaledWidth) / 2
            let scaledHeight = (square.size.height * CGFloat(1))
            let scaledYValue = ((square.size.height) - scaledHeight) / 2
            let scaledRect = CGRect(x: scaledXValue, y: scaledYValue, width: scaledWidth, height: scaledHeight)
            let center = CGPoint(x: square.width/2, y: square.height/2)
            var angle = CGFloat( Double.pi / 2.0 )
            let angleCounter = CGFloat( Double.pi * 2.0 / Double(sides) )
            let radius = min(scaledRect.size.width/2, scaledRect.size.height/2)
          
            path.move(to: CGPoint(x: radius * cos(angle) + center.x, y: radius * sin(angle) + center.y))
            for _ in 1...sides {
                angle += angleCounter
                path.addLine(to: CGPoint(x: radius * cos(angle) + center.x, y: radius * sin(angle) + center.y))
            }
            path.close()
            
        } else if type == .heart {
            let scaledWidth = (square.size.width * CGFloat(1))
            let scaledXValue = ((square.size.width) - scaledWidth) / 2
            let scaledHeight = (square.size.height * CGFloat(1))
            let scaledYValue = ((square.size.height) - scaledHeight) / 2
            
            let scaledRect = CGRect(x: scaledXValue, y: scaledYValue, width: scaledWidth, height: scaledHeight)
            
            path.move(to: CGPoint(x: square.size.width/2, y: scaledRect.origin.y + scaledRect.size.height))
            
            path.addCurve(to: CGPoint(x: scaledRect.origin.x, y: scaledRect.origin.y + (scaledRect.size.height/4)),
                          controlPoint1: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width/2), y: scaledRect.origin.y + (scaledRect.size.height*3/4)) ,
                          controlPoint2: CGPoint(x: scaledRect.origin.x, y: scaledRect.origin.y + (scaledRect.size.height/2)) )
            
            path.addArc(withCenter: CGPoint( x: scaledRect.origin.x + (scaledRect.size.width/4), y: scaledRect.origin.y + (scaledRect.size.height/4)),
                        radius: (scaledRect.size.width/4),
                        startAngle: CGFloat(Double.pi),
                        endAngle: 0,
                        clockwise: true)
            
            path.addArc(withCenter: CGPoint( x: scaledRect.origin.x + (scaledRect.size.width * 3/4), y: scaledRect.origin.y + (scaledRect.size.height/4)),
                        radius: (scaledRect.size.width/4),
                        startAngle: CGFloat(Double.pi),
                        endAngle: 0,
                        clockwise: true)
            
            path.addCurve(to: CGPoint(x: square.size.width/2, y: scaledRect.origin.y + scaledRect.size.height),
                          controlPoint1: CGPoint(x: scaledRect.origin.x + scaledRect.size.width, y: scaledRect.origin.y + (scaledRect.size.height/2)),
                          controlPoint2: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width/2), y: scaledRect.origin.y + (scaledRect.size.height*3/4)) )
            
            path.close()
        } else if type == .star {
            return UIBezierPath().getStars(square, scale: 1, corners: 5, extrusion: 50)
        }
        return path
    }
}

public extension UIBezierPath {
    
    func getPolygon(_ originalRect: CGRect, scale: Double, sides: Int) -> UIBezierPath {
        let scaledWidth = (originalRect.size.width * CGFloat(scale))
        let scaledXValue = ((originalRect.size.width) - scaledWidth) / 2
        let scaledHeight = (originalRect.size.height * CGFloat(scale))
        let scaledYValue = ((originalRect.size.height) - scaledHeight) / 2
        let scaledRect = CGRect(x: scaledXValue, y: scaledYValue, width: scaledWidth, height: scaledHeight)
        drawPolygon(originalRect, scaledRect: scaledRect, sides: sides)
        return self
    }
    
    func drawPolygon(_ originalRect: CGRect, scaledRect: CGRect, sides: Int) {
        let center = CGPoint(x: originalRect.width/2, y: originalRect.height/2)
        var angle = CGFloat( Double.pi / 2.0 )
        let angleCounter = CGFloat( Double.pi * 2.0 / Double(sides) )
        let radius = min(scaledRect.size.width/2, scaledRect.size.height/2)
        self.move(to: CGPoint(x: radius * cos(angle) + center.x, y: radius * sin(angle) + center.y))
        for _ in 1...sides {
            angle += angleCounter
            self.addLine(to: CGPoint(x: radius * cos(angle) + center.x, y: radius * sin(angle) + center.y))
        }
        self.close()
    }
}

extension Int {
    var degreesToRadians: CGFloat { return CGFloat(self) * .pi / 180 }
}

extension UIBezierPath {
    
    convenience init(heartIn rect: CGRect) {
        self.init()
        //Calculate Radius of Arcs
        let sideOne = rect.width * 0.4
        let sideTwo = rect.height * 0.3
        let arcRadius = sqrt(sideOne*sideOne + sideTwo*sideTwo)/2
        //Left Hand Curve
        self.addArc(withCenter: CGPoint(x: rect.width * 0.3, y: rect.height * 0.35), radius: arcRadius, startAngle: 135.degreesToRadians, endAngle: 315.degreesToRadians, clockwise: true)
        //Top Centre Dip
        self.addLine(to: CGPoint(x: rect.width/2, y: rect.height * 0.2))
        //Right Hand Curve
        self.addArc(withCenter: CGPoint(x: rect.width * 0.7, y: rect.height * 0.35), radius: arcRadius, startAngle: 225.degreesToRadians, endAngle: 45.degreesToRadians, clockwise: true)
        //Right Bottom Line
        self.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.95))
        //Left Bottom Line
        self.close()
    }
    
}

public extension UIBezierPath {
    
    func getStars(_ originalRect: CGRect, scale: Double, corners: Int, extrusion: Int) -> UIBezierPath {
        let scaledWidth = (originalRect.size.width * CGFloat(scale))
        let scaledXValue = ((originalRect.size.width) - scaledWidth) / 2
        let scaledHeight = (originalRect.size.height * CGFloat(scale))
        let scaledYValue = ((originalRect.size.height) - scaledHeight) / 2
        let scaledRect = CGRect(x: scaledXValue, y: scaledYValue, width: scaledWidth, height: scaledHeight)
        drawStars(originalRect, scaledRect: scaledRect, corners: corners, extrusion: extrusion)
        return self
    }
    
    func drawStars(_ originalRect: CGRect, scaledRect: CGRect, corners: Int, extrusion: Int) {
       
        let center = CGPoint(x: originalRect.width/2, y: originalRect.height/2)
        var angle = -CGFloat( Double.pi / 2.0 )
        let angleCounter = CGFloat( Double.pi * 2.0 / Double(corners * 2) )
        let radius = min(scaledRect.size.width/2, scaledRect.size.height/2)
        let extrusion = radius * CGFloat(extrusion) / 100
        self.move(to: CGPoint(x: radius * cos(angle) + center.x, y: radius * sin(angle) + center.y))
        for index in 1...(corners * 2) {
            if index % 2 != 0 {
                self.addLine(to: CGPoint(x: radius * cos(angle) + center.x, y: radius * sin(angle) + center.y))
            } else {
                self.addLine(to: CGPoint(x: extrusion * cos(angle) + center.x, y: extrusion * sin(angle) + center.y))
            }
            angle += angleCounter
        }
        self.close()
    }
}
