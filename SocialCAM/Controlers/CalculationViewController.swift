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
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @IBAction func btnTotalInAppHelpTapped(_ sender: Any) {
    }
    
    @IBAction func btnTotalIncomeHelpTapped(_ sender: Any) {
    }
    
}
