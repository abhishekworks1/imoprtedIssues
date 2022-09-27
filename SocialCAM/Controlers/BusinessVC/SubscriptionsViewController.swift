//
//  SubscriptionsViewController.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 10/11/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit

class SubscriptionsViewController: UIViewController {
    
    @IBOutlet weak var thankYouiPhoneLabel: UILabel!
    @IBOutlet weak var thankYouSubscriptionTypeAppleIconImageView: UIImageView!
    @IBOutlet weak var thankYouSubscriptionTypeBadgeBGImageView: UIImageView!
    @IBOutlet weak var thankYouSubscriptionTitleLabel: UILabel!
    @IBOutlet weak var thankYouSubscriptionTypeLabel: UILabel!
    @IBOutlet weak var thankYouSubscriptionBadgeLabel: UILabel!
    @IBOutlet weak var thankYouViewSubScription: UIView!
    @IBOutlet weak var subScriptionTypeLabel: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var quickCamModeSubTitles: UILabel!
    @IBOutlet weak var pic2ArtSubTitleLabel: UILabel!
    @IBOutlet weak var videoEditorSubTitlesLabel: UILabel!
    @IBOutlet weak var mobileDashboardSubTitlesLabel: UILabel!
    @IBOutlet weak var businessDashboardSubTitleLabel: UILabel!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var monthlyPriceView: UIView!
    @IBOutlet weak var subScriptionBadgeImageView: UIImageView!
    @IBOutlet weak var appleIconImageView: UIImageView!
    @IBOutlet weak var appleLogoCenterY: NSLayoutConstraint!
    @IBOutlet weak var trialPackExpireLabel: UILabel!
    @IBOutlet weak var planActiveView: UIView!
    @IBOutlet weak var yourPlanActiveLabel: UILabel!
    @IBOutlet weak var upGradeButtonView: UIView!
    @IBOutlet weak var upGradeButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var pic2ArtTitleLabel: UILabel!
    
    @IBOutlet weak var lblBadgeRemainingDays: UILabel!
    
    @IBOutlet weak var days7TrialSubTitleLabel: UILabel!
    @IBOutlet weak var days7TrialTitleLabel: UILabel!
    
    @IBOutlet weak var freeTrialView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
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
    
    //    @IBOutlet weak var btnUpgrade: UIButton!
//    @IBOutlet weak var lblYourCurrentPlan: UILabel!
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var freeModeAlertView: UIView!
//    @IBOutlet weak var freeModeAlertBlurView: UIVisualEffectView!
//    @IBOutlet weak var lblExpiryDate: UILabel!
//    @IBOutlet weak var lblFreeTrial: UILabel!
//    @IBOutlet weak var expiryDateHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var downgradePopupView: UIView!
//
//    @IBOutlet weak var lblpriceTitle: UILabel!

    
    internal var subscriptionType = AppMode.free {
        didSet {
            self.title = subscriptionType.description
        }
    }
    var appMode: AppMode?
    private var viewModel = PurchaseHelper.shared.objSubscriptionListViewModel
    private var subscriptionsList: [Subscription] {
        return viewModel.subscriptionPlanData
    }
    var isFreeTrialMode = false
    private var countdownTimer: Timer?
    var isFromWelcomeScreen: Bool = false
    var onboardImageName = "free"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        self.viewModel.getPackageList()
        setupUI()
        print(subscriptionType)
        print("subscriptionType")
        print(Defaults.shared.appMode)
        print("Defaults.shared.appMode")
        planActiveView.isHidden = true
        timerStackView.isHidden = true
        lblBadgeRemainingDays.text = ""
        var subscriptionStatus = "free"
        if let paidSubscriptionStatus = Defaults.shared.currentUser?.paidSubscriptionStatus {
            subscriptionStatus = paidSubscriptionStatus
        } else if let subscriptionSts = Defaults.shared.currentUser?.subscriptionStatus {
            subscriptionStatus = subscriptionSts
        }
        if subscriptionType == .basic {
            bindViewModel(appMode: appMode ?? .basic)
            lblPrice.text = "Price: \n$1.99/month"
            subScriptionTypeLabel.text = "Basic"
            if (subscriptionStatus.lowercased() == "basic"){
                planActiveView.isHidden = false
            }
        }
        else if subscriptionType == .advanced {
            bindViewModel(appMode: appMode ?? .basic)
            lblPrice.text = "Price: \n$2.99/month"
            subScriptionTypeLabel.text = "Advanced"
            if (subscriptionStatus.lowercased() == "advance"){
                planActiveView.isHidden = false
            }
        }
        else if subscriptionType == .professional {
            bindViewModel(appMode: appMode ?? .basic)
            lblPrice.text = "Price: \n$4.99/month"
            subScriptionTypeLabel.text = "Premium"
            if (subscriptionStatus.lowercased() == "pro"){
                planActiveView.isHidden = false
            }
        }else{
            lblPrice.text = "Free:  $0/month \nNo subscription required"
            subScriptionTypeLabel.text = "Free"
            if (subscriptionStatus.lowercased() == "trial"){
                let numberOfFreeTrialDays = Defaults.shared.numberOfFreeTrialDays ?? 0
                lblBadgeRemainingDays.text = numberOfFreeTrialDays > 0 ? "\(numberOfFreeTrialDays)" : ""
                planActiveView.isHidden = false
            }
        }
//        if Defaults.shared.allowFullAccess == true {
//            btnUpgrade.isUserInteractionEnabled = false
//            expiryDateHeightConstraint.constant = 0
//            lblPrice.isHidden = true
//        }
        
        setSubscriptionBadgeDetails()
        setOnboardImageName()
//        if self.subscriptionType == .free {
            setTimer()
//        }
        setupFreeTrialView()
//        setUpMessageLabel()
        tapGestureSetUp()
        if let subscriptionStatus = Defaults.shared.currentUser?.subscriptionStatus {
            if let paidSubscriptionStatus = Defaults.shared.currentUser!.paidSubscriptionStatus {
                if subscriptionStatus == "trial" && (paidSubscriptionStatus == "premium" || paidSubscriptionStatus == SubscriptionTypeForBadge.PRO.rawValue) {
                    self.timerStackView.isHidden = true
                    self.messageLabel.isHidden = true
                }
            }
            if subscriptionStatus == SubscriptionTypeForBadge.PRO.rawValue || subscriptionStatus == "premium" {
                self.timerStackView.isHidden = true
                self.messageLabel.isHidden = true
            }
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        countdownTimer?.invalidate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationBarView.addBottomShadow()
        bottomView.addShadow(location: .top)
      
        switch appMode {
        case .professional:
            let firstColor = UIColor.init(hexString: "4D83D4")
            let secondColor = UIColor.init(hexString: "92C5F4")
            monthlyPriceView.applyGradient(isVertical: false, colorArray: [firstColor, secondColor])
        case .advanced:
            let firstColor = UIColor.init(hexString: "77C159")
            let secondColor = UIColor.init(hexString: "BADDAB")
            monthlyPriceView.applyGradient(isVertical: false, colorArray: [firstColor, secondColor])
        case .basic:
            let firstColor = UIColor.init(hexString: "FDE774")
            let secondColor = UIColor.init(hexString: "FDDC66")
            monthlyPriceView.applyGradient(isVertical: false, colorArray: [firstColor, secondColor])
        case .free:
            let firstColor = UIColor.init(hexString: "C3C3C3")
            let secondColor = UIColor.init(hexString: "D7D7D7")
            monthlyPriceView.applyGradient(isVertical: false, colorArray: [firstColor, secondColor])
        default:
            break
        }
    }
    
    func tapGestureSetUp() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapThankYouView))
        tapGesture.numberOfTapsRequired = 1
        self.thankYouViewSubScription.addGestureRecognizer(tapGesture)
    }
    
   @objc func didTapThankYouView(sender: UITapGestureRecognizer)  {
       self.thankYouViewSubScription.isHidden = true

       if isFromWelcomeScreen {
           guard let onBoardView = R.storyboard.welcomeOnboarding.welcomeViewController() else { return }
           let welcomeNavigationVC = R.storyboard.welcomeOnboarding.welcomeViewController()
           welcomeNavigationVC?.viewControllers.append((R.storyboard.welcomeOnboarding.welcomeViewController()?.viewControllers.first)!)
           Utils.appDelegate?.window?.rootViewController = welcomeNavigationVC
       } else {
           for controller in self.navigationController!.viewControllers as Array {
               if controller.isKind(of: StoryCameraViewController.self) {
                   self.navigationController!.popToViewController(controller, animated: true)
                   break
               } else if controller.isKind(of: StorySettingsVC.self) {
                   self.navigationController!.popToViewController(controller, animated: true)
                   break
               }
           }
//           navigationController?.popToViewController(ofClass: StoryCameraViewController.self)
          // self.navigationController?.popToRootViewController(animated: true)
       }
    }
    
    func setupView() {
        appleIconImageView.isHidden = true
        thankYouSubscriptionTypeAppleIconImageView.isHidden = true
        switch appMode {
        case .professional:
            days7TrialTitleLabel.isHidden = true
            days7TrialSubTitleLabel.isHidden = true
            pic2ArtTitleLabel.isHidden = false
            pic2ArtSubTitleLabel.isHidden = false
            subScriptionTypeLabel.text = "Premium"
            subScriptionTypeLabel.textColor = UIColor.init(hexString: "5092D0")
            subScriptionBadgeImageView.image = R.image.badgeIphonePre()
            appleIconImageView.image = R.image.preAppleIcon()
            let firstColor = UIColor.init(hexString: "4D83D4")
            upGradeButtonView.backgroundColor = firstColor
            yourPlanActiveLabel.textColor = firstColor
            planActiveView.isHidden = true
            upGradeButtonView.isHidden = false
            quickCamModeSubTitles.text = "- Record in 2x, 3x, 4x and 5x fast motion\n- Record in -2x, -3x, -4x and -5x slow motion\n- Zoom in and out\n- Record in normal speed\n- Record up to 3 minutes\n- Save Mode"
            pic2ArtSubTitleLabel.text = "- 44 Pic2Art filters\n- Pic2Art Photo Editor"
            videoEditorSubTitlesLabel.text = "- Edit existing videos, up to 5 min\n- Edit up to 20 segments\n- Bitmoji integration\n- Trim, Cut & Crop\n- Watermarks\n- Referral link\n- Share on all supported social media"
            mobileDashboardSubTitlesLabel.text = "- Referral Duplication System\n- Invite Wizard with Contact Inviter\n\t- TextShare\n\t- Manual Email\n\t- QRCodeShare\n\t- SocialShare\n- Income Goal Calculator\n- Notifications\n- iPhone Premium Subscriber Badge"
            businessDashboardSubTitleLabel.text = "- Free while in Beta\n- Automated email inviter\n- Custom Referral pages\n- Referral Commissions and Payout"
            
            //"- Referral Duplication System\n- Custom Referral page for affiliates\n- Invite Wizard with Text and Email Inviter\n- QR Code Profile Badge\n- iPhone Premium Subscriber Badge Business Dashboard (Web access)"
        case .advanced:
            pic2ArtTitleLabel.isHidden = false
            pic2ArtSubTitleLabel.isHidden = false
            days7TrialTitleLabel.isHidden = true
            days7TrialSubTitleLabel.isHidden = true
            subScriptionTypeLabel.text = "Advanced"
            subScriptionBadgeImageView.image = R.image.badgeIphoneAdvance()
            appleIconImageView.image = R.image.advancedAppleIcon()
            subScriptionTypeLabel.textColor = UIColor.init(hexString: "77C159")
            let firstColor = UIColor.init(hexString: "77C159")
            upGradeButtonView.backgroundColor = firstColor
            yourPlanActiveLabel.textColor = firstColor
            planActiveView.isHidden = true
            upGradeButtonView.isHidden = false
            quickCamModeSubTitles.text = "- Record in 2x, 3x and 4x fast motion\n- Record in -2x, -3x and -4x slow motion\n- Zoom in and out\n- Record in normal speed\n- Record up to 2 minutes\n- Save Mode"
            pic2ArtSubTitleLabel.text = "- 44 Pic2Art filters\n- Pic2Art Photo Editor"
            videoEditorSubTitlesLabel.text = "- Edit existing videos, up to 2 minutes\n- Bitmoji integration\n- Trim, Cut & Crop\n- Watermarks\n- Referral link\n- Share on all supported social media"
            mobileDashboardSubTitlesLabel.text = "- Referral Duplication System\n- Invite Wizard with Contact Inviter\n\t- TextShare\n\t- Manual Email\n\t- QRCodeShare\n\t- SocialShare\n- Income Goal Calculator\n- Notifications\n- iPhone Advanced Subscriber Badge"
            businessDashboardSubTitleLabel.text = "- Free while in Beta\n- Automated email inviter\n- Custom Referral pages\n- Referral Commissions and Payout"
        case .basic:
            subScriptionTypeLabel.text = "Basic"
            subScriptionTypeLabel.textColor = UIColor.init(hexString: "EAB140")
            subScriptionBadgeImageView.image = R.image.badgeIphoneBasic()
            appleIconImageView.image = R.image.basicAppleIcon()
            let firstColor = UIColor.init(hexString: "FDE774")
            //DCAF54
            planActiveView.isHidden = true
            upGradeButtonView.isHidden = false
            upGradeButtonView.backgroundColor = firstColor
            yourPlanActiveLabel.textColor = UIColor.init(hexString: "DCAF54")
            pic2ArtTitleLabel.isHidden = true
            pic2ArtSubTitleLabel.isHidden = true
            days7TrialTitleLabel.isHidden = true
            days7TrialSubTitleLabel.isHidden = true
            quickCamModeSubTitles.text = "- Record in 2x and 3x fast motion\n- Record in -2x and -3x slow motion\n- Zoom in and out\n- Record in normal speed\n- Record up to 1 minute"
            videoEditorSubTitlesLabel.text = "- Edit existing videos, up to 1 minutes\n- Bitmoji integration\n- Trim, Cut & Crop\n- Watermarks\n- Invite link sticker\n- Referral link\n- Share on all supported social media"
            mobileDashboardSubTitlesLabel.text = "- Referral Duplication System\n- Invite Wizard with Contact Inviter\n\t- TextShare\n\t- Manual Email\n\t- QRCodeShare\n\t- SocialShare\n- Income Goal Calculator\n- Notifications\n- iPhone Basic Subscriber Badge"
            businessDashboardSubTitleLabel.text = "- Free while in Beta\n- Automated email inviter\n- Custom Referral pages\n- Referral Commissions and Payout"
        case .free:
            pic2ArtTitleLabel.isHidden = true
            pic2ArtSubTitleLabel.isHidden = true
            days7TrialTitleLabel.isHidden = false
            days7TrialSubTitleLabel.isHidden = false
            subScriptionTypeLabel.text = "Free"
            subScriptionTypeLabel.textColor = UIColor.init(hexString: "000000")
            subScriptionBadgeImageView.image = R.image.badgeIphoneTrial()
            appleIconImageView.image = R.image.freeAppleIcon()
            let firstColor = UIColor.init(hexString: "C3C3C3")
            upGradeButtonView.backgroundColor = firstColor
            yourPlanActiveLabel.textColor = firstColor
            planActiveView.isHidden = true
            upGradeButtonView.isHidden = false
            days7TrialSubTitleLabel.text = "- Access to all Premium Features\n- No credit card required"
            
            quickCamModeSubTitles.text = "- Record in 2x and 3x fast motion\n- Record in -2x and -3x slow motion\n- Zoom in and out\n- Record in normal speed\n- Record up to 30 seconds"
            
            videoEditorSubTitlesLabel.text = "- Edit existing videos, up to 30 seconds\n- Bitmoji integration\n- Trim, Cut & Crop\n- Watermarks\n- Referral link\n- Invite link sticker\n- Share on all supported social media"
            
            mobileDashboardSubTitlesLabel.text = "- Referral Duplication System\n- Invite Wizard with Contact Inviter\n\t- TextShare\n\t- Manual Email\n\t- QRCodeShare\n\t- SocialShare\n- Income Goal Calculator\n- Notifications\n- Free User Badge"
            
            businessDashboardSubTitleLabel.text = "- Free while in Beta\n- Automated email inviter\n- Custom Referral pages\n- Referral Commissions and Payout"
        default:
            break
        }
    }
    
    @IBAction func btnUpgradeTapped(_ sender: UIButton) {
//        switch appMode {
//        case .professional:
//            print("premium")
//        case .advanced:
//            print("Advanced")
//        case .basic:
//            print("Basic")
//        case .free:
//            print("free")
//        default:
//            break
//        }
        if subscriptionType == .free {
            if isFromWelcomeScreen {
                guard let onBoardView = R.storyboard.welcomeOnboarding.welcomeViewController() else { return }
                Utils.appDelegate?.window?.rootViewController = onBoardView
            } else {
                navigationController?.popViewController(animated: true)
            }
        }
         else if Defaults.shared.appMode != self.subscriptionType || isFreeTrialMode || (Defaults.shared.isDowngradeSubscription == true && Defaults.shared.appMode != .free) {
            Defaults.shared.isSubscriptionApiCalled = true
             
            self.enableMode(appMode: self.subscriptionType)
        }
    }
    
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        if appDelegate?.isSubscriptionButtonPressed ?? false{
            return
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnOkayTapped(_ sender: UIButton) {
        self.thankYouViewSubScription.isHidden = true
        if isFromWelcomeScreen {
            guard let onBoardView = R.storyboard.welcomeOnboarding.welcomeViewController() else { return }
            let welcomeNavigationVC = R.storyboard.welcomeOnboarding.welcomeViewController()
            welcomeNavigationVC?.viewControllers.append((R.storyboard.welcomeOnboarding.welcomeViewController()?.viewControllers.first)!)
            Utils.appDelegate?.window?.rootViewController = welcomeNavigationVC
        } else {
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: StoryCameraViewController.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                } else if controller.isKind(of: StorySettingsVC.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }
//        freeModeAlertBlurView.isHidden = true
//        freeModeAlertView.isHidden = true
//        Defaults.shared.isSubscriptionApiCalled = false
    }
    
    @IBAction func btnCancelPopupTapped(_ sender: UIButton) {
//        self.downgradePopupView.isHidden = true
//        Defaults.shared.isSubscriptionApiCalled = false
    }
    
    @IBAction func btnOkDowngradeTapped(_ sender: UIButton) {
//        self.downgradePopupView.isHidden = true
//        if Defaults.shared.releaseType == .store {
//            guard let url = URL(string: Constant.SubscriptionUrl.cancelSubscriptionUrl) else {
//                return
//            }
//            UIApplication.shared.open(url)
//        } else {
//            if let subscriptionId = Defaults.shared.subscriptionId {
//                self.downgradeSubscription(subscriptionId)
//            } else {
//                Defaults.shared.isSubscriptionApiCalled = false
//            }
//        }
    }
    
    private func setupUI() {
        let subscriptionData = subscriptionsList.filter({$0.productId == Constant.IAPProductIds.quickCamLiteBasic})
        if let currentUser = Defaults.shared.currentUser {
//            lblExpiryDate.text = R.string.localizable.expiryDaysLeft("\(Defaults.shared.numberOfFreeTrialDays ?? 0)")
            //if currentUser.isTempSubscription ?? false && subscriptionType != .free && Defaults.shared.appMode != .free {
            if (Defaults.shared.subscriptionType == "trial") && subscriptionType != .free && Defaults.shared.appMode != .free {
                isFreeTrialMode = true
                setupForFreeTrial(isFreeTrial: true)
            } else if Defaults.shared.isDowngradeSubscription == true && subscriptionType != .free && Defaults.shared.appMode != .free {
//                lblYourCurrentPlan.isHidden = false
                setupForFreeTrial(isFreeTrial: false)
//                expiryDateHeightConstraint.constant = 48
            } else {
                setupForFreeTrial(isFreeTrial: false)
                if Defaults.shared.numberOfFreeTrialDays != 0 && subscriptionType != .free && Defaults.shared.appMode != .free {
//                    expiryDateHeightConstraint.constant = 48
                }
            }
            //if (currentUser.isTempSubscription == true && subscriptionType == .free) || (Defaults.shared.isDowngradeSubscription == true && subscriptionType == .free) {
            if ((Defaults.shared.subscriptionType == "trial") && subscriptionType == .free) || (Defaults.shared.isDowngradeSubscription == true && subscriptionType == .free) {
//                btnUpgrade.isHidden = true
            }
        }
        self.lblTitle.text = self.subscriptionType.description
        print(self.subscriptionType.description)
        print("self.subscriptionType.description")
        //Comment by Navroz
       /* DispatchQueue.main.async {
            if let price = subscriptionData.first?.price,
               price == 1.99 {
                self.lblPrice.text = (self.subscriptionType != .free) ? "$\(price)/Month" : self.subscriptionType.price
            } else {
                self.lblPrice.text = self.subscriptionType.price
            }
//            self.expiryDateHeightConstraint.constant = 48
        }
        */
        if subscriptionType == .basic {
            print("basic")
        }else{
            print("free")
        }


//        var isSubscriptionCondition = true
//        if (Defaults.shared.subscriptionType == "trial"){
//            if (Defaults.shared.numberOfFreeTrialDays ?? 0 > 0){
//                isFreeTrialMode = false  // need to purchase manually
//                setupForFreeTrial(isFreeTrial: true)
//            }else {
//                isFreeTrialMode = false
//            }
//        }else if(Defaults.shared.subscriptionType == "basic")
//        {
//            isSubscriptionCondition = false
//            if(Defaults.shared.isDowngradeSubscription ?? false == true){
//                btnUpgrade.setTitle(R.string.localizable.upgradeNow(), for: .normal)
//                btnUpgrade.backgroundColor = R.color.appPrimaryColor()
//            }else{
//                lblYourCurrentPlan.isHidden = false
//                self.setDowngradeButton()
//            }
//        }else{
//            isFreeTrialMode = false
//        }
//
//        if (isSubscriptionCondition) {
//            btnUpgrade.setTitle( R.string.localizable.upgradeNow(), for: .normal)
//            btnUpgrade.backgroundColor =  R.color.appPrimaryColor()
//            btnUpgrade.isHidden = (subscriptionType == .free) ? false : true //!isFreeTrialMode
//            lblYourCurrentPlan.isHidden = (subscriptionType == .free) ? false : true //isFreeTrialMode
//            if !isFreeTrialMode {
//                btnUpgrade.titleLabel?.font = R.font.sfuiTextRegular(size: 20)
//            }
//        }

        if Defaults.shared.appMode == self.subscriptionType {
            if Defaults.shared.isDowngradeSubscription == true && Defaults.shared.appMode != .free {
//                btnUpgrade.setTitle(R.string.localizable.upgradeNow(), for: .normal)
//                btnUpgrade.backgroundColor = R.color.appPrimaryColor()
            } else {
//                btnUpgrade.setTitle(isFreeTrialMode ? R.string.localizable.upgradeNow() : R.string.localizable.yourCurrentPlan(), for: .normal)
//                btnUpgrade.backgroundColor = isFreeTrialMode ? R.color.appPrimaryColor() : R.color.currentPlanButtonColor()
//                btnUpgrade.isHidden = !isFreeTrialMode
//                lblYourCurrentPlan.isHidden = isFreeTrialMode
//                if !isFreeTrialMode {
//                    btnUpgrade.titleLabel?.font = R.font.sfuiTextRegular(size: 20)
//                }
            }
        } else {
            self.setDowngradeButton()
        }
        Defaults.shared.subscriptionId = subscriptionData.first?.id ?? ""
        if subscriptionType == .free {
//            btnUpgrade.isHidden = true
        }
        var subscriptionStatus = "free"
        if let paidSubscriptionStatus = Defaults.shared.currentUser?.paidSubscriptionStatus {
            subscriptionStatus = paidSubscriptionStatus
        } else if let subscriptionSts = Defaults.shared.currentUser?.subscriptionStatus {
            subscriptionStatus = subscriptionSts
        }
        if (subscriptionStatus == "basic") || (subscriptionStatus == "advance") || (subscriptionStatus == "pro"){
            upGradeButtonView.isHidden = true
        }
        if appMode == .free{
            upGradeButtonView.isHidden = true
        }
//        if subscriptionType == .free {
//            if planActiveView.isHidden {
               // upGradeButtonView.isHidden = false
//            }
//        }
    }
    func setupFreeTrialView(){
        freeTrialView.isHidden = true
        if subscriptionType == .free {
            if Defaults.shared.currentUser?.subscriptionStatus == "trial" {
                freeTrialView.isHidden = false
            }
        }
    }
    func setUpMessageLabel() {
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
//        messageLabel.text = message
//        if messageLabel.text == "" {
//            messageLabel.isHidden = true
//        }
    }
    
    func setSubscriptionBadgeDetails(){
//        lblBadgeRemainingDays.text =  ""
        print(Defaults.shared.currentUser?.badges ?? "")
        if let badgearray = Defaults.shared.currentUser?.badges {
            for parentbadge in badgearray {
                let badgeCode = parentbadge.badge?.code ?? ""

                // Setup For iOS Badge
                if badgeCode == Badges.SUBSCRIBER_IOS.rawValue
                {
                    let subscriptionType = parentbadge.meta?.subscriptionType ?? ""
                    let finalDay = Defaults.shared.getCountFromBadge(parentbadge: parentbadge)
                    
                    lblBadgeRemainingDays.text = ""
                    lblBadgeRemainingDays.text = finalDay
                 /*   if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                        if finalDay == "7" {
                            lblPrice.text = "Today is the last day of your 7-day free trial. Upgrade now to access these features"
                            if self.subscriptionType == .free {
                                freeTrialView.isHidden = false
                                if let createdDate = parentbadge.createdAt?.isoDateFromString() {
                                    showTimer(createdDate: createdDate)
                                }
                            }
                        } else {
                            var fday = 0
                            if let day = Int(finalDay) {
                                if day <= 7 && day >= 0
                                {
                                    fday = 7 - day
                                }
                            }
                            if fday == 0{
                                lblPrice.text = "Your 7-day free trial period has expired. Upgrade now to access these features."
                            }else{
                                lblPrice.text = "You have \(fday) days left on your free trial. Subscribe now and earn your subscription badge."
                                if self.subscriptionType == .free {
                                    freeTrialView.isHidden = false
                                    if let createdDate = parentbadge.createdAt?.isoDateFromString() {
                                        showTimer(createdDate: createdDate)
                                    }
                                }
                                
                            }
                        }
                        
                    } else */
                    if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
                        lblBadgeRemainingDays.text = ""
//                        lblPrice.text = "Your 7-day free trial is over. Subscribe now to continue using the Basic, Advanced or Premium features."
//                        freeTrialView.isHidden = true
                        if self.subscriptionType == .free {
                            subScriptionBadgeImageView.image = R.image.badgeIphoneFree()
//                            if let createdDate = Defaults.shared.currentUser?.created?.isoDateFromString() {
//                                showFreeTimer(createdDate: createdDate)
//                            }
                        }
                    }
                }
            }
        }
        appleLogoCenterY.constant = (lblBadgeRemainingDays.text ?? "").trim.isEmpty ? -10 : -10
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
    func setTimer(){
        let subscriptionStatus = Defaults.shared.currentUser?.subscriptionStatus
        if subscriptionStatus == "trial" {
            if let timerDate = Defaults.shared.userSubscription?.endDate?.isoDateFromString() {
//                self.messageLabel.isHidden = false
//                self.messageLabel.text = "Time remaining"
                showDownTimer(timerDate: timerDate)
            }
        } else if subscriptionStatus == "free" {
            if let timerDate = Defaults.shared.currentUser?.trialSubscriptionStartDateIOS?.isoDateFromString() {
//                self.messageLabel.isHidden = false
//                self.messageLabel.text = "Your 7-Day Premium Free Trial is over. Subscribe now to continue using the Basic, Advanced or Premium features.\nTime since signing up"
               showUpTimer(timerDate: timerDate)
            } else if let timerDate = Defaults.shared.currentUser?.created?.isoDateFromString() {
//                self.messageLabel.isHidden = false
//                self.messageLabel.text = "Your 7-Day Premium Free Trial is over. Subscribe now to continue using the Basic, Advanced or Premium features.\nTime since signing up"
                showUpTimer(timerDate: timerDate)
            }
        } else if subscriptionStatus == "expired" {
            if let timerDate = Defaults.shared.currentUser?.subscriptionEndDate?.isoDateFromString() {
//                self.messageLabel.isHidden = false
//                self.messageLabel.text = "Your subscription has ended. Please upgrade your account now to resume using the basic, advanced or premium features.\nTime since subscription ended"
                showUpTimer(timerDate: timerDate)
            }
        } else {
            timerStackView.isHidden = true
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
            if let subscriptionStatus = Defaults.shared.currentUser?.subscriptionStatus {
                if let paidSubscriptionStatus = Defaults.shared.currentUser!.paidSubscriptionStatus {
                    if subscriptionStatus == "trial" && (paidSubscriptionStatus == "premium" || paidSubscriptionStatus == SubscriptionTypeForBadge.PRO.rawValue) {
                        self.timerStackView.isHidden = true
                        self.messageLabel.isHidden = true
                    }
                }
                if subscriptionStatus == SubscriptionTypeForBadge.PRO.rawValue || subscriptionStatus == "premium" {
                    self.timerStackView.isHidden = true
                    self.messageLabel.isHidden = true
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
        self.timerStackView.isHidden = false
        if let subscriptionStatus = Defaults.shared.currentUser?.subscriptionStatus {
            if let paidSubscriptionStatus = Defaults.shared.currentUser!.paidSubscriptionStatus {
                if subscriptionStatus == "trial" && (paidSubscriptionStatus == "premium" || paidSubscriptionStatus == SubscriptionTypeForBadge.PRO.rawValue) {
                    self.timerStackView.isHidden = true
                    self.messageLabel.isHidden = true
                }
            }
            if subscriptionStatus == SubscriptionTypeForBadge.PRO.rawValue || subscriptionStatus == "premium" {
                self.timerStackView.isHidden = true
                self.messageLabel.isHidden = true
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
  
    private func setDowngradeButton() {
        switch Defaults.shared.appMode {
        case .free:
            return
        case .basic:
            if self.subscriptionType == .advanced || self.subscriptionType == .professional {
                return
            }
        case .advanced:
            if self.subscriptionType == .professional {
                return
            }
        case .professional:
            break
        }
//        btnUpgrade.setTitle(R.string.localizable.downgrade(), for: .normal)
    }
    
    func enableMode(appMode: AppMode) {
        var message: String? = ""
        let placeholder: String? = R.string.localizable.activationCode()
        var proModeCode: String? = Constant.Application.proModeCode
        #if PIC2ARTAPP
        switch appMode {
        case .professional:
            proModeCode = Constant.Application.pic2artProModeCode
        default:
            break
        }
        #endif
        var successMessage: String? = ""
        switch appMode {
        case .free:
            if Defaults.shared.releaseType == .beta {
//                freeModeAlertBlurView.isHidden = false
//                freeModeAlertView.isHidden = false
            } else {
                message = R.string.localizable.areYouSureSubscriptionMessage(R.string.localizable.downgrade(), appMode.description)
                successMessage = R.string.localizable.freeModeIsEnabled()
            }
        case .basic:
            var upgradeString = R.string.localizable.upgrade()
            if Defaults.shared.appMode == .advanced || Defaults.shared.appMode == .professional {
                upgradeString = R.string.localizable.downgrade()
            }
            message = R.string.localizable.enterCodeSubscriptionMessage(appMode.description)
            if isLiteApp {
                successMessage = R.string.localizable.basicLiteModeIsEnabled()
            } else {
                successMessage = R.string.localizable.basicModeIsEnabled()
            }
        case .advanced:
            var upgradeString = R.string.localizable.upgrade()
            if Defaults.shared.appMode == .professional {
                upgradeString = R.string.localizable.downgrade()
            }
            message = R.string.localizable.areYouSureSubscriptionMessage(upgradeString, appMode.description)
            if isLiteApp {
                successMessage = R.string.localizable.advancedModeIsEnabled()
            } else {
                successMessage = R.string.localizable.advancedModeIsEnabled()
            }
           
        case .professional:
            message = R.string.localizable.areYouSureSubscriptionMessage(R.string.localizable.upgrade(), appMode.description)
            if isLiteApp {
                successMessage = R.string.localizable.professionalModeIsEnabled()
            } else {
                successMessage = R.string.localizable.professionalModeIsEnabled()
            }
        }
        
        let objAlert = UIAlertController(title: Constant.Application.displayName, message: message, preferredStyle: .alert)
        if appMode != .free {
            objAlert.addTextField { (textField: UITextField) -> Void in
                #if DEBUG
                textField.text = proModeCode
                #endif
                textField.placeholder = placeholder
            }
        }
        
        let actionSave = UIAlertAction(title: R.string.localizable.oK(), style: .default) { [weak self] ( _: UIAlertAction) in
            guard let `self` = self else {
                return
            }
            if appMode != .free {
                guard let textField = objAlert.textFields?.first,
                    textField.text?.count ?? 0 > 0 else {
                    Utils.customaizeToastMessage(title: R.string.localizable.pleaseEnterValidCode(), toastView: self.view)
                    return
                }
                self.callSubscriptionApi(appMode: appMode, code: textField.text ?? "", successMessage: successMessage)
            } else {
                if Defaults.shared.releaseType == .store {
                    guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else {
                        return
                    }
                    UIApplication.shared.open(url)
                } else {
                    if let subscriptionId = Defaults.shared.subscriptionId {
                        self.downgradeSubscription(subscriptionId)
                    } else {
                        Defaults.shared.isSubscriptionApiCalled = false
                    }
                }
            }
            
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .default) { (_: UIAlertAction) in
            Defaults.shared.isSubscriptionApiCalled = false
        }
        objAlert.addAction(cancelAction)
        objAlert.addAction(actionSave)
        if isQuickApp{
            var productid = Constant.IAPProductIds.quickCamLiteBasic
            if appMode == .basic{
                productid = Constant.IAPProductIds.quickCamLiteBasic
            }else if appMode == .advanced{
                productid = Constant.IAPProductIds.quickCamLiteAdvance
            }else if appMode == .professional{
                productid = Constant.IAPProductIds.quickCamLitePro
            }
          
            let subscriptionData = subscriptionsList.filter({$0.productId == productid})
            self.purchaseProduct(productIdentifire: subscriptionData.first?.productId ?? "", productServerID: subscriptionData.first?.id ?? "")
            self.appMode = appMode
           
        } else if isQuickApp && appMode == .free {
//            self.downgradePopupView.isHidden = false
        } else if appMode != .free || Defaults.shared.releaseType != .beta {
            self.present(objAlert, animated: true, completion: nil)
        }
    }
    
    func callSubscriptionApi(appMode: AppMode, code: String, successMessage: String?) {
        ProManagerApi.setSubscription(type: appMode.getType, code: code).request(Result<User>.self).subscribe(onNext: { (response) in
            self.dismissHUD()
            if response.status == ResponseType.success {
                Defaults.shared.isSubscriptionApiCalled = false
                Defaults.shared.currentUser = response.result
                CurrentUser.shared.setActiveUser(response.result)
                SubscriptionSettings.storySettings[0].settings[appMode.rawValue].selected = true
                AppEventBus.post("changeMode")
                self.navigationController?.popViewController(animated: true)
                //Utils.appDelegate?.window?.makeToast(successMessage)
                Utils.appDelegate?.window?.currentController?.showAlert(alertMessage: successMessage ?? "")
            } else {
                Defaults.shared.isSubscriptionApiCalled = false
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            Defaults.shared.isSubscriptionApiCalled = false
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
        
    }
    
}

extension SubscriptionsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.subscriptionType.features.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.subscriptionFeatureCell.identifier) as? SubscriptionFeatureTableViewCell else { return UITableViewCell() }
        cell.setData(description: self.subscriptionType.features[indexPath.row])
        return cell
    }
    
}

// MARK: - Purchase Product Method
extension SubscriptionsViewController {
    
    internal func purchaseProduct(productIdentifire: String, productServerID: String) {
        print("PurchaseHelper.shared.iapProducts\(PurchaseHelper.shared.iapProducts)")
        print("productIdentifire\(productIdentifire)")
        guard let selectedProduct = PurchaseHelper.shared.iapProducts.filter({$0.productIdentifier == productIdentifire}).first else {
            Defaults.shared.isSubscriptionApiCalled = false
            return
        }
        self.showHUD()
        appDelegate?.isSubscriptionButtonPressed = true
        PurchaseHelper.shared.purchaseProduct(product: selectedProduct, productid: productServerID) { (expired, error, isUserCancelled) in
            if let error = error {
                if !isUserCancelled {
                    Defaults.shared.isSubscriptionApiCalled = false
                    self.showAlert(alertMessage: error.localizedDescription)
                    self.dismissHUD()
                } else {
                    Defaults.shared.isSubscriptionApiCalled = false
                    self.dismissHUD()
                }
            } else {
                Defaults.shared.isSubscriptionApiCalled = false
                self.dismissHUD()
            }
        }
    }
    
    func bindViewModel(appMode: AppMode) {
        self.viewModel.subscriptionResponseMsg.bind { [weak self] (message, isSuccess) in
            guard let `self` = self else { return }
            
            self.syncUserModel { _ in

            self.dismissHUD()
            if isSuccess {
                let user = Defaults.shared.currentUser
                user?.subscriptionStatus = appMode.getType
                user?.isTempSubscription = false
               // Defaults.shared.currentUser = user
                Defaults.shared.isSubscriptionApiCalled = false
                Defaults.shared.isDowngradeSubscription = false
                SubscriptionSettings.storySettings[0].settings[appMode.rawValue].selected = true
                AppEventBus.post("changeMode")
                switch self.subscriptionType {
                case .free:
                    self.thankYouSubscriptionTypeLabel.text = "Enjoy using the Free features to create fun and engaging content!"
//                    self.thankYouSubscriptionTitleLabel.text = "Thank you for your Free Subscription"
                    self.thankYouSubscriptionBadgeLabel.text = "You have been awarded the\nFree Subscription Badge!"
                    let firstColor = UIColor.init(hexString: "C3C3C3")
                    self.thankYouiPhoneLabel.textColor = firstColor
                    self.thankYouSubscriptionTypeBadgeBGImageView.image = R.image.badgeIphoneTrial()
                    self.thankYouSubscriptionTypeAppleIconImageView.image = R.image.freeAppleIcon()
                case .basic:
                    self.thankYouSubscriptionTypeLabel.text = "Enjoy using the Basic features to create fun and engaging content!"
//                    self.thankYouSubscriptionTitleLabel.text = "Thank you for your Basic Subscription"
                    self.thankYouSubscriptionBadgeLabel.text = "You have been awarded the\nBasic Subscription Badge!"
                    let firstColor = UIColor.init(hexString: "FDE774")
                    self.thankYouiPhoneLabel.textColor = firstColor
                    self.thankYouSubscriptionTypeBadgeBGImageView.image = R.image.badgeIphoneBasic()
                    self.thankYouSubscriptionTypeAppleIconImageView.image = R.image.basicAppleIcon()
                case .advanced:
                    self.thankYouSubscriptionTypeLabel.text = "Enjoy using the Advanced features to create fun and engaging content!"
//                    self.thankYouSubscriptionTitleLabel.text = "Thank you for your Advance Subscription"
                    self.thankYouSubscriptionBadgeLabel.text = "You have been awarded the\nAdvanced Subscription Badge!"
                    let firstColor = UIColor.init(hexString: "77C159")
                    self.thankYouiPhoneLabel.textColor = firstColor
                    self.thankYouSubscriptionTypeBadgeBGImageView.image = R.image.badgeIphoneAdvance()
                    self.thankYouSubscriptionTypeAppleIconImageView.image = R.image.advancedAppleIcon()
                case .professional:
                    self.thankYouSubscriptionTypeLabel.text = "Enjoy using the Premium features to create fun and engaging content!"
//                    self.thankYouSubscriptionTitleLabel.text = "Thank you for your Premium Subscription"
                    self.thankYouSubscriptionBadgeLabel.text = "You have been awarded the\nPremium Subscription Badge!"
                    let firstColor = UIColor.init(hexString: "4D83D4")
                    self.thankYouiPhoneLabel.textColor = firstColor
                    self.thankYouSubscriptionTypeBadgeBGImageView.image = R.image.badgeIphonePre()
                    self.thankYouSubscriptionTypeAppleIconImageView.image = R.image.preAppleIcon()
//                default:
//                    break
                }
                self.thankYouViewSubScription.isHidden = false
                
//                Utils.appDelegate?.window?.currentController?.showAlert(alertMessage: R.string.localizable.basicLiteModeIsEnabled())
            }

//            self.showAlert(alertMessage: message)
            
            }
        }
        
        self.viewModel.subscriptionError.bind { [weak self] (message) in
            guard let `self` = self else { return }
            self.dismissHUD()
            self.showAlert(alertMessage: message)
        }
    }
    
    func syncUserModel(completion: @escaping (_ isCompleted: Bool?) -> Void) {
        //print("***syncUserModel***")
        ProManagerApi.userSync.request(Result<UserSyncModel>.self).subscribe(onNext: { (response) in
            if response.status == ResponseType.success {
                //print("***userSync***\(response)")
                Defaults.shared.currentUser = response.result?.user
                Defaults.shared.userSubscription = response.result?.userSubscription
                Defaults.shared.numberOfFreeTrialDays = response.result?.diffDays
                Defaults.shared.userCreatedDate = response.result?.user?.created
                Defaults.shared.isDowngradeSubscription = response.result?.userSubscription?.isDowngraded
                Defaults.shared.isFreeTrial = response.result?.user?.isTempSubscription
                Defaults.shared.allowFullAccess = response.result?.userSubscription?.allowFullAccess
                Defaults.shared.subscriptionType = response.result?.userSubscription?.subscriptionType
                Defaults.shared.socialPlatforms = response.result?.user?.socialPlatforms
                Defaults.shared.referredUserCreatedDate = response.result?.user?.refferedBy?.created
                Defaults.shared.publicDisplayName = response.result?.user?.publicDisplayName
                Defaults.shared.emailAddress = response.result?.user?.email
                Defaults.shared.privateDisplayName = response.result?.user?.privateDisplayName
                if let isAllowAffiliate = response.result?.user?.isAllowAffiliate {
                    Defaults.shared.isAffiliateLinkActivated = isAllowAffiliate
                }
                Defaults.shared.referredByData = response.result?.user?.refferedBy
                self.setAppModeBasedOnUserSync()
                completion(true)
            }
        }, onError: { error in
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }

    func setAppModeBasedOnUserSync(){
       //   Defaults.shared.allowFullAccess = true
            if Defaults.shared.allowFullAccess ?? false == true{
                Defaults.shared.appMode = .professional
            }else if (Defaults.shared.subscriptionType == "trial"){
                if (Defaults.shared.numberOfFreeTrialDays ?? 0 > 0){
                    Defaults.shared.appMode = .professional
                }else {
                    Defaults.shared.appMode = .free
                }
            }else if(Defaults.shared.subscriptionType == "basic")
            {
                if(Defaults.shared.isDowngradeSubscription ?? false == true){
                    if (Defaults.shared.numberOfFreeTrialDays ?? 0 > 0){
                        Defaults.shared.appMode = .basic
                    }else {
                        Defaults.shared.appMode = .free
                    }
                }else{
                    Defaults.shared.appMode = .basic
                }
            }else if(Defaults.shared.subscriptionType == "advance")
            {
                if(Defaults.shared.isDowngradeSubscription ?? false == true){
                    if (Defaults.shared.numberOfFreeTrialDays ?? 0 > 0){
                        Defaults.shared.appMode = .advanced
                    }else {
                        Defaults.shared.appMode = .free
                    }
                }else{
                    Defaults.shared.appMode = .advanced
                }
            }else if(Defaults.shared.subscriptionType == "pro")
            {
                if(Defaults.shared.isDowngradeSubscription ?? false == true){
                    if (Defaults.shared.numberOfFreeTrialDays ?? 0 > 0){
                        Defaults.shared.appMode = .professional
                    }else {
                        Defaults.shared.appMode = .free
                    }
                }else{
                    Defaults.shared.appMode = .professional
                }
            }else{
                Defaults.shared.appMode = .free
            }
/*
         if(allowFullAccess){
              Allow access to premium content
         }else if(isTempSubscription){
             if(diffDays > 0){
              Allow access to premium content
              }else{
              Free trial expired
              }
         }else if(subscriptions.android.currentStatus === 'basic'){
             if(userSubscription.isDowngraded){
                 if(diffDays > 0){
                    Allow access to premium content
                   }else{
                    Subscription is expired
                   }

             }else{
              Allow access to premium content
             }
         }else{
           User does not have any active subscriptions
         }
         */
        }
    
    func setupForFreeTrial(isFreeTrial: Bool) {
        return
//        expiryDateHeightConstraint.constant = isFreeTrial ? 48 : 0
//        lblFreeTrial.isHidden = !isFreeTrial
    }
    
    func downgradeSubscription(_ subscriptionId: String) {
        ProManagerApi.downgradeSubscription(subscriptionId: subscriptionId).request(Result<EmptyModel>.self).subscribe(onNext: { (response) in
            if response.status == ResponseType.success {
                Defaults.shared.isSubscriptionApiCalled = false
                Defaults.shared.isDowngradeSubscription = true
                self.navigationController?.popViewController(animated: true)
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            } else {
                Defaults.shared.isSubscriptionApiCalled = false
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            Defaults.shared.isSubscriptionApiCalled = false
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
    
}

extension SubscriptionsViewController {
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
                    return "Your 7-Day Premium Free Trial has ended. Upgrade Now!."
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
                        return "Your 7-Day Premium Free Trial has ended. Your access level is now Basic. Upgrade to Advanced or Premium available soon!"
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
            return "Your 7-Day Premium Free Trial has  ended. Please upgrade now to resume using the Basic, Advanced or Premium subscription features.\nTime since signing up:"
        }
        else if subscriptionType ==  SubscriptionTypeForBadge.EXPIRE.rawValue  {
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

extension SubscriptionsViewController {
    
    func setupMessage() {
        UserSync.shared.getMessages(screen: "subscription-details") { messageData in
            let messsgeData: [MessageData] = messageData?.data ?? []
            if let messageDataObj =  messsgeData.first, let messageObj = messageDataObj.messages?.first {
                let aData: [String] = messageObj.a ?? []
                let bData: [String] = messageObj.b ?? []
                let cData: [String] = messageObj.c ?? []
                
                let astr = aData.joined(separator: "\n")
                let bstr = bData.joined(separator: "\n")
                let cstr = cData.joined(separator: "\n")
                print("\(astr)--\(bstr)---\(cstr)")
                
                
                self.messageLabel.text = astr + bstr + "\n" + cstr
                if self.messageLabel.text?.trimStr() == "" {
                    self.messageLabel.isHidden = true
                }
            }
        }

    }
}
