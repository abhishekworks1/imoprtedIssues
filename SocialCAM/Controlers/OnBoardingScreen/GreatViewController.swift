//
//  GreatViewController.swift
//  SocialCAM
//
//  Created by Satish Rajpurohit on 26/06/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

protocol GreatPopupDelegate {
    func greatPopupEvent(isUpgrade: Bool)
}

class GreatViewController: UIViewController {

    @IBOutlet weak var timerStackView: UIStackView!
    
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var secLabel: UILabel!
    
    @IBOutlet weak var dayLineView: UIView!
    @IBOutlet weak var hourLineView: UIView!
    @IBOutlet weak var minLineView: UIView!
    @IBOutlet weak var secLineView: UIView!
    
    @IBOutlet weak var freeModeDayImageView: UIImageView!
    @IBOutlet weak var freeModeHourImageView: UIImageView!
    @IBOutlet weak var freeModeMinImageView: UIImageView!
    @IBOutlet weak var freeModeSecImageView: UIImageView!
    
    @IBOutlet weak var dayValueLabel: UILabel!
    @IBOutlet weak var hourValueLabel: UILabel!
    @IBOutlet weak var minValueLabel: UILabel!
    @IBOutlet weak var secValueLabel: UILabel!
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var upgradeNowButton: UIButton!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var quickStartGuideLabel: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var foundingMemberImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var backToQuickStartButton: UIButton!
    @IBOutlet weak var userImageHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var userImageWidthConstraints: NSLayoutConstraint!
    var categoryString: String?
    
    private var countdownTimer: Timer?
    var greatViewDelegate: GreatPopupDelegate?
    var guidTimerDate: Date = Date()
    var isTrialExpire = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setup()
        self.setupUser()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        countdownTimer?.invalidate()
    }

    
    @IBAction func subscribeNowOnClick(_ sender: Any) {
        self.dismiss(animated: false)
        self.greatViewDelegate?.greatPopupEvent(isUpgrade: true)
    }
    
    
    @IBAction func backToQuickGuidOnClick(_ sender: Any) {
        self.dismiss(animated: false)
        self.greatViewDelegate?.greatPopupEvent(isUpgrade: false)
    }
    
    @IBAction func closePopupClick(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
}

extension GreatViewController {
    
    func setupUI() {
        self.centerView.layer.cornerRadius = 8.0
        self.upgradeNowButton.layer.cornerRadius = 24.0
        self.btnClose.isHidden = true
    }
    func setup() {
        var durationString: String = Date().offset(from: self.guidTimerDate).dateComponentsToTimeString()
        if let firstName = Defaults.shared.publicDisplayName {
            self.displayNameLabel.text = "Great Job\n \(firstName)!!!"
        }
        
       // self.quickStartGuideLabel.text = "You've completed \(self.categoryString!) in \(durationString).\nSubscribe now before your 7-day free trial ends."
        self.quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nSubscribe now before your 7-Day Premium Free Trial ends."
        
        if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
            self.userImageView.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: R.image.user_placeholder())
        }
        let isFoundingMember = Defaults.shared.currentUser?.badges?.filter({ return $0.badge?.code == "founding-member" }).count ?? 0 > 0
        if isFoundingMember {
            self.foundingMemberImageView.isHidden = false
        } else {
            self.foundingMemberImageView.isHidden = true
            self.userImageHeightConstraints.constant = 143
            self.userImageWidthConstraints.constant = 143
            self.userImageView.layer.cornerRadius = 71.5
            self.view.updateConstraintsIfNeeded()
            self.view.setNeedsUpdateConstraints()
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
}

extension GreatViewController {
    func setupUser() {
        checkTrailPeriodExpire()
        self.getDays()
        //self.setSubscriptionBadgeDetails()
        UserSync.shared.syncUserModel { isCompleted in
            self.checkTrailPeriodExpire()
            //self.setSubscriptionBadgeDetails()
            self.getDays()
        }
    }
    
    func showTimer(createdDate: Date) {
        timerStackView.isHidden = false
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
                    let subscriptionType = Defaults.shared.currentUser!.subscriptionStatus!
                    let finalDay = Defaults.shared.getCountFromBadge(parentbadge: parentbadge)
                   
                    var fday = 0
                    if let day = Int(finalDay) {
                        if day <= 7 && day >= 0
                        {
                            fday = 7 - day
                        }
                    }
                    if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                       if finalDay == "7" {
                           quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nToday is the last day of your 7-Day Premium Free Trial"
                           if let createdDate = parentbadge.createdAt?.isoDateFromString() {
                               showTimer(createdDate: createdDate)
                           }
                           self.setuptimerViewBaseOnDayLeft(days: "1", subscriptionType: subscriptionType)
                        } else {
                            fday = isTrialExpire ? 0 : fday
                            if fday == 0 {
                                self.setuptimerViewBaseOnDayLeft(days: "0", subscriptionType: subscriptionType)
                            } else {
                                quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nYou have \(fday) days left on your free trial. Subscribe now and earn your subscription badge."
                            self.setuptimerViewBaseOnDayLeft(days: "\(fday + 1)", subscriptionType: subscriptionType)
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
                        self.setuptimerViewBaseOnDayLeft(days: "0", subscriptionType: subscriptionType)
                    } else {
                        
                        if finalDay == "7" {
                            if let createdDate = parentbadge.createdAt?.isoDateFromString() {
                                showTimer(createdDate: createdDate)
                            }
                            self.setuptimerViewBaseOnDayLeft(days: "1", subscriptionType: subscriptionType)
                        } else {
                            fday = isTrialExpire ? 0 : fday
                            if fday == 0 {
                               // self.upgradeNowButton.setTitle("Upgrade To Premium", for: .normal)
                                self.timerStackView.isHidden = true
                                setUpTimerViewForZeroDaySubscription(subscriptionType: subscriptionType)
                            } else {
                                self.setuptimerViewBaseOnDayLeft(days: "\(fday + 1)", subscriptionType: subscriptionType)
                                if let createdDate = parentbadge.createdAt?.isoDateFromString() {
                                    showTimer(createdDate: createdDate)
                                }
                            }
                            subscribersHideTimer(subscriptionType: subscriptionType)
                        }
                    }
                }
            }
        }
    }
}

extension GreatViewController {
    
    func setuptimerViewBaseOnDayLeft(days: String, subscriptionType: String) {
        self.upgradeNowButton.isHidden = false
        self.backToQuickStartButton.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.5), for: .normal)
        if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
            setUpLineIndicatorForSignupDay(lineColor: UIColor(red: 1, green: 0, blue: 0, alpha: 1))
            
            if days == "0" {
                setImageForDays(days: days, imageName: "freeOnboard")
                quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nYour 7-Day Premium Free Trial has ended. Please upgrade your subscription to resume using the Premium features."
                setUpTimerViewForZeroDay()
            } else if (days == "7") {
                setUpTimerViewForSignupDay()
            }
            else {
                setImageForDays(days: days, imageName: "freeOnboard")
                setUpTimerViewForOtherDay()
            }
            
        } else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
            quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nYour 7-Day Premium Free Trial has ended. Please upgrade your subscription to resume using the Premium features."
            setImageForDays(days: "1", imageName: "freeOnboard")
            setUpTimerViewForOtherDay()
        } else if subscriptionType == SubscriptionTypeForBadge.EXPIRE.rawValue {
            quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nYour subscription has  ended. Please upgrade your account now to resume using the basic, advanced or premium features.."
            setImageForDays(days: "1", imageName: "freeOnboard")
            setUpTimerViewForOtherDay()
        } else if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
            setUpLineIndicatorForSignupDay(lineColor: UIColor(red: 0.614, green: 0.465, blue: 0.858, alpha: 1))
           // self.upgradeNowButton.setTitle("Upgrade To Premium", for: .normal)
            
            if (days == "7") {
                setUpTimerViewForSignupDay()
            } else {
                setImageForDays(days: days, imageName: "basicOnboard")
                setUpTimerViewForOtherDay()
            }
            
        } else if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
            setUpLineIndicatorForSignupDay(lineColor: UIColor(red: 0.212, green: 0.718, blue: 1, alpha: 1))
           // self.upgradeNowButton.setTitle("Upgrade To Premium", for: .normal)
            
            if (days == "7") {
                setUpTimerViewForSignupDay()
            } else {
                setImageForDays(days: days, imageName: "advanceOnboard")
                setUpTimerViewForOtherDay()
            }
        } else if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue || subscriptionType == "premium" {
            setUpLineIndicatorForSignupDay(lineColor: UIColor(red: 0.38, green: 0, blue: 1, alpha: 1))
            self.upgradeNowButton.isHidden = true
            self.backToQuickStartButton.setTitleColor(UIColor(red: 0.259, green: 0.522, blue: 0.957, alpha: 1), for: .normal)
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
        if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
            badgeImageView.image = UIImage(named: "badgeIphoneBasic")
            badgeImageView.isHidden = false
            quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nUpgrading your subscription to Advanced or Premium will be available in the next release. You'll be notified when upgrading your channel is ready."
        } else if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
            badgeImageView.image = UIImage(named: "badgeIphoneAdvance")
            badgeImageView.isHidden = false
            quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nUpgrading your subscription to Premium will be available in the next release. You'll be notified when upgrading your channel is ready."
        } else if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue || subscriptionType == "premium" {
            self.upgradeNowButton.isHidden = true
            self.backToQuickStartButton.setTitleColor(UIColor(red: 0.259, green: 0.522, blue: 0.957, alpha: 1), for: .normal)
            badgeImageView.image = UIImage(named: "badgeIphonePre")
            badgeImageView.isHidden = false
            quickStartGuideLabel.text = "You've completed \(self.categoryString!).Use TextShare as the fastest way to share the QuickCam opportunity and grow your potential income."
        }
    }
    
    
    func subscribersHideTimer(subscriptionType: String) {
        timerStackView.isHidden = true
        self.upgradeNowButton.isHidden = true
        self.backToQuickStartButton.setTitleColor(UIColor(red: 0.259, green: 0.522, blue: 0.957, alpha: 1), for: .normal)
        setUpTimerViewForZeroDaySubscription(subscriptionType: subscriptionType)
    }
    
}

extension GreatViewController {
    func getDays() {
        timerStackView.isHidden = true
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
                quickStartGuideLabel.text = self.showMessageData(subscriptionType: subscriptionType, daysLeft: diffDays)
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
    
    func showNewTimer(createdDate: Date, subscriptionType: String) {
        timerStackView.isHidden = false
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

    
    func showWelcomeData(subscriptionType: String, daysLeft: Int) {
        if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
            var originalSubscriptionType = subscriptionType
            if let paidSubscriptionStatus = Defaults.shared.currentUser!.paidSubscriptionStatus {
                originalSubscriptionType = paidSubscriptionStatus
            }
            print("----o \(originalSubscriptionType)")
            if daysLeft == 7 {
                quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nYour 7-Day Premium Free Trial has started. You have 7 days to access all the QuickCam premium features for free while learning how to create fun and engaging content and/or make money sharing QuickCam."
                self.setuptimerViewBaseOnDayLeft(days: "\(daysLeft)", subscriptionType: originalSubscriptionType)
            } else if daysLeft == 0 || daysLeft < 0 {
                quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nYour 7-Day Premium Free Trial has ended. Please upgrade your subscription to resume using the Premium features."
                self.setuptimerViewBaseOnDayLeft(days: "0", subscriptionType: originalSubscriptionType)
            } else if daysLeft == 1 {
                quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nToday is the last day of your 7-Day Premium Free Trial"
                self.setuptimerViewBaseOnDayLeft(days: "1", subscriptionType: originalSubscriptionType)
            } else {
                self.setuptimerViewBaseOnDayLeft(days: "\(daysLeft)", subscriptionType: originalSubscriptionType)
                quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nYou have \(daysLeft) days left on your free trial. Subscribe now and earn your subscription badge."
            }
        } else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
            quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nYour 7-Day Premium Free Trial has ended. Please upgrade your subscription to resume using the Premium features."
            self.setuptimerViewBaseOnDayLeft(days: "0", subscriptionType: subscriptionType)
        } else if subscriptionType == SubscriptionTypeForBadge.EXPIRE.rawValue {
            self.setuptimerViewBaseOnDayLeft(days: "0", subscriptionType: subscriptionType)
            quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nYour subscription has  ended. Please upgrade your account now to resume using the basic, advanced or premium features."
        } else if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
            self.setuptimerViewBaseOnDayLeft(days: "\(daysLeft)", subscriptionType: subscriptionType)
            if daysLeft == 7 {
                quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nYour 7-Day Premium Free Trial has started. You have 7 days to access all the QuickCam premium features for free while learning how to create fun and engaging content and/or make money sharing QuickCam."
            } else if daysLeft == 0 || daysLeft < 0 {
                
            } else if daysLeft == 1 {
                quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nToday is the last day of your 7-Day Premium Free Trial"
            } else {
                quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nYou have \(daysLeft) days left on your free trial. Subscribe now and earn your subscription badge."
            }
            self.subscribersHideTimer(subscriptionType: subscriptionType)
        } else if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
            self.setuptimerViewBaseOnDayLeft(days: "\(daysLeft)", subscriptionType: subscriptionType)
            if daysLeft == 7 {
                quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nYour 7-Day Premium Free Trial has started. You have 7 days to access all the QuickCam premium features for free while learning how to create fun and engaging content and/or make money sharing QuickCam."
            } else if daysLeft == 0 || daysLeft < 0 {
                
            } else if daysLeft == 1 {
                quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nToday is the last day of your 7-Day Premium Free Trial"
            } else {
                quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nYou have \(daysLeft) days left on your free trial. Subscribe now and earn your subscription badge."
            }
            self.subscribersHideTimer(subscriptionType: subscriptionType)
        } else if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue || subscriptionType == "premium" {
            self.setuptimerViewBaseOnDayLeft(days: "\(daysLeft)", subscriptionType: subscriptionType)
            if daysLeft == 7 {
                quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nYour 7-Day Premium Free Trial has started. You have 7 days to access all the QuickCam premium features for free while learning how to create fun and engaging content and/or make money sharing QuickCam."
            } else if daysLeft == 0 || daysLeft < 0 {
                
            } else if daysLeft == 1 {
                quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nToday is the last day of your 7-Day Premium Free Trial"
            } else {
                quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nYou have \(daysLeft) days left on your free trial. Subscribe now and earn your subscription badge."
            }
            self.subscribersHideTimer(subscriptionType: subscriptionType)
        }
    }
    
}

extension GreatViewController {
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
