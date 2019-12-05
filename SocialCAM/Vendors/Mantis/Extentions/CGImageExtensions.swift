//
//  CGImageExtensions.swift
//  Mantis
//
//  Created by Echo on 10/30/18.
//
//  This class is from CGImage+IGRPhotoTweakExtension.swift in
//  https://github.com/IGRSoft/IGRPhotoTweaks
//
// Copyright Vitalii Parovishnyk. All rights reserved.

import UIKit
import VideoToolbox
import Accelerate

extension CGImage {
    
    func transformedImage(_ transform: CGAffineTransform, zoomScale: CGFloat, isFlipped: Bool, sourceSize: CGSize, cropSize: CGSize, imageViewSize: CGSize) -> CGImage? {
        let expectedWidth = floor(((sourceSize.width / imageViewSize.width * cropSize.width) / zoomScale) / 16) * 16
        let expectedHeight = floor((sourceSize.height / imageViewSize.height * cropSize.height) / zoomScale)

        let outputSize = CGSize(width: expectedWidth, height: expectedHeight)
        let bitmapBytesPerRow = 0
        
        let context = CGContext(data: nil,
                                width: Int(outputSize.width),
                                height: Int(outputSize.height),
                                bitsPerComponent: self.bitsPerComponent,
                                bytesPerRow: bitmapBytesPerRow,
                                space: self.colorSpace!,
                                bitmapInfo: self.bitmapInfo.rawValue)
        context?.setFillColor(UIColor.clear.cgColor)
        context?.fill(CGRect(x: 0,
                             y: 0,
                             width: outputSize.width,
                             height: outputSize.height))
        
        var uiCoords = CGAffineTransform(scaleX: outputSize.width / cropSize.width,
                                         y: outputSize.height / cropSize.height)
        uiCoords = uiCoords.translatedBy(x: cropSize.width / 2, y: cropSize.height / 2)
        uiCoords = uiCoords.scaledBy(x: 1.0, y: -1.0)
        
        context?.concatenate(uiCoords)
        context?.concatenate(transform)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        context?.draw(self, in: CGRect(x: (-imageViewSize.width / 2),
                                       y: (-imageViewSize.height / 2),
                                       width: imageViewSize.width,
                                       height: imageViewSize.height))
        
        var result = context?.makeImage()
        if isFlipped {
            result = result?.flippedImage(isHorizontal: true)
        }
        return result
    }
 
    public func pixelBuffer() -> CVPixelBuffer? {
        return pixelBuffer(width: width, height: height,
                           pixelFormatType: kCVPixelFormatType_32ARGB,
                           colorSpace: CGColorSpaceCreateDeviceRGB(),
                           alphaInfo: .noneSkipFirst)
    }
 
    func pixelBuffer(width: Int, height: Int, pixelFormatType: OSType,
                     colorSpace: CGColorSpace, alphaInfo: CGImageAlphaInfo) -> CVPixelBuffer? {
                
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
    
    public static func create(from pixelBuffer: CVPixelBuffer) -> CGImage? {
      var cgImage: CGImage?
      VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
      return cgImage
    }
    
    func flippedImage(isHorizontal: Bool) -> CGImage? {
        let width = size_t(self.width)
        let height = size_t(self.height)
        let bytesPerRow = size_t(width * 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0 | CGImageAlphaInfo.premultipliedFirst.rawValue) else {
            return nil
        }

        context.draw(self, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        
        guard let data = context.data else {
            return nil
        }
        var src = vImage_Buffer(data: data, height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: bytesPerRow)
        var dest = vImage_Buffer(data: data, height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: bytesPerRow)
        if isHorizontal {
            vImageHorizontalReflect_ARGB8888(&src, &dest, vImage_Flags(kvImageBackgroundColorFill))
        } else {
            vImageVerticalReflect_ARGB8888(&src, &dest, vImage_Flags(kvImageBackgroundColorFill))
        }
        return context.makeImage()
    }

}
