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
    @IBOutlet weak var btnPic2ArtSkip: UIButton!
    @IBOutlet weak var btnPic2ArtNext: UIButton!
    
    // MARK: - Variables declaration
    var gifArray = ["Tooltip1", "Tooltip2", "Tooltip3", "Tooltip4", "Tooltip5"]
    var pic2ArtGifArray = ["Pic2ArtTooltip1", "Pic2ArtTooltip2"]
    var gifCount = 0
    var pushFromSettingScreen = false
    var isPic2ArtGif = false
    
    // MARK: - View life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if isPic2ArtGif {
            hideShowSkipNextButton(shouldShow: false)
            addGifToImageView(gifName: pic2ArtGifArray.first ?? "Pic2ArtTooltip1")
        } else {
            hideShowSkipNextButton(shouldShow: true)
            addGifToImageView(gifName: gifArray.first ?? R.string.localizable.tooltip1())
        }
    }
    
    private func addGifToImageView(gifName: String) {
        imgViewTooltip.loadGif(name: gifName)
    }
    
    private func hideShowSkipNextButton(shouldShow: Bool) {
        btnPic2ArtSkip.isHidden = shouldShow
        btnPic2ArtNext.isHidden = shouldShow
        btnSkip.isHidden = !shouldShow
        btnNext.isHidden = !shouldShow
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
        if isPic2ArtGif {
            if (gifCount == 2) {
                btnSkipClicked(sender)
            } else {
                addGifToImageView(gifName: pic2ArtGifArray[gifCount])
                if gifCount == 1 {
                    btnPic2ArtNext.setTitle(R.string.localizable.done(), for: .normal)
                    btnPic2ArtSkip.isHidden = true
                }
            }
        } else {
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
    
}
