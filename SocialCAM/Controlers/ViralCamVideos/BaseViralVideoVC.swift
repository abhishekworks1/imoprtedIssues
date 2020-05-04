//
//  BaseViralVideoVC.swift
//  SocialCAM
//
//  Created by Viraj Patel on 30/04/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import MXSegmentedPager

enum TopSegments: String {
    case facebook = "Facebook"
    case google = "Google"
    case tiktok = "Tiktok"
    case instagram = "Instagram"
    case snapchat = "Snapchat"
    
    static var allValues : [TopSegments] {
        return [.facebook, .google, .tiktok, .instagram, .snapchat]
    }
    
    var next: TopSegments? {
        if let index = TopSegments.allValues.firstIndex(of: self), (index + 1) < TopSegments.allValues.count {
            return  TopSegments.allValues[index + 1]
        } else {
            return nil
        }
    }
    
    var previous : TopSegments? {
        if let index = TopSegments.allValues.firstIndex(of: self), (index - 1) >= 0 {
            return  TopSegments.allValues[index - 1]
        } else {
            return nil
        }
    }
}

protocol SegmentTypeController {
    var segmentType: TopSegments? {get set}
}

protocol ViralCamVideosDelegate: class {
    func viewControllerFor(viralCamVideos: ViralCamVideos, for segment: TopSegments) -> SegmentTypeController?
}

class BaseViralVideoVC: MXSegmentedPagerController {
    
    @IBOutlet weak var headerView: UIView!
    var pageDelegate: ViralCamVideosDelegate?
    
    var segmentStrings: [TopSegments] = TopSegments.allValues
    var firstModalPersiontage: Double = 0.0
    var firstModalUploadCompletedSize: Double = 0.0
   
    deinit {
        print("Deinit \(self.description)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedPager.backgroundColor = ApplicationSettings.appPrimaryColor
        // Parallax Header
        
        segmentedPager.segmentedControl.type = .text
        segmentedPager.segmentedControlEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        segmentedPager.parallaxHeader.view = headerView
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
//        if segue.identifier == "mx_page_0" {
//            if let viralCamVideosVC = R.storyboard.viralCamVideos.viralCamVideos() {
//                viralCamVideosVC.segmentType = .facebook
//            }
//        } else if segue.identifier == "mx_page_2" {
//            if let viralCamVideosVC = R.storyboard.viralCamVideos.viralCamVideos() {
//                viralCamVideosVC.segmentType = .tiktok
//            }
//        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onRestartUploadClick(_ sender: Any) {
       
    }
    
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, viewControllerForPageAt index: Int) -> UIViewController {
        if let viralCamVideosVC = R.storyboard.viralCamVideos.viralCamVideos(), index == 0 {
            //viralCamVideosVC.segmentType = .facebook
            return viralCamVideosVC
        }
        if let viralCamVideosVC = R.storyboard.viralCamVideos.viralCamVideos(), index == 3 {
            //viralCamVideosVC.segmentType = .tiktok
            return viralCamVideosVC
        }
        return UIViewController()
    }
    
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        return segmentStrings[index].rawValue
    }
}
