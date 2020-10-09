//
//  IncomeCalculatorOneViewController.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 14/09/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit
import EasyTipView

class IncomeCalculatorTableViewCell: UITableViewCell {
    
    // MARK: -
    // MARK: - Outlets
    
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var lblIncome: UILabel!
    @IBOutlet weak var viewFollowers: UIView!
    @IBOutlet weak var viewIncome: UIView!
    
    // MARK: -
    // MARK: - Class Functions
    
    internal func setBlueBorder() {
        self.viewFollowers.layer.borderColor = UIColor.blue.cgColor
        self.viewFollowers.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        self.viewIncome.layer.borderColor = UIColor.blue.cgColor
        self.viewIncome.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
    }
    
    internal func setData(level: String, followers: String, income: String = "") {
        self.lblLevel.text = level
        self.lblFollowers.text = followers
        self.lblIncome.text = "$" + income
    }
    
}

class IncomeCalculatorOneViewController: UIViewController {
    
    // MARK: -
    // MARK: - Outlets
    
    @IBOutlet weak var inAppSlider: UISlider!
    @IBOutlet weak var percentageSlider: UISlider!
    @IBOutlet weak var lblAverageInAppPurchase: UILabel!
    @IBOutlet weak var lblPercentageFilled: UILabel!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet var tableSectionHeaderView: UIView!
    @IBOutlet weak var levelOneRefferalsSlider: UISlider!
    @IBOutlet weak var levelTwoRefferalsSlider: UISlider!
    @IBOutlet weak var levelThreeRefferalsSlider: UISlider!
    @IBOutlet weak var lblLevelOneRefferals: UILabel!
    @IBOutlet weak var lblLevelTwoRefferals: UILabel!
    @IBOutlet weak var lblLevelThreeRefferals: UILabel!
    
    // MARK: -
    // MARK: - Variables
    
    private var incomeData = [(Int, Int)]()
    private var averageInAppPurchase = 2
    private var percentageFilled = 10 {
        didSet {
            self.percentageSlider.value = Float(percentageFilled)
        }
    }
    private var directRefferals = 0
    private var levelTwoRefferals = 0
    private var levelThreeRefferals = 0
    private var totalFollowerCount = 0
    private var totalIncomeCount = 0
    private var levelOnePercentage = 0
    private var levelTwoPercentage = 0
    private var levelThreePercentage = 0
    private var percentageArray: [Int] {
        return [levelOnePercentage, levelTwoPercentage, levelThreePercentage]
    }
    private var toolTip = EasyTipView(text: "")
    
    // MARK: -
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getWebsiteId { [weak self] (type) in
            guard let `self` = self else { return }
            self.getCalculatorConfig(type: type)
        }
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
    
    @IBAction func percentageSliderChanged(_ sender: UISlider) {
        self.toolTip.dismiss()
        self.percentageFilled = Int(sender.value)
    }
    
    @IBAction func inAppSliderChanged(_ sender: UISlider) {
        self.toolTip.dismiss()
        self.averageInAppPurchase = Int(sender.value)
    }
    
    @IBAction func levelOneSliderChanged(_ sender: UISlider) {
        self.toolTip.dismiss()
    }
    
    @IBAction func levelTwoSliderChanged(_ sender: UISlider) {
        self.toolTip.dismiss()
    }
    
    @IBAction func levelThreeSliderChanged(_ sender: UISlider) {
        self.toolTip.dismiss()
    }
    
    @IBAction func levelOneRefferalsHelpTapped(_ sender: UIButton) {
        self.toolTip.dismiss()
        self.showTipView(text: R.string.localizable.levelOneToolTipText(), on: sender)
    }
    
    @IBAction func levelTwoRefferalsHelpTapped(_ sender: UIButton) {
        self.toolTip.dismiss()
        self.showTipView(text: R.string.localizable.levelTwoToolTipText(), on: sender)
    }
    
    @IBAction func levelThreeRefferalsHelpTapped(_ sender: UIButton) {
        self.toolTip.dismiss()
        self.showTipView(text: R.string.localizable.levelThreeToolTipText(), on: sender)
    }
    
    @IBAction func percentageHelpTapped(_ sender: UIButton) {
        self.toolTip.dismiss()
        self.showTipView(text: R.string.localizable.percentageToolTipText(), on: sender)
    }
    
    @IBAction func inAppPurchaseHelpTapped(_ sender: UIButton) {
        self.toolTip.dismiss()
        self.showTipView(text: R.string.localizable.inAppToolTipText(), on: sender)
    }
    
    // MARK: -
    // MARK: - Class Functions
    
    private func validateAndCalculate() {
        self.toolTip.dismiss()
        self.view.endEditing(true)
        self.directRefferals = Int(self.levelOneRefferalsSlider.value)
        self.levelTwoRefferals = Int(self.levelTwoRefferalsSlider.value)
        self.levelThreeRefferals = Int(self.levelThreeRefferalsSlider.value)
        self.calculateIncome()
        tableview.isHidden = false
        self.tableview.reloadData()
    }
    
    private func getFormattedNumberString(number: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value: number))
        return formattedNumber ?? ""
    }
    
    private func calculateIncome() {
        self.incomeData = []
        self.totalFollowerCount = 0
        self.totalIncomeCount = 0
        for index in 0...3 {
            let followers = Int(self.getNoOfPeople(indexPath: IndexPath(row: index, section: 0))) ?? 0
            let income = Int(self.getIncome(followers: followers, indexPath: IndexPath(row: index, section: 0))) ?? 0
            if index < 3 {
                self.totalIncomeCount += income
                self.totalFollowerCount += followers
                incomeData.append((followers, income))
            } else {
                incomeData.append((totalFollowerCount, totalIncomeCount))
            }
        }
    }
    
    private func showTipView(text: String, on view: UIView) {
        self.toolTip.dismiss()
        toolTip = EasyTipView(text: text, preferences: EasyTipView.globalPreferences)
        toolTip.show(animated: true, forView: view, withinSuperview: self.view)
    }
    
    private func getCalculatorConfig(type: String) {
        if UIApplication.checkInternetConnection() {
            self.showHUD()
            ProManagerApi.getCalculatorConfig(type: type).request(CalculatorConfigurationModel.self).subscribe(onNext: { (response) in
                self.dismissHUD()
                if let calcConfig = response.result?.first(where: { $0.type == "potential_income_1" }) {
                    self.levelOneRefferalsSlider.maximumValue = Float(calcConfig.levelsArray?[0] ?? 0)
                    self.levelTwoRefferalsSlider.maximumValue = Float(calcConfig.levelsArray?[1] ?? 0)
                    self.levelThreeRefferalsSlider.maximumValue = Float(calcConfig.levelsArray?[2] ?? 0)
                    self.levelOnePercentage = Int(self.levelOneRefferalsSlider.maximumValue)
                    self.levelTwoPercentage = Int(self.levelTwoRefferalsSlider.maximumValue)
                    self.levelThreePercentage = Int(self.levelThreeRefferalsSlider.maximumValue)
                    self.lblLevelOneRefferals.text = Int(self.levelOneRefferalsSlider.maximumValue).description
                    self.lblLevelTwoRefferals.text = Int(self.levelTwoRefferalsSlider.maximumValue).description
                    self.lblLevelThreeRefferals.text = Int(self.levelThreeRefferalsSlider.maximumValue).description
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

extension IncomeCalculatorOneViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.incomeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.incomeCalculatorTableViewCell.identifier) as? IncomeCalculatorTableViewCell else { return UITableViewCell() }
        if indexPath.row == incomeData.count - 1 {
            cell.setData(level: "Total", followers: self.getFormattedNumberString(number: self.incomeData[indexPath.row].0), income: self.getFormattedNumberString(number: self.incomeData[indexPath.row].1))
            cell.setBlueBorder()
        } else {
            cell.setData(level: (indexPath.row + 1).description + " (\(self.percentageArray[indexPath.row])%)", followers: self.getFormattedNumberString(number: self.incomeData[indexPath.row].0), income: self.getFormattedNumberString(number: self.incomeData[indexPath.row].1))
        }
        return cell
    }
    
    private func getNoOfPeople(indexPath: IndexPath) -> String {
        switch indexPath.row {
        case 0:
            return self.directRefferals.description
        case 1:
            return Int(self.directRefferals * self.levelTwoRefferals).description
        case 2:
            return Int(self.directRefferals * self.levelTwoRefferals * self.levelThreeRefferals).description
        case 3:
            return totalFollowerCount.description
        default:
            break
        }
        return ""
    }
    
    private func getIncome(followers: Int, indexPath: IndexPath) -> String {
        switch indexPath.row {
        case 0:
            let income = Int((followers * self.levelOnePercentage * percentageFilled * averageInAppPurchase) / 10000)
            return income.description
        case 1:
            let income = Int((followers * self.levelTwoPercentage * percentageFilled * averageInAppPurchase) / 10000)
            return income.description
        case 2:
            let income = Int((followers * self.levelThreePercentage * percentageFilled * averageInAppPurchase) / 10000)
            return income.description
        default:
            return self.totalIncomeCount.description
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableSectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 132
    }
    
}
