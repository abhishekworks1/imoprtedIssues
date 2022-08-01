//
//  MakeMoneyReferringViewController.swift
//  SocialCAM
//
//  Created by Satish Rajpurohit on 09/06/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit
import SafariServices
import Alamofire

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
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(["isAllowAffiliate" : true])
            self.setAffiliate(data:jsonData)
        } catch {}
        setNavigation()
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
        self.navigationController?.popViewController(animated: true)
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
        let safariVC = SFSafariViewController(url: URL(string: "\(websiteUrl)/terms-and-conditions")!)
        present(safariVC, animated: true, completion: nil)
    }
    
    func setNavigation() {
        if let userImageURL = Defaults.shared.currentUser?.profileImageURL , !userImageURL.isEmpty, userImageURL != "undefined" {
            if let contactWizardController = R.storyboard.contactWizardwithAboutUs.contactImportVC() {
                contactWizardController.isFromOnboarding = true
                navigationController?.pushViewController(contactWizardController, animated: true)
            }
        } else {
            if let editProfileController = R.storyboard.refferalEditProfile.refferalEditProfileViewController() {
                editProfileController.isFromOnboarding = true
                navigationController?.pushViewController(editProfileController, animated: true)
            }
        }
    }
    
    func setAffiliate(data: Data) {
        let path = API.shared.baseUrl + "user/updateProfileDetails"
        print(path)
        var request = URLRequest(url:URL(string:path)!)
        //some header examples
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Defaults.shared.currentUser?.id ?? "", forHTTPHeaderField: "userid")
        request.setValue(Defaults.shared.sessionToken ?? "", forHTTPHeaderField: "x-access-token")
        request.setValue("1", forHTTPHeaderField: "deviceType")
        request.httpBody = data
        // self.showLoader()
        AF.request(request).responseJSON { response in
            print(response)
            switch (response.result) {
            case .success:
                
                //  self.hideLoader()
                break
                
            case .failure(let error):
                print(error)
                // self.hideLoader()
                break
                
            }
        }
    }
    
}
