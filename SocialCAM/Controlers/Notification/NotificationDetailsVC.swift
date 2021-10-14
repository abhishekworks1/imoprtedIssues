//
//  NotificationDetailsVC.swift
//  SocialCAM
//
//  Created by Viraj Patel on 07/10/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import AVKit

class NotificationDetailsVC: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnPrevious: UIButton!
    var notificationArray: [UserNotification] = []
    var selectedIndex = 0
    var notification: UserNotification?
    @IBOutlet weak var collectionView: UICollectionView!
    var gridLayout : GridFlowLayout! =  GridFlowLayout()
    var pageIndex: Int = 0
    var postsCount: Int = 0
    var notificationArrayHandler : ((_ notification: [UserNotification], _ pageIndex: Int, _ postsCount:Int) -> Void)?
    var startLoading : Bool = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationCapturesStatusBarAppearance = true
        if let index = self.notificationArray.firstIndex(where: { $0.id == notification?.id }) {
            self.selectedIndex = index
        }
        collectionView.isPagingEnabled = true
        collectionView.collectionViewLayout = gridLayout
        collectionView.reloadData()
        collectionView.showsHorizontalScrollIndicator = false
        btnNext.backgroundColor = ApplicationSettings.appPrimaryColor
        btnNext.setTitleColor(ApplicationSettings.appWhiteColor, for: .normal)
        btnPrevious.backgroundColor = ApplicationSettings.appPrimaryColor
        btnPrevious.setTitleColor(ApplicationSettings.appWhiteColor, for: .normal)
        DispatchQueue.runOnMainThread { [weak self]  in
            guard let `self` = self else {
                return
            }
            self.collectionView.isPagingEnabled = false
            self.collectionView.scrollToItem(at: IndexPath(item: self.selectedIndex, section: 0), at: UICollectionView.ScrollPosition.right, animated: false)
            self.collectionView.isPagingEnabled = true
        }
    }
    
    func scrollToNextCell() {
        if self.collectionView.visibleCurrentCellIndexPath?.row != (self.notificationArray.count - 1), let indexPath = self.collectionView.visibleCurrentCellIndexPath {
            let notificationIndex: Int = indexPath.row + 1
            self.notificationUnread(self.notificationArray[notificationIndex])
            self.collectionView.isPagingEnabled = false
            self.collectionView.scrollToItem(at: IndexPath(row: notificationIndex, section: 0), at: UICollectionView.ScrollPosition.right, animated: true)
            self.collectionView.isPagingEnabled = true
        }
    }

    func scrollToPreviousCell() {
        if self.collectionView.visibleCurrentCellIndexPath?.row != 0, let indexPath = self.collectionView.visibleCurrentCellIndexPath {
            let notificationIndex: Int = indexPath.row - 1
            self.notificationUnread(self.notificationArray[notificationIndex])
            self.collectionView.isPagingEnabled = false
            self.collectionView.scrollToItem(at: IndexPath(row: notificationIndex, section: 0), at: UICollectionView.ScrollPosition.left, animated: true)
            self.collectionView.isPagingEnabled = true
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnNextTapped(_ sender: Any) {
        btnNext.flash()
        self.scrollToNextCell()
    }
    
    @IBAction func btnPreviousTapped(_ sender: Any) {
        btnPrevious.flash()
        self.scrollToPreviousCell()
    }
    
    func notificationUnread(_ notification: UserNotification) {
        if !(notification.isRead ?? true) {
            ProManagerApi.notificationsRead(notificationId: notification.id ?? "").request(Result<NotificationResult>.self).subscribe(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                if response.status == ResponseType.success {
                    if let index = self.notificationArray.firstIndex(where: { $0.id == notification.id }) {
                        self.notificationArray[index].isRead = true
                    }
                }
            }, onError: { [weak self] error in
                guard let `self` = self else { return }
                self.showAlert(alertMessage: error.localizedDescription)
            }, onCompleted: {
            }).disposed(by: rx.disposeBag)
        }
    }
    
    func getFollowingNotifications(pageIndex: Int) {
        ProManagerApi.getNotification(page: pageIndex).request(Result<NotificationResult>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else { return }
            self.collectionView.es.stopPullToRefresh()
            self.collectionView.es.stopLoadingMore()
            self.dismissHUD()
            if response.status == ResponseType.success {
                self.postsCount = response.result?.count ?? 0
                if pageIndex == 0 {
                    self.notificationArray = response.result?.notifications ?? []
                } else {
                    self.notificationArray.append(contentsOf: response.result?.notifications ?? [])
                }
                self.collectionView.reloadData()
                if let handler = self.notificationArrayHandler {
                    handler(self.notificationArray, self.pageIndex, self.postsCount)
                }
                self.startLoading = false
            } else {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { [weak self] error in
            guard let `self` = self else { return }
            self.showAlert(alertMessage: error.localizedDescription)
            self.dismissHUD()
        }, onCompleted: {
        }).disposed(by: rx.disposeBag)
    }
    
    func userFollowing(_ notification: UserNotification, _ userId: String, _ index: Int) {
        ProManagerApi.setFollow(userId: userId).request(Result<NotificationResult>.self).subscribe(onNext: { [weak self] response in
            guard let `self` = self else {
                return
            }
            self.dismissHUD()
            if response.status == ResponseType.success {
                notification.isFollowing = true
                self.notificationArray[index] = notification
                for item in self.notificationArray {
                    if item.refereeUserId?.id == notification.refereeUserId?.id {
                        item.isFollowing = true
                    }
                }
                self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            } else {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { [weak self] error in
            guard let `self` = self else { return }
            self.showAlert(alertMessage: error.localizedDescription)
            self.dismissHUD()
        }, onCompleted: {
        }).disposed(by: rx.disposeBag)
    }
    
    func userUnFollowing(_ notification: UserNotification, _ userId: String, _ index: Int) {
        ProManagerApi.setUnFollow(userId: userId).request(Result<NotificationResult>.self).subscribe(onNext: { [weak self] response in
            guard let `self` = self else {
                return
            }
            self.dismissHUD()
            if response.status == ResponseType.success {
                notification.isFollowing = false
                self.notificationArray[index] = notification
                for item in self.notificationArray {
                    if item.refereeUserId?.id == notification.refereeUserId?.id {
                        item.isFollowing = false
                    }
                }
                self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            } else {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { [weak self] error in
            guard let `self` = self else { return }
            self.showAlert(alertMessage: error.localizedDescription)
            self.dismissHUD()
        }, onCompleted: {
        }).disposed(by: rx.disposeBag)
    }
    
    func followButtonTapped(_ notification: UserNotification?, _ index: Int) {
        if let notification = notification, let userId = notification.refereeUserId?.id {
            self.showHUD()
            if let following = notification.isFollowing, !following {
                self.userFollowing(notification, userId, index)
            } else {
                self.userUnFollowing(notification, userId, index)
            }
        }
    }
}

// MARK: - CollectionView DataSource
extension NotificationDetailsVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.notificationDetailsViewCell.identifier, for: indexPath) as? NotificationDetailsViewCell else {
            return UICollectionViewCell()
        }
        cell.notification = notificationArray[indexPath.row]
        cell.followButtonHandler = { [weak self] notification in
            guard let `self` = self else {
                return
            }
            self.followButtonTapped(notification, indexPath.row)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notificationArray.count
    }

    // prefetch
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if self.postsCount > self.notificationArray.count, indexPath.row >= notificationArray.count - 2 && !self.startLoading {
            startLoading = true
            self.pageIndex += 1
            self.showHUD()
            self.getFollowingNotifications(pageIndex: self.pageIndex)
        }
    }
}

extension UIButton {
    func flash() {
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.2
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 1
        layer.add(flash, forKey: nil)
    }
}
