//
//  WelcomeViewController.swift
//  SocialCAM
//
//  Created by Satish Rajpurohit on 23/06/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit
import SafariServices

class WelcomeViewController: UIViewController {

    @IBOutlet weak var timerLeftLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var subscriptionDetailLabel: UILabel!
    @IBOutlet weak var timerStackView: UIStackView!
    @IBOutlet weak var dayValueLabel: UILabel!
    @IBOutlet weak var hourValueLabel: UILabel!
    @IBOutlet weak var minValueLabel: UILabel!
    @IBOutlet weak var secValueLabel: UILabel!
    @IBOutlet weak var freeModeDayImageView: UIImageView!
    @IBOutlet weak var freeModeHourImageView: UIImageView!
    @IBOutlet weak var freeModeMinImageView: UIImageView!
    @IBOutlet weak var freeModeSecImageView: UIImageView!
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var secLabel: UILabel!
    
    @IBOutlet weak var dayLineView: UIView!
    @IBOutlet weak var hourLineView: UIView!
    @IBOutlet weak var minLineView: UIView!
    @IBOutlet weak var secLineView: UIView!
    @IBOutlet weak var upgradeNowButton: UIButton!
    @IBOutlet weak var upgradeButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var timeStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var semiHalfView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var foundingMemberImageView: UIImageView!
    @IBOutlet weak var badgeImageView: UIImageView!
    
    @IBOutlet weak var profileWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var profileHeightConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var tipOfDayActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var whatDoYouWantSeeView: UIView!
    @IBOutlet weak var whatDoYouWantSeeViewBoxButton: UIButton! {
        didSet {
            whatDoYouWantSeeViewBoxButton.setImage(UIImage(named: "checkBoxInActive"), for: .normal)
        }
    }
    @IBOutlet weak var tipOfTheDayLabel: UILabel!
    @IBOutlet weak var tipOfTheDayView: UIView! {
        didSet {
            tipOfTheDayView.isHidden = true
        }
    }
    @IBOutlet weak var quickGuideStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mobileDashboardStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var whatToSeeStackViewHeight: NSLayoutConstraint!
    @IBOutlet var selectFeatureDetailSwitch: UISwitch!
    @IBOutlet var selectFeatureDetailLabels: [UILabel]!
    @IBOutlet weak var whatToSeeFirstBaseView: UIView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideWhatToSee))
            whatToSeeFirstBaseView.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet weak var lblAppInfo: UILabel! {
        didSet {
            lblAppInfo.text = "\(Constant.Application.displayName) - 1.2(41.\(Constant.Application.appBuildNumber))"
        }
    }
    @IBOutlet weak var imgAppLogo: UIImageView! {
        didSet {
//            setupUI()
        }
    }
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var channelNameLabel: UILabel!
    
    //Badges
    @IBOutlet weak var preLaunchBadgeImageView: UIImageView!
    @IBOutlet weak var foundingMemberBadgeImageView: UIImageView!
    @IBOutlet weak var socialBadgeImageView: UIImageView!
    @IBOutlet weak var dayBadgeImageView: UIImageView!

    @IBOutlet weak var iosBadgeView: UIView!
    @IBOutlet weak var iosShieldImageview: UIImageView!
    @IBOutlet weak var iosIconImageview: UIImageView!
    @IBOutlet weak var iosRemainingDaysLabel: UILabel!
    
    @IBOutlet weak var androidBadgeView: UIView!
    @IBOutlet weak var androidShieldImageview: UIImageView!
    @IBOutlet weak var androidIconImageview: UIImageView!
    @IBOutlet weak var androidRemainingDaysLabel: UILabel!

    @IBOutlet weak var webBadgeView: UIView!
    @IBOutlet weak var webShieldImageview: UIImageView!
    @IBOutlet weak var webIconImageview: UIImageView!
    @IBOutlet weak var webRemainingDaysLabel: UILabel!

    private var countdownTimer: Timer?
    var isTrialExpire = false
    var fromLogin = false
    let lastWelcomeTimerAlertDateKey = "lastWelcomeTimerAlertDate"
    var isWhatDoYouWantSeeViewChecked = false

    var loadingView: LoadingView? = LoadingView.instanceFromNib()
    var isFirstTime = true
    
    weak var tipTimer: Timer?
    var currentSelectedTip: Int = 0
    var tipArray = [String]()
    
    @IBOutlet weak var btnProfilePic: UIButton!
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    var imageSource = ""
    var croppedImg: UIImage?
    private lazy var storyCameraVC = StoryCameraViewController()
    var profilePicHelper: ProfilePicHelper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectFeatureDetailSwitch.setOn(Defaults.shared.shouldDisplayDetailsOfWelcomeScreenFeatures, animated: false)
        selectFeatureChanged(selectFeatureDetailSwitch)
        self.activityIndicator.hidesWhenStopped = true
//        self.whatDoYouWantSeeView.isHidden = !Defaults.shared.shouldDisplayQuickStartFirstOptionSelection
    }
    
    private func setupUI() {
        #if SOCIALCAMAPP
        imgAppLogo.image = R.image.socialCamSplashLogo()
        #elseif VIRALCAMAPP
        imgAppLogo.image = R.image.viralcamrgb()
        #elseif SOCCERCAMAPP || FUTBOLCAMAPP
        imgAppLogo.image = R.image.soccercamWatermarkLogo()
        #elseif QUICKCAMAPP
        imgAppLogo.image = R.image.ssuQuickCam()
        #elseif SNAPCAMAPP
        imgAppLogo.image = R.image.snapcamWatermarkLogo()
        #elseif SPEEDCAMAPP
        imgAppLogo.image = R.image.ssuSpeedCam()
        #elseif TIMESPEEDAPP
        imgAppLogo.image = R.image.timeSpeedWatermarkLogo()
        #elseif FASTCAMAPP
        imgAppLogo.image = R.image.ssuFastCam()
        #elseif BOOMICAMAPP
        imgAppLogo.image = R.image.boomicamWatermarkLogo()
        #elseif VIRALCAMLITEAPP
        imgAppLogo.image = R.image.viralcamLiteWatermark()
        #elseif FASTCAMLITEAPP
        imgAppLogo.image = R.image.ssuFastCamLite()
        #elseif QUICKCAMLITEAPP || QUICKAPP
        imgAppLogo.image = (Defaults.shared.releaseType == .store) ? R.image.ssuQuickCam() : R.image.ssuQuickCamLite()
        #elseif SPEEDCAMLITEAPP
        imgAppLogo.image = R.image.speedcamLiteSsu()
        #elseif SNAPCAMLITEAPP
        imgAppLogo.image = R.image.snapcamliteSplashLogo()
        #elseif RECORDERAPP
        imgAppLogo.image = R.image.socialScreenRecorderWatermarkLogo()
        #else
        imgAppLogo.image = R.image.pic2artWatermarkLogo()
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.dropShadowNew()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        countdownTimer?.invalidate()
        tipTimer?.invalidate()
    }
    
    @objc func hideWhatToSee() {
        whatToSeeFirstBaseView.isHidden = true
    }
    
    @IBAction func whatDoYouWantSeeViewBoxOnClick(_ sender: Any) {
        if isWhatDoYouWantSeeViewChecked {
            isWhatDoYouWantSeeViewChecked = false
            whatDoYouWantSeeViewBoxButton.setImage(UIImage(named: "checkBoxInActive"), for: .normal)
        } else {
            isWhatDoYouWantSeeViewChecked = true
            whatDoYouWantSeeViewBoxButton.setImage(UIImage(named: "checkBoxActive"), for: .normal)
        }
    }
    
    @IBAction func selectFeatureChanged(_ sender: UISwitch) {
        Defaults.shared.shouldDisplayDetailsOfWelcomeScreenFeatures = sender.isOn
        quickGuideStackViewHeight.constant = sender.isOn ? 200 : 132
        mobileDashboardStackViewHeight.constant = sender.isOn ? 278 : 132
        whatToSeeStackViewHeight.constant = sender.isOn ? 200 : 132
        selectFeatureDetailLabels.map({ $0.isHidden = !sender.isOn })
    }
    
    @IBAction func selectFeatureOnClick(_ sender: UIButton) {
        Defaults.shared.callHapticFeedback(isHeavy: false)
        switch sender.tag {
        case 0:
            Defaults.shared.isSignupLoginFlow = true
            if let storySettingsVC = R.storyboard.storyCameraViewController.storyCameraViewController() {
                storySettingsVC.isFromCameraParentView = true
                navigationController?.pushViewController(storySettingsVC, animated: true)
            }
            break
        case 1:
            if Defaults.shared.shouldDisplayQuickStartFirstOptionSelection {
                whatToSeeFirstBaseView.isHidden = false
            } else {
                openOnboarding()
            }
        case 2:
            let storySettingsVC = R.storyboard.storyCameraViewController.storySettingsVC()!
            navigationController?.pushViewController(storySettingsVC, animated: true)
            break
        case 3:
            if let token = Defaults.shared.sessionToken {
                 let urlString = "\(websiteUrl)/redirect?token=\(token)"
                 guard let url = URL(string: urlString) else {
                     return
                 }
                let safariVC = SFSafariViewController(url: url)
                present(safariVC, animated: true, completion: nil)
             }
            break
        default: break
        }
    }
    
    @IBAction func upgradeNowOnClick(_ sender: Any) {
        Defaults.shared.callHapticFeedback(isHeavy: false)
        if let subscriptionVC = R.storyboard.subscription.subscriptionContainerViewController() {
            subscriptionVC.isFromWelcomeScreen = true
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.pushViewController(subscriptionVC, animated: true)
        }
    }
    
    func openOnboarding() {
        guard let onBoardView = R.storyboard.onBoardingView.onBoardingViewController() else { return }
        (onBoardView.viewControllers.first as? OnBoardingViewController)?.showPopUpView = false
        (onBoardView.viewControllers.first as? OnBoardingViewController)?.fromNavigation = true
        self.navigationController?.pushViewController((onBoardView.viewControllers.first as? OnBoardingViewController)!, animated: true)
    }
    
    @IBAction func continueOnClick(_ sender: Any) {
        openOnboarding()
    }
    
    @IBAction func makeMoneyOptionClicked(_ sender: Any) {
        Defaults.shared.callHapticFeedback(isHeavy: false)
        Defaults.shared.shouldDisplayQuickStartFirstOptionSelection = !isWhatDoYouWantSeeViewChecked
        Defaults.shared.selectedQuickStartOption = .makeMoney
        UserSync.shared.setOnboardingUserFlags()
        whatToSeeFirstBaseView.isHidden = true
        openOnboarding()
    }
    
    @IBAction func createContentOptionClicked(_ sender: Any) {
        Defaults.shared.callHapticFeedback(isHeavy: false)
        Defaults.shared.shouldDisplayQuickStartFirstOptionSelection = !isWhatDoYouWantSeeViewChecked
        Defaults.shared.selectedQuickStartOption = .createContent
        UserSync.shared.setOnboardingUserFlags()
        whatToSeeFirstBaseView.isHidden = true
        openOnboarding()
    }
}

extension WelcomeViewController {
    func setupView() {
        subscriptionDetailLabel.textAlignment = .left
        
        self.updateUserProfilePic()
        
        self.displayNameLabel.text = Defaults.shared.publicDisplayName
        self.channelNameLabel.text = "@\(Defaults.shared.currentUser?.channelName ?? (R.string.localizable.channelName(Defaults.shared.currentUser?.channelId ?? "")))"
        self.checkTrailPeriodExpire()
      //  self.setSubscriptionBadgeDetails()
        self.getDays()
        self.setUpgradeButton()
        self.showLoader()
//        self.tipOfTheDayLabel.text = Defaults.shared.tipOfDay?[0]
        checkTipOfDayText(tipOfDay: Defaults.shared.tipOfDay?[0] ?? "")
        UserSync.shared.getTipOfDay { [self] tip in
            self.tipArray = Defaults.shared.tipOfDay ?? [String]()
//            self.tipOfTheDayLabel.text = Defaults.shared.tipOfDay?[0]
            checkTipOfDayText(tipOfDay: Defaults.shared.tipOfDay?[0] ?? "")
            self.startTipTimer()
        }
        UserSync.shared.syncUserModel { isCompleted in
            self.tipOfTheDayView.isHidden = !Defaults.shared.shouldDisplayTipOffDay
            UserSync.shared.getOnboardingUserFlags { isCompleted in
                self.hideLoader()
                
//                self.whatDoYouWantSeeView.isHidden = !Defaults.shared.shouldDisplayQuickStartFirstOptionSelection
                self.tipOfTheDayView.isHidden = !Defaults.shared.shouldDisplayTipOffDay
                Defaults.shared.shouldDisplayTipOffDay = true
                UserSync.shared.setOnboardingUserFlags()
            }
            
            self.updateUserProfilePic()
            
            let isFoundingMember = Defaults.shared.currentUser?.badges?.filter({ return $0.badge?.code == "founding-member" }).count ?? 0 > 0
            if isFoundingMember {
                self.foundingMemberImageView.isHidden = false
            } else {
                self.foundingMemberImageView.isHidden = true
                self.profileWidthConstraints.constant = 143
                self.profileHeightConstraints.constant = 143
                self.userImageView.layer.cornerRadius = 71.5
                self.view.updateConstraintsIfNeeded()
                self.view.setNeedsUpdateConstraints()
            }
            self.checkTrailPeriodExpire()
            self.displayNameLabel.text = Defaults.shared.publicDisplayName
            self.channelNameLabel.text = "@\(Defaults.shared.currentUser?.channelName ?? (R.string.localizable.channelName(Defaults.shared.currentUser?.channelId ?? "")))"
            //    self.setSubscriptionBadgeDetails()

            if self.checkIfWelcomePopupShouldAppear()
            {
//                self.showWelcomeTimerAlert()
                self.checkIfWelcomeTimerAlertShownToday()
            }
            self.getDays()
            self.hideLoader()
            self.setUpgradeButton()
            self.setUpSubscriptionBadges()
        }
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        self.userImageView.isUserInteractionEnabled = true
        self.userImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func updateUserProfilePic() {
        self.btnProfilePic.isHidden = false
        
        if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
            if userImageURL.contains("http") {
                self.btnProfilePic.isHidden = true
                if self.tapGestureRecognizer != nil {
                    self.userImageView.removeGestureRecognizer(self.tapGestureRecognizer)
                }
            }
            self.userImageView.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: R.image.user_placeholder())
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        if let tappedImage = tapGestureRecognizer.view as? UIImageView {
            self.openSocialShareVC()
        }
    }
    
    func checkTipOfDayText(tipOfDay: String) {
        tipOfDayActivityIndicator.isHidden = false
        tipOfDayActivityIndicator.startAnimating()
        tipOfTheDayLabel.text = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [self] in
            // Do whatever you want
            tipOfDayActivityIndicator.stopAnimating()
            tipOfDayActivityIndicator.isHidden = true
            tipOfTheDayLabel.text = tipOfDay
        }
    }
    func checkIfWelcomePopupShouldAppear() -> Bool {
       if let subscriptionStatus = Defaults.shared.currentUser?.subscriptionStatus {
            if subscriptionStatus == SubscriptionTypeForBadge.TRIAL.rawValue || subscriptionStatus == SubscriptionTypeForBadge.FREE.rawValue || subscriptionStatus == SubscriptionTypeForBadge.EXPIRE.rawValue {
               return true
            } else {
                return false
            }
        }
        return false
    }
    func checkIfWelcomeTimerAlertShownToday() {
        if let lastAlertDate = UserDefaults.standard.object(forKey: lastWelcomeTimerAlertDateKey) as? Date {
            if Calendar.current.isDateInToday(lastAlertDate) {
                print("Alert was shown today!")
            } else {
                showWelcomeTimerAlert()
            }
        } else {
            showWelcomeTimerAlert()
        }
    }
    func setUpgradeButton() {
        upgradeNowButton.isHidden = true
        if let paidSubscriptionStatus = Defaults.shared.currentUser?.paidSubscriptionStatus {
            if paidSubscriptionStatus.lowercased() == SubscriptionTypeForBadge.BASIC.rawValue || paidSubscriptionStatus.lowercased() == SubscriptionTypeForBadge.ADVANCE.rawValue || paidSubscriptionStatus.lowercased() == SubscriptionTypeForBadge.PREMIUM.rawValue || paidSubscriptionStatus.lowercased() == SubscriptionTypeForBadge.PRO.rawValue {
                upgradeNowButton.isHidden = true
            }
        } else if let subscriptionStatus = Defaults.shared.currentUser?.subscriptionStatus {
            if subscriptionStatus == SubscriptionTypeForBadge.TRIAL.rawValue || subscriptionStatus == SubscriptionTypeForBadge.FREE.rawValue || subscriptionStatus == SubscriptionTypeForBadge.EXPIRE.rawValue {
                upgradeNowButton.isHidden = false
            } else {
                upgradeNowButton.isHidden = true
            }
        } else {
            upgradeNowButton.isHidden = false
        }
        if upgradeNowButton.isHidden {
            upgradeButtonHeight.constant = 0
        } else {
            upgradeButtonHeight.constant = 32
        }
    }
    
    func showWelcomeTimerAlert() {
        print("Need to show an alert today!")
        UserDefaults.standard.set(Date(), forKey: lastWelcomeTimerAlertDateKey)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeTimerPopupViewController") as! WelcomeTimerPopupViewController
        //        vc.delegate = self
        vc.providesPresentationContextTransitionStyle = true;
        vc.definesPresentationContext = true;
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        vc.upgradeButtonAction = {
            if let subscriptionVC = R.storyboard.subscription.subscriptionContainerViewController() {
                subscriptionVC.isFromWelcomeScreen = true
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.pushViewController(subscriptionVC, animated: true)
            }
            
//            guard let subscriptionVc = R.storyboard.subscription.subscriptionsViewController() else { return }
//            subscriptionVc.appMode = .professional
//            subscriptionVc.subscriptionType = .professional
//            subscriptionVc.isFromWelcomeScreen = true
//            self.navigationController?.isNavigationBarHidden = true
//            self.navigationController?.pushViewController(subscriptionVc, animated: true)
        }
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func showLoader() {
        guard isFirstTime else {
            self.activityIndicator.startAnimating()
            upgradeNowButton.isHidden = false
            return
        }
        upgradeNowButton.isHidden = true
        isFirstTime = false
    }
    
    func hideLoader() {
        self.activityIndicator.stopAnimating()
    }
}

extension WelcomeViewController {
    func startTipTimer() {
        if currentSelectedTip < tipArray.count {
//            tipOfTheDayLabel.text = tipArray[currentSelectedTip]
            checkTipOfDayText(tipOfDay: tipArray[currentSelectedTip])
        }
        tipTimer =  Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] (_) in
            guard let `self` = self else {
                return
            }
            self.manageTip()
        }
//        tipTimer?.tolerance = 0.1
    }
    func manageTip() {
        let nIndex = currentSelectedTip + 1
        if nIndex < tipArray.count {
            currentSelectedTip += 1
        } else {
            currentSelectedTip = 0
        }
        if currentSelectedTip < tipArray.count {
//            self.tipOfTheDayLabel.text = self.tipArray[self.currentSelectedTip]
            checkTipOfDayText(tipOfDay: self.tipArray[self.currentSelectedTip])
        }
    }
    func showTimer(createdDate: Date) {
        countdownTimer?.invalidate()
        timerStackView.isHidden = false
        timeStackViewHeight.constant = 72
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.day = 7
        if let futureDate = Calendar.current.date(byAdding: dateComponent, to: createdDate) {
            self.countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                let countdown = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: futureDate)
                let days = countdown.day!
                let hours = countdown.hour!
                let minutes = countdown.minute!
                let seconds = countdown.second!
                self.secValueLabel.text = String(format: "%02d", seconds)
                self.minValueLabel.text = String(format: "%02d", minutes)
                self.hourValueLabel.text = String(format: "%02d", hours)
                self.dayValueLabel.text = String(format: "%01d", days)
            }
        }
    }
    
    func checkTrailPeriodExpire() {
        if let badgearray = Defaults.shared.currentUser?.badges {
            for parentbadge in badgearray {
                let badgeCode = parentbadge.badge?.code ?? ""
                if badgeCode == Badges.SUBSCRIBER_IOS.rawValue {
                    if let createdDate = parentbadge.createdAt?.isoDateFromString() {
                        var dateComponent = DateComponents()
                        dateComponent.day = 7
                        if let futureDate = Calendar.current.date(byAdding: dateComponent, to: createdDate) {
                            let trailDate = futureDate.timeIntervalSince(Date())
                            self.isTrialExpire = trailDate.sign == .minus ? true : false
                        }
                    }
                }
            }
        }
    }
    
    func setSubscriptionBadgeDetails(){
        timerStackView.isHidden = true
        timeStackViewHeight.constant = 0
        freeModeDayImageView.isHidden = true
        freeModeMinImageView.isHidden = true
        freeModeSecImageView.isHidden = true
        freeModeHourImageView.isHidden = true
        if let badgearray = Defaults.shared.currentUser?.badges {
            for parentbadge in badgearray {
                let badgeCode = parentbadge.badge?.code ?? ""

                if badgeCode == Badges.SUBSCRIBER_IOS.rawValue
                {
                    let subscriptionType = Defaults.shared.currentUser!.subscriptionStatus!
                    let finalDay = Defaults.shared.getCountFromBadge(parentbadge: parentbadge)
                   
                    var fday = 0
                    if let day = Int(finalDay) {
                        if day <= 7 && day >= 0
                        {
                            fday = 7 - day
                        }
                    }
                    subscriptionDetailLabel.text = ""
                    if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                       if finalDay == "7" {
                           subscriptionDetailLabel.text = "Today is the last day of your 7-Day Premium Free Trial"
                           if let createdDate = parentbadge.createdAt?.isoDateFromString() {
                               showTimer(createdDate: createdDate)
                           }
                           self.setuptimerViewBaseOnDayLeft(days: "1", subscriptionType: subscriptionType)
                        } else {
                            fday = isTrialExpire ? 0 : fday
                            if fday == 0 {
                                self.setuptimerViewBaseOnDayLeft(days: "0", subscriptionType: subscriptionType)
                            } else {
                                self.setuptimerViewBaseOnDayLeft(days: "\(fday + 1)", subscriptionType: subscriptionType)
                                if fday + 1 == 7 {
                                    subscriptionDetailLabel.text = "Your 7-Day Premium Free Trial has started. You have 7 days to access all the QuickCam premium features for free while learning how to create fun and engaging content and/or make money sharing QuickCam."
                                } else {
                                    subscriptionDetailLabel.text = "You have \(fday + 1) days left on your free trial. Subscribe now and earn your subscription badge."
                                }
                                if let createdDate = parentbadge.createdAt?.isoDateFromString() {
                                    showTimer(createdDate: createdDate)
                                }
                            }
                        }
                        if fday == 0 {
                            self.setuptimerViewBaseOnDayLeft(days: "0", subscriptionType: subscriptionType)
                        }
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
                        self.setuptimerViewBaseOnDayLeft(days: "0", subscriptionType: subscriptionType)
                    } else if subscriptionType == "expired" {
                        subscriptionDetailLabel.text = "Your subscription has ended. Please upgrade your account now to resume using the basic, advanced or premium features."
                        self.setuptimerViewBaseOnDayLeft(days: "0", subscriptionType: subscriptionType)
                    } else {
                        
                        if finalDay == "7" {
                            subscriptionDetailLabel.text = "Today is the last day of your 7-Day Premium Free Trial"
                            if let createdDate = parentbadge.createdAt?.isoDateFromString() {
                                showTimer(createdDate: createdDate)
                            }
                            self.setuptimerViewBaseOnDayLeft(days: "1", subscriptionType: subscriptionType)
                        } else {
                            fday = isTrialExpire ? 0 : fday
                            if fday == 0  {
                               self.timerStackView.isHidden = true
                                timeStackViewHeight.constant = 0
                                setUpTimerViewForZeroDaySubscription(subscriptionType: subscriptionType)
                            } else {
                                self.setuptimerViewBaseOnDayLeft(days: "\(fday + 1)", subscriptionType: subscriptionType)
                                if fday + 1 == 7 {
                                    subscriptionDetailLabel.text = "Your 7-Day Premium Free Trial has started. You have 7 days to access all the QuickCam premium features for free while learning how to create fun and engaging content and/or make money sharing QuickCam."
                                } else {
                                    subscriptionDetailLabel.text = "You have \(fday + 1) days left on your free trial. Subscribe now and earn your subscription badge."
                                }
                                if let createdDate = parentbadge.createdAt?.isoDateFromString() {
                                    showTimer(createdDate: createdDate)
                                }
                            }
                        }
                        self.subscribersHideTimer(subscriptionType: subscriptionType)
                    }
                }
            }
        }
    }
    
}

extension WelcomeViewController {
    
    func setuptimerViewBaseOnDayLeft(days: String, subscriptionType: String) {
        print("----o \(subscriptionType)")
        if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
            setUpLineIndicatorForSignupDay(lineColor: UIColor(red: 1, green: 0, blue: 0, alpha: 1))
            
            if days == "0" {
                setImageForDays(days: days, imageName: "freeOnboard")
                subscriptionDetailLabel.text = "Your 7-Day Premium Free Trial has ended. Please upgrade your subscription to resume using the Premium features."
                setUpTimerViewForZeroDay()
            } else if (days == "7") {
                setUpTimerViewForSignupDay()
            }
            else {
                setImageForDays(days: days, imageName: "freeOnboard")
                setUpTimerViewForOtherDay()
            }
            
        } else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
            subscriptionDetailLabel.text = "Your 7-Day Premium Free Trial has ended. Please upgrade your subscription to resume using the Premium features."
            setImageForDays(days: "1", imageName: "freeOnboard")
            setUpTimerViewForOtherDay()
            //setUpTimerViewForZeroDay()
        } else if subscriptionType == SubscriptionTypeForBadge.EXPIRE.rawValue {
            setImageForDays(days: "1", imageName: "freeOnboard")
            setUpTimerViewForOtherDay()
            //setUpTimerViewForZeroDay()
        } else if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
            setUpLineIndicatorForSignupDay(lineColor: UIColor(red: 0.614, green: 0.465, blue: 0.858, alpha: 1))
            if (days == "7") {
                setUpTimerViewForSignupDay()
            } else {
                setImageForDays(days: days, imageName: "basicOnboard")
                setUpTimerViewForOtherDay()
            }
            
        } else if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
            setUpLineIndicatorForSignupDay(lineColor: UIColor(red: 0.212, green: 0.718, blue: 1, alpha: 1))
            if (days == "7") {
                setUpTimerViewForSignupDay()
            } else {
                setImageForDays(days: days, imageName: "advanceOnboard")
                setUpTimerViewForOtherDay()
            }
        } else if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue || subscriptionType == SubscriptionTypeForBadge.PREMIUM.rawValue {
            setUpLineIndicatorForSignupDay(lineColor: UIColor(red: 0.38, green: 0, blue: 1, alpha: 1))
            if (days == "7") {
                setUpTimerViewForSignupDay()
            } else {
                setImageForDays(days: days, imageName: "premiumOnboard")
                setUpTimerViewForOtherDay()
            }
        }
    }
    
    func setUpTimerViewForZeroDay() {
        timerStackView.isHidden = false
        timeStackViewHeight.constant = 72
        freeModeDayImageView.isHidden = false
        freeModeMinImageView.isHidden = false
        freeModeSecImageView.isHidden = false
        freeModeHourImageView.isHidden = false
        dayLineView.isHidden = true
        hourLineView.isHidden = true
        minLineView.isHidden = true
        secLineView.isHidden = true
        dayLabel.isHidden = true
        hourLabel.isHidden = true
        minLabel.isHidden = true
        secLabel.isHidden = true
        dayValueLabel.isHidden = true
        hourValueLabel.isHidden = true
        secValueLabel.isHidden = true
        minValueLabel.isHidden = true
        
    }
    
    func setUpTimerViewForOtherDay() {
        timerStackView.isHidden = false
        timeStackViewHeight.constant = 72
        freeModeDayImageView.isHidden = false
        freeModeMinImageView.isHidden = false
        freeModeSecImageView.isHidden = false
        freeModeHourImageView.isHidden = false
        dayLineView.isHidden = true
        hourLineView.isHidden = true
        minLineView.isHidden = true
        secLineView.isHidden = true
        dayLabel.isHidden = false
        hourLabel.isHidden = false
        minLabel.isHidden = false
        secLabel.isHidden = false
        dayValueLabel.isHidden = false
        hourValueLabel.isHidden = false
        secValueLabel.isHidden = false
        minValueLabel.isHidden = false
    }
    
    func setUpTimerViewForSignupDay() {
        timerStackView.isHidden = false
        timeStackViewHeight.constant = 72
        freeModeDayImageView.isHidden = true
        freeModeMinImageView.isHidden = true
        freeModeSecImageView.isHidden = true
        freeModeHourImageView.isHidden = true
        dayLineView.isHidden = false
        hourLineView.isHidden = false
        minLineView.isHidden = false
        secLineView.isHidden = false
        dayLabel.isHidden = false
        hourLabel.isHidden = false
        minLabel.isHidden = false
        secLabel.isHidden = false
        dayValueLabel.isHidden = false
        hourValueLabel.isHidden = false
        secValueLabel.isHidden = false
        minValueLabel.isHidden = false
    }
    
    func setImageForDays(days: String, imageName: String) {
        freeModeDayImageView.image = UIImage(named: "\(imageName)\(days)") 
        freeModeMinImageView.image = UIImage(named: "\(imageName)\(days)")
        freeModeSecImageView.image = UIImage(named: "\(imageName)\(days)")
        freeModeHourImageView.image = UIImage(named: "\(imageName)\(days)")
    }
    
    func setUpLineIndicatorForSignupDay(lineColor: UIColor) {
        hourLineView.backgroundColor = lineColor
        minLineView.backgroundColor = lineColor
        secLineView.backgroundColor = lineColor
        dayLineView.backgroundColor = lineColor
    }
    
    func setUpTimerViewForZeroDaySubscription(subscriptionType: String) {
      //  Upgrade from <current subscriber level> to Premium before your 7-day premium free trial ends to continue using premium features!
        if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
            subscriptionDetailLabel.text = "Upgrading your subscription to Advanced or Premium will be available in the next release. You'll be notified when upgrading your channel is ready."//"Upgrade from BASIC to Premium before your 7-day premium free trial ends to continue using premium features!"
            badgeImageView.image = UIImage(named: "badgeIphoneBasic")
            badgeImageView.isHidden = false
            timeStackViewHeight.constant = 72
        } else if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
            subscriptionDetailLabel.text = "Upgrading your subscription to Premium will be available in the next release. You'll be notified when upgrading your channel is ready."//"Upgrade from ADVANCE to Premium before your 7-day premium free trial ends to continue using premium features!"
            badgeImageView.image = UIImage(named: "badgeIphoneAdvance")
            badgeImageView.isHidden = false
            timeStackViewHeight.constant = 72
        } else if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue || subscriptionType == "premium" {
            subscriptionDetailLabel.isHidden = false
            badgeImageView.image = UIImage(named: "badgeIphonePre")
            badgeImageView.isHidden = false
            timeStackViewHeight.constant = 72
            
            let tipOftheDayAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]
            let tipTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]
            let tipOftheDay = NSMutableAttributedString(string: "Tip of the Day\n", attributes: tipOftheDayAttributes)
            let tipText = NSMutableAttributedString(string: "Use TextShare as the fastest way to share the QuickCam opportunity and grow your potential income.", attributes: tipTextAttributes)
            tipOftheDay.append(tipText)
            subscriptionDetailLabel.text = ""
        }
    }
    
    func subscribersHideTimer(subscriptionType: String) {
        timerStackView.isHidden = true
        timeStackViewHeight.constant = 0
        setUpTimerViewForZeroDaySubscription(subscriptionType: subscriptionType)
    }

    
}

extension WelcomeViewController {
    
    func setTimerText(subscriptionStatus: String) {
        timerLeftLabel.isHidden = false
        if subscriptionStatus == SubscriptionTypeForBadge.TRIAL.rawValue {
            timerLeftLabel.text = "Time left in premium free trial"
        } else if subscriptionStatus == SubscriptionTypeForBadge.FREE.rawValue {
            timerLeftLabel.text = "Time since signed up"
        } else if  subscriptionStatus == SubscriptionTypeForBadge.FREE.rawValue {
            timerLeftLabel.text = "Time since your subscription expired"
        } else {
            timerLeftLabel.isHidden = true
        }
    }
    
    func getDays() {
        timerStackView.isHidden = true
        timeStackViewHeight.constant = 0
        freeModeDayImageView.isHidden = true
        freeModeMinImageView.isHidden = true
        freeModeSecImageView.isHidden = true
        freeModeHourImageView.isHidden = true
        
       // checkNewTrailPeriodExpire()
        var diffDays = 0
        let subscriptionType = Defaults.shared.currentUser!.subscriptionStatus!
        if let timerStartDate = Defaults.shared.currentUser?.trialSubscriptionStartDateIOS?.isoDateFromString() {
            var timerDate = timerStartDate
            var dateComponent = DateComponents()
            if subscriptionType == "trial" {
                dateComponent.day = 8
            }
            if subscriptionType == "expired" {
                if let timerExpireDate = Defaults.shared.currentUser?.subscriptionEndDate?.isoDateFromString() {
                    timerDate = timerExpireDate
                }
            }
            
            if let futureDate = Calendar.current.date(byAdding: dateComponent, to: timerDate) {
                diffDays = futureDate.days(from: Date())
                
                if subscriptionType == "expired" || subscriptionType == "free" {
                    showUpTimer(timerDate: timerDate)
                } else {
                    showNewTimer(createdDate: timerDate, subscriptionType: subscriptionType)
                }
                setTimerText(subscriptionStatus: subscriptionType)
                self.showWelcomeData(subscriptionType: subscriptionType, daysLeft: diffDays)
                self.subscriptionDetailLabel.text = self.showMessageData(subscriptionType: subscriptionType, daysLeft: diffDays)
            }
        } else {
            
        }
    }
    
    func checkNewTrailPeriodExpire() {
        if let timerDate = Defaults.shared.currentUser?.trialSubscriptionStartDateIOS?.isoDateFromString() {
            var dateComponent = DateComponents()
            dateComponent.day = 7
            if let futureDate = Calendar.current.date(byAdding: dateComponent, to: timerDate) {
                let trailDate = futureDate.timeIntervalSince(Date())
                self.isTrialExpire = trailDate.sign == .minus ? true : false
            }
        }
    }
    
    
    func showUpTimer(timerDate: Date) {
        countdownTimer?.invalidate()
        self.countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            let countdown = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: timerDate, to: Date())
            let days = countdown.day!
            let hours = countdown.hour!
            let minutes = countdown.minute!
            let seconds = countdown.second!
            self.secValueLabel.text = String(format: "%02d", seconds)
            self.minValueLabel.text = String(format: "%02d", minutes)
            self.hourValueLabel.text = String(format: "%02d", hours)
            self.dayValueLabel.text = String(format: "%01d", days)
        }
    }
    
    func showNewTimer(createdDate: Date, subscriptionType: String) {
        countdownTimer?.invalidate()
        timerStackView.isHidden = false
        timeStackViewHeight.constant = 72
        var dateComponent = DateComponents()
        dateComponent.day = 7
        if let futureDate = Calendar.current.date(byAdding: dateComponent, to: createdDate) {
            self.countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                let countdown = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: futureDate)
                let days = countdown.day!
                let hours = countdown.hour!
                let minutes = countdown.minute!
                let seconds = countdown.second!
                self.secValueLabel.text = String(format: "%02d", seconds)
                self.minValueLabel.text = String(format: "%02d", minutes)
                self.hourValueLabel.text = String(format: "%02d", hours)
                self.dayValueLabel.text = String(format: "%01d", days)
            }
        }
    }
    
    func showWelcomeData(subscriptionType: String, daysLeft: Int) {
        if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
            var originalSubscriptionType = subscriptionType
            if let paidSubscriptionStatus = Defaults.shared.currentUser!.paidSubscriptionStatus {
                originalSubscriptionType = paidSubscriptionStatus
            }
            badgeImageView.isHidden = true
            if daysLeft == 7 {
                subscriptionDetailLabel.text = "Your 7-Day Premium Free Trial has started. You have 7 days to access all the QuickCam premium features for free while learning how to create fun and engaging content and/or make money sharing QuickCam."
                self.setuptimerViewBaseOnDayLeft(days: "\(daysLeft)", subscriptionType: originalSubscriptionType)
            } else if daysLeft == 0 || daysLeft < 0 {
                subscriptionDetailLabel.text = "Your 7-Day Premium Free Trial has ended. Please upgrade your subscription to resume using the Premium features."
                self.setuptimerViewBaseOnDayLeft(days: "0", subscriptionType: originalSubscriptionType)
            } else if daysLeft == 1 {
                subscriptionDetailLabel.text = "Today is the last day of your 7-Day Premium Free Trial"
                self.setuptimerViewBaseOnDayLeft(days: "1", subscriptionType: originalSubscriptionType)
            } else {
                self.setuptimerViewBaseOnDayLeft(days: "\(daysLeft)", subscriptionType: originalSubscriptionType)
                subscriptionDetailLabel.text = "You have \(daysLeft) days left on your free trial. Subscribe now and earn your subscription badge."
            }
        } else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
            subscriptionDetailLabel.text = "Your 7-Day Premium Free Trial has ended. Please upgrade your subscription to resume using the Premium features."
            self.setuptimerViewBaseOnDayLeft(days: "0", subscriptionType: subscriptionType)
            badgeImageView.isHidden = true
        } else if subscriptionType == "expired" {
            self.setuptimerViewBaseOnDayLeft(days: "0", subscriptionType: subscriptionType)
            subscriptionDetailLabel.text = "Your subscription has ended. Please upgrade your account now to resume using the basic, advanced or premium features."
            badgeImageView.isHidden = true
        } else if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
            self.setuptimerViewBaseOnDayLeft(days: "\(daysLeft)", subscriptionType: subscriptionType)
            if daysLeft == 7 {
                subscriptionDetailLabel.text = "Your 7-Day Premium Free Trial has started. You have 7 days to access all the QuickCam premium features for free while learning how to create fun and engaging content and/or make money sharing QuickCam."
            } else if daysLeft == 0 || daysLeft < 0 {
                
            } else if daysLeft == 1 {
                subscriptionDetailLabel.text = "Today is the last day of your 7-Day Premium Free Trial"
            } else {
                subscriptionDetailLabel.text = "You have \(daysLeft) days left on your free trial. Subscribe now and earn your subscription badge."
            }
            self.subscribersHideTimer(subscriptionType: subscriptionType)
        } else if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
            self.setuptimerViewBaseOnDayLeft(days: "\(daysLeft)", subscriptionType: subscriptionType)
            if daysLeft == 7 {
                subscriptionDetailLabel.text = "Your 7-Day Premium Free Trial has started. You have 7 days to access all the QuickCam premium features for free while learning how to create fun and engaging content and/or make money sharing QuickCam."
            } else if daysLeft == 0 || daysLeft < 0 {
                
            } else if daysLeft == 1 {
                subscriptionDetailLabel.text = "Today is the last day of your 7-Day Premium Free Trial"
            } else {
                subscriptionDetailLabel.text = "You have \(daysLeft) days left on your free trial. Subscribe now and earn your subscription badge."
            }
            self.subscribersHideTimer(subscriptionType: subscriptionType)
        } else if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue || subscriptionType == "premium" {
            self.setuptimerViewBaseOnDayLeft(days: "\(daysLeft)", subscriptionType: subscriptionType)
            if daysLeft == 7 {
                subscriptionDetailLabel.text = "Your 7-Day Premium Free Trial has started. You have 7 days to access all the QuickCam premium features for free while learning how to create fun and engaging content and/or make money sharing QuickCam."
            } else if daysLeft == 0 || daysLeft < 0 {
                
            } else if daysLeft == 1 {
                subscriptionDetailLabel.text = "Today is the last day of your 7-Day Premium Free Trial"
            } else {
                subscriptionDetailLabel.text = "You have \(daysLeft) days left on your free trial. Subscribe now and earn your subscription badge."
            }
            self.subscribersHideTimer(subscriptionType: subscriptionType)
        }
    }
    
}

extension WelcomeViewController {
    
    func setUpSubscriptionBadges() {
        dayBadgeImageView.isHidden = true
        preLaunchBadgeImageView.isHidden = true
        socialBadgeImageView.isHidden = true
        foundingMemberBadgeImageView.isHidden = true
        iosBadgeView.isHidden = true
        androidBadgeView.isHidden = true
        webBadgeView.isHidden = true
        
        if let badgearray = Defaults.shared.currentUser?.badges {
            for parentbadge in badgearray {
                let badgeCode = parentbadge.badge?.code ?? ""
                print("badgeCode:\(badgeCode)")
                let freeTrialDay = parentbadge.meta?.freeTrialDay ?? 0
                let subscriptionType = parentbadge.meta?.subscriptionType ?? ""
                let finalDay = Defaults.shared.getCountFromBadge(parentbadge: parentbadge)
                iosIconImageview.isHidden = true
                androidIconImageview.isHidden = true
                webIconImageview.isHidden = true
                switch badgeCode {
                case Badges.PRELAUNCH.rawValue:
                    preLaunchBadgeImageView.isHidden = false
                    preLaunchBadgeImageView.image = UIImage(named: "prelaunchBadge")
                case Badges.FOUNDING_MEMBER.rawValue:
                    foundingMemberBadgeImageView.isHidden = false
                    foundingMemberBadgeImageView.image = UIImage(named: "foundingMemberBadge")
                case Badges.SOCIAL_MEDIA_CONNECTION.rawValue:
                    socialBadgeImageView.isHidden = false
                    socialBadgeImageView.image = UIImage(named: "socialBadge")
                default:
                    break
                }
                // Setup For iOS Badge
                if badgeCode == Badges.SUBSCRIBER_IOS.rawValue
                {
                    var hideDayBadge = false
                    if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                        iosBadgeView.isHidden = false
                        iosRemainingDaysLabel.text = finalDay
                        iosShieldImageview.image = R.image.badgeIphoneTrial()
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
                        iosBadgeView.isHidden = false
                       /* if freeTrialDay > 0 {
                            lbliosDaysRemains.text = finalDay
                            iosSheildImageview.image = R.image.freeBadge()
                        } else {*/
                            //iOS shield hide
                            //square badge show
                            iosRemainingDaysLabel.text = ""
                            iosShieldImageview.image = R.image.badgeIphoneFree()
//                        }
                        hideDayBadge = true
                    }
                    
                    if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
                        iosBadgeView.isHidden = false
                        iosRemainingDaysLabel.text = finalDay
                        iosShieldImageview.image = R.image.badgeIphoneBasic()
                    }
                    if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
                        iosBadgeView.isHidden = false
                        iosRemainingDaysLabel.text = finalDay
                        iosShieldImageview.image = R.image.badgeIphoneAdvance()
                    }
                    if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue {
                        iosBadgeView.isHidden = false
                        iosRemainingDaysLabel.text = finalDay
                        iosShieldImageview.image = R.image.badgeIphonePre()
                    }
                    dayBadgeImageView.isHidden = hideDayBadge
                    dayBadgeImageView.image = UIImage(named: "day_badge_\(finalDay)")
                }
                // Setup For Android Badge
                if badgeCode == Badges.SUBSCRIBER_ANDROID.rawValue
                {
                    if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                        androidBadgeView.isHidden = false
                        androidRemainingDaysLabel.text = finalDay
                        androidShieldImageview.image = R.image.badgeAndroidTrial()
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
                        androidBadgeView.isHidden = false
                        if freeTrialDay > 0 {
                            androidRemainingDaysLabel.text = finalDay
                            androidShieldImageview.image = R.image.badgeAndroidTrial()
                        } else {
                            androidRemainingDaysLabel.text = ""
                            androidShieldImageview.image = R.image.badgeAndroidFree()
                        }
                    }
                    if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
                        androidBadgeView.isHidden = false
                        androidRemainingDaysLabel.text = finalDay
                        androidShieldImageview.image = R.image.badgeAndroidBasic()
                    }
                    if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
                        androidBadgeView.isHidden = false
                        androidRemainingDaysLabel.text = finalDay
                        androidShieldImageview.image = R.image.badgeAndroidAdvance()
                    }
                    if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue {
                        androidBadgeView.isHidden = false
                        androidRemainingDaysLabel.text = finalDay
                        androidShieldImageview.image = R.image.badgeAndroidPre()
                    }
                }
                
                if badgeCode == Badges.SUBSCRIBER_WEB.rawValue
                {
                    if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                        webBadgeView.isHidden = false
                        webRemainingDaysLabel.text = finalDay
                        webShieldImageview.image = R.image.badgeWebTrial()
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
                        webBadgeView.isHidden = false
                        if freeTrialDay > 0 {
                            webRemainingDaysLabel.text = finalDay
                            webShieldImageview.image = R.image.badgeWebTrial()
                        } else {
                            webRemainingDaysLabel.text = ""
                            webShieldImageview.image = R.image.badgeWebFree()
                        }
                    }
                    
                    if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
                        webBadgeView.isHidden = false
                        webRemainingDaysLabel.text = finalDay
                        webShieldImageview.image = R.image.badgeWebBasic()
                    }
                    if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
                        webBadgeView.isHidden = false
                        webRemainingDaysLabel.text = finalDay
                        webShieldImageview.image = R.image.badgeWebAdvance()
                    }
                    if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue {
                        webBadgeView.isHidden = false
                        webRemainingDaysLabel.text = finalDay
                        webShieldImageview.image = R.image.badgeWebPre()
                    }
                }
            }
        }
    }
    
    func showMessageData(subscriptionType: String, daysLeft: Int) -> String {
        if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
            
            var originalSubscriptionType = subscriptionType
            if let paidSubscriptionStatus = Defaults.shared.currentUser!.paidSubscriptionStatus {
                originalSubscriptionType = paidSubscriptionStatus
            }
            
            if originalSubscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                // for TRIAL user use this
                if daysLeft == 7 {
                    return "Your 7-Day Premium Free Trial has started. You have 7 days to access all the QuickCam Premium features for free. \nUpgrade to Premium today and get your Premium Subscriber Badge and Day 1 Subscriber Badge!"
                } else if daysLeft == 6 {
                    return "You’re on Day 2 of your 7-Day Premium Free Trial. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 2 Subscriber Badge!"
                } else if daysLeft == 5 {
                    return "You’re on Day 3 of your 7-Day Premium Free Trial. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 3 Subscriber Badge!"
                } else if daysLeft == 4 {
                    return "You’re on Day 4 of your 7-Day Premium Free Trial. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 4 Subscriber Badge!"
                } else if daysLeft == 3 {
                    return "You’re on Day 5 of your 7-Day Premium Free Trial. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 5 Subscriber Badge!"
                } else if daysLeft == 2 {
                    return "You’re on Day 6 of your 7-Day Premium Free Trial. Don’t lose your Premium access after today. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 6 Subscriber Badge!"
                } else if daysLeft == 1 {
                    return "You’re on the last day of your 7-Day Premium Free Trial. Today is the last day you can access all the QuickCam Premium features for free and the last day to get the Day Subscriber Badge. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 7 Subscriber Badge!"
                } else {
                    return "Your 7-Day Premium Free Trial has ended. You can still use QuickCam with Free User access level and the Free User Badge. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 7 Subscriber Badge!"
                }
            }
            else {
                // purchase during trail use this.
                if originalSubscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
                    if daysLeft == 7 {
                        return "You’re on Day 1 of the 7-Day Premium Free Trial. As a Basic Subscriber, you’ll continue to have access to all the QuickCam Premium features for free during the 7 days before access drops to Basic subscription level. \nUpgrading to Advanced or Premium available soon."
                    } else if daysLeft == 6 {
                        return "You’re on Day 2 of your 7-Day Premium Free Trial. \nUpgrading to Advanced or Premium available soon."
                    } else if daysLeft == 5 {
                        return "You’re on Day 3 of your 7-Day Premium Free Trial. \nUpgrading to Advanced or Premium available soon."
                    } else if daysLeft == 4 {
                        return "You’re on Day 4 of your 7-Day Premium Free Trial. \nUpgrading to Advanced or Premium available soon."
                    } else if daysLeft == 3 {
                        return "You’re on Day 5 of your 7-Day Premium Free Trial. \nUpgrading to Advanced or Premium available soon."
                    } else if daysLeft == 2 {
                        return "You’re on Day 6 of your 7-Day Premium Free Trial. \nUpgrading to Advanced or Premium available soon."
                    } else if daysLeft == 1 {
                        return "You’re on the last day of your 7-Day Premium Free Trial. As a Basic Subscriber, today is the last day you can access all the QuickCam Premium features for free. \nUpgrading to Advanced or Premium available soon."
                    } else {
                        return "Your 7-Day Premium Free Trial has ended. Your access level is now Basic. \nUpgrade to Advanced or Premium available soon!"
                    }
                }
                else if originalSubscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
                    if daysLeft == 7 {
                        return "You’re on Day 1 of the 7-Day Premium Free Trial. As an Advanced Subscriber,you’ll continue to have access to all the QuickCam Premium features for free during the 7 days before access drops to Advanced subscription level. \nUpgrading to Premium available soon."
                    } else if daysLeft == 6 {
                        return "You’re on Day 2 of your 7-Day Premium Free Trial. \nUpgrading to Premium available soon."
                    } else if daysLeft == 5 {
                        return "You’re on Day 3 of your 7-Day Premium Free Trial. \nUpgrading to Premium available soon."
                    } else if daysLeft == 4 {
                        return "You’re on Day 4 of your 7-Day Premium Free Trial. \nUpgrading to Premium available soon."
                    } else if daysLeft == 3 {
                        return "You’re on Day 5 of your 7-Day Premium Free Trial. \nUpgrade to Premium now, get the Premium Subscriber Badge and continue using all of the Premium features after the free trial."
                    } else if daysLeft == 2 {
                        return "You’re on Day 6 of your 7-Day Premium Free Trial. \nUpgrade to Premium now, get the Premium Subscriber Badge and continue using all of the Premium features after the free trial."
                    } else if daysLeft == 1 {
                        return "You’re on the last day of your 7-Day Premium Free Trial. As an Advanced Subscriber, today is the last day you can access all the QuickCam Premium features for free. \nUpgrading to Premium available soon."
                    } else {
                        return "Your 7-Day Premium Free Trial has ended. Your access level is now Advanced. \nUpgrading to Premium available soon."
                    }
                }
                else if originalSubscriptionType == SubscriptionTypeForBadge.PRO.rawValue || originalSubscriptionType.lowercased() == SubscriptionTypeForBadge.PREMIUM.rawValue {
                    if daysLeft == 7 {
                        return "You’re on Day 1 of your first week as a Premium subscriber. \nAs a Premium Subscriber, you can access all the QuickCam Premium features and learn how to create fun and engaging content, and how to make money sharing QuickCam."
                    } else if daysLeft == 6 {
                        return "You’re on Day 2 of your first week as a Premium subscriber. \nStart creating fun and engaging content and sharing QuickCam to your contacts."
                    } else if daysLeft == 5 {
                        return "You’re on Day 3 of your 7-Day Premium Free Trial. \nUse the unique fast & slow motion special effects to create fun and engaging videos. Share QuickCam to your family, friends & contacts and followers on social media."
                    } else if daysLeft == 4 {
                        return "You’re on Day 4 of your 7-Day Premium Free Trial. \nMake money by inviting your family, friends & contacts. When they subscribe, you make money!"
                    } else if daysLeft == 3 {
                        return "You’re on Day 5 of your 7-Day Premium Free Trial. \nMake money by inviting your family, friends & contacts. When they subscribe, you make money!"
                    } else if daysLeft == 2 {
                        return "You’re on Day 6 of your 7-Day Premium Free Trial. \nMake money by inviting your family, friends & contacts. When they subscribe, you make money!"
                    } else if daysLeft == 1 {
                        return "You’re on the last day of your 7-Day Premium Free Trial. \nAs an Premium Subscriber, your Premium access will continue uninterrupted."
                    } else {
                        return "Your 7-Day Premium Free Trial has ended. \nYour Premium subscription ensures you have continuous Premium level access."
                    }
                }
            }
        }
        else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
            return "Your 7-Day Premium Free Trial has ended. You can still use QuickCam with Free User access level and the Free User Badge. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 7 Subscriber Badge!"
        }
        else if subscriptionType == "expired" {
            return "Your subscription has ended. Please upgrade now to resume using the Basic, Advanced or Premium subscription features."
        }
        else if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
            return ""
        }
        else if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
            return ""
        }
        else if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue || subscriptionType.lowercased() == "premium" {
            return ""
        }
        return ""
    }
}

// MARK: - SharingSocialTypeDelegate
extension WelcomeViewController: SharingSocialTypeDelegate {
    
    func setSocialPlatforms() {
        self.profilePicHelper?.settingSocialPlatforms()
    }
    
    func setCroppedImage(croppedImg: UIImage) {
        self.profilePicHelper?.settingSocialPlatforms()
        self.croppedImg = croppedImg
        self.saveProfilePic()
    }
    
    func shareSocialType(socialType: ProfileSocialShare) {
        self.profilePicHelper = ProfilePicHelper(parentVC: self, navVC: self.navigationController ?? UINavigationController())
        self.profilePicHelper?.openSheet(socialType: socialType)
    }
    
}

// MARK: - Camera and Photo gallery methods
extension WelcomeViewController {
    
    /// Delete Image
    private func deleteImage() {
        self.userImageView.image = UIImage()
    }
    
    func openSocialShareVC() {
        if let editProfileSocialShareVC = R.storyboard.editProfileViewController.editProfileSocialShareViewController() {
            editProfileSocialShareVC.modalPresentationStyle = .overFullScreen
            editProfileSocialShareVC.delegate = self
            navigationController?.present(editProfileSocialShareVC, animated: true, completion: {
                editProfileSocialShareVC.backgroundUpperView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backgroundTapped)))
            })
        }
    }
    
    @objc func backgroundTapped() {
        self.dismiss(animated: true)
    }
}

// MARK: - API methods
extension WelcomeViewController {
    func saveProfilePic() {
        self.showHUD()
//        if let img = self.userImageView.image {
            self.updateProfilePic(image: self.croppedImg!)
            self.updateProfileDetails(image: self.croppedImg!)
//        }
    }
    
    func updateProfilePic(image: UIImage) {
        ProManagerApi.uploadPicture(image: image, imageSource: imageSource).request(Result<EmptyModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            
            self.storyCameraVC.syncUserModel { (isComplete) in
                self.view.makeToast("Your changes are saved.")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.updateUserProfilePic()
                    // Do whatever you want
//                    self.setRedirection()
                }
            }
        }, onError: { error in
            self.dismissHUD()
            self.view.isUserInteractionEnabled = true
        }, onCompleted: {
            self.dismissHUD()
        }).disposed(by: self.rx.disposeBag)
    }
    
    func updateProfileDetails(image: UIImage) {
        ProManagerApi.updateProfileDetails(image: image, imageSource: imageSource).request(Result<EmptyModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            self.dismissHUD()
          
        }, onError: { error in
            self.dismissHUD()
            self.view.isUserInteractionEnabled = true
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
}

