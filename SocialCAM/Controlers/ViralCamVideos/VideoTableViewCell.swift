//
//  VideoTableViewCell.swift
//  ViralCam
//
//  Created by Viraj Patel on 22/04/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

class ShadowView: UIView {
    
    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }

    private func setupShadow() {
        self.layer.cornerRadius = 8
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.3
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}

class VideoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var lblDesc: UILabel?
    @IBOutlet weak var lblHashTag: UILabel?
    @IBOutlet weak var imgVideo: UIImageView?
    @IBOutlet weak var upvote: UIButton?

    var postModel: CreatePostViralCam? {
        didSet {
            if let post = postModel {
                self.lblTitle?.text = post.title
                self.lblDesc?.text = post.description
                self.lblHashTag?.text = post.hashtags?.joined(separator: ", ")
                if let imageURL = post.image {
                    self.imgVideo?.sd_setImage(with: URL.init(string: imageURL), placeholderImage: ApplicationSettings.userPlaceHolder)
                } else {
                    self.imgVideo?.image = ApplicationSettings.userPlaceHolder
                }
                self.selectionStyle = .none
                self.updateConstraintsIfNeeded()
                self.setNeedsUpdateConstraints()
            }
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

    @IBAction func btnUpVoteClicked(sender: Any?) {

    }

}
