//
//  FllowMeStoryView.swift
//  SocialCAM
//
//  Created by Jasmin Patel on 04/03/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

class FollowMeStoryView: UIView {
    
    @IBOutlet weak var deleteButton: UIButton!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "FollowMeStoryView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    public var pannable: Bool = false {
        didSet {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
            self.addGestureRecognizer(panGesture)
        }
    }
    
    public var hideDeleteButton: Bool = false {
        didSet {
            deleteButton.isHidden = hideDeleteButton
        }
    }
    
    @IBAction func onDelete(_ sender: UIButton) {
        removeFromSuperview()
    }
}

extension FollowMeStoryView {
    
    @objc func onPan(_ gesture: UIPanGestureRecognizer) {
        guard let superView = self.superview else {
            return
        }
        center = CGPoint(x: center.x + gesture.translation(in: superView).x,
                         y: center.y + gesture.translation(in: superView).y)
        gesture.setTranslation(.zero, in: self)
    }
    
}
