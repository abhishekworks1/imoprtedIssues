import CoreGraphics
import Accelerate
import CoreImage
import UIKit

extension CGImage {
    
    public enum ImageError: Swift.Error {
        case imageResizingFailed
        case cgContextCreationFailed
        case pngDataCreationFailed
    }
    
    public enum ResizeTechnique {
        case uiKit
        case coreImage
        case coreGraphics
        case imageIO
        case accelerate
    }
    
    /// Resize image from given size.
    ///
    /// - Parameter maxPixels: Max pixels in the output image. If input image pixel count is less than maxPixels value then it won'n be risezed.
    /// - Parameter resizeTechnique: Technique for image resizing: UIKit / CoreImage / CoreGraphics / ImageIO / Accelerate.
    /// - Returns: Resized image.
    public func resize(maxPixels: Int,
                       with resizeTechnique: ResizeTechnique) throws -> CGImage {
        let pixelCount = self.width * self.height
        if pixelCount > maxPixels {
            let sizeRatio = sqrt(Double(maxPixels) / Double(pixelCount))
            let newWidth = Int(Double(self.width) * sizeRatio)
            let newHeight = Int(Double(self.height) * sizeRatio)
            return try self.resized(to: .init(width: newWidth, height: newHeight), with: resizeTechnique)
        }
        return self
    }
    
    /// Resize image from given size.
    ///
    /// - Parameter newSize: Size of the image output.
    /// - Parameter resizeTechnique: Technique for image resizing: UIKit / CoreImage / CoreGraphics / ImageIO / Accelerate.
    /// - Returns: Resized image.
    public func resized(to newSize: CGSize,
                        with resizeTechnique: ResizeTechnique) throws -> CGImage {
        switch resizeTechnique {
        case .uiKit:
            return try self.resizeWithUIKit(to: newSize)
        case .coreGraphics:
            return try self.resizeWithCoreGraphics(to: newSize)
        case .coreImage:
            return try self.resizeWithCoreImage(to: newSize)
        case .imageIO:
            return try self.resizeWithImageIO(to: newSize)
        case .accelerate:
            return try self.resizeWithAccelerate(to: newSize)
        }
    }
    
    // MARK: - UIKit
    private func resizeWithUIKit(to newSize: CGSize) throws -> CGImage {
        guard let resultCGImage = try UIImage(cgImage: self).resized(to: newSize, with: .uiKit) .cgImage else {
            throw ImageError.imageResizingFailed
        }
        return resultCGImage
    }
    
    // MARK: - CoreImage
    private func resizeWithCoreImage(to newSize: CGSize) throws -> CGImage {
        let ciImage = CIImage(cgImage: self)
        let scale = (Double)(newSize.width) / (Double)(ciImage.extent.size.width)
        let context = CIContext(options: [.useSoftwareRenderer: false])
        let filter = CIFilter(name: "CILanczosScaleTransform")!
        filter.setValue(ciImage,
                        forKey: kCIInputImageKey)
        filter.setValue(NSNumber(value:scale),
                        forKey: kCIInputScaleKey)
        filter.setValue(1.0,
                        forKey: kCIInputAspectRatioKey)
        guard let outputImage = filter.value(forKey: kCIOutputImageKey) as? CIImage,
              let resultCGImage = context.createCGImage(outputImage,
                                                        from: outputImage.extent) else {
            throw ImageError.imageResizingFailed
        }
        return resultCGImage
    }
    
    // MARK: - CoreGraphics
    private func resizeWithCoreGraphics(to newSize: CGSize) throws -> CGImage {
        guard let colorSpace = self.colorSpace,
              let context = CGContext(data: nil,
                                      width: Int(newSize.width),
                                      height: Int(newSize.height),
                                      bitsPerComponent: self.bitsPerComponent,
                                      bytesPerRow: self.bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: self.bitmapInfo.rawValue) else {
            throw ImageError.cgContextCreationFailed
        }
        context.interpolationQuality = .high
        context.draw(self, in: .init(origin: .zero, size: newSize))
        guard let resultCGImage = context.makeImage() else {
            throw ImageError.cgContextCreationFailed
        }
        return resultCGImage
    }
    
    // MARK: - ImageIO
    private func resizeWithImageIO(to newSize: CGSize) throws -> CGImage {
        guard let pngData = CFDataCreateMutable(nil, 0),
              let destination = CGImageDestinationCreateWithData(pngData,
                                                                 "public.png" as CFString,
                                                                 1,
                                                                 nil) else {
            throw ImageError.pngDataCreationFailed
        }
        CGImageDestinationAddImage(destination, self, nil)
        guard CGImageDestinationFinalize(destination) else {
            throw ImageError.pngDataCreationFailed
        }
        let options = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: max(newSize.width,
                                                     newSize.height)
        ] as CFDictionary
        guard let source = CGImageSourceCreateWithData(pngData, nil),
              let resultCGImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else {
            throw ImageError.imageResizingFailed
        }
        return resultCGImage
    }
    
    // MARK: - Accelerate
    private func resizeWithAccelerate(to newSize: CGSize) throws -> CGImage {
        guard let colorSpace = self.colorSpace else {
            throw ImageError.imageResizingFailed
        }
        var format = vImage_CGImageFormat(bitsPerComponent: numericCast(self.bitsPerComponent),
                                          bitsPerPixel: numericCast(self.bitsPerPixel),
                                          colorSpace: Unmanaged.passUnretained(colorSpace),
                                          bitmapInfo: self.bitmapInfo,
                                          version: 0,
                                          decode: nil,
                                          renderingIntent: .defaultIntent)
        var sourceBuffer = vImage_Buffer()
        defer { sourceBuffer.data.deallocate() }
        var error = vImageBuffer_InitWithCGImage(&sourceBuffer,
                                                 &format,
                                                 nil,
                                                 self,
                                                 numericCast(kvImageNoFlags))
        guard error == kvImageNoError else {
            throw ImageError.imageResizingFailed
        }
        let destinationWidth = Int(newSize.width)
        let destinationHeight = Int(newSize.height)
        let bytesPerPixel = self.bitsPerPixel
        let destinationBytesPerRow = destinationWidth * bytesPerPixel
        let destData = UnsafeMutablePointer<UInt8>.allocate(capacity: destinationHeight * destinationBytesPerRow)
        defer { destData.deallocate() }
        var destBuffer = vImage_Buffer(data: destData,
                                       height: vImagePixelCount(destinationHeight),
                                       width: vImagePixelCount(destinationWidth),
                                       rowBytes: destinationBytesPerRow)
        error = vImageScale_ARGB8888(&sourceBuffer,
                                     &destBuffer,
                                     nil,
                                     numericCast(kvImageHighQualityResampling))
        guard error == kvImageNoError else {
            throw ImageError.imageResizingFailed
        }
        guard let resultCGImage = vImageCreateCGImageFromBuffer(&destBuffer,
                                                                &format,
                                                                nil,
                                                                nil,
                                                                numericCast(kvImageNoFlags),
                                                                &error)?.takeRetainedValue() else {
            throw ImageError.imageResizingFailed
        }
        return resultCGImage
    }
    
}
