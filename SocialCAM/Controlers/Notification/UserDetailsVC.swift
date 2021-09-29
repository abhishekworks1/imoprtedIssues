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
        } else {
            if let name = Defaults.shared.currentUser?.refferingChannel {
                self.lblUserName.text = "@\(name)"
            }
        }
        self.imgUserImage.layer.cornerRadius = imgUserImage.bounds.width / 2
        self.imgUserImage.contentMode = .scaleAspectFill
        if let userImageURL = notification?.refereeUserId?.profileImageURL {
            self.imgUserImage.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: R.image.user_placeholder())
        } else {
            if let userImageUrl = Defaults.shared.currentUser?.refferedBy?.profileImageURL {
                self.imgUserImage.sd_setImage(with: URL.init(string: userImageUrl), placeholderImage: R.image.user_placeholder())
            }
        }
        self.getVerifiedSocialPlatforms()
        if let createdDate = notification?.createdAt {
            self.lblJoiningDate.text = R.string.localizable.sinceJoined(convertDate(createdDate))
        } else {
            if let referredUserCreatedDate = Defaults.shared.referredUserCreatedDate {
                self.lblJoiningDate.text = R.string.localizable.sinceJoined(convertDate(referredUserCreatedDate))
            }
        }
    }
    
    func getVerifiedSocialPlatforms() {
        if let socialPlatforms = notification?.refereeUserId?.socialPlatforms, socialPlatforms.count > 0 {
            socialPlatFormSettings(socialPlatforms as! [String])
        } else if let socialPlatforms = Defaults.shared.referredByData?.socialPlatforms, socialPlatforms.count > 0 {
            socialPlatFormSettings(socialPlatforms)
        } else {
            verifiedStackView.isHidden = true
        }
    }
    
    func socialPlatFormSettings(_ socialPlatfroms: [String]) {
        verifiedStackView.isHidden = false
        for socialPlatform in socialPlatfroms {
            if socialPlatform == R.string.localizable.facebook().lowercased() {
                self.facebookVerifiedView.isHidden = false
            } else if socialPlatform == R.string.localizable.twitter().lowercased() {
                self.twitterVerifiedView.isHidden = false
            } else if socialPlatform == R.string.localizable.snapchat().lowercased() {
                self.snapchatVerifiedView.isHidden = false
            } else if socialPlatform == R.string.localizable.youtube().lowercased() {
                self.youtubeVerifiedView.isHidden = false
            }
        }
        self.imgUserPlaceholder.image = (socialPlatfroms.count == 4) ? R.image.shareScreenRibbonProfileBadge() : R.image.shareScreenProfileBadge()
    }
    
    func convertDate(_ date: String) -> String {
        let convertedDate = CommonFunctions.getDateInSpecificFormat(dateInput: date, dateOutput: R.string.localizable.mmmdYyyy())
        return convertedDate
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
