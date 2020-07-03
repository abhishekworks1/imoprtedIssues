//
//  BaseViralVideoVC.swift
//  SocialCAM
//
//  Created by Viraj Patel on 30/04/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import MXSegmentedPager

protocol ViralCamVideosDelegate: class {
    func viewControllerFor(viralCamVideos: ViralCamVideos, for segment: TopSegments) -> SegmentTypeController?
}

class BaseViralVideoVC: MXSegmentedPagerController, SegmentTypeController {
    var segmentType: TopSegments? = .family
    @IBOutlet weak var headerView: UIView!
    
    weak var pageDelegate: ViralCamVideosDelegate?
    var viralCamVideosVC: ViralCamVideos!
    var viralCamVideosVC1: ViralCamVideos!
    var viralCamVideosVC2: ViralCamVideos!
    var viralCamVideosVC3: ViralCamVideos!
    var viralCamVideosVC4: ViralCamVideos!
    var viralCamVideosVC5: ViralCamVideos!
    
    var segmentStrings: [SecondTopSegments] = SecondTopSegments.allValues
    var firstModalPersiontage: Double = 0.0
    var firstModalUploadCompletedSize: Double = 0.0
   
    deinit {
        print("Deinit \(self.description)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedPager.backgroundColor = ApplicationSettings.appPrimaryColor
        segmentedPager.segmentedControlEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        segmentedPager.segmentedControl.borderColor = ApplicationSettings.appClearColor
        segmentedPager.segmentedControl.borderWidth = 2
        segmentedPager.parallaxHeader.view = headerView
        segmentedPager.parallaxHeader.mode = .fill
        segmentedPager.parallaxHeader.height = 0
        segmentedPager.parallaxHeader.minimumHeight = 0
        segmentedPager.pager.bounces = false
        segmentedPager.bounces = false
        
        // Segmented Control customization
        segmentedPager.segmentedControl.type = .text
        segmentedPager.segmentedControl.selectionIndicatorLocation = .down
        segmentedPager.segmentedControl.backgroundColor = ApplicationSettings.appPrimaryColor
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
            viralCamVideosVC = segue.destination as? ViralCamVideos
            viralCamVideosVC.segmentType = segmentStrings[0]
        } else if segue.identifier == "mx_page_1" {
            viralCamVideosVC1 = segue.destination as? ViralCamVideos
            viralCamVideosVC1.segmentType = segmentStrings[1]
        } else if segue.identifier == "mx_page_2" {
            viralCamVideosVC2 = segue.destination as? ViralCamVideos
            viralCamVideosVC2.segmentType = segmentStrings[2]
        } else if segue.identifier == "mx_page_3" {
            viralCamVideosVC3 = segue.destination as? ViralCamVideos
            viralCamVideosVC3.segmentType = segmentStrings[3]
        } else if segue.identifier == "mx_page_4" {
            viralCamVideosVC4 = segue.destination as? ViralCamVideos
            viralCamVideosVC4.segmentType = segmentStrings[4]
        } else if segue.identifier == "mx_page_5" {
            viralCamVideosVC4 = segue.destination as? ViralCamVideos
            viralCamVideosVC4.segmentType = segmentStrings[5]
        } else if segue.identifier == "mx_page_6" {
            viralCamVideosVC4 = segue.destination as? ViralCamVideos
            viralCamVideosVC4.segmentType = segmentStrings[6]
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onRestartUploadClick(_ sender: Any) {
       
    }
    
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        return segmentStrings[index].rawValue
    }
}
