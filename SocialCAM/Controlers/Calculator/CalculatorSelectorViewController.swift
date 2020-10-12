//
//  CalculatorSelectorViewController.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 16/09/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit

class CalculatorSelectorViewController: UIViewController {
    
    // MARK: -
    // MARK: - Variables
    
    internal var buttonAction: ((Int) -> Void)?
    
    // MARK: -
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: -
    // MARK: - Class Functions
    
    func goToCalculatosScreen(index: Int) {
        switch index {
        case 0:
            guard let destinationVc = R.storyboard.calculator.calculatorViewController() else { return }
            self.navigationController?.pushViewController(destinationVc, animated: true)
        case 1:
            guard let destinationVc = R.storyboard.calculator.incomeCalculatorOne() else { return }
            self.navigationController?.pushViewController(destinationVc, animated: true)
        case 2:
            guard let destinationVc = R.storyboard.calculator.incomeCalculatorTwo() else { return }
            self.navigationController?.pushViewController(destinationVc, animated: true)
        case 3:
            guard let destinationVc = R.storyboard.calculator.incomeCalculatorTwo() else { return }
            destinationVc.isCalculatorThree = true
            self.navigationController?.pushViewController(destinationVc, animated: true)
        case 4:
            guard let destinationVc = R.storyboard.calculator.incomeCalculatorFourViewController() else { return }
            self.navigationController?.pushViewController(destinationVc, animated: true)
        default:
            break
        }
    }
    
    // MARK: -
    // MARK: - Button Action Methods
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPotentialFollowersTapped(_ sender: Any) {
        self.goToCalculatosScreen(index: 0)
    }
    
    @IBAction func btnCalculatorOneTapped(_ sender: Any) {
        self.goToCalculatosScreen(index: 1)
    }
    
    @IBAction func btnCalculatorTwoTapped(_ sender: Any) {
        self.goToCalculatosScreen(index: 2)
    }
    
    @IBAction func btnCalculatorThreeTapped(_ sender: Any) {
        self.goToCalculatosScreen(index: 3)
    }
    
    @IBAction func btnCalculatorFourTapped(_ sender: Any) {
        self.goToCalculatosScreen(index: 4)
    }
    
}
