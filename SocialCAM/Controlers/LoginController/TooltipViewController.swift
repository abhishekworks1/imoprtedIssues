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
    @IBOutlet weak var btnSkipEditTooltip: UIButton!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var signupTooltipView: UIView!
    
    // MARK: - Variables declaration
    var gifArray = ["Tooltip1", "Tooltip2", "Tooltip3", "Tooltip6", "Tooltip4", "Tooltip5"]
    var cameraGifArray = ["CameraTooltip1","CameraTooltip2","CameraTooltip3","CameraTooltip4",]
    var pic2ArtGifArray = ["Pic2ArtTooltip"]
    var editGifArray = ["EditTooltip1"]
   
    var editTooltip = ["editTooltip1", "editTooltip2", "editTooltip3", "editTooltip4", "editTooltip5", "editTooltip6", "editTooltip7", "editTooltip8", "editTooltip9"]
    var quickLinkGifArray = ["QuickLinkTooltip1", "QuickLinkTooltip2"]
    var gifCount = 0
    var pushFromSettingScreen = false
    var isPic2ArtGif = false
    var isEditScreenTooltip = false
    var isQuickLinkTooltip = false
    var isCameraGif = false
    
    // MARK: - View life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if isPic2ArtGif {
            hideShowSkipNextButton(shouldShow: false)
            addGifToImageView(gifName: pic2ArtGifArray.first ?? R.string.localizable.pic2ArtTooltip1())
            btnPic2ArtNext.setTitle(R.string.localizable.done(), for: .normal)
            btnPic2ArtSkip.isHidden = true
        } else if isEditScreenTooltip {
//            hideButtonsForEditTooltip()
//            addEditTooltipToImgView(imgName: editTooltip.first ?? R.string.localizable.editTooltip1())
            hideShowSkipNextButton(shouldShow: false)
            addGifToImageView(gifName: editGifArray.first ?? R.string.localizable.tooltip1())
            btnPic2ArtNext.setTitle(R.string.localizable.done(), for: .normal)
            btnPic2ArtSkip.isHidden = true
        } else if isQuickLinkTooltip {
            hideShowSkipNextButton(shouldShow: false)
            addGifToImageView(gifName: quickLinkGifArray.first ?? R.string.localizable.quickLinkTooltip1())
        } else {
            hideShowSkipNextButton(shouldShow: true)
            addGifToImageView(gifName: cameraGifArray.first ?? R.string.localizable.pic2ArtTooltip1())
        }
        blurView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func addGifToImageView(gifName: String) {
        imgViewTooltip.loadGif(name: gifName)
    }
    
    private func addEditTooltipToImgView(imgName: String) {
        imgViewTooltip.image = UIImage(named: imgName)
    }
    
    private func hideShowSkipNextButton(shouldShow: Bool) {
        btnPic2ArtSkip.isHidden = shouldShow
        btnPic2ArtNext.isHidden = shouldShow
        btnSkip.isHidden = !shouldShow
        btnNext.isHidden = !shouldShow
        btnSkipEditTooltip.isHidden = true
    }
    
    private func hideButtonsForEditTooltip() {
        btnPic2ArtSkip.isHidden = true
        btnPic2ArtNext.isHidden = true
        btnSkip.isHidden = true
        btnNext.isHidden = true
        btnSkipEditTooltip.isHidden = false
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
            btnSkipClicked(sender)
        } else if isQuickLinkTooltip {
            if gifCount == 2 {
                btnSkipClicked(sender)
            } else {
                addGifToImageView(gifName: quickLinkGifArray[gifCount])
                if gifCount == 1 {
                    btnPic2ArtNext.setTitle(R.string.localizable.done(), for: .normal)
                    btnPic2ArtSkip.isHidden = true
                }
            }
        } else if isCameraGif {
            if gifCount == 4 {
                btnSkipClicked(sender)
            } else {
                addGifToImageView(gifName: cameraGifArray[gifCount])
                if gifCount == 3 {
                    btnPic2ArtNext.setTitle(R.string.localizable.done(), for: .normal)
                    btnPic2ArtSkip.isHidden = true
                }
            }
        } else {
            btnSkipClicked(sender)
        }
    }
    
    @IBAction func tooltipTapView(_ sender: UITapGestureRecognizer) {
        if  isCameraGif{
            gifCount += 1
            if gifCount == 4 {
                btnSkipClicked(UIButton())
            } else {
                addGifToImageView(gifName: cameraGifArray[gifCount])
                if gifCount == 3 {
                    btnPic2ArtNext.setTitle(R.string.localizable.done(), for: .normal)
                    btnPic2ArtSkip.isHidden = true
                }
            }
        }
    }
    
    @IBAction func signUpTooltipOkClicked(_ sender: UIButton) {
        blurView.isHidden = true
        signupTooltipView.isHidden = true
    }
}
