//
//  CameraView.swift
//  ProManager
//
//  Created by Viraj Patel on 09/08/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit
import AVKit

public class CameraView: UIView, AVCapturePhotoCaptureDelegate {
    
    class func instanceFromNib() -> CameraView {
        return R.nib.cameraView.firstView(owner: nil) ?? CameraView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
    }
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            self.imageView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var cameraView: UIView!
    
    public var shouldCancelShow = false
    public var loadingViewShow = false
    var isResized = true
    var containerView: LoadingContainerView?
    public var shouldDimBackground = true
    public var dimBackgroundColor = ApplicationSettings.appBlackColor.withAlphaComponent(0.6)
    public var isBlocking = true
    public var shouldTapToDismiss = false
    public var sizeInContainer: CGSize = CGSize(width: 180, height: 180)
    
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let avCapture = AVCaptureVideoPreviewLayer(session: session)
        avCapture.videoGravity = .resizeAspectFill
        return avCapture
    }()
    
    private let captureDevice: AVCaptureDevice? = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    private lazy var session: AVCaptureSession = {
        let avCaptureSession = AVCaptureSession()
        avCaptureSession.sessionPreset = .vga640x480
        return avCaptureSession
    }()
    
    private lazy var cameraOutput: AVCapturePhotoOutput = {
        let output = AVCapturePhotoOutput.init()
        return output
    }()
    
    var cameraClick: ((UIImage) -> Void)?
    var isSnapshoot = false
    var tapCount = 0
    var isRoundView = false
   
    deinit {
        print("Deinit \(self.description)")
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    public override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open func setup() {
        onThirdTap()
        cameraView.contentMode = UIView.ContentMode.scaleAspectFill
        self.beginSession()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture(_:)))
        cameraView.addGestureRecognizer(tapGesture)
    }
    
    /**
     UITapGestureRecognizer - Taping on Objects
     Will make scale scale Effect
     Selecting transparent parts of the imageview won't move the object
     */
    @objc func tapGesture(_ recognizer: UITapGestureRecognizer) {
        scaleEffect(view: self)
    }
    
    // to Override Control Center screen edge pan from bottom
    
    /**
     Scale Effect
     */
    func scaleEffect(view: UIView) {
        view.superview?.bringSubviewToFront(view)
        onTap(UIButton())
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
        let previouTransform =  view.transform
        UIView.animate(withDuration: 0.2,
                       animations: {
                        view.transform = view.transform.scaledBy(x: 1.2, y: 1.2)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.2) {
                            view.transform  = previouTransform
                        }
        })
    }
    
    @objc func onTap(_ sender: UIButton) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layoutIfNeeded()
        self.tapCount = tapCount + 1
        self.onTapWith(tapCount)
        self.layoutIfNeeded()
        self.translatesAutoresizingMaskIntoConstraints = true
    }
    
    func onTapWith(_ tapCount: Int) {
        if tapCount % 3 == 1 {
            onFirstTap()
        } else if tapCount % 3 == 2 {
            onSecondTap()
        } else if tapCount % 3 == 0 {
            onThirdTap()
        }
    }
    
    func onFirstTap() {
        let opacity: CGFloat = 0.6
        let borderColor = ApplicationSettings.appWhiteColor
        cameraView.layer.borderColor = borderColor.withAlphaComponent(opacity).cgColor
        cameraView.borderWidthV = 15
        cameraView.cornerRadiusV = cameraView.height / 2
        isRoundView = true
    }
    
    func onSecondTap() {
        cameraView.borderColorV = ApplicationSettings.appWhiteColor
        cameraView.borderWidthV = 4
        cameraView.cornerRadiusV = 0
        isRoundView = false
    }
    
    func onThirdTap() {
        cameraView.borderColorV = ApplicationSettings.appWhiteColor
        cameraView.borderWidthV = 4
        cameraView.cornerRadiusV = cameraView.height / 2
        isRoundView = true
    }
    
    // Camera Capture requiered properties
    private func beginSession() {
        do {
            guard let captureDevice = captureDevice else {
                return
            }
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            if session.canAddInput(deviceInput) {
                session.addInput(deviceInput)
            }
            
            if (session.canAddOutput(cameraOutput)) {
                session.addOutput(cameraOutput)
            }
            
            cameraView.layer.masksToBounds = true
            cameraView.layer.addSublayer(previewLayer)
            
            previewLayer.frame = bounds
            session.startRunning()
        } catch let error {
            debugPrint("\(self.self): \(#function) line: \(#line).  \(error.localizedDescription)")
        }
    }
    
    func convert(cmage: CIImage) -> UIImage {
        let context: CIContext = CIContext.init(options: nil)
        let cgImage: CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image: UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    // clean up AVCapture
    func stopCamera() {
        session.stopRunning()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if isRoundView {
            cameraView.cornerRadiusV = cameraView.height / 2
        }
        previewLayer.frame = cameraView.bounds
    }
    
    public func showOnKeyWindow(completion: (() -> Void)? = nil) {
        show(on: UIApplication.shared.keyWindow!, completion: completion)
    }
    
    public func show(on view: UIView, completion: (() -> Void)? = nil) {
        
        var targetView = view
        if let view = view as? UIScrollView, let superView = view.superview {
            targetView = superView
        }
        // Remove existing container views
        let containerViews = targetView.subviews.filter { view -> Bool in
            return view is LoadingContainerView
        }
        containerViews.forEach { view in
            if let view = view as? LoadingContainerView { view.free() }
        }
        
        backgroundColor = ApplicationSettings.appClearColor
        sizeInContainer = view.frame.size
        
        completion?()
    }
    
    static public func hideFromKeyWindow() {
        hide(from: UIApplication.shared.keyWindow!)
    }
    
    static public func hide(from view: UIView) {
        let containerViews = view.subviews.filter { (view) -> Bool in
            return view is LoadingContainerView
        }
        containerViews.forEach { (view) in
            if let containerView = view as? LoadingContainerView {
                containerView.loadingView.hide()
            }
        }
    }
    
    @objc open func hide() {
        hideContainerView()
    }
    
    fileprivate func showContainerView() {
        if let containerView = containerView {
            containerView.isHidden = false
            containerView.alpha = 0.0
            UIView.animate(withDuration: 0.2) {
                containerView.alpha = 1.0
            }
        }
    }
    
    fileprivate func hideContainerView() {
        if let containerView = containerView {
            UIView.animate(withDuration: 0.2, animations: {
                containerView.alpha = 0.0
            }, completion: { _ in
                containerView.free()
            })
        }
    }
    
    @IBAction func btnCameraClick(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings()
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
            kCVPixelBufferWidthKey as String: 480,
            kCVPixelBufferHeightKey as String: 640
        ]
        settings.previewPhotoFormat = previewFormat
        guard captureDevice != nil else {
            return
        }
        
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        let dataProvider = CGDataProvider(data: imageData as CFData)
        let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImage.Orientation.leftMirrored)
        
        imageView.image = image
        AudioServicesPlaySystemSound(1108)
        self.cameraClick!(image)
        previewLayer.removeFromSuperlayer()
        stopCamera()
        btnCamera.isHidden = true
    }
    
}
