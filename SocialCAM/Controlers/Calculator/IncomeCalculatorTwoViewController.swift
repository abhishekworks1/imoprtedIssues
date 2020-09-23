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
    
    @IBOutlet weak var txtDirectReferCount: UITextField!
    @IBOutlet weak var txtLevel2ReferCount: UITextField!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var lblNavigationTitle: UILabel!
    @IBOutlet var tableViewSectionHeader: UIView!
    @IBOutlet weak var lblPercentageFilled: UILabel!
    @IBOutlet weak var lblAverageInAppPurchase: UILabel!
    
    // MARK: -
    // MARK: - Variables
    
    private var averageInAppPurchase = 2 {
        didSet {
            self.lblAverageInAppPurchase.text = "$" + averageInAppPurchase.description
        }
    }
    private var percentageFilled = 10 {
        didSet {
            self.lblPercentageFilled.text = percentageFilled.description + "%"
        }
    }
    internal var isCalculatorThree = false
    private var directRefferals = 0
    private var levelTwoRefferals = 0
    private var totalCount = 0
    private var referLimit = 0
    private var levelTwoReferLimit = 0
    private var incomeData = [(String, String)]()
    private var totalFollowerCount = 0
    private var totalIncomeCount = 0
    
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

    
    @IBAction func percentageSliderValueChanged(_ sender: UISlider) {
        self.percentageFilled = Int(sender.value)
    }
    
    @IBAction func inAppSliderChanged(_ sender: UISlider) {
        self.averageInAppPurchase = Int(sender.value)
    }
    
    // MARK: -
    // MARK: - Class Functions
    
    private func validateAndCalculate() {
        self.view.endEditing(true)
        if let directReferCount = self.txtDirectReferCount.text, let levelTwoReferCount = self.txtLevel2ReferCount.text, let directReferCountInt = Int(directReferCount), let levelTwoReferCountInt = Int(levelTwoReferCount) {
            self.directRefferals = directReferCountInt
            self.levelTwoRefferals = levelTwoReferCountInt
            self.calculateIncome()
            tableview.isHidden = false
            self.tableview.reloadData()
        } else {
            self.showAlert(alertMessage: R.string.localizable.incomeCalculatorAlertMessage("\(self.directRefferals)", "\(self.levelTwoReferLimit)"))
        }
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
                incomeData.append((followers.description, income.description))
            } else {
                incomeData.append((totalFollowerCount.description, totalIncomeCount.description))
            }
        }
    }
    
    private func getIncome(followers: Int, indexPath: IndexPath) -> String {
        switch indexPath.row {
        case 0:
            let income = Int(followers * self.referLimit * percentageFilled * averageInAppPurchase / 10000)
            return income.description
        case 1:
            let income = Int(followers * self.levelTwoReferLimit * percentageFilled * averageInAppPurchase / 10000)
            return income.description
        default:
            return self.totalIncomeCount.description
        }
    }
    
    private func getCalculatorConfig() {
        if UIApplication.checkInternetConnection() {
            self.showHUD()
            ProManagerApi.getCalculatorConfig.request(CalculatorConfigurationModel.self).subscribe(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                self.dismissHUD()
                if let calcConfig = response.result?.first(where: { $0.type == (self.isCalculatorThree ? "potential_income_2" : "potential_income_3") }) {
                    self.referLimit = calcConfig.level1 ?? self.referLimit
                    self.levelTwoReferLimit = calcConfig.level2 ?? self.levelTwoReferLimit
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
