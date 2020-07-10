//
//  NewDashboardViewController.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 14/11/17.
//  Copyright © 2017 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import MXSegmentedPager
import AVFoundation
import AVKit
import Pageboy

enum SyncType {
    case VideoPhotoSync
    case Feedsync
    case youtubeSync
}

protocol SyncFeedVideoPhoto: class {
    func updatePost(post: Posts, at type: SyncType)
    func deletePost(post: Posts, at type: SyncType)
}

enum SecondTopSegments: String {
    case twitter = "Twitter"
    case facebook = "Facebook"
    case instagram = "Instagram"
    case snapchat = "Snapchat"
    case google = "Youtube"
    case tiktok = "Tiktok"
    case storiCam = "StoriCam"

    static var allValues: [SecondTopSegments] {
        return [.storiCam, .instagram, .tiktok, .google, .twitter, .facebook, .snapchat]
    }

    var next: SecondTopSegments? {
        if let index = SecondTopSegments.allValues.firstIndex(of: self), (index + 1) < SecondTopSegments.allValues.count {
            return SecondTopSegments.allValues[index + 1]
        } else {
            return nil
        }
    }

    var previous: SecondTopSegments? {
        if let index = SecondTopSegments.allValues.firstIndex(of: self), (index - 1) >= 0 {
            return SecondTopSegments.allValues[index - 1]
        } else {
            return nil
        }
    }
}

class NewDashboardViewController: MXSegmentedPagerController, SegmentTypeController {
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var uploadProgressStackView: UIStackView!
    var isConnectionLoss: Bool = false
    var segmentStrings: [SecondTopSegments] = SecondTopSegments.allValues
    
    var segmentType: TopSegments? {
        didSet {
            if let segmentType = self.segmentType {
                if segmentType == .follow {
                    self.browserType = .following
                } else if segmentType == .trending {
                    self.browserType = .trending
                } else if segmentType == .favourite {
                    self.browserType = .favourite
                } else if segmentType == .featured {
                    self.browserType = .featured
                } else if segmentType == .media {
                    self.browserType = .media
                } else if segmentType == .custom {
                    self.browserType = .custom
                } else if segmentType == .family {
                    self.browserType = .family
                }
            }
        }
    }
    
    var browserType: BrowserType = .following {
        didSet {
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedPager.backgroundColor = ApplicationSettings.appLightWhiteColor
        segmentedPager.segmentedControl.type = .text
        segmentedPager.segmentedControlEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
        segmentedPager.parallaxHeader.view = headerView
        segmentedPager.parallaxHeader.mode = .fill
        segmentedPager.parallaxHeader.height = 0
        segmentedPager.parallaxHeader.minimumHeight = 0
        // Segmented Control customization
        segmentedPager.segmentedControl.selectionIndicatorLocation = .down
        segmentedPager.segmentedControl.backgroundColor = ApplicationSettings.appWhiteColor
        segmentedPager.segmentedControl.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.gray85, NSAttributedString.Key.font: R.font.sfuiTextMedium(size: 12)!]
        segmentedPager.segmentedControl.selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ApplicationSettings.appPrimaryColor, NSAttributedString.Key.font: R.font.sfuiTextMedium(size: 12)!]
        segmentedPager.segmentedControl.selectionStyle = .fullWidthStripe
        segmentedPager.segmentedControl.selectionIndicatorColor = ApplicationSettings.appPrimaryColor
        segmentedPager.segmentedControl.borderType = .bottom
        segmentedPager.segmentedControl.borderColor = ApplicationSettings.appLightWhiteColor
        segmentedPager.segmentedControl.borderWidth = 1
        segmentedPager.segmentedControl.selectionIndicatorHeight = 2
        segmentedPager.pager.bounces = false
        segmentedPager.bounces = false
        let imageView = UIImageView(image: #imageLiteral(resourceName: "thinArrow"))
        imageView.contentMode = .center
        imageView.backgroundColor = ApplicationSettings.appWhiteColor
        imageView.frame = CGRect(x: UIScreen.main.bounds.size.width - 8, y: 0, width: 8, height: 44)
        segmentedPager.segmentedControl.addSubview(imageView)
        
        // Do any additional setup after loading the view.
    }

    func setBrowserType(type: BrowserType?) {
        switch type {
        case .following?:
            self.browserType = type ?? .following
            self.segmentedPager.pager.isHidden = false
            self.segmentedPager.segmentedControl.isHidden = false
        case .trending?:
            self.browserType = type ?? .following
            self.segmentedPager.pager.isHidden = false
            self.segmentedPager.segmentedControl.isHidden = false
        case .featured?:
            self.segmentedPager.pager.isHidden = true
            self.segmentedPager.segmentedControl.isHidden = false
        case .media?:
            self.segmentedPager.segmentedControl.isHidden = false
        case .family?:
            self.segmentedPager.pager.isHidden = true
            self.segmentedPager.segmentedControl.isHidden = false
        case .custom?:
            self.segmentedPager.pager.isHidden = true
            self.segmentedPager.segmentedControl.isHidden = false
        case .favourite?:
            self.segmentedPager.pager.isHidden = false
            self.segmentedPager.segmentedControl.isHidden = false
            self.browserType = type ?? .following
        default:
            break
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        ChannelManagment.instance.getPackage { (packageResult) in
            purchasedPackageForOthers.getPackage = packageResult
            purchasedPackageForOthers.noOfChannels = packageResult?.remainingPackageCount ?? 0
            purchasedPackageForOthers.availableChannel = packageResult?.remainingPackageCount ?? 0
            purchasedPackageForOthers.numberOfPackages = packageResult?.remainingOtherUserPackageCount ?? 0
            print(purchasedPackageForOthers.noOfChannels)
        }
        self.tabBarController?.tabBar.isHidden = false
        if ApplicationSettings.shared.needtoRefresh == true {
            ApplicationSettings.shared.needtoRefresh = false
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        return segmentStrings[index].rawValue
    }

    override func segmentedPager(_ segmentedPager: MXSegmentedPager, imageForSectionAt index: Int) -> UIImage {
        return #imageLiteral(resourceName: "youtubeFeedTabIcon")
    }

    override func segmentedPager(_ segmentedPager: MXSegmentedPager, selectedImageForSectionAt index: Int) -> UIImage {
        return #imageLiteral(resourceName: "youtubeFeedTabIcon")
    }

    override func segmentedPager(_ segmentedPager: MXSegmentedPager, didScrollWith parallaxHeader: MXParallaxHeader) {
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mx_page_0" {
            let viralCamVideosVC = segue.destination as? ViralCamVideos
            viralCamVideosVC!.segmentType = segmentStrings[0]
        }
        if segue.identifier == "mx_page_1" {
            let viralCamVideosVC = segue.destination as? ViralCamVideos
            viralCamVideosVC!.segmentType = segmentStrings[1]
        }
        if segue.identifier == "mx_page_2" {
            let viralCamVideosVC = segue.destination as? ViralCamVideos
            viralCamVideosVC!.segmentType = segmentStrings[2]
        }
        if segue.identifier == "mx_page_3" {
            let viralCamVideosVC = segue.destination as? ViralCamVideos
            viralCamVideosVC!.segmentType = segmentStrings[3]
        }
    }
}

extension NewDashboardViewController {

    override func segmentedPager(_ segmentedPager: MXSegmentedPager, didEndDisplayingPage page: UIView, at index: Int) {
        super.segmentedPager(segmentedPager, didEndDisplayingPage: page, at: index)
    }

    override func segmentedPager(_ segmentedPager: MXSegmentedPager, didSelectViewWith index: Int) {
        print("index")
        print(index)
    }
}

extension NewDashboardViewController: SyncFeedVideoPhoto {

    func updatePost(post: Posts, at type: SyncType) {
        
    }

    func deletePost(post: Posts, at type: SyncType) {
        
    }

}

extension NewDashboardViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
            if let velocity = (gestureRecognizer as? UIPanGestureRecognizer)?.velocity(in: self.view) {
                if abs(velocity.x) < abs(velocity.y) {
                    return false
                }
            } else {
                return true
            }
        }
        return true
    }

}

extension UIStackView {
    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))

        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}

extension MXSegmentedPagerController {

    func getViewControllerAtIndex<T>(index: Int) -> T? {
        let viewController = self.pageViewControllers[index] as? T
        return viewController
    }

}

extension NewDashboardViewController: ChannelDelegate {
    
    func cancelSwitchChannel(_ viewController: ChannelListViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func finishedWithSwitchChannel(newChannel channel: User, _ viewController: ChannelListViewController) {
        viewController.dismiss(animated: true, completion: nil)
        self.changeChannelData(newChannel: channel)
    }
    
}
