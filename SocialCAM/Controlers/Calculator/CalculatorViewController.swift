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
        self.viewFollowers.layer.borderColor = R.color.calculatorButtonColor()?.cgColor
        self.viewFollowers.backgroundColor = R.color.calculatorButtonColor()?.withAlphaComponent(0.1)
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
    
    @IBOutlet weak var percentageSlider: CustomSlider!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var innerCircleSlider: UISlider!
    @IBOutlet weak var extendedCircleSlider: UISlider!
    @IBOutlet var tableSectionHeaderView: UIView!
    @IBOutlet weak var lblTotalFollowers: UILabel!
    @IBOutlet var tableHeaderView: UIView!
    @IBOutlet weak var lblPercentageFilled: UILabel!
    @IBOutlet weak var lblInnerCircleCount: UILabel!
    @IBOutlet weak var lblExtendedCircleCount: UILabel!
    
    // MARK: -
    // MARK: - Variables
    
    private var referCount = 0
    private var otherReferCount = 0
    private var totalCount = 0
    private var referLimit = 0
    private var otherReferLimit = 0
    private var percentage = 0 {
        didSet {
            self.percentageSlider.value = Float(percentage)
            self.lblPercentageFilled.text = percentage.description + "%"
        }
    }
    private var followersCount = [Int]()
    
    // MARK: -
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getWebsiteId { [weak self] (type) in
            guard let `self` = self else { return }
            self.getCalculatorConfig(type: type)
        }
        self.tableview.tableHeaderView = tableHeaderView
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
    
    @IBAction func percentageBarChanged(_ sender: UISlider) {
        self.percentage = Int(sender.value)
    }
    
    @IBAction func directReferHelpTapped(_ sender: UIButton) {
        showCustomAlert(message: R.string.localizable.numberOfPeopleYouPersonallyReferInTheNext612Months())
    }
    
    @IBAction func percentageFilledHelpTapped(_ sender: UIButton) {
        showCustomAlert(message: R.string.localizable.percentageToolTipText())
    }
    
    @IBAction func innerCircleSliderChanged(_ sender: UISlider) {
        self.lblInnerCircleCount.text = Int(sender.value).description
    }
    
    @IBAction func extendedCircleSliderChanged(_ sender: UISlider) {
        self.lblExtendedCircleCount.text = Int(sender.value).description
    }
    
    @IBAction func indirectReferHelpTapped(_ sender: UIButton) {
        showCustomAlert(message: R.string.localizable.averageNumberOfPeopleTheyReferInTheNext612Months())
    }
    
    // MARK: -
    // MARK: - Class Functions
    
    private func validateAndCalculate() {
        self.view.endEditing(true)
        self.referCount = Int(self.innerCircleSlider.value)
        self.otherReferCount = Int(self.extendedCircleSlider.value)
        self.calculateFollowers()
        tableview.isHidden = false
        self.tableview.reloadData()
    }
    
    private func calculateFollowers() {
        self.followersCount = [self.referCount]
        self.totalCount = self.referCount
        for row in 1...9 {
            let newFollowers = followersCount[row - 1] * self.otherReferCount * percentage / 100
            self.followersCount.append(newFollowers)
            self.totalCount += newFollowers
        }
        self.lblTotalFollowers.text = CommonFunctions.getFormattedNumberString(number: totalCount)
    }
    
    private func getCalculatorConfig(type: String) {
        if UIApplication.checkInternetConnection() {
            ProManagerApi.getCalculatorConfig(type: type).request(CalculatorConfigurationModel.self).subscribe(onNext: { (response) in
                if let calcConfig = response.result?.first(where: { $0.type == "potential_followers"}) {
                    self.innerCircleSlider.maximumValue = Float(calcConfig.maxLevel ?? 0)
                    self.extendedCircleSlider.maximumValue = Float(calcConfig.maxRefer ?? 0)
                    self.percentage = calcConfig.percentage ?? 0
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

extension CalculatorViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return referCount == 0 ? 0 : 11
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.calculatorCell.identifier) as? CalculatorTableViewCell else { return UITableViewCell() }
        if indexPath.row == 10 {
            cell.setData(level: R.string.localizable.total(), followers: CommonFunctions.getFormattedNumberString(number: totalCount))
            cell.setBlueBorder()
        } else {
            cell.setData(level: "\(indexPath.row + 1)", followers: CommonFunctions.getFormattedNumberString(number: self.followersCount[indexPath.row]))
            cell.setGrayBorder()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableSectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }

}
