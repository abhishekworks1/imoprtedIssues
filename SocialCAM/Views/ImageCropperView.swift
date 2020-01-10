//
//  ZImageCropperView.swift
//  ZImageCropper
//
//  Created by Zaid Pathan on 25/05/19.
//  Copyright © 2019 Zaid Pathan. All rights reserved.
//

import UIKit

public protocol ImageCropperDelegate: class {
    func didEndCropping(croppedImage: UIImage?)
}

extension ImageCropperDelegate {
    func didEndCropping(croppedImage: UIImage?) { }
}

public class ImageCropperView: UIImageView {

    // Update this to enable/disable cropping
    public var isCropEnabled = true

    // Update this for path line color
    public var strokeColor: UIColor = UIColor.gray.withAlphaComponent(0.6)
    
    // Update this for path line width
    public var lineWidth: CGFloat = 20.0
    
    public var delegate: ImageCropperDelegate?
    
    private var path = UIBezierPath()
    private var shapeLayer = CAShapeLayer()
    
    // Get recently cropped image anytime
    public var croppedImage: UIImage?
    
    public var isLogEnabled = true
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = isCropEnabled
    }
    
    // MARK: - Public methods

    /**
     Crop selection layer
     - Returns: Cropped image
     */
    public func cropImage() -> UIImage? {
        shapeLayer.strokeColor = ApplicationSettings.appBlackColor.cgColor
        shapeLayer.fillColor = ApplicationSettings.appBlackColor.cgColor
        layer.mask = shapeLayer
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 1)
        
        if let currentContext = UIGraphicsGetCurrentContext() {
            layer.render(in: currentContext)
            
            if let croppedImageFromContext = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                croppedImage = croppedImageFromContext
            }
        }
        
        if let cgCroppedImage = croppedImage?.cgImage?.cropping(to: path.bounds) {
            croppedImage = UIImage(cgImage: cgCroppedImage)
        }
        
        return croppedImage
    }
    
    /**
     Reset cropping
     */
    public func resetCrop() {
        path = UIBezierPath()
        shapeLayer = CAShapeLayer()
        layer.mask = nil
        croppedImage = nil
    }
    
    // MARK: - Private methods
    /**
     This methods is adding CAShapeLayer line to tempImageView
     */
    private func addNewPathToImage() {
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.fillColor = ApplicationSettings.appClearColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        layer.addSublayer(shapeLayer)
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first as UITouch? {
            let touchPoint = touch.location(in: self)
            if isLogEnabled {
                debugPrint("touch begin to : \(touchPoint)")
            }
            path.move(to: touchPoint)
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchPoint = touch.location(in: self)
            if isLogEnabled {
                print("touch moved to : \(touchPoint)")
            }
            path.addLine(to: touchPoint)
            addNewPathToImage()
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchPoint = touch.location(in: self)
            if isLogEnabled {
                print("touch ended at : \(touchPoint)")
            }
            path.addLine(to: touchPoint)
            addNewPathToImage()
            path.close()
            delegate?.didEndCropping(croppedImage: cropImage())
        }
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchPoint = touch.location(in: self)
            if isLogEnabled {
                print("touch canceled at : \(touchPoint)")
            }
            path.close()
            delegate?.didEndCropping(croppedImage: cropImage())
        }
    }
}

class ImageCropperVC: UIViewController {
    
    public weak var delegate: ImageCropperDelegate?
    
    @IBOutlet weak var imageView: ImageCropperView! {
        didSet {
            imageView.delegate = self
        }
    }
    
    public var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = image
    }
    
    deinit {
        print("Deinit \(self.description)")
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension ImageCropperVC: ImageCropperDelegate {
    
    func didEndCropping(croppedImage: UIImage?) {
        self.delegate?.didEndCropping(croppedImage: croppedImage)
        self.navigationController?.popViewController(animated: false)
    }
    
}
