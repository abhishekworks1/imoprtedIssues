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
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var secLabel: UILabel!
    
    @IBOutlet weak var tipOfTheDayStaticLabel: UILabel!
    @IBOutlet weak var tipOfTheDayLabel: UILabel!
    
    @IBOutlet weak var upgradeNowButton: UIButton!
    
    private var countdownTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
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
            if let timerDate = Defaults.shared.currentUser?.created?.isoDateFromString() {
                showUpTimer(timerDate: timerDate)
            }
        } else if  subscriptionStatus == "expired" {
            if let timerDate = Defaults.shared.currentUser?.subscriptionEndDate?.isoDateFromString() {
                showUpTimer(timerDate: timerDate)
            }
        }
    }
    func showUpTimer(timerDate: Date){
        self.countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            let countdown = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: timerDate, to: Date())
            let days = countdown.day!
            let hours = countdown.hour!
            let minutes = countdown.minute!
            let seconds = countdown.second!
            self.secLabel.text = String(format: "%02ds", seconds)
            self.minLabel.text = String(format: "%02dm", minutes)
            self.hourLabel.text = String(format: "%02dh", hours)
            self.dayLabel.text = String(format: "%01dd", days)
        }
    }
    func showDownTimer(timerDate: Date){
        self.countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            let countdown = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: timerDate)
            let days = countdown.day!
            let hours = countdown.hour!
            let minutes = countdown.minute!
            let seconds = countdown.second!
            self.secLabel.text = String(format: "%02ds", seconds)
            self.minLabel.text = String(format: "%02dm", minutes)
            self.hourLabel.text = String(format: "%02dh", hours)
            self.dayLabel.text = String(format: "%01dd", days)
        }
    }
    func setSubscriptionMessageLabel() {
//        if subscriptionType == .free {
//            Note : possible values for subscriptionStatus = free,trial,basic,advance,pro,expired
            if Defaults.shared.currentUser?.subscriptionStatus == "trial" {
                if let diffDays = Defaults.shared.numberOfFreeTrialDays {
                    if diffDays == 0 {
                        subscriptionMessageLabel.text = "Today is the last day of your 7-day free trial. Upgrade now to access these features"
                    } else if diffDays > 0 {
                        subscriptionMessageLabel.text = "You have \(diffDays) days left on your free trial. Subscribe now and earn your subscription badge."
                    }
                }
            } else  if Defaults.shared.currentUser?.subscriptionStatus == "expired" {
                subscriptionMessageLabel.text = "Your 7-day free trial is over. Subscribe now to continue using the Basic, Advanced or Premium features." //"Your 7-day free trial period has expired. Upgrade now to access these features."
            } else  if Defaults.shared.currentUser?.subscriptionStatus == "free" {
                subscriptionMessageLabel.text = "Your 7-day free trial is over. Subscribe now to continue using the Basic, Advanced or Premium features."
            }
//        }
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
            guard let subscriptionVc = R.storyboard.subscription.subscriptionsViewController() else { return }
            subscriptionVc.appMode = .professional
            subscriptionVc.subscriptionType = .professional
            subscriptionVc.isFromWelcomeScreen = true
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.pushViewController(subscriptionVc, animated: true)
        }
    }
    
}
