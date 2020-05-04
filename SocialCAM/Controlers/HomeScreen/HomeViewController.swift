//
//  HomeViewController.swift
//  SocialCAM
//
//  Created by Viraj Patel on 22/01/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import MXSegmentedPager

enum HomeTopSegments: String {
    case following = "Following"
    case discover = "Discover"
    case myUpvotes = "My Upvotes"
    
    static var allValues : [HomeTopSegments] {
        return [.following, .discover, .myUpvotes]
    }
    
    var next: HomeTopSegments? {
        if let index = HomeTopSegments.allValues.firstIndex(of: self), (index + 1) < HomeTopSegments.allValues.count {
            return  HomeTopSegments.allValues[index + 1]
        } else {
            return nil
        }
    }
    
    var previous : HomeTopSegments? {
        if let index = HomeTopSegments.allValues.firstIndex(of: self), (index - 1) >= 0 {
            return  HomeTopSegments.allValues[index - 1]
        } else {
            return nil
        }
    }
}

class HomeViewController: MXSegmentedPagerController {
   
    var segmentStrings: [HomeTopSegments] = HomeTopSegments.allValues
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedPager.backgroundColor = ApplicationSettings.appPrimaryColor
        segmentedPager.segmentedControlEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        segmentedPager.parallaxHeader.view = nil
        segmentedPager.parallaxHeader.mode = .fill
        segmentedPager.parallaxHeader.height = 0
        segmentedPager.parallaxHeader.minimumHeight = 0
        segmentedPager.segmentedControl.backgroundColor = ApplicationSettings.appPrimaryColor
        segmentedPager.segmentedControl.borderColor = ApplicationSettings.appClearColor
        segmentedPager.segmentedControl.borderWidth = 2
        segmentedPager.pager.bounces = false
        segmentedPager.bounces = false
        
        // Segmented Control customization
        segmentedPager.segmentedControl.selectionIndicatorLocation = .down
        segmentedPager.segmentedControl.type = .text
        segmentedPager.segmentedControl.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ApplicationSettings.appLightWhiteColor.withAlphaComponent(0.5), NSAttributedString.Key.font: UIFont.sfuiTextRegular14 as Any]
        segmentedPager.segmentedControl.selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ApplicationSettings.appWhiteColor, NSAttributedString.Key.font: UIFont.sfuiTextRegular14 as Any]
        segmentedPager.segmentedControl.selectionStyle = .textWidthStripe
        segmentedPager.segmentedControl.selectionIndicatorColor = ApplicationSettings.appWhiteColor
        segmentedPager.segmentedControl.borderType = .bottom
        segmentedPager.segmentedControl.selectionIndicatorHeight = 2.5
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        segmentedPager.reloadData()
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
    
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        return segmentStrings[index].rawValue
    }
    
}
