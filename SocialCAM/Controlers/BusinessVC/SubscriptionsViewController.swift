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
    @IBOutlet weak var thankYouSubscriptionTypeLabel: UILabel!
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
        lblBadgeRemainingDays.text = ""
        if subscriptionType == .basic {
            bindViewModel(appMode: appMode ?? .basic)
            lblPrice.text = "Early-Bird Special Price: $1.99/month"
            subScriptionTypeLabel.text = "Basic"
            if (Defaults.shared.subscriptionType?.lowercased() == "basic"){
                planActiveView.isHidden = false
            }
        }
        else if subscriptionType == .advanced {
            bindViewModel(appMode: appMode ?? .basic)
            lblPrice.text = "Early-Bird Special Price: $2.99/month"
            subScriptionTypeLabel.text = "Advanced"
            if (Defaults.shared.subscriptionType?.lowercased() == "advance"){
                planActiveView.isHidden = false
            }
        }
        else if subscriptionType == .professional {
            bindViewModel(appMode: appMode ?? .basic)
            lblPrice.text = "Early-Bird Special Price: $4.99/month"
            subScriptionTypeLabel.text = "Premium"
            if (Defaults.shared.subscriptionType?.lowercased() == "pro"){
                planActiveView.isHidden = false
            }
        }else{
            lblPrice.text = "Free:  $0/month \n No subscription required"
            subScriptionTypeLabel.text = "Free"
            if (Defaults.shared.subscriptionType?.lowercased() == "trial"){
               
                let numberOfFreeTrialDays = Defaults.shared.numberOfFreeTrialDays ?? 0
                lblBadgeRemainingDays.text = numberOfFreeTrialDays > 0 ? "\(numberOfFreeTrialDays)" : ""
                planActiveView.isHidden = false
                //Your 7-day free trial is over. Subscribe now to continue using the Basic, Advanced or Premium features.
            }
        }
//        if Defaults.shared.allowFullAccess == true {
//            btnUpgrade.isUserInteractionEnabled = false
//            expiryDateHeightConstraint.constant = 0
//            lblPrice.isHidden = true
//        }
        
        setSubscriptionBadgeDetails()
        tapGestureSetUp()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationBarView.addBottomShadow()
        bottomView.addShadow(location: .top)
    }
    
    func tapGestureSetUp() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapThankYouView))
        tapGesture.numberOfTapsRequired = 1
        self.thankYouViewSubScription.addGestureRecognizer(tapGesture)
    }
    
   @objc func didTapThankYouView(sender: UITapGestureRecognizer)  {
        self.thankYouViewSubScription.isHidden = true
    }
    
    func setupView() {
        switch appMode {
        case .professional:
            days7TrialTitleLabel.isHidden = true
            days7TrialSubTitleLabel.isHidden = true
            pic2ArtTitleLabel.isHidden = false
            pic2ArtSubTitleLabel.isHidden = false
            subScriptionTypeLabel.text = "Premium"
            subScriptionTypeLabel.textColor = UIColor.init(hexString: "5092D0")
            subScriptionBadgeImageView.image = R.image.priBadgeBG()
            appleIconImageView.image = R.image.preAppleIcon()
            let firstColor = UIColor.init(hexString: "4D83D4")
            let secondColor = UIColor.init(hexString: "92C5F4")
            monthlyPriceView.applyGradient(isVertical: false, colorArray: [firstColor, secondColor])
            upGradeButtonView.backgroundColor = firstColor
            yourPlanActiveLabel.textColor = firstColor
            planActiveView.isHidden = true
            upGradeButtonView.isHidden = false
            quickCamModeSubTitles.text = "-  Record in 2x, 3x, 4x and 5x fast motion\n-  Record in -2x, -3x, -4x and -5x slow motion\n-  Zoom in and out\n-  Record in normal speed\n-  Record up to 3 minutes\n- Save Mode"
            pic2ArtSubTitleLabel.text = "- 44 Pic2Art filters\n- Pic2Art Photo Editor"
            videoEditorSubTitlesLabel.text = "- Edit existing videos, up to 5 min\n- Edit up to 20 segments\n- Bitmoji integration\n- Trim, Cut & Crop\n- Watermarks\n- Referral link\n- Share on all supported social media"
            mobileDashboardSubTitlesLabel.text = "- Referral Duplication System\n- Custom Referral page for affiliates\n- Referral Wizard with Text and Email Inviter\n- QR Code Profile Badge\n- iPhone Premium Subscriber Badge"
            businessDashboardSubTitleLabel.text = "-  Free while in Beta\n- Automated email inviter\n- Custom Referral pages\n- Referral Commissions"
            
            //"- Referral Duplication System\n- Custom Referral page for affiliates\n- Referral Wizard with Text and Email Inviter\n- QR Code Profile Badge\n- iPhone Premium Subscriber Badge Business Dashboard (Web access)"
        case .advanced:
            pic2ArtTitleLabel.isHidden = false
            pic2ArtSubTitleLabel.isHidden = false
            days7TrialTitleLabel.isHidden = true
            days7TrialSubTitleLabel.isHidden = true
            subScriptionTypeLabel.text = "Advanced"
            subScriptionBadgeImageView.image = R.image.advBadgeBG()
            appleIconImageView.image = R.image.advancedAppleIcon()
            subScriptionTypeLabel.textColor = UIColor.init(hexString: "77C159")
            let firstColor = UIColor.init(hexString: "77C159")
            let secondColor = UIColor.init(hexString: "BADDAB")
            upGradeButtonView.backgroundColor = firstColor
            yourPlanActiveLabel.textColor = firstColor
            planActiveView.isHidden = true
            upGradeButtonView.isHidden = false
            monthlyPriceView.applyGradient(isVertical: false, colorArray: [firstColor, secondColor])
            quickCamModeSubTitles.text = "-  Record in 2x, 3x and 4x fast motion\n-  Record in -2x, -3x and -4x slow motion\n-  Zoom in and out\n-  Record in normal speed\n-  Record up to 2 minutes\n- Save Mode"
            pic2ArtSubTitleLabel.text = "- 44 Pic2Art filters\n- Pic2Art Photo Editor"
            videoEditorSubTitlesLabel.text = "- Edit existing videos, up to 2 minutes\n- Bitmoji integration\n- Trim, Cut & Crop\n- Watermarks\n- Referral link\n- Share on all supported social media"
            mobileDashboardSubTitlesLabel.text = "- Referral Duplication System\n- Custom Referral page for affiliates\n- Referral Wizard with Text and Email Inviter\n- QR Code Profile Badge\n- iPhone Advanced Subscriber Badge"
            businessDashboardSubTitleLabel.text = "-  Free while in Beta\n- Automated email inviter\n- Custom Referral pages\n- Referral Commissions"
        case .basic:
            subScriptionTypeLabel.text = "Basic"
            subScriptionTypeLabel.textColor = UIColor.init(hexString: "EAB140")
            subScriptionBadgeImageView.image = R.image.basicBadgeBG()
            appleIconImageView.image = R.image.basicAppleIcon()
            
            let firstColor = UIColor.init(hexString: "FDE774")
            let secondColor = UIColor.init(hexString: "FDDC66")
            //DCAF54
            planActiveView.isHidden = true
            upGradeButtonView.isHidden = false
            upGradeButtonView.backgroundColor = firstColor
            yourPlanActiveLabel.textColor =  UIColor.init(hexString: "DCAF54")
            monthlyPriceView.applyGradient(isVertical: false, colorArray: [firstColor, secondColor])
            pic2ArtTitleLabel.isHidden = true
            pic2ArtSubTitleLabel.isHidden = true
            days7TrialTitleLabel.isHidden = true
            days7TrialSubTitleLabel.isHidden = true
            quickCamModeSubTitles.text = "-  Record in 2x and 3x fast motion\n-  Record in -2x and -3x slow motion\n-  Zoom in and out\n-  Record in normal speed\n-  Record up to 1 minute"
            videoEditorSubTitlesLabel.text = "- Edit existing videos, up to 1 minutes\n- Bitmoji integration\n- Trim, Cut & Crop\n- Watermarks\n- Referral link\n- Share on all supported social media"
            mobileDashboardSubTitlesLabel.text = "- Referral Duplication System\n- Custom Referral page for affiliates\n- Referral Wizard with Text and Email Inviter\n- QR Code Profile Badge\n- iPhone Basic Subscriber Badge"
            businessDashboardSubTitleLabel.text = "-  Free while in Beta\n- Automated email inviter\n- Custom Referral pages\n- Referral Commissions"
        case .free:
            pic2ArtTitleLabel.isHidden = true
            pic2ArtSubTitleLabel.isHidden = true
            days7TrialTitleLabel.isHidden = false
            days7TrialSubTitleLabel.isHidden = false
            subScriptionTypeLabel.text = "Free"
            subScriptionTypeLabel.textColor = UIColor.init(hexString: "000000")
            subScriptionBadgeImageView.image = R.image.freeBadgeBG()
            appleIconImageView.image = R.image.freeAppleIcon()
            let firstColor = UIColor.init(hexString: "C3C3C3")
            let secondColor = UIColor.init(hexString: "D7D7D7")
            upGradeButtonView.backgroundColor = firstColor
            yourPlanActiveLabel.textColor = firstColor
            planActiveView.isHidden = true
            upGradeButtonView.isHidden = false
            monthlyPriceView.applyGradient(isVertical: false, colorArray: [firstColor, secondColor])
            days7TrialSubTitleLabel.text = "-  Access to all Premium Features\n-  No credit card required"
            
            quickCamModeSubTitles.text = "-  Record in 2x and 3x fast motion\n-  Record in -2x and -3x slow motion\n-  Zoom in and out\n-  Record in normal speed\n-  Record up to 1 minute"
            
            videoEditorSubTitlesLabel.text = "- Edit existing videos, up to 1 minutes\n- Bitmoji integration\n- Trim, Cut & Crop\n- Watermarks\n- Referral link\n- Share on all supported social media"
            
            mobileDashboardSubTitlesLabel.text = "- Referral Duplication System\n- Custom Referral page for affiliates\n- Referral Wizard with Text and Email Inviter\n- QR Code Profile Badge"
            
            businessDashboardSubTitleLabel.text = "-  Free while in Beta\n- Automated email inviter\n- Custom Referral pages\n- Referral Commissions"
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
            navigationController?.popViewController(animated: true)
        }
         else if Defaults.shared.appMode != self.subscriptionType || isFreeTrialMode || (Defaults.shared.isDowngradeSubscription == true && Defaults.shared.appMode != .free) {
            Defaults.shared.isSubscriptionApiCalled = true
            self.enableMode(appMode: self.subscriptionType)
        }
    }
    
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnOkayTapped(_ sender: UIButton) {
        self.thankYouViewSubScription.isHidden = true
        self.navigationController?.popToRootViewController(animated: true)
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
     
        if (Defaults.shared.subscriptionType?.lowercased() == "basic") || (Defaults.shared.subscriptionType?.lowercased() == "advance") || (Defaults.shared.subscriptionType?.lowercased() == "pro"){
             upGradeButtonView.isHidden = true
        }
        if appMode == .free{
            upGradeButtonView.isHidden = true
        }
        if subscriptionType == .free {
            if planActiveView.isHidden {
                upGradeButtonView.isHidden = false
            }
        }
    }
    func setSubscriptionBadgeDetails(){
//        lblBadgeRemainingDays.text =  ""
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
                    if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                        if finalDay == "7" {
                            lblPrice.text = "Today is the last day of your 7-day free trial. Upgrade now to access these features"
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
                            }
                           
                        }
                    } else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
                        subScriptionBadgeImageView.image = R.image.squareBadge()
                        lblPrice.text = "Your 7-day free trial is over. Subscribe now to continue using the Basic, Advanced or Premium features."
                    }else{
                        lblPrice.text = ""
                    }
                }
            }
        }
        appleLogoCenterY.constant = (lblBadgeRemainingDays.text ?? "").trim.isEmpty ? 6 : -8
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
                    self.view.makeToast(R.string.localizable.pleaseEnterValidCode())
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
                    self.thankYouSubscriptionTypeLabel.text = "Your Free Badge"
                    let firstColor = UIColor.init(hexString: "C3C3C3")
                    self.thankYouiPhoneLabel.textColor = firstColor
                    self.thankYouSubscriptionTypeBadgeBGImageView.image = R.image.freeBadgeBG()
                    self.thankYouSubscriptionTypeAppleIconImageView.image = R.image.freeAppleIcon()
                case .basic:
                    self.thankYouSubscriptionTypeLabel.text = "Your Basic Badge"
                    let firstColor = UIColor.init(hexString: "FDE774")
                    self.thankYouiPhoneLabel.textColor = firstColor
                    self.thankYouSubscriptionTypeBadgeBGImageView.image = R.image.basicBadgeBG()
                    self.thankYouSubscriptionTypeAppleIconImageView.image = R.image.basicAppleIcon()
                case .advanced:
                    self.thankYouSubscriptionTypeLabel.text = "Your Advanced Badge"
                    let firstColor = UIColor.init(hexString: "77C159")
                    self.thankYouiPhoneLabel.textColor = firstColor
                    self.thankYouSubscriptionTypeBadgeBGImageView.image = R.image.advBadgeBG()
                    self.thankYouSubscriptionTypeAppleIconImageView.image = R.image.advancedAppleIcon()
                case .professional:
                    self.thankYouSubscriptionTypeLabel.text = "Your Premium Badge"
                    let firstColor = UIColor.init(hexString: "4D83D4")
                    self.thankYouiPhoneLabel.textColor = firstColor
                    self.thankYouSubscriptionTypeBadgeBGImageView.image = R.image.priBadgeBG()
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
