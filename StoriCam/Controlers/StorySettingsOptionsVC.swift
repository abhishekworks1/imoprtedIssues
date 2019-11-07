//
//  StorySettingsOptionsVC.swift
//  ProManager
//
//  Created by Jasmin Patel on 27/07/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit

class StorySettingsOptionsVC: UIViewController {
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    var firstPercentage: Double = 0.0
    var firstUploadCompletedSize: Double = 0.0
    
    
    var settingsOptions = ["Privacy Settings",
                           "Control Center",
                           "Story Recover",
                           "Logout"]
    
    var settingsOptionsImages = [#imageLiteral(resourceName: "ico-privacy-s"),
                                 #imageLiteral(resourceName: "ico-control center"),
                                 #imageLiteral(resourceName: "ico-story recover"),
                                 #imageLiteral(resourceName: "ico-story recover")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    deinit {
        print("deinit StorySettingsOptionsVC")
    }

    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension StorySettingsOptionsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.storySettingsCell.identifier, for: indexPath) as? StorySettingsCell else {
            fatalError("StorySettingsCell Not Found")
        }
        cell.settingsName.text = settingsOptions[indexPath.row]
        cell.onOffButton.setImage(settingsOptionsImages[indexPath.row], for: UIControl.State.normal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            if let storySettingsVC = R.storyboard.storyCameraViewController.storySettingsVC() {
                navigationController?.pushViewController(storySettingsVC, animated: true)
            }
            break
        case 1:
            if let baseUploadVC = R.storyboard.storyCameraViewController.baseUploadVC() {
                baseUploadVC.firstModalPersiontage = firstPercentage
                baseUploadVC.firstModalUploadCompletedSize = firstUploadCompletedSize
                navigationController?.pushViewController(baseUploadVC, animated: true)
            }
            
            break
        case 2:
            self.showAlert(alertMessage: "Coming Soon...")
            break
        case 3:
            self.logoutUser()
            break
        default:
            break
        }
    }
    
    func logoutUser() {
        let objAlert = UIAlertController(title: "Log out", message: "Are you sure want to log out?", preferredStyle: .alert)
        let actionlogOut = UIAlertAction(title: "Log out", style: .default) { (action : UIAlertAction) in
            StoryDataManager.shared.deleteAllRecords()
            PostDataManager.shared.deleteAllRecords()
            
            SelectedTimer.removeAll()
            self.logoutApi(token: "")
            Defaults.shared.clearData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action : UIAlertAction) in }
        objAlert.addAction(actionlogOut)
        objAlert.addAction(cancelAction)
        self.present(objAlert, animated: true, completion: nil)
    }
    
    func logoutApi(token: String) {
        self.showHUD()
        ProManagerApi.logOut(deviceToken: token, userId: "").request(Result<User>.self).subscribe(onNext: { (result) in
            self.dismissHUD()
            Defaults.shared.currentUser = nil
            CurrentUser.shared.setActiveUser(nil)
            
            if let loginNav = R.storyboard.loginViewController.loginNavigation() {
                Utils.appDelegate?.window?.rootViewController = loginNav
            }
        }, onError: { (error) in
            self.dismissHUD()
            
            if let loginNav = R.storyboard.loginViewController.loginNavigation() {
                Utils.appDelegate?.window?.rootViewController = loginNav
                Utils.appDelegate?.window?.makeKeyAndVisible()
            }
        }, onCompleted: {
            self.dismissHUD()
        }).disposed(by: self.rx.disposeBag)
    }
}
