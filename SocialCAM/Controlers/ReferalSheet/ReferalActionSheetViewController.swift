//
//  ReferalActionSheetViewController.swift
//  SocialCAM
//
//  Created by Siddharth on 10/06/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit
import SDWebImage

enum ReferralImageType {
    case camera
    case bitmoji
    case gallery
    case profilePic
    case appLogo
}

protocol ReferalActionSheetViewDelegate {
    func referralImageSelectedType(selectedType: ReferralImageType)
}

class ReferalActionSheetViewController: UIViewController {

    @IBOutlet weak var yourProfilePicImageView: UIImageView!
    var referralType: ReferralImageType?
    var delegate: ReferalActionSheetViewDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .clear
        if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
            if userImageURL.isEmpty {
                yourProfilePicImageView.isHidden = false
            }
            yourProfilePicImageView.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: R.image.placeHolderRef())
        } else {
            yourProfilePicImageView.image = R.image.placeHolderRef()
        }
    }
    
    @IBAction func didTapCloseButton(_ sender: UIButton) {
//        referralType = .cancel
//        delegate?.referralImageSelectedType(selectedType: referralType ?? .cancel)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapAppLogoButton(_ sender: UIButton) {
        referralType = .appLogo
        self.dismiss(animated: true) {
            self.delegate?.referralImageSelectedType(selectedType: self.referralType!)
        }
        
    }
    
    @IBAction func didTapYourProfilePic(_ sender: UIButton) {
        referralType = .profilePic
        self.dismiss(animated: true) {
            self.delegate?.referralImageSelectedType(selectedType: self.referralType!)
        }
    }
    
    @IBAction func didTapGalleryButton(_ sender: UIButton) {
        referralType = .gallery
        self.dismiss(animated: true) {
            self.delegate?.referralImageSelectedType(selectedType: self.referralType!)
        }
    }
    
    @IBAction func didTapBitMojiButton(_ sender: UIButton) {
        referralType = .bitmoji
        self.dismiss(animated: true) {
            self.delegate?.referralImageSelectedType(selectedType: self.referralType!)
        }
    }
    
    @IBAction func didTapCameraButton(_ sender: UIButton) {
        referralType = .camera
        self.dismiss(animated: true) {
            self.delegate?.referralImageSelectedType(selectedType: self.referralType!)
        }
    }
}
