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
    }
    func setup() {
        var durationString: String = Date().offset(from: self.guidTimerDate).dateComponentsToTimeString()
        if let firstName = Defaults.shared.publicDisplayName {
            self.displayNameLabel.text = "Great Job\n \(firstName)!!!"
        }
        
       // self.quickStartGuideLabel.text = "You've completed \(self.categoryString!) in \(durationString).\nSubscribe now before your 7-day free trial ends."
        self.quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nSubscribe now before your 7-day free trial ends."
        
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
        self.setSubscriptionBadgeDetails()
        UserSync.shared.syncUserModel { isCompleted in
            self.checkTrailPeriodExpire()
            self.setSubscriptionBadgeDetails()
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
                           quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nToday is the last day of your 7-day free trial"
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
        if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
            setUpLineIndicatorForSignupDay(lineColor: UIColor(red: 1, green: 0, blue: 0, alpha: 1))
            
            if days == "0" {
                setImageForDays(days: days, imageName: "freeOnboard")
                quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nYour 7-Day Free Trial has ended. Please upgrade your subscription to resume using the Premium features."
                setUpTimerViewForZeroDay()
            } else if (days == "7") {
                setUpTimerViewForSignupDay()
            }
            else {
                setImageForDays(days: days, imageName: "freeOnboard")
                setUpTimerViewForOtherDay()
            }
            
        } else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
            quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nYour 7-Day Free Trial has ended. Please upgrade your subscription to resume using the Premium features."
            setImageForDays(days: days, imageName: "freeOnboard")
            setUpTimerViewForZeroDay()
        } else if subscriptionType == "expired" {
            quickStartGuideLabel.text = "You've completed \(self.categoryString!).\nYour subscription has  ended. Please upgrade your account now to resume using the basic, advanced or premium features.."
            setImageForDays(days: days, imageName: "freeOnboard")
            setUpTimerViewForZeroDay()
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
            badgeImageView.image = UIImage(named: "badgeIphonePre")
            badgeImageView.isHidden = false
            quickStartGuideLabel.text = "You've completed \(self.categoryString!).Use TextShare as the fastest way to share the QuickCam opportunity and grow your potential income."
        }
    }
    
    
    func subscribersHideTimer(subscriptionType: String) {
        timerStackView.isHidden = true
        self.upgradeNowButton.isHidden = true
        setUpTimerViewForZeroDaySubscription(subscriptionType: subscriptionType)
    }
    
}
