//
//  CropMaskProtocol.swift
//  Mantis
//
//  Created by Echo on 10/22/18.
//  Copyright © 2018 Echo. All rights reserved.
//

import UIKit

private let minOverLayerUnit: CGFloat = 30
private let initialFrameLength: CGFloat = 1000

protocol CropMaskProtocol where Self: UIView {
    func initialize()
    func setMask()
    func adaptMaskTo(match cropRect: CGRect)
}

extension CropMaskProtocol {
    func initialize() {
        setInitialFrame()
        setMask()
    }
    
    private func setInitialFrame() {
        let width = initialFrameLength
        let height = initialFrameLength
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let x = (screenWidth - width) / 2
        let y = (screenHeight - height) / 2
        
        self.frame = CGRect(x: x, y: y, width: width, height: height)
    }
    
    func adaptMaskTo(match cropRect: CGRect) {
        let scaleX = cropRect.width / minOverLayerUnit
        let scaleY = cropRect.height / minOverLayerUnit

        transform = CGAffineTransform(scaleX: scaleX, y: scaleY)

        self.frame.origin.x = cropRect.midX - self.frame.width / 2
        self.frame.origin.y = cropRect.midY - self.frame.height / 2
    }
    
    func createOverLayer(opacity: Float) -> CAShapeLayer {
        let x = bounds.midX - minOverLayerUnit / 2
        let y = bounds.midY - minOverLayerUnit / 2
        let initialRect = CGRect(x: x, y: y, width: minOverLayerUnit, height: minOverLayerUnit)
        
        let path = UIBezierPath(rect: self.bounds)
        let innerPath = UIBezierPath(rect: initialRect)
        path.append(innerPath)
        path.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = UIColor.black.cgColor
        fillLayer.opacity = opacity
        return fillLayer
    }
}
