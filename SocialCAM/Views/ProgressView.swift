//
//  ProgressView.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 11/07/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit

protocol ProgressViewDelegate: class {
    func finishProgress(_ progressView: ProgressView)
    func seekPlayerToTime(currentTime: TimeInterval)
    func pausePlayer()
    func resumePlayer()
}

extension ProgressViewDelegate {
    func finishProgress(_ progressView: ProgressView) { }
    func seekPlayerToTime(currentTime: TimeInterval) { }
    func pausePlayer() { }
    func resumePlayer() { }
}

class ProgressView: UIProgressView {
    var timer: Timer?
    var roundView: UIView?
    var currentTime: TimeInterval = 0 {
        didSet {
            if !Float(self.currentTime/self.duration).isNaN {
                self.setProgress(Float(self.currentTime/self.duration), animated: false)
                if self.currentTime >= self.duration {
                    if let delegate = self.delegate {
                        delegate.finishProgress(self)
                    }
                }
            }
        }
    }
    
    var duration: TimeInterval = 0.0
    
    weak var delegate: ProgressViewDelegate?
    var useTimer: Bool = false
    
    func startProgress() {
        if useTimer == false {
            return
        }
        currentTime = 0.0
        if let timer = self.timer {
            if timer.isValid {
                timer.invalidate()
            }
        }
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (_: Timer) in
            if self.currentTime >= self.duration {
                self.timer?.invalidate()
                self.currentTime = 0.0
                return
            }
            self.currentTime += 0.1
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isUserInteractionEnabled = true
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.moveSlider(sender:)))
        self.addGestureRecognizer(pan)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.progressTap(sender:)))
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
        roundView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10, height: 10))
        roundView?.layer.cornerRadius = 5
        roundView?.clipsToBounds = true
        roundView?.backgroundColor = ApplicationSettings.appPrimaryColor
        roundView?.isHidden = true
        self.addSubview(roundView!)
    }
    
    func pauseProgress() {
        if useTimer == false {
            return
        }
        if let timer = self.timer {
            if timer.isValid {
                timer.invalidate()
            }
        }
    }
    
    func resumeProgress() {
        if useTimer == false {
            return
        }
        if let timer = self.timer {
            if timer.isValid {
                timer.invalidate()
            }
        }
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (_: Timer) in
            if self.currentTime >= self.duration {
                if self.currentTime >= self.duration {
                    self.timer?.invalidate()
                    self.currentTime = 0.0
                    return
                }
            }
            self.currentTime += 0.1
        })
    }
    
    // MRAK : ----- Move Slider --------
    
    @objc func moveSlider(sender: UIPanGestureRecognizer) {
        if self.isUserInteractionEnabled == false {
            return
        }
        if sender.state == .began {
            self.pauseProgress()
            if let delegate = self.delegate {
                delegate.pausePlayer()
            }
            let x = self.progress * Float(self.frame.size.width)
            roundView?.center = CGPoint(x: CGFloat(x), y: self.frame.size.height/2.0)
            roundView?.isHidden = false
            
        } else if sender.state == .changed {
            let x = sender.location(in: self).x
            let progress = x / self.width
            roundView?.center = CGPoint(x: CGFloat(x), y: self.frame.size.height/2.0)
            self.currentTime = Double(progress) * self.duration
            if let delegate = self.delegate {
                delegate.seekPlayerToTime(currentTime: self.currentTime)
            }
            // self.setProgress(Float(progress), animated: false)
        } else if sender.state == .ended {
            self.resumeProgress()
            if let delegate = self.delegate {
                delegate.resumePlayer()
            }
            roundView?.isHidden = true
        } else {
            self.resumeProgress()
            if let delegate = self.delegate {
                delegate.resumePlayer()
            }
            roundView?.isHidden = true
        }
        
    }

    @objc func progressTap(sender: UITapGestureRecognizer) {
        let x = sender.location(in: self).x
        if self.isUserInteractionEnabled == false {
            return
        }
        self.pauseProgress()
        if let delegate = self.delegate {
            delegate.pausePlayer()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let progress = x / self.width
            self.roundView?.center = CGPoint(x: CGFloat(x), y: self.frame.size.height/2.0)
            self.currentTime = Double(progress) * self.duration
            self.roundView?.isHidden = false
            if let delegate = self.delegate {
                delegate.seekPlayerToTime(currentTime: self.currentTime)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.resumeProgress()
            self.roundView?.isHidden = true
            if let delegate = self.delegate {
                delegate.resumePlayer()
            }
        }
  
    }
    
}

class ProgressContainerView: UIView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height).contains(point) {
              return self.subviews[0]
        } else {
            return super.hitTest(point, with: event)
        }
    }
}
