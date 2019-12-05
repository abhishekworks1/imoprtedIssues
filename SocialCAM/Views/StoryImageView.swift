//
//  StoryImageView.swift
//  SCRecorder_Swift
//
//  Created by Jasmin Patel on 09/10/18.
//  Copyright © 2018 Simform. All rights reserved.
//

import UIKit
import CoreMedia
import MetalKit

class StoryImageView: UIView {
    
    public enum ImageContentMode : Int {
        
        case scaleToFill
        
        case scaleAspectFit

        case scaleAspectFill
        
    }
    
    struct ImageTransformation {
        
        var tx: CGFloat
        var ty: CGFloat
        var scaleX: CGFloat
        var scaleY: CGFloat
        var rotation: CGFloat
        
    }
    
    public var mtkView: MTKView?
    
    public var mtlCommandQueue: MTLCommandQueue?
    /**
     The MTLDevice
     */
    private(set) var mtlDevice: MTLDevice?
    /**
     The StoryContext that hold the underlying CIContext for rendering the CIImage's
     Will be automatically loaded when setting the first CIImage or when rendering
     for the first if using a CoreGraphics context type.
     You can also set your own context.
     Supported contexts are Metal, CoreGraphics, EAGL
     */
    public var ciContext: CIContext? {
        didSet {
            unloadContext()
            if ciContext != nil {
                mtlCommandQueue = self.mtlDevice?.makeCommandQueue()
                mtkView = MTKView(frame: self.bounds, device: self.mtlDevice)
                mtkView?.clearColor = MTLClearColorMake(0, 0, 0, 0)
                mtkView?.contentScaleFactor = self.contentScaleFactor
                mtkView?.delegate = self
                mtkView?.enableSetNeedsDisplay = true
                mtkView?.framebufferOnly = false
                self.insertSubview(mtkView!, at: 0)
            }
        }
    }
    /**
     The CIImage to render.
     */
    public var ciImage: CIImage? {
        didSet {
            if self.ciImage != nil {
                _ = loadContextIfNeeded()
            }
            setNeedsDisplay()
        }
    }
    /**
     The preferred transform for rendering the CIImage
     */
    public var preferredCIImageTransform: CGAffineTransform = .identity
    /**
     ContentMode for rendering the CIImage
     */
    public var imageContentMode: StoryImageView.ImageContentMode = .scaleAspectFit
    
    public var imageTransformation: StoryImageView.ImageTransformation?

    override func layoutSubviews() {
        super.layoutSubviews()
        mtkView?.frame = bounds
    }
    
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        mtkView?.setNeedsDisplay()
    }
    
    /**
     Set the CIImage using an UIImage
     */
    public func setImageBy(_ image: UIImage) {
        preferredCIImageTransform = image.preferredCIImageTransform
        if let anImage = image.cgImage {
            ciImage = CIImage(cgImage: anImage)
        }
    }
    /**
     Set the CIImage using a sampleBuffer
     */
    public func setImageBy(_ sampleBuffer: CMSampleBuffer) {
        if let cvPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            self.ciImage = CIImage(cvPixelBuffer: cvPixelBuffer)
        }
        setNeedsDisplay()
    }
    /**
     Returns the rendered CIImage in the given rect.
     Subclass can override this method to alterate the rendered image.
     */
    func renderedCIImage(in rect: CGRect) -> CIImage? {
        guard var image = self.ciImage else {
            return nil
        }
        image = image.transformed(by: preferredCIImageTransform)
        image = image.transformed(by: scaleAndResizeTransform(image, for: rect))
        image = applyTransformationIfNeeded(image)
        return image
    }
    
    /**
     Returns the rendered CIImage in its natural size.
     Subclass should not override this method.
     */
    func renderedCIImage() -> CIImage? {
        guard let ciImage = self.ciImage else {
            return nil
        }
        return self.renderedCIImage(in: ciImage.extent)
    }
    
    /**
     Returns the rendered UIImage in its natural size.
     Subclass should not override this method.
     */
    func renderedUIImage() -> UIImage? {
        guard let ciImage = self.ciImage else {
            return nil
        }
        var returnedImage: UIImage?

        let rect = mtkView?.bounds.multiply(with: contentScaleFactor) ?? ciImage.extent
        var image = renderedCIImage(in: rect)
        if let scaleFactor = self.mtkView?.contentScaleFactor {
            let mtkRect = mtkView?.bounds.multiply(with: scaleFactor) ?? ciImage.extent
            image = image?.transformed(by: CGAffineTransform(scaleX: mtkRect.size.width/image!.extent.width, y: mtkRect.size.height/image!.extent.height))
        }
        #if targetEnvironment(simulator)
        image = image?.transformed(by: CGAffineTransform(scaleX: 1, y: -1))
        #endif
        if let anImage = image {
            var context: CIContext?
            if !loadContextIfNeeded() {
                context = CIContext(options: [CIContextOption.useSoftwareRenderer: false])
            } else {
                context = self.ciContext
            }
            let imageRef = context?.createCGImage(anImage, from: anImage.extent)
            if let aRef = imageRef {
                returnedImage = UIImage(cgImage: aRef)
            }
        }
        
        return returnedImage
    }
    /**
     Create the CIContext and setup the underlying rendering views. This is automatically done when setting an CIImage
     for the first time to make the initialization faster. If for some reasons you want it to be done earlier
     you can call this method.
     Returns whether the context has been successfully loaded, returns NO otherwise.
     */
    public func loadContextIfNeeded() -> Bool {
        guard CIContext.self.responds(to: #selector(CIContext.init(mtlDevice:options:))) else {
            return false
        }
        if ciContext == nil {
            self.mtlDevice = MTLCreateSystemDefaultDevice()
            if let device = self.mtlDevice {
                self.ciContext = CIContext(mtlDevice: device,
                                           options: [CIContextOption.workingColorSpace : NSNull(),
                                                     CIContextOption.outputColorSpace : NSNull()])
            }
        }
        return true
    }
    
    func unloadContext() {
        if mtkView != nil {
            mtlCommandQueue = nil
            mtkView?.removeFromSuperview()
            mtkView?.releaseDrawables()
            mtkView = nil
        }
    }
}
// MARK:
extension StoryImageView {
    
    func scaleAndResizeTransform(_ image: CIImage, for rect: CGRect) -> CGAffineTransform {
        let imageSize = image.extent.size
        
        var horizontalScale: CGFloat = rect.size.width / imageSize.width
        var verticalScale: CGFloat = rect.size.height / imageSize.height
        
        if imageContentMode == .scaleAspectFill {
            horizontalScale = max(horizontalScale, verticalScale)
            verticalScale = horizontalScale
        } else if imageContentMode == .scaleAspectFit {
            horizontalScale = min(horizontalScale, verticalScale)
            verticalScale = horizontalScale
        }
        return CGAffineTransform(scaleX: horizontalScale, y: verticalScale)
    }
    
    func applyTransformationIfNeeded(_ image: CIImage) -> CIImage {
        let backgroundImage = #imageLiteral(resourceName: "videoBackground")

        guard let cgBackgroundImage = backgroundImage.cgImage,
            let transformation = self.imageTransformation else {
                return image
        }

        let backgroundCIImage = CIImage(cgImage: cgBackgroundImage)
        let backgroundCIImageWidth = backgroundCIImage.extent.width
        let backgroundCIImageHeight = backgroundCIImage.extent.height

        var overlayCIImage = image

        let scaleTransform = scaleAndResizeTransform(overlayCIImage, for: backgroundCIImage.extent)
        overlayCIImage = overlayCIImage.transformed(by: scaleTransform)

        overlayCIImage = overlayCIImage.transformed(by: CGAffineTransform(scaleX: transformation.scaleX, y: transformation.scaleY))

        overlayCIImage = overlayCIImage.transformed(by: CGAffineTransform(translationX: 0, y: backgroundCIImageHeight/2 - overlayCIImage.extent.height/2))

        overlayCIImage = overlayCIImage.transformed(by: CGAffineTransform(rotationAngle: -transformation.rotation))

        let txValue = (backgroundCIImageWidth*transformation.tx/100) - overlayCIImage.extent.origin.x
        let tyValue = backgroundCIImageHeight - (backgroundCIImageHeight*transformation.ty/100) - overlayCIImage.extent.height - overlayCIImage.extent.origin.y

        overlayCIImage = overlayCIImage.transformed(by: CGAffineTransform(translationX: txValue, y: tyValue))

        var combinedCIImage = overlayCIImage.composited(over: backgroundCIImage)
        combinedCIImage = combinedCIImage.cropped(to: backgroundCIImage.extent)

        #if targetEnvironment(simulator)
        combinedCIImage = combinedCIImage.transformed(by: CGAffineTransform(scaleX: 1, y: -1))
        #endif

        return combinedCIImage
    }
    
}
// MARK: MTKViewDelegate
extension StoryImageView: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        autoreleasepool {
            let rect = view.bounds.multiply(with: contentScaleFactor)
            
            var image = renderedCIImage(in: rect)
            
            if image != nil {
                if let scaleFactor = self.mtkView?.contentScaleFactor {
                    let mtkRect = view.bounds.multiply(with: scaleFactor)
                    var horizontalScale: CGFloat = mtkRect.size.width / image!.extent.width
                    var verticalScale: CGFloat = mtkRect.size.height / image!.extent.height

                    if contentMode == .scaleAspectFill {
                        horizontalScale = max(horizontalScale, verticalScale)
                        verticalScale = horizontalScale
                    } else if contentMode == .scaleAspectFit {
                        horizontalScale = min(horizontalScale, verticalScale)
                        verticalScale = horizontalScale
                    }
                    image = image?.transformed(by: CGAffineTransform(scaleX: horizontalScale, y: verticalScale))
                }
                let commandBuffer = mtlCommandQueue?.makeCommandBuffer()
                let texture = view.currentDrawable?.texture
                let deviceRGB = CGColorSpaceCreateDeviceRGB()
                ciContext?.render(image!, to: texture!, commandBuffer: commandBuffer, bounds: image!.extent, colorSpace: deviceRGB)
                commandBuffer?.present(view.currentDrawable!)
                commandBuffer?.commit()
            }
        }
    }
    
}
