//
//  CalculatorViewController.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 08/09/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit

class IncomeCalculatorFourTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var viewInAppPurchase: UIView!
    @IBOutlet weak var lblIncome: UILabel!
    @IBOutlet weak var viewIncome: UIView!
    
    internal func setBlueBorder() {
        self.viewInAppPurchase.layer.borderColor = R.color.calculatorButtonColor()?.cgColor
        self.viewInAppPurchase.backgroundColor = R.color.calculatorButtonColor()?.withAlphaComponent(0.1)
        self.viewIncome.layer.borderColor = R.color.calculatorButtonColor()?.cgColor
        self.viewIncome.backgroundColor = R.color.calculatorButtonColor()?.withAlphaComponent(0.1)
    }
    
    internal func setGrayBorder() {
        self.viewInAppPurchase.layer.borderColor = R.color.cellViewBorderColor()?.cgColor ?? UIColor.gray.cgColor
        self.viewInAppPurchase.backgroundColor = R.color.cellViewBackgroundColor()
        self.viewIncome.layer.borderColor = R.color.cellViewBorderColor()?.cgColor ?? UIColor.gray.cgColor
        self.viewIncome.backgroundColor = R.color.cellViewBackgroundColor()
    }
    
    internal func setData(level: String, followers: String, income: String) {
        self.lblLevel.text = level
        self.lblFollowers.text = followers
        self.lblIncome.text = "$" + income
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
    @IBOutlet weak var lblPotentialIncome: UILabel!
    @IBOutlet weak var lblPercentage: UILabel!
    @IBOutlet weak var lblInAppPurchase: UILabel!
    @IBOutlet weak var calculateButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblFixedInAppPurchase: UILabel!
    @IBOutlet weak var btnInAppHelp: UIButton!
    @IBOutlet weak var inAppPurchaseTopConstraint: NSLayoutConstraint!
    
    // MARK: -
    // MARK: - Variables
    
    private var referCount = 0
    private var otherReferCount = 0
    private var totalCount = 0
    private var totalIncome: Double = 0
    private var referLimit = 0
    private var otherReferLimit = 0
    private var percentage = 0 {
        didSet {
            self.percentageSlider.value = Float(percentage)
            self.lblPercentage.text = percentage.description + "%"
        }
    }
    private var inAppPurchase = 0 {
        didSet {
            self.inAppSlider.value = Float(inAppPurchase)
            self.lblInAppPurchase.text = "$" +  inAppPurchase.description
        }
    }
    private var incomeData = [Double]()
    private var followersData = [Int]()
    private var levelOnePercentage = 0
    private var levelTwoPercentage = 0
    private var percentageArray: [Int] = []
    
    // MARK: -
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.tableHeaderView = tableHeaderView
        self.getWebsiteId { [weak self] (type) in
            guard let `self` = self else { return }
            self.getCalculatorConfig(type: type)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableview.tableHeaderView?.frame.size.height = 139
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
        self.lblInnerCircleLimit.text = Int(sender.value).description
    }
    
    @IBAction func extendedCircleSliderChanged(_ sender: UISlider) {
        self.lblExtendedCircleLimit.text = Int(sender.value).description
    }
    
    @IBAction func percentageBarChanged(_ sender: UISlider) {
        self.percentage = Int(sender.value)
    }
    
    @IBAction func inAppSliderChanged(_ sender: UISlider) {
        self.inAppPurchase = Int(sender.value)
    }
    
    @IBAction func directReferHelpTapped(_ sender: UIButton) {
        showCustomAlert(message: R.string.localizable.numberOfPeopleYouPersonallyReferInTheNext612Months())
    }
    
    @IBAction func indirectReferHelpTapped(_ sender: UIButton) {
        showCustomAlert(message: R.string.localizable.averageNumberOfPeopleTheyReferInTheNext612Months())
    }
    
    @IBAction func btnPercentageHelpTapped(_ sender: UIButton) {
        showCustomAlert(message: R.string.localizable.percentageToolTipText())
    }
    
    @IBAction func btnInAppHelpTapped(_ sender: UIButton) {
        showCustomAlert(message: R.string.localizable.inAppToolTipText())
    }
    
    // MARK: -
    // MARK: - Class Functions
    
    private func configureUiForLiteApps() {
        if isLiteApp {
            self.inAppPurchaseTopConstraint.constant = 20
            self.calculateButtonTopConstraint.constant = 20
            self.btnInAppHelp.isHidden = false
            self.inAppPurchase = 1
            self.lblFixedInAppPurchase.isHidden = false
            self.inAppSlider.isHidden = true
            self.lblInAppPurchase.isHidden = true
        }
    }
    
    private func validateAndCalculate() {
        self.view.endEditing(true)
        
        self.referCount = Int(self.innerCircleSlider.value)
        self.otherReferCount = Int(self.extendedCircleSlider.value)
        self.calculateFollowers()
        tableview.isHidden = false
        self.tableview.reloadData()
    }
    
    private func calculateFollowers() {
        if referCount == 0 {
            return
        }
        self.followersData = [self.referCount]
        self.totalCount = self.referCount
        self.followersData = [self.totalCount]
        self.totalIncome = Double(self.getIncome(followers: self.referCount, index: 0)) ?? 0
        self.incomeData = [totalIncome]
        for row in 1...9 {
            let newFollowers = followersData[row - 1] * self.otherReferCount * percentage / 100
            self.followersData.append(newFollowers)
            let newIncome = Double(self.getIncome(followers: newFollowers, index: row)) ?? 0
            incomeData.append(newIncome)
            self.totalCount += newFollowers
            self.totalIncome += newIncome
        }
        self.lblTotalFollowers.text = CommonFunctions.getFormattedNumberString(number: totalCount)
        self.lblTotalIncome.text = CommonFunctions.getFormattedNumberString(number: totalIncome)
    }
    
    private func getIncome(followers: Int, index: Int) -> String {
        var income: Float = 0
        if index == 0 {
            income = Float(followers) * Float(inAppPurchase) * Float(self.percentageArray[index]) / 100
        } else {
            let result = Float(followers) * Float(self.percentageSlider.value) * Float(self.percentageArray[index]) * Float(inAppPurchase)
            income = result / 10000
        }
        return income.roundToPlaces(places: 1).description
    }
    
    private func getCalculatorConfig(type: String) {
        if UIApplication.checkInternetConnection() {
            ProManagerApi.getCalculatorConfig(type: type).request(CalculatorConfigurationModel.self).subscribe(onNext: { (response) in
                if let calcConfig = response.result?.first(where: { $0.type == "potential_income_4"}) {
                    self.innerCircleSlider.maximumValue = Float(calcConfig.maxPersonal ?? 0)
                    self.extendedCircleSlider.maximumValue = Float(calcConfig.maxExtended ?? 0)
                    self.inAppSlider.maximumValue = Float(calcConfig.inAppPurchaseLimit ?? 0)
                    self.percentageArray = calcConfig.levelsArray ?? []
                }
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

extension IncomeCalculatorFourViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return referCount == 0 ? 0 : 11
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.incomeCalculatorFourTableViewCell.identifier) as? IncomeCalculatorFourTableViewCell else { return UITableViewCell() }
        if indexPath.row == 10 {
            cell.setData(level: R.string.localizable.total(), followers: CommonFunctions.getFormattedNumberString(number: totalCount), income: CommonFunctions.getFormattedNumberString(number: totalIncome))
            cell.setBlueBorder()
        } else {
            if indexPath.row >= self.percentageArray.count {
                cell.setData(level: "\(indexPath.row + 1)", followers: CommonFunctions.getFormattedNumberString(number: self.followersData[indexPath.row]), income: CommonFunctions.getFormattedNumberString(number: incomeData[indexPath.row]))
            } else {
                cell.setData(level: "\(indexPath.row + 1)" + " (\(self.percentageArray[indexPath.row])%)", followers: CommonFunctions.getFormattedNumberString(number: self.followersData[indexPath.row]), income: CommonFunctions.getFormattedNumberString(number:  incomeData[indexPath.row]))
            }
            cell.setGrayBorder()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableSectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 10, let destinationVc = R.storyboard.calculator.calculationViewController() {
            destinationVc.modalPresentationStyle = .overFullScreen
            self.present(destinationVc, animated: true, completion: nil)
        }
    }

}
