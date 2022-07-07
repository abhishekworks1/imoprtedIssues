//
//  WelcomeTimerPopupViewController.swift
//  SocialCAM
//
//  Created by ideveloper5 on 01/07/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class WelcomeTimerPopupViewController: UIViewController {

    @IBOutlet weak var subscriptionMessageLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var foundingMemberImageView: UIImageView!
    @IBOutlet weak var semiHalfView: UIView!
    
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
    
    private var countdownTimer: Timer?
    
    var upgradeButtonAction:(()-> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tipOfTheDayLabel.text = Defaults.shared.tipOfDay
        UserSync.shared.getTipOfDay { tip in
            self.tipOfTheDayLabel.text = Defaults.shared.tipOfDay
        }
        setUpUI()
        setTimer()
        setSubscriptionMessageLabel()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        countdownTimer?.invalidate()
    }
    func setUpUI() {
        if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
            self.userImageView.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: R.image.user_placeholder())
        }
        
        // Shadow Color and Radius
        let isFoundingMember = Defaults.shared.currentUser?.badges?.filter({ return $0.badge?.code == "founding-member" }).count ?? 0 > 0
        semiHalfView.layer.shadowColor = isFoundingMember ? UIColor.lightGray.cgColor : UIColor.white.cgColor
        semiHalfView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        semiHalfView.layer.shadowOpacity = 0.7
        semiHalfView.layer.shadowRadius = 0
        semiHalfView.layer.masksToBounds = false
        semiHalfView.layer.cornerRadius = 81.5
        
    }
    func setTimer(){
        let subscriptionStatus = Defaults.shared.currentUser?.subscriptionStatus
        if subscriptionStatus == "trial" {
            if let timerDate = Defaults.shared.userSubscription?.endDate?.isoDateFromString() {
                showDownTimer(timerDate: timerDate)
            }
        } else if subscriptionStatus == "free" {
            if let timerDate = Defaults.shared.currentUser?.trialSubscriptionStartDateIOS?.isoDateFromString() {
                showUpTimer(timerDate: timerDate)
            }
        } else if  subscriptionStatus == "expired" {
            if let timerDate = Defaults.shared.currentUser?.subscriptionEndDate?.isoDateFromString() {
                showUpTimer(timerDate: timerDate)
            }
        } else {
            timerStackView.isHidden = true
            upgradeNowButton.isHidden = true
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
            self.setImageForDays(days: "1", imageName: "freeOnboard")
            self.timerStackView.isHidden = false
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
                        self.setImageForDays(days: "\(imageNumber)", imageName: "freeOnboard")
                        self.setUpTimerViewForOtherDay()
                    } else if imageNumber >= 7 {
                        self.setUpTimerViewForSignupDay()
                    } else {
                        self.setImageForDays(days: "1", imageName: "freeOnboard")
                    }
                }
            }
            self.timerStackView.isHidden = false
        }
    }
    
    func setSubscriptionMessageLabel() {
//            Note : possible values for subscriptionStatus = free,trial,basic,advance,pro,expired
            if Defaults.shared.currentUser?.subscriptionStatus == "trial" {
                if let diffDays = Defaults.shared.numberOfFreeTrialDays {
                    if diffDays == 1 {
                        subscriptionMessageLabel.text = "Today is the last day of your 7-day free trial. Upgrade now to access these features"
                    } else if diffDays > 1 {
                        subscriptionMessageLabel.text = "You have \(diffDays) days left on your free trial. Subscribe now and earn your subscription badge."
                    }
                }
            } else  if Defaults.shared.currentUser?.subscriptionStatus == "expired" {
                subscriptionMessageLabel.text = "Your subscription has ended. Please upgrade your account now to resume using the basic, advanced or premium features."
            } else  if Defaults.shared.currentUser?.subscriptionStatus == "free" {
                subscriptionMessageLabel.text = "Your 7-day free trial is over. Subscribe now to continue using the Basic, Advanced or Premium features."
            } else {
                subscriptionMessageLabel.text = ""
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
