//
//  WelcomeViewController.swift
//  SocialCAM
//
//  Created by Satish Rajpurohit on 23/06/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var subscriptionDetailLabel: UILabel!
    @IBOutlet weak var timerStackView: UIStackView!
    @IBOutlet weak var dayValueLabel: UILabel!
    @IBOutlet weak var hourValueLabel: UILabel!
    @IBOutlet weak var minValueLabel: UILabel!
    @IBOutlet weak var secValueLabel: UILabel!
    @IBOutlet weak var freeImageView: UIImageView!
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
    
    private var countdownTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        countdownTimer?.invalidate()
    }
    
    @IBAction func upgradeNowOnClick(_ sender: Any) {
        if let subscriptionVC = R.storyboard.subscription.subscriptionContainerViewController() {
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.pushViewController(subscriptionVC, animated: true)
        }
    }
    
    @IBAction func continueOnClick(_ sender: Any) {
        guard let onBoardView = R.storyboard.onBoardingView.onBoardingViewController() else { return }
        (onBoardView.viewControllers.first as? OnBoardingViewController)?.showPopUpView = false
        Defaults.shared.onBoardingReferral = OnboardingReferral.QuickMenu.description
        Utils.appDelegate?.window?.rootViewController = onBoardView
    }
}

extension WelcomeViewController {
    func setupView() {
        UserSync.shared.syncUserModel { isCompleted in
            if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
                self.userImageView.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: R.image.user_placeholder())
            }
            
            self.displayNameLabel.text = Defaults.shared.currentUser?.firstName
            self.setSubscriptionBadgeDetails()
        }
    }
}

extension WelcomeViewController {
    
    func showTimer(createdDate: Date) {
        timerStackView.isHidden = false
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.day = 7
        if let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate) {
            self.countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                let countdown = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: futureDate)
                let days = countdown.day!
                let hours = countdown.hour!
                let minutes = countdown.minute!
                let seconds = countdown.second!
                self.secValueLabel.text = String(format: "%02ds", seconds)
                self.minValueLabel.text = String(format: "%02dm", minutes)
                self.hourValueLabel.text = String(format: "%02dh", hours)
                self.dayValueLabel.text = String(format: "%01dd", days)
            }
        }
    }
    
    func setSubscriptionBadgeDetails(){
        timerStackView.isHidden = true
        freeModeDayImageView.isHidden = true
        freeModeMinImageView.isHidden = true
        freeModeSecImageView.isHidden = true
        freeModeHourImageView.isHidden = true
        if let badgearray = Defaults.shared.currentUser?.badges {
            for parentbadge in badgearray {
                let badgeCode = parentbadge.badge?.code ?? ""

                if badgeCode == Badges.SUBSCRIBER_IOS.rawValue
                {
                    let subscriptionType = parentbadge.meta?.subscriptionType ?? ""
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
                           subscriptionDetailLabel.text = "Today is the last day of your 7-day free trial"
                           if let createdDate = parentbadge.createdAt?.isoDateFromString() {
                               showTimer(createdDate: createdDate)
                           }
                           self.setuptimerViewBaseOnDayLeft(days: "1", subscriptionType: subscriptionType)
                        } else {
                            self.setuptimerViewBaseOnDayLeft(days: "\(fday + 1)", subscriptionType: subscriptionType)
                            subscriptionDetailLabel.text = "You have \(fday) days left on your free trial."
                            if let createdDate = parentbadge.createdAt?.isoDateFromString() {
                                showTimer(createdDate: createdDate)
                            }
                        }
                        if fday == 0 {
                            self.setuptimerViewBaseOnDayLeft(days: "0", subscriptionType: subscriptionType)
                        }
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
                        self.setuptimerViewBaseOnDayLeft(days: "0", subscriptionType: subscriptionType)
                    } else {
                        subscriptionDetailLabel.text = "Enjoy your subscribe features"
                    }
                }
            }
        }
    }
    
}

extension WelcomeViewController {
    
    func setuptimerViewBaseOnDayLeft(days: String, subscriptionType: String) {
        if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
            if days == "0" {
                setImageForDays(days: days)
                subscriptionDetailLabel.text = "Your subscription ended, please upgrade your account for explore more features"
                setUpTimerViewForZeroDay()
            } else if (days == "7") {
                setUpTimerViewForSignupDay()
            }
            else {
                setImageForDays(days: days)
                setUpTimerViewForOtherDay()
            }
            
        } else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
            subscriptionDetailLabel.text = "Your subscription ended, please upgrade your account for explore more features"
            setImageForDays(days: days)
            setUpTimerViewForZeroDay()
        } else if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
            
        } else if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
            
        } else if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue {
            
        }
    }
    
    func setUpTimerViewForZeroDay() {
        timerStackView.isHidden = false
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
    
    func setUpTimerViewForSignupDay() {
        timerStackView.isHidden = false
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
    
    func setImageForDays(days: String) {
        freeModeDayImageView.image = UIImage(named: "freeOnboard\(days)")
        freeModeMinImageView.image = UIImage(named: "freeOnboard\(days)")
        freeModeSecImageView.image = UIImage(named: "freeOnboard\(days)")
        freeModeHourImageView.image = UIImage(named: "freeOnboard\(days)")
    }
}
