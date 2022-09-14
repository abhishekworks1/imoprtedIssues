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
    
    @IBOutlet weak var lblQuickStartGuideTitle: UILabel!
    @IBOutlet weak var quickStartGuideLabel: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var foundingMemberImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var lblTimerSince: UILabel!
    @IBOutlet weak var backToQuickStartButton: UIButton!
    @IBOutlet weak var userImageHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var userImageWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var badgeVerticalConstraintToFoudingMember: NSLayoutConstraint!
    @IBOutlet weak var badgeVerticalConstraintTolabelSince: NSLayoutConstraint!
    var categoryString: String?
    
    private var countdownTimer: Timer?
    var greatViewDelegate: GreatPopupDelegate?
    var guidTimerDate: Date = Date()
    var isTrialExpire = false
    
    @IBOutlet weak var btnProfilePic: UIButton!
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    var imageSource = ""
    var croppedImg: UIImage?
    private lazy var storyCameraVC = StoryCameraViewController()
    var profilePicHelper: ProfilePicHelper?
    
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
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        self.userImageView.isUserInteractionEnabled = true
        self.userImageView.addGestureRecognizer(tapGestureRecognizer)
        
        self.badgeVerticalConstraintTolabelSince.constant = 7
        self.centerView.layer.cornerRadius = 8.0
        self.upgradeNowButton.layer.cornerRadius = 20.0
        self.btnClose.isHidden = true
        
        let attributedString: [NSAttributedString.Key: Any] = [
              .font: UIFont.systemFont(ofSize: 14),
              .underlineStyle: NSUnderlineStyle.single.rawValue
          ]

        let attributeString = NSMutableAttributedString(
                string: "Back to QuickStart Guide",
                attributes: attributedString
             )

        self.backToQuickStartButton.setAttributedTitle(attributeString, for: .normal)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        if let tappedImage = tapGestureRecognizer.view as? UIImageView {
            self.openSocialShareVC()
        }
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
            self.userImageView.loadImageWithSDwebImage(imageUrlString: userImageURL)
        }
    }
    
    func setup() {
        var durationString: String = Date().offset(from: self.guidTimerDate).dateComponentsToTimeString()
        if let firstName = Defaults.shared.publicDisplayName {
            self.displayNameLabel.text = "Great Job \(firstName)!"
        }
        

        self.quickStartGuideLabel.text = "You've completed QuickStart Guide - \(self.categoryString ?? "").\nSubscribe now before your 7-Day Premium Free Trial ends."
        
        self.lblQuickStartGuideTitle.text = "You’ve completed the \(self.categoryString ?? "") section of QuickStart Guide."
        
        self.updateUserProfilePic()
//        if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
//            self.userImageView.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: R.image.user_placeholder())
//        }
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
        countdownTimer?.invalidate()
        timerStackView.isHidden = false
        lblTimerSince.isHidden = false
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
        lblTimerSince.isHidden = true
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
                           quickStartGuideLabel.text = "You've completed \(self.categoryString ?? "").\nToday is the last day of your 7-Day Premium Free Trial"
                           if let createdDate = parentbadge.createdAt?.isoDateFromString() {
                               showTimer(createdDate: createdDate)
                           }
                           self.setuptimerViewBaseOnDayLeft(days: "1", subscriptionType: subscriptionType)
                        } else {
                            fday = isTrialExpire ? 0 : fday
                            if fday == 0 {
                                self.setuptimerViewBaseOnDayLeft(days: "0", subscriptionType: subscriptionType)
                            } else {
                                quickStartGuideLabel.text = "You've completed \(self.categoryString ?? "").\nYou have \(fday) days left on your free trial. Subscribe now and earn your subscription badge."
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
                    } else if subscriptionType == SubscriptionTypeForBadge.EXPIRE.rawValue {
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
                                lblTimerSince.isHidden = true
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
                quickStartGuideLabel.text = "You've completed \(self.categoryString ?? "").\nYour 7-Day Premium Free Trial has ended. Please upgrade your subscription to resume using the Premium features."
                setUpTimerViewForZeroDay()
            } else if (days == "7") {
                setUpTimerViewForSignupDay()
            }
            else {
                setImageForDays(days: days, imageName: "freeOnboard")
                setUpTimerViewForOtherDay()
            }
            
        } else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
            quickStartGuideLabel.text = "You've completed \(self.categoryString ?? "").\nYour 7-Day Premium Free Trial has ended. Please upgrade your subscription to resume using the Premium features."
            setImageForDays(days: "1", imageName: "freeOnboard")
            setUpTimerViewForOtherDay()
        } else if subscriptionType == SubscriptionTypeForBadge.EXPIRE.rawValue {
            quickStartGuideLabel.text = "You've completed \(self.categoryString ?? "").\nYour subscription has  ended. Please upgrade your account now to resume using the basic, advanced or premium features.."
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
        lblTimerSince.isHidden = false
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
        lblTimerSince.isHidden = false
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
        lblTimerSince.isHidden = false
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
            self.badgeVerticalConstraintTolabelSince.constant = -30
            badgeImageView.image = UIImage(named: "badgeIphoneBasic")
            badgeImageView.isHidden = false
            quickStartGuideLabel.text = "You've completed \(self.categoryString ?? "").\nUpgrading your subscription to Advanced or Premium will be available in the next release. You'll be notified when upgrading your channel is ready."
        } else if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
            self.badgeVerticalConstraintTolabelSince.constant = -30
            badgeImageView.image = UIImage(named: "badgeIphoneAdvance")
            badgeImageView.isHidden = false
            quickStartGuideLabel.text = "You've completed \(self.categoryString ?? "").\nUpgrading your subscription to Premium will be available in the next release. You'll be notified when upgrading your channel is ready."
        } else if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue || subscriptionType == SubscriptionTypeForBadge.PREMIUM.rawValue {
            self.badgeVerticalConstraintTolabelSince.constant = -30
            self.upgradeNowButton.isHidden = true
            self.backToQuickStartButton.setTitleColor(UIColor(red: 0.259, green: 0.522, blue: 0.957, alpha: 1), for: .normal)
            badgeImageView.image = UIImage(named: "badgeIphonePre")
            badgeImageView.isHidden = false
            quickStartGuideLabel.text = "You've completed \(self.categoryString ?? "").Use TextShare as the fastest way to share the QuickCam opportunity and grow your potential income."
        }
    }
    
    
    func subscribersHideTimer(subscriptionType: String) {
        timerStackView.isHidden = true
        lblTimerSince.isHidden = true
        self.upgradeNowButton.isHidden = true
        self.backToQuickStartButton.setTitleColor(UIColor(red: 0.259, green: 0.522, blue: 0.957, alpha: 1), for: .normal)
        setUpTimerViewForZeroDaySubscription(subscriptionType: subscriptionType)
    }
    
}

extension GreatViewController {
    func getDays() {
        timerStackView.isHidden = true
        lblTimerSince.isHidden = true
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
                quickStartGuideLabel.text = self.showMessageData(subscriptionType: subscriptionType, daysLeft: diffDays).0
                self.lblTimerSince.text = self.showMessageData(subscriptionType: subscriptionType, daysLeft: diffDays).1
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
        countdownTimer?.invalidate()
        timerStackView.isHidden = false
        lblTimerSince.isHidden = false
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

    
    func showWelcomeData(subscriptionType: String, daysLeft: Int) {
        if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
            var originalSubscriptionType = subscriptionType
            if let paidSubscriptionStatus = Defaults.shared.currentUser!.paidSubscriptionStatus {
                originalSubscriptionType = paidSubscriptionStatus
            }
            self.badgeImageView.isHidden = true
            print("----o \(originalSubscriptionType)")
            if daysLeft == 7 {
                quickStartGuideLabel.text = "You've completed \(self.categoryString ?? "").\nYour 7-Day Premium Free Trial has started. You have 7 days to access all the QuickCam premium features for free while learning how to create fun and engaging content and/or make money sharing QuickCam."
                self.setuptimerViewBaseOnDayLeft(days: "\(daysLeft)", subscriptionType: originalSubscriptionType)
            } else if daysLeft == 0 || daysLeft < 0 {
                quickStartGuideLabel.text = "You've completed \(self.categoryString ?? "").\nYour 7-Day Premium Free Trial has ended. Please upgrade your subscription to resume using the Premium features."
                self.setuptimerViewBaseOnDayLeft(days: "0", subscriptionType: originalSubscriptionType)
            } else if daysLeft == 1 {
                quickStartGuideLabel.text = "You've completed \(self.categoryString ?? "").\nToday is the last day of your 7-Day Premium Free Trial"
                self.setuptimerViewBaseOnDayLeft(days: "1", subscriptionType: originalSubscriptionType)
            } else {
                self.setuptimerViewBaseOnDayLeft(days: "\(daysLeft)", subscriptionType: originalSubscriptionType)
                quickStartGuideLabel.text = "You've completed \(self.categoryString ?? "").\nYou have \(daysLeft) days left on your free trial. Subscribe now and earn your subscription badge."
            }
        } else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
            self.badgeImageView.isHidden = true
            quickStartGuideLabel.text = "You've completed \(self.categoryString ?? "").\nYour 7-Day Premium Free Trial has ended. Please upgrade your subscription to resume using the Premium features."
            self.setuptimerViewBaseOnDayLeft(days: "0", subscriptionType: subscriptionType)
        } else if subscriptionType == SubscriptionTypeForBadge.EXPIRE.rawValue {
            self.badgeImageView.isHidden = true
            self.setuptimerViewBaseOnDayLeft(days: "0", subscriptionType: subscriptionType)
            quickStartGuideLabel.text = "You've completed \(self.categoryString ?? "").\nYour subscription has  ended. Please upgrade your account now to resume using the basic, advanced or premium features."
        } else if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
            self.setuptimerViewBaseOnDayLeft(days: "\(daysLeft)", subscriptionType: subscriptionType)
            if daysLeft == 7 {
                quickStartGuideLabel.text = "You've completed \(self.categoryString ?? "").\nYour 7-Day Premium Free Trial has started. You have 7 days to access all the QuickCam premium features for free while learning how to create fun and engaging content and/or make money sharing QuickCam."
            } else if daysLeft == 0 || daysLeft < 0 {
                
            } else if daysLeft == 1 {
                quickStartGuideLabel.text = "You've completed \(self.categoryString ?? "").\nToday is the last day of your 7-Day Premium Free Trial"
            } else {
                quickStartGuideLabel.text = "You've completed \(self.categoryString ?? "").\nYou have \(daysLeft) days left on your free trial. Subscribe now and earn your subscription badge."
            }
            self.subscribersHideTimer(subscriptionType: subscriptionType)
        } else if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
            self.setuptimerViewBaseOnDayLeft(days: "\(daysLeft)", subscriptionType: subscriptionType)
            if daysLeft == 7 {
                quickStartGuideLabel.text = "You've completed \(self.categoryString ?? "").\nYour 7-Day Premium Free Trial has started. You have 7 days to access all the QuickCam premium features for free while learning how to create fun and engaging content and/or make money sharing QuickCam."
            } else if daysLeft == 0 || daysLeft < 0 {
                
            } else if daysLeft == 1 {
                quickStartGuideLabel.text = "You've completed \(self.categoryString ?? "").\nToday is the last day of your 7-Day Premium Free Trial"
            } else {
                quickStartGuideLabel.text = "You've completed \(self.categoryString ?? "").\nYou have \(daysLeft) days left on your free trial. Subscribe now and earn your subscription badge."
            }
            self.subscribersHideTimer(subscriptionType: subscriptionType)
        } else if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue || subscriptionType == "premium" {
            self.setuptimerViewBaseOnDayLeft(days: "\(daysLeft)", subscriptionType: subscriptionType)
            if daysLeft == 7 {
                quickStartGuideLabel.text = "You've completed \(self.categoryString ?? "").\nYour 7-Day Premium Free Trial has started. You have 7 days to access all the QuickCam premium features for free while learning how to create fun and engaging content and/or make money sharing QuickCam."
            } else if daysLeft == 0 || daysLeft < 0 {
                
            } else if daysLeft == 1 {
                quickStartGuideLabel.text = "You've completed \(self.categoryString ?? "").\nToday is the last day of your 7-Day Premium Free Trial"
            } else {
                quickStartGuideLabel.text = "You've completed \(self.categoryString ?? "").\nYou have \(daysLeft) days left on your free trial. Subscribe now and earn your subscription badge."
            }
            self.subscribersHideTimer(subscriptionType: subscriptionType)
        }
    }
    
}

extension GreatViewController {
    func showMessageData(subscriptionType: String, daysLeft: Int) -> (String, String) {
        if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
          var originalSubscriptionType = subscriptionType
          if let paidSubscriptionStatus = Defaults.shared.currentUser!.paidSubscriptionStatus {
            originalSubscriptionType = paidSubscriptionStatus
          }
          if originalSubscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
            // for TRIAL user use this
            if daysLeft == 7 {
              return ("Your 7-Day Premium Free Trial has started. You have 7 days to access all the QuickCam Premium features for free. \nUpgrade to Premium today and get your Premium Subscriber Badge and Day 1 Subscriber Badge!", "Time left in premium free trial.")
            } else if daysLeft == 6 {
              return ("You’re on Day 2 of your 7-Day Premium Free Trial. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 2 Subscriber Badge!", "Time left in premium free trial.")
            } else if daysLeft == 5 {
              return ("You’re on Day 3 of your 7-Day Premium Free Trial. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 3 Subscriber Badge!", "Time left in premium free trial.")
            } else if daysLeft == 4 {
              return ("You’re on Day 4 of your 7-Day Premium Free Trial. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 4 Subscriber Badge!", "Time left in premium free trial.")
            } else if daysLeft == 3 {
              return ("You’re on Day 5 of your 7-Day Premium Free Trial. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 5 Subscriber Badge!", "Time left in premium free trial.")
            } else if daysLeft == 2 {
              return ("You’re on Day 6 of your 7-Day Premium Free Trial. Don’t lose your Premium access after today. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 6 Subscriber Badge!", "Time left in premium free trial.")
            } else if daysLeft == 1 {
              return ("You’re on the last day of your 7-Day Premium Free Trial. Today is the last day you can access all the QuickCam Premium features for free and the last day to get the Day Subscriber Badge. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 7 Subscriber Badge!", "Time left in premium free trial.")
            } else {
              return ("Your 7-Day Premium Free Trial has ended. You can still use QuickCam with Free User access level and the Free User Badge. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 7 Subscriber Badge!", "Time since signed up.")
            }
          }
          else {
            // purchase during trail use this.
            if originalSubscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
              if daysLeft == 7 {
                return ("You’re on Day 1 of the 7-Day Premium Free Trial. As a Basic Subscriber, you’ll continue to have access to all the QuickCam Premium features for free during the 7 days before access drops to Basic subscription level. \nUpgrading to Advanced or Premium available soon.", "Time left in premium free trial.")
              } else if daysLeft == 6 {
                return ("You’re on Day 2 of your 7-Day Premium Free Trial. \nUpgrading to Advanced or Premium available soon.", "Time left in premium free trial.")
              } else if daysLeft == 5 {
                return ("You’re on Day 3 of your 7-Day Premium Free Trial. \nUpgrading to Advanced or Premium available soon.", "Time left in premium free trial.")
              } else if daysLeft == 4 {
                return ("You’re on Day 4 of your 7-Day Premium Free Trial. \nUpgrading to Advanced or Premium available soon.", "Time left in premium free trial.")
              } else if daysLeft == 3 {
                return ("You’re on Day 5 of your 7-Day Premium Free Trial. \nUpgrading to Advanced or Premium available soon.", "Time left in premium free trial.")
              } else if daysLeft == 2 {
                return ("You’re on Day 6 of your 7-Day Premium Free Trial. \nUpgrading to Advanced or Premium available soon.", "Time left in premium free trial.")
              } else if daysLeft == 1 {
                return ("You’re on the last day of your 7-Day Premium Free Trial. As a Basic Subscriber, today is the last day you can access all the QuickCam Premium features for free. \nUpgrading to Advanced or Premium available soon.", "Time left in premium free trial.")
              } else {
                return ("Your 7-Day Premium Free Trial has ended. Your access level is now Basic.", "Upgrade to Advanced or Premium available soon!")
              }
            }
            else if originalSubscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
              if daysLeft == 7 {
                return ("You’re on Day 1 of the 7-Day Premium Free Trial. As an Advanced Subscriber,you’ll continue to have access to all the QuickCam Premium features for free during the 7 days before access drops to Advanced subscription level. \nUpgrading to Premium available soon.", "Time left in premium free trial.")
              } else if daysLeft == 6 {
                return ("You’re on Day 2 of your 7-Day Premium Free Trial. \nUpgrading to Premium available soon.", "Time left in premium free trial.")
              } else if daysLeft == 5 {
                return ("You’re on Day 3 of your 7-Day Premium Free Trial. \nUpgrading to Premium available soon.", "Time left in premium free trial.")
              } else if daysLeft == 4 {
                return ("You’re on Day 4 of your 7-Day Premium Free Trial. \nUpgrading to Premium available soon.", "Time left in premium free trial.")
              } else if daysLeft == 3 {
                return ("You’re on Day 5 of your 7-Day Premium Free Trial. \nUpgrade to Premium now, get the Premium Subscriber Badge and continue using all of the Premium features after the free trial.", "Time left in premium free trial.")
              } else if daysLeft == 2 {
                return ("You’re on Day 6 of your 7-Day Premium Free Trial. \nUpgrade to Premium now, get the Premium Subscriber Badge and continue using all of the Premium features after the free trial.", "Time left in premium free trial.")
              } else if daysLeft == 1 {
                return ("You’re on the last day of your 7-Day Premium Free Trial. As an Advanced Subscriber, today is the last day you can access all the QuickCam Premium features for free. \nUpgrading to Premium available soon.", "Time left in premium free trial.")
              } else {
                return ("Your 7-Day Premium Free Trial has ended. Your access level is now Advanced. \nUpgrading to Premium available soon.", "")
              }
            }
            else if originalSubscriptionType == SubscriptionTypeForBadge.PRO.rawValue || originalSubscriptionType.lowercased() == SubscriptionTypeForBadge.PREMIUM.rawValue {
              if daysLeft == 7 {
                return ("You’re on Day 1 of your first week as a Premium subscriber. \nAs a Premium Subscriber, you can access all the QuickCam Premium features and learn how to create fun and engaging content, and how to make money sharing QuickCam.", "")
              } else if daysLeft == 6 {
                return ("You’re on Day 2 of your first week as a Premium subscriber. \nStart creating fun and engaging content and sharing QuickCam to your contacts.", "")
              } else if daysLeft == 5 {
                return ("You’re on Day 3 of your 7-Day Premium Free Trial. \nUse the unique fast & slow motion special effects to create fun and engaging videos. Share QuickCam to your family, friends & contacts and followers on social media.", "")
              } else if daysLeft == 4 {
                return ("You’re on Day 4 of your 7-Day Premium Free Trial. \nMake money by inviting your family, friends & contacts. When they subscribe, you make money!", "")
              } else if daysLeft == 3 {
                return ("You’re on Day 5 of your 7-Day Premium Free Trial. \nMake money by inviting your family, friends & contacts. When they subscribe, you make money!", "")
              } else if daysLeft == 2 {
                return ("You’re on Day 6 of your 7-Day Premium Free Trial. \nMake money by inviting your family, friends & contacts. When they subscribe, you make money!", "")
              } else if daysLeft == 1 {
                return ("You’re on the last day of your 7-Day Premium Free Trial. \nAs an Premium Subscriber, your Premium access will continue uninterrupted.", "")
              } else {
                return ("Your 7-Day Premium Free Trial has ended. \nYour Premium subscription ensures you have continuous Premium level access.", "")
              }
            }
          }
        }
        else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
          return ("Your 7-Day Premium Free Trial has ended. You can still use QuickCam with Free User access level and the Free User Badge. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 7 Subscriber Badge!", "Time since signing up.")
        }
        else if subscriptionType == SubscriptionTypeForBadge.EXPIRE.rawValue {
          return ("Your subscription has ended. Please upgrade now to resume using the Basic, Advanced or Premium subscription features.", "Time since your subscription expired.")
        }
        else if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
          return ("", "")
        }
        else if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
          return ("", "")
        }
        else if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue || subscriptionType.lowercased() == "premium" {
          return ("", "")
        }
        return ("", "")
      }

}

// MARK: - SharingSocialTypeDelegate
extension GreatViewController: SharingSocialTypeDelegate {
    
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
extension GreatViewController {
    
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
extension GreatViewController {
    
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

