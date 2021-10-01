//
//  UserDetailsVC.swift
//  SocialCAM
//
//  Created by Viraj Patel on 24/09/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import Foundation

class UserDetailsVC: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var popupContentContainerView: UIView!
    @IBOutlet weak var popupMainView: UIView! {
        didSet {
            popupMainView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblJoiningDate: UILabel!
    @IBOutlet weak var imgUserPlaceholder: UIImageView!
    @IBOutlet weak var imgUserImage: UIImageView!
    @IBOutlet weak var verifiedStackView: UIStackView!
    @IBOutlet weak var facebookVerifiedView: UIView!
    @IBOutlet weak var twitterVerifiedView: UIView!
    @IBOutlet weak var snapchatVerifiedView: UIView!
    @IBOutlet weak var youtubeVerifiedView: UIView!
    @IBOutlet weak var btnFollow: PButton!
    
    var notification: UserNotification?
    
    var customBlurEffectStyle: UIBlurEffect.Style = .dark
    var customInitialScaleAmmount: CGFloat = CGFloat(Double(0.1))
    var customAnimationDuration: TimeInterval = TimeInterval(0.5)
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        customBlurEffectStyle == .dark ? .lightContent : .default
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    // MARK: - IBActions
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    func setup() {
        if let channelId = notification?.refereeUserId?.channelId {
            self.lblUserName.text = "@\(channelId)"
        }
        if let userImageURL = notification?.refereeUserId?.profileImageURL {
            self.imgUserImage.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: R.image.user_placeholder())
            self.imgUserImage.layer.cornerRadius = imgUserImage.bounds.width / 2
            self.imgUserImage.contentMode = .scaleAspectFill
        }
        self.getVerifiedSocialPlatforms()
        if let createdDate = notification?.createdAt {
            let date = CommonFunctions.getDateInSpecificFormat(dateInput: createdDate, dateOutput: R.string.localizable.mmmdYyyy())
            self.lblJoiningDate.text = R.string.localizable.sinceJoined(date)
        }
        
        btnFollow.backgroundColor = ApplicationSettings.appPrimaryColor
        btnFollow.setTitleColor(ApplicationSettings.appWhiteColor, for: .normal)
        btnFollow.setTitle(R.string.localizable.following(), for: .normal)
    }
    
    func getVerifiedSocialPlatforms() {
        if let socialPlatforms = notification?.refereeUserId?.socialPlatforms, socialPlatforms.count > 0 {
            verifiedStackView.isHidden = false
            for socialPlatform in socialPlatforms {
                if socialPlatform as! String == R.string.localizable.facebook().lowercased() {
                    self.facebookVerifiedView.isHidden = false
                } else if socialPlatform as! String == R.string.localizable.twitter().lowercased() {
                    self.twitterVerifiedView.isHidden = false
                } else if socialPlatform as! String == R.string.localizable.snapchat().lowercased() {
                    self.snapchatVerifiedView.isHidden = false
                } else if socialPlatform as! String == R.string.localizable.youtube().lowercased() {
                    self.youtubeVerifiedView.isHidden = false
                }
            }
            if socialPlatforms.count >= 4 {
                self.imgUserPlaceholder.image = R.image.shareScreenSocialProfileBadge()
            }
        } else {
            verifiedStackView.isHidden = true
        }
    }
}

// MARK: - MIBlurPopupDelegate

extension UserDetailsVC: MIBlurPopupDelegate {
    
    var popupView: UIView {
        popupContentContainerView ?? UIView()
    }
    
    var blurEffectStyle: UIBlurEffect.Style? {
        customBlurEffectStyle
    }
    
    var initialScaleAmmount: CGFloat {
        customInitialScaleAmmount
    }
    
    var animationDuration: TimeInterval {
        customAnimationDuration
    }
    
}
