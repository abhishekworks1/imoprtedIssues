//
//  DashboardViewController.swift
//  SocialCAM
//
//  Created by Viraj Patel on 08/07/20.`
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import Pageboy
import MXSegmentedPager

protocol SegmentTypeController {
    var segmentType: TopSegments? {get set}
}

class DashboardViewController: UIViewController {
    @IBOutlet var uploadContainerView: UIView?
    @IBOutlet var familyContainerView: UIView?
    @IBOutlet var heightConstraint: NSLayoutConstraint?
    @IBOutlet var heightConstraintUploadVc: NSLayoutConstraint?
    var pageController: DashboardPageViewController?
    var selectedSegment: TopSegments = .follow
    @IBOutlet var roundBadgeView: RoundedView!
    @IBOutlet var lblBadgeText: UILabel!
    @IBOutlet var headerTitle: PLabel!

    @IBOutlet var headerImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        headerTitle.text = Defaults.shared.currentUser?.channelId
        #if SOCIALCAMAPP
        headerImageView.image = R.image.socialCamSplashLogo()
        #elseif VIRALCAMAPP
        headerImageView.image = R.image.viralCamSplashLogo()
        #elseif SOCCERCAMAPP || FUTBOLCAMAPP
        headerImageView.image = R.image.soccercamWatermarkLogo()
        #elseif QUICKCAMAPP
        headerImageView.image = R.image.quickcamWatermarkLogo()
        #elseif SNAPCAMAPP
        headerImageView.image = R.image.snapcamWatermarkLogo()
        #elseif TIMESPEEDAPP
        headerImageView.image = R.image.timeSpeedWatermarkLogo()
        #elseif FASTCAMAPP
        headerImageView.image = R.image.fastcamWatermarkLogo()
        #elseif BOOMICAMAPP
        headerImageView.image = R.image.boomicamWatermarkLogo()
        #else
        headerImageView.image = R.image.pic2artWatermarkLogo()
        #endif
        self.lblBadgeText.text = ""
        self.roundBadgeView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardViewController.refreshUnreadCount), name: (NSNotification.Name(rawValue: "unreadChatCount")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.switchChannel), name: NSNotification.Name.switchChannel, object: nil)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.switchChannel, object: self)
        print("deinit-- \(self.description)")
    }
    
    @objc func refreshUnreadCount(_ notification: NSNotification) {
        if let count = notification.userInfo?["count"] as? Int {
            // do something with your image
            if count >= 1 {
                roundBadgeView.isHidden = false
                lblBadgeText.text = "\((count))"
                if count > 9 {
                    lblBadgeText.text = "9+"
                }
            } else {
                roundBadgeView.isHidden = true
            }
        }
    }
    
    @objc func switchChannel() {
          headerTitle.text = Defaults.shared.currentUser?.channelId
        
    }
    
    func viewControllerfor(type: TopSegments) -> SegmentTypeController? {
        if type == .follow {
            let vc = R.storyboard.viralCamVideos.baseViralVideoVC()
            vc?.segmentType = type
            return vc
        } else {
            let vc = R.storyboard.homeScreen.comingSoonController()
            return vc
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegmentedSegue" {
            let segmentViewController = segue.destination as? HMSegmentViewController
            segmentViewController?.sectionTitles = TopSegments.allValues.map {
               return $0.rawValue
            }
            segmentViewController?.delegate = self
        }
        if segue.identifier == "PageControllerSegue" {
            self.pageController = segue.destination as? DashboardPageViewController
            self.pageController?.pageDelegate = self
        }
    }
    
    // Mark : --- Action Methods ---------
    
    @IBAction func btnChannelClicked(_ sender: Any) {
        
    }
    
    @IBAction func btnMessageAction(_ sender: UIButton) {
        if let pageVC = self.navigationController?.parentPageViewController {
            pageVC.scrollToPage(PageboyViewController.Page.next, animated: true)
        }
    }
    
    @IBAction func btnStoryAction(_ sender: UIButton) {
        if let pageVC = self.navigationController?.parentPageViewController {
            pageVC.scrollToPage(PageboyViewController.Page.previous, animated: true)
        }
    }
    
}

extension DashboardViewController: HMSegmentViewControllerDelgate {
    
    func segmentedControl(segmentedControl: HMSegmentViewController, didSelectSegment segment: TopSegments) {
        self.selectedSegment = segment
        self.pageController?.scrollToType(type: self.selectedSegment)
    }
    
}

extension DashboardViewController: DashboardPageViewDelegate {
    func viewControllerFor(dashboradPageViewController: DashboardPageViewController, for segment: TopSegments) -> SegmentTypeController? {
         return self.viewControllerfor(type: segment)
    }
    
}
