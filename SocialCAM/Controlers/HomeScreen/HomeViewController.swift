//
//  HomeViewController.swift
//  SocialCAM
//
//  Created by Viraj Patel on 22/01/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import MXSegmentedPager

class HomeViewController: MXSegmentedPagerController {
   
    var segmentStrings: [TopSegments] = [TopSegments.facebook, TopSegments.google, TopSegments.facebook]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedPager.backgroundColor = ApplicationSettings.appPrimaryColor
        // Parallax Header
        
        segmentedPager.segmentedControl.type = .text
        segmentedPager.segmentedControlEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        segmentedPager.parallaxHeader.view = nil
        segmentedPager.parallaxHeader.mode = .fill
        segmentedPager.parallaxHeader.height = 0
        segmentedPager.parallaxHeader.minimumHeight = 0
        // Segmented Control customization
        segmentedPager.segmentedControl.selectionIndicatorLocation = .down
        segmentedPager.segmentedControl.backgroundColor = ApplicationSettings.appPrimaryColor
        segmentedPager.segmentedControl.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ApplicationSettings.appLightWhiteColor.withAlphaComponent(0.5), NSAttributedString.Key.font: UIFont.sfuiTextRegular14 as Any]
        segmentedPager.segmentedControl.selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ApplicationSettings.appWhiteColor, NSAttributedString.Key.font: UIFont.sfuiTextRegular14 as Any]
        segmentedPager.segmentedControl.selectionStyle = .textWidthStripe
        segmentedPager.segmentedControl.selectionIndicatorColor = ApplicationSettings.appWhiteColor
        segmentedPager.segmentedControl.borderType = .bottom
        segmentedPager.segmentedControl.borderColor = ApplicationSettings.appClearColor
        segmentedPager.segmentedControl.borderWidth = 2
        segmentedPager.segmentedControl.selectionIndicatorHeight = 2.5
        segmentedPager.pager.bounces = false
        segmentedPager.bounces = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mx_page_0" {
            if let viralCamVideosVC = R.storyboard.viralCamVideos.baseViralVideoVC() {
               
            }
        }
    }
    
    deinit {
        print("deinit-- \(self.description)")
    }
    
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, viewControllerForPageAt index: Int) -> UIViewController {
        if let viralCamVideosVC = R.storyboard.viralCamVideos.baseViralVideoVC(), index == 0 {
            //viralCamVideosVC.segmentType = .facebook
            return viralCamVideosVC
        }
        
        return UIViewController()
    }
    
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        return segmentStrings[index].rawValue
    }
    
}
