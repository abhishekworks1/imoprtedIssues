//
//  BaseStoryTagView.swift
//  ProManager
//
//  Created by Jasmin Patel on 26/11/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import Foundation

class BaseStoryTagView: UIView {
    
    var tapButton: UIButton
    var tapCount = 0
    var tapEnable: Bool = true {
        didSet {
            tapButton.isHidden = !tapEnable
        }
    }
    var isStaticView: Bool = false

    override init(frame: CGRect) {
        tapButton = UIButton()
        super.init(frame: frame)
        addSubview(tapButton)
        tapButton.addTarget(self, action: #selector(onTap(_:)), for: .touchUpInside)
        setupTapButtonConstraint()
        self.onTap(UIButton())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onTap(_ sender: UIButton) {
        if !isStaticView {
            scaleEffect()
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layoutIfNeeded()
        self.tapCount = tapCount + 1
        self.onTapWith(tapCount)
        self.layoutIfNeeded()
        self.translatesAutoresizingMaskIntoConstraints = true
    }
    
    func onTapWith(_ tapCount: Int) {
        if tapCount % 2 == 0 {
            print("first type")
        } else if tapCount % 2 == 1 {
            print("second type")
        } else if tapCount % 3 == 2 {
            print("third type")
        }
    }
    
    private func scaleEffect() {
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
        let previouTransform = self.transform
        UIView.animate(withDuration: 0.2,
                       animations: {
                        self.transform = self.transform.scaledBy(x: 0.9, y: 0.9)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.2) {
                            self.transform  = previouTransform
                        }
        })
    }
    
    func setupTapButtonConstraint() {
        tapButton.translatesAutoresizingMaskIntoConstraints = false
        tapButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        tapButton.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        tapButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        tapButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
    }
    
    func labelFor(text: String, textAlignment: NSTextAlignment, fontSize: CGFloat, textColor: UIColor = ApplicationSettings.appWhiteColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = textColor
        label.font = UIFont.boldSystemFont(ofSize: fontSize)
        label.textAlignment = textAlignment
        return label
    }
    
    func stackViewWith(spacing: CGFloat, axis: NSLayoutConstraint.Axis) -> UIStackView {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = axis
        stackView.spacing = spacing
        return stackView
    }
    
    override func addSubview(_ view: UIView) {
        insertSubview(view, belowSubview: tapButton)
    }
    
}
