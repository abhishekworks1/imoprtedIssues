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
    case influencerTools
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
                                               BusinessVCOption(name: R.string.localizable.announcement(), image: R.image.announcementCopy(), type: .announcement),
                                               BusinessVCOption(name: "\(R.string.localizable.channel()) \n \(R.string.localizable.management())", image: R.image.channelManagement(), type: .channelManagement),
                                               BusinessVCOption(name: R.string.localizable.calculator(), image: R.image.calculator(), type: .calculator),
                                               BusinessVCOption(name: R.string.localizable.socialConnection(), image: R.image.socialConnection(), type: .socialConnection),
                                               BusinessVCOption(name: R.string.localizable.leaderboard(), image: R.image.leaderboard(), type: .leaderboard),
                                               BusinessVCOption(name: R.string.localizable.map(), image: R.image.world(), type: .map),
                                               BusinessVCOption(name: R.string.localizable.followerNetwork(), image: R.image.genealogy(), type: .genealogy),
                                               BusinessVCOption(name: R.string.localizable.stats(), image: R.image.stat(), type: .stats),
                                               BusinessVCOption(name: R.string.localizable.money(), image: R.image.money(), type: .money),
                                               BusinessVCOption(name: R.string.localizable.influencerTools(), image: R.image.subscribers(), type: .influencerTools),
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
        
        var navTitle = R.string.localizable.socialCam()
        if isSocialCamApp {
            navTitle = R.string.localizable.socialCam()
        } else if isViralCamApp {
            navTitle = R.string.localizable.viralCam()
        } else if isSoccerCamApp {
            navTitle = R.string.localizable.soccerCam()
        } else if isFutbolCamApp {
            navTitle = R.string.localizable.futbolCam()
        } else if isQuickCamApp {
            navTitle = R.string.localizable.quickCam()
        } else if isPic2ArtApp {
            navTitle = R.string.localizable.pic2Art()
        } else if isBoomiCamApp {
            navTitle = R.string.localizable.boomiCam()
        } else if isTimeSpeedApp {
            navTitle = R.string.localizable.timeSpeed()
        } else if isFastCamApp {
            navTitle = R.string.localizable.fastCam()
        } else if isSnapCamApp {
            navTitle = R.string.localizable.snapCam()
        } else if isViralCamLiteApp {
            navTitle = R.string.localizable.viralCamLite()
        } else if isQuickCamLiteApp {
            navTitle = R.string.localizable.quickCamLite()
        } else if isFastCamLiteApp {
            navTitle = R.string.localizable.fastCamLite()
        } else if isSpeedCamApp {
            navTitle = R.string.localizable.speedCam()
        } else if isSpeedCamLiteApp {
            navTitle = R.string.localizable.speedCamLite()
        }
        
        navigationTitle.text = navTitle + " " + R.string.localizable.businessCenter()
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
        if businessVCOption.type != .subscription && businessVCOption.type != .socialConnection && businessVCOption.type != .channelManagement && businessVCOption.type != .share && businessVCOption.type != .calculator {
            cell.tagImageView.alpha = 0.5
            cell.tagLabel.alpha = 0.7
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
        case .calculator:
            guard let calculatorSelectorVc = R.storyboard.calculator.calculatorSelectorViewController() else { break }
            calculatorSelectorVc.buttonAction = { index in
                switch index {
                case 0:
                    guard let destinationVc = R.storyboard.calculator.calculatorViewController() else { return }
                    self.navigationController?.pushViewController(destinationVc, animated: true)
                case 1:
                    guard let destinationVc = R.storyboard.calculator.incomeCalculatorOne() else { return }
                    self.navigationController?.pushViewController(destinationVc, animated: true)
                case 2:
                    guard let destinationVc = R.storyboard.calculator.incomeCalculatorTwo() else { return }
                    self.navigationController?.pushViewController(destinationVc, animated: true)
                case 3:
                    guard let destinationVc = R.storyboard.calculator.incomeCalculatorTwo() else { return }
                    destinationVc.isCalculatorThree = true
                    self.navigationController?.pushViewController(destinationVc, animated: true)
                default:
                    break
                }
            }
            calculatorSelectorVc.modalPresentationStyle = .overFullScreen
            self.navigationController?.present(calculatorSelectorVc, animated: true, completion: nil)
            break
        default:
            if isViralCamLiteApp || isQuickCamLiteApp || isFastCamLiteApp || isSpeedCamLiteApp {
            self.view.makeToast(R.string.localizable.thisFeatureIsNotAvailable())
            } else {
                self.view.makeToast(R.string.localizable.comingSoon())
            }
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
