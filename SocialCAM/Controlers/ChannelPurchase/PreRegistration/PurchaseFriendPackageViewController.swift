//
//  PurchaseFriendPackageViewController.swift
//  ProManager
//
//  Created by Steffi Pravasi on 18/09/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit

struct SelectedPackage {
    var price: Int = 5
    var numberOfChannels: Int = 5
    var packageName: String = "1 Package of 5 channels"
}

class PurchaseFriendPackageViewController: UIViewController {
    
    // MARK: -- Variables
    var numOfPackages: Int = 20
    var channelsInPackage: Int = 5
    var chargeOfPackage: Int = 5
    var arrayOfPackages: [String] = []
    var arrayOfAmount: [Int] = []
    var channels: [Int] = []
    var package: Int = 0
    var selectedPackage = SelectedPackage()
    var userId: String = ""
    var remainingPackageCountForOthers: Int = 0
    var isFromPreRegistration: Bool = false
    
    // MARK: -- Outlets
    @IBOutlet var dataView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var submitBtn: PButton!
    
    // MARK: -- View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(remainingPackageCountForOthers)
        if self.remainingPackageCountForOthers > 0 {
            if isFromPreRegistration {
                self.numOfPackages = 20 - (self.remainingPackageCountForOthers / 5)
            } else {
                self.numOfPackages = self.remainingPackageCountForOthers / 5
            }
        } else {
            self.numOfPackages = 20
        }
        self.tableView.rowHeight = 50
        if numOfPackages > 0 {
            for i in 1...numOfPackages {
                arrayOfPackages.append("\(i) Package of")
                channels.append(channelsInPackage)
                arrayOfAmount.append(chargeOfPackage)
                channelsInPackage += 5
                chargeOfPackage += 5
            }
            self.tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.submitBtn.isEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: -- Actions
    
    @IBAction func submitBtnClicked(_ sender: Any) {
        self.submitBtn.isEnabled = false
        if self.remainingPackageCountForOthers == 0 || isFromPreRegistration {
            if let vc = R.storyboard.preRegistration.paymentViewController() {
                vc.price =  selectedPackage.price
                vc.numberOfChannels = selectedPackage.numberOfChannels
                vc.packageName = selectedPackage.packageName
                vc.isPackageForSelf = false
                vc.userId = self.userId
                vc.isFromPreRegistration = self.isFromPreRegistration
                if !(self.remainingPackageCountForOthers == 0) {
                    vc.packagesForOthers = selectedPackage.numberOfChannels
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            print(self.userId)
            ChannelManagment.instance.addPackage(user: self.userId, parentId: Defaults.shared.parentID ?? (Defaults.shared.currentUser?.id ?? ""), packageName: selectedPackage.packageName, packageCount: selectedPackage.numberOfChannels, isOwner: false, paymentAmount: nil, paymentResponse: nil, { (success) in
                    self.navigationController?.popToRootViewController(animated: true)
                    UIApplication.showAlert(title: Constant.Application.displayName, message: R.string.localizable.youHaveSuccessfullyAddedThePackageForYourFriend())
                })
            }
    }
    
    @IBAction func backBtnCLicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: -- TableView Delegate Methods

extension PurchaseFriendPackageViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfPackages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.friendPackageTableViewCell.identifier) as? FriendPackageTableViewCell else {
            fatalError("FriendPackageTableViewCell not found")
        }
        cell.setData(name: arrayOfPackages[indexPath.row] , amount: arrayOfAmount[indexPath.row], numberChannels: channels[indexPath.row])
        cell.selectedView.isHidden = true
        if package == indexPath.row {
            cell.selectedView.isHidden = false
        }
        cell.buttonAction = { sender in
            if cell.selectedView.isHidden {
                self.package = indexPath.row
                cell.selectedView.isHidden = false
                self.tableView.reloadData()
                self.selectedPackage = SelectedPackage(price: self.arrayOfAmount[indexPath.row], numberOfChannels: self.channels[indexPath.row], packageName: "\(self.arrayOfPackages[indexPath.row]) \(self.channels[indexPath.row]) channels")
            } else {
                self.package = 0
                self.tableView.reloadData()
                cell.selectedView.isHidden = true
            }
        }
        return cell
    }

}
