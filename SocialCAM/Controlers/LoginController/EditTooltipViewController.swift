//
//  EditTooltipViewController.swift
//  SocialCAM
//
//  Created by Nilisha Gupta on 04/10/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit

class EditTooltipViewController: UIViewController {
    
    // MARK: - Outlets Declaration
    @IBOutlet var editTooltipsButtons: [UIButton]!
    @IBOutlet weak var lblEditTooltip: UILabel!
    @IBOutlet var btnSkipEditTooltip: UIButton!
    
    // MARK: - Variable Declarations
    var editTooltipText = Constant.EditTooltip.editTooltipTextArray
    var editTooltipCount = 0
    
    // MARK: - View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showEditTooltip()
    }
    
    func showEditTooltip() {
        editTooltipsButtons?.first?.alpha = 1
        lblEditTooltip.text = editTooltipText.first
    }
    
    // MARK: - Action Methods
    @IBAction func editTooltipSkipButtonClicked(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editTooltipTapView(_ sender: UITapGestureRecognizer) {
        editTooltipCount += 1
        if let btnEditTooltipCount = editTooltipsButtons?.count {
            for btnCount in 0...btnEditTooltipCount - 1 {
                if editTooltipCount == btnCount {
                    if btnCount == btnEditTooltipCount - 1 {
                        btnSkipEditTooltip.isHidden = true
                    }
                    editTooltipsButtons?[btnCount].alpha = 1
                    lblEditTooltip.text = editTooltipText[btnCount]
                } else {
                    editTooltipsButtons?[btnCount].alpha = 0
                }
            }
            if editTooltipCount == btnEditTooltipCount {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}
