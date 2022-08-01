//
//  CoverViewProtocol.swift
//  Pods
//
//  Created by Millman YANG on 2017/6/20.
//
//

import Foundation
import AVKit

@objc public protocol MMPlayerBasePlayerProtocol: class {
    weak var playLayer: MMPlayerLayer? { get set }
    @objc optional func player(isMuted: Bool)
    
    @objc optional func timerObserver(time: CMTime)
    @objc optional func coverView(isShow: Bool)
    func removeObserver()
    func addObserver()
}

public protocol MMPlayerCoverViewProtocol: MMPlayerBasePlayerProtocol {
    func currentPlayer(status: MMPlayerPlayStatus)
}

public enum MMPlayerCoverAutoHideType {
    case autoHide(after: TimeInterval)
    case disable
}

public enum MMPlayerCacheType {
    case none
    case memory(count: Int)
}

public enum MMPlayerPlayStatus {
    case ready
    case unknown
    case failed(err: String)
    case playing
    case pause
    case end
}

public enum CoverViewFitType {
    case fitToPlayerView
    case fitToVideoRect
}

public enum ProgressType {
    case `default`
    case none
    case custom(view: UIView & MMProgressProtocol)
}

public protocol MMProgressProtocol {
    func start()
    func stop()
}

public protocol MMPlayerLayerProtocol: class {
    func touchInVideoRect(contain: Bool)
}

public protocol MMPlayerLoadingProtocol: class {
    func playbackBufferEmpty()
    func playbackLikelyToKeepUp()
}
