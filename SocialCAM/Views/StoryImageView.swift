//
//  StoryImageView.swift
//  SCRecorder_Swift
//
//  Created by Jasmin Patel on 09/10/18.
//  Copyright © 2018 Simform. All rights reserved.
//

import UIKit
import CoreMedia
#if !targetEnvironment(simulator)
import MetalKit
#endif
class StoryImageView: UIView {
    
    /**
     The context type to use when loading the context.
     */
    public var contextType: StoryContextType = .auto {
        didSet {
            self.context = nil
        }
    }
    /**
     The StoryContext that hold the underlying CIContext for rendering the CIImage's
     Will be automatically loaded when setting the first CIImage or when rendering
     for the first if using a CoreGraphics context type.
     You can also set your own context.
     Supported contexts are Metal, CoreGraphics, EAGL
     */
    public var context: StoryContext? {
        didSet {
            unloadContext()
            if context != nil {
                switch context!.type {
                case .coreGraphics:
                    break
                    #if !targetEnvironment(simulator)
                case .metal:
                    mtlCommandQueue = self.context?.mtlDevice?.makeCommandQueue()
                    mtkView = MTKView.init(frame: self.bounds, device: self.context!.mtlDevice!)
                    mtkView?.clearColor = MTLClearColorMake(0, 0, 0, 0)
                    mtkView?.contentScaleFactor = self.contentScaleFactor
                    mtkView?.delegate = self
                    mtkView?.enableSetNeedsDisplay = true
                    mtkView?.framebufferOnly = false
                    self.insertSubview(mtkView!, at: 0)
                    #endif
                default:
                    fatalError("InvalidContext : Unsupported context type: \(String(describing: context?.type ?? StoryContextType(rawValue: 0))). StoryImageView only supports CoreGraphics, EAGL and Metal")
                }
            } else {
                glImageView = GLImageView.init(frame: self.bounds)
                self.insertSubview(glImageView!, at: 0)
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
            #if targetEnvironment(simulator)
            if glImageView == nil {
                glImageView = GLImageView.init(frame: self.bounds)
                self.insertSubview(glImageView!, at: 0)
            }
            glImageView?.image = self.ciImage
            #endif
            setNeedsDisplay()
        }
    }
    /**
     The preferred transform for rendering the CIImage
     */
    public var preferredCIImageTransform: CGAffineTransform = .identity
    /**
     Whether the CIImage should be scaled and resized according to the contentMode of this view.
     Default is YES.
     */
    public var scaleAndResizeCIImageAutomatically = true
    
    #if !targetEnvironment(simulator)
    public var mtkView: MTKView?
    public var mtlCommandQueue: MTLCommandQueue?
    #endif
    
    public var glImageView: GLImageView?
    public var currentSampleBuffer: CMSampleBuffer?

    override func layoutSubviews() {
        super.layoutSubviews()
        #if !targetEnvironment(simulator)
        mtkView?.frame = bounds
        #endif
        glImageView?.frame = bounds
    }
    
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        #if !targetEnvironment(simulator)
        mtkView?.setNeedsDisplay()
        #endif
        glImageView?.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if (ciImage != nil || currentSampleBuffer != nil) && loadContextIfNeeded() {
            if context?.type == .coreGraphics,
                let image = renderedCIImage(in: rect) {
                #if arch(i386) || arch(x86_64)
                
                //simulator
                #else
                context?.ciContext?.draw(image, in: rect, from: image.extent)
                #endif
                
            }
        }
    }
    /**
     Set the CIImage using an UIImage
     */
    public func setImageBy(_ image: UIImage?) {
        if image == nil {
            ciImage = nil
        } else {
            preferredCIImageTransform = image!.preferredCIImageTransform
            if let anImage = image?.cgImage {
                ciImage = CIImage(cgImage: anImage)
            }
        }
    }
    /**
     Set the CIImage using a sampleBuffer. The CIImage will be automatically generated
     when needed. This avoids creating multiple CIImage if the StoryImageView can't render them
     as fast.
     */
    public func setImageBy(_ sampleBuffer: CMSampleBuffer?) {
        if let aBuffer = sampleBuffer {
            currentSampleBuffer = aBuffer
        }
        setNeedsDisplay()
    }
    /**
     Returns the rendered CIImage in the given rect.
     Subclass can override this method to alterate the rendered image.
     */
    func renderedCIImage(in rect: CGRect) -> CIImage? {
        if let sampleBuffer = currentSampleBuffer {
            self.ciImage = CIImage(cvPixelBuffer: CMSampleBufferGetImageBuffer(sampleBuffer)!)
            currentSampleBuffer = nil
        }
        guard var image = self.ciImage else {
            return nil
        }
        image = image.transformed(by: preferredCIImageTransform)
        if context?.type != .metal {
            image = image.oriented(forExifOrientation: 4)
        }
        if scaleAndResizeCIImageAutomatically {
            image = scaleAndResize(image, for: rect)
        }
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
    
    func scaleAndResize(_ image: CIImage, for rect: CGRect) -> CIImage {
        let imageSize = image.extent.size
        
        var horizontalScale: CGFloat = rect.size.width / imageSize.width
        var verticalScale: CGFloat = rect.size.height / imageSize.height
        
        if contentMode == .scaleAspectFill {
            horizontalScale = max(horizontalScale, verticalScale)
            verticalScale = horizontalScale
        } else if contentMode == .scaleAspectFit {
            horizontalScale = min(horizontalScale, verticalScale)
            verticalScale = horizontalScale
        }
        return image.transformed(by: CGAffineTransform(scaleX: horizontalScale, y: verticalScale))
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
        #if !targetEnvironment(simulator)
        let rect = mtkView?.bounds.multiply(with: contentScaleFactor) ?? ciImage.extent
        var image = renderedCIImage(in: rect)
        if let scaleFactor = self.mtkView?.contentScaleFactor {
            let mtkRect = mtkView?.bounds.multiply(with: scaleFactor) ?? ciImage.extent
            image = image?.transformed(by: CGAffineTransform(scaleX: mtkRect.size.width/image!.extent.width, y: mtkRect.size.height/image!.extent.height))
        }
        #else
        let rect = ciImage.extent
        let image = renderedCIImage(in: rect)
        #endif
        
        if let anImage = image {
            var context: CIContext?
            if !loadContextIfNeeded() {
                context = CIContext(options: [CIContextOption.useSoftwareRenderer: false])
            } else {
                context = self.context?.ciContext
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
        if context == nil {
            var contextType: StoryContextType = self.contextType
            if contextType == .auto {
                contextType = StoryContext.suggestedContextType()
            }
            var options: [AnyHashable : Any]? = nil
            switch contextType {
            case .coreGraphics:
                let contextRef = UIGraphicsGetCurrentContext()
                if contextRef == nil {
                    return false
                }
                if let aRef = contextRef {
                    options = [StoryContext.StoryContextOptionsCGContextKey: aRef]
                }
            case .cpu:
                fatalError("UnsupportedContextType : StoryImageView does not support CPU context type.")
            default:
                break
            }
            context = StoryContext.contextWithType(contextType, options: options)
        }
        
        return true
    }
    
    func unloadContext() {
        #if !targetEnvironment(simulator)
        if mtkView != nil {
            mtlCommandQueue = nil
            mtkView?.removeFromSuperview()
            mtkView?.releaseDrawables()
            mtkView = nil
        }
        #endif
    }
}
#if !targetEnvironment(simulator)
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
                    image = image?.transformed(by: CGAffineTransform(scaleX: mtkRect.size.width/image!.extent.width, y: mtkRect.size.height/image!.extent.height))
                }
                let commandBuffer = mtlCommandQueue?.makeCommandBuffer()
                let texture = view.currentDrawable?.texture
                let deviceRGB = CGColorSpaceCreateDeviceRGB()
                context?.ciContext.render(image!, to: texture!, commandBuffer: commandBuffer, bounds: image!.extent, colorSpace: deviceRGB)
                commandBuffer?.present(view.currentDrawable!)
                commandBuffer?.commit()
            }
        }
    }
    
}
#endif
