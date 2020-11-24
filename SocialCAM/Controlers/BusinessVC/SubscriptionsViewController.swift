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
            self.enableMode(appMode: self.subscriptionType)
        }
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
        btnUpgrade.setTitle(R.string.localizable.downgradeNow(), for: .normal)
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
            message = R.string.localizable.areYouSureSubscriptionMessage(R.string.localizable.downgrade(), appMode.description)
            successMessage = R.string.localizable.freeModeIsEnabled()
        case .basic:
            var upgradeString = R.string.localizable.upgrade()
            if Defaults.shared.appMode == .advanced || Defaults.shared.appMode == .professional {
                upgradeString = R.string.localizable.downgrade()
            }
            message = R.string.localizable.areYouSureSubscriptionMessage(upgradeString, appMode.description)
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
        
        let actionSave = UIAlertAction(title: R.string.localizable.oK(), style: .default) { ( _: UIAlertAction) in
            if appMode != .free {
                guard let textField = objAlert.textFields?.first,
                    textField.text?.count ?? 0 > 0 else {
                    self.view.makeToast(R.string.localizable.pleaseEnterValidCode())
                    return
                }
                if textField.text?.lowercased() != proModeCode {
                    self.view.makeToast(R.string.localizable.pleaseEnterValidCode())
                    return
                }
            }
            Defaults.shared.appMode = appMode
            SubscriptionSettings.storySettings[0].settings[appMode.rawValue].selected = true
            AppEventBus.post("changeMode")
            self.navigationController?.popViewController(animated: true)
            Utils.appDelegate?.window?.makeToast(successMessage)
            
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .default) { (_: UIAlertAction) in }
        objAlert.addAction(cancelAction)
        objAlert.addAction(actionSave)
        self.present(objAlert, animated: true, completion: nil)
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