//
//  CIFilter.swift
//  ProManager
//
//  Created by Jasmin Patel on 25/07/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import CoreImage
import UIKit
import Foundation

extension CALayer {
    var borderUIColor: UIColor {
        set {
            self.borderColor = newValue.cgColor
        }
        get {
            return UIColor(cgColor: self.borderColor!)
        }
    }
}

extension CIFilter {
    
    class func filter(from lutImage: UIImage, dimension: Int = 64) -> CIFilter? {
        guard let lutCGImage = lutImage.cgImage else {
            return nil
        }
        let lutWidth = lutCGImage.width
        let lutHeight = lutCGImage.height
        let rowCount = lutHeight / dimension
        let columnCount = lutWidth / dimension
        
        if (lutWidth % dimension != 0) || (lutHeight % dimension != 0) || (rowCount * columnCount != dimension) {
            return nil
        }
        
        guard let bitmap = imageBytes(from: lutCGImage) else {
            return nil
        }
        
        let floatSize = MemoryLayout<Float>.size
        
        let cubeData = UnsafeMutablePointer<Float>.allocate(capacity: dimension * dimension * dimension * 4 * floatSize)
        var zIndex = 0
        var bitmapOffset = 0
        
        for _ in 0 ..< rowCount {
            for yIndex in 0 ..< dimension {
                let tmp = zIndex
                for _ in 0 ..< columnCount {
                    for xIndex in 0 ..< dimension {
                        
                        let alpha   = Float(bitmap[bitmapOffset]) / 255.0
                        let red     = Float(bitmap[bitmapOffset+1]) / 255.0
                        let green   = Float(bitmap[bitmapOffset+2]) / 255.0
                        let blue    = Float(bitmap[bitmapOffset+3]) / 255.0
                        
                        let dataOffset = (zIndex*dimension*dimension + yIndex*dimension + xIndex) * 4
                        
                        cubeData[dataOffset + 3] = alpha
                        cubeData[dataOffset + 2] = red
                        cubeData[dataOffset + 1] = green
                        cubeData[dataOffset + 0] = blue
                        bitmapOffset += 4
                    }
                    zIndex += 1
                }
                zIndex = tmp
            }
            zIndex += columnCount
        }
        
        let colorCubeData = NSData(bytesNoCopy: cubeData, length: dimension * dimension * dimension * 4 * floatSize, freeWhenDone: true)
        
        // create CIColorCube Filter
        let filter = CIFilter(name: "CIColorCube")
        filter?.setValue(colorCubeData, forKey: "inputCubeData")
        filter?.setValue(dimension, forKey: "inputCubeDimension")

        return filter
    }
    
    class func imageBytes(from lutCGImage: CGImage) -> [UInt8]? {
        let width = Int(lutCGImage.width)
        let height = Int(lutCGImage.height)
        let bitsPerComponent = 8
        let bytesPerRow = width * 4
        let totalBytes = height * bytesPerRow
        
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var intensities = [UInt8](repeating: 0, count: totalBytes)
        
        let contextRef = CGContext(data: &intensities, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        contextRef?.draw(lutCGImage, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))
        
        return intensities
    }
    
}
