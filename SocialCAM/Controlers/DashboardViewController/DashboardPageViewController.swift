//
//  DashboardPageViewController.swift
//  SocialCAM
//
//  Created by Viraj Patel on 08/07/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

protocol DashboardPageViewDelegate: class {
    func viewControllerFor(dashboradPageViewController: DashboardPageViewController, for segment : TopSegments) -> SegmentTypeController?
}

class DashboardPageViewController: UIPageViewController {
    private var noOfPages: Int = TopSegments.allValues.count
    weak var pageDelegate: DashboardPageViewDelegate?
    var selectedIndex: Int = 0
    var scrollview: UIScrollView? {
        get {
            for view in self.view.subviews {
                if let scrollView = view as? UIScrollView {
                    return scrollView
                }
            }
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        self.scrollview?.isScrollEnabled = false
        if noOfPages > 0 {
            if let firstVc = pageDelegate?.viewControllerFor(dashboradPageViewController: self, for: TopSegments.allValues.first!) {
                self.setViewControllers([firstVc as! UIViewController], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollToType(type: TopSegments) {
        if let vc = pageDelegate?.viewControllerFor(dashboradPageViewController: self, for: type) {
            self.setViewControllers([vc as! UIViewController], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
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

extension DashboardPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let vc = viewController as? SegmentTypeController, let type = vc.segmentType?.previous {
            return pageDelegate?.viewControllerFor(dashboradPageViewController: self, for: type) as? UIViewController
        } else {
           return nil
        }

    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let vc = viewController as? SegmentTypeController, let type = vc.segmentType?.next {
            return pageDelegate?.viewControllerFor(dashboradPageViewController: self, for: type) as? UIViewController
        } else {
            return nil
        }
    }
    
}

extension DashboardPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        
        if let vc  = pageViewController.viewControllers?.first as? SegmentTypeController {
           print(vc.segmentType?.rawValue ?? "")
        }
       
    }
}
