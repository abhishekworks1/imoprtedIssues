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
    
    @IBOutlet weak var timeStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var semiHalfView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var foundingMemberImageView: UIImageView!
    @IBOutlet weak var badgeImageView: UIImageView!
    
    @IBOutlet weak var profileWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var profileHeightConstraints: NSLayoutConstraint!
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
    
    private var countdownTimer: Timer?
    var isTrialExpire = false
    var fromLogin = false
    let lastWelcomeTimerAlertDateKey = "lastWelcomeTimerAlertDate"
    var isWhatDoYouWantSeeViewChecked = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tipOfTheDayLabel.text = Defaults.shared.tipOfDay
        UserSync.shared.getTipOfDay { tip in
            self.tipOfTheDayLabel.text = Defaults.shared.tipOfDay
        }
        selectFeatureDetailSwitch.setOn(Defaults.shared.shouldDisplayDetailsOfWelcomeScreenFeatures, animated: false)
        selectFeatureChanged(selectFeatureDetailSwitch)
//        self.whatDoYouWantSeeView.isHidden = !Defaults.shared.shouldDisplayQuickStartFirstOptionSelection
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.dropShadowNew()
        
        // Shadow Color and Radius
        /*let isFoundingMember = Defaults.shared.currentUser?.badges?.filter({ return $0.badge?.code == "founding-member" }).count ?? 0 > 0
        semiHalfView.layer.shadowColor = isFoundingMember ? UIColor.lightGray.cgColor : UIColor.white.cgColor
        semiHalfView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        semiHalfView.layer.shadowOpacity = 0.7
        semiHalfView.layer.shadowRadius = 0
        semiHalfView.layer.masksToBounds = false
        semiHalfView.layer.cornerRadius = 81.5*/
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        countdownTimer?.invalidate()
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
        switch sender.tag {
        case 0:
            Defaults.shared.isSignupLoginFlow = true
            let rootViewController: UIViewController? = R.storyboard.pageViewController.pageViewController()
            Utils.appDelegate?.window?.rootViewController = rootViewController
            break
        case 1:
            whatToSeeFirstBaseView.isHidden = false
        case 2:
//            let rootViewController: UIViewController? = R.storyboard.pageViewController.pageViewController()
//            if let pageViewController = rootViewController as? PageViewController,
//               let navigationController = pageViewController.pageControllers.first as? UINavigationController,
//               let settingVC = R.storyboard.storyCameraViewController.storySettingsVC() {
//                navigationController.viewControllers.append(settingVC)
//            }
//            Utils.appDelegate?.window?.rootViewController = rootViewController
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
//        guard let subscriptionVc = R.storyboard.subscription.subscriptionsViewController() else { return }
//        subscriptionVc.appMode = .professional
//        subscriptionVc.subscriptionType = .professional
//        subscriptionVc.isFromWelcomeScreen = true
//        self.navigationController?.isNavigationBarHidden = true
//        navigationController?.pushViewController(subscriptionVc, animated: true)
        
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
        Defaults.shared.shouldDisplayQuickStartFirstOptionSelection = !isWhatDoYouWantSeeViewChecked
        Defaults.shared.selectedQuickStartOption = .makeMoney
        UserSync.shared.setOnboardingUserFlags()
        openOnboarding()
    }
    
    @IBAction func createContentOptionClicked(_ sender: Any) {
        Defaults.shared.shouldDisplayQuickStartFirstOptionSelection = !isWhatDoYouWantSeeViewChecked
        Defaults.shared.selectedQuickStartOption = .createContent
        UserSync.shared.setOnboardingUserFlags()
        openOnboarding()
    }
}

extension WelcomeViewController {
    func setupView() {
        if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
            self.userImageView.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: R.image.user_placeholder())
        }
        
        self.displayNameLabel.text = Defaults.shared.publicDisplayName
        self.checkTrailPeriodExpire()
      //  self.setSubscriptionBadgeDetails()
        self.getDays()
        UserSync.shared.syncUserModel { isCompleted in
            self.tipOfTheDayView.isHidden = !Defaults.shared.shouldDisplayTipOffDay
            UserSync.shared.getOnboardingUserFlags { isCompleted in
//                self.whatDoYouWantSeeView.isHidden = !Defaults.shared.shouldDisplayQuickStartFirstOptionSelection
                self.tipOfTheDayView.isHidden = !Defaults.shared.shouldDisplayTipOffDay
                Defaults.shared.shouldDisplayTipOffDay = true
                UserSync.shared.setOnboardingUserFlags()
            }
            if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
                self.userImageView.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: R.image.user_placeholder())
            }
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
        //    self.setSubscriptionBadgeDetails()
//            self.checkIfWelcomeTimerAlertShownToday()
            self.showWelcomeTimerAlert()
            self.getDays()
        }
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
            guard let subscriptionVc = R.storyboard.subscription.subscriptionsViewController() else { return }
            subscriptionVc.appMode = .professional
            subscriptionVc.subscriptionType = .professional
            subscriptionVc.isFromWelcomeScreen = true
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.pushViewController(subscriptionVc, animated: true)
        }
        self.present(vc, animated: true, completion: nil)
        
    }
}

extension WelcomeViewController {
    
    func showTimer(createdDate: Date) {
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
                        subscriptionDetailLabel.text = "Your subscription has  ended. Please upgrade your account now to resume using the basic, advanced or premium features."
                        self.upgradeNowButton.setTitle("Upgrade To Premium", for: .normal)
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
                                self.upgradeNowButton.setTitle("Upgrade To Premium", for: .normal)
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
        self.upgradeNowButton.isHidden = false
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
            self.upgradeNowButton.setTitle("Upgrade To Premium", for: .normal)
            
            if (days == "7") {
                setUpTimerViewForSignupDay()
            } else {
                setImageForDays(days: days, imageName: "basicOnboard")
                setUpTimerViewForOtherDay()
            }
            
        } else if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
            setUpLineIndicatorForSignupDay(lineColor: UIColor(red: 0.212, green: 0.718, blue: 1, alpha: 1))
            self.upgradeNowButton.setTitle("Upgrade To Premium", for: .normal)
            
            if (days == "7") {
                setUpTimerViewForSignupDay()
            } else {
                setImageForDays(days: days, imageName: "advanceOnboard")
                setUpTimerViewForOtherDay()
            }
        } else if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue || subscriptionType == SubscriptionTypeForBadge.PREMIUM.rawValue {
            setUpLineIndicatorForSignupDay(lineColor: UIColor(red: 0.38, green: 0, blue: 1, alpha: 1))
            self.upgradeNowButton.isHidden = true
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
            self.upgradeNowButton.isHidden = true
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
        self.upgradeNowButton.isHidden = true
        setUpTimerViewForZeroDaySubscription(subscriptionType: subscriptionType)
    }

    
}

extension WelcomeViewController {
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
    func showMessageData(subscriptionType: String, daysLeft: Int) -> String {
        if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
            
            var originalSubscriptionType = subscriptionType
            if let paidSubscriptionStatus = Defaults.shared.currentUser!.paidSubscriptionStatus {
                originalSubscriptionType = paidSubscriptionStatus
            }
            
            if originalSubscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                // for TRIAL user use this
                if daysLeft == 7 {
                    return "Your 7-Day Premium Free Trial has started. You have 7 days to access all the QuickCam Premium features for free. Learn how to create fun and engaging content, and how to make money sharing QuickCam. Upgrade now to Premium and get your Premium Subscriber Badge and Day 1 Subscriber Badge!"
                } else if daysLeft == 6 {
                    return "You’re on Day 2 of your 7-Day Premium Free Trial. You have 6 more days to access all the QuickCam Premium features for free. Start creating fun and engaging content and sharing QuickCam to your contacts. Upgrade now to Premium and get your Premium Subscriber Badge and Day 2 Subscriber Badge!"
                } else if daysLeft == 5 {
                    return "You’re on Day 3 of your 7-Day Premium Free Trial. You have 5 more days to access all the QuickCam Premium features for free. Use the unique fast & slow motion special effects to create fun and engaging videos. Share QuickCam to your family, friends and followers on social media. Upgrade now to Premium and get your Premium Subscriber Badge and Day 3 Subscriber Badge!"
                } else if daysLeft == 4 {
                    return "You’re on Day 4 of your 7-Day Premium Free Trial. You have 4 more days to access all the QuickCam Premium features for free. Make money by inviting your family, friends. When they subscribe, you make money! Upgrade now to Premium and get your Premium Subscriber Badge and Day 4 Subscriber Badge!"
                } else if daysLeft == 3 {
                    return "You’re on Day 5 of your 7-Day Premium Free Trial. You have 3 more days to access all the QuickCam Premium features for free. Make money by inviting your family, friends. When they subscribe, you make money! Upgrade now to Premium and get your Premium Subscriber Badge and Day 5 Subscriber Badge!"
                } else if daysLeft == 2 {
                    return "You’re on Day 6 of your 7-Day Premium Free Trial. You have 2 more days to access all the QuickCam Premium features for free. Make money by inviting your family, friends. When they subscribe, you make money! Upgrade now to Premium and get your Premium Subscriber Badge and Day 6 Subscriber Badge!"
                } else if daysLeft == 1 {
                    return "You’re on the last day of your 7-Day Premium Free Trial. Today is the last day you can access all the QuickCam Premium features for free and the last day to get the Day Subscriber Badge. Upgrade now to Premium and get your Premium Subscriber Badge and Day 7 Subscriber Badge!"
                } else {
                    return "Your 7-Day Premium Free Trial has ended. You can still use QuickCam with Free User access level and the Free User Badge."
                }
            }
            else {
                // purchase during trail use this.
                if originalSubscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
                    if daysLeft == 7 {
                        return "You’re on Day 1 of the 7-Day Premium Free Trial. As a Basic Subscriber, you have 7 days to access all the QuickCam Premium features for free. Learn how to create fun and engaging content, and how to make money sharing QuickCam. Upgrading to Advanced or Premium available soon."
                    } else if daysLeft == 6 {
                        return "You’re on Day 2 of your 7-Day Premium Free Trial. As a Basic Subscriber, you have 6 more days to access all the QuickCam Premium features for free. Start creating fun and engaging content and sharing QuickCam to your contacts. Upgrading to Advanced or Premium available soon."
                    } else if daysLeft == 5 {
                        return "You’re on Day 3 of your 7-Day Premium Free Trial. As a Basic Subscriber, you have 5 more days to access all the QuickCam Premium features for free. Use the unique fast & slow motion special effects to create fun and engaging videos. Share QuickCam to your family, friends and followers on social media. Upgrading to Advanced or Premium available soon."
                    } else if daysLeft == 4 {
                        return "You’re on Day 4 of your 7-Day Premium Free Trial. As a Basic Subscriber, you have 4 more days to access all the QuickCam Premium features for free. Make money by inviting your family, friends. When they subscribe, you make money! Upgrading to Advanced or Premium available soon."
                    } else if daysLeft == 3 {
                        return "You’re on Day 5 of your 7-Day Premium Free Trial. As a Basic Subscriber, you have 3 more days to access all the QuickCam Premium features for free. Make money by inviting your family, friends. When they subscribe, you make money! Upgrading to Advanced or Premium available soon."
                    } else if daysLeft == 2 {
                        return "You’re on Day 6 of your 7-Day Premium Free Trial. As a Basic Subscriber, you have 2 more days to access all the QuickCam Premium features for free. Make money by inviting your family, friends. When they subscribe, you make money! Upgrading to Advanced or Premium available soon."
                    } else if daysLeft == 1 {
                        return "You’re on the last day of your 7-Day Premium Free Trial. As a Basic Subscriber, today is the last day you can access all the QuickCam Premium features for free. Upgrading to Advanced or Premium available soon."
                    } else {
                        return "Your 7-Day Premium Free Trial has ended. Your access level is now Basic. Upgrade to Advanced or Premium available soon"
                    }
                }
                else if originalSubscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
                    if daysLeft == 7 {
                        return "You’re on Day 1 of the 7-Day Premium Free Trial. As an Advanced Subscriber, you have 7 days to access all the QuickCam Premium features for free. Learn how to create fun and engaging content, and how to make money sharing QuickCam. Upgrading to Premium available soon."
                    } else if daysLeft == 6 {
                        return "You’re on Day 2 of your 7-Day Premium Free Trial. As an Advanced Subscriber, you have 6 more days to access all the QuickCam Premium features for free. Start creating fun and engaging content and sharing QuickCam to your contacts. Upgrading to Premium available soon."
                    } else if daysLeft == 5 {
                        return "You’re on Day 3 of your 7-Day Premium Free Trial. As an Advanced Subscriber, you have 5 more days to access all the QuickCam Premium features for free. Use the unique fast & slow motion special effects to create fun and engaging videos. Share QuickCam to your family, friends and followers on social media. Upgrading to Premium available soon."
                    } else if daysLeft == 4 {
                        return "You’re on Day 4 of your 7-Day Premium Free Trial. As an Advanced Subscriber, you have 4 more days to access all the QuickCam Premium features for free. Make money by inviting your family, friends. When they subscribe, you make money! Upgrading to Premium available soon."
                    } else if daysLeft == 3 {
                        return "You’re on Day 5 of your 7-Day Premium Free Trial. As an Advanced Subscriber, you have 3 more days to access all the QuickCam Premium features for free. Make money by inviting your family, friends. When they subscribe, you make money! Upgrading to Premium available soon."
                    } else if daysLeft == 2 {
                        return "You’re on Day 6 of your 7-Day Premium Free Trial. As an Advanced Subscriber, you have 2 more days to access all the QuickCam Premium features for free. Make money by inviting your family, friends. When they subscribe, you make money! Upgrading to Premium available soon."
                    } else if daysLeft == 1 {
                        return "You’re on the last day of your 7-Day Premium Free Trial. As an Advanced Subscriber, today is the last day you can access all the QuickCam Premium features for free. Upgrading to Premium available soon."
                    } else {
                        return "Your 7-Day Premium Free Trial has ended. Your access level is now Advanced. Upgrade to Premium available soon."
                    }
                }
                else if originalSubscriptionType == SubscriptionTypeForBadge.PRO.rawValue || originalSubscriptionType.lowercased() == "premium" {
                    if daysLeft == 7 {
                        return "As a Premium Subscriber, you can access all the QuickCam Premium features and learn how to create fun and engaging content, and how to make money sharing QuickCam."
                    } else if daysLeft == 6 {
                        return "You’re on Day 2 of your first week as a Premium subscriber. Start creating fun and engaging content and sharing QuickCam to your contacts."
                    } else if daysLeft == 5 {
                        return "You’re on Day 3 of your 7-Day Premium Free Trial. As an Premium Subscriber, your Premium access will continue uninterrupted after the free trial. Use the unique fast & slow motion special effects to create fun and engaging videos. Share QuickCam to your family, friends and followers on social media."
                    } else if daysLeft == 4 {
                        return "You’re on Day 4 of your 7-Day Premium Free Trial. As an Premium Subscriber, your Premium access will continue uninterrupted after the free trial. Make money by inviting your family, friends. When they subscribe, you make money!"
                    } else if daysLeft == 3 {
                        return "You’re on Day 5 of your 7-Day Premium Free Trial. As an Premium Subscriber, your Premium access will continue uninterrupted after the free trial. Make money by inviting your family, friends. When they subscribe, you make money!"
                    } else if daysLeft == 2 {
                        return "You’re on Day 6 of your 7-Day Premium Free Trial. As an Premium Subscriber, your Premium access will continue uninterrupted after the free trial. Make money by inviting your family, friends. When they subscribe, you make money!"
                    } else if daysLeft == 1 {
                        return "You’re on the last day of your 7-Day Premium Free Trial. As an Premium Subscriber, your Premium access will continue uninterrupted after the free trial."
                    } else {
                        return "Your 7-Day Premium Free Trial has ended. Your access level is now Advanced. Upgrade to Premium available soon."
                    }
                }
            }
        }
        else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
            return "Your 7-Day Premium Free Trial has ended. Your Premium subscription ensures you have continuous Premium level access."
        }
        else if subscriptionType == "expired" {
            return "Your subscription has ended. Please upgrade now to resume using the Basic, Advanced or Premium subscription features.\nTime since your subscription expired:"
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
