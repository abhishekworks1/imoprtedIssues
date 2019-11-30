//
//  StoryCameraViewController+Gesture.swift
//  SocialCAM
//
//  Created by Viraj Patel on 22/11/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit
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
                return
            case .closed:
                return
            }
        })
        inTitleAnimator.scrubsLinearly = false
        
        // an animator for the title that is transitioning out of view
        let outTitleAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeOut, animations: {
            switch state {
            case .open:
                return
            case .closed:
                return
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
        if case .Down = recognizer.verticalDirection(target: self.view) {
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

// MARK: - InstantPanGestureRecognizer

/// A pan gesture that enters into the `began` state on touch down instead of waiting for a touches moved event.
class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    
    
}

extension UIPanGestureRecognizer {
    
    enum GestureDirection {
        case Up
        case Down
        case Left
        case Right
    }
    
    /// Get current vertical direction
    ///
    /// - Parameter target: view target
    /// - Returns: current direction
    func verticalDirection(target: UIView) -> GestureDirection {
        return self.velocity(in: target).y > 0 ? .Down : .Up
    }
    
    /// Get current horizontal direction
    ///
    /// - Parameter target: view target
    /// - Returns: current direction
    func horizontalDirection(target: UIView) -> GestureDirection {
        return self.velocity(in: target).x > 0 ? .Right : .Left
    }
    
    /// Get a tuple for current horizontal/vertical direction
    ///
    /// - Parameter target: view target
    /// - Returns: current direction
    func versus(target: UIView) -> (horizontal: GestureDirection, vertical: GestureDirection) {
        return (self.horizontalDirection(target: target), self.verticalDirection(target: target))
    }
    
}
