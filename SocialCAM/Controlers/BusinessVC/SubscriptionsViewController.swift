//
//  SubscriptionsViewController.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 10/11/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit

class SubscriptionsViewController: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var btnUpgrade: UIButton!
    @IBOutlet weak var lblYourCurrentPlan: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var freeModeAlertView: UIView!
    @IBOutlet weak var freeModeAlertBlurView: UIVisualEffectView!
    @IBOutlet weak var lblExpiryDate: UILabel!
    @IBOutlet weak var lblFreeTrial: UILabel!
    @IBOutlet weak var expiryDateHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var downgradePopupView: UIView!
    
    @IBOutlet weak var cancelSubscriptionPopupView: UIView!
    @IBOutlet weak var lblcancelSubscriptionPopupTitle: UILabel!
    @IBOutlet weak var cancelConfirmedPopupView: UIView!
    @IBOutlet weak var lblcancelConfirmedPopupTitle: UILabel!
    @IBOutlet weak var lblpriceTitle: UILabel!
    
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
    var cancelInProgressSubscriptionType:AppMode = .free
    
    var cancelAPItimer = Timer()
    var cancelAPItimerIteration:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.getPackageList()
        setupUI()
        let notificationCenter = NotificationCenter.default
                notificationCenter.addObserver(self, selector:#selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
   
//        if Defaults.shared.allowFullAccess == true {
//            btnUpgrade.isUserInteractionEnabled = false
//            expiryDateHeightConstraint.constant = 0
//            lblFreeTrial.isHidden = true
//        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        
    }
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func appMovedToForeground() {
        if self.cancelInProgressSubscriptionType == self.subscriptionType || self.subscriptionType == .free{
            cancelAPItimer = Timer.scheduledTimer(timeInterval:5.0, target: self, selector: #selector(cancelAPItimerAction), userInfo: nil, repeats: true)
            callCancelSubscriptionApi()
        }
    }
    @objc func cancelAPItimerAction() {
        cancelAPItimerIteration += 1
        if cancelAPItimerIteration > 4{
            cancelAPItimer.invalidate()
            return
        }
        callCancelSubscriptionApi()
    }
    @IBAction func btnUpgradeTapped(_ sender: Any) {
        if Defaults.shared.appMode != self.subscriptionType || isFreeTrialMode || (Defaults.shared.isDowngradeSubscription == true && Defaults.shared.appMode != .free) {
            Defaults.shared.isSubscriptionApiCalled = true
            self.enableMode(appMode: self.subscriptionType)
        }
    }
    
    @IBAction func btnOkayTapped(_ sender: UIButton) {
        freeModeAlertBlurView.isHidden = true
        freeModeAlertView.isHidden = true
        Defaults.shared.isSubscriptionApiCalled = false
    }
    
    @IBAction func btnCancelPopupTapped(_ sender: UIButton) {
        self.downgradePopupView.isHidden = true
        Defaults.shared.isSubscriptionApiCalled = false
    }
    
    @IBAction func btnOkDowngradeTapped(_ sender: UIButton) {
        self.downgradePopupView.isHidden = true
        if Defaults.shared.releaseType == .store {
           openAppleCancelSubscriptionScreen()
        } else {
            if let subscriptionId = Defaults.shared.subscriptionId {
                self.downgradeSubscription(subscriptionId)
            } else {
                Defaults.shared.isSubscriptionApiCalled = false
            }
        }
    }
    
    private func setupUI() {
        let subscriptionData = subscriptionsList.filter({$0.productId == Constant.IAPProductIds.quickCamLiteBasic})
        if let currentUser = Defaults.shared.currentUser {
            lblExpiryDate.text = R.string.localizable.expiryDaysLeft("\(Defaults.shared.numberOfFreeTrialDays ?? 0)")
            //if currentUser.isTempSubscription ?? false && subscriptionType != .free && Defaults.shared.appMode != .free {
            if (Defaults.shared.subscriptionType == "trial") && subscriptionType != .free && Defaults.shared.appMode != .free {
                isFreeTrialMode = true
                setupForFreeTrial(isFreeTrial: true)
            } else if Defaults.shared.isDowngradeSubscription == true && subscriptionType != .free && Defaults.shared.appMode != .free {
//                lblYourCurrentPlan.isHidden = false
                setupForFreeTrial(isFreeTrial: false)
                expiryDateHeightConstraint.constant = 48
            } else {
                setupForFreeTrial(isFreeTrial: false)
                if Defaults.shared.numberOfFreeTrialDays != 0 && subscriptionType != .free && Defaults.shared.appMode != .free {
                    expiryDateHeightConstraint.constant = 48
                }
            }
            //if (currentUser.isTempSubscription == true && subscriptionType == .free) || (Defaults.shared.isDowngradeSubscription == true && subscriptionType == .free) {
            if ((Defaults.shared.subscriptionType == "trial") && subscriptionType == .free) || (Defaults.shared.isDowngradeSubscription == true && subscriptionType == .free) {
                btnUpgrade.isHidden = true
            }
        }
        self.lblTitle.text = self.subscriptionType.description
        DispatchQueue.main.async {
            if let price = subscriptionData.first?.price,
               price == 1.99 {
                self.lblPrice.text = (self.subscriptionType != .free) ? "$\(price)/Month" : self.subscriptionType.price
            } else {
                self.lblPrice.text = self.subscriptionType.price
            }
            self.expiryDateHeightConstraint.constant = 48
        }
        
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
                btnUpgrade.setTitle(R.string.localizable.upgradeNow(), for: .normal)
                btnUpgrade.backgroundColor = R.color.appPrimaryColor()
            } else {
                btnUpgrade.setTitle(isFreeTrialMode ? R.string.localizable.upgradeNow() : R.string.localizable.yourCurrentPlan(), for: .normal)
                btnUpgrade.backgroundColor = isFreeTrialMode ? R.color.appPrimaryColor() : R.color.currentPlanButtonColor()
                btnUpgrade.isHidden = !isFreeTrialMode
                lblYourCurrentPlan.isHidden = isFreeTrialMode
                if !isFreeTrialMode {
                    btnUpgrade.titleLabel?.font = R.font.sfuiTextRegular(size: 20)
                }
            }
        } else {
            self.setDowngradeButton()
        }
        Defaults.shared.subscriptionId = subscriptionData.first?.id ?? ""
        if subscriptionType == .free {
            btnUpgrade.isHidden = true
        }
        
        
        //for setting current plan label and top text
        lblYourCurrentPlan.isHidden = true
        if subscriptionType == .basic {
            bindViewModel(appMode: appMode ?? .basic)
            lblpriceTitle.text = "Introductory Price  | $1.99/month (3 months) \n Regular Price  | $2.99/month (after 3 months)"
            lblFreeTrial.text = "Basic"
            if (Defaults.shared.subscriptionType?.lowercased() == "basic"){
                lblYourCurrentPlan.isHidden = false
            }
        }else if subscriptionType == .advanced {
            bindViewModel(appMode: appMode ?? .basic)
            lblpriceTitle.text = "Regular Price  | $2.99/month"
            lblFreeTrial.text = "Advance"
            if (Defaults.shared.subscriptionType?.lowercased() == "advance"){
                lblYourCurrentPlan.isHidden = false
            }
        }else if subscriptionType == .professional {
            bindViewModel(appMode: appMode ?? .basic)
            lblpriceTitle.text = "\n Regular Price  | $4.99/month"
            lblFreeTrial.text = "Pro"
            if (Defaults.shared.subscriptionType?.lowercased() == "pro"){
                lblYourCurrentPlan.isHidden = false
            }
        }else{
            lblpriceTitle.text = "Free | $0/month \n No subscription required"
            lblFreeTrial.text = "Free"
            if (Defaults.shared.subscriptionType?.lowercased() == "trial"){
               lblYourCurrentPlan.isHidden = false
            }
        }
      
        btnUpgrade.isHidden = !lblYourCurrentPlan.isHidden //if lable is visible, button will be hidden
    }
    
    private func setDowngradeButton() {
        if Defaults.shared.numberOfFreeTrialDays ?? 0 > 0 {
            return
        } else {
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
            btnUpgrade.setTitle(R.string.localizable.downgrade(), for: .normal)
        }
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
                freeModeAlertBlurView.isHidden = false
                freeModeAlertView.isHidden = false
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
        if isQuickApp && (self.subscriptionType != Defaults.shared.appMode) && Defaults.shared.numberOfFreeTrialDays ?? 0 == 0 //&& Defaults.shared.appMode != .free  && appMode != .free
        {
            print(appMode)
            print(self.subscriptionType)
            print(Defaults.shared.appMode)
            self.setCancelSubscriptionPopup(subsriptionType: self.subscriptionType)
            self.cancelSubscriptionPopupView.isHidden = false
          
        }else  if isQuickApp && appMode == .free && Defaults.shared.appMode == .free{
            print(appMode)
            return
        }else if isQuickApp{
            
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
            self.downgradePopupView.isHidden = false
        } else if appMode != .free || Defaults.shared.releaseType != .beta {
            self.present(objAlert, animated: true, completion: nil)
        }
    }
    func openAppleCancelSubscriptionScreen(){
        guard let url = URL(string: Constant.SubscriptionUrl.cancelSubscriptionUrl) else {
            return
        }
        UIApplication.shared.open(url)
    }
    func callCancelSubscriptionApi() {
        showHUD()
        
        ProManagerApi.cancelledSubscriptions.request(Result<CancelSubscriptionModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            if response.status == ResponseType.success {
                self.dismissHUD()
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = true
                    if self.subscriptionType == .free{
                        return
                    }
                    self.setCancelSubscriptionConfirmPopup(subsriptionType: self.subscriptionType)
                    Defaults.shared.appMode = .free // because all subscriptions have been cancelled
                    self.cancelConfirmedPopupView.isHidden = false
                    self.view.isUserInteractionEnabled = true
                    if self.subscriptionType != .free{
                      //  self.enableMode(appMode:self.subscriptionType)
                    }
                   
                }
                self.cancelAPItimer.invalidate()
            } else {
                if self.cancelAPItimerIteration == 4{
                    self.dismissHUD()
                 
                    Utils.appDelegate?.window?.currentController?.showAlert(alertMessage: "It seems you have not cancelled subscription from Apple store. Please try again later. ")
                    self.view.isUserInteractionEnabled = true
                    Defaults.shared.isSubscriptionApiCalled = false
                }
               
            }
        }, onError: { error in
            
            if self.cancelAPItimerIteration == 4{
                self.dismissHUD()
                
                Utils.appDelegate?.window?.currentController?.showAlert(alertMessage: "It seems you have not cancelled subscription from Apple store. Please try again later. ")
                self.view.isUserInteractionEnabled = true
                Defaults.shared.isSubscriptionApiCalled = false
            }
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
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
    @IBAction func cancelSubscriptionPopupCancelClick(_ sender: UIButton) {
        self.cancelSubscriptionPopupView.isHidden = true
    }
    @IBAction func cancelSubscriptionPopupContinueClick(_ sender: UIButton) {
        self.cancelSubscriptionPopupView.isHidden = true
        if Defaults.shared.releaseType != .store {
            guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else {
                return
            }
            self.cancelInProgressSubscriptionType = Defaults.shared.appMode
            UIApplication.shared.open(url)
            
        } else {
            if let subscriptionId = Defaults.shared.subscriptionId {
                self.downgradeSubscription(subscriptionId)
            } else {
                Defaults.shared.isSubscriptionApiCalled = false
            }
        }
    }
    @IBAction func cancelSubscriptionConfirmPopupContinueClick(_ sender: UIButton) {
        self.cancelConfirmedPopupView.isHidden = true
        if self.subscriptionType != .free{
            self.enableMode(appMode:self.subscriptionType)
        }
    }
    func setCancelSubscriptionPopup(subsriptionType:AppMode){
        var upgradeStr = "Upgrading"
        var currentsubscription = "Basic"
        if Defaults.shared.appMode == .basic {
            currentsubscription = "Basic"
        }else if Defaults.shared.appMode == .advanced{
            currentsubscription = "Advanced"
        }else if Defaults.shared.appMode == .professional{
            currentsubscription = "Pro"
        }
        var subsriptiontype = "Basic"
        if subsriptionType == .basic{
            subsriptiontype = "Basic"
        }else if subsriptionType == .advanced{
            subsriptiontype = "Advanced"
        }else if subsriptionType == .professional{
            subsriptiontype = "Pro"
        }
        
        if (currentsubscription == "Advanced" && subsriptiontype == "Basic") || (currentsubscription == "Pro" && subsriptiontype == "Basic") || (currentsubscription == "Pro" && subsriptiontype == "Advanced") || subsriptionType == .free{
            upgradeStr = "Downgrading"
        }
        
        if subsriptionType == .free{
            self.lblcancelSubscriptionPopupTitle.text = "You are \(upgradeStr) from \(currentsubscription) to \(subsriptiontype)."
        }else{
            self.lblcancelSubscriptionPopupTitle.text = "\(upgradeStr) from \(currentsubscription) to \(subsriptiontype) requires that you first cancel your \(currentsubscription) subscription then subscribe to \(subsriptiontype)."
        }
        
        
        
    }
    func setCancelSubscriptionConfirmPopup(subsriptionType:AppMode){
        var currentsubscription = "Basic"
        if Defaults.shared.appMode == .basic {
            currentsubscription = "Basic"
        }else if Defaults.shared.appMode == .advanced{
            currentsubscription = "Advanced"
        }else if Defaults.shared.appMode == .professional{
            currentsubscription = "Pro"
        }
        var subsriptiontype = "Basic"
        if subsriptionType == .basic{
            subsriptiontype = "Basic"
        }else if subsriptionType == .advanced{
            subsriptiontype = "Advanced"
        }else if subsriptionType == .professional{
            subsriptiontype = "Pro"
        }
        
        
        self.lblcancelConfirmedPopupTitle.text = "Your \(currentsubscription) has been cancelled and your account is ready to be upgraded to \(subsriptiontype)."
        
        
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
            self.dismissHUD()
            if isSuccess {
                self.syncUserModel { _ in
                    let user = Defaults.shared.currentUser
                    user?.subscriptionStatus = appMode.getType
                    user?.isTempSubscription = false
                    Defaults.shared.currentUser = user
                    Defaults.shared.isSubscriptionApiCalled = false
                    Defaults.shared.isDowngradeSubscription = false
                    SubscriptionSettings.storySettings[0].settings[appMode.rawValue].selected = true
                    AppEventBus.post("changeMode")
    //                self.navigationController?.popViewController(animated: true)
                    self.navigationController?.popToRootViewController(animated: true)
                    //Utils.appDelegate?.window?.makeToast(R.string.localizable.basicLiteModeIsEnabled())
                    Utils.appDelegate?.window?.currentController?.showAlert(alertMessage: R.string.localizable.basicLiteModeIsEnabled())
                }
               
            }
            self.showAlert(alertMessage: message)
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
                
                completion(true)
            }
        }, onError: { error in
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
    
    func setupForFreeTrial(isFreeTrial: Bool) {
        expiryDateHeightConstraint.constant = isFreeTrial ? 48 : 0
        lblFreeTrial.isHidden = !isFreeTrial
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
