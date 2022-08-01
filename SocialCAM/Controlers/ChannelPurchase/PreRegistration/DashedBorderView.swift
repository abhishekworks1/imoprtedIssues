//
//  myView.swift
//  ProManager
//
//  Created by Steffi Pravasi on 20/08/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit

@IBDesignable class DashedBorderView: UIView {

    @IBInspectable var heightVw: CGFloat = 0
    
        var shapeLayer : CAShapeLayer {
            let shape = self.layer as! CAShapeLayer
            let shapeRect = CGRect(x: 1, y: 1, width: self.frame.width - 1, height: 120 - 1)
            shape.bounds = shapeRect
            shape.strokeColor = ApplicationSettings.appBlackColor.cgColor
            shape.lineDashPattern = [3, 3]
            shape.frame = self.bounds
            shape.fillColor = #colorLiteral(red: 0.2901960784, green: 0.5647058824, blue: 0.8862745098, alpha: 1)
            shape.strokeColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            shape.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 5).cgPath
            return shape
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            shapeLayer.frame = self.frame
        }
    
        override func layoutSubviews() {
            super.layoutSubviews()
            shapeLayer.frame = self.frame
        }
    
        override open class var layerClass: AnyClass {
            return CAShapeLayer.self
        }

}

@IBDesignable class DashedQuizBorderView: UIView {
    
    @IBInspectable var dashHeight: CGFloat = 2 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var dashColor: UIColor = ApplicationSettings.appBlackColor {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        addDashedBorder()
    }
    
    func addDashedBorder() {
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = ApplicationSettings.appClearColor.cgColor
        shapeLayer.strokeColor = dashColor.cgColor
        shapeLayer.lineWidth = dashHeight
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [6,3]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
    
}
