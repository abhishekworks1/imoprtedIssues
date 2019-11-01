//
//  ThumbnailsView.swift
//  TrimmerVideo
//
//  Created by Diego Caroli on 19/09/2018.
//  Copyright © 2018 Diego Caroli. All rights reserved.
//

import UIKit
import AVFoundation

open class ThumbnailsView: UIView {
    
    // MARK: Properties
    private let thumbsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    open var isReloadImages: Bool = false
    
    open var asset: AVAsset! {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    private var assetImageGenerator: AVAssetImageGenerator!
    
    private var thumbnailSize: CGSize {
        get {
            guard let track = asset.tracks(withMediaType: AVMediaType.video).first
                else { return CGSize.zero }
            
            let targetSize = bounds.size
            let assetSize = track.naturalSize.applying(track.preferredTransform)
            
            assert(targetSize.width > 0)
            assert(targetSize.height > 0)
            
            let scaleFactor = targetSize.height / assetSize.height
            let newWidth = assetSize.width * scaleFactor
            return CGSize(width: newWidth,
                          height: assetSize.height)
        }
    }
    
    private var totalTimeLength: Int {
        return Int(videoDuration.seconds * Double(videoDuration.timescale))
    }
    
    /// Return the duration of the video
    var videoDuration: CMTime {
        return asset.duration
    }
    
    /// Return the width size that contains the thumbnails
    var durationSize: CGFloat {
        return bounds.width
    }
    
    /// Return the number of thumbnails that will be genearate
    open var currentThumbnailsCount: Int {
        guard asset != nil else { return 0 }
        if thumbnailSize.width != 0 {
            var number = bounds.width / thumbnailSize.width
            number.round(.toNearestOrAwayFromZero)
            return abs(Int(number))
        }
        return 0
    }
    
    var lastThumbnailsCount: Int = 0 {
        didSet {
            if lastThumbnailsCount != oldValue {
                regenerateThumbViews(count: lastThumbnailsCount)
                generateThumbnails()
            } else if isReloadImages {
                regenerateThumbViews(count: lastThumbnailsCount)
                generateThumbnails()
                isReloadImages = false
            }
        }
    }
    
    func reIamagesSet() {
        regenerateThumbViews(count: lastThumbnailsCount)
        generateThumbnails()
    }
    
    /// Return the length of each step of the video
    private var videoStep: Int {
        return totalTimeLength / currentThumbnailsCount
    }
    
    // MARK: Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: View Life Cycle
    override open func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
   
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.setNeedsLayout()
    }
    
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        thumbsStackView.frame = bounds
        lastThumbnailsCount = currentThumbnailsCount
    }
    
    // MARK: Methods
    private func setup() {
        addSubview(thumbsStackView)
    }
    
    private func imageGenerator() -> AVAssetImageGenerator {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceAfter = CMTime.zero
        generator.requestedTimeToleranceBefore = CMTime.zero
        generator.appliesPreferredTrackTransform = true
        
        let scale = UIScreen.main.nativeScale
        let generatorSize = CGSize(
            width: thumbnailSize.width * scale,
            height: thumbnailSize.height * scale)
        
        generator.maximumSize = generatorSize
        
        return generator
    }
    
    /// Generate the thumbnail for each image view
    private func generateThumbnails() {
        
        assetImageGenerator = imageGenerator()
        
        assetImageGenerator.cancelAllCGImageGeneration()
        
        let frameForTimes: [NSValue] = (0..<currentThumbnailsCount).map {
            let cmTime = CMTime(value: Int64($0 * videoStep),
                                timescale: Int32(videoDuration.timescale))
            return NSValue(time: cmTime)
        }
        
        assert(frameForTimes.count == thumbsStackView.arrangedSubviews.count)
        
        DispatchQueue.global(qos: .userInitiated).async { [assetImageGenerator] in
            var index = 0
            
            assetImageGenerator?.generateCGImagesAsynchronously(
            forTimes: frameForTimes) { (time, image, _, _, error) in
                
                guard error == nil else {
                    print("\nError = \(error!)\n")
                    return
                }
                
                guard let image = image else { return }
                
                DispatchQueue.main.async { [weak self] in
                    guard let imageViews = self?.thumbsStackView
                        .arrangedSubviews as? [UIImageView] else { return }
                    if imageViews.count > index {
                        imageViews[index].image = UIImage(cgImage: image)
                        index += 1
                    }
                }
            }
        }
    }
    
    /// Return the video time from a position of a view
    func getTime(from position: CGFloat) -> CMTime? {
        let normalizedRatio = getNormalizedPosition(from: position)
        guard asset != nil else { return CMTime.zero }
        let positionTimeValue = Double(normalizedRatio)
            * Double(asset.duration.value)
        
        return CMTime(
            value: Int64(positionTimeValue),
            timescale: asset.duration.timescale)
        
    }
    
    /// Normalized time
    func getNormalizedTime(from time: CMTime) -> CGFloat? {
        guard asset != nil else { return 0 }
        let result = CGFloat(time.seconds / asset.duration.seconds)
        return result
    }
    
    /// Return the the position of a view from the video time
    func getPosition(from time: CMTime) -> CGFloat? {
        return getNormalizedTime(from: time)
            .map { $0 * durationSize }
    }
    
    /// Normalized position
    func getNormalizedPosition(from position: CGFloat) -> CGFloat {
        return max(min(1, position / durationSize), 0)
    }
    
    /// Delete the old thumbnails
    func regenerateThumbViews(count: Int) {
        thumbsStackView.arrangedSubviews
            .forEach { view in
                thumbsStackView.removeArrangedSubview(view)
                view.removeFromSuperview()
        }
        
        (0..<count).map { _ in
            let imageView = UIImageView()
            imageView.frame.size = thumbnailSize
            imageView.backgroundColor = ApplicationSettings.appBlackColor
            return imageView
            }.forEach(thumbsStackView.addArrangedSubview)
    }
}
