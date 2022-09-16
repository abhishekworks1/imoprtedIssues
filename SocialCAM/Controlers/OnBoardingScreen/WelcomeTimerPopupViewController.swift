//
//  WelcomeTimerPopupViewController.swift
//  SocialCAM
//
//  Created by ideveloper5 on 01/07/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class WelcomeTimerPopupViewController: UIViewController {

    @IBOutlet weak var laterButton: UIButton!
    @IBOutlet weak var tipOfDayActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var topMessageView: UIView!
    @IBOutlet weak var topMessageLabel: UILabel!
    @IBOutlet weak var topMessageHeight: NSLayoutConstraint!
    @IBOutlet weak var subscriptionMessageLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var foundingMemberImageView: UIImageView!
    @IBOutlet weak var semiHalfView: UIView!
    
    @IBOutlet weak var timerDescLabel: UILabel!
    @IBOutlet weak var timerStackView: UIStackView!
    @IBOutlet weak var dayValueLabel: UILabel!
    @IBOutlet weak var hourValueLabel: UILabel!
    @IBOutlet weak var minValueLabel: UILabel!
    @IBOutlet weak var secValueLabel: UILabel!
    @IBOutlet weak var freeModeDayImageView: UIImageView!
    @IBOutlet weak var freeModeHourImageView: UIImageView!
    @IBOutlet weak var freeModeMinImageView: UIImageView!
    @IBOutlet weak var freeModeSecImageView: UIImageView!
    @IBOutlet weak var dayLineView: UIView!
    @IBOutlet weak var hourLineView: UIView!
    @IBOutlet weak var minLineView: UIView!
    @IBOutlet weak var secLineView: UIView!
    
    @IBOutlet weak var tipOfTheDayStaticLabel: UILabel!
    @IBOutlet weak var tipOfTheDayLabel: UILabel!
    
    @IBOutlet weak var upgradeNowButton: UIButton!
    
    @IBOutlet weak var popUpScrollview: UIScrollView!
    private var countdownTimer: Timer?
    weak var tipTimer: Timer?
    var currentSelectedTip: Int = 0 
    var tipArray = [String]()
    
    var upgradeButtonAction:(()-> Void)?
    var onboardImageName = "free"
    override func viewDidLoad() {
        super.viewDidLoad()
       setUpUI()
        setOnboardImageName()
        setSubscriptionMessageLabel()
        setUpgradeButton()
    }
    override func viewWillAppear(_ animated: Bool) {
        setTimer()
        UserSync.shared.getTipOfDay { tip in
            self.tipArray = Defaults.shared.tipOfDay ?? [String]()
//            self.tipOfTheDayLabel.text = Defaults.shared.tipOfDay?[0]
            self.checkTipOfDayText(tipOfDay: Defaults.shared.tipOfDay?[0] ?? "")
            self.startTipTimer()
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        countdownTimer?.invalidate()
        tipTimer?.invalidate()
        
    }
    func setUpUI() {
        if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
            self.userImageView.loadImageWithSDwebImage(imageUrlString: userImageURL)
        }
        
        // Shadow Color and Radius
        let isFoundingMember = Defaults.shared.currentUser?.badges?.filter({ return $0.badge?.code == "founding-member" }).count ?? 0 > 0
        semiHalfView.layer.shadowColor = isFoundingMember ? UIColor.white.cgColor : UIColor.white.cgColor
        semiHalfView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        semiHalfView.layer.shadowOpacity = 0.7
        semiHalfView.layer.shadowRadius = 0
        semiHalfView.layer.masksToBounds = false
        semiHalfView.layer.cornerRadius = 81.5
        
//        self.tipOfTheDayLabel.text = Defaults.shared.tipOfDay?[0]
        checkTipOfDayText(tipOfDay: Defaults.shared.tipOfDay?[0] ?? "")
    }
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
    func setOnboardImageName() {
        if let paidSubscriptionStatus = Defaults.shared.currentUser?.paidSubscriptionStatus {
            if paidSubscriptionStatus.lowercased() == "basic" {
                onboardImageName = "basic"
               setUpLineIndicatorForSignupDay(lineColor: UIColor(red: 0.614, green: 0.465, blue: 0.858, alpha: 1))
            } else if paidSubscriptionStatus.lowercased() == "pro" {
                onboardImageName = "premium"
                setUpLineIndicatorForSignupDay(lineColor: UIColor(red: 0.38, green: 0, blue: 1, alpha: 1))
            } else if paidSubscriptionStatus.lowercased() == "advance" {
                onboardImageName = "advance"
                setUpLineIndicatorForSignupDay(lineColor: UIColor(red: 0.212, green: 0.718, blue: 1, alpha: 1))
            }
        } else if let subscriptionStatus = Defaults.shared.currentUser?.subscriptionStatus {
            if subscriptionStatus == "trial" || subscriptionStatus == "free" || subscriptionStatus == "expired" {
                onboardImageName = "free"
            } else {
                onboardImageName = "free"
            }
        } else {
            onboardImageName = "free"
        }
    }
    func setTimer() {
        let subscriptionStatus = Defaults.shared.currentUser?.subscriptionStatus
        if subscriptionStatus == "trial" {
            if let timerDate = Defaults.shared.userSubscription?.endDate?.isoDateFromString() {
                timerDescLabel.text = "Time left in premium free trial"
                showDownTimer(timerDate: timerDate)
            }
        } else if subscriptionStatus == "free" {
            if let timerDate = Defaults.shared.currentUser?.trialSubscriptionStartDateIOS?.isoDateFromString() {
                timerDescLabel.text = "Time since signed up"
                showUpTimer(timerDate: timerDate)
            }
        } else if  subscriptionStatus == "expired" {
            if let timerDate = Defaults.shared.currentUser?.subscriptionEndDate?.isoDateFromString() {
                timerDescLabel.text = "Time since your subscription expired"
               showUpTimer(timerDate: timerDate)
            }
        } else {
            timerStackView.isHidden = true
            timerDescLabel.isHidden = true
        }
    }
    func showUpTimer(timerDate: Date){
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
            self.setImageForDays(days: "1", imageName: "\(self.onboardImageName)Onboard")
            self.timerStackView.isHidden = false
            self.timerDescLabel.isHidden = false
        }
    }
    func showDownTimer(timerDate: Date){
        self.countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            let countdown = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: timerDate)
            let days = countdown.day!
            let hours = countdown.hour!
            let minutes = countdown.minute!
            let seconds = countdown.second!
            self.secValueLabel.text = String(format: "%02d", seconds)
            self.minValueLabel.text = String(format: "%02d", minutes)
            self.hourValueLabel.text = String(format: "%02d", hours)
            self.dayValueLabel.text = String(format: "%01d", days)
            if Defaults.shared.currentUser?.subscriptionStatus == "trial" {
                if let diffDays = Defaults.shared.numberOfFreeTrialDays {
                    let imageNumber = Int(diffDays)
                   if imageNumber >= 1 && imageNumber <= 6 {
                        self.setImageForDays(days: "\(imageNumber)", imageName: "\(self.onboardImageName)Onboard")
                        self.setUpTimerViewForOtherDay()
                    } else if imageNumber >= 7 {
                        self.setUpTimerViewForSignupDay()
                    } else {
                        self.setImageForDays(days: "1", imageName: "\(self.onboardImageName)Onboard")
                    }
                }
            }
            self.timerStackView.isHidden = false
            self.timerDescLabel.isHidden = false
        }
    }
    
    func setSubscriptionMessageLabel() {
//            Note : possible values for subscriptionStatus = free,trial,basic,advance,pro,expired
        var message = ("","")
            if Defaults.shared.currentUser?.subscriptionStatus == "trial" {
                if let timerDate = Defaults.shared.currentUser?.trialSubscriptionStartDateIOS?.isoDateFromString() {
                    var dateComponent = DateComponents()
                    dateComponent.day = 8
                    if let futureDate = Calendar.current.date(byAdding: dateComponent, to: timerDate) {
                        var diffDays = futureDate.days(from: Date())
                        message = showMessageData(subscriptionType: Defaults.shared.currentUser?.subscriptionStatus ?? "", daysLeft: diffDays)
                   /* if diffDays == 1 {
                        subscriptionMessageLabel.text = "Today is the last day of your 7-Day Premium Free Trial. Upgrade now to access these features"
                    } else if diffDays > 1 {
                        subscriptionMessageLabel.text = "You have \(diffDays) days left on your free trial. Subscribe now and earn your subscription badge."
                    }*/
                    }
                }
            } else  if Defaults.shared.currentUser?.subscriptionStatus == "expired" {
                message = showMessageData(subscriptionType: Defaults.shared.currentUser?.subscriptionStatus ?? "", daysLeft: 0)
            } else  if Defaults.shared.currentUser?.subscriptionStatus == "free" {
                message = showMessageData(subscriptionType: Defaults.shared.currentUser?.subscriptionStatus ?? "", daysLeft: 0)
            } else {
                message = ("","")
            }
        subscriptionMessageLabel.text = message.1
        if subscriptionMessageLabel.text == "" {
            subscriptionMessageLabel.isHidden = true
        } else {
            subscriptionMessageLabel.isHidden = false
        }
        topMessageLabel.text = message.0
        if topMessageLabel.text == "" {
            topMessageView.isHidden = true
            topMessageHeight.constant = 0
        } else {
            topMessageView.isHidden = false
            topMessageHeight.constant = 80
        }
        
    }
    func setUpgradeButton() {
        laterButton.isHidden = true
        upgradeNowButton.isHidden = true
        if let paidSubscriptionStatus = Defaults.shared.currentUser?.paidSubscriptionStatus {
            if paidSubscriptionStatus.lowercased() == "basic" || paidSubscriptionStatus.lowercased() == "advance" || paidSubscriptionStatus.lowercased() == "pro" {
                upgradeNowButton.isHidden = true
                laterButton.isHidden = true
            }
        } else if let subscriptionStatus = Defaults.shared.currentUser?.subscriptionStatus {
            if subscriptionStatus == "trial" || subscriptionStatus == "free" || subscriptionStatus == "expired" {
                upgradeNowButton.isHidden = false
                laterButton.isHidden = false
            } else {
                upgradeNowButton.isHidden = true
                laterButton.isHidden = true
            }
        } else {
            upgradeNowButton.isHidden = false
            laterButton.isHidden = false
        }
    }
    func setUpgradeButtonwithUpgrade() {
        laterButton.isHidden = true
        upgradeNowButton.isHidden = true
        if let paidSubscriptionStatus = Defaults.shared.currentUser?.paidSubscriptionStatus {
            if paidSubscriptionStatus.lowercased() == "basic" || paidSubscriptionStatus.lowercased() == "advance" {
                upgradeNowButton.setTitle("Upgrade Now", for: .normal)
                upgradeNowButton.isHidden = false
                laterButton.isHidden = false
            }
            else if paidSubscriptionStatus.lowercased() == "pro" {
                upgradeNowButton.isHidden = true
                laterButton.isHidden = true
            }
        } else if let subscriptionStatus = Defaults.shared.currentUser?.subscriptionStatus {
            if subscriptionStatus == "trial" || subscriptionStatus == "free" || subscriptionStatus == "expired" {
                upgradeNowButton.setTitle("Subscribe Now", for: .normal)
                upgradeNowButton.isHidden = false
                laterButton.isHidden = false
            } else if subscriptionStatus.lowercased() == "basic" || subscriptionStatus.lowercased() == "advance" {
                upgradeNowButton.setTitle("Upgrade Now", for: .normal)
                upgradeNowButton.isHidden = false
                laterButton.isHidden = false
            } else if subscriptionStatus.lowercased() == "pro" {
                upgradeNowButton.isHidden = true
                laterButton.isHidden = true
            } else {
                upgradeNowButton.isHidden = true
                laterButton.isHidden = true
            }
        } else {
            upgradeNowButton.isHidden = false
            laterButton.isHidden = false
        }
    }
    
    func setUpTimerViewForOtherDay() {
        freeModeDayImageView.isHidden = false
        freeModeMinImageView.isHidden = false
        freeModeSecImageView.isHidden = false
        freeModeHourImageView.isHidden = false
        dayLineView.isHidden = true
        hourLineView.isHidden = true
        minLineView.isHidden = true
        secLineView.isHidden = true
        dayValueLabel.isHidden = false
        hourValueLabel.isHidden = false
        secValueLabel.isHidden = false
        minValueLabel.isHidden = false
    }
    
    func setUpTimerViewForSignupDay() {
        freeModeDayImageView.isHidden = true
        freeModeMinImageView.isHidden = true
        freeModeSecImageView.isHidden = true
        freeModeHourImageView.isHidden = true
        dayLineView.isHidden = false
        hourLineView.isHidden = false
        minLineView.isHidden = false
        secLineView.isHidden = false
        dayValueLabel.isHidden = false
        hourValueLabel.isHidden = false
        secValueLabel.isHidden = false
        minValueLabel.isHidden = false
        setUpLineIndicatorForSignupDay(lineColor: UIColor(red: 1, green: 0, blue: 0, alpha: 1))
    }
    
    func setImageForDays(days: String, imageName: String) {
        dayLineView.isHidden = true
        hourLineView.isHidden = true
        minLineView.isHidden = true
        secLineView.isHidden = true
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func upgradeNowOnClick(_ sender: Any) {
        dismiss(animated: true) {
            self.upgradeButtonAction?()
        }
    }
}
extension WelcomeTimerPopupViewController {
    func showMessageData(subscriptionType: String, daysLeft: Int) -> (String,String) {
        if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
            
            var originalSubscriptionType = subscriptionType
            if let paidSubscriptionStatus = Defaults.shared.currentUser!.paidSubscriptionStatus {
                originalSubscriptionType = paidSubscriptionStatus
            }
            
            if originalSubscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                // for TRIAL user use this
                if daysLeft == 7 {
                    return ("Your 7-Day Premium Free Trial has started.","You have 7 days to access all the QuickCam Premium features for free. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 1 Subscriber Badge!")
                } else if daysLeft == 6 {
                    return ("You’re on Day 2 of your\n7-Day Premium Free Trial.","You have 6 more days to access all the QuickCam Premium features for free. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 2 Subscriber Badge!")
                } else if daysLeft == 5 {
                    return ("You’re on Day 3 of your\n7-Day Premium Free Trial.","You have 5 more days to access all the QuickCam Premium features for free. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 3 Subscriber Badge!")
                } else if daysLeft == 4 {
                    return ("You’re on Day 4 of your\n7-Day Premium Free Trial.","You have 4 more days to access all the QuickCam Premium features for free. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 4 Subscriber Badge!")
                } else if daysLeft == 3 {
                    return ("You’re on Day 5 of your\n7-Day Premium Free Trial.","You have 3 more days to access all the QuickCam Premium features for free. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 5 Subscriber Badge!")
                } else if daysLeft == 2 {
                    return ("You’re on Day 6 of your\n7-Day Premium Free Trial.","You have 2 more days to access all the QuickCam Premium features for free. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 6 Subscriber Badge!")
                } else if daysLeft == 1 {
                    return ("You’re on the last day of your\n7-Day Premium Free Trial.","Today is the last day you can access all the QuickCam Premium features for free and the last day to get the Day Subscriber Badge. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 7 Subscriber Badge!")
                } else {
                    return ("Your 7-Day Premium Free Trial has ended.","You can still use QuickCam with Free User access level and the Free User Badge. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 7 Subscriber Badge!")
                }
            }
            else {
                // purchase during trail use this.
                if originalSubscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
                    if daysLeft == 7 {
                        return ("You’re on Day 1 of the\n7-Day Premium Free Trial.","As a Basic Subscriber, you’ll continue to have access to all the QuickCam Premium features for free during the 7 days before access drops to Basic subscription level. \nUpgrading to Advanced or Premium available soon.")
                    } else if daysLeft == 6 {
                        return ("You’re on Day 2 of your\n7-Day Premium Free Trial.","Upgrading to Advanced or Premium available soon.")
                    } else if daysLeft == 5 {
                        return ("You’re on Day 3 of your\n7-Day Premium Free Trial.","Upgrading to Advanced or Premium available soon.")
                    } else if daysLeft == 4 {
                        return ("You’re on Day 4 of your\n7-Day Premium Free Trial.","Upgrading to Advanced or Premium available soon.")
                    } else if daysLeft == 3 {
                        return ("You’re on Day 5 of your\n7-Day Premium Free Trial.","Upgrading to Advanced or Premium available soon.")
                    } else if daysLeft == 2 {
                        return ("You’re on Day 6 of your\n7-Day Premium Free Trial.","Upgrading to Advanced or Premium available soon.")
                    } else if daysLeft == 1 {
                        return ("You’re on the last day of your\n7-Day Premium Free Trial.","As a Basic Subscriber, today is the last day you can access all the QuickCam Premium features for free. \nUpgrading to Advanced or Premium available soon.")
                    } else {
                        return ("Your 7-Day Premium Free Trial has ended.","Your access level is now Basic. \nUpgrade to Advanced or Premium available soon!")
                    }
                }
                else if originalSubscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
                    if daysLeft == 7 {
                        return ("You’re on Day 1 of the\n7-Day Premium Free Trial.","As an Advanced Subscriber,you’ll continue to have access to all the QuickCam Premium features for free during the 7 days before access drops to Advanced subscription level. \nUpgrading to Premium available soon.")
                    } else if daysLeft == 6 {
                        return ("You’re on Day 2 of your\n7-Day Premium Free Trial.","Upgrading to Premium available soon.")
                    } else if daysLeft == 5 {
                        return ("You’re on Day 3 of your\n7-Day Premium Free Trial.","Upgrading to Premium available soon.")
                    } else if daysLeft == 4 {
                        return ("You’re on Day 4 of your\n7-Day Premium Free Trial.","Upgrading to Premium available soon.")
                    } else if daysLeft == 3 {
                        return ("You’re on Day 5 of your\n7-Day Premium Free Trial.","Upgrade to Premium now, get the Premium Subscriber Badge and continue using all of the Premium features after the free trial.")
                    } else if daysLeft == 2 {
                        return ("You’re on Day 6 of your\n7-Day Premium Free Trial.","Upgrade to Premium now, get the Premium Subscriber Badge and continue using all of the Premium features after the free trial.")
                    } else if daysLeft == 1 {
                        return ("You’re on the last day of your\n7-Day Premium Free Trial.","As an Advanced Subscriber, today is the last day you can access all the QuickCam Premium features for free. \nUpgrading to Premium available soon.")
                    } else {
                        return ("Your 7-Day Premium Free Trial has ended.","Your access level is now Advanced. \nUpgrade to Premium available soon.")
                    }
                }
                else if originalSubscriptionType == SubscriptionTypeForBadge.PRO.rawValue || originalSubscriptionType.lowercased() == SubscriptionTypeForBadge.PREMIUM.rawValue {
                    if daysLeft == 7 {
                        return ("You’re on Day 1 of your\nfirst week as a Premium subscriber.","As a Premium Subscriber, you can access all the QuickCam Premium features and learn how to create fun and engaging content, and how to make money sharing QuickCam.")
                    } else if daysLeft == 6 {
                        return ("You’re on Day 2 of your\nfirst week as a Premium subscriber.","Start creating fun and engaging content and sharing QuickCam to your contacts.")
                    } else if daysLeft == 5 {
                        return ("You’re on Day 3 of your\n7-Day Premium Free Trial.","As a Premium Subscriber, your Premium access will continue uninterrupted after the free trial. \nUse the unique fast & slow motion special effects to create fun and engaging videos. Share QuickCam to your family, friends & contacts and followers on social media.")
                    } else if daysLeft == 4 {
                        return ("You’re on Day 4 of your\n7-Day Premium Free Trial.","Make money by inviting your family, friends & contacts. When they subscribe, you make money!")
                    } else if daysLeft == 3 {
                        return ("You’re on Day 5 of your\n7-Day Premium Free Trial.","Make money by inviting your family, friends & contacts. When they subscribe, you make money!")
                    } else if daysLeft == 2 {
                        return ("You’re on Day 6 of your\n7-Day Premium Free Trial.","Make money by inviting your family, friends & contacts. When they subscribe, you make money!")
                    } else if daysLeft == 1 {
                        return ("You’re on the last day of your\n7-Day Premium Free Trial.","As an Premium Subscriber, your Premium access will continue uninterrupted.")
                    } else {
                        return ("Your 7-Day Premium Free Trial has ended.","Your Premium subscription ensures you have continuous Premium level access.")
                    }
                }
            }
        }
        else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
            return ("Your 7-Day Premium Free Trial has ended.","You can still use QuickCam with Free User access level and the Free User Badge. \nUpgrade to Premium now and get your Premium Subscriber Badge and Day 7 Subscriber Badge!")
        }
        else if subscriptionType == "expired" {
            return ("Your subscription has ended.","Please upgrade now to resume using the Basic, Advanced or Premium subscription features.")
        }
        else if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
            return ("","")
        }
        else if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
            return ("","")
        }
        else if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue || subscriptionType.lowercased() == "premium" {
            return ("","")
        }
        return ("","")
    }
    func showMessageDataTemplate(subscriptionType: String, daysLeft: Int) -> String {
        if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
            var originalSubscriptionType = subscriptionType
            if let paidSubscriptionStatus = Defaults.shared.currentUser!.paidSubscriptionStatus {
                originalSubscriptionType = paidSubscriptionStatus
            }
            
            if originalSubscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                // for TRIAL user use this
                if daysLeft == 7 {
                    
                }
            } else {
                // purchase during trail use this.
                if originalSubscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
                    if daysLeft == 7 {
                        return "You’re on Day 1 of the\n7-Day Premium Free Trial. As a Basic Subscriber, you have 7 days to access all the QuickCam Premium features for free. Learn how to create fun and engaging content, and how to make money sharing QuickCam. Upgrading to Advanced or Premium available soon."
                    } else if daysLeft == 6 {
                        return "You’re on Day 2 of your\n7-Day Premium Free Trial. As a Basic Subscriber, you have 6 more days to access all the QuickCam Premium features for free. Start creating fun and engaging content and sharing QuickCam to your contacts. Upgrading to Advanced or Premium available soon."
                    } else if daysLeft == 5 {
                        return "You’re on Day 3 of your\n7-Day Premium Free Trial. As a Basic Subscriber, you have 5 more days to access all the QuickCam Premium features for free. Use the unique fast & slow motion special effects to create fun and engaging videos. Share QuickCam to your family, friends and followers on social media. Upgrading to Advanced or Premium available soon."
                    } else if daysLeft == 4 {
                        return "You’re on Day 4 of your\n7-Day Premium Free Trial. As a Basic Subscriber, you have 4 more days to access all the QuickCam Premium features for free. Make money by inviting your family, friends. When they subscribe, you make money! Upgrading to Advanced or Premium available soon."
                     } else if daysLeft == 3 {
                         return "You’re on Day 5 of your\n7-Day Premium Free Trial. As a Basic Subscriber, you have 3 more days to access all the QuickCam Premium features for free. Make money by inviting your family, friends. When they subscribe, you make money! Upgrading to Advanced or Premium available soon."
                       } else if daysLeft == 2 {
                           return "You’re on Day 6 of your\n7-Day Premium Free Trial. As a Basic Subscriber, you have 2 more days to access all the QuickCam Premium features for free. Make money by inviting your family, friends. When they subscribe, you make money! Upgrading to Advanced or Premium available soon."
                        } else if daysLeft == 1 {
                            return "You’re on the last day of your\n7-Day Premium Free Trial. As a Basic Subscriber, today is the last day you can access all the QuickCam Premium features for free. Upgrading to Advanced or Premium available soon."
                          } else {
                              return ""
                            }
                }
                else if originalSubscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
                    if daysLeft == 7 {
                        return ""
                    } else if daysLeft == 6 {
                        return ""
                    } else if daysLeft == 5 {
                        return ""
                     } else if daysLeft == 4 {
                         return ""
                        } else if daysLeft == 3 {
                            return ""
                           } else if daysLeft == 2 {
                               return ""
                             } else if daysLeft == 1 {
                                 return ""
                                } else {
                                    return ""
                                   }
                }
                else if originalSubscriptionType == SubscriptionTypeForBadge.PRO.rawValue || originalSubscriptionType.lowercased() == "premium" {
                    return ""
                }
            }
        } else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
            return ""
        
        } else if subscriptionType == SubscriptionTypeForBadge.EXPIRE.rawValue {
            return ""
        
        } else if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
            return ""
        
        } else if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
            return ""
        } else if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue || subscriptionType == "premium" {
            return ""
        }
        return ""
    }
}
