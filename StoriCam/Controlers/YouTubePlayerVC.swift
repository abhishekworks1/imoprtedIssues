//
//  ViewController.swift
//  YouTubeDemo
//
//  Created by Jasmin Patel on 31/01/18.
//  Copyright © 2018 Simform. All rights reserved.
//

import UIKit
import YoutubePlayerView

class YouTubePlayerVC: UIViewController {
    
    var youTubeView: YoutubePlayerView = YoutubePlayerView()
    
    var completion: (() -> Swift.Void)? = nil
    
    public var previewUrl: URL?
    public var videoId: String?
    
    init(_ videoID: String?) {
        self.videoId = videoID
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init() {
        self.init(nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ApplicationSettings.appBlackColor.withAlphaComponent(0.75)
        setupYouTubeView()
        guard let videoId = videoId else {
            return
        }
        let playvarsDic = ["controls": 1, "playsinline": 1, "autohide": 1, "showinfo": 0, "autoplay": 1, "color": "white", "origin": "https://www.youtube.com"] as [String : Any]
        self.youTubeView.setPlaybackQuality(YoutubePlaybackQuality.auto)
        self.youTubeView.loadWithVideoId(videoId, with: playvarsDic)
        
        NotificationCenter.default.addObserver(self, selector: #selector(VideoExitFullScreen), name: UIWindow.didBecomeVisibleNotification, object: self.youTubeView.window)
        NotificationCenter.default.addObserver(self, selector: #selector(VideoEnterFullScreen), name: UIWindow.didBecomeHiddenNotification, object: self.youTubeView.window)
    }
    
    func setupYouTubeView() {
        view.addSubview(youTubeView)
        youTubeView.translatesAutoresizingMaskIntoConstraints = false
        
        youTubeView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        NSLayoutConstraint(item: youTubeView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.width, multiplier: 0.9, constant: 0).isActive = true
        NSLayoutConstraint(item: youTubeView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: youTubeView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: 0).isActive = true
        
        youTubeView.layer.cornerRadius = 7.5
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(roundedRect: youTubeView.bounds, cornerRadius: 12).cgPath
        shadowLayer.fillColor = ApplicationSettings.appWhiteColor.cgColor
        shadowLayer.shadowColor = ApplicationSettings.appBlackColor.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        shadowLayer.shadowOpacity = 0.8
        shadowLayer.shadowRadius = 5
        youTubeView.layer.insertSublayer(shadowLayer, at: 0)
        youTubeView.delegate = self
    }
    
    @IBAction func pauseVideoClicked(_ sender: Any) {
        if youTubeView.playerState == .playing {
            youTubeView.pause()
        } else {
            youTubeView.play()
        }
    }
    
    @IBAction func fullScreenClicked(_ sender: Any) {
        
    }
    
    @objc func VideoEnterFullScreen() {
        print("exit")
        youTubeView.play()
    }
    
    @objc func VideoExitFullScreen() {
        print("enter")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        youTubeView.removeFromSuperview()
        self.dismiss(animated: true, completion: completion)
    }
}

extension YouTubePlayerVC: YoutubePlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YoutubePlayerView) {
        playerView.play()
    }
    
    func playerViewPreferredInitialLoadingView(_ playerView: YoutubePlayerView) -> UIView? {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: playerView.bounds.width, height: playerView.bounds.height))
        view.setImageFromURL(previewUrl?.absoluteString ?? "")
        view.backgroundColor = ApplicationSettings.appBlackColor
        return view
    }
    
    func playerView(_ playerView: YoutubePlayerView, didChangeTo state: YoutubePlayerState) {
        
    }
}

extension UIViewController {
    func openYoutubeView(_ videoID: String, previewUrl: String?, completion: (() -> Swift.Void)? = nil) {
        let youTubeVC = YouTubePlayerVC(videoID)
        if let urlString = previewUrl,let url = URL.init(string: urlString) {
            youTubeVC.previewUrl = url
        }
        youTubeVC.completion = completion
        youTubeVC.modalPresentationStyle = .overCurrentContext
        youTubeVC.modalTransitionStyle = .crossDissolve
        present(youTubeVC, animated: true, completion: nil)
    }
}
