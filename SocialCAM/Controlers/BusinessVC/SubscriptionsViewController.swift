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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var freeModeAlertView: UIView!
    @IBOutlet weak var freeModeAlertBlurView: UIVisualEffectView!
    
    internal var subscriptionType = AppMode.free {
        didSet {
            self.title = subscriptionType.description
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @IBAction func btnUpgradeTapped(_ sender: Any) {
        if Defaults.shared.appMode != self.subscriptionType {
            Defaults.shared.isSubscriptionApiCalled = true
            self.enableMode(appMode: self.subscriptionType)
        }
    }
    
    @IBAction func btnOkayTapped(_ sender: UIButton) {
        freeModeAlertBlurView.isHidden = true
        freeModeAlertView.isHidden = true
        Defaults.shared.isSubscriptionApiCalled = false
    }
    
    private func setupUI() {
        self.lblTitle.text = self.subscriptionType.description
        self.lblPrice.text = self.subscriptionType.price
        if Defaults.shared.appMode == self.subscriptionType {
            btnUpgrade.setTitle(R.string.localizable.yourCurrentPlan(), for: .normal)
            btnUpgrade.backgroundColor = R.color.currentPlanButtonColor()
        } else {
            self.setDowngradeButton()
        }
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
        btnUpgrade.backgroundColor = R.color.downgradeButtonColor()
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
                self.callSubscriptionApi(appMode: appMode, code: "GET_SUBSCRIPTION", successMessage: successMessage)
            }
            
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .default) { (_: UIAlertAction) in
            Defaults.shared.isSubscriptionApiCalled = false
        }
        objAlert.addAction(cancelAction)
        objAlert.addAction(actionSave)
        if appMode != .free || Defaults.shared.releaseType != .beta {
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
