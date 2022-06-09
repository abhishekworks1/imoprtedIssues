//
//  OnBoardingViewController.swift
//  SocialCAM
//
//  Created by Siddharth on 09/06/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class OnBoardingViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    

    @IBAction func didTapMakeMoneyClick(_ sender: UIButton) {
        guard let makeMoneyReferringVC = R.storyboard.onBoardingView.makeMoneyReferringViewController() else { return }
        present(makeMoneyReferringVC, animated: true)
    }
    
    
    @IBAction func createContent(_ sender: UIButton) {
        Defaults.shared.isSignupLoginFlow = true
        let rootViewController: UIViewController? = R.storyboard.pageViewController.pageViewController()
        Utils.appDelegate?.window?.rootViewController = rootViewController
    }
    
}

extension OnBoardingViewController {
    
    func setupView() {
        if let user = Defaults.shared.currentUser {
            self.welcomeLabel.text = " Welcome \(String(describing: user.username!)), to QuickCam, the next level smart phone camera app for making money! \nThe perfect global economic crisis antidote!!"
        }
    }
    
}
