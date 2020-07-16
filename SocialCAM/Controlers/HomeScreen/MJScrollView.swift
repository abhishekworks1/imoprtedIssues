//
//  MJScrollView.swift
//  SocialCAM
//
//  Created by Viraj Patel on 13/07/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import MXSegmentedPager

class MJScrollView: UIScrollView, UIGestureRecognizerDelegate {
    fileprivate var isObserving: Bool = false
    fileprivate var lock: Bool = false
    fileprivate var observedViews: [UIScrollView] = []
    fileprivate static var myContext = 1
    fileprivate var forwarder: MJScrollViewDelegateForwarder?
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    override var delegate: UIScrollViewDelegate? {
        didSet {
            self.forwarder?.delegate = delegate
            super.delegate = nil
            super.delegate = self.forwarder
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "contentOffset", context: &MJScrollView.myContext)
        self.removeObservedViews()
    }
    
    func initialize() {
        self.forwarder = MJScrollViewDelegateForwarder()
        super.delegate = self.forwarder
        self.showsVerticalScrollIndicator = false
        self.isDirectionalLockEnabled = true
        self.bounces = false
        
        self.panGestureRecognizer.cancelsTouchesInView = false
        self.observedViews = []
        self.addObserver(self, forKeyPath: "contentOffset", options: [.new,.old], context: &MJScrollView.myContext)
        
        isObserving = true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.view == self {
            return false
        }
        //   Ignore other gesture than pan
        if !gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
            return false
        }
        // Lock horizontal pan gesture.
        let velocity = (gestureRecognizer as? UIPanGestureRecognizer)?.velocity(in: self)
        if  fabs(Double(velocity?.x ?? 0.0)) > fabs(Double(velocity?.y ?? 0.0)) {
            return false
        }
        
        // Consider scroll view pan only
        
        guard let scrollView = otherGestureRecognizer.view as? UIScrollView else {
            return false
        }
        
        if (scrollView.isKind(of: MXScrollView.self)) {
            return false
        }
        
        if (scrollView.superview?.isKind(of: UITableView.self))! {
            return false
        }
        var shouldScroll : Bool = true
        
        if scrollView.isKind(of: MXPagerView.self) {
            shouldScroll = false
        }
        if shouldScroll {
            self.addObservedView(scrollView: scrollView)
        }
        
        return shouldScroll
    }
    
}

// MARK: -------- KVO ---------

extension MJScrollView {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &MJScrollView.myContext && keyPath == "contentOffset" {
            guard let new = change?[NSKeyValueChangeKey.newKey] as? CGPoint else {
                return
            }
            guard let old = change?[NSKeyValueChangeKey.oldKey] as? CGPoint else {
                return
            }
            let diff = old.y - new.y
            if diff == 0.0 || !isObserving {
                return
            }
            if let obj = object as? MJScrollView , obj == self {
                if diff > 0 && lock {
                    self.scrollView(self, contentOffset: old)
                } else if ((self.contentOffset.y < -self.contentInset.top) && !self.bounces) {
                    self.scrollView(self, contentOffset: CGPoint(x: self.contentOffset.x, y: -self.contentInset.top))
                }
            } else {
                guard let scrollView = object as? UIScrollView else {
                    return
                }
                lock = (scrollView.contentOffset.y > -scrollView.contentInset.top)
                
                if self.contentOffset.y < 0 && lock && diff < 0 {
                    self.scrollView(scrollView, contentOffset: old)
                }
                
                if (!lock && ((self.contentOffset.y > -self.contentInset.top) || self.bounces)) {
                    self.scrollView(scrollView, contentOffset: CGPoint(x: scrollView.contentOffset.x, y: -scrollView.contentInset.top))
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context:context)
        }
    }
    
    func scrollView(_ scrollView: UIScrollView , contentOffset offset: CGPoint) {
        isObserving = false
        scrollView.contentOffset = offset
        isObserving = true
    }
    
    func addObserverToView(scrollView: UIScrollView) {
        lock = (scrollView.contentOffset.y > -scrollView.contentInset.top)
        scrollView.addObserver(self, forKeyPath:"contentOffset", options: [.new, .old] , context:  &MJScrollView.myContext)
    }
    
    func removeObserverFromView(scrollView: UIScrollView) {
        scrollView.removeObserver(self, forKeyPath: "contentOffset", context: &MJScrollView.myContext)
    }
    
    func addObservedView(scrollView:UIScrollView){
        if !self.observedViews.contains(scrollView) {
            self.observedViews.append(scrollView)
            self.addObserverToView(scrollView: scrollView)
        }
    }
    
    func removeObservedViews() {
        for scrollView in self.observedViews {
            self.removeObserverFromView(scrollView: scrollView)
        }
        self.observedViews.removeAll()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        lock = false
        self.removeObservedViews()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool){
        if !decelerate {
            lock = false
            self.removeObservedViews()
        }
    }
    
}

class MJScrollViewDelegateForwarder: NSObject {
    var delegate: UIScrollViewDelegate?
}

extension MJScrollViewDelegateForwarder: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        (scrollView as? MJScrollView)?.scrollViewDidEndDecelerating(scrollView: scrollView)
        if let delegate = self.delegate {
            delegate.scrollViewDidEndDecelerating?(scrollView)
        }
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        (scrollView as? MJScrollView)?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        if let delegate = self.delegate {
            delegate.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        }
    }
}
