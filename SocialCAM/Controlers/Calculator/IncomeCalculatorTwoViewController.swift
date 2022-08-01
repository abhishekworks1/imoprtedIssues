//
//  IncomeCalculatorTwoViewController.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 14/09/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit

class IncomeCalculatorTwoViewController: UIViewController {
    
    // MARK: -
    // MARK: - Outlets
    
    @IBOutlet weak var lblLegal: UILabel!
    @IBOutlet var viewLegalNotice: UIView!
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
    @IBOutlet weak var viewSliderContainer: UIView!
    @IBOutlet weak var sliderContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblFixedInAppPurchase: UILabel!
    @IBOutlet weak var btnInAppHelp: UIButton!
    @IBOutlet weak var inAppPurchaseTopConstraint: NSLayoutConstraint!
    
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
    internal var isLiteCalculator = false
    internal var calculatorType = CalculatorType.incomeTwo
    private var directRefferals = 0
    private var levelTwoRefferals = 0
    private var totalCount = 0
    private var levelOnePercentage = 0
    private var levelTwoPercentage = 0
    private var incomeData = [(Int, Double)]()
    private var totalFollowerCount = 0
    private var totalIncomeCount: Double = 0
    private var percentageArray: [Int] {
        return [levelOnePercentage, levelTwoPercentage]
    }
    private var levels = [Int]()
    
    
    // MARK: -
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.tableFooterView = viewLegalNotice
        lblNavigationTitle.text = calculatorType.getNavigationTitle()
        self.setupUiForLiteApps()
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
    
    @IBAction func percentageSliderValueChanged(_ sender: UISlider) {
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
    
    @IBAction func levelOneHelpTapped(_ sender: UIButton) {
        showCustomAlert(message: R.string.localizable.levelOneToolTipText())
    }
    
    @IBAction func levelTwoHelpTapped(_ sender: UIButton) {
        showCustomAlert(message: R.string.localizable.levelTwoToolTipText())
    }
    
    @IBAction func percentageHelpTapped(_ sender: UIButton) {
        showCustomAlert(message: R.string.localizable.percentageToolTipText())
    }
    
    @IBAction func inAppHelpTapped(_ sender: UIButton) {
        showCustomAlert(message: R.string.localizable.inAppToolTipText())
    }
    
    // MARK: -
    // MARK: - Class Functions
    
    private func configureUI(configuration: [CalculatorConfigurationData]?) {
        if let calcConfig = configuration?.first(where: { $0.type == (self.calculatorType.rawValue) }) {
            self.levelOneSlider.maximumValue = Float(calcConfig.maxLevel1 ?? 0)
            self.levelTwoSlider.maximumValue = Float(calcConfig.maxLevel2 ?? 0)
            self.inAppSlider.maximumValue = Float(calcConfig.inAppPurchaseLimit ?? 0)
            self.levelOnePercentage = calcConfig.levelsArray?[0] ?? self.levelOnePercentage
            self.levelTwoPercentage = calcConfig.levelsArray?[1] ?? self.levelOnePercentage
        }
    }
    
    private func setupUiForLiteApps() {
        if isLiteCalculator {
            self.inAppPurchaseTopConstraint.constant = 20
            self.btnInAppHelp.isHidden = false
            self.lblFixedInAppPurchase.isHidden = false
            self.percentageFilled = 100
            self.averageInAppPurchase = 1
            self.sliderContainerHeightConstraint.constant = 0
            self.viewSliderContainer.isHidden = true
            self.inAppSlider.isHidden = true
            self.lblAverageInAppPurchase.isHidden = true
        } else {
            self.sliderContainerHeightConstraint.constant = 0
            self.percentageFilled = 100
            self.viewSliderContainer.isHidden = true
        }
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
            let income = Double(self.getIncome(followers: followers, indexPath: IndexPath(row: index, section: 0))) ?? 0
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
        var income: Float = 0
        switch indexPath.row {
        case 0:
            income = Float(followers) * Float(self.levelOnePercentage) * Float(percentageFilled) * Float(averageInAppPurchase) / 10000
        case 1:
            income = Float(followers) * Float(self.levelTwoPercentage) * Float(percentageFilled) * Float(averageInAppPurchase) / 10000
        default:
            return self.totalIncomeCount.description
        }
        if isLiteApp {
            return income.roundToPlaces(places: 1).description
        } else {
            return Int(income).description
        }
    }
    
    private func getCalculatorConfig(type: String) {
        if UIApplication.checkInternetConnection() {
            ProManagerApi.getCalculatorConfig(type: type).request(CalculatorConfigurationModel.self).subscribe(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
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

extension IncomeCalculatorTwoViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.incomeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.incomeCalculator2TableViewCell.identifier) as? IncomeCalculatorTableViewCell else { return UITableViewCell() }
        if indexPath.row == incomeData.count - 1 {
            cell.setBlueBorder()
            cell.setData(level: R.string.localizable.total(), followers: CommonFunctions.getFormattedNumberString(number: self.incomeData[indexPath.row].0), income: CommonFunctions.getFormattedNumberString(number: self.incomeData[indexPath.row].1))
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == incomeData.count - 1, let destinationVc = R.storyboard.calculator.calculationViewController() {
            destinationVc.modalPresentationStyle = .overFullScreen
            self.present(destinationVc, animated: true, completion: nil)
        }
    }
    
}
