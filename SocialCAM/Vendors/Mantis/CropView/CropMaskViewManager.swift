//
//  CropMaskViewManager.swift
//  Mantis
//
//  Created by Echo on 10/28/18.
//  Copyright © 2018 Echo. All rights reserved.
//

import UIKit

class CropMaskViewManager {
    fileprivate var dimmingView: CropDimmingView!
    fileprivate var visualEffectView: CropVisualEffectView!

    init(with superview: UIView) {
        setup(in: superview)
    }
    
    private func setupOverlayView(in view: UIView) {
        dimmingView = CropDimmingView()
        dimmingView.isUserInteractionEnabled = false
        dimmingView.alpha = 1
        view.addSubview(dimmingView)
    }
    
    private func setupTranslucencyView(in view: UIView) {
        visualEffectView = CropVisualEffectView()
        visualEffectView.isUserInteractionEnabled = false
        view.addSubview(visualEffectView)
    }

    func setup(in view: UIView) {
        setupOverlayView(in: view)
        setupTranslucencyView(in: view)
    }
    
    func removeMaskViews() {
        dimmingView.removeFromSuperview()
        visualEffectView.removeFromSuperview()
    }
    
    func bringMaskViewsToFront() {
        dimmingView.superview?.bringSubviewToFront(dimmingView)
        visualEffectView.superview?.bringSubviewToFront(visualEffectView)
    }
    
    func showDimmingBackground() {
        UIView.animate(withDuration: 0.1) {
            self.dimmingView.alpha = 1
            self.visualEffectView.alpha = 0
        }
    }
    func hideBackground() {
        UIView.animate(withDuration: 0.1) {
            self.dimmingView.alpha = 1
            self.visualEffectView.alpha = 0
        }
    }
    func setVisualEffectBGColor(color:UIColor,opacity:Float) {
        if opacity == 1.0{
            hideBackground()
        }else{
            self.dimmingView.alpha = 0
            self.visualEffectView.alpha = 1
        }
        if let sublayers = self.dimmingView.layer.sublayers{
            for layer in sublayers{
                if let prevLayer = layer as? CAShapeLayer{
                    let shapeLayer = CAShapeLayer()
                    shapeLayer.path = prevLayer.path
                    shapeLayer.fillColor = color.cgColor
                    shapeLayer.fillRule = .evenOdd
                    shapeLayer.opacity = opacity
                    prevLayer.removeFromSuperlayer()
                    self.dimmingView.layer.addSublayer(shapeLayer)
                }
            }
        }
    }
    func showVisualEffectBackground() {
        //this should not call incase color is selected
        if Defaults.shared.enableBlurVideoBackgroud{
            UIView.animate(withDuration: 0.5) {
                self.dimmingView.alpha = 0
                 self.visualEffectView.alpha = 1
            }
        }
       
    }
    
    func adaptMaskTo(match cropRect: CGRect) {
        dimmingView.adaptMaskTo(match: cropRect)
        visualEffectView.adaptMaskTo(match: cropRect)
    }
}
