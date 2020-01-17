//
//  SnapGesture.swift
//  ProManager
//
//  Created by Jasmin Patel on 18/07/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation

class SnapGesture: NSObject, UIGestureRecognizerDelegate {
    
    public var gestureCompletion: ((Bool) -> Void)?
    
    // MARK: - init and deinit
    convenience init(view: UIView) {
        self.init(transformView: view, gestureView: view)
    }
    init(transformView: UIView, gestureView: UIView) {
        super.init()
        
        self.addGestures(view: gestureView)
        self.weakTransformView = transformView
    }
    deinit {
        print("Deinit \(self.description)")
        self.cleanGesture()
    }
    
    // MARK: - private method
    weak var weakGestureView: UIView?
    weak var weakTransformView: UIView?
    
    private var panGesture: UIPanGestureRecognizer?
    private var pinchGesture: UIPinchGestureRecognizer?
    private var rotationGesture: UIRotationGestureRecognizer?
    
    private func addGestures(view: UIView) {
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panProcess(_:)))
        view.isUserInteractionEnabled = true
        panGesture?.delegate = self     // for simultaneous recog
        panGesture?.minimumNumberOfTouches = 2
        view.addGestureRecognizer(panGesture!)
        
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchProcess(_:)))
        //view.isUserInteractionEnabled = true
        pinchGesture?.delegate = self   // for simultaneous recog
        view.addGestureRecognizer(pinchGesture!)
        
        rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotationProcess(_:)))
        rotationGesture?.delegate = self
        view.addGestureRecognizer(rotationGesture!)
        
        self.weakGestureView = view
    }
    
    private func cleanGesture() {
        if let view = self.weakGestureView {
            if panGesture != nil {
                view.removeGestureRecognizer(panGesture!)
                panGesture = nil
            }
            if pinchGesture != nil {
                view.removeGestureRecognizer(pinchGesture!)
                pinchGesture = nil
            }
            if rotationGesture != nil {
                view.removeGestureRecognizer(rotationGesture!)
                rotationGesture = nil
            }
        }
        self.weakGestureView = nil
        self.weakTransformView = nil
    }
    
    // MARK: - API
    
    private func setView(view: UIView?) {
        self.setTransformView(view, gestgureView: view)
    }
    
    private func setTransformView(_ transformView: UIView?, gestgureView: UIView?) {
        self.cleanGesture()
        
        if let view = gestgureView {
            self.addGestures(view: view)
        }
        self.weakTransformView = transformView
    }
    
    open func resetViewPosition() {
        UIView.animate(withDuration: 0.4) {
            self.weakTransformView?.transform = CGAffineTransform.identity
        }
    }
    
    open var isGestureEnabled = true
    
    // MARK: - gesture handle
    
    // location will jump when finger number change
    private var initPanFingerNumber: Int = 1
    private var isPanFingerNumberChangedInThisSession = false
    private var lastPanPoint: CGPoint = CGPoint(x: 0, y: 0)
    @objc func panProcess(_ recognizer: UIPanGestureRecognizer) {
        backToIdentity(recognizer: recognizer)
        
        if isGestureEnabled {
            guard let view = self.weakTransformView else { return }
            
            // init
            if recognizer.state == .began {
                lastPanPoint = recognizer.location(in: view)
                initPanFingerNumber = recognizer.numberOfTouches
                isPanFingerNumberChangedInThisSession = false
            }
            
            // judge valid
            if recognizer.numberOfTouches != initPanFingerNumber {
                isPanFingerNumberChangedInThisSession = true
            }
            if isPanFingerNumberChangedInThisSession {
                return
            }
            
            // perform change
            let point = recognizer.location(in: view)
            view.transform = view.transform.translatedBy(x: point.x - lastPanPoint.x, y: point.y - lastPanPoint.y)
            lastPanPoint = recognizer.location(in: view)
            backToIdentity(recognizer: recognizer)
            
        }
    }
    
    private var lastScale: CGFloat = 1.0
    private var lastPinchPoint: CGPoint = CGPoint(x: 0, y: 0)
    @objc func pinchProcess(_ recognizer: UIPinchGestureRecognizer) {
        backToIdentity(recognizer: recognizer)
        if isGestureEnabled {
            
            guard let view = self.weakTransformView else { return }
            
            // init
            if recognizer.state == .began {
                lastScale = 1.0
                lastPinchPoint = recognizer.location(in: view)
            }
            
            // judge valid
            if recognizer.numberOfTouches < 2 {
                lastPinchPoint = recognizer.location(in: view)
                return
            }
            
            // Scale
            let scale = 1.0 - (lastScale - recognizer.scale)
            view.transform = view.transform.scaledBy(x: scale, y: scale)
            lastScale = recognizer.scale
            
            // Translate
            let point = recognizer.location(in: view)
            view.transform = view.transform.translatedBy(x: point.x - lastPinchPoint.x, y: point.y - lastPinchPoint.y)
            lastPinchPoint = recognizer.location(in: view)
            
            backToIdentity(recognizer: recognizer)
        }
    }
    
    func backToIdentity(recognizer: UIGestureRecognizer) {
        if recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed {
            UIView.animate(withDuration: 0.2) {
                recognizer.view?.transform = .identity
                self.gestureCompletion?(true)
            }
        } else if recognizer.state == .began {
            self.gestureCompletion?(false)
        }
    }
    
    @objc func rotationProcess(_ recognizer: UIRotationGestureRecognizer) {
        backToIdentity(recognizer: recognizer)
        
        if isGestureEnabled {
            guard let view = self.weakTransformView else { return }
            
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
            
            backToIdentity(recognizer: recognizer)
            
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate Methods
    func gestureRecognizer(_: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

class SnapGesture2: NSObject, UIGestureRecognizerDelegate {
    
    // MARK: - init and deinit
    convenience init(view: UIView) {
        self.init(transformView: view, gestureView: view)
    }
    
    init(transformView: UIView, gestureView: UIView) {
        super.init()
        
        self.addGestures(view: gestureView)
        self.weakTransformView = transformView
        
        guard let transformView = self.weakTransformView, let superview = transformView.superview else {
            return
        }
        
        // This is required in order to be able to snap the view to center later on,
        // using the tx property of its transform.
        transformView.center = superview.center
    }
    deinit {
        self.cleanGesture()
    }
    
    // MARK: - private method
    private weak var weakGestureView: UIView?
    weak var weakTransformView: UIView?
    
    private var panGesture: UIPanGestureRecognizer?
    private var pinchGesture: UIPinchGestureRecognizer?
    private var rotationGesture: UIRotationGestureRecognizer?
    
    private func addGestures(view: UIView) {
        view.isUserInteractionEnabled = true
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panProcess(_:)))
        panGesture?.delegate = self
        view.addGestureRecognizer(panGesture!)
        
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchProcess(_:)))
        pinchGesture?.delegate = self
        view.addGestureRecognizer(pinchGesture!)
        
        rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotationProcess(_:)))
        rotationGesture?.delegate = self
        view.addGestureRecognizer(rotationGesture!)
        
        self.weakGestureView = view
    }
    
    private func cleanGesture() {
        if let view = self.weakGestureView {
            if panGesture != nil {
                view.removeGestureRecognizer(panGesture!)
                panGesture = nil
            }
            if pinchGesture != nil {
                view.removeGestureRecognizer(pinchGesture!)
                pinchGesture = nil
            }
            if rotationGesture != nil {
                view.removeGestureRecognizer(rotationGesture!)
                rotationGesture = nil
            }
        }
        self.weakGestureView = nil
        self.weakTransformView = nil
    }
    
    // MARK: - API
    
    private func setView(view: UIView?) {
        self.setTransformView(view, gestgureView: view)
    }
    
    private func setTransformView(_ transformView: UIView?, gestgureView: UIView?) {
        self.cleanGesture()
        
        if let view = gestgureView {
            self.addGestures(view: view)
        }
        self.weakTransformView = transformView
    }
    
    open func resetViewPosition() {
        UIView.animate(withDuration: 0.4) {
            self.weakTransformView?.transform = CGAffineTransform.identity
        }
    }
    
    open var isGestureEnabled = true
    
    // MARK: - gesture handle
    
    // location will jump when finger number change
    private var initPanFingerNumber: Int = 1
    private var isPanFingerNumberChangedInThisSession = false
    private var lastPanPoint: CGPoint = CGPoint(x: 0, y: 0)
    
    @objc func panProcess(_ recognizer: UIPanGestureRecognizer) {
        guard isGestureEnabled, let view = self.weakTransformView else { return }
        
        // init
        if recognizer.state == .began {
            lastPanPoint = recognizer.location(in: view)
            initPanFingerNumber = recognizer.numberOfTouches
            isPanFingerNumberChangedInThisSession = false
        }
        
        // judge valid
        if recognizer.numberOfTouches != initPanFingerNumber {
            isPanFingerNumberChangedInThisSession = true
        }
        
        if isPanFingerNumberChangedInThisSession {
            return
        }
        
        // perform change
        let point = recognizer.location(in: view)
        view.transform = view.transform.translatedBy(x: point.x - lastPanPoint.x, y: point.y - lastPanPoint.y)
        lastPanPoint = recognizer.location(in: view)
        
    }
    
    private var lastScale: CGFloat = 1.0
    private var lastPinchPoint: CGPoint = CGPoint(x: 0, y: 0)
    
    @objc func pinchProcess(_ recognizer: UIPinchGestureRecognizer) {
        guard isGestureEnabled, let view = self.weakTransformView else { return }
        
        // init
        if recognizer.state == .began {
            lastScale = 1.0
            lastPinchPoint = recognizer.location(in: view)
        }
        
        // judge valid
        if recognizer.numberOfTouches < 2 {
            lastPinchPoint = recognizer.location(in: view)
            return
        }
        
        // Scale
        let scale = 1.0 - (lastScale - recognizer.scale)
        view.transform = view.transform.scaledBy(x: scale, y: scale)
        lastScale = recognizer.scale
        
        // Translate
        let point = recognizer.location(in: view)
        view.transform = view.transform.translatedBy(x: point.x - lastPinchPoint.x, y: point.y - lastPinchPoint.y)
        lastPinchPoint = recognizer.location(in: view)
    }
    
    @objc func rotationProcess(_ recognizer: UIRotationGestureRecognizer) {
        guard isGestureEnabled, let view = self.weakTransformView else { return }
        
        view.transform = view.transform.rotated(by: recognizer.rotation)
        recognizer.rotation = 0
    }
    
    // MARK: - UIGestureRecognizerDelegate Methods
    func gestureRecognizer(_: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
