//
//  StorySettingsHeader.swift
//  ProManager
//
//  Created by Jasmin Patel on 21/06/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit

protocol HeaderViewDelegate: class {
   func toggleSection(header: StorySettingsHeader, section: Int)
}

class StorySettingsHeader: UITableViewCell {

    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var arrowLabel: UILabel?
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var btnProfilePic: UIButton!
    @IBOutlet weak var badgeIconHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addProfilePic: UIImageView!
    @IBOutlet weak var imgSocialMediaBadge: UIImageView!
    @IBOutlet weak var imgprelaunch: UIImageView!
    @IBOutlet weak var imgfoundingMember: UIImageView!
    @IBOutlet weak var imgSubscribeBadge: UIImageView!

    
    @IBOutlet weak var iconSettingsImage: UIImageView!
    @IBOutlet weak var badgesView: UIStackView!
    weak var delegate: HeaderViewDelegate?
    var section: Int = 0
    var callBackForReload : ((Bool) -> ())?
    var collapsed: Bool = false {
        didSet {
            arrowLabel?.rotate(collapsed ? 0.0 : .pi)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapHeader)))
        
       // setUpbadges()
        
    }
    
    @IBAction func didTapProfilePicButton(_ sender: UIButton) {
        self.callBackForReload!(true)
        
    }
    
    
    func setUpbadges() {
        let badgearry = Defaults.shared.getbadgesArray()
        imgprelaunch.isHidden = true
        imgfoundingMember.isHidden = true
        imgSocialMediaBadge.isHidden = true
        imgSubscribeBadge.isHidden = true
        
        if  badgearry.count >  0 {
            imgprelaunch.isHidden = false
            imgprelaunch.image = UIImage.init(named: badgearry[0])
        }
        if  badgearry.count >  1 {
            imgfoundingMember.isHidden = false
            imgfoundingMember.image = UIImage.init(named: badgearry[1])
        }
        if  badgearry.count >  2 {
            imgSocialMediaBadge.isHidden = false
            imgSocialMediaBadge.image = UIImage.init(named: badgearry[2])
        }
        if  badgearry.count >  3 {
            imgSubscribeBadge.isHidden = false
            imgSubscribeBadge.image = UIImage.init(named: badgearry[3])
        }
    }
    @objc private func didTapHeader() {
        delegate?.toggleSection(header: self, section: section)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension UIView {
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.001) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")

        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards

        self.layer.add(animation, forKey: nil)
    }
}
