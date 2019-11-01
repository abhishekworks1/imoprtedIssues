//
//  CoreML+Helpers.swift
//  AVBasicVideoOutput
//
//  Created by Jasmin Patel on 21/05/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import CoreGraphics
import CoreImage
import VideoToolbox
import UIKit

extension CVPixelBuffer {
    
    public func mlPixelFormatBuffer(scale: CGFloat = 0.3) -> CVPixelBuffer? {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(self, options: nil, imageOut: &cgImage)
        if let cgImage = cgImage {
            let size = CGSize(width: CVPixelBufferGetWidth(self), height: CVPixelBufferGetHeight(self))
            let targetSize = CGSize(width: floor(size.width * scale), height: floor(size.height * scale))
            
            let widthRatio  = targetSize.width  / size.width
            let heightRatio = targetSize.height / size.height
            
            var newSize: CGSize
            if(widthRatio > heightRatio) {
                newSize = CGSize.init(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize.init(width: size.width * widthRatio, height: size.height * widthRatio)
            }
            
            return cgImage.pixelBuffer(width: Int(newSize.width),
                                       height: Int(newSize.height),
                                       orientation: cgImage.cgOrientation())
        }
        return nil
    }
    
}

extension CGImage {
    
    func cgOrientation() -> CGImagePropertyOrientation {
        
        let image = UIImage(cgImage: self)
        
        switch image.imageOrientation {
        case .down:
            return .down
        case .left:
            return .left
        case .right:
            return .right
        case .up:
            return .up
        case .downMirrored:
            return .downMirrored
        case .leftMirrored:
            return .leftMirrored
        case .rightMirrored:
            return .rightMirrored
        case .upMirrored:
            return .upMirrored
        @unknown default:
            return .down
        }
    }
    
    /**
     Resizes the image to width x height and converts it to an RGB CVPixelBuffer.
     */
    public func pixelBuffer(width: Int, height: Int,
                            orientation: CGImagePropertyOrientation) -> CVPixelBuffer? {
        return pixelBuffer(width: width, height: height,
                           pixelFormatType: kCVPixelFormatType_32ARGB,
                           colorSpace: CGColorSpaceCreateDeviceRGB(),
                           alphaInfo: .noneSkipFirst,
                           orientation: orientation)
    }
    
    /**
     Resizes the image to width x height and converts it to a grayscale CVPixelBuffer.
     */
    public func pixelBufferGray(width: Int, height: Int,
                                orientation: CGImagePropertyOrientation) -> CVPixelBuffer? {
        return pixelBuffer(width: width, height: height,
                           pixelFormatType: kCVPixelFormatType_OneComponent8,
                           colorSpace: CGColorSpaceCreateDeviceGray(),
                           alphaInfo: .none,
                           orientation: orientation)
    }
    
    func pixelBuffer(width: Int, height: Int, pixelFormatType: OSType,
                     colorSpace: CGColorSpace, alphaInfo: CGImageAlphaInfo,
                     orientation: CGImagePropertyOrientation) -> CVPixelBuffer? {
        
        // TODO: If the orientation is not .up, then rotate the CGImage.
        // See also: https://stackoverflow.com/a/40438893/
        assert(orientation == .up)
        
        var maybePixelBuffer: CVPixelBuffer?
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue]
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         width,
                                         height,
                                         pixelFormatType,
                                         attrs as CFDictionary,
                                         &maybePixelBuffer)
        
        guard status == kCVReturnSuccess, let pixelBuffer = maybePixelBuffer else {
            return nil
        }
        
        let flags = CVPixelBufferLockFlags(rawValue: 0)
        guard kCVReturnSuccess == CVPixelBufferLockBaseAddress(pixelBuffer, flags) else {
            return nil
        }
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, flags) }
        
        guard let context = CGContext(data: CVPixelBufferGetBaseAddress(pixelBuffer),
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                      space: colorSpace,
                                      bitmapInfo: alphaInfo.rawValue)
            else {
                return nil
        }
        
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        return pixelBuffer
    }
}

extension CGImage {
    /**
     Creates a new CGImage from a CVPixelBuffer.
     - Note: Not all CVPixelBuffer pixel formats support conversion into a
     CGImage-compatible pixel format.
     */
    public static func create(pixelBuffer: CVPixelBuffer) -> CGImage? {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        return cgImage
    }
    
    /*
     // Alternative implementation:
     public static func create(pixelBuffer: CVPixelBuffer) -> CGImage? {
     // This method creates a bitmap CGContext using the pixel buffer's memory.
     // It currently only handles kCVPixelFormatType_32ARGB images. To support
     // other pixel formats too, you'll have to change the bitmapInfo and maybe
     // the color space for the CGContext.
     guard kCVReturnSuccess == CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly) else {
     return nil
     }
     defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
     if let context = CGContext(data: CVPixelBufferGetBaseAddress(pixelBuffer),
     width: CVPixelBufferGetWidth(pixelBuffer),
     height: CVPixelBufferGetHeight(pixelBuffer),
     bitsPerComponent: 8,
     bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
     space: CGColorSpaceCreateDeviceRGB(),
     bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue),
     let cgImage = context.makeImage() {
     return cgImage
     } else {
     return nil
     }
     }
     */
    
    /**
     Creates a new CGImage from a CVPixelBuffer, using Core Image.
     */
    public static func create(pixelBuffer: CVPixelBuffer, context: CIContext) -> CGImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let rect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer),
                          height: CVPixelBufferGetHeight(pixelBuffer))
        return context.createCGImage(ciImage, from: rect)
    }
}
