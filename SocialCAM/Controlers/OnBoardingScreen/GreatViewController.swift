//
//  GreatViewController.swift
//  SocialCAM
//
//  Created by Satish Rajpurohit on 26/06/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class GreatViewController: UIViewController {

    @IBOutlet weak var timerStackView: UIStackView!
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var secLabel: UILabel!
    
    @IBOutlet weak var dayLineView: UIView!
    @IBOutlet weak var hourLineView: UIView!
    @IBOutlet weak var minLineView: UIView!
    @IBOutlet weak var secLineView: UIView!
    
    @IBOutlet weak var freeModeDayImageView: UIImageView!
    @IBOutlet weak var freeModeHourImageView: UIImageView!
    @IBOutlet weak var freeModeMinImageView: UIImageView!
    @IBOutlet weak var freeModeSecImageView: UIImageView!
    
    @IBOutlet weak var dayValueLabel: UILabel!
    @IBOutlet weak var hourValueLabel: UILabel!
    @IBOutlet weak var minValueLabel: UILabel!
    @IBOutlet weak var secValueLabel: UILabel!
    
    @IBOutlet weak var badgeImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension GreatViewController {
    func setup() {
       // self.displayNameLabel.text = Defaults.shared.currentUser?.firstName
        
//        if let subscriptionVC = R.storyboard.subscription.subscriptionContainerViewController() {
//            subscriptionVC.isFromWelcomeScreen = true
//            self.navigationController?.isNavigationBarHidden = true
//            self.navigationController?.pushViewController(subscriptionVC, animated: true)
//        }
    }
}
