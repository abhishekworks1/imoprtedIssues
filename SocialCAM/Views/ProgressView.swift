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

protocol PlayerControlViewDelegate: class {
    func sliderTouchBegin(_ sender: UISlider)
    func sliderTouchEnd(_ sender: UISlider)
    func sliderValueChange(_ sender: UISlider)
}

class VideoSliderView: UIView {
    
    weak var delegate: PlayerControlViewDelegate?
    
    lazy var timeSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0
        slider.minimumValue = 0
        slider.maximumValue = 1.0
        slider.backgroundColor = UIColor.clear
        slider.contentMode = ContentMode.scaleAspectFit
        slider.minimumTrackTintColor = ApplicationSettings.appPrimaryColor
        slider.maximumTrackTintColor = UIColor.clear
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .touchDown)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.setThumbImage(R.image.icoRoundView()?.withImageTintColor(ApplicationSettings.appPrimaryColor), for: .normal)
        slider.setThumbImage(R.image.icoRoundView()?.withImageTintColor(ApplicationSettings.appPrimaryColor), for: .highlighted)
        slider.addTarget(self, action: #selector(sliderValueChange(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderAllTouchBegin(_:)), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderAllTouchEnd(_:)), for: .touchCancel)
        slider.addTarget(self, action: #selector(sliderAllTouchEnd(_:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderAllTouchEnd(_:)), for: .touchUpOutside)
        return slider
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSliderView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSliderView()
    }
    
    func addSliderView() {
        self.addSubview(timeSlider)
        timeSlider.heightAnchor.constraint(equalToConstant: 5).isActive = true
        timeSlider.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        timeSlider.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        timeSlider.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
    
    var currentTime: Float = 0 {
        didSet {
            timeSlider.value = currentTime
        }
    }
    
    var maximumValue: Float = 0.0 {
        didSet {
            timeSlider.maximumValue = maximumValue
        }
    }
    
    @objc func sliderValueChange(_ sender: UISlider) {
        delegate?.sliderValueChange(sender)
    }
    
    @objc func sliderAllTouchBegin(_ sender: UISlider) {
        delegate?.sliderTouchBegin(sender)
    }
    
    @objc func sliderAllTouchEnd(_ sender: UISlider) {
        delegate?.sliderTouchEnd(sender)
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        delegate?.sliderValueChange(sender)
    }
    
}

class ProgressView: UIProgressView {
    var timer: Timer?
    var roundView: UIView?
    var currentTime: TimeInterval = 0 {
        didSet {
            if !Float(self.currentTime/self.duration).isNaN {
                self.setProgress(Float(self.currentTime/self.duration), animated: false)
                let xValue = self.progress * Float(self.frame.size.width)
                roundView?.center = CGPoint(x: CGFloat(xValue), y: self.frame.size.height/2.0)
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
        roundView?.isHidden = false
        roundView?.isUserInteractionEnabled = true
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
            let xValue = self.progress * Float(self.frame.size.width)
            roundView?.center = CGPoint(x: CGFloat(xValue), y: self.frame.size.height/2.0)
            roundView?.isHidden = false
        } else if sender.state == .changed {
            let xValue = sender.location(in: self).x
            let progress = xValue / self.viewWidth
            roundView?.center = CGPoint(x: CGFloat(xValue), y: self.frame.size.height/2.0)
            self.currentTime = Double(progress) * self.duration
            if let delegate = self.delegate {
                delegate.seekPlayerToTime(currentTime: self.currentTime)
            }
        } else if sender.state == .ended {
            self.resumeProgress()
            if let delegate = self.delegate {
                delegate.resumePlayer()
            }
            roundView?.isHidden = false
        } else {
            self.resumeProgress()
            if let delegate = self.delegate {
                delegate.resumePlayer()
            }
            roundView?.isHidden = false
        }
        
    }

    @objc func progressTap(sender: UITapGestureRecognizer) {
        let xValue = sender.location(in: self).x
        if self.isUserInteractionEnabled == false {
            return
        }
        self.pauseProgress()
        if let delegate = self.delegate {
            delegate.pausePlayer()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let progress = xValue / self.viewWidth
            self.roundView?.center = CGPoint(x: CGFloat(xValue), y: self.frame.size.height/2.0)
            self.currentTime = Double(progress) * self.duration
            self.roundView?.isHidden = false
            if let delegate = self.delegate {
                delegate.seekPlayerToTime(currentTime: self.currentTime)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.resumeProgress()
            self.roundView?.isHidden = false
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
