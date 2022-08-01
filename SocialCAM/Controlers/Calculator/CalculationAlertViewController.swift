//
//  CalculationAlertViewController.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 20/10/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit

class CalculationAlertViewController: UIViewController {

    // MARK: -
    // MARK: - Outlets
    
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    
    // MARK: -
    // MARK: - Variables
    
    internal var message = ""
    internal var total = ""

    // MARK: -
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMessage(message: self.message, total: self.total)
    }

    // MARK: -
    // MARK: - Class Functions
    
    internal func setMessage(message: String, total: String) {
        self.lblMessage.text = message
        self.lblTotal.text = total
    }

    // MARK: -
    // MARK: - Button Action Methods

    @IBAction func btnCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
