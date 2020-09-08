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
        self.viewFollowers.layer.borderColor = UIColor.blue.cgColor
        self.viewFollowers.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        self.viewIncome.layer.borderColor = UIColor.blue.cgColor
        self.viewIncome.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
    }
    
    internal func setData(level: String, followers: String, income: String) {
        self.lblLevel.text = level
        self.lblFollowers.text = followers
        self.lblIncome.text = "$" + income
    }
    
}

class IncomeCalculatorOneViewController: UIViewController {
    
    // MARK: -
    // MARK: - Outlets
    
    @IBOutlet weak var txtDirectReferCount: UITextField!
    @IBOutlet weak var txtLevel2ReferCount: UITextField!
    @IBOutlet weak var txtLevel3ReferCount: UITextField!
    @IBOutlet weak var lblAverageInAppPurchase: UILabel!
    @IBOutlet weak var lblPercentageFilled: UILabel!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet var tableSectionHeaderView: UIView!
    
    // MARK: -
    // MARK: - Variables
    
    private var incomeData = [(String, String)]()
    private var averageInAppPurchase = 2 {
        didSet {
            self.lblAverageInAppPurchase.text = "$" + averageInAppPurchase.description
        }
    }
    private var percentageFilled = 100 {
        didSet {
            self.lblPercentageFilled.text = percentageFilled.description + "%"
        }
    }
    private var directRefferals = 0
    private var levelTwoRefferals = 0
    private var levelThreeRefferals = 0
    private var totalFollowerCount = 0
    private var totalIncomeCount = 0
    private var referLimit = 0
    private var levelTwoReferLimit = 0
    private var levelThreeReferLimit = 0
    
    // MARK: -
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblPercentageFilled.font = R.font.sfuiTextSemibold(size: 15.0) ?? UIFont.systemFont(ofSize: 15.0)
        lblAverageInAppPurchase.font = R.font.sfuiTextSemibold(size: 15.0) ?? UIFont.systemFont(ofSize: 15.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getCalculatorConfig()
    }
    
    // MARK: -
    // MARK: - Button Action Methods
    
    @IBAction func btnCalculateTapped(_ sender: Any) {
        self.validateAndCalculate()
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func percentageMinusTapped(_ sender: Any) {
        if self.percentageFilled > 1 {
            self.percentageFilled -= 1
        }
    }
    
    @IBAction func percentagePlusTapped(_ sender: Any) {
        if self.percentageFilled < 100 {
            self.percentageFilled += 1
        }
    }
    
    @IBAction func inAppPurchaseMinusTapped(_ sender: Any) {
        if self.averageInAppPurchase > 1 {
            self.averageInAppPurchase -= 1
        }
    }
    
    @IBAction func inAppPurchasePlusTapped(_ sender: Any) {
        if self.averageInAppPurchase < 35 {
            self.averageInAppPurchase += 1
        }
    }
    
    // MARK: -
    // MARK: - Class Functions
    
    private func validateAndCalculate() {
        self.view.endEditing(true)
        if let directReferCount = self.txtDirectReferCount.text, let levelTwoReferCount = self.txtLevel2ReferCount.text, let levelThreeReferCount = self.txtLevel3ReferCount.text, let directReferCountInt = Int(directReferCount), let levelTwoReferCountInt = Int(levelTwoReferCount), let levelThreeReferCountInt = Int(levelThreeReferCount) {
            self.directRefferals = directReferCountInt
            self.levelTwoRefferals = levelTwoReferCountInt
            self.levelThreeRefferals = levelThreeReferCountInt
            self.calculateIncome()
            tableview.isHidden = false
            self.tableview.reloadData()
        } else {
            self.showAlert(alertMessage: R.string.localizable.levelThreeReferCountAlertMessage("\(self.directRefferals)", "\(self.levelTwoReferLimit)", "\(self.levelThreeRefferals)"))
        }
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
                incomeData.append((followers.description, income.description))
            } else {
                incomeData.append((totalFollowerCount.description, totalIncomeCount.description))
            }
        }
    }
    
    private func getCalculatorConfig() {
        if UIApplication.checkInternetConnection() {
            self.showHUD()
            ProManagerApi.getCalculatorConfig.request(CalculatorConfigurationModel.self).subscribe(onNext: { (response) in
                self.dismissHUD()
                if let calcConfig = response.result?.first(where: { $0.type == "potential_income_1" }) {
                    self.referLimit = calcConfig.level1 ?? self.referLimit
                    self.levelTwoReferLimit = calcConfig.level2 ?? self.levelTwoReferLimit
                    self.levelThreeReferLimit = calcConfig.level3 ?? self.levelThreeReferLimit
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
        cell.setData(level: (indexPath.row + 1).description, followers: self.incomeData[indexPath.row].0, income: self.incomeData[indexPath.row].1)
        if indexPath.row == incomeData.count - 1 {
            cell.setBlueBorder()
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
            let income = Int(followers * self.referLimit * percentageFilled * averageInAppPurchase / 10000)
            return income.description
        case 1:
            let income = Int(followers * 25 * self.levelTwoReferLimit * averageInAppPurchase / 10000)
            return income.description
        case 2:
            let income = Int(followers * 5 * self.levelThreeReferLimit * averageInAppPurchase / 10000)
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
