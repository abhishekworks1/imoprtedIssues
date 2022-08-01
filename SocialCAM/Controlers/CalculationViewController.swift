//
//  calculationViewController.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 19/10/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit

class CalculationViewController: UIViewController {
    
    // MARK: -
    // MARK: - Outlets
    
    @IBOutlet weak var btnTotalFollowers: UIButton!
    @IBOutlet weak var btnTotalIncome: UIButton!
    
    // MARK: -
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setAttributtedFontColors()
    }
    
    // MARK: -
    // MARK: - Class Functions
    
    private func setAttributtedFontColors() {
        var attributedString = NSMutableAttributedString(string: btnTotalFollowers.titleLabel?.text ?? "", attributes: [
          .font: UIFont.systemFont(ofSize: 17.0, weight: .medium),
          .foregroundColor: UIColor.black,
          .kern: 0.04
        ])
        attributedString.addAttribute(.foregroundColor, value: R.color.calculatorButtonColor() ?? UIColor.blue, range: NSRange(location: 15, length: 3))
        self.btnTotalFollowers.setAttributedTitle(attributedString, for: .normal)
        
        attributedString = NSMutableAttributedString(string: btnTotalIncome.titleLabel?.text ?? "", attributes: [
          .font: UIFont.systemFont(ofSize: 17.0, weight: .medium),
          .foregroundColor: UIColor.black,
          .kern: 0.04
        ])
        attributedString.addAttribute(.foregroundColor, value: R.color.calculatorButtonColor() ?? UIColor.blue, range: NSRange(location: 17, length: 3))
        self.btnTotalIncome.setAttributedTitle(attributedString, for: .normal)
    }
    
    // MARK: -
    // MARK: - Button Action Methods
    
    @IBAction func btnCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnDirectRefferalHelpTapped(_ sender: Any) {
        self.showCustomAlert(message: R.string.localizable.levelOneToolTipText())
    }
    
    @IBAction func btnLevelTwoRefferalHelpTapped(_ sender: Any) {
        self.showCustomAlert(message: R.string.localizable.levelTwoToolTipText())
    }
    
    @IBAction func btnLevelThreeRefferalHelpTapped(_ sender: Any) {
        self.showCustomAlert(message: R.string.localizable.levelThreeToolTipText())
    }
    
    @IBAction func btnPercentageHelpTapped(_ sender: Any) {
        self.showCustomAlert(message: R.string.localizable.percentageToolTipText())
    }
    
    @IBAction func btnInAppHelpTapped(_ sender: Any) {
        self.showCustomAlert(message: R.string.localizable.inAppToolTipText())
    }
    
    @IBAction func btnLevelTwoInAppHelpTapped(_ sender: Any) {
        self.showCalculationAlert(message: R.string.localizable.levelTwoInAppHelpText(), total: "= 50")
    }
    
    @IBAction func btnLevelThreeInAppHelpTapped(_ sender: Any) {
        self.showCalculationAlert(message: R.string.localizable.levelThreeInAppHelpText(), total: "= 200")
    }
    
    @IBAction func btnLevelOneIncomeHelpTapped(_ sender: Any) {
        self.showCalculationAlert(message: R.string.localizable.levelOneIncomeHelpText(), total: R.string.localizable.fiveDollars())
    }
    
    @IBAction func btnLevelTwoIncomeHelpTapped(_ sender: Any) {
        self.showCalculationAlert(message: R.string.localizable.levelTwoIncomeHelpText(), total: R.string.localizable.twentyFiveDollars())
    }
    
    @IBAction func btnLevelThreeIncomeHelpTapped(_ sender: Any) {
        self.showCalculationAlert(message: R.string.localizable.levelThreeIncomeHelpText(), total: R.string.localizable.twentyDollars())
    }
    
    @IBAction func btnTotalInAppHelpTapped(_ sender: Any) {
        self.showCalculationAlert(message: R.string.localizable.totalInAppHelpText(), total: "= 260")
    }
    
    @IBAction func btnTotalIncomeHelpTapped(_ sender: Any) {
        self.showCalculationAlert(message: R.string.localizable.totalIncomeHelpText(), total: R.string.localizable.fiftyDollars())
    }
    
}
