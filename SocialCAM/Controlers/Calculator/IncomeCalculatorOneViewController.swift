//
//  IncomeCalculatorOneViewController.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 14/09/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit

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
        self.viewFollowers.layer.borderColor = R.color.calculatorButtonColor()?.cgColor
        self.viewFollowers.backgroundColor = R.color.calculatorButtonColor()?.withAlphaComponent(0.1)
        self.viewIncome.layer.borderColor = R.color.calculatorButtonColor()?.cgColor
        self.viewIncome.backgroundColor = R.color.calculatorButtonColor()?.withAlphaComponent(0.1)
    }
    
    internal func setGrayBorder() {
        self.viewFollowers.layer.borderColor = R.color.cellViewBorderColor()?.cgColor ?? UIColor.gray.cgColor
        self.viewFollowers.backgroundColor = R.color.cellViewBackgroundColor()
        self.viewIncome.layer.borderColor = R.color.cellViewBorderColor()?.cgColor ?? UIColor.gray.cgColor
        self.viewIncome.backgroundColor = R.color.cellViewBackgroundColor()
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
    
    @IBOutlet weak var lblLegal: UILabel!
    @IBOutlet var viewLegalNotice: UIView!
    @IBOutlet weak var lblNavigationTitle: UILabel!
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
    
    internal var isLiteCalculator = false
    internal var calculatorType = CalculatorType.incomeOne
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
    
    // MARK: -
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.tableFooterView = viewLegalNotice
        self.lblNavigationTitle.text = calculatorType.getNavigationTitle()
        setupUiForLiteApp()
        if let calcConfig = Defaults.shared.calculatorConfig {
            self.configureUI(configuration: calcConfig)
        } else {
            self.showHUD()
            self.view.isUserInteractionEnabled = false
        }
        self.getWebsiteId { [weak self] (type) in
            guard let `self` = self else { return }
            self.getCalculatorConfig(type: type)
        }
        lblLegal.setCalculatorLegalText()
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
        self.percentageFilled = Int(sender.value)
    }
    
    @IBAction func inAppSliderChanged(_ sender: UISlider) {
        self.averageInAppPurchase = Int(sender.value)
    }
    
    @IBAction func levelOneSliderChanged(_ sender: UISlider) {
        self.lblLevelOneRefferals.text = Int(sender.value).description
    }
    
    @IBAction func levelTwoSliderChanged(_ sender: UISlider) {
        self.lblLevelTwoRefferals.text = Int(sender.value).description
    }
    
    @IBAction func levelThreeSliderChanged(_ sender: UISlider) {
        self.lblLevelThreeRefferals.text = Int(sender.value).description
    }
    
    @IBAction func levelOneRefferalsHelpTapped(_ sender: UIButton) {
        showCustomAlert(message: R.string.localizable.levelOneToolTipText())
    }
    
    @IBAction func levelTwoRefferalsHelpTapped(_ sender: UIButton) {
        showCustomAlert(message: R.string.localizable.levelTwoToolTipText())
    }
    
    @IBAction func levelThreeRefferalsHelpTapped(_ sender: UIButton) {
        showCustomAlert(message: R.string.localizable.levelThreeToolTipText())
    }
    
    @IBAction func percentageHelpTapped(_ sender: UIButton) {
        showCustomAlert(message: R.string.localizable.percentageToolTipText())
    }
    
    @IBAction func inAppPurchaseHelpTapped(_ sender: UIButton) {
        showCustomAlert(message: R.string.localizable.inAppToolTipText())
    }
    
    // MARK: -
    // MARK: - Class Functions
    
    private func setupUiForLiteApp() {
        if isLiteCalculator {
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
    
    private func configureUI(configuration: [CalculatorConfigurationData]?) {
        if let calcConfig = configuration?.first(where: { $0.type == self.calculatorType.rawValue }) {
            self.levelOneRefferalsSlider.maximumValue = Float(calcConfig.maxLevel1 ?? 0)
            self.levelTwoRefferalsSlider.maximumValue = Float(calcConfig.maxLevel2 ?? 0)
            self.levelThreeRefferalsSlider.maximumValue = Float(calcConfig.maxLevel3 ?? 0)
            self.inAppSlider.maximumValue = Float(calcConfig.inAppPurchaseLimit ?? 0)
            self.levelOnePercentage = calcConfig.levelsArray?[0] ?? 0
            self.levelTwoPercentage = calcConfig.levelsArray?[1] ?? 0
            self.levelThreePercentage = calcConfig.levelsArray?[2] ?? 0
        }
    }
    
    private func getCalculatorConfig(type: String) {
        if UIApplication.checkInternetConnection() {
            ProManagerApi.getCalculatorConfig(type: type).request(CalculatorConfigurationModel.self).subscribe(onNext: { (response) in
                self.configureUI(configuration: response.result)
                Defaults.shared.calculatorConfig = response.result
                self.dismissHUD()
            }, onError: { error in
                self.dismissHUD()
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
            cell.setGrayBorder()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == incomeData.count - 1, let destinationVc = R.storyboard.calculator.calculationViewController() {
            destinationVc.modalPresentationStyle = .overFullScreen
            self.present(destinationVc, animated: true, completion: nil)
        }
    }
    
}
