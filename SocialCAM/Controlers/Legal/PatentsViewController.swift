//
//  PatentsViewController.swift
//  SocialCAM
//
//  Created by Meet Mistry on 30/09/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit

class PatentsViewController: UIViewController {

    // MARK: - Outlets Declaration
    @IBOutlet weak var lblPatentDesciption: UILabel!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Action Methods
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
