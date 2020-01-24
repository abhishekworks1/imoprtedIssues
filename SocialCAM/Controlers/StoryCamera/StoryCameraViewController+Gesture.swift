//
//  StoryCameraViewController+Gesture.swift
//  SocialCAM
//
//  Created by Viraj Patel on 22/11/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit

extension StoryCameraViewController {
    
    func removeGesturesOf(view: UIView) {
        guard let gestures = view.gestureRecognizers else {
            return
        }
        for gesture in gestures {
            view.removeGestureRecognizer(gesture)
        }
    }
    
    func addGesturesTo(view: UIView) {
        view.isUserInteractionEnabled = true
        
        replyQuePanGesture = UIPanGestureRecognizer(target: self,
                                                    action: #selector(replyQuePanGesture(_:)))
        replyQuePanGesture?.minimumNumberOfTouches = 1
        replyQuePanGesture?.maximumNumberOfTouches = 1
        replyQuePanGesture?.delegate = self
        view.addGestureRecognizer(replyQuePanGesture!)
        
        replyQuePinchGesture = UIPinchGestureRecognizer(target: self,
                                                        action: #selector(replyQuePinchGesture(_:)))
        replyQuePinchGesture?.delegate = self
        view.addGestureRecognizer(replyQuePinchGesture!)
        
        replyQueRotationGestureRecognizer = UIRotationGestureRecognizer(target: self,
                                                                        action: #selector(replyQueRotationGestureRecognizer(_:)))
        replyQueRotationGestureRecognizer?.delegate = self
        view.addGestureRecognizer(replyQueRotationGestureRecognizer!)
        
    }
    
    @objc func replyQuePanGesture(_ recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            isPageScrollEnable = false
        }
        if recognizer.state == .ended {
            isPageScrollEnable = true
        }
        if let view = recognizer.view {
            view.center = CGPoint(x: view.center.x + recognizer.translation(in: self.baseView).x,
                                  y: view.center.y + recognizer.translation(in: self.baseView).y)
            recognizer.setTranslation(CGPoint.zero, in: self.baseView)
        }
    }
    
    @objc func replyQuePinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .began {
            isPageScrollEnable = false
        }
        if recognizer.state == .ended {
            isPageScrollEnable = true
        }
        if let view = recognizer.view {
            view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
        }
    }
    
    @objc func replyQueRotationGestureRecognizer(_ recognizer: UIRotationGestureRecognizer) {
        if recognizer.state == .began {
            isPageScrollEnable = false
        }
        if recognizer.state == .ended {
            isPageScrollEnable = true
        }
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }    
}

// MARK: - State

enum State {
    case closed
    case open
}

extension State {
    var opposite: State {
        switch self {
        case .open: return .closed
        case .closed: return .open
        }
    }
}

extension StoryCameraViewController {
    func layout() {
        bottomCameraViews.translatesAutoresizingMaskIntoConstraints = false
        bottomCameraViews.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomCameraViews.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomConstraint = bottomCameraViews.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: popupOffset)
        bottomConstraint.isActive = true
        bottomCameraViews.heightAnchor.constraint(equalToConstant: 400).isActive = true
    }
    
    /// Animates the transition, if the animation is not already running.
    func animateTransitionIfNeeded(to state: State, duration: TimeInterval) {
        
        // ensure that the animators array is empty (which implies new animations need to be created)
        guard runningAnimators.isEmpty else { return }
        
        // an animator for the transition
        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
            switch state {
            case .open:
                self.bottomConstraint.constant = 0
                self.bottomCameraViews.layer.cornerRadius = 20
            case .closed:
                self.bottomConstraint.constant = self.popupOffset
                self.bottomCameraViews.layer.cornerRadius = 0
            }
            self.view.layoutIfNeeded()
        })
        
        // the transition completion block
        transitionAnimator.addCompletion { position in
            self.cameraModeIndicatorView.isHidden = false
            // update the state
            switch position {
            case .start:
                self.currentState = state.opposite
            case .end:
                self.currentState = state
            case .current:
                ()
            @unknown default:
                return
            }
            
            // manually reset the constraint positions
            switch self.currentState {
            case .open:
                self.bottomConstraint.constant = 0
            case .closed:
                self.bottomConstraint.constant = self.popupOffset
            }
            
            // remove all running animators
            self.runningAnimators.removeAll()
            
        }
        
        // an animator for the title that is transitioning into view
        let inTitleAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeIn, animations: {
            switch state {
            case .open:
                self.cameraModeIndicatorView.alpha = 1
                self.cameraSliderView.alpha = 0
            case .closed:
                self.cameraModeIndicatorView.alpha = 0
                self.cameraSliderView.alpha = 1
            }
        })
        inTitleAnimator.scrubsLinearly = false
        
        // an animator for the title that is transitioning out of view
        let outTitleAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeOut, animations: {
            switch state {
            case .open:
                self.cameraModeIndicatorView.alpha = 0
                self.cameraSliderView.alpha = 1
            case .closed:
                self.cameraModeIndicatorView.alpha = 1
                self.cameraSliderView.alpha = 0
            }
        })
        outTitleAnimator.scrubsLinearly = false
        
        // start all animators
        transitionAnimator.startAnimation()
        inTitleAnimator.startAnimation()
        outTitleAnimator.startAnimation()
        
        // keep track of all running animators
        runningAnimators.append(transitionAnimator)
        runningAnimators.append(inTitleAnimator)
        runningAnimators.append(outTitleAnimator)
    }
    
    @objc func popupViewPanned(recognizer: UIPanGestureRecognizer) {
        if isRecording {
            return
        }
        if case .down = recognizer.verticalDirection(target: self.view) {
            switch recognizer.state {
            case .began:
                
                // start the animations
                animateTransitionIfNeeded(to: currentState.opposite, duration: 1)
                
                // pause all animations, since the next event may be a pan changed
                runningAnimators.forEach { $0.pauseAnimation() }
                
                // keep track of each animator's progress
                animationProgress = runningAnimators.map { $0.fractionComplete }
                
            case .changed:
                
                // variable setup
                let translation = recognizer.translation(in: bottomCameraViews)
                var fraction = -translation.y / popupOffset
                
                // adjust the fraction for the current state and reversed state
                if currentState == .open { fraction *= -1 }
                if runningAnimators[0].isReversed { fraction *= -1 }
                
                // apply the new fraction
                for (index, animator) in runningAnimators.enumerated() {
                    animator.fractionComplete = fraction + animationProgress[index]
                }
                
            case .ended:
                
                // variable setup
                let yVelocity = recognizer.velocity(in: bottomCameraViews).y
                let shouldClose = yVelocity > 0
                
                // if there is no motion, continue all animations and exit early
                if yVelocity == 0 {
                    runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
                    break
                }
                
                // reverse the animations based on their current state and pan motion
                switch currentState {
                case .open:
                    if !shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                    if shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                case .closed:
                    if shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                    if !shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                }
                
                // continue all animations
                runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
                
            default:
                ()
            }
            print("Swiping down")
        } else {
            switch recognizer.state {
            case .began:
                
                // start the animations
                animateTransitionIfNeeded(to: currentState.opposite, duration: 1)
                
                // pause all animations, since the next event may be a pan changed
                runningAnimators.forEach { $0.pauseAnimation() }
                
                // keep track of each animator's progress
                animationProgress = runningAnimators.map { $0.fractionComplete }
                
            case .changed:
                
                // variable setup
                let translation = recognizer.translation(in: bottomCameraViews)
                var fraction = -translation.y / popupOffset
                
                // adjust the fraction for the current state and reversed state
                if currentState == .open { fraction *= -1 }
                if runningAnimators[0].isReversed { fraction *= -1 }
                
                // apply the new fraction
                for (index, animator) in runningAnimators.enumerated() {
                    animator.fractionComplete = fraction + animationProgress[index]
                }
                
            case .ended:
                
                // variable setup
                let yVelocity = recognizer.velocity(in: bottomCameraViews).y
                let shouldClose = yVelocity > 0
                
                // if there is no motion, continue all animations and exit early
                if yVelocity == 0 {
                    runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
                    break
                }
                
                // reverse the animations based on their current state and pan motion
                switch currentState {
                case .open:
                    if !shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                    if shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                case .closed:
                    if shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                    if !shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                }
                
                // continue all animations
                runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
                
            default:
                ()
            }
            print("Swiping up")
        }
        
    }
}

extension StoryCameraViewController {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

// MARK: - InstantPanGestureRecognizer

/// A pan gesture that enters into the `began` state on touch down instead of waiting for a touches moved event.
class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    
}

extension UIPanGestureRecognizer {
    
    enum GestureDirection {
        case up
        case down
        case left
        case right
    }
    
    /// Get current vertical direction
    ///
    /// - Parameter target: view target
    /// - Returns: current direction
    func verticalDirection(target: UIView) -> GestureDirection {
        return self.velocity(in: target).y > 0 ? .down : .up
    }
    
    /// Get current horizontal direction
    ///
    /// - Parameter target: view target
    /// - Returns: current direction
    func horizontalDirection(target: UIView) -> GestureDirection {
        return self.velocity(in: target).x > 0 ? .right : .left
    }
    
    /// Get a tuple for current horizontal/vertical direction
    ///
    /// - Parameter target: view target
    /// - Returns: current direction
    func versus(target: UIView) -> (horizontal: GestureDirection, vertical: GestureDirection) {
        return (self.horizontalDirection(target: target), self.verticalDirection(target: target))
    }
    
}
