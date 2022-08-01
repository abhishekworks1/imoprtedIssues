//
//  Pulsing.swift
//  PulseButton
//
//  Created by Nilisha Gupta on 05/01/21.
//

import Foundation
import UIKit

class Pulsing: CALayer {
    
    // MARK: - Variables
    var animationGroup = CAAnimationGroup()
    var initialPulseScale: Float = 0.3
    var nextPulseAfter: TimeInterval = 0
    var animationDuration: TimeInterval = 0.9
    var radius: CGFloat = 50
    var numberOfPulses: Float = Float.infinity
    
    // MARK: - Initializers
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init (numberOfPulses: Float = Float.infinity, radius: CGFloat = 50, position: CGPoint = .zero) {
        super.init()
        self.backgroundColor = UIColor.white.cgColor
        self.contentsScale = UIScreen.main.scale
        self.opacity = 0
        self.radius = radius
        self.numberOfPulses = numberOfPulses
        self.position = position
        self.bounds = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
        self.cornerRadius = radius
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            self.setupAnimationGroup()
            DispatchQueue.main.async {
                self.add(self.animationGroup, forKey: R.string.localizable.pulse())
            }
        }
    }
    
    // MARK: - Animation Methods
    func createScaleAnimation () -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.fromValue = NSNumber(value: initialPulseScale)
        scaleAnimation.toValue = NSNumber(value: 1)
        scaleAnimation.duration = animationDuration
        scaleAnimation.repeatCount = .infinity
        return scaleAnimation
    }
    
    func createOpacityAnimation() -> CAKeyframeAnimation {
        let opacityAnimation = CAKeyframeAnimation(keyPath: R.string.localizable.opacity())
        opacityAnimation.duration = animationDuration
        opacityAnimation.values = [1, 0.9, 0]
        opacityAnimation.keyTimes = [0, 0.2, 1]
        return opacityAnimation
    }
    
    func setupAnimationGroup() {
        
        self.animationGroup = CAAnimationGroup()
        self.animationGroup.duration = animationDuration
        self.animationGroup.repeatCount = .infinity
        let defaultCurve = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        self.animationGroup.timingFunction = defaultCurve
        self.animationGroup.animations = [createScaleAnimation(), createOpacityAnimation()]
    }
    
}
