//
//  BaseWeatherTagView.swift
//  ProManager
//
//  Created by Jasmin Patel on 11/12/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

class WeatherTagView: BaseStoryTagView {
    
    public var temperature: String = "" {
        didSet {
            temperatureLabel.text = temperature
        }
    }
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView.init(image: R.image.weather())
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var temperatureLabel: UILabel = {
        return self.labelFor(text: self.temperature,
                             textAlignment: .center,
                             fontSize: 40)
    }()
    
    lazy var stackView: UIStackView = {
        return self.stackViewWith(spacing: 10, axis: .vertical)
    }()
    
    convenience init(temperature: String) {
        self.init(frame: CGRect.zero)
        self.temperature = temperature
        setupViews()
    }
    
    private func setupViews() {
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(temperatureLabel)
        self.insertSubview(stackView, belowSubview: tapButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        onFirstTap()
    }
    
    override func onTapWith(_ tapCount: Int) {
        super.onTapWith(tapCount)
        if self.tapCount % 3 == 1 {
            onFirstTap()
        } else if self.tapCount % 3 == 2 {
            onSecondTap()
        } else if self.tapCount % 3 == 0 {
            onThirdTap()
        }
    }
    
    func onFirstTap() {
        imageView.isHidden = true
        temperatureLabel.text = "\(Int(Double(temperature) ?? 0))° C"
    }
    
    func onSecondTap() {
        imageView.isHidden = false
        temperatureLabel.text = "\(Int(Double(temperature) ?? 0))° C"
    }
    
    func onThirdTap() {
        imageView.isHidden = true
        temperatureLabel.text = "\(Int(self.fahrenheitOf(celsius: Double(temperature) ?? 0)))° F"
    }
    
    func fahrenheitOf(celsius: Double) -> Double {
        return (celsius * 1.8) + 32
    }
    
}
