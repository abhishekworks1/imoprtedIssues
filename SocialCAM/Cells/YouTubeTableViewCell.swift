//
//  YouTubeTableViewCell.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 19/09/17.
//  Copyright © 2017 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WebKit

class YouTubeTableViewCell: UITableViewCell {
    @IBOutlet var webView: WKWebView!
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblTag: UILabel!
    @IBOutlet var lblDiscribtion: UILabel!
    @IBOutlet var lblLike: UILabel!
    @IBOutlet var lblDisLike: UILabel!
    @IBOutlet var lblViews: UILabel!
    var playHandler : ((_ item: Item) -> Void)?
    var shareHandler : ((_ item: Item) -> Void)?
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
                    self.lblTag.text = tagText
                } else {
                    self.lblTag.text = ""
                }
                if let url = video.snippet?.thumbnail {
                    self.imgView.sd_setImage(with: URL.init(string: url), placeholderImage: nil)
                }
               
                self.updateConstraintsIfNeeded()
                self.setNeedsUpdateConstraints()
            }
        }
    }
    
    @IBAction func btnPlayClicked(_ sender: Any) {
        if let handler = self.playHandler {
            handler(self.observable!)
        }
    }
    
    @IBAction func btnShareClicked(_ sender: Any) {
        if let handler = self.shareHandler {
            handler(self.observable!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
