//
//  PlayerView.swift
//  Gemini
//
//  Created by shoheiyokoyama on 2017/07/02.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import AVKit

protocol PlayerBufferDelegate: class {
    func playbackBufferEmpty()
    func playbackLikelyToKeepUp()
}

open class PlayerView: UIView {
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    override open class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    fileprivate var asset: AVURLAsset?
    fileprivate var cahce = MMPlayerCache()
    public var cacheType: MMPlayerCacheType = .none
    fileprivate var timeObserver: Any?
    var muteHandler: ((_ isMute: Bool) -> Void)?
    var statusHandler : ((_ status: MMPlayerPlayStatus) -> Void)?
    var isAutoPlay: Bool = true
    var indicatorHandler : ((_ start: Bool) -> Void)?
    weak var bufferDelegate: PlayerBufferDelegate?
    fileprivate let assetKeysRequiredToPlay = [
        "duration",
        "playable",
        "hasProtectedContent"
        ]
    
    public var playUrl: URL? {
        willSet {
            self.player?.replaceCurrentItem(with: nil)
            if let indicator = self.indicatorHandler {
               indicator(true)
            }
            guard let url = newValue else {
                return
            }
            let fileManager = FileManager.default
            var outputURL = ""
           
            if let storyCacheVideoPath = try? FileSystem.init().documentFolder?.subfolder(named: "StoryCacheVideo") {
                outputURL = storyCacheVideoPath.path + url.lastPathComponent
            }
            
            if fileManager.fileExists(atPath: outputURL) {
                self.asset = AVURLAsset.init(url: URL(fileURLWithPath: outputURL))
                self.asset?.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
                let item = AVPlayerItem(asset: self.asset!)
                self.player?.replaceCurrentItem(with: item)
                self.addObserverForEnd()
            } else if let cacheItem = self.cahce.getItem(key: url), cacheItem.status == .readyToPlay {
                self.asset = (cacheItem.asset as? AVURLAsset)
                self.asset?.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
                self.player?.replaceCurrentItem(with: cacheItem)
                self.addObserverForEnd()
            } else {
                self.asset = AVURLAsset(url: url)
                self.asset?.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
                self.asset?.loadValuesAsynchronously(forKeys: assetKeysRequiredToPlay) { [weak self] in
                    DispatchQueue.main.async {
                        if let a = self?.asset, let keys = self?.assetKeysRequiredToPlay {
                            for key in keys {
                                var error: NSError?
                                _ =  a.statusOfValue(forKey: key, error: &error)
                                if error != nil {
                                    return
                                }
                            }
                            let item = AVPlayerItem(asset: a)
                            switch self?.cacheType {
                            case .some(.memory(let count)):
                                self?.cahce.cacheCount = count
                                self?.cahce.appendCache(key: url, item: item)
                            default:
                                self?.cahce.removeAll()
                                
                            }
                            self?.player?.replaceCurrentItem(with: item)
                            self?.addObserverForEnd()
                        }
                    }
                }
            }
        }
    }
    
    func addObserverForEnd() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: nil, using: { [weak self] (notification) in
            guard let obj = notification.object as? AVPlayerItem, let strongSelf = self else {
                return
            }
            
            if !strongSelf.checkStorageFull() {
                strongSelf.saveTempVideoForCatch()
            }
            
            if obj != strongSelf.player?.currentItem {
                return
            }
            let s = strongSelf.currentPlayStatus
            switch s {
            case .playing, .pause:
                strongSelf.currentPlayStatus = .end
            default: break
            }
        })
    }
    
    func saveTempVideoForCatch() {
        
        let exporter = AVAssetExportSession(asset: self.asset!, presetName: AVAssetExportPresetHighestQuality)
        
        var outputURL = ""
        
        var subfolder = try? FileSystem.init().documentFolder?.createSubfolder(named: "StoryCacheVideo")
        if subfolder == nil {
            subfolder = try? FileSystem.init().documentFolder?.subfolder(named: "StoryCacheVideo")
        }
        outputURL = subfolder!.path + self.asset!.url.lastPathComponent
        
        if !FileManager.default.fileExists(atPath: outputURL) {
            exporter?.outputURL = URL.init(fileURLWithPath: outputURL)
            exporter?.outputFileType = AVFileType.mp4
            
            exporter?.exportAsynchronously(completionHandler: {
                if let exporter = exporter {
                    switch exporter.status {
                    case .failed: do {
                        print(exporter.error?.localizedDescription ?? "Error in exporting..")
                        }
                    case .completed: do {
                        print("VideoForCatch URL:\(String(describing: exporter.outputURL))")
                        print("Scaled video has been generated successfully!")
                        }
                    case .unknown: break
                    case .waiting: break
                    case .exporting: break
                    case .cancelled: break
                    @unknown default:
                        break
                    }
                }
            })
        }
       
    }
    
    public var currentPlayStatus: MMPlayerPlayStatus = .unknown {
        didSet {
            switch self.currentPlayStatus {
            case .ready:
                break
            case .failed(err: _):
                if let indicator = self.indicatorHandler {
                    indicator(false)
                }
                break
            case .playing:
                break
            case .pause:
                break
            case .end:
                if isAutoPlay {
                    self.player?.currentItem?.seek(to: CMTime.zero, completionHandler: { [weak self] (isSeeked)  in
                        if isSeeked {
                            self?.player?.play()
                        }
                    })
                }
                break
            case .unknown:
                if let indicator = self.indicatorHandler {
                    indicator(false)
                }
                break

            }
            if let handler = self.statusHandler {
                handler(currentPlayStatus)
            }
        }
    }

    var updateProgressHandler : ((_ time: CMTime) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
        playerLayer.backgroundColor = ApplicationSettings.appBlackColor.cgColor
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
    }
    
    deinit {
        self.removeAllObserver()
    }
    
    fileprivate func setup() {
        self.player = AVPlayer()
        self.playerLayer.frame = self.bounds
        self.addPlayerObserver()
    }
    
    func removeAllObserver() {
        self.player?.replaceCurrentItem(with: nil)
        self.player?.pause()
        self.player?.safeRemove(observer: self, forKeyPath: "Muted")
        self.player?.safeRemove(observer: self, forKeyPath: "rate")
        NotificationCenter.default.removeObserver(self)
        self.player?.safeRemove(observer: self, forKeyPath: "currentItem")
        if timeObserver != nil {
            timeObserver = nil
        }
    }
    
    fileprivate func addPlayerObserver() {
        NotificationCenter.default.removeObserver(self)
        if timeObserver == nil {
            timeObserver = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 100), queue: DispatchQueue.main, using: { [weak self] (time) in
                
                if time.isIndefinite {
                    return
                }
                if let handler = self?.updateProgressHandler {
                    handler(time)
                }
                
            })
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil, using: { [weak self] (_) in
            switch self?.currentPlayStatus ?? .unknown {
            case .pause:
                break
            default:
                break
            }
            self?.player?.pause()
        })
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil, using: { (_) in
          
        })
        
        self.player?.safeAdd(observer: self, forKeyPath: "Muted", options: [.new, .old], context: nil)
        self.player?.safeAdd(observer: self, forKeyPath: "rate", options: [.new, .old], context: nil)
        self.player?.safeAdd(observer: self, forKeyPath: "currentItem", options: [.new, .old], context: nil)
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        if let k = keyPath {
            switch k {
            case "Muted":
            if let old = change?[.oldKey] as? Bool,
                let new = change?[.newKey] as? Bool, old != new {
                if let muteHandler = self.muteHandler {
                    muteHandler(new)
                }
            }
            case "rate":
                switch self.currentPlayStatus {
                case .playing, .pause, .ready:
                    if let new = change?[.newKey] as? CGFloat {
                        self.currentPlayStatus = (new == 0.0) ? .pause : .playing
                    }
                case .end:
                    let total = self.player?.currentItem?.duration.seconds ?? 0.0
                    let current = self.player?.currentItem?.currentTime().seconds ?? 0.0
                    if let new = change?[.newKey] as? CGFloat, current < total {
                        self.currentPlayStatus = (new == 0.0) ? .pause : .playing
                    }
                default:
                    break
                }
            case "currentItem":
                if let old = change?[.oldKey] as? AVPlayerItem {
                    old.safeRemove(observer: self, forKeyPath: "playbackBufferEmpty")
                    old.safeRemove(observer: self, forKeyPath: "playbackLikelyToKeepUp")
                    old.safeRemove(observer: self, forKeyPath: "status")
                }
                
                if let new = change?[.newKey] as? AVPlayerItem {
                    new.safeAdd(observer: self, forKeyPath: "status", options: [.new], context: nil)
                    new.safeAdd(observer: self, forKeyPath: "playbackLikelyToKeepUp", options: [.new], context: nil)
                    new.safeAdd(observer: self, forKeyPath: "playbackBufferEmpty", options: [.new], context: nil)
                }
            case "playbackBufferEmpty":
                if let c = change?[.newKey] as? Bool, c == true {
                    if let indicator = self.indicatorHandler {
                        indicator(true)
                    }
                    if let delegate = self.bufferDelegate {
                        delegate.playbackBufferEmpty()
                    }
                }
            case "playbackLikelyToKeepUp":
                if let c = change?[.newKey] as? Bool, c == true {
                    if let indicator = self.indicatorHandler {
                        indicator(false)
                    }
                    if let delegate = self.bufferDelegate {
                        delegate.playbackLikelyToKeepUp()
                    }
                }
            case "status":
                let s = self.convertItemStatus()
                switch s {
                case .failed, .unknown:
                    self.currentPlayStatus = s
                case .ready:
                    switch self.currentPlayStatus {
                    case .ready:
                        self.currentPlayStatus = s
                    case .failed, .unknown:
                        self.currentPlayStatus = s
                    default:
                        break
                    }
                default:
                    break
                }
            default:
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }
        }
    }
    
    fileprivate func convertItemStatus() -> MMPlayerPlayStatus {
        if let item = self.player?.currentItem {
            switch item.status {
            case .failed:
                let msg =  item.error?.localizedDescription ??  ""
                return .failed(err: msg)
            case .readyToPlay:
                return .ready
            case .unknown:
                return .unknown
            @unknown default:
                return .unknown
            }
        }
        return .unknown
    }

    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }
}

extension PlayerView: AVAssetResourceLoaderDelegate {
    
}
