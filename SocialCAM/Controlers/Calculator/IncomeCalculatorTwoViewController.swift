//
//  IncomeCalculatorTwoViewController.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 14/09/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit
import EasyTipView

class IncomeCalculatorTwoViewController: UIViewController {
    
    // MARK: -
    // MARK: - Outlets
    
    @IBOutlet weak var levelOneSlider: UISlider!
    @IBOutlet weak var levelTwoSlider: UISlider!
    @IBOutlet weak var lblLevelOneRefferals: UILabel!
    @IBOutlet weak var lblLevelTwoRefferals: UILabel!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var lblNavigationTitle: UILabel!
    @IBOutlet var tableViewSectionHeader: UIView!
    @IBOutlet weak var lblPercentageFilled: UILabel!
    @IBOutlet weak var lblAverageInAppPurchase: UILabel!
    @IBOutlet weak var percentageSlider: CustomSlider!
    @IBOutlet weak var inAppSlider: CustomSlider!
    
    // MARK: -
    // MARK: - Variables
    
    private var averageInAppPurchase = 0 {
        didSet {
            self.lblAverageInAppPurchase.text = "$" + averageInAppPurchase.description
            self.inAppSlider.value = Float(averageInAppPurchase)
        }
    }
    private var percentageFilled = 0 {
        didSet {
            self.lblPercentageFilled.text = percentageFilled.description + "%"
            self.percentageSlider.value = Float(percentageFilled)
        }
    }
    internal var isCalculatorThree = false
    private var directRefferals = 0
    private var levelTwoRefferals = 0
    private var totalCount = 0
    private var levelOnePercentage = 0
    private var levelTwoPercentage = 0
    private var incomeData = [(Int, Int)]()
    private var totalFollowerCount = 0
    private var totalIncomeCount = 0
    private var percentageArray: [Int] {
        return [levelOnePercentage, levelTwoPercentage]
    }
    private var levels = [Int]()
    private var toolTip = EasyTipView(text: "")
    
    
    // MARK: -
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isCalculatorThree {
            lblNavigationTitle.text = "Potential Income Calculator 3"
        }
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

    
    @IBAction func percentageSliderValueChanged(_ sender: UISlider) {
        self.toolTip.dismiss()
        self.percentageFilled = Int(sender.value)
    }
    
    @IBAction func inAppSliderChanged(_ sender: UISlider) {
        self.toolTip.dismiss()
        self.averageInAppPurchase = Int(sender.value)
    }
    
    @IBAction func levelOneSliderChanged(_ sender: UISlider) {
        self.toolTip.dismiss()
        self.lblLevelOneRefferals.text = Int(sender.value).description
    }
    
    @IBAction func levelTwoSliderChanged(_ sender: UISlider) {
        self.toolTip.dismiss()
        self.lblLevelTwoRefferals.text = Int(sender.value).description
    }
    
    @IBAction func levelOneHelpTapped(_ sender: UIButton) {
        self.showTipView(text: R.string.localizable.levelOneToolTipText(), on: sender)
    }
    
    @IBAction func levelTwoHelpTapped(_ sender: UIButton) {
        self.showTipView(text: R.string.localizable.levelTwoToolTipText(), on: sender)
    }
    
    @IBAction func percentageHelpTapped(_ sender: UIButton) {
        self.showTipView(text: R.string.localizable.percentageToolTipText(), on: sender)
    }
    
    @IBAction func inAppHelpTapped(_ sender: UIButton) {
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
        self.view.endEditing(true)
        self.directRefferals = Int(self.levelOneSlider.value)
        self.levelTwoRefferals = Int(self.levelTwoSlider.value)
        self.calculateIncome()
        tableview.isHidden = false
        self.tableview.reloadData()
    }
    
    private func calculateIncome() {
        self.incomeData = []
        self.totalFollowerCount = 0
        self.totalIncomeCount = 0
        for index in 0...2 {
            let followers = Int(self.getNoOfPeople(indexPath: IndexPath(row: index, section: 0))) ?? 0
            let income = Int(self.getIncome(followers: followers, indexPath: IndexPath(row: index, section: 0))) ?? 0
            if index < 2 {
                self.totalIncomeCount += income
                self.totalFollowerCount += followers
                incomeData.append((followers, income))
            } else {
                incomeData.append((totalFollowerCount, totalIncomeCount))
            }
        }
    }
    
    private func getIncome(followers: Int, indexPath: IndexPath) -> String {
        switch indexPath.row {
        case 0:
            let income = Int(followers * self.levelOnePercentage * percentageFilled * averageInAppPurchase / 10000)
            return income.description
        case 1:
            let income = Int(followers * self.levelTwoPercentage * percentageFilled * averageInAppPurchase / 10000)
            return income.description
        default:
            return self.totalIncomeCount.description
        }
    }
    
    private func getCalculatorConfig(type: String) {
        if UIApplication.checkInternetConnection() {
            self.showHUD()
            ProManagerApi.getCalculatorConfig(type: type).request(CalculatorConfigurationModel.self).subscribe(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                self.dismissHUD()
                if let calcConfig = response.result?.first(where: { $0.type == (self.isCalculatorThree ? "potential_income_2" : "potential_income_3") }) {
                    self.levelOneSlider.maximumValue = Float(calcConfig.maxLevel1 ?? 0)
                    self.levelTwoSlider.maximumValue = Float(calcConfig.maxLevel2 ?? 0)
                    self.inAppSlider.maximumValue = Float(calcConfig.inAppPurchaseLimit ?? 0)
                    self.levelOnePercentage = calcConfig.levelsArray?[0] ?? self.levelOnePercentage
                    self.levelTwoPercentage = calcConfig.levelsArray?[1] ?? self.levelOnePercentage
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

extension IncomeCalculatorTwoViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.incomeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.incomeCalculator2TableViewCell.identifier) as? IncomeCalculatorTableViewCell else { return UITableViewCell() }
        if indexPath.row == incomeData.count - 1 {
            cell.setBlueBorder()
            cell.setData(level: "Total", followers: self.getFormattedNumberString(number: self.incomeData[indexPath.row].0), income: self.getFormattedNumberString(number: self.incomeData[indexPath.row].1))
        } else {
            cell.setData(level: (indexPath.row + 1).description + " (\(self.percentageArray[indexPath.row])%)", followers: self.getFormattedNumberString(number: self.incomeData[indexPath.row].0), income: self.getFormattedNumberString(number: self.incomeData[indexPath.row].1))
        }
        return cell
    }
    
    private func getFormattedNumberString(number: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value: number))
        return formattedNumber ?? ""
    }
    
    private func getNoOfPeople(indexPath: IndexPath) -> String {
        switch indexPath.row {
        case 0:
            return self.directRefferals.description
        case 1:
            return Int(self.directRefferals * self.levelTwoRefferals).description
        default:
            return totalFollowerCount.description
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableViewSectionHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 132
    }
    
}
