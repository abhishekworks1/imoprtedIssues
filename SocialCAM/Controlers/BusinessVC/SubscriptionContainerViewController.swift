//
//  SubscriptionContainerViewController.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 10/11/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit
import Parchment

class SubscriptionContainerViewController: UIViewController {
    
    // MARK: -
    // MARK: - Outlets

    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var subscriptionImgV: UIImageView!
    
    @IBOutlet weak var timerDescLabel: UILabel!
    @IBOutlet weak var timerContainerStackView: UIStackView!
    @IBOutlet weak var activeFreeView: UIView!
    @IBOutlet weak var viewDetailFreeView: UIView!
    
    @IBOutlet weak var activeBasicView: UIView!
    @IBOutlet weak var viewDetailBasicView: UIView!
    
    @IBOutlet weak var activeAdvancedView: UIView!
    @IBOutlet weak var viewDetailAdvancedView: UIView!
    
    @IBOutlet weak var activeProView: UIView!
    @IBOutlet weak var viewDetailProView: UIView!
    
    
    @IBOutlet weak var lblBadgeFree: UILabel!
    @IBOutlet weak var lblBadgeBasic: UILabel!
    @IBOutlet weak var lblBadgeAdvanced: UILabel!
    @IBOutlet weak var lblBadgePro: UILabel!
    @IBOutlet weak var lbltrialDays: UILabel!
  
    @IBOutlet var imageViewfreeShield: UIImageView!
    
    @IBOutlet weak var freeAppleLogoCenterY: NSLayoutConstraint!
    @IBOutlet weak var basicAppleLogoCenterY: NSLayoutConstraint!
    @IBOutlet weak var advancedAppleLogoCenterY: NSLayoutConstraint!
    @IBOutlet weak var premiumAppleLogoCenterY: NSLayoutConstraint!
    @IBOutlet weak var subscribeNowLabel: UILabel!
    @IBOutlet weak var subscribertypeview: UIView!
    @IBOutlet weak var subscribertypeLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
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
    
    // MARK: -
    // MARK: - Variables
    
    private var isViewControllerAdded = false
    private var pagingViewController = PagingViewController()
    private let indicatorWidth: CGFloat = 47
    private let indicatorWidthDividend: CGFloat = isLiteApp ? 2 : 4
    private var countdownTimer: Timer?
    var isFromWelcomeScreen: Bool = false
    var onboardImageName = "free"
    
    // MARK: -Delegate
    public weak var subscriptionDelegate: SubscriptionScreenDelegate?
    //
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupPagingViewController()
//        setupSubscriotion()
        viewDetailFreeView.isHidden = false
        viewDetailBasicView.isHidden = false
        viewDetailAdvancedView.isHidden = false
        viewDetailProView.isHidden = false
        
        activeFreeView.isHidden = true
        activeBasicView.isHidden = true
        activeAdvancedView.isHidden = true
        activeProView.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        subscribertypeview.isHidden = true
        setSubscriptionBadgeDetails()
        setlblTrialDaysText()
        setSubscribeNowLabel()
        setOnboardImageName()
        setTimer()
    }
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        countdownTimer?.invalidate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationBarView.addBottomShadow()
    }
    
    func setSubscriptionBadgeDetails(){
        if let badgearray = Defaults.shared.currentUser?.badges {
            for parentbadge in badgearray {
                let badgeCode = parentbadge.badge?.code ?? ""

                // Setup For iOS Badge
                if badgeCode == Badges.SUBSCRIBER_IOS.rawValue
                {
                    let subscriptionType = parentbadge.meta?.subscriptionType ?? ""
                    let finalDay = Defaults.shared.getCountFromBadge(parentbadge: parentbadge)
                    
                    lblBadgeFree.text = finalDay
                    lblBadgeBasic.text = finalDay
                    lblBadgeAdvanced.text = finalDay
                    lblBadgePro.text = finalDay
                   
//                    var fday = 0
//                    if let day = Int(finalDay) {
//                        if day <= 7 && day >= 0
//                        {
//                            fday = 7 - day
//                        }
//                    }
//                    lbltrialDays.text = ""
//                    if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
//                       if finalDay == "7" {
//                            lbltrialDays.text = "Today is the last day of your 7-day free trial"//. Upgrade now to access these features"
////                           if let createdDate = parentbadge.createdAt?.isoDateFromString() {
////                               showTimer(createdDate: createdDate)
////                           }
//                        } else {
//                            lbltrialDays.text = "You have \(fday) days left on your free trial."
////                            if let createdDate = parentbadge.createdAt?.isoDateFromString() {
////                                showTimer(createdDate: createdDate)
////                            }
//                        }
//                        if fday == 0 {
//                            lbltrialDays.text = ""
//                        }
//                    }
//                    else
                        if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
                        imageViewfreeShield.image = R.image.badgeIphoneFree()
//                        lbltrialDays.text = ""
                        lblBadgeFree.text = ""
                        lblBadgeBasic.text = ""
                        lblBadgeAdvanced.text = ""
                        lblBadgePro.text = ""
//                        if let createdDate = Defaults.shared.currentUser?.created?.isoDateFromString() {
//                            showFreeTimer(createdDate: createdDate)
//                        }
                    }
                }
            }
        }
    }
    /*func setSubscriptionMessageLabel() {
        //            Note : possible values for subscriptionStatus = free,trial,basic,advance,pro,expired
        if Defaults.shared.currentUser?.subscriptionStatus == "trial" {
            //                        got this data from sagar
            //                        diffDays -> in case of ongoing trial, we will get remaining days
            //                        diffDays -> in case of Paid subscription -> we will get remaining days, after subs is cancelled
            if let timerDate = Defaults.shared.currentUser?.trialSubscriptionStartDateIOS?.isoDateFromString() {
                var dateComponent = DateComponents()
                dateComponent.day = 8
                if let futureDate = Calendar.current.date(byAdding: dateComponent, to: timerDate) {
                    var diffDays = futureDate.days(from: Date())
                    if diffDays == 1 {
                        lbltrialDays.text = "Today is the last day of your 7-Day Premium Free Trial."// Upgrade now to access these features"
                    } else if diffDays > 1 {
                        lbltrialDays.text = "You have \(diffDays) days left on your free trial."// Subscribe now and earn your subscription badge."
                    }
                }
            }
        } else  if Defaults.shared.currentUser?.subscriptionStatus == "expired" {
            lbltrialDays.text = "Your subscription has ended. Please upgrade your account now to resume using the basic, advanced or premium features.\nTime since subscription ended"
        } else  if Defaults.shared.currentUser?.subscriptionStatus == "free" {
            lbltrialDays.text = "Your 7-Day Premium Free Trial is over. Subscribe now to continue using the Basic, Advanced or Premium features.\nTime since signing up"
        } else {
            lbltrialDays.text = ""
        }
        
        if lbltrialDays.text == "" {
            lbltrialDays.isHidden = true
        }
    }*/
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
    func setlblTrialDaysText() {
        //            Note : possible values for subscriptionStatus = free,trial,basic,advance,pro,expired
        var message = ""
        if Defaults.shared.currentUser?.subscriptionStatus == "trial" {
//                        got this data from sagar
//                        diffDays -> in case of ongoing trial, we will get remaining days
//                        diffDays -> in case of Paid subscription -> we will get remaining days, after subs is cancelled
            
         
            if let timerDate = Defaults.shared.currentUser?.trialSubscriptionStartDateIOS?.isoDateFromString() {
                var dateComponent = DateComponents()
                dateComponent.day = 8
                if let futureDate = Calendar.current.date(byAdding: dateComponent, to: timerDate) {
                    let diffDays = futureDate.days(from: Date())
                   message = showMessageData(subscriptionType: Defaults.shared.currentUser?.subscriptionStatus ?? "", daysLeft: diffDays)
                }
            }
        }
        else  if Defaults.shared.currentUser?.subscriptionStatus == "expired" {
            message = showMessageData(subscriptionType: Defaults.shared.currentUser?.subscriptionStatus ?? "", daysLeft: 0)
        } else  if Defaults.shared.currentUser?.subscriptionStatus == "free" {
            message = showMessageData(subscriptionType: Defaults.shared.currentUser?.subscriptionStatus ?? "", daysLeft: 0)
        } else {
            message = ""
        }
        lbltrialDays.text = message
        if lbltrialDays.text == "" {
            lbltrialDays.isHidden = true
        }
    }
    func setTimer(){
        timerContainerStackView.isHidden = true
        let subscriptionStatus = Defaults.shared.currentUser?.subscriptionStatus
        if subscriptionStatus == "trial" {
            if let timerDate = Defaults.shared.userSubscription?.endDate?.isoDateFromString() {
                timerDescLabel.text = "Time remaining:"
                showDownTimer(timerDate: timerDate)
            }
        } else if subscriptionStatus == "free" {
            timerDescLabel.text = "Time since signing up:"
            if let timerDate = Defaults.shared.currentUser?.trialSubscriptionStartDateIOS?.isoDateFromString() {
                showUpTimer(timerDate: timerDate)
            } else if let timerDate = Defaults.shared.currentUser?.created?.isoDateFromString() {
                showUpTimer(timerDate: timerDate)
            }
        } else if subscriptionStatus == "expired" {
            timerDescLabel.text = "Time since your subscription expired:"
            if let timerDate = Defaults.shared.currentUser?.subscriptionEndDate?.isoDateFromString() {
                showUpTimer(timerDate: timerDate)
            }
        } else {
            timerContainerStackView.isHidden = true
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
            self.timerContainerStackView.isHidden = false
            if let subscriptionStatus = Defaults.shared.currentUser?.subscriptionStatus {
                if let paidSubscriptionStatus = Defaults.shared.currentUser!.paidSubscriptionStatus {
                    if subscriptionStatus == "trial" && (paidSubscriptionStatus == "premium" || paidSubscriptionStatus == SubscriptionTypeForBadge.PRO.rawValue) {
                        self.timerContainerStackView.isHidden = true
                    }
                }
                if subscriptionStatus == SubscriptionTypeForBadge.PRO.rawValue || subscriptionStatus == "premium" {
                    self.timerContainerStackView.isHidden = true
                }
            }
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
        self.timerContainerStackView.isHidden = false
        if let subscriptionStatus = Defaults.shared.currentUser?.subscriptionStatus {
            
            if let paidSubscriptionStatus = Defaults.shared.currentUser!.paidSubscriptionStatus {
                if subscriptionStatus == "trial" && (paidSubscriptionStatus == "premium" || paidSubscriptionStatus == SubscriptionTypeForBadge.PRO.rawValue) {
                    self.timerContainerStackView.isHidden = true
                }
            }
            if subscriptionStatus == SubscriptionTypeForBadge.PRO.rawValue || subscriptionStatus == "premium" {
                self.timerContainerStackView.isHidden = true
            }
        }
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
    @IBAction func didTapPremiumButton(_ sender: UIButton) {
        guard let subscriptionVc = R.storyboard.subscription.subscriptionsViewController() else { return }
        subscriptionVc.appMode = .professional
        subscriptionVc.subscriptionType = .professional
        subscriptionVc.isFromWelcomeScreen = self.isFromWelcomeScreen
        navigationController?.pushViewController(subscriptionVc, animated: true)
    }
    
    
    @IBAction func didTapAdvancedButton(_ sender: UIButton) {
        guard let subscriptionVc = R.storyboard.subscription.subscriptionsViewController() else { return }
        subscriptionVc.appMode = .advanced
        subscriptionVc.subscriptionType = .advanced
        subscriptionVc.isFromWelcomeScreen = self.isFromWelcomeScreen
        navigationController?.pushViewController(subscriptionVc, animated: true)
    }
    
    @IBAction func didTapBasicButton(_ sender: UIButton) {
        guard let subscriptionVc = R.storyboard.subscription.subscriptionsViewController() else { return }
        subscriptionVc.appMode = .basic
        subscriptionVc.subscriptionType = .basic
        subscriptionVc.isFromWelcomeScreen = self.isFromWelcomeScreen
        navigationController?.pushViewController(subscriptionVc, animated: true)
    }
    
    
    @IBAction func didTapFreeButton(_ sender: UIButton) {
        guard let subscriptionVc = R.storyboard.subscription.subscriptionsViewController() else { return }
        subscriptionVc.appMode = .free
        subscriptionVc.subscriptionType = .free
        subscriptionVc.isFromWelcomeScreen = self.isFromWelcomeScreen
        navigationController?.pushViewController(subscriptionVc, animated: true)
    }
    
    
    private func setupPagingViewController() {
        guard let freeSubscriptionVc = R.storyboard.subscription.subscriptionsViewController(), let basicSubscriptionVc = R.storyboard.subscription.subscriptionsViewController(), let advancedSubscriptionVc = R.storyboard.subscription.subscriptionsViewController(), let proSubscriptionVc = R.storyboard.subscription.subscriptionsViewController() else { return }
      
        freeSubscriptionVc.subscriptionType = .free
        basicSubscriptionVc.subscriptionType = .basic
        advancedSubscriptionVc.subscriptionType = .advanced
        proSubscriptionVc.subscriptionType = .professional
        if isLiteApp {
            pagingViewController = PagingViewController(viewControllers: [freeSubscriptionVc, basicSubscriptionVc,advancedSubscriptionVc,proSubscriptionVc])
        } else {
            pagingViewController = PagingViewController(viewControllers: [freeSubscriptionVc, basicSubscriptionVc, advancedSubscriptionVc, proSubscriptionVc])
        }
        let menuItemWidth = UIScreen.main.bounds.width / indicatorWidthDividend
        pagingViewController.menuItemLabelSpacing = 0
        pagingViewController.menuItemSize = .fixed(width: menuItemWidth, height: 50)
        let indicatorlineWidth = (menuItemWidth - indicatorWidth) / indicatorWidthDividend
        pagingViewController.indicatorOptions = PagingIndicatorOptions.visible(height: 3, zIndex: 5, spacing: UIEdgeInsets(top: 0, left: indicatorlineWidth, bottom: 0, right: indicatorlineWidth), insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        pagingViewController.menuBackgroundColor = .clear
        pagingViewController.indicatorColor = R.color.appPrimaryColor() ?? .blue
        pagingViewController.borderColor = .clear
        pagingViewController.textColor = .black
        pagingViewController.selectedTextColor = .black
        
        addChild(pagingViewController)
        self.containerView.addSubview(pagingViewController.view)
        pagingViewController.didMove(toParent: self)
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pagingViewController.includeSafeAreaInsets = false
        
        NSLayoutConstraint.activate([
            pagingViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pagingViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pagingViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            pagingViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor)
        ])
    }
    
    func setupSubscriotion(){
        var imgStr = "free-user-icon"
        if Defaults.shared.allowFullAccess ?? false == true{
            imgStr = "trial-user-icon"
        }else if (Defaults.shared.subscriptionType == "trial"){
            if (Defaults.shared.numberOfFreeTrialDays ?? 0 > 0){
                imgStr = "trial-user-icon"
            }else {
                imgStr = "free-user-icon"
            }
        }else if(Defaults.shared.subscriptionType == "basic")
        {
            if(Defaults.shared.isDowngradeSubscription ?? false == true){
                if (Defaults.shared.numberOfFreeTrialDays ?? 0 > 0){
                    imgStr = "active-icon"
                }else {
                    imgStr = "free-user-icon"
                }
            }else{
                imgStr = "active-icon"
            }
        }else{
            imgStr = "free-user-icon"
        }
        subscriptionImgV.image = UIImage.init(named: imgStr)
    }
    func setSubscribeNowLabel() {
        var subscriptionStatus = "free"
        if let paidSubscriptionStatus = Defaults.shared.currentUser?.paidSubscriptionStatus {
            subscriptionStatus = paidSubscriptionStatus
        } else if let subscriptionSts = Defaults.shared.currentUser?.subscriptionStatus {
            subscriptionStatus = subscriptionSts
        }
        subscribeNowLabel.isHidden = true
        if (subscriptionStatus.lowercased() == "basic"){
            viewDetailBasicView.isHidden = true
            activeBasicView.isHidden = false
            subscribeNowLabel.text = "Your Subscription Plan Basic"
            subscribertypeLabel.text = "Your Subscription Plan: Basic"
            subscribertypeview.isHidden = false
            subscribertypeview.backgroundColor = UIColor(hexString:"C9B552")
        }else if(subscriptionStatus.lowercased() == "advance"){
            viewDetailAdvancedView.isHidden = true
            activeAdvancedView.isHidden = false
            subscribeNowLabel.text = "Your Subscription Plan"
            subscribertypeLabel.text = "Your Subscription Plan: Advanced"
            subscribertypeview.isHidden = false
            subscribertypeview.backgroundColor = UIColor(hexString:"88A975")
        }else if(subscriptionStatus.lowercased() == "pro"){
            viewDetailProView.isHidden = true
            activeProView.isHidden = false
            subscribeNowLabel.text = "Your Subscription Plan"
            subscribertypeLabel.text = "Your Subscription Plan: Premium"
            subscribertypeview.isHidden = false
            subscribertypeview.backgroundColor = UIColor(hexString:"617FB1")
        }else{
            subscribeNowLabel.text = "SUBSCRIBE NOW"
            viewDetailFreeView.isHidden = true
            activeFreeView.isHidden = false
            subscribertypeview.isHidden = true
        }
    }
   /* private func setSubscriptionBadgeDetails(){
        lblBadgeFree.text = ""
        lblBadgeBasic.text = ""
        lblBadgeAdvanced.text = ""
        lblBadgePro.text = ""
        lbltrialDays.text = ""
        if let badgearray = Defaults.shared.currentUser?.badges {
            for parentbadge in badgearray {
                let badgeCode = parentbadge.badge?.code ?? ""
                let freeTrialDay = parentbadge.meta?.freeTrialDay ?? 0
                let subscriptionType = parentbadge.meta?.subscriptionType ?? ""
                
                // Setup For iOS Badge
                if badgeCode == Badges.SUBSCRIBER_IOS.rawValue
                {
                   if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                       if freeTrialDay > 0{
                           let trialDayText = "You have \(freeTrialDay) days left on your free trial."
                           lbltrialDays.text = trialDayText
                       }
                        lblBadgeFree.text = freeTrialDay > 0 ? "\(freeTrialDay)" : ""
                       
                      // You have 0 days left on your free trial.
                    }else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
                        if freeTrialDay > 0 {
                            lblBadgeFree.text = "\(freeTrialDay)"
                        } else {
                            //iOS shield hide
                            //square badge show
                            lblBadgeFree.text = ""
                        }
                    }
                    if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
                        lblBadgeBasic.text = freeTrialDay == 0 ? "" : "\(freeTrialDay)"
                    }
                    if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
                        lblBadgeAdvanced.text = freeTrialDay == 0 ? "" : "\(freeTrialDay)"
                    }
                    if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue {
                        lblBadgePro.text = freeTrialDay == 0 ? "" : "\(freeTrialDay)"
                    }
                }
                
            }
        }
        freeAppleLogoCenterY.constant = (lblBadgeFree.text ?? "").trim.isEmpty ? 8 : 0
        basicAppleLogoCenterY.constant = (lblBadgeBasic.text ?? "").trim.isEmpty ? 8 : 0
        advancedAppleLogoCenterY.constant = (lblBadgeAdvanced.text ?? "").trim.isEmpty ? 8 : 0
        premiumAppleLogoCenterY.constant = (lblBadgePro.text ?? "").trim.isEmpty ? 8 : 0
    } */
    // MARK: -
    // MARK: - Button Action Methods
    
    @IBAction func btnBackTapped(_ sender: Any) {
//        if Defaults.shared.isSubscriptionApiCalled == false {
//            subscriptionDelegate?.backFromSubscription()
            self.navigationController?.popViewController(animated: true)
//        }
    }
}

// MARK: - SubscriptionScreenDelegateDelegate

public protocol SubscriptionScreenDelegate: AnyObject {

    func backFromSubscription()
}

extension UIView {
    func addBottomShadow() {
        layer.masksToBounds = false
        layer.shadowRadius = 4
        layer.shadowOpacity = 1
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0 , height: 2)
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                     y: bounds.maxY - layer.shadowRadius,
                                                     width: bounds.width,
                                                     height: layer.shadowRadius)).cgPath
    }
}

enum VerticalLocation: String {
    case bottom
    case top
}

extension UIView {
    func addShadow(location: VerticalLocation, color: UIColor = .black, opacity: Float = 0.5, radius: CGFloat = 5.0) {
        switch location {
        case .bottom:
             addShadow(offset: CGSize(width: 0, height: 3), color: color, opacity: opacity, radius: radius)
        case .top:
            addShadow(offset: CGSize(width: 0, height: -3), color: color, opacity: opacity, radius: radius)
        }
    }

    func addShadow(offset: CGSize, color: UIColor = .darkGray, opacity: Float = 0.5, radius: CGFloat = 5.0) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
}

extension UIView {

    func applyGradient(isVertical: Bool, colorArray: [UIColor]) {
        layer.sublayers?.filter({ $0 is CAGradientLayer }).forEach({ $0.removeFromSuperlayer() })
         
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colorArray.map({ $0.cgColor })
        if isVertical {
            //top to bottom
            gradientLayer.locations = [0.0, 1.0]
        } else {
            //left to right
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        }
        
        backgroundColor = .clear
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }

}
extension SubscriptionContainerViewController {
    func showMessageData(subscriptionType: String, daysLeft: Int) -> String {
        if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
            
            var originalSubscriptionType = subscriptionType
            if let paidSubscriptionStatus = Defaults.shared.currentUser!.paidSubscriptionStatus {
                originalSubscriptionType = paidSubscriptionStatus
            }
            
            if originalSubscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                // for TRIAL user use this
                if daysLeft == 7 {
                    return "Your 7-Day Premium Free Trial has started. Upgrade now to Premium and get your Premium Subscriber Badge and Day 1 Subscriber Badge!"
                } else if daysLeft == 6 {
                    return "You’re on Day 2 of your 7-Day Premium Free Trial. Upgrade now to Premium and get your Premium Subscriber Badge and Day 2 Subscriber Badge!"
                } else if daysLeft == 5 {
                    return "You’re on Day 3 of your 7-Day Premium Free Trial. Upgrade now to Premium and get your Premium Subscriber Badge and Day 3 Subscriber Badge!"
                } else if daysLeft == 4 {
                    return "You’re on Day 4 of your 7-Day Premium Free Trial. Upgrade now to Premium and get your Premium Subscriber Badge and Day 4 Subscriber Badge!"
                } else if daysLeft == 3 {
                    return "You’re on Day 5 of your 7-Day Premium Free Trial. Upgrade now to Premium and get your Premium Subscriber Badge and Day 5 Subscriber Badge!"
                } else if daysLeft == 2 {
                    return "You’re on Day 6 of your 7-Day Premium Free Trial. Upgrade now to Premium and get your Premium Subscriber Badge and Day 6 Subscriber Badge!"
                } else if daysLeft == 1 {
                    return "You’re on the last day of your 7-Day Premium Free Trial. Upgrade now to Premium and get your Premium Subscriber Badge and Day 7 Subscriber Badge!"
                } else {
                    return "Your 7-Day Premium Free Trial has ended. You can still use QuickCam with Free User access level and the Free User Badge"
                }
            }
            else {
                // purchase during trail use this.
                if originalSubscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
                    if daysLeft == 7 {
                        return "You’re on Day 1 of the 7-Day Premium Free Trial. Upgrading to Advanced or Premium available soon."
                    } else if daysLeft == 6 {
                        return "You’re on Day 2 of the 7-Day Premium Free Trial. Upgrading to Advanced or Premium available soon."
                    } else if daysLeft == 5 {
                        return "You’re on Day 3 of the 7-Day Premium Free Trial. Upgrading to Advanced or Premium available soon."
                    } else if daysLeft == 4 {
                        return "You’re on Day 4 of the 7-Day Premium Free Trial. Upgrading to Advanced or Premium available soon."
                    } else if daysLeft == 3 {
                        return "You’re on Day 5 of the 7-Day Premium Free Trial. Upgrading to Advanced or Premium available soon."
                    } else if daysLeft == 2 {
                        return "You’re on Day 6 of the 7-Day Premium Free Trial. Upgrading to Advanced or Premium available soon."
                    } else if daysLeft == 1 {
                        return "You’re on the last day of your 7-Day Premium Free Trial. Upgrading to Advanced or Premium available soon."
                    } else {
                        return "Your 7-Day Premium Free Trial has ended. Your access level is now Basic. Upgrade to Advanced or Premium available soon"
                    }
                }
                else if originalSubscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
                    if daysLeft == 7 {
                        return "You’re on Day 1 of the 7-Day Premium Free Trial. Upgrading to Premium available soon."
                    } else if daysLeft == 6 {
                        return "You’re on Day 2 of the 7-Day Premium Free Trial. Upgrading to Premium available soon."
                    } else if daysLeft == 5 {
                        return "You’re on Day 3 of the 7-Day Premium Free Trial. Upgrading to Premium available soon."
                    } else if daysLeft == 4 {
                        return "You’re on Day 4 of the 7-Day Premium Free Trial. Upgrading to Premium available soon."
                    } else if daysLeft == 3 {
                        return "You’re on Day 5 of the 7-Day Premium Free Trial. Upgrading to Premium available soon."
                    } else if daysLeft == 2 {
                        return "You’re on Day 6 of the 7-Day Premium Free Trial. Upgrading to Premium available soon."
                    } else if daysLeft == 1 {
                        return "You’re on the last day of your 7-Day Premium Free Trial. Upgrading to Premium available soon."
                    } else {
                        return "Your 7-Day Premium Free Trial has ended. Your access level is now Basic. Upgrade to Premium available soon"
                    }
                }
                else if originalSubscriptionType == SubscriptionTypeForBadge.PRO.rawValue || originalSubscriptionType.lowercased() == "premium" {
                    return "As a Premium subscriber, you are at the most feature rich subscription level."
                }
            }
        }
        else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
            return "Your 7-Day Premium Free Trial has  ended. Please upgrade now to resume using the Basic, Advanced or Premium subscription features."
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
