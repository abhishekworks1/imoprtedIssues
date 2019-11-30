//
//  StoryPlayer.swift
//  SCRecorder_Swift
//
//  Created by Jasmin Patel on 08/10/18.
//  Copyright © 2018 Simform. All rights reserved.
//

import AVFoundation
import CoreImage

protocol StoryPlayerDelegate: class {
    /**
     Called when the player has played some frames. The loopsCount will contains the number of
     loop if the curent item was set using setSmoothItem.
     */
    func player(_ player: StoryPlayer, didPlay currentTime: CMTime, loopsCount: Int)
    
    /**
     Called when the item has been changed on the StoryPlayer
     */
    func player(_ player: StoryPlayer, didChange item: AVPlayerItem?)
    
    /**
     Called when the item has reached end
     */
    func player(_ player: StoryPlayer, didReachEndFor item: AVPlayerItem)
    
    /**
     Called when the item is ready to play
     */
    func player(_ player: StoryPlayer, itemReadyToPlay item: AVPlayerItem)
    
    /**
     Called when the player has setup the renderer so it can receive the image in the
     proper orientation.
     */
    func player(_ player: StoryPlayer, didSetupSCImageView StoryImageView: StoryImageView)
    
    /**
     Called when the item has updated the time ranges that have been loaded
     */
    func player(_ player: StoryPlayer, didUpdateLoadedTimeRanges timeRange: CMTimeRange)
    
    /**
     Called when the item playback buffer is empty
     */
    func player(_ player: StoryPlayer, itemPlaybackBufferIsEmpty item: AVPlayerItem?)
}

extension StoryPlayerDelegate {
    
    func player(_ player: StoryPlayer, didPlay currentTime: CMTime, loopsCount: Int) { }
    
    func player(_ player: StoryPlayer, didChange item: AVPlayerItem?) { }
    
    func player(_ player: StoryPlayer, didReachEndFor item: AVPlayerItem) { }
    
    func player(_ player: StoryPlayer, itemReadyToPlay item: AVPlayerItem) { }
    
    func player(_ player: StoryPlayer, didSetupSCImageView StoryImageView: StoryImageView) { }
    
    func player(_ player: StoryPlayer, didUpdateLoadedTimeRanges timeRange: CMTimeRange) { }

    func player(_ player: StoryPlayer, itemPlaybackBufferIsEmpty item: AVPlayerItem?) { }
}

class StoryPlayer: AVPlayer {
    /**
     The delegate that will receive the messages
     */
    weak public var delegate: StoryPlayerDelegate?
    /**
     Whether the video should start again from the beginning when its reaches the end
     */
    public var loopEnabled = false {
        didSet {
            actionAtItemEnd = loopEnabled ? .none : .pause
        }
    }
    /**
     Will be true if beginSendingPlayMessages has been called.
     */
    public var isSendingPlayMessages: Bool {
        return timeObserver != nil
    }
    /**
     Whether this instance is currently playing.
     */
    public var isPlaying: Bool {
        return rate > 0
    }
    /**
     Whether this instance displays default rendered video
     */
    public var shouldSuppressPlayerRendering = false {
        didSet {
            videoOutput?.suppressesPlayerRendering = shouldSuppressPlayerRendering
        }
    }
    /**
     The actual item duration.
     */
    public var itemDuration: CMTime {
        guard let currentItem = self.currentItem else {
            return .zero
        }
        let ratio = Float64(1.0 / itemsLoopLength)
        return CMTimeMultiply(currentItem.duration, multiplier: Int32(ratio))
    }
    /**
     The total currently loaded and playable time.
     */
    public var playableDuration: CMTime {
        guard let currentItem = currentItem else {
            return .zero
        }
        var playableDuration: CMTime = .zero
        if currentItem.status != .failed {
            for value in currentItem.loadedTimeRanges {
                let timeRange = value.timeRangeValue
                playableDuration = CMTimeAdd(playableDuration, timeRange.duration)
            }
        }
        return playableDuration
    }
    /**
     If true, the player will figure out an affine transform so the video best fits the screen. The resulting video may not be in the correct device orientation though.
     For example, if the video is in landscape and the current device orientation is in portrait mode,
     with this property enabled the video will be rotated so it fits the entire screen. This avoid
     showing the black border on the sides. If your app supports multiple orientation, you typically
     wouldn't want this feature on.
     */
    public var autoRotate = false
    /**
     The renderer for the CIImage. If this property is set, the player will set the CIImage
     property when the current frame changes.
     */
    public weak var scImageView: StoryImageView? {
        didSet {
            if scImageView == nil {
                unsetupDisplayLink()
            } else {
                setupDisplayLink()
            }
        }
    }

    private var displayLink: CADisplayLink?
    private var videoOutput: AVPlayerItemVideoOutput?
    private var oldItem: AVPlayerItem?
    private var itemsLoopLength: Float64 = 1
    private var timeObserver: Any?
    private var rendererWasSetup = false
    private var rendererTransform: CGAffineTransform = .identity
    
    override init() {
        super.init()
        shouldSuppressPlayerRendering = true
        addObserver(self, forKeyPath: "currentItem", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem" {
            initObserver()
        } else if keyPath == "status" {
            let block: (() -> Void) = { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.setupVideoOutput(to: self.currentItem)
                if let delegate = self.delegate {
                    delegate.player(self, itemReadyToPlay: self.currentItem!)
                }
            }
            if Thread.isMainThread {
                block()
            } else {
                DispatchQueue.main.async(execute: block)
            }
        } else if keyPath == "loadedTimeRanges" {
            let block: (() -> Void) = { [weak self] in
                guard let `self` = self else {
                    return
                }
                if let delegate = self.delegate {
                    let array = self.currentItem?.loadedTimeRanges
                    let range = array?.first?.timeRangeValue
                    delegate.player(self, didUpdateLoadedTimeRanges: range!)
                }
            }
            if Thread.isMainThread {
                block()
            } else {
                DispatchQueue.main.async(execute: block)
            }
        } else if keyPath == "playbackBufferEmpty" {
            let block: (() -> Void) = { [weak self] in
                guard let `self` = self else {
                    return
                }
                if let delegate = self.delegate {
                    delegate.player(self, itemPlaybackBufferIsEmpty: self.currentItem)
                }
            }
            if Thread.isMainThread {
                block()
            } else {
                DispatchQueue.main.async(execute: block)
            }
        }
    }
    
    override func replaceCurrentItem(with item: AVPlayerItem?) {
        itemsLoopLength = 1
        super.replaceCurrentItem(with: item)
        suspendDisplay()
    }
    
    deinit {
        endSendingPlayMessages()
        unsetupDisplayLink()
        unsetupVideoOutput(to: currentItem)
        removeObserver(self, forKeyPath: "currentItem")
        removeOldObservers()
        endSendingPlayMessages()
    }

    func initObserver() {
        removeOldObservers()
        if currentItem != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(self.playReachedEnd(_:)), name: .AVPlayerItemDidPlayToEndTime, object: currentItem)
            oldItem = currentItem
            currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
            currentItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
            setupVideoOutput(to: currentItem)
        }
        if let delegate = self.delegate {
            delegate.player(self, didChange: currentItem)
        }
        
    }
    
    func removeOldObservers() {
        if oldItem != nil {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: oldItem)
            oldItem?.removeObserver(self, forKeyPath: "status")
            oldItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            oldItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
            unsetupVideoOutput(to: oldItem)
            oldItem = nil
        }
    }
    
    /**
     Ask the StoryPlayer to send didPlay messages during the playback
     endSendingPlayMessages must be called, otherwise the StoryPlayer will never
     be deallocated
     */
    public func beginSendingPlayMessages() {
        if !isSendingPlayMessages {
            timeObserver = addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 24), queue: DispatchQueue.main, using: { [weak self] time in
                guard let `self` = self else { return }
                if let delegate = self.delegate {
                    let ratio = Float64(1.0 / Double(self.itemsLoopLength))
                    let currentTime: CMTime = CMTimeMultiplyByFloat64(time, multiplier: ratio)
                    
                    let loopCount = Int(CMTimeGetSeconds(time) / (CMTimeGetSeconds(self.currentItem?.duration ?? .zero) / Float64(self.itemsLoopLength)))
                    
                    delegate.player(self, didPlay: currentTime, loopsCount: loopCount)
                }
            })
        }
    }
    /**
     Ask the StoryPlayer to stop sending didPlay messages during the playback
     */
    public func endSendingPlayMessages() {
        if let observer = timeObserver {
            removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    /**
     Set the item using a file string path.
     */
    public func setItemByStringPath(_ stringPath: String) {
        if let url = URL(string: stringPath) {
            setItemBy(url)
        }
    }
    /**
     Set the item using an URL
     */
    public func setItemBy(_ url: URL) {
        setItemBy(AVURLAsset(url: url, options: nil))
    }
    /**
     Set the item using an Asset
     */
    public func setItemBy(_ asset: AVAsset) {
        setItem(AVPlayerItem(asset: asset))
    }
    /**
     Set the item using an AVPlayerItem
     */
    public func setItem(_ item: AVPlayerItem) {
        replaceCurrentItem(with: item)
    }
    /**
     Set an item using a file string path. This will generate an AVComposition containing "loopCount"
     times the item. This avoids the hiccup when looping for up to "loopCount" times.
     */
    public func setSmoothLoopItemByStringPath(_ stringPath: String, smoothLoopCount loopCount: Int) {
        if let url = URL(string: stringPath) {
            setSmoothLoopItemBy(url, smoothLoopCount: loopCount)
        }
    }
    /**
     Set the item using an URL. This will generate an AVComposition containing "loopCount"
     times the item. This avoids the hiccup when looping for up to "loopCount" times.
     */
    public func setSmoothLoopItemBy(_ url: URL, smoothLoopCount loopCount: Int) {
        setSmoothLoopItemBy(AVURLAsset(url: url, options: nil), smoothLoopCount: loopCount)
    }
    /**
     Set the item using an Asset. This will generate an AVComposition containing "loopCount"
     times the item. This avoids the hiccup when looping for up to "loopCount" times.
     */
    public func setSmoothLoopItemBy(_ asset: AVAsset, smoothLoopCount loopCount: Int) {
        let composition = AVMutableComposition()
        
        let timeRange: CMTimeRange = CMTimeRange(start: .zero, duration: asset.duration)
        
        for _ in 0..<loopCount {
            try? composition.insertTimeRange(timeRange, of: asset, at: composition.duration)
        }
        
        setItemBy(composition)
        
        itemsLoopLength = Float64(loopCount)
    }
    
    @objc func playReachedEnd(_ notification: Notification) {
        guard let item = notification.object as? AVPlayerItem, item == currentItem else {
            return
        }
        if loopEnabled {
            seek(to: .zero)
            if isPlaying {
                play()
            }
        }
        if let delegate = self.delegate {
            delegate.player(self, didReachEndFor: self.currentItem!)
        }
    }
    
}

extension StoryPlayer {
    
    func setupVideoOutput(to item: AVPlayerItem?) {
        if let displayLink = displayLink,
            let item = item,
            videoOutput == nil,
            item.status == .readyToPlay {
            let pixBuffAttributes = [kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA]
            
            videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: pixBuffAttributes as [String: Any])
            
            videoOutput?.setDelegate(self, queue: DispatchQueue.main)
            videoOutput?.suppressesPlayerRendering = shouldSuppressPlayerRendering
            
            item.add(videoOutput!)
            
            displayLink.isPaused = false
            
            var transform: CGAffineTransform = .identity
            
            let videoTracks = item.asset.tracks(withMediaType: .video)
            
            if videoTracks.count > 0 {
                let track = videoTracks.first
                
                if let aTransform = track?.preferredTransform {
                    transform = aTransform
                }
                
                // Return the video if it is upside down
                if transform.b == 1 && transform.c == -1 {
                    transform = transform.rotated(by: .pi)
                }
                
                if autoRotate {
                    let videoSize = track?.naturalSize
                    let viewSize = scImageView?.frame.size
                    let outRect = CGRect(x: 0, y: 0, width: videoSize?.width ?? 0.0, height: videoSize?.height ?? 0.0).applying(transform)
                    
                    let viewIsWide: Bool = (viewSize?.width ?? 0.0) / (viewSize?.height ?? 0.0) > 1
                    let videoIsWide: Bool = outRect.size.width / outRect.size.height > 1
                    
                    if viewIsWide != videoIsWide {
                        transform = transform.rotated(by: .pi/2)
                    }
                }
            }
            rendererTransform = transform
            rendererWasSetup = false
        }
    }
    
    func unsetupVideoOutput(to item: AVPlayerItem?) {
        guard let output = videoOutput, let playerItem = item else {
            return
        }
        if playerItem.outputs.contains(output) {
            playerItem.remove(output)
        }
        videoOutput = nil
    }
    
}

extension StoryPlayer {
    
    func setupDisplayLink() {
        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(self.willRenderFrame(_:)))
            displayLink?.preferredFramesPerSecond = 60
            setupVideoOutput(to: currentItem)
            displayLink?.add(to: RunLoop.main, forMode: .common)
            suspendDisplay()
        }
        rendererWasSetup = false
    }
    
    @objc func willRenderFrame(_ sender: CADisplayLink?) {
        let nextFrameTime: CFTimeInterval = (sender?.timestamp ?? 0) + (sender?.duration ?? 0)
        renderVideo(nextFrameTime)
    }
    
    func renderVideo(_ hostFrameTime: CFTimeInterval) {
        guard let output = self.videoOutput else {
            return
        }
        let outputItemTime: CMTime = output.itemTime(forHostTime: hostFrameTime)
        
        if output.hasNewPixelBuffer(forItemTime: outputItemTime) {
            if let renderer = scImageView {
                if !rendererWasSetup {
                    renderer.preferredCIImageTransform = rendererTransform
                    if let delegate = self.delegate {
                        delegate.player(self, didSetupSCImageView: renderer)
                    }
                    rendererWasSetup = true
                }
                
                let pixelBuffer = output.copyPixelBuffer(forItemTime: outputItemTime, itemTimeForDisplay: nil)
                
                if let aBuffer = pixelBuffer {
                    let inputImage = CIImage(cvPixelBuffer: aBuffer)
                    renderer.ciImage = inputImage
                }
            }
        }
    }
    
    func unsetupDisplayLink() {
        if displayLink != nil {
            displayLink?.invalidate()
            displayLink = nil
            unsetupVideoOutput(to: currentItem)
            videoOutput = nil
        }
    }
    
    func suspendDisplay() {
        displayLink?.isPaused = true
        videoOutput?.requestNotificationOfMediaDataChange(withAdvanceInterval: 0.1)
    }
    
}

extension StoryPlayer: AVPlayerItemOutputPullDelegate {
    
    func outputMediaDataWillChange(_ sender: AVPlayerItemOutput) {
        displayLink?.isPaused = false
    }
    
}
