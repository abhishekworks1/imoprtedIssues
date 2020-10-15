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
    
    @IBOutlet weak var inAppPurchaseTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var percentageViewHeightCeonstraint: NSLayoutConstraint!
    @IBOutlet weak var lblStaticInAppPurchase: UILabel!
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
    @IBOutlet weak var viewPercentage: UIView!
    @IBOutlet weak var btnStaticInAppHelp: UIButton!
    
    // MARK: -
    // MARK: - Variables
    
    private var incomeData = [(Int, Double)]()
    private var averageInAppPurchase = 0 {
        didSet {
            self.inAppSlider.value = Float(averageInAppPurchase)
            self.lblAverageInAppPurchase.text = "$" + averageInAppPurchase.description
        }
    }
    private var percentageFilled = 0 {
        didSet {
            self.percentageSlider.value = Float(percentageFilled)
            self.lblPercentageFilled.text = percentageFilled.description + "%"
        }
    }
    private var directRefferals = 0
    private var levelTwoRefferals = 0
    private var levelThreeRefferals = 0
    private var totalFollowerCount = 0
    private var totalIncomeCount: Double = 0
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
        setupUiForLiteApp()
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
        self.lblLevelOneRefferals.text = Int(sender.value).description
        self.toolTip.dismiss()
    }
    
    @IBAction func levelTwoSliderChanged(_ sender: UISlider) {
        self.lblLevelTwoRefferals.text = Int(sender.value).description
        self.toolTip.dismiss()
    }
    
    @IBAction func levelThreeSliderChanged(_ sender: UISlider) {
        self.lblLevelThreeRefferals.text = Int(sender.value).description
        self.toolTip.dismiss()
    }
    
    @IBAction func levelOneRefferalsHelpTapped(_ sender: UIButton) {
        self.showTipView(text: R.string.localizable.levelOneToolTipText(), on: sender)
    }
    
    @IBAction func levelTwoRefferalsHelpTapped(_ sender: UIButton) {
        self.showTipView(text: R.string.localizable.levelTwoToolTipText(), on: sender)
    }
    
    @IBAction func levelThreeRefferalsHelpTapped(_ sender: UIButton) {
        self.showTipView(text: R.string.localizable.levelThreeToolTipText(), on: sender)
    }
    
    @IBAction func percentageHelpTapped(_ sender: UIButton) {
        self.showTipView(text: R.string.localizable.percentageToolTipText(), on: sender)
    }
    
    @IBAction func inAppPurchaseHelpTapped(_ sender: UIButton) {
        self.showTipView(text: R.string.localizable.inAppToolTipText(), on: sender)
    }
    
    // MARK: -
    // MARK: - Class Functions
    
    private func setupUiForLiteApp() {
        if isLiteApp {
            self.inAppPurchaseTopConstraint.constant += 10
            self.btnStaticInAppHelp.isHidden = false
            self.percentageFilled = 100
            lblStaticInAppPurchase.isHidden = false
            self.averageInAppPurchase = 1
            
            self.viewPercentage.isHidden = true
            self.percentageViewHeightCeonstraint.constant = 0
            self.inAppSlider.isHidden = true
            self.lblAverageInAppPurchase.isHidden = true
        }
    }
    
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
    
    private func calculateIncome() {
        self.incomeData = []
        self.totalFollowerCount = 0
        self.totalIncomeCount = 0
        for index in 0...3 {
            let followers = Int(self.getNoOfPeople(indexPath: IndexPath(row: index, section: 0))) ?? 0
            let income = Double(self.getIncome(followers: followers, indexPath: IndexPath(row: index, section: 0))) ?? 0
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
                    self.levelOneRefferalsSlider.maximumValue = Float(calcConfig.maxLevel1 ?? 0)
                    self.levelTwoRefferalsSlider.maximumValue = Float(calcConfig.maxLevel2 ?? 0)
                    self.levelThreeRefferalsSlider.maximumValue = Float(calcConfig.maxLevel3 ?? 0)
                    self.inAppSlider.maximumValue = Float(calcConfig.inAppPurchaseLimit ?? 0)
                    self.levelOnePercentage = calcConfig.levelsArray?[0] ?? 0
                    self.levelTwoPercentage = calcConfig.levelsArray?[1] ?? 0
                    self.levelThreePercentage = calcConfig.levelsArray?[2] ?? 0
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
            cell.setData(level: R.string.localizable.total(), followers: CommonFunctions.getFormattedNumberString(number: self.totalFollowerCount), income: CommonFunctions.getFormattedNumberString(number: self.totalIncomeCount))
            cell.setBlueBorder()
        } else {
            cell.setData(level: (indexPath.row + 1).description + " (\(self.percentageArray[indexPath.row])%)", followers: CommonFunctions.getFormattedNumberString(number: self.incomeData[indexPath.row].0), income: CommonFunctions.getFormattedNumberString(number: self.incomeData[indexPath.row].1))
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
        var income: Float = 0
        switch indexPath.row {
        case 0:
            income = (Float(followers) * Float(self.levelOnePercentage) * Float(percentageFilled) * Float(averageInAppPurchase)) / 10000
        case 1:
            income = (Float(followers) * Float(self.levelTwoPercentage) * Float(percentageFilled) * Float(averageInAppPurchase)) / 10000
        case 2:
            income = (Float(followers) * Float(self.levelThreePercentage) * Float(percentageFilled) * Float(averageInAppPurchase)) / 10000
        default:
            return self.totalIncomeCount.description
        }
        if isLiteApp {
            return income.roundToPlaces(places: 1).description
        } else {
            return Int(income).description
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableSectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 132
    }
    
}
