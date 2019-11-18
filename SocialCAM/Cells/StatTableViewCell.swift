//
//  StatTableViewCell.swift
//  ProManager
//
//  Created by Arpit Shah on 27/09/17.
//  Copyright © 2017 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class StatTableViewCell: UITableViewCell {
    @IBOutlet var lblTitle : UILabel!
    @IBOutlet var lblTag : UILabel!
    @IBOutlet var lblNumber : UILabel!
    @IBOutlet var lblViews : UILabel!
    @IBOutlet var lblDate : UILabel!
    @IBOutlet var lblCategory : UILabel!
    @IBOutlet var lblChannel : UILabel!
    @IBOutlet var tagBtn  : UIButton!
    var tagHandler : ((_ item:Item)->Void)?
    var playHandler : ((_ item:Item)->Void)?
    var shareHandler : ((_ item:Item)->Void)?
    var channelHandler : ((_ item:Item)->Void)?
    var observable : Item? {
        didSet {
            if let items = observable {
              self.configCell(items: items)
            }
        }
    }
    
    func configCell(items:Item) {
        let video = items
        self.lblChannel.text = video.snippet?.channelTitle
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.lblChannelTaped(sender:)))
        tap.numberOfTapsRequired = 1
        self.lblChannel.isUserInteractionEnabled = true
        self.lblChannel.addGestureRecognizer(tap)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        if let dateObj = formatter.date(from: (video.snippet?.publishedAt)!) {
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "MM-dd-yyyy"
            self.lblDate.text = formatter2.string(from: dateObj)
        } else {
            self.lblDate.text = video.snippet?.publishedAt
        }
        self.lblTitle.text = video.snippet?.title ?? ""
        self.lblViews.text = video.statistics?.viewCount
        self.lblViews.adjustsFontSizeToFitWidth = true
        if let tags = video.snippet?.tags , tags.count > 0 {
            let tempString = tags.joined(separator: ", ")
            let hash = ""
            let tagText = hash.appending(tempString)
            self.lblTag.text = tagText
        } else {
            self.lblTag.text = ""
        }
       
        self.updateConstraintsIfNeeded()
        self.setNeedsUpdateConstraints()
    }
    
    @objc func lblChannelTaped(sender:Any) {
        if let handler = self.channelHandler {
            handler(self.observable!)
        }
    }
    
    @IBAction func btnPlayClicked(_ sender : Any) {
        if let handler = self.playHandler {
            handler(self.observable!)
        }
    }
    
    @IBAction func btnShareClicked(_ sender: Any) {
        if let handler = self.shareHandler {
            handler(self.observable!)
        }
        
    }
    
    @IBAction func btnTagClicked(_ sender: Any) {
        if let handler = self.tagHandler {
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
