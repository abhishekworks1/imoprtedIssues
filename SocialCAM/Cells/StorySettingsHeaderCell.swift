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
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var arrowLabel: UILabel?
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var btnProfilePic: UIButton!
    
    weak var delegate: HeaderViewDelegate?
    var section: Int = 0
    var collapsed: Bool = false {
        didSet {
            arrowLabel?.rotate(collapsed ? 0.0 : .pi)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapHeader)))
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
