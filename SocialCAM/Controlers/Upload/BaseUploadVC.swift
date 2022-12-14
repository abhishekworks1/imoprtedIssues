//
//  BaseUploadVC.swift
//  ProManager
//
//  Created by Jasmin Patel on 21/10/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import MXSegmentedPager

class BaseUploadVC: MXSegmentedPagerController {
    
    @IBOutlet weak var headerView: UIView!
    
    var firstModalPersiontage: Double = 0.0
    var firstModalUploadCompletedSize: Double = 0.0
   
    deinit {
        print("Deinit \(self.description)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedPager.backgroundColor = ApplicationSettings.appLightWhiteColor
        segmentedPager.segmentedControlEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        segmentedPager.segmentedControl.borderColor = ApplicationSettings.appLightWhiteColor
        segmentedPager.segmentedControl.borderWidth = 1
        segmentedPager.parallaxHeader.view = headerView
        segmentedPager.parallaxHeader.mode = .fill
        segmentedPager.parallaxHeader.height = 44
        segmentedPager.parallaxHeader.minimumHeight = 44
        segmentedPager.pager.bounces = false
        segmentedPager.bounces = false
        segmentedPager.segmentedControl.backgroundColor = ApplicationSettings.appWhiteColor
        
        // Segmented Control customization
        segmentedPager.segmentedControl.selectionIndicatorLocation = .down
        segmentedPager.segmentedControl.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.gray85, NSAttributedString.Key.font: UIFont.sfuiTextRegular as Any]
        segmentedPager.segmentedControl.selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ApplicationSettings.appPrimaryColor, NSAttributedString.Key.font: UIFont.sfuiTextRegular as Any]
        segmentedPager.segmentedControl.selectionStyle = .fullWidthStripe
        segmentedPager.segmentedControl.selectionIndicatorColor = ApplicationSettings.appPrimaryColor
        segmentedPager.segmentedControl.borderType = .bottom
        segmentedPager.segmentedControl.type = .text
        segmentedPager.segmentedControl.selectionIndicatorHeight = 2
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mx_page_0" {
            if let storyUploadVC = R.storyboard.storyCameraViewController.storyUploadVC() {
                storyUploadVC.firstModalPersiontage = firstModalPersiontage
                storyUploadVC.firstModalUploadCompletedSize = firstModalUploadCompletedSize
            }
        } else if segue.identifier == "mx_page_1" {
            if let feedUploadVC = R.storyboard.storyCameraViewController.feedUploadVC() {
                feedUploadVC.firstModalPersiontage = firstModalPersiontage
                feedUploadVC.firstModalUploadCompletedSize = firstModalUploadCompletedSize
            }
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onRestartUploadClick(_ sender: Any) {
        StoryDataManager.shared.restartAll()
        PostDataManager.shared.restartAll()
    }
    
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        return ["Story", "Feed"][index]
    }
}
