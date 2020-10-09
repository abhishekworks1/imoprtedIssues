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

    @IBInspectable var trackHeight: CGFloat = 5
    @IBInspectable var thumbRadius: CGFloat = 10 {
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.thumbTextLabel.center = thumbFrame.center
        thumbTextLabel.frame = CGRect(x: thumbTextLabel.frame.origin.x, y: thumbFrame.origin.y - 20, width: 80, height: thumbFrame.size.height)
        thumbTextLabel.font = UIFont.systemFont(ofSize: 12.0)
        if appendUnit {
            thumbTextLabel.text = Int(self.value).description + unitString
        } else {
            thumbTextLabel.text = unitString + Int(self.value).description
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(thumbTextLabel)
        thumbTextLabel.textAlignment = .center
        thumbTextLabel.layer.zPosition = layer.zPosition + 1
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
        self.trackHeight = 5
        self.thumbRadius = 10
    }
    
    @objc func sliderTouchDown() {
        self.trackHeight = 10
        self.thumbRadius = 15
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
