//
//  CountdownView.swift
//  ProManager
//
//  Created by Viraj Patel on 04/05/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

private let kDefaultCountdownFrom: Int = 5

protocol CountdownViewDelegate: NSObjectProtocol {
    func countdownFinished(_ view: CountdownView?)
}

let COUNTDOWN_LABEL_FONT_SCALE_FACTOR: CGFloat = 0.3

class CountdownView: UIView {
    var timer: Timer?
    var countdownLabel: UILabel?
    var currentCountdownValue: Int = 0
    var countdownFrom: Int = 0
    var finishText = ""
    // appearance settings
    var countdownColor: UIColor?
    var fontName = ""
    var backgroundAlpha: Float = 0.0
    weak var delegate: CountdownViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        updateAppearance()

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateAppearance()

    }
    func updateAppearance() {

        backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: CGFloat(backgroundAlphas()))
        // countdown label
        let fontSize = Float(bounds.size.width * COUNTDOWN_LABEL_FONT_SCALE_FACTOR)
        countdownLabel = UILabel()
        if let aSize = UIFont(name: fontNames() ?? "", size: CGFloat(fontSize)) {
            countdownLabel?.font = aSize
        }
        if let aColor = countdownColors() {
            countdownLabel?.textColor = aColor
        }
        countdownLabel?.textAlignment = .center
        countdownLabel?.isOpaque = true
        countdownLabel?.alpha = 1.0
        if let aLabel = countdownLabel {
            addSubview(aLabel)
        }
        countdownLabel?.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: UIScreen.width + 400, height: UIScreen.height)
        countdownLabel?.center = center
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        countdownLabel?.frame = CGRect(x: 0, y: 0, width: UIScreen.width + 400, height: UIScreen.height)
        countdownLabel?.center = center
    }

// MARK: - start/stopping
    func start() {
        stop()
        currentCountdownValue = countdownFroms()
        countdownLabel?.text = "\(countdownFroms())"
        animate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.animate), userInfo: nil, repeats: true)
    }
    func stop() {
        if timer != nil && (timer?.isValid)! {
            timer?.invalidate()
        }
    }
// MARK: - animation stuff
    @objc func animate() {
        UIView.animate(withDuration: 0.9, animations: { () -> Void in
            let transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
            self.countdownLabel?.transform = transform
            self.countdownLabel?.alpha = 0
        }, completion: { (_ finished: Bool) -> Void in
            if finished {
                if self.currentCountdownValue == 0 {
                    self.stop()
                    if (self.delegate != nil) {
                        self.delegate?.countdownFinished(self)
                    }
                } else {
                    self.countdownLabel?.transform = .identity
                    self.countdownLabel?.alpha = 1.0
                    self.currentCountdownValue -= 1
                    if self.currentCountdownValue == 0 {
                        self.countdownLabel?.text = self.finishTexts()
                    } else {
                        self.countdownLabel?.text = "\(self.currentCountdownValue)"
                    }
                }
            }
        })
    }

    // MARK: - custom getters

    func finishTexts() -> String? {
        if finishText == "" {
            finishText = "Go"
        }
        return finishText
    }
    func backgroundAlphas() -> Float {
        if backgroundAlpha == 0 {
            backgroundAlpha = 0.3
        }
        return backgroundAlpha
    }
    func countdownFroms() -> Int {
        if countdownFrom == 0 {
            countdownFrom = kDefaultCountdownFrom
        }
        return countdownFrom
        
    }
    
    func countdownColors() -> UIColor? {
        
        if countdownColor == nil {
            countdownColor = ApplicationSettings.appBlackColor
        }
        return countdownColor
        
    }
    
    func fontNames() -> String? {
        
        if fontName == "" {
            fontName = "HelveticaNeue-Medium"
        }
        return fontName
    }
}
