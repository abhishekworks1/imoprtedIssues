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
    
    // MARK: - Variables Declaration
    var channels: [Channel] = []
    var ChanelHandler: ((_ channel:Channel)->Void)?
    
    // MARK: - View Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblView.isHidden = true
        self.lblReferringChannel.text = R.string.localizable.referringChannelScreenText(Constant.Application.displayName)
        CommonFunctions.setAppLogo(imgLogo: imgLogo)
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
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.getReferringChannelSuggestion()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.changeClearButton(shouldShow: !(txtField.text?.isEmpty ?? false))
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
            }
        } else {
            let addSocialConnectionViewController = R.storyboard.socialConnection.addSocialConnectionViewController()
            addSocialConnectionViewController?.fromLogin = true
            Utils.appDelegate?.window?.rootViewController = addSocialConnectionViewController
        }
    }
    
    func getReferringChannelSuggestion() {
        let result = self.txtField.rx.text.orEmpty.throttle(0.5, scheduler: MainScheduler.instance).distinctUntilChanged().flatMapLatest { (channel: String) -> Observable<ResultArray<Channel>> in
            self.showHUD()
            return ProManagerApi.search(channel: channel).request(ResultArray<Channel>.self)
        }
        result.subscribe(onNext: { response in
            self.dismissHUD()
            let channel: [Channel] = response.result!
            self.channels = channel
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
