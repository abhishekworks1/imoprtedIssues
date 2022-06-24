//
//  OnBoardingViewController.swift
//  SocialCAM
//
//  Created by Siddharth on 09/06/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

protocol QuickStartOptionable {
    var title: String { get }
    var description: String { get }
    var isLastStep: Bool { get }
    var isFirstStep: Bool { get }
    var rawValue: Int { get }
}

enum QuickStartOption {
    
    case createContent
    case mobileDashboard
    case makeMoney
    
    func option(for rawValue: Int) -> QuickStartOptionable? {
        switch self {
        case .createContent:
            return CreateContentOption(rawValue: rawValue)
        case .mobileDashboard:
            return MobileDashboardOption(rawValue: rawValue)
        case .makeMoney:
            return MakeMoneyOption(rawValue: rawValue)
        }
    }
    
    enum CreateContentOption: Int, QuickStartOptionable {
        var title: String {
            switch self {
            case .quickCamCamera:
                return "QuickCam Camera"
            case .fastSlowEditor:
                return "Fast & Slow Motion Recording"
            case .quickieVideoEditor:
                return "Quickie Video Editor"
            case .pic2Art:
                return "Pic2Art"
            case .bitmojis:
                return "Bitmojis"
            case .socialMediaSharing:
                return "Social Media Sharing"
            }
        }
        
        var description: String {
            switch self {
            case .quickCamCamera:
                return """
a. Fast and Slow Motion speeds depends on subscription level.

b. Free: 3x fast motion (No slow motion)

c. Basic: -3x slow motion up to 3x fast motion

d. Advanced: -4x slow motion up to 4x fast motion

e. Premium: -5x slow motion up to 5x fast motion
"""
            case .fastSlowEditor:
                return """
a. Simply touch and hold the record button, then move your finger to the right to record in fast motion, and move your finger to the left for slow motion. Return to the middle for normal speed.

b. Move your finger from bottom to top to zoom in and back down to zoom out while using the fast/slow motion real-time recording.

c. When you lift up your finger, your video will begin playing back immediately in the Quickie Video Editor.
"""
            case .quickieVideoEditor:
                return """
a. Quickly edit your video and share on social media.

b. Crop, trim and cut your videos.
"""
            case .bitmojis:
                return """
a. Connect your Snapchat account with your Bitmojis to QuickCam to integrate your bitmojis into your video quickies and Pic2Art.
"""
            case .socialMediaSharing:
                return """
 a. Share your video quickies on TikTok, Instagram, Snapchat, Facebook, YouTube, Twitter and more.

 b. Share your video quickies on local social media platforms like Chingari and Takatak.
"""
            case .pic2Art:
                return """
a. Turn your ordinary photos into beautiful digital art that you’ll want to print and hang on your wall!

b. 44 filters to choose from to create unique Pic2Art every time.
"""
            }
        }
        
        var isLastStep: Bool {
            return self == .socialMediaSharing
        }
        
        var isFirstStep: Bool {
            return self == .quickCamCamera
        }

        case quickCamCamera = 0
        case fastSlowEditor
        case quickieVideoEditor
        case pic2Art
        case bitmojis
        case socialMediaSharing
    }

    enum MobileDashboardOption: Int, QuickStartOptionable {
        var title: String {
            switch self {
            case .notifications:
                return "Notifications"
            case .howItWorks:
                return "How it Works"
            case .cameraSettings:
                return "Camera Settings"
            case .subscriptions:
                return "Subscription"
            case .checkForUpdates:
                return "Check Updates"
            }
        }
        
        var description: String {
            switch self {
            case .notifications:
                return """
a. Get a notification whenever one of your contacts signs up as a referral.

b. Get a notification whenever one of your referrals subscribes.

c. Get a notification whenever one of the channels you’re following earns a new badge!

d. Get a daily notification of the summary of the day’s referral activity.

e. Set your notifications to receive only the ones you want.
"""
            case .howItWorks:
                return """
a. Get all of the tutorials videos in one location in the How It Works.
"""
            case .cameraSettings:
                return """
a. Change the camera settings to unleash your style and optimize your creativity.

b. Camera settings options available are based on your subscription level.
"""
            case .subscriptions:
                return """
a. Premium 7-Day Free Trial

b. Free User mode afterward for non-subscribers

c. "Early-Bird Special" Subscription Price - During Pre-Launch

d. Android
    i. Basic -  $0.99/month
    ii. Advanced -  $1.99/month
    iii. Premium -  $3.99/month

e. iPhone
    i. Basic -  $1.99/month
    ii. Advanced -  $2.99/month
    iii. Premium -  $4.99/month

f. Regular Price - to be announced after Early Bird Special
"""
            case .checkForUpdates:
                return """
a. We periodically update the app to include additional features and bug fixes.
"""
            }
        }
        
        var isLastStep: Bool {
            return self == .checkForUpdates
        }
        
        var isFirstStep: Bool {
            return self == .notifications
        }
        
        case notifications = 0
        case howItWorks
        case cameraSettings
        case subscriptions
        case checkForUpdates
    }

    enum MakeMoneyOption: Int, QuickStartOptionable {
        var title: String {
            switch self {
            case .referralCommissionProgram:
                return "Referral Commissions Program"
            case .textEmailInviter:
                return "TextInviter™ & EmailInviter™"
            case .socialQRCodeShare:
                return "SocialSharing™ & QRCodeShare™"
            case .contactManagerTools:
                return "Contact Management Tools"
            case .fundraising:
                return "Great for Fundraising"
            }
            
        }
        
        var description: String {
            switch self {
            case .referralCommissionProgram:
                return """
a.  2-Level Referral Revenue Share
    i. When any of your referrals download QuickCam and subscribe, 50% of the subscription revenues is paid to you for the first 2 months. Thereafter, 25% is paid to you and 25% is paid to your referring channel.
    ii. When your referrals also refer to their contacts and those contacts sign up and subscribe, your referrals earn 25% and you'll earn a matching bonus of 25% on the 3rd month and thereafter.

b. How can I earn money?
    i. Share your videos with your referral link in your private snaps, direct messages, social media posts, email and text messages.
    ii. Share your QR code to your referral link in person and in print. For example, business cards and promotional material..
    iii. Let's say your contacts click on your referral link and sign up. When they confirm you as their referring channel, you'll get a notification letting you know you have new referrals.
    iv. When they subscribe, you begin earning ongoing passive monthly residual income!!

c. How much money can I earn?
    i. It depends on you and those you share QuickCam with.
    ii. We've provided a Potential Income Calculator so you can set your goals and find out.
    iii. Use the special effects to create fun and engaging videos to share online to get more referrals. The more referrals you have who subscribe, the more money you'll make.
    iv. Use the Mobile Dashboard TextShare, EmailShare, SocialShare and QRCodeShare to get more referrals.
    v. Login frequently to the QuickCam Business Dashboard to keep track of how much you're making.

"""
            case .textEmailInviter:
                return """
The following are the ways you can refer QuickCam to your friends, family, followers, neighbors, co-workers, church members, club members, non-profit supporters and everyone you know.

a. TextShare (tm)
    i. Use TextShare to invite your contacts by sending them a text with your unique referral link.
    ii. After you send your invites, each time you open Contact Manager, thereafter, you’ll be able to track the contacts you invited and see when the recipients have opened, signed up and subscribed.

b. EmailShare (tm)
    i. Use the EmailShare to invite your contacts by sending them an email with your unique referral link.
    ii. You’ll be able to connect your Gmail and Outlook email accounts to use the automated EmailShare to invite all of your contacts in one click.
    iii. You’ll be able to track the contacts you emailed and see when the recipients have opened, signed up and subscribed.
"""
            case .socialQRCodeShare:
                return """
The following are the ways you can refer QuickCam to your friends, family, followers, neighbors, co-workers, church members, club members, non-profit supporters and everyone you know.

a. SocialShare (tm)
    i. Use SocialShare to invite your social media followers by posting your unique referral link to your social media newsfeed.
    ii. For influencers with a large following, SocialShare is a way to get wide exposure to their referral link.
    iii. You can post to the following social media platforms that SocialShare supports: Facebook, Instagram, Snapchat, Twitter, Whatsapp, Messenger and more.

b. QRCodeShare (tm)
    i. Use QRCodeShare to invite your in-person contacts by sharing your QR Code.
    ii. When they scan your QR Code and sign up, you’ll receive credit as their referring channel.
"""
            case .contactManagerTools:
                return """
a. Business Dashboard
    i. The Business Dashboard is a management tool to keep track of your referrals, earnings, payout and more.
    ii. The Business Dashboard is a separate product from QuickCam camera apps. It's a subscription product with a premium free trial and free mode.
    iii. QuickCam Business Dashboard subscription is a separate subscription from the QuickCam camera app subscriptions.
    iv. Business Dashboard subscription option for premium features is for those who want to make money online. Subscription to QuickCam Business Dashboard will be activated at QuickCam Business Dashboard Official Launch. (to be announced)
    v. Access the QuickCam Business Dashboard directly from the QuickCam camera app.
    vi. QuickCam Business Dashboard Pre-Launch free version is available now.

b. Contact Manager
    i. Invite and track your referrals, see who has signed up and who’s subscribing.
"""
            case .fundraising:
                return """
a. Raise funds for clubs, groups or non-profits that you support by sharing your referral link.

b. Clubs, groups or non-profits can get their members to join and pledge a portion of their earnings when they refer Quickcam.

"""
            }
        }
        
        var isLastStep: Bool {
            return self == .fundraising
        }
        
        var isFirstStep: Bool {
            return self == .referralCommissionProgram
        }

        case referralCommissionProgram = 0
        case textEmailInviter
        case socialQRCodeShare
        case contactManagerTools
        case fundraising
    }
}

class OnBoardingViewController: UIViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var centerPlaceholderView: NSLayoutConstraint!
    @IBOutlet weak var heightPlaceholderView: NSLayoutConstraint!
    @IBOutlet weak var foundingMemberImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var subscriptionStatusLabel: UILabel!
    @IBOutlet weak var createContentStepIndicatorView: StepIndicatorView!
    @IBOutlet weak var mobileDashboardStepIndicatorView: StepIndicatorView!
    @IBOutlet weak var makeMoneyStepIndicatorView: StepIndicatorView!

    var showPopUpView: Bool = true
    var shouldShowFoundingMemberView: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for option in Defaults.shared.createContentOptions {
            createContentStepIndicatorView.finishedStep = option
        }
        for option in Defaults.shared.mobileDashboardOptions {
            mobileDashboardStepIndicatorView.finishedStep = option
        }
        for option in Defaults.shared.makeMoneyOptions {
            makeMoneyStepIndicatorView.finishedStep = option
        }
    }

    @IBAction func didTapMakeMoneyClick(_ sender: UIButton) {
        let hasAllowAffiliate = Defaults.shared.currentUser?.isAllowAffiliate ?? false
        if hasAllowAffiliate {
            self.setNavigation()
        } else {
            guard let makeMoneyReferringVC = R.storyboard.onBoardingView.makeMoneyReferringViewController() else { return }
            navigationController?.pushViewController(makeMoneyReferringVC, animated: true)
        }
    }
    
    
    @IBAction func createContent(_ sender: UIButton) {
        Defaults.shared.isSignupLoginFlow = true
        let rootViewController: UIViewController? = R.storyboard.pageViewController.pageViewController()
        Utils.appDelegate?.window?.rootViewController = rootViewController
    }
    
    @IBAction func didTapMobileDashboardClick(_ sender: UIButton) {
        let rootViewController: UIViewController? = R.storyboard.pageViewController.pageViewController()
        if let pageViewController = rootViewController as? PageViewController,
           let navigationController = pageViewController.pageControllers.first as? UINavigationController,
           let settingVC = R.storyboard.storyCameraViewController.storySettingsVC() {
            navigationController.viewControllers.append(settingVC)
        }
        Utils.appDelegate?.window?.rootViewController = rootViewController
    }
    
    @IBAction func didTapCloseClick(_ sender: UIButton) {
        popupView.isHidden = true
    }
    
    @IBAction func didTapOnCreateContentSteps(_ sender: UIButton) {
        guard let option = QuickStartOption.createContent.option(for: sender.tag),
              let quickStartDetail = R.storyboard.onBoardingView.quickStartOptionDetailViewController() else {
            return
        }
        var options = Defaults.shared.createContentOptions
        options.append(option.rawValue)
        Defaults.shared.createContentOptions = Array(Set(options))
        quickStartDetail.selectedOption = option
        quickStartDetail.selectedQuickStartMenu = .createContent
        navigationController?.pushViewController(quickStartDetail, animated: true)
    }
    
    @IBAction func didTapOnMobileDashboardSteps(_ sender: UIButton) {
        guard let option = QuickStartOption.mobileDashboard.option(for: sender.tag),
              let quickStartDetail = R.storyboard.onBoardingView.quickStartOptionDetailViewController() else {
            return
        }
        var options = Defaults.shared.mobileDashboardOptions
        options.append(option.rawValue)
        Defaults.shared.mobileDashboardOptions = Array(Set(options))
        quickStartDetail.selectedOption = option
        quickStartDetail.selectedQuickStartMenu = .mobileDashboard
        navigationController?.pushViewController(quickStartDetail, animated: true)
    }
    
    @IBAction func didTapOnMakeMoneySteps(_ sender: UIButton) {
        guard let option = QuickStartOption.makeMoney.option(for: sender.tag),
              let quickStartDetail = R.storyboard.onBoardingView.quickStartOptionDetailViewController() else {
            return
        }
        var options = Defaults.shared.makeMoneyOptions
        options.append(option.rawValue)
        Defaults.shared.makeMoneyOptions = Array(Set(options))
        quickStartDetail.selectedOption = option
        quickStartDetail.selectedQuickStartMenu = .makeMoney
        navigationController?.pushViewController(quickStartDetail, animated: true)
    }
    
}

extension OnBoardingViewController {
    
    func setupView() {
        popupView.isHidden = !self.showPopUpView
        UserSync.shared.syncUserModel { isCompleted in
            if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
                self.userImageView.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: R.image.user_placeholder())
            }
            let isFoundingMember = Defaults.shared.currentUser?.badges?.filter({ return $0.badge?.code == "founding-member" }).count ?? 0 > 0
            if isFoundingMember {
                self.foundingMemberImageView.isHidden = false
                self.centerPlaceholderView.constant = -30
                self.heightPlaceholderView.constant = 211
            } else {
                self.foundingMemberImageView.isHidden = true
                self.centerPlaceholderView.constant = 0
                self.heightPlaceholderView.constant = 110
            }
            self.userNameLabel.text = Defaults.shared.currentUser?.firstName
            if let badgearray = Defaults.shared.currentUser?.badges {
                for parentbadge in badgearray {
                    let badgeCode = parentbadge.badge?.code ?? ""
                    if badgeCode == Badges.SUBSCRIBER_IOS.rawValue {
                        let subscriptionType = parentbadge.meta?.subscriptionType ?? ""
                        let finalDay = Defaults.shared.getCountFromBadge(parentbadge: parentbadge)
                        if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                            if finalDay == "7" {
                                self.subscriptionStatusLabel.text = "Today is the last day of your 7-day free trial. Upgrade now to access these features"
                            } else {
                                var fday = 0
                                if let day = Int(finalDay) {
                                    if day <= 7 && day >= 0
                                    {
                                        fday = 7 - day
                                    }
                                }
                                if fday == 0{
                                    self.subscriptionStatusLabel.text = "Your 7-day free trial period has expired. Upgrade now to access these features."
                                } else {
                                    self.subscriptionStatusLabel.text = "You have \(fday) days left on your free trial. Subscribe now and earn your subscription badge."
                                }
                               
                            }
                        } else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
                            self.subscriptionStatusLabel.text = "Your 7-day free trial is over. Subscribe now to continue using the Basic, Advanced or Premium features."
                        }
                    }
                }
            }
        }
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
    
}
