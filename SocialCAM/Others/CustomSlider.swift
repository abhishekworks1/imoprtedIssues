//
//  CustomSlider.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 09/10/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit

class CustomSlider: UISlider {
    
    // MARK: -
    // MARK: - Variables

    @IBInspectable var trackHeight: CGFloat = 3
    @IBInspectable var thumbRadius: CGFloat = 8 {
        didSet {
            let thumb = thumbImage(radius: thumbRadius)
            setThumbImage(thumb, for: .normal)
        }
    }
    private lazy var thumbView: UIView = {
        let thumb = UIView()
        thumb.backgroundColor = .white
        return thumb
    }()
    var thumbTextLabel: UILabel = UILabel()
    @IBInspectable var unitString: String = ""
    @IBInspectable var appendUnit: Bool = true
    
    private var thumbFrame: CGRect {
        return thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
    }
    
    // MARK: -
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addTarget(self, action: #selector(sliderTouchUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(sliderTouchUp), for: .touchUpOutside)
        self.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let thumb = thumbImage(radius: thumbRadius)
        setThumbImage(thumb, for: .normal)
    }
    
    @objc func sliderTouchUp() {
        self.trackHeight = 3
        self.thumbRadius = 8
    }
    
    @objc func sliderTouchDown() {
        self.trackHeight = 5
        self.thumbRadius = 10
    }
    
    // MARK: -
    // MARK: - Class Functions

    private func thumbImage(radius: CGFloat) -> UIImage {

        thumbView.frame = CGRect(x: 0, y: radius / 2, width: radius, height: radius)
        thumbView.layer.cornerRadius = radius / 2

        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
        return renderer.image { rendererContext in
            let context = rendererContext.cgContext
            context.setFillColor(R.color.appPrimaryColor()?.cgColor ?? UIColor.blue.cgColor)
            thumbView.layer.render(in: context)
        }
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newRect = super.trackRect(forBounds: bounds)
        newRect.size.height = trackHeight
        return newRect
    }

}
