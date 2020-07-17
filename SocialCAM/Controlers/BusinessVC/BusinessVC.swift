//
//  BusinessVC.swift
//  SocialCAM
//
//  Created by Viraj Patel on 26/06/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

enum BusinessVCOptionType {
    case stats
    case leaderboard
    case announcement
    case share
    case map
    case genealogy
    case calculator
    case money
    case subscribers
    case subscription
    case socialConnection
    case channelManagement
    case iicC
}

struct BusinessVCOption {
    var name: String
    var image: UIImage?
    var type: BusinessVCOptionType
    
    static let contents: [BusinessVCOption] = [BusinessVCOption(name: R.string.localizable.share(), image: R.image.share(), type: .share),
                                               BusinessVCOption(name: R.string.localizable.subscription(), image: R.image.subscription(), type: .subscription),
                                               BusinessVCOption(name: R.string.localizable.socialConnection(), image: R.image.socialConnection(), type: .socialConnection),
                                               BusinessVCOption(name: "\(R.string.localizable.channel()) \n \(R.string.localizable.management())", image: R.image.channelManagement(), type: .channelManagement),
                                               BusinessVCOption(name: R.string.localizable.stats(), image: R.image.stat(), type: .stats),
                                               BusinessVCOption(name: R.string.localizable.leaderboard(), image: R.image.leaderboard(), type: .leaderboard),
                                               BusinessVCOption(name: R.string.localizable.announcement(), image: R.image.announcementCopy(), type: .announcement),
                                               BusinessVCOption(name: R.string.localizable.map(), image: R.image.world(), type: .map),
                                               BusinessVCOption(name: R.string.localizable.followerNetwork(), image: R.image.genealogy(), type: .genealogy),
                                               BusinessVCOption(name: R.string.localizable.calculator(), image: R.image.calculator(), type: .calculator),
                                               BusinessVCOption(name: R.string.localizable.money(), image: R.image.money(), type: .money),
                                               BusinessVCOption(name: R.string.localizable.subscribers(), image: R.image.subscribers(), type: .subscribers),
                                               BusinessVCOption(name: R.string.localizable.iicC(), image: R.image.iiCc(), type: .iicC)]
}

class BusinessVC: UIViewController {

    @IBOutlet weak var navigationTitle: UILabel!

    @IBOutlet weak var navigationImageView: UIImageView! {
        didSet {
            navigationImageView.isHidden = true
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var isFutbolCamApp: Bool {
        #if FUTBOLCAMAPP
        return true
        #else
        return false
        #endif
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var navTitle = R.string.localizable.businessCenter()
        #if SOCIALCAMAPP
        navTitle = R.string.localizable.socialCam() + " " + R.string.localizable.businessCenter()
        #elseif VIRALCAMAPP
        navTitle = R.string.localizable.viralCam() + " " + R.string.localizable.businessCenter()
        #elseif SOCCERCAMAPP
        navTitle = R.string.localizable.soccerCam() + " " + R.string.localizable.businessCenter()
        #elseif FUTBOLCAMAPP
        navTitle = R.string.localizable.futbolCam() + " " + R.string.localizable.businessCenter()
        #elseif PIC2ARTAPP
        navTitle = R.string.localizable.pic2Art() + " " + R.string.localizable.businessCenter()
        #elseif BOOMICAMAPP
        navTitle = R.string.localizable.boomiCam() + " " + R.string.localizable.businessCenter()
        #elseif TIMESPEEDAPP
        navTitle = R.string.localizable.timeSpeed() + " " + R.string.localizable.businessCenter()
        #elseif FASTCAMAPP
        navTitle = R.string.localizable.fastCam() + " " + R.string.localizable.businessCenter()
        #elseif SNAPCAMAPP
        navTitle = R.string.localizable.snapCam() + " " + R.string.localizable.businessCenter()
        #endif
        
        navigationTitle.text = navTitle
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
     
}

extension BusinessVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BusinessVCOption.contents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.ssuTagSelectionCell.identifier, for: indexPath) as? SSUTagSelectionCell else {
            return UICollectionViewCell()
        }
        let businessVCOption = BusinessVCOption.contents[indexPath.row]
        if businessVCOption.type != .subscription && businessVCOption.type != .socialConnection && businessVCOption.type != .channelManagement && businessVCOption.type != .share {
            cell.tagImageView.alpha = 0.5
            cell.tagLabel.alpha = 0.5
        }
        
        cell.tagImageView.image = BusinessVCOption.contents[indexPath.row].image
        cell.tagLabel.text = BusinessVCOption.contents[indexPath.row].name
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let businessVCOption = BusinessVCOption.contents[indexPath.row]
        switch businessVCOption.type {
        case .subscription:
            if let subscriptionVC = R.storyboard.storyCameraViewController.subscriptionVC() {
                navigationController?.pushViewController(subscriptionVC, animated: true)
            }
        case .socialConnection:
            if let addSocialConnectionViewController = R.storyboard.socialConnection.addSocialConnectionViewController() {
                navigationController?.pushViewController(addSocialConnectionViewController, animated: true)
            }
        case .channelManagement:
            if let chVc = R.storyboard.preRegistration.channelListViewController() {
                chVc.remainingPackageCountForOthers = Defaults.shared.currentUser?.remainingOtherUserPackageCount ?? 0
                self.navigationController?.pushViewController(chVc, animated: true)
            }
        case .share:
            let publicLink = "\(Constant.URLs.websiteURL)/referral/\(Defaults.shared.currentUser?.referralCode ?? "")"
            let shareAll = [publicLink] as [Any]
            let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.size.width/3, height: 115)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
