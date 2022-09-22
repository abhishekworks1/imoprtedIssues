//
//  BadgesPopUpViewController.swift
//  SocialCAM
//
//  Created by Siddharth on 05/09/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

struct GetBadges {
    var badgesImage: UIImage?
    var badgeName: String?
    var badgeDescription: String?
    var badgeCount: String?
}
enum BadgeType {
    case allBadges
    case basicBadges
    case subscriptionBadges
}
class BadgesPopUpViewController: UIViewController {
    @IBOutlet weak var badgesCollectionView: UICollectionView!
    @IBOutlet weak var previousPageButton: UIButton!
    @IBOutlet weak var nextPageButton: UIButton!
    @IBOutlet weak var currentPageButton: UIButton!
    var flowLayout = BadgesCarouselFlowLayout()
    var currentPage: Int = 0
    var selectedBadgeTag: Int = 0
    var badgeDetails: [GetBadges] = []
    var badgeType : BadgeType = .allBadges
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SB --> \(selectedBadgeTag)")
        previousPageButton.isHidden = true
        setUpCollectionView()
        badgeDetails = setUpSubscriptionBadges()
        badgesCollectionView.reloadData()
        print("CP --> \(currentPage)")
        self.badgesCollectionView.scrollToItem(at: IndexPath(row: currentPage-1, section: 0), at: .centeredHorizontally, animated: true)
        setUpPageButtonText(currentPageText: currentPage, nextPage: currentPage + 1, previousPage: currentPage - 1)
        
    }

    
    func setUpPageButtonText(currentPageText:Int,nextPage: Int, previousPage: Int) {
        currentPageButton.setTitle("\(currentPageText)", for: .normal)
        nextPageButton.setTitle("\(currentPageText + 1)", for: .normal)
        previousPageButton.setTitle("\(currentPageText - 1)", for: .normal)
        currentPageButton.tag = currentPageText
        if currentPageText == 1 {
            previousPageButton.isHidden = true
            previousPageButton.tag = 0
        } else {
            previousPageButton.isHidden = false
            previousPageButton.tag = currentPageText - 1
        }
        if currentPageText >= badgeDetails.count {
            nextPageButton.isHidden = true
            nextPageButton.tag = 0
        } else {
            nextPageButton.isHidden = false
            nextPageButton.tag = currentPageText + 1
        }
        
//        previousPageButton.tag = previousPage - 1
//        currentPageButton.tag = currentPageText - 1
//        nextPageButton.tag = nextPage - 1
    }
    
    
    @IBAction func didTapOnPreviousPageTextButton(_ sender: UIButton) {
//        print(previousPageButton.tag)
        if currentPage == 1 {
            return
        } else {
            currentPage = currentPage - 1
        }
        self.badgesCollectionView.reloadData()
        self.badgesCollectionView.scrollToItem(at: IndexPath(row: currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    
    @IBAction func didTapOnCurrentTextPageButton(_ sender: UIButton) {
        return
        print(currentPageButton.tag)
        self.badgesCollectionView.reloadData()
        self.badgesCollectionView.scrollToItem(at: IndexPath(row: currentPageButton.tag, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    @IBAction func didTapOnNextPageTextButton(_ sender: UIButton) {
//        print(nextPageButton.tag)
        if currentPage == badgeDetails.count {
            return
        } else {
            currentPage = currentPage + 1
        }
        self.badgesCollectionView.reloadData()
        self.badgesCollectionView.scrollToItem(at: IndexPath(row: currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    
    @IBAction func didTapArrowPreviusButton(_ sender: UIButton) {
        if currentPage != 1 {
            self.currentPage -= 1
            self.badgesCollectionView.reloadData()
            self.badgesCollectionView.scrollToItem(at: IndexPath(row: currentPage-1, section: 0), at: .centeredHorizontally, animated: true)
            setUpPageButtonText(currentPageText: currentPage, nextPage: currentPage + 1, previousPage: currentPage-1)
        } else {
            return
        }
  
    }
    
    @IBAction func didTapArrowNextButton(_ sender: UIButton) {
        if currentPage == badgeDetails.count {
            return
        } else {
            self.currentPage += 1
            self.badgesCollectionView.reloadData()
            self.badgesCollectionView.scrollToItem(at: IndexPath(row: currentPage-1, section: 0), at: .centeredHorizontally, animated: true)
            setUpPageButtonText(currentPageText: currentPage, nextPage: currentPage + 1, previousPage: currentPage-1)
        }
       /*if self.currentPage == 1 {
            self.currentPage += 1
            self.badgesCollectionView.scrollToItem(at: IndexPath(row: currentPage, section: 0), at: .centeredHorizontally, animated: true)
            setUpPageButtonText(currentPageText: currentPage + 1, nextPage: currentPage + 2, previousPage: currentPage)
        } else {
            if currentPage == badgeDetails.count - 1 {
                return
            } else {
                self.currentPage += 1
                self.badgesCollectionView.scrollToItem(at: IndexPath(row: currentPage, section: 0), at: .centeredHorizontally, animated: true)
                setUpPageButtonText(currentPageText: currentPage + 1, nextPage: currentPage + 2, previousPage: currentPage)
            }
        } */

    }
    
    func setUpSubscriptionBadges() -> [GetBadges] {
        if let badgearray = Defaults.shared.currentUser?.badges {
         /*   if let parentbadge = badgearray.filter({ $0.badge?.code == Badges.SUBSCRIBER_ANDROID.rawValue}).first {
                if let subscriptionType = parentbadge.meta?.subscriptionType, subscriptionType != SubscriptionTypeForBadge.TRIAL.rawValue && subscriptionType != SubscriptionTypeForBadge.FREE.rawValue && subscriptionType != SubscriptionTypeForBadge.EXPIRE.rawValue {
                    let finalDay = Defaults.shared.getCountFromBadge(parentbadge: parentbadge)
                    if finalDay.count > 0 {
                        let androidDayBadgeImage = UIImage(named: "day_badge_android_\(finalDay)")
                        badgeDetails.append(GetBadges(badgesImage: androidDayBadgeImage, badgeName: "Android \(finalDay) badge"))
                        if selectedBadgeTag == 1 {
                            currentPage = badgeDetails.count
                        }
                    }
                }
            }
            if let parentbadge = badgearray.filter({ $0.badge?.code == Badges.SUBSCRIBER_IOS.rawValue}).first {
                if let subscriptionType = parentbadge.meta?.subscriptionType, subscriptionType != SubscriptionTypeForBadge.TRIAL.rawValue && subscriptionType != SubscriptionTypeForBadge.FREE.rawValue && subscriptionType != SubscriptionTypeForBadge.EXPIRE.rawValue {
                    let finalDay = Defaults.shared.getCountFromBadge(parentbadge: parentbadge)
                    if finalDay.count > 0 {
                        let iosDayBadgeImage = UIImage(named: "day_badge_\(finalDay)")
                        badgeDetails.append(GetBadges(badgesImage: iosDayBadgeImage, badgeName: "IOS \(finalDay) badge"))
                        if selectedBadgeTag == 2 {
                            currentPage = badgeDetails.count
                        }
                    }
                }
            }
            if let parentbadge = badgearray.filter({ $0.badge?.code == Badges.SUBSCRIBER_WEB.rawValue}).first {
                if let subscriptionType = parentbadge.meta?.subscriptionType, subscriptionType != SubscriptionTypeForBadge.TRIAL.rawValue && subscriptionType != SubscriptionTypeForBadge.FREE.rawValue && subscriptionType != SubscriptionTypeForBadge.EXPIRE.rawValue {
                    let finalDay = Defaults.shared.getCountFromBadge(parentbadge: parentbadge)
                    if finalDay.count > 0 {
                        let webDayBadgeImage = UIImage(named: "day_badge_Web_\(finalDay)")
                        badgeDetails.append(GetBadges(badgesImage: webDayBadgeImage, badgeName: "Web \(finalDay) badge"))
                        if selectedBadgeTag == 3 {
                            currentPage = badgeDetails.count
                        }
                    }
                }
            } */
            if badgeType == .allBadges || badgeType == .basicBadges {
                if let parentbadge = badgearray.filter({ $0.badge?.code == Badges.PRELAUNCH.rawValue}).first {
                    let prelaunchBadge = R.image.prelaunchBadge()
                    badgeDetails.append(GetBadges(badgesImage: prelaunchBadge, badgeName: "Prelaunch Badge", badgeDescription: "Recognize the beta testers and early adopters"))
                    if selectedBadgeTag == 4 {
                        currentPage = badgeDetails.count
                    }
                }
                if let parentbadge = badgearray.filter({ $0.badge?.code == Badges.FOUNDING_MEMBER.rawValue}).first {
                    let foundingMemberBadge = R.image.foundingMemberBadge()
                    badgeDetails.append(GetBadges(badgesImage: foundingMemberBadge, badgeName: "Founding Member Badge", badgeDescription: "Recognize early adopters and trend setters"))
                    if selectedBadgeTag == 5 {
                        currentPage = badgeDetails.count
                    }
                }
                if let parentbadge = badgearray.filter({ $0.badge?.code == Badges.SOCIAL_MEDIA_CONNECTION.rawValue}).first {
                    let socialBadge = R.image.socialBadge()
                    badgeDetails.append(GetBadges(badgesImage: socialBadge, badgeName: "Social Badge", badgeDescription: "Recognize channels with connected social media accounts"))
                    if selectedBadgeTag == 6 {
                        currentPage = badgeDetails.count
                    }
                }
            }
            if badgeType == .allBadges || badgeType == .subscriptionBadges {
                if let parentbadge = badgearray.filter({ $0.badge?.code == Badges.SUBSCRIBER_ANDROID.rawValue}).first {
                    let finalDay = Defaults.shared.getCountFromBadge(parentbadge: parentbadge)
                    let freeTrialDay = parentbadge.meta?.freeTrialDay ?? 0
                    let subscriptionType = parentbadge.meta?.subscriptionType ?? ""
                    if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                        badgeDetails.append(GetBadges(badgesImage: R.image.badgeAndroidTrial(), badgeName: "Android Trial", badgeDescription: "", badgeCount: finalDay))
                        if selectedBadgeTag == 7 {
                            currentPage = badgeDetails.count
                        }
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
                        if freeTrialDay > 0 {
                            badgeDetails.append(GetBadges(badgesImage: R.image.badgeAndroidTrial(), badgeName: "Android Trial", badgeDescription: "", badgeCount: finalDay))
                            if selectedBadgeTag == 7 {
                                currentPage = badgeDetails.count
                            }
                        } else {
                            badgeDetails.append(GetBadges(badgesImage: R.image.badgeAndroidFree(), badgeName: "Android Free", badgeDescription: "", badgeCount: finalDay))
                            if selectedBadgeTag == 7 {
                                currentPage = badgeDetails.count
                            }
                        }
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
                        badgeDetails.append(GetBadges(badgesImage: R.image.badgeAndroidBasic(), badgeName: "Android Basic", badgeDescription: "Recognize the channel’s Basic subscription level", badgeCount: finalDay))
                        if selectedBadgeTag == 7 {
                            currentPage = badgeDetails.count
                        }
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
                        badgeDetails.append(GetBadges(badgesImage: R.image.badgeAndroidAdvance(), badgeName: "Android Advanced", badgeDescription: "Recognize the channel’s Advanced subscription level", badgeCount: finalDay))
                        if selectedBadgeTag == 7 {
                            currentPage = badgeDetails.count
                        }
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue {
                        badgeDetails.append(GetBadges(badgesImage: R.image.badgeAndroidPre(), badgeName: "Android Premium", badgeDescription: "Recognize the channel’s Premium subscription level", badgeCount: finalDay))
                        if selectedBadgeTag == 7 {
                            currentPage = badgeDetails.count
                        }
                    }
                }
                if let parentbadge = badgearray.filter({ $0.badge?.code == Badges.SUBSCRIBER_IOS.rawValue}).first {
                    let finalDay = Defaults.shared.getCountFromBadge(parentbadge: parentbadge)
                    let freeTrialDay = parentbadge.meta?.freeTrialDay ?? 0
                    let subscriptionType = parentbadge.meta?.subscriptionType ?? ""
                    if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                        badgeDetails.append(GetBadges(badgesImage: R.image.badgeIphoneTrial(), badgeName: "Iphone Trial", badgeDescription: "", badgeCount: finalDay))
                        if selectedBadgeTag == 8 {
                            currentPage = badgeDetails.count
                        }
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
                        badgeDetails.append(GetBadges(badgesImage: R.image.badgeIphoneFree(), badgeName: "Iphone Free", badgeDescription: "", badgeCount: finalDay))
                        if selectedBadgeTag == 8 {
                            currentPage = badgeDetails.count
                        }
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
                        badgeDetails.append(GetBadges(badgesImage: R.image.badgeIphoneBasic(), badgeName: "Iphone Basic", badgeDescription: "Recognize the channel’s Basic subscription level", badgeCount: finalDay))
                        if selectedBadgeTag == 8 {
                            currentPage = badgeDetails.count
                        }
                        
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
                        badgeDetails.append(GetBadges(badgesImage: R.image.badgeIphoneAdvance(), badgeName: "Iphone Advanced", badgeDescription: "Recognize the channel’s Advanced subscription level", badgeCount: finalDay))
                        if selectedBadgeTag == 8 {
                            currentPage = badgeDetails.count
                        }
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue {
                        badgeDetails.append(GetBadges(badgesImage: R.image.badgeIphonePre(), badgeName: "Iphone Premium", badgeDescription: "Recognize the channel’s Premium subscription level", badgeCount: finalDay))
                        if selectedBadgeTag == 8 {
                            currentPage = badgeDetails.count
                        }
                    }
                }
                if let parentbadge = badgearray.filter({ $0.badge?.code == Badges.SUBSCRIBER_WEB.rawValue}).first {
                    let finalDay = Defaults.shared.getCountFromBadge(parentbadge: parentbadge)
                    let freeTrialDay = parentbadge.meta?.freeTrialDay ?? 0
                    let subscriptionType = parentbadge.meta?.subscriptionType ?? ""
                    if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                        badgeDetails.append(GetBadges(badgesImage: R.image.badgeWebTrial(), badgeName: "Web Trial", badgeDescription: "", badgeCount: finalDay))
                        if selectedBadgeTag == 9 {
                            currentPage = badgeDetails.count
                        }
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
                        if freeTrialDay > 0 {
                            badgeDetails.append(GetBadges(badgesImage: R.image.badgeWebTrial(), badgeName: "Web Trial", badgeDescription: "", badgeCount: finalDay))
                            if selectedBadgeTag == 9 {
                                currentPage = badgeDetails.count
                            }
                        } else {
                            badgeDetails.append(GetBadges(badgesImage: R.image.badgeWebFree(), badgeName: "Web Free", badgeDescription: "", badgeCount: finalDay))
                            if selectedBadgeTag == 9 {
                                currentPage = badgeDetails.count
                            }
                        }
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
                        badgeDetails.append(GetBadges(badgesImage: R.image.badgeWebBasic(), badgeName: "Web Basic", badgeDescription: "Recognize the channel’s Basic subscription level", badgeCount: finalDay))
                        if selectedBadgeTag == 9 {
                            currentPage = badgeDetails.count
                        }
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
                        badgeDetails.append(GetBadges(badgesImage: R.image.badgeWebAdvance(), badgeName: "Web Advanced", badgeDescription: "Recognize the channel’s Advanced subscription level", badgeCount: finalDay))
                        if selectedBadgeTag == 9 {
                            currentPage = badgeDetails.count
                        }
                    }
                    else if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue {
                        badgeDetails.append(GetBadges(badgesImage: R.image.badgeWebPre(), badgeName: "Web Premium", badgeDescription: "Recognize the channel’s Premium subscription level", badgeCount: finalDay))
                        if selectedBadgeTag == 9 {
                            currentPage = badgeDetails.count
                        }
                    }
                }
            }
            /*  for parentbadge in badgearray {
             let badgeCode = parentbadge.badge?.code ?? ""
             let finalDay = Defaults.shared.getCountFromBadge(parentbadge: parentbadge)
             let freeTrialDay = parentbadge.meta?.freeTrialDay ?? 0
             let subscriptionType = parentbadge.meta?.subscriptionType ?? ""
             // Setup For Android Badge
             if badgeCode == Badges.SUBSCRIBER_ANDROID.rawValue
             {
             if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
             badgeDetails.append(GetBadges(badgesImage: R.image.badgeAndroidTrial(), badgeName: "Android Trial"))
             }
             else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
             if freeTrialDay > 0 {
             badgeDetails.append(GetBadges(badgesImage: R.image.badgeAndroidTrial(), badgeName: "Android Trial"))
             } else {
             badgeDetails.append(GetBadges(badgesImage: R.image.badgeAndroidFree(), badgeName: "Android Free"))
             }
             }
             if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
             badgeDetails.append(GetBadges(badgesImage: R.image.badgeAndroidBasic(), badgeName: "Android Basic"))
             }
             if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
             badgeDetails.append(GetBadges(badgesImage: R.image.badgeAndroidAdvance(), badgeName: "Android Advanced"))
             }
             if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue {
             badgeDetails.append(GetBadges(badgesImage: R.image.badgeAndroidPre(), badgeName: "Android Premium"))
             }
             }
             
             
             if badgeCode == Badges.SUBSCRIBER_IOS.rawValue
             {
             if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
             badgeDetails.append(GetBadges(badgesImage: R.image.badgeIphoneTrial(), badgeName: "Iphone Trial"))
             }
             else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
             badgeDetails.append(GetBadges(badgesImage: R.image.badgeIphoneFree(), badgeName: "Iphone Free"))
             }
             
             if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
             badgeDetails.append(GetBadges(badgesImage: R.image.badgeIphoneBasic(), badgeName: "Iphone Basic"))
             
             }
             if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
             badgeDetails.append(GetBadges(badgesImage: R.image.badgeIphoneAdvance(), badgeName: "Iphone Advanced"))
             }
             if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue {
             badgeDetails.append(GetBadges(badgesImage: R.image.badgeIphonePre(), badgeName: "Iphone Premium"))
             }
             }
             
             if badgeCode == Badges.SUBSCRIBER_WEB.rawValue
             {
             if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
             badgeDetails.append(GetBadges(badgesImage: R.image.badgeWebTrial(), badgeName: "Web Trial"))
             }
             else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
             
             if freeTrialDay > 0 {
             badgeDetails.append(GetBadges(badgesImage: R.image.badgeWebTrial(), badgeName: "Web Trial"))
             } else {
             badgeDetails.append(GetBadges(badgesImage: R.image.badgeWebFree(), badgeName: "Web Free"))
             }
             }
             
             if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
             badgeDetails.append(GetBadges(badgesImage: R.image.badgeWebBasic(), badgeName: "Web Basic"))
             }
             if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
             badgeDetails.append(GetBadges(badgesImage: R.image.badgeWebAdvance(), badgeName: "Web Advanced"))
             }
             if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue {
             badgeDetails.append(GetBadges(badgesImage: R.image.badgeWebPre(), badgeName: "Web Premium"))
             }
             }
             } */
        }
        return badgeDetails
    }
    
    
    func setUpCollectionView() {
        badgesCollectionView.register(R.nib.badgesCollectionViewCell)
        guard let collectionView = badgesCollectionView else { fatalError() }
        //collectionView.decelerationRate = .fast // uncomment if necessary
        badgesCollectionView.delegate = self
        badgesCollectionView.dataSource = self
        collectionView.collectionViewLayout = flowLayout
        collectionView.contentInsetAdjustmentBehavior = .always
    }
    
    func getCurrentPage() -> Int {
        let visibleRect = CGRect(origin: badgesCollectionView.contentOffset, size: badgesCollectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = badgesCollectionView.indexPathForItem(at: visiblePoint) {
            return visibleIndexPath.row + 1
        }
        return currentPage
    }
    
    @IBAction func didTapOnViewButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}

extension BadgesPopUpViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return badgeDetails.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.badgesCollectionViewCell.identifier, for: indexPath) as? BadgesCollectionViewCell else { return UICollectionViewCell() }
        if currentPage - 1 == indexPath.item {
            cell.badgeImageView.alpha = 1
            cell.badgeNameLabel.isHidden = false
            cell.badgeDescriptionLabel.isHidden = true
            if Int(cell.daysRemainLabel.text ?? "0") ?? 0 > 0 {
                cell.daysRemainLabel.isHidden = false
            } else {
                cell.daysRemainLabel.isHidden = true
            }
        } else {
            cell.badgeImageView.alpha = 0.3
            cell.badgeNameLabel.isHidden = true
            cell.badgeDescriptionLabel.isHidden = true
            cell.daysRemainLabel.isHidden = true
        }
        
        cell.setUpbadgesViewForLoad(badgesDetails: badgeDetails[indexPath.item])
        
        return cell
    }


}
extension BadgesPopUpViewController {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPage = getCurrentPage()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        currentPage = getCurrentPage()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentPage = getCurrentPage()
        badgesCollectionView.reloadData()
        setUpPageButtonText(currentPageText: currentPage, nextPage: currentPage + 1, previousPage: currentPage-1)
    }
}
