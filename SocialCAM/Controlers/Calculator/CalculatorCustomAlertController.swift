//
//  CalculatorCustomAlertController.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 20/10/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit

class CalculatorCustomAlertController: UIViewController {

    // MARK: -
    // MARK: - Outlets
    
    @IBOutlet weak var lblMessage: UILabel!
    
    // MARK: -
    // MARK: - Variables
    
    internal var message = ""

    // MARK: -
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMessage(message: self.message)
    }

    // MARK: -
    // MARK: - Class Functions
    
    internal func setMessage(message: String) {
        self.lblMessage.text = message
    }

    // MARK: -
    // MARK: - Button Action Methods

    @IBAction func btnCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
