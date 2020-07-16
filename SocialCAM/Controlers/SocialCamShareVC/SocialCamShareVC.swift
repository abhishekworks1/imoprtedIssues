//
//  SocialCamShareVC.swift
//  SocialCAM
//
//  Created by Viraj Patel on 15/07/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

class SocialCamShareVC: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var btnPost: UIButton!
    @IBOutlet weak var btnStory: UIButton!
  
    var btnStoryPostClicked: ((_ item: Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentSizeInPopup = CGSize(width: 250, height: 180)
        landscapeContentSizeInPopup = CGSize(width: 400, height: 200)
    }
    
    @IBAction func onClickShare(_ sender: UIButton) {
        if let handler = self.btnStoryPostClicked {
            handler(sender.tag)
        }
    }
}
