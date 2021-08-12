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
        self.viewModel.getPackageList()
        setupUI()
        if subscriptionType == .basic {
            bindViewModel(appMode: appMode ?? .basic)
        }
        if Defaults.shared.allowFullAccess == true {
            btnUpgrade.isUserInteractionEnabled = false
            expiryDateHeightConstraint.constant = 0
            lblFreeTrial.isHidden = true
        }
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
            guard let url = URL(string: Constant.SubscriptionUrl.cancelSubscriptionUrl) else {
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
    
    private func setupUI() {
        if let currentUser = Defaults.shared.currentUser {
            lblExpiryDate.text = R.string.localizable.expiryDaysLeft("\(Defaults.shared.numberOfFreeTrialDays ?? 0)")
            if currentUser.isTempSubscription ?? false && subscriptionType != .free && Defaults.shared.appMode != .free {
                isFreeTrialMode = true
                setupForFreeTrial(isFreeTrial: true)
            } else if Defaults.shared.isDowngradeSubscription == true && subscriptionType != .free && Defaults.shared.appMode != .free {
                lblYourCurrentPlan.isHidden = false
                setupForFreeTrial(isFreeTrial: false)
                expiryDateHeightConstraint.constant = 48
            } else {
                setupForFreeTrial(isFreeTrial: false)
                if Defaults.shared.numberOfFreeTrialDays != 0 && subscriptionType != .free && Defaults.shared.appMode != .free {
                    expiryDateHeightConstraint.constant = 48
                }
            }
            if (currentUser.isTempSubscription == true && subscriptionType == .free) || (Defaults.shared.isDowngradeSubscription == true && subscriptionType == .free) {
                btnUpgrade.isHidden = true
            }
        }
        self.lblTitle.text = self.subscriptionType.description
        self.lblPrice.text = self.subscriptionType.price
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
        let subscriptionData = subscriptionsList.filter({$0.productId == Constant.IAPProductIds.quickCamLiteBasic})
        Defaults.shared.subscriptionId = subscriptionData.first?.id ?? ""
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
        btnUpgrade.setTitle(R.string.localizable.downgrade(), for: .normal)
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
            successMessage = R.string.localizable.advancedModeIsEnabled()
        case .professional:
            message = R.string.localizable.areYouSureSubscriptionMessage(R.string.localizable.upgrade(), appMode.description)
            successMessage = R.string.localizable.professionalModeIsEnabled()
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
        if isQuickApp && appMode == .basic {
            let subscriptionData = subscriptionsList.filter({$0.productId == Constant.IAPProductIds.quickCamLiteBasic})
            self.purchaseProduct(productIdentifire: subscriptionData.first?.productId ?? "", productServerID: subscriptionData.first?.id ?? "")
            self.appMode = appMode
        } else if isQuickApp && appMode == .free {
            self.downgradePopupView.isHidden = false
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
                Utils.appDelegate?.window?.makeToast(successMessage)
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
                let user = Defaults.shared.currentUser
                user?.subscriptionStatus = appMode.getType
                user?.isTempSubscription = false
                Defaults.shared.currentUser = user
                Defaults.shared.isSubscriptionApiCalled = false
                Defaults.shared.isDowngradeSubscription = false
                SubscriptionSettings.storySettings[0].settings[appMode.rawValue].selected = true
                AppEventBus.post("changeMode")
                self.navigationController?.popViewController(animated: true)
                Utils.appDelegate?.window?.makeToast(R.string.localizable.basicLiteModeIsEnabled())
            }
            self.showAlert(alertMessage: message)
        }
        
        self.viewModel.subscriptionError.bind { [weak self] (message) in
            guard let `self` = self else { return }
            self.dismissHUD()
            self.showAlert(alertMessage: message)
        }
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
