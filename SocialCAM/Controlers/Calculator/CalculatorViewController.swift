//
//  CalculatorViewController.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 08/09/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit
import EasyTipView

class CalculatorTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var viewFollowers: UIView!
    
    internal func setBlueBorder() {
        self.viewFollowers.layer.borderColor = UIColor.blue.cgColor
        self.viewFollowers.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
    }
    
    internal func setGrayBorder() {
        self.viewFollowers.layer.borderColor = R.color.cellViewBorderColor()?.cgColor ?? UIColor.gray.cgColor
        self.viewFollowers.backgroundColor = R.color.cellViewBackgroundColor()
    }
    
    internal func setData(level: String, followers: String) {
        self.lblLevel.text = level
        self.lblFollowers.text = followers
    }
    
}

class CalculatorViewController: UIViewController {
    
    // MARK: -
    // MARK: - Outlets
    
    @IBOutlet weak var percentageSlider: UISlider!
    @IBOutlet weak var txtReferCount: UITextField!
    @IBOutlet weak var txtOtherReferCount: UITextField!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet var tableSectionHeaderView: UIView!
    @IBOutlet weak var lblTotalFollowers: UILabel!
    @IBOutlet var tableHeaderView: UIView!
    @IBOutlet weak var lblPercentageFilled: UILabel!
    
    // MARK: -
    // MARK: - Variables
    
    private var referCount = 0
    private var otherReferCount = 0
    private var totalCount = 0
    private var referLimit = 0
    private var otherReferLimit = 0
    private var percentage = 10 {
        didSet {
            self.lblPercentageFilled.text = percentage.description + "%"
            self.percentageSlider.value = Float(percentage)
        }
    }
    private var toolTip = EasyTipView(text: "")
    private var followersCount = [Int]()
    
    // MARK: -
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.tableHeaderView = tableHeaderView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getCalculatorConfig()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableview.tableHeaderView?.frame.size.height = 126
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.toolTip.dismiss()
    }

    // MARK: -
    // MARK: - Button Action Methods
    
    @IBAction func btnCalculateTapped(_ sender: Any) {
        self.validateAndCalculate()
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func percentageBarChanged(_ sender: UISlider) {
        self.toolTip.dismiss()
        self.percentage = Int(sender.value)
    }
    
    @IBAction func directReferHelpTapped(_ sender: UIButton) {
        self.toolTip.dismiss()
        toolTip = EasyTipView(text: R.string.localizable.numberOfPeopleYouPersonallyReferInTheNext612Months(), preferences: EasyTipView.globalPreferences)
        toolTip.show(animated: true, forView: sender, withinSuperview: self.view)
    }
    
    @IBAction func indirectReferHelpTapped(_ sender: UIButton) {
        self.toolTip.dismiss()
        toolTip = EasyTipView(text: R.string.localizable.averageNumberOfPeopleTheyReferInTheNext612Months(), preferences: EasyTipView.globalPreferences)
        toolTip.show(animated: true, forView: sender, withinSuperview: self.view)
    }
    
    // MARK: -
    // MARK: - Class Functions
    
    private func validateAndCalculate() {
        self.toolTip.dismiss()
        self.view.endEditing(true)
        if let referCount = self.txtReferCount.text, let otherReferCount = self.txtOtherReferCount.text, let referCountInt = Int(referCount), let otherReferCountInt = Int(otherReferCount), referCountInt <= self.referLimit, otherReferCountInt <= self.otherReferLimit {
            self.referCount = referCountInt
            self.otherReferCount = otherReferCountInt
            self.calculateFollowers()
            tableview.isHidden = false
            self.tableview.reloadData()
        } else {
            self.showAlert(alertMessage: R.string.localizable.referCountAlertMessage("\(self.referLimit)", "\(self.otherReferLimit)"))
        }
    }
    
    private func calculateFollowers() {
        self.followersCount = [self.referCount]
        self.totalCount = self.referCount
        for row in 1...9 {
            let newFollowers = followersCount[row - 1] * self.otherReferCount * percentage / 100
            self.followersCount.append(newFollowers)
            self.totalCount += newFollowers
        }
        self.lblTotalFollowers.text = self.getFormattedNumberString(number: totalCount)
    }
    
    private func getCalculatorConfig() {
        if UIApplication.checkInternetConnection() {
            self.showHUD()
            ProManagerApi.getCalculatorConfig.request(CalculatorConfigurationModel.self).subscribe(onNext: { (response) in
                self.dismissHUD()
                if let calcConfig = response.result?.first(where: { $0.type == "potential_followers"}) {
                    self.referLimit = calcConfig.maxRefer ?? self.referLimit
                    self.otherReferLimit = calcConfig.maxAverageRefer ?? self.otherReferLimit
                    self.percentage = calcConfig.percentage ?? 0
                }
            }, onError: { error in
                self.showAlert(alertMessage: error.localizedDescription)
            }, onCompleted: {
            }).disposed(by: rx.disposeBag)
        } else {
            self.showAlert(alertMessage: R.string.localizable.nointernetconnectioN())
        }
    }
    
}

// MARK: -
// MARK: - UITableView Delegate and DataSource

extension CalculatorViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return referCount == 0 ? 0 : 11
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.calculatorCell.identifier) as? CalculatorTableViewCell else { return UITableViewCell() }
        if indexPath.row == 10 {
            cell.setData(level: "Total", followers: self.getFormattedNumberString(number: totalCount))
            cell.setBlueBorder()
        } else {
            cell.setData(level: "\(indexPath.row + 1)", followers: self.getFormattedNumberString(number: self.followersCount[indexPath.row]))
            cell.setGrayBorder()
        }
        return cell
    }
    
    private func getFormattedNumberString(number: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value: number))
        return formattedNumber ?? ""
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableSectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }

}

extension CalculatorViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            return true
        } else {
            var maxLimit = 0
            switch textField {
            case self.txtReferCount:
                maxLimit = self.referLimit
            case self.txtOtherReferCount:
                maxLimit = self.otherReferLimit
            default:
                return true
            }
            if let text = textField.text, let int = Int(text + string), int <= maxLimit {
                return true
            } else {
                return false
            }
        }
    }
    
}
