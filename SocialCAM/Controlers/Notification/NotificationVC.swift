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
        ProManagerApi.getNotification(page: 0).request(Result<NotificationResult>.self).subscribe(onNext: { (response) in
            self.tblNotification.es.stopPullToRefresh()
            self.tblNotification.es.stopLoadingMore()
            print(response)
            if response.status == ResponseType.success {
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
        cell.updateConstraints()
        cell.setNeedsUpdateConstraints()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = self.notificationArray[indexPath.row]
        if !(notification.isRead ?? true) {
            ProManagerApi.notificationsRead(notificationId: notification.id ?? "").request(Result<NotificationResult>.self).subscribe(onNext: { (response) in
                if response.status == ResponseType.success {
                    self.notificationArray[indexPath.row].isRead = true
                    self.tblNotification.reloadRows(at: [indexPath], with: .automatic)
                }
            }, onError: { error in
            }, onCompleted: {
            }).disposed(by: rx.disposeBag)
        }
        if let popupViewController = R.storyboard.notificationVC.userDetailsVC() {
            popupViewController.notification = notification
            MIBlurPopup.show(popupViewController, on: self)
        }
    }
}
