//
//  ReferringChannelSuggestionViewController.swift
//  SocialCAM
//
//  Created by Nilisha Gupta on 19/05/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import NSObject_Rx

class ReferringChannelSuggestionViewController: UIViewController {
    
    // MARK: - Outlets Declaration
    @IBOutlet var searchView: UIView!
    @IBOutlet var txtField: UITextField!
    @IBOutlet var btnSearch: UIButton!
    @IBOutlet var btnClear: UIButton!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var referringTooltipView: UIView!
    @IBOutlet weak var lblReferringChannel: UILabel!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var txtChannelName: UITextField!
    
    // MARK: - Variables Declaration
    var channels: [Channel] = []
    var ChanelHandler: ((_ channel:Channel)->Void)?
    
    // MARK: - View Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblView.isHidden = true
        self.lblReferringChannel.text = R.string.localizable.referringChannelScreenText(Constant.Application.displayName)
        CommonFunctions.setAppLogo(imgLogo: imgLogo)
        self.txtChannelName.text = Defaults.shared.currentUser?.channelName
    }
    
    // MARK: - UI Setup Methods
    /// Hide clear button when search is complete
    private func changeClearButton(shouldShow: Bool) {
        self.btnClear.isHidden = !shouldShow
        self.btnSearch.isHidden = shouldShow
        self.tblView.isHidden = !shouldShow
    }
    
    /// Hide and show tooltip
    private func hideShowTooltipView(shouldShow: Bool) {
        self.referringTooltipView.isHidden = !shouldShow
    }
    
    // MARK: - Action Methods
    @IBAction func btnSearchClicked(_ sender: UIButton) {
        self.getReferringChannelSuggestion()
        self.showHUD()
    }
    
    @IBAction func btnContinueClicked(_ sender: UIButton) {
        guard let referringChannel = txtField.text else {
            return
        }
        if referringChannel.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            self.showAlert(alertMessage: R.string.localizable.pleaseEnterTheNameOfYourReferringChannelIfYouDoNotHaveOneUseTheSearchFeatureToFindAChannelToUse())
        } else {
            self.addReferral()
        }
    }
    
    @IBAction func btnClearClicked(_ sender: UIButton) {
        self.changeClearButton(shouldShow: false)
        self.txtField.text = ""
    }
    
    @IBAction func btnTooltipClicked(_ sender: UIButton) {
        self.hideShowTooltipView(shouldShow: true)
    }
    
    @IBAction func btnOkClicked(_ sender: UIButton) {
        self.hideShowTooltipView(shouldShow: false)
    }
    
}

// MARK: - TextField Delegate
extension ReferringChannelSuggestionViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.changeClearButton(shouldShow: true)
        self.tblView.isHidden = true
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.changeClearButton(shouldShow: !(txtField.text?.isEmpty ?? false))
        if let textFieldCount = textField.text?.count {
            if textFieldCount >= 3 {
                self.getReferringChannelSuggestion()
                self.showHUD()
            } else if textFieldCount < 3 {
                self.tblView.isHidden = true
            }
        }
        return true
    }
    
}

// MARK: - TableView DataSource
extension ReferringChannelSuggestionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chanelCell.identifier) as? ChanelCell else {
            fatalError("ChanelCell Not Found")
        }
        cell.channel = self.channels[indexPath.row]
        return cell
    }
    
}

// MARK: - TableView Delegate
extension ReferringChannelSuggestionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let channel = ChanelHandler {
            channel(self.channels[indexPath.row])
        }
        self.txtField.text = self.channels[indexPath.row].channelName
        self.tblView.isHidden = true
    }
    
}

// MARK: - Redirection and API Methods
extension ReferringChannelSuggestionViewController {
    
    func redirectToHomeScreen() {
        if let isRegistered = Defaults.shared.isRegistered {
            if isRegistered {
                let tooltipViewController = R.storyboard.loginViewController.tooltipViewController()
                Utils.appDelegate?.window?.rootViewController = tooltipViewController
                tooltipViewController?.blurView.isHidden = false
                tooltipViewController?.blurView.alpha = 0.7
                tooltipViewController?.signupTooltipView.isHidden = false
            }
        } else {
            let cameraNavVC = R.storyboard.storyCameraViewController.storyCameraViewNavigationController()
            cameraNavVC?.navigationBar.isHidden = true
            Utils.appDelegate?.window?.rootViewController = cameraNavVC
        }
    }
    
    func getReferringChannelSuggestion() {
        guard let text = txtField.text else {
            return
        }
        ProManagerApi.search(channel: text).request(ResultArray<Channel>.self).subscribe(onNext: { response in
            self.dismissHUD()
            let channel: [Channel] = response.result!
            self.channels = channel
            self.tblView.isHidden = false
            self.tblView.reloadData()
        }, onError: { error in
            self.dismissHUD()
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: (rx.disposeBag))
    }
    
    func addReferral() {
        guard let referringChannel = txtField.text else {
            return
        }
        ProManagerApi.addReferral(refferingChannel: referringChannel).request(Result<EmptyModel>.self).subscribe(onNext: { (response) in
            if response.status == ResponseType.success {
                let user = Defaults.shared.currentUser
                user?.refferingChannel = referringChannel
                Defaults.shared.currentUser = user
                self.redirectToHomeScreen()
            } else {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
    
}

// MARK: - UIGestureRecognizer Delegate
extension ReferringChannelSuggestionViewController: UIGestureRecognizerDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if touch?.view != tblView {
            tblView.isHidden = true
        }
    }
    
}
