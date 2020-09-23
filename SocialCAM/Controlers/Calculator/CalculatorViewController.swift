//
//  CalculatorViewController.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 08/09/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit

class CalculatorTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var viewFollowers: UIView!
    
    internal func setBlueBorder() {
        self.viewFollowers.layer.borderColor = UIColor.blue.cgColor
        self.viewFollowers.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
    }
    
    internal func setGrayBorder() {
        self.viewFollowers.layer.borderColor = R.color.cellViewBorderColor()?.cgColor ?? UIColor.gray.cgColor
        self.viewFollowers.backgroundColor = R.color.cellViewBackgroundColor()
    }
    
    internal func setData(level: String, followers: String) {
        self.lblLevel.text = level
        self.lblFollowers.text = followers
    }
    
}

class CalculatorViewController: UIViewController {
    
    // MARK: -
    // MARK: - Outlets
    
    @IBOutlet weak var txtReferCount: UITextField!
    @IBOutlet weak var txtOtherReferCount: UITextField!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet var tableSectionHeaderView: UIView!
    @IBOutlet weak var lblTotalFollowers: UILabel!
    @IBOutlet var tableHeaderView: UIView!
    @IBOutlet weak var lblPercentageFilled: UILabel!
    
    // MARK: -
    // MARK: - Variables
    
    private var referCount = 0
    private var otherReferCount = 0
    private var totalCount = 0
    private var referLimit = 0
    private var otherReferLimit = 0
    private var percentage = 10 {
        didSet {
            self.lblPercentageFilled.text = percentage.description + "%"
        }
    }
    private var followersCount = [String]()
    
    // MARK: -
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.tableHeaderView = tableHeaderView
        lblPercentageFilled.font = R.font.sfuiTextSemibold(size: 15.0) ?? UIFont.systemFont(ofSize: 15.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getCalculatorConfig()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableview.tableHeaderView?.frame.size.height = 126
    }

    // MARK: -
    // MARK: - Button Action Methods
    
    @IBAction func btnCalculateTapped(_ sender: Any) {
        self.validateAndCalculate()
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btnPlusTapped(_ sender: Any) {
        if self.percentage < 100 {
            percentage += 1
        }
    }
    
    @IBAction func btnMinusTapped(_ sender: Any) {
        if self.percentage > 1 {
            percentage -= 1
        }
    }
    
    // MARK: -
    // MARK: - Class Functions
    
    private func validateAndCalculate() {
        self.view.endEditing(true)
        if let referCount = self.txtReferCount.text, let otherReferCount = self.txtOtherReferCount.text, let referCountInt = Int(referCount), let otherReferCountInt = Int(otherReferCount), referCountInt <= self.referLimit, otherReferCountInt <= self.otherReferLimit {
            self.referCount = referCountInt
            self.otherReferCount = otherReferCountInt
            self.calculateFollowers()
            tableview.isHidden = false
            self.tableview.reloadData()
        } else {
            self.showAlert(alertMessage: R.string.localizable.referCountAlertMessage("\(self.referLimit)", "\(self.otherReferLimit)"))
        }
    }
    
    private func calculateFollowers() {
        self.followersCount = []
        self.totalCount = 0
        for row in 0...referCount - 1 {
            self.followersCount.append(self.getFollowers(indexPath: IndexPath(row: row, section: 0)))
        }
        self.lblTotalFollowers.text = totalCount.description
    }
    
    private func getCalculatorConfig() {
        if UIApplication.checkInternetConnection() {
            self.showHUD()
            ProManagerApi.getCalculatorConfig.request(CalculatorConfigurationModel.self).subscribe(onNext: { (response) in
                self.dismissHUD()
                if let calcConfig = response.result?.first(where: { $0.type == "potential_followers"}) {
                    self.referLimit = calcConfig.maxRefer ?? self.referLimit
                    self.otherReferLimit = calcConfig.maxAverageRefer ?? self.otherReferLimit
                    self.percentage = calcConfig.percentage ?? 0
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

extension CalculatorViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return referCount + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.calculatorCell.identifier) as? CalculatorTableViewCell else { return UITableViewCell() }
        if indexPath.row == referCount {
            cell.setData(level: "Total", followers: self.totalCount.description)
            cell.setBlueBorder()
        } else {
            cell.setData(level: "\(indexPath.row + 1)", followers: self.followersCount[indexPath.row])
            cell.setGrayBorder()
        }
        return cell
    }
    
    private func getFollowers(indexPath: IndexPath) -> String {
        let followers = referCount * Int(pow(Double(otherReferCount), Double(indexPath.row + 1))) * percentage/100
        totalCount += followers
        return followers.description
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableSectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }

}
