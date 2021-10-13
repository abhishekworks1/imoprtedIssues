//
//  NotificationVC.swift
//  SocialCAM
//
//  Created by Viraj Patel on 23/09/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit

class NotificationVC: UIViewController {
    var notificationArray: [UserNotification] = []
    var pageIndex: Int = 0
    var postsCount: Int = 0
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tblNotification: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblNotification.estimatedRowHeight = 50.0
        self.tblNotification.rowHeight = UITableView.automaticDimension
        self.tblNotification.es.addPullToRefresh { [weak self] in
            if let `self` = self {
                self.pageIndex = 0
                self.getFollowingNotifications(pageIndex: self.pageIndex)
            }
        }
        self.tblNotification.es.startPullToRefresh()
        self.tblNotification.es.addInfiniteScrolling { [weak self] in
            if let `self` = self {
                if self.postsCount > (self.notificationArray.count) {
                    self.pageIndex += 1
                    self.getFollowingNotifications(pageIndex: self.pageIndex)
                } else {
                    self.tblNotification.es.noticeNoMoreData()
                }
            }
        }
    }
    
    deinit {
        print("deinit-- \(self.description)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Action Methods
    @IBAction func onBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    func getFollowingNotifications(pageIndex: Int) {
        ProManagerApi.getNotification(page: pageIndex).request(Result<NotificationResult>.self).subscribe(onNext: { (response) in
            self.tblNotification.es.stopPullToRefresh()
            self.tblNotification.es.stopLoadingMore()
            if response.status == ResponseType.success {
                self.postsCount = response.result?.count ?? 0
                if pageIndex == 0 {
                    self.notificationArray = response.result?.notifications ?? []
                    if self.notificationArray.count == 0 {
                        self.emptyView?.isHidden = false
                    } else {
                        self.emptyView?.isHidden = true
                    }
                } else {
                    self.notificationArray.append(contentsOf: response.result?.notifications ?? [])
                }
                self.tblNotification.reloadData()
            } else {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
        }, onCompleted: {
        }).disposed(by: rx.disposeBag)
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

extension NotificationVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notificationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell") as? NotificationTableViewCell else {
            fatalError("NotificationTableViewCell Not Found")
        }
        cell.notification = self.notificationArray[indexPath.row]
        cell.profileImgHandler = { [weak self] notification in
            guard let `self` = self, let userNotification = notification else {
                return
            }
            self.notificationUnread(userNotification)
            if let popupViewController = R.storyboard.notificationVC.userDetailsVC() {
                popupViewController.notificationUpdateHandler = { [weak self] notification in
                    guard let `self` = self, let userNotification = notification else {
                        return
                    }
                    self.notificationArray[indexPath.row] = userNotification
                    for item in self.notificationArray {
                        if item.refereeUserId?.id == userNotification.refereeUserId?.id {
                            item.isFollowing = userNotification.isFollowing
                        }
                    }
                }
                popupViewController.notification = notification
                MIBlurPopup.show(popupViewController, on: self)
            }
        }
        cell.profileDeatilsHandler = { [weak self] notification in
            guard let `self` = self, let userNotification = notification else {
                return
            }
            self.notificationUnread(userNotification)
            if let notificationDetails = R.storyboard.notificationVC.notificationDetails() {
                notificationDetails.notificationArray = self.notificationArray
                notificationDetails.pageIndex = self.pageIndex
                notificationDetails.postsCount = self.postsCount
                notificationDetails.notification = notification
                notificationDetails.notificationArrayHandler = { [weak self] notificationArraay, index, count in
                    guard let `self` = self else {
                        return
                    }
                    self.notificationArray = notificationArraay
                    self.pageIndex = index
                    self.postsCount = count
                    self.tblNotification.reloadData()
                }
                self.navigationController?.pushViewController(notificationDetails, animated: true)
            }
        }
        cell.updateConstraints()
        cell.setNeedsUpdateConstraints()
        return cell
    }
    
    func notificationUnread(_ notification: UserNotification) {
        if !(notification.isRead ?? true) {
            ProManagerApi.notificationsRead(notificationId: notification.id ?? "").request(Result<NotificationResult>.self).subscribe(onNext: { (response) in
                if response.status == ResponseType.success {
                    if let index = self.notificationArray.firstIndex(where: { $0.id == notification.id }) {
                        self.notificationArray[index].isRead = true
                        self.tblNotification.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                }
            }, onError: { error in
            }, onCompleted: {
            }).disposed(by: rx.disposeBag)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = self.notificationArray[indexPath.row]
        self.notificationUnread(notification)
    }
}
