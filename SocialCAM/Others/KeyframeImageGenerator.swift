//
//  KeyframeImageGenerator.swift
//  ProManager
//
//  Created by Viraj Patel on 26/09/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import AVKit
import UIKit

/// keyframe image model
open class KeyframeImage: NSObject {
    
    /// image of keyframe
    public var image: UIImage
    
    /// time of wanted
    public var requestedTime: CMTime
    
    /// time of actual
    public var actualTime: CMTime
    
    /// Init Method
    public init(image: UIImage, requestedTime: CMTime, actualTime: CMTime) {
        self.image = image
        self.requestedTime = requestedTime
        self.actualTime = actualTime
    }
}

/// closure type of generate single image
public typealias SingleImageClosure = (KeyframeImage?) -> Void
/// closure type of generate sequence of image
public typealias SequenceOfImagesClosure = ([KeyframeImage]) -> Void

/// generate keyframe image
open class KeyframeImageGenerator: NSObject {
    
    /// generate image of second
    ///
    /// - parameter asset:     AVAsset
    /// - parameter second:    wanted time, default 0
    /// - parameter closure:   completed handler
    open func generateSingleImage(from asset: AVAsset, second: Float64 = 0, closure: @escaping SingleImageClosure) {
        let requestedTime = CMTimeMakeWithSeconds(second, preferredTimescale: asset.duration.timescale)
        
        generateSingleImage(from: asset, time: requestedTime, closure: closure)
    }
    
    /// generate image of time
    ///
    /// - parameter asset:   AVAsset
    /// - parameter time:    wanted time, default CMTime.zero
    /// - parameter closure: completed handler
    open func generateSingleImage(from asset: AVAsset, time: CMTime = CMTime.zero, closure: @escaping SingleImageClosure) {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.requestedTimeToleranceBefore = CMTime.zero
        imageGenerator.requestedTimeToleranceAfter = CMTime.zero
        
        imageGenerator.appliesPreferredTrackTransform = true
        
        var actualTime: CMTime = CMTimeMake(value: 0, timescale: asset.duration.timescale)
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
            let image = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
            let keyframeImage = KeyframeImage(image: image, requestedTime: time, actualTime: actualTime)
            
            //callback on main queue
            DispatchQueue.main.async {
                closure(keyframeImage)
            }
        } catch {
            
            //callback on main queue
            DispatchQueue.main.async {
                closure(nil)
            }
        }
    }
    
    /// generate images of times
    ///
    /// - parameter asset:     AVAsset
    /// - parameter seconds:   seconds
    /// - parameter closure:   completed handler
    open func generateSequenceOfImages(from asset: AVAsset, seconds: [Float64], closure: @escaping SequenceOfImagesClosure) {
        
        let times = seconds.map { CMTimeMakeWithSeconds($0, preferredTimescale: asset.duration.timescale) }
        
        generateSequenceOfImages(from: asset, times: times, closure: closure)
    }
    
    /// generate images of times
    ///
    /// - parameter asset:   AVAsset
    /// - parameter times:   [CMTime]
    /// - parameter closure: completed handler
    open func generateSequenceOfImages(from asset: AVAsset, times: [CMTime], closure: @escaping SequenceOfImagesClosure) {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.requestedTimeToleranceBefore = CMTime.zero
        imageGenerator.requestedTimeToleranceAfter = CMTime.zero
        
        imageGenerator.appliesPreferredTrackTransform = true
        
        let timeValues = times.map { NSValue(time: $0) }
        
        var keyframeImages: [KeyframeImage] = []
        //completed count(success and failed)
        var completedCount = 0
        imageGenerator.generateCGImagesAsynchronously(forTimes: timeValues) {
            (requestedTime, cgImage, actualTime, result, _) in
            //increase completed count
            completedCount += 1
            
            if result == .succeeded, let cgImage = cgImage {
                let image = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
                let keyframeImage = KeyframeImage(image: image, requestedTime: requestedTime, actualTime: actualTime)
                keyframeImages.append(keyframeImage)
            }
            
            //complete if completedCount equal to requestedTimes count
            if completedCount == timeValues.count {
                //sorted with Asc
                let sortedKeyframeImages = keyframeImages.sorted {
                    $0.actualTime.seconds < $1.actualTime.seconds
                }
                
                //perform on main queue
                DispatchQueue.main.async {
                    closure(sortedKeyframeImages)
                }
            }
        }
    }
    
    /// generate default images with asset(like iPhone photo library)
    ///
    /// - parameter asset:   AVAsset
    /// - parameter closure: completed handler
    open func generateDefaultSequenceOfImages(from asset: AVAsset, closure: @escaping SequenceOfImagesClosure) {
        let second = Int(asset.duration.seconds)
        let maxCount = 20
        var requestedCount = 0
        if second <= 5 {
            requestedCount = second + 1
        } else {
            requestedCount = min(second * 2, maxCount)
        }
        
        let spacing = asset.duration.seconds / Float64(requestedCount)
        var seconds: [Float64] = []
        for index in 0..<requestedCount {
            seconds.append(Float64(index) * spacing)
        }
        
        generateSequenceOfImages(from: asset, seconds: seconds, closure: closure)
    }
}
