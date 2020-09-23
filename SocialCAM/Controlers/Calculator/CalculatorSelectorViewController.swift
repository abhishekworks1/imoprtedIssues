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
    // MARK: - Button Action Methods
    
    @IBAction func btnPotentialFollowersTapped(_ sender: Any) {
        self.dismiss(animated: true) { [weak self] in
            guard let uSelf = self else { return }
            uSelf.buttonAction?(0)
        }
    }
    
    @IBAction func btnCalculatorOneTapped(_ sender: Any) {
        self.dismiss(animated: true) { [weak self] in
            guard let uSelf = self else { return }
            uSelf.buttonAction?(1)
        }
    }
    
    @IBAction func btnCalculatorTwoTapped(_ sender: Any) {
        self.dismiss(animated: true) { [weak self] in
            guard let uSelf = self else { return }
            uSelf.buttonAction?(2)
        }
    }
    
    @IBAction func btnCalculatorThreeTapped(_ sender: Any) {
        self.dismiss(animated: true) { [weak self] in
            guard let uSelf = self else { return }
            uSelf.buttonAction?(3)
        }
    }
    
    @IBAction func btnDismissTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
