//
//  TooltipViewController.swift
//  SocialCAM
//
//  Created by Nilisha Gupta on 26/04/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit

class TooltipViewController: UIViewController {
    
    // MARK: - Outlets declaration
    @IBOutlet weak var imgViewTooltip: UIImageView!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    // MARK: - Variables declaration
    var gifArray = ["Tooltip1", "Tooltip2", "Tooltip3", "Tooltip4", "Tooltip5"]
    var gifCount = 0
    var pushFromSettingScreen = false
    
    // MARK: - View life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        addGifToImageView(gifName: gifArray.first ?? R.string.localizable.tooltip1())
    }
    
    private func addGifToImageView(gifName: String) {
        imgViewTooltip.loadGif(name: gifName)
    }
    
    // MARK: - Action mehtods
    @IBAction func btnSkipClicked(_ sender: UIButton) {
        if pushFromSettingScreen {
            navigationController?.popViewController(animated: true)
        } else {
            let cameraNavVC = R.storyboard.storyCameraViewController.storyCameraViewNavigationController()
            cameraNavVC?.navigationBar.isHidden = true
            Utils.appDelegate?.window?.rootViewController = cameraNavVC
        }
    }
    
    @IBAction func btnNextClicked(_ sender: UIButton) {
        gifCount += 1
        if (gifCount == 5) {
            btnSkipClicked(sender)
        } else {
            addGifToImageView(gifName: gifArray[gifCount])
            if gifCount == 4 {
                btnNext.setTitle(R.string.localizable.done(), for: .normal)
                btnSkip.isHidden = true
            }
        }
    }
    
}
