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
    
    // MARK: -
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isCalculatorThree {
            lblNavigationTitle.text = "Potential Income Calculator 3"
        }
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
        if self.percentageFilled > 10 {
            self.percentageFilled -= 10
        }
    }
    
    @IBAction func percentagePlusTapped(_ sender: Any) {
        if self.percentageFilled < 100 {
            self.percentageFilled += 10
        }
    }
    
    @IBAction func inAppPurchaseMinusTapped(_ sender: Any) {
        self.averageInAppPurchase += 1
    }
    
    @IBAction func inAppPurchasePlusTapped(_ sender: Any) {
        if self.averageInAppPurchase >= 1 {
            self.averageInAppPurchase -= 1
        }
    }

    // MARK: -
    // MARK: - Class Functions
    
    private func validateAndCalculate() {
        self.view.endEditing(true)
        if let directReferCount = self.txtDirectReferCount.text, let levelTwoReferCount = self.txtLevel2ReferCount.text, let directReferCountInt = Int(directReferCount), let levelTwoReferCountInt = Int(levelTwoReferCount), directReferCountInt <= self.referLimit, levelTwoReferCountInt <= self.levelTwoReferLimit {
            self.directRefferals = directReferCountInt
            self.levelTwoRefferals = levelTwoReferCountInt
            tableview.isHidden = false
            self.tableview.reloadData()
        } else {
            self.showAlert(alertMessage: R.string.localizable.incomeCalculatorAlertMessage("\(self.directRefferals)", "\(self.levelTwoReferLimit)"))
        }
    }
    
    private func getCalculatorConfig() {
        UIApplication.checkInternetConnection()
        self.showHUD()
        ProManagerApi.getCalculatorConfig.request(RootClass.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else { return }
            self.dismissHUD()
            if let calcConfig = response.result?.first(where: { $0.type == "potential_income_2" }) {
                self.referLimit = calcConfig.level1 ?? self.referLimit
                self.levelTwoReferLimit = calcConfig.level2 ?? self.levelTwoReferLimit
                self.percentageFilled = calcConfig.percentage ?? 0
                self.averageInAppPurchase = calcConfig.level1 ?? 0
            }
        }, onError: { error in
            print(error)
        }, onCompleted: {
            print("Compl")
        }).disposed(by: rx.disposeBag)
    }
    
}

// MARK: -
// MARK: - UITableView Delegate and DataSource

extension IncomeCalculatorTwoViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.incomeCalculator2TableViewCell.identifier) as? IncomeCalculatorTableViewCell else { return UITableViewCell() }
        if indexPath.row == 2 {
            cell.setData(level: "Total", followers: self.totalCount.description)
            cell.setBlueBorder()
        } else {
            cell.setData(level: (indexPath.row + 1).description, followers: self.getNoOfPeople(indexPath: indexPath))
        }
        return cell
    }
    
    private func getNoOfPeople(indexPath: IndexPath) -> String {
        switch indexPath.row {
        case 0:
            totalCount = 0
            totalCount += self.directRefferals
            return self.directRefferals.description
        case 1:
            totalCount += Int(self.directRefferals * self.levelTwoRefferals)
            return Int(self.directRefferals * self.levelTwoRefferals).description
        case 2:
            return self.totalCount.description
        default:
            break
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableViewSectionHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 132
    }
    
}
