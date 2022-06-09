//
//  MakeMoneyReferringViewController.swift
//  SocialCAM
//
//  Created by Satish Rajpurohit on 09/06/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class MakeMoneyReferringViewController: UIViewController {

    @IBOutlet weak var referLinkLabel: UILabel!
    @IBOutlet weak var termsOfServiceLabel: UILabel!
    @IBOutlet weak var termsCheckBoxButton: UIButton!
    @IBOutlet weak var agreeButton: UIButton!
    var isAgreeChecked = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
    }
    
    @IBAction func agreeOnclick(_ sender: Any) {
        let rootViewController: UIViewController? = R.storyboard.pageViewController.pageViewController()
        Utils.appDelegate?.window?.rootViewController = rootViewController
    }
    
    @IBAction func termsCheckOnClick(_ sender: Any) {
        if isAgreeChecked {
            setupAgreeButton()
            isAgreeChecked = false
            termsCheckBoxButton.setImage(UIImage(named: "checkBoxInActive"), for: .normal)
        } else {
            setupAgreeButton(isSelected: true)
            isAgreeChecked = true
            termsCheckBoxButton.setImage(UIImage(named: "checkBoxActive"), for: .normal)
        }
    }
    
    @IBAction func backOnclick(_ sender: Any) {
        dismiss(animated: true)
    }
    
}

extension MakeMoneyReferringViewController {
    
    func setUpView() {
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tappedOnLabel(_:)))
            tapGesture.numberOfTouchesRequired = 1
            termsOfServiceLabel.addGestureRecognizer(tapGesture)
        termsCheckBoxButton.setImage(UIImage(named: "checkBoxInActive"), for: .normal)
        setupAgreeButton()
        setupReferLink()
    }
    
    func setupAgreeButton(isSelected: Bool = false) {
        self.agreeButton.isUserInteractionEnabled = isSelected
        self.agreeButton.backgroundColor = isSelected ? .systemBlue : .lightGray
        self.agreeButton.titleLabel?.textColor = isSelected ? .white : .darkGray
        self.agreeButton.layer.cornerRadius = self.agreeButton.frame.height/2
    }
    
    func setupReferLink() {
        if let channelId = Defaults.shared.currentUser?.channelId {
            self.referLinkLabel.text = "\(websiteUrl)/\(channelId)"
        }
    }
    
    @objc func tappedOnLabel(_ gesture: UITapGestureRecognizer) {
        print("tapp")
    }
    
}
