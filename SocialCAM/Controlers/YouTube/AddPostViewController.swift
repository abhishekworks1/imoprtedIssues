//
//  AddPostViewController.swift
//  ProManager
//
//  Created by Arpit Shah on 28/09/17.
//  Copyright © 2017 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import NSObject_Rx
import NVActivityIndicatorView
import WebKit
import YoutubePlayerView
import AVKit

class AddPostViewController: UIViewController {
    
    @IBOutlet var webView: WKWebView!
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblTag: UILabel!
    @IBOutlet var lblDiscribtion: UILabel!
    @IBOutlet var lblLike: UILabel!
    @IBOutlet var lblDisLike: UILabel!
    @IBOutlet var lblViews: UILabel!
    @IBOutlet var scrolViewHeight: NSLayoutConstraint!
    @IBOutlet var viewVideo: BorderView!
    @IBOutlet var txtComment: UITextView!
    @IBOutlet var txtTag: UITextView!
    @IBOutlet var viewPlayer: UIView!
    
    var playHandler : ((_ item: Item) -> Void)?
    var video = Item(JSON: [:])
    var popHandler : ((_ youTubeUrl: String) -> Void)?
    var shareHandler : ((_ url: String, _ hashtag: [String]?, _ title: String?, _ channelId: String?) -> Void)?
    var videoPlayer: AVPlayer!
    var player: YoutubePlayerView?
    var isReview = false
    var observable: Item? {
        didSet {
            if let items = observable {
                let video = items
                self.lblTitle.text = video.snippet?.title ?? ""
                self.lblDiscribtion.text = video.snippet?.description ?? ""
                self.lblLike.text = "\(video.statistics?.likeCount ?? "")"
                self.lblDisLike.text = "\(video.statistics?.dislikeCount ?? "")"
                self.lblViews.text = "\(video.statistics?.viewCount ?? "")"
                if let tags = video.snippet?.tags, !tags.isEmpty {
                    let tempString = tags.joined(separator: ",#")
                    let hash = "#"
                    let tagText = hash.appending(tempString)
                    self.txtTag.text = tagText
                } else {
                    self.txtTag.text = ""
                }
                self.txtComment.text = video.snippet?.description
                if let url = video.snippet?.thumbnail {
                    self.imgView.sd_setImage(with: URL.init(string: url), placeholderImage: nil)
                }
                self.view.updateConstraintsIfNeeded()
                self.view.setNeedsUpdateConstraints()
                scrolViewHeight.constant = viewVideo.frame.size.height + 400
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.observable = video
        setBoarderLayer()
        directPlay()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let player = self.player {
            player.stop()
        }
    }
    
    deinit {
        print("close full screen YouTube View Controller")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setBoarderLayer() {
        self.txtTag.layer.cornerRadius = 3.0
        self.txtTag.layer.borderWidth = 0.7
        self.txtTag.layer.borderColor = ApplicationSettings.appLightGrayColor.cgColor
        self.txtComment.layer.cornerRadius = 3.0
        self.txtComment.layer.borderWidth = 0.7
        self.txtComment.layer.borderColor = ApplicationSettings.appLightGrayColor.cgColor
    }
    
    @objc func moviePlayerLoadStateDidChange(notification: Notification) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

    // MARK: IBActions
    
    @IBAction func onBack(_ sender: Any) {
        if let player = self.player {
            player.stop()
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPlayClicked(_ sender: Any) {
      
    }
    
    func directPlay() {
        player = YoutubePlayerView()
        viewPlayer.addSubview(player!)
        player?.translatesAutoresizingMaskIntoConstraints = false
        
        player?.topAnchor.constraint(equalTo: viewPlayer.topAnchor).isActive = true
        player?.bottomAnchor.constraint(equalTo: viewPlayer.bottomAnchor).isActive = true
        player?.leadingAnchor.constraint(equalTo: viewPlayer.leadingAnchor).isActive = true
        player?.trailingAnchor.constraint(equalTo: viewPlayer.trailingAnchor).isActive = true
        player?.delegate = self
        
        let playvarsDic = ["controls": 1, "playsinline": 1, "autohide": 1, "showinfo": 0, "autoplay": 1, "color": "white", "origin": "https://www.youtube.com"] as [String: Any]
        self.player?.setPlaybackQuality(YoutubePlaybackQuality.auto)
        self.player?.loadWithVideoId(video?.ids ?? "", with: playvarsDic)
        
        NotificationCenter.default.addObserver(self, selector: #selector(videoEnterFullScreen), name: UIWindow.didBecomeHiddenNotification, object: self.player?.window)
    }
    
    @IBAction func btnShareClicked(_ sender: Any) {
        if let player = self.player {
            player.stop()
            print("inside")
        }
        self.popHandler = { [weak self] youTubeUrl in
            guard let strongSelf = self else {
                return
            }
            if strongSelf.isReview {
                print("Review screen")
                return
            }
            var hash1: [String] = []
            if let tags = strongSelf.video?.snippet?.tags, !tags.isEmpty {
                hash1 = tags.map {
                    return $0.replace(" ", with: "")
                }
            }
            if let handler = strongSelf.shareHandler {
                handler(youTubeUrl, hash1, strongSelf.video?.snippet?.title, strongSelf.video?.snippet?.channelId)
            }
            strongSelf.navigationController?.popViewController(animated: false)
        }
        let url = "https://www.youtube.com/watch?v=" + (video?.ids!)!
        self.popHandler!(url)
    }

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension AddPostViewController: YoutubePlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YoutubePlayerView) {
        playerView.play()
    }
    
    @objc func videoEnterFullScreen() {
        player?.play()
    }
    
}
