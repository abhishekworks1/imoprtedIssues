//
//  PassViewPushTransition.swift
//  ETNews
//
//  Created by Millman YANG on 2017/5/22.
//  Copyright © 2017年 Sen Informatoin co. All rights reserved.
//

import UIKit

public class MMPlayerPassViewPushTransition: MMPlayerBaseNavTransition, UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return config.duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let toVC = transitionContext.viewController(forKey: .to)!
        container.addSubview(toVC.view)

        switch self.operation {
        case .push:
            toVC.view.layoutIfNeeded()
            guard let passLayer = (self.source as? MMPlayerFromProtocol)?.passPlayer else {
                print("Need Called setView")
                return
            }
            guard let passContainer = (toVC as? MMPLayerToProtocol)?.containerView else {
                print("Need implement PassViewToProtocol")
                return
            }
            if let c = self.config as? MMPlayerPassViewPushConfig {
                c.passOriginalSuper = passLayer.playView
                c.playLayer = passLayer
            }
            (self.source as? MMPlayerFromProtocol)?.transitionWillStart()
            let convertRect: CGRect = passLayer.superlayer?.convert(passLayer.superlayer!.frame, to: nil) ?? .zero
            let finalFrame = transitionContext.finalFrame(for: toVC)
            let originalColor = toVC.view.backgroundColor
            passLayer.clearURLWhenChangeView = false
            let pass = UIView(frame: convertRect)
            passLayer.playView = pass
            toVC.view.backgroundColor = ApplicationSettings.appClearColor
            toVC.view.frame = finalFrame
            pass.removeFromSuperview()
            container.addSubview(pass)
            pass.frame = convertRect
            let finalFrameContenerView = toVC.view.convert(passContainer.frame, from: passContainer)
            UIView.animate(withDuration: self.config.duration, animations: {
                pass.frame = finalFrameContenerView
            }, completion: { (_) in
                pass.frame = finalFrameContenerView
                toVC.view.backgroundColor = originalColor
                pass.translatesAutoresizingMaskIntoConstraints = false
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                passLayer.playView = passContainer
                (toVC as? MMPLayerToProtocol)?.transitionCompleted(player: passLayer)
                passLayer.clearURLWhenChangeView = true
            })
        case .pop:
            let from = transitionContext.viewController(forKey: .from)
            guard let config = self.config as? MMPlayerPassViewPushConfig else {
                return
            }
            
            guard let pass = config.playLayer?.playView else {
                return
            }
            
            guard let source = self.source as? MMPlayerFromProtocol else {
                print("Need Implement PassViewFromProtocol")
                return
            }
            config.playLayer?.clearURLWhenChangeView = false
            pass.translatesAutoresizingMaskIntoConstraints = true
            let superV = source.backReplaceSuperView?(original: config.passOriginalSuper) ?? config.passOriginalSuper
            let original: CGRect = pass.convert(pass.frame, to: nil)

            let convertRect: CGRect = (superV != nil ) ? superV!.convert(superV!.frame, to: nil) : .zero
            
            if superV != nil {
                pass.removeFromSuperview()
                container.addSubview(pass)
            }
            pass.frame = original
            UIView.animate(withDuration: self.config.duration, animations: {
                from?.view.alpha = 0.0
                pass.frame = convertRect
            }, completion: { (_) in
                config.playLayer?.playView = superV
                pass.translatesAutoresizingMaskIntoConstraints = false
                superV?.isHidden = false
                pass.removeFromSuperview()
                from?.view.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                config.playLayer?.clearURLWhenChangeView = true
                source.transitionCompleted()
            })
        default:
            break
        }
    }
}
