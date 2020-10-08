//
//  CalculatorViewController.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 08/09/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit
import EasyTipView

class IncomeCalculatorFourTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblInAppPurchase: UILabel!
    @IBOutlet weak var viewInAppPurchase: UIView!
    @IBOutlet weak var lblIncome: UILabel!
    @IBOutlet weak var viewIncome: UIView!
    
    internal func setBlueBorder() {
        self.viewInAppPurchase.layer.borderColor = UIColor.blue.cgColor
        self.viewInAppPurchase.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
    }
    
    internal func setGrayBorder() {
        self.viewInAppPurchase.layer.borderColor = R.color.cellViewBorderColor()?.cgColor ?? UIColor.gray.cgColor
        self.viewInAppPurchase.backgroundColor = R.color.cellViewBackgroundColor()
    }
    
    internal func setData(level: String, percentage: String, inAppPurcahse: String, income: String) {
        self.lblLevel.text = level + percentage
        self.lblInAppPurchase.text = inAppPurcahse
        self.lblIncome.text = income
    }
    
}

class IncomeCalculatorFourViewController: UIViewController {
    
    // MARK: -
    // MARK: - Outlets
    
    @IBOutlet weak var percentageSlider: CustomSlider!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet var tableSectionHeaderView: UIView!
    @IBOutlet weak var lblTotalFollowers: UILabel!
    @IBOutlet weak var lblTotalIncome: UILabel!
    @IBOutlet var tableHeaderView: UIView!
    @IBOutlet weak var inAppSlider: CustomSlider!
    @IBOutlet weak var innerCircleSlider: CustomSlider!
    @IBOutlet weak var extendedCircleSlider: CustomSlider!
    @IBOutlet weak var lblExtendedCircleLimit: UILabel!
    @IBOutlet weak var lblInnerCircleLimit: UILabel!
    
    // MARK: -
    // MARK: - Variables
    
    private var referCount = 0
    private var otherReferCount = 0
    private var totalCount = 0
    private var totalIncome: Float = 0.0
    private var referLimit = 0
    private var otherReferLimit = 0
    private var percentage = 10
    private var inAppPurchase = 10
    private var toolTip = EasyTipView(text: "")
    private var followersCount = [Int]()
    private var incomeData = [Float]()
    private var levelOnePercentage = 0
    private var levelTwoPercentage = 0
    private var percentageArray: [Int] {
        return [levelOnePercentage, levelTwoPercentage]
    }
    
    // MARK: -
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.tableHeaderView = tableHeaderView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getWebsiteId { [weak self] (type) in
            guard let `self` = self else { return }
            self.getCalculatorConfig(type: type)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableview.tableHeaderView?.frame.size.height = 139
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
    
    @IBAction func innerCircleSliderChanged(_ sender: UISlider) {
        self.toolTip.dismiss()
    }
    
    @IBAction func extendedCircleSliderChanged(_ sender: UISlider) {
        self.toolTip.dismiss()
    }
    
    @IBAction func percentageBarChanged(_ sender: UISlider) {
        self.toolTip.dismiss()
        self.percentage = Int(sender.value)
    }
    
    @IBAction func inAppSliderChanged(_ sender: UISlider) {
        self.toolTip.dismiss()
        self.inAppPurchase = Int(sender.value)
    }
    
    @IBAction func directReferHelpTapped(_ sender: UIButton) {
        self.showTipView(text: R.string.localizable.numberOfPeopleYouPersonallyReferInTheNext612Months(), on: sender)
    }
    
    @IBAction func indirectReferHelpTapped(_ sender: UIButton) {
        self.showTipView(text: R.string.localizable.averageNumberOfPeopleTheyReferInTheNext612Months(), on: sender)
    }
    
    @IBAction func btnPercentageHelpTapped(_ sender: UIButton) {
        self.showTipView(text: R.string.localizable.percentageToolTipText(), on: sender)
    }
    
    @IBAction func btnInAppHelpTapped(_ sender: UIButton) {
        self.showTipView(text: R.string.localizable.inAppToolTipText(), on: sender)
    }
    
    // MARK: -
    // MARK: - Class Functions
    
    private func showTipView(text: String, on view: UIView) {
        self.toolTip.dismiss()
        toolTip = EasyTipView(text: text, preferences: EasyTipView.globalPreferences)
        toolTip.show(animated: true, forView: view, withinSuperview: self.view)
    }
    
    private func validateAndCalculate() {
        self.toolTip.dismiss()
        self.view.endEditing(true)
        
        self.referCount = Int(self.innerCircleSlider.value)
        self.otherReferCount = Int(self.extendedCircleSlider.value)
        self.calculateFollowers()
        tableview.isHidden = false
        self.tableview.reloadData()
    }
    
    private func calculateFollowers() {
        self.totalCount = self.referCount
        self.followersCount = [self.totalCount]
        self.totalIncome = self.getInome(followers: self.referCount, index: 0)
        self.incomeData = [totalIncome]
        for row in 1...9 {
            let newFollowers = followersCount[row - 1] * self.otherReferCount * percentage / 100
            self.followersCount.append(newFollowers)
            let newIncome = self.getInome(followers: newFollowers, index: row)
            incomeData.append(newIncome)
            self.totalCount += newFollowers
            self.totalIncome += newIncome
        }
        self.lblTotalFollowers.text = self.getFormattedNumberString(number: totalCount)
    }
    
    private func getInome(followers: Int, index: Int) -> Float {
        if index == 0 {
            return Float(followers) * self.inAppSlider.value * Float(self.percentageArray[index])
        } else {
            return Float(followers) * self.percentageSlider.value * Float(self.percentageArray[index]) * self.inAppSlider.value
        }
    }
    
    private func getCalculatorConfig(type: String) {
        if UIApplication.checkInternetConnection() {
            self.showHUD()
            ProManagerApi.getCalculatorConfig(type: type).request(CalculatorConfigurationModel.self).subscribe(onNext: { (response) in
                self.dismissHUD()
                if let calcConfig = response.result?.first(where: { $0.type == "potential_income_4"}) {
                    self.innerCircleSlider.maximumValue = Float(calcConfig.maxRefer ?? 0)
                    self.extendedCircleSlider.maximumValue = Float(calcConfig.maxAverageRefer ?? 0)
                    self.percentage = calcConfig.percentage ?? 0
                    self.lblInnerCircleLimit.text = Int(self.innerCircleSlider.maximumValue).description
                    self.lblExtendedCircleLimit.text = Int(self.extendedCircleSlider.maximumValue).description
                    self.levelOnePercentage = calcConfig.levelsArray?[0] ?? self.levelOnePercentage
                    self.levelTwoPercentage = calcConfig.levelsArray?[1] ?? self.levelTwoPercentage
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

extension IncomeCalculatorFourViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return referCount == 0 ? 0 : 11
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.calculatorCell.identifier) as? CalculatorTableViewCell else { return UITableViewCell() }
        if indexPath.row == 10 {
            cell.setData(level: "Total", followers: self.getFormattedNumberString(number: totalCount))
            cell.setBlueBorder()
        } else {
            cell.setData(level: "\(indexPath.row + 1)" + " (\(self.percentageArray[indexPath.row])%)", followers: self.getFormattedNumberString(number: self.followersCount[indexPath.row]))
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
