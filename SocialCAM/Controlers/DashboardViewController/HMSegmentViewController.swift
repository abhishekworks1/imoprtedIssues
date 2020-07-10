//
//  HMSegmentViewController.swift
//  DashBoardHeaderDesign
//
//  Created by Jatin Kathrotiya on 20/12/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import MXSegmentedPager

protocol HMSegmentViewControllerDelgate: class {
    func segmentedControl(segmentedControl:HMSegmentViewController, didSelectSegment segment : TopSegments)
}

class HMSegmentViewController: UIViewController {
    
    weak var delegate: HMSegmentViewControllerDelgate?
    
    var sectionTitles: [String] {
        set {
              self.segmentedControl.sectionTitles = newValue
        }
        get {
            return self.segmentedControl.sectionTitles 
        }
    }
    
    var segmentedControl: HMSegmentedControl {
        return self.view as! HMSegmentedControl
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configSegmentController()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configSegmentController() {
        segmentedControl.backgroundColor = ApplicationSettings.appPrimaryColor
        segmentedControl.borderColor = ApplicationSettings.appClearColor
        segmentedControl.borderWidth = 2
        
        // Segmented Control customization
        segmentedControl.type = .text
        segmentedControl.selectionIndicatorLocation = .down
        segmentedControl.backgroundColor = ApplicationSettings.appPrimaryColor
        segmentedControl.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ApplicationSettings.appLightWhiteColor.withAlphaComponent(0.5), NSAttributedString.Key.font: UIFont.sfuiTextRegular14 as Any]
        segmentedControl.selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ApplicationSettings.appWhiteColor, NSAttributedString.Key.font: UIFont.sfuiTextRegular14 as Any]
        segmentedControl.selectionStyle = .textWidthStripe
        segmentedControl.selectionIndicatorColor = ApplicationSettings.appWhiteColor
        segmentedControl.borderType = .bottom
        segmentedControl.selectionIndicatorHeight = 2.5
        
        segmentedControl.segmentEdgeInset = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0, right: 7.0)
        
    }
    
    @IBAction func pageControlValueChanged(segmentedControl: HMSegmentedControl) {
         if let delegate = self.delegate {
            if let segment = TopSegments(rawValue: self.sectionTitles[segmentedControl.selectedSegmentIndex]) {
            delegate.segmentedControl(segmentedControl: self, didSelectSegment: segment)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
