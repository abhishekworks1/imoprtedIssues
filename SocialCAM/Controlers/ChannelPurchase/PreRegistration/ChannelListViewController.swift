//
//  ChannelListViewController.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 03/07/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit

protocol ChannelDelegate : class {
    func cancelSwitchChannel(_ viewController:ChannelListViewController)
    func finishedWithSwitchChannel(newChannel channel:User , _ viewController : ChannelListViewController)
}

class ChannelListViewController: UIViewController {
    
    //MARK: -- Outlets
    @IBOutlet var tblChannelList : UITableView!

    //MARK: -- Variables
    var selectedIndex : Int = 0
    var channelList : [User] = [] {
        didSet {
            for (index, channel) in self.channelList.enumerated() {
                if channel.id == Defaults.shared.currentUser?.id {
                    self.channelList.remove(at: index)
                    self.channelList.insert(channel, at: 0)
                    break
                }
            }
        }
    }
     
    var purchasedChannels: [User] {
        return self.channelList.filter({ return $0.id != Defaults.shared.currentUser?.id })
    }
    
    var remainingPackageCountForOthers: Int = 0
    var getPackage: GetPackage?
    weak var delegate : ChannelDelegate?
    
    //MARK: -- View life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.channelList = ChannelManagment.instance.channels
        self.tblChannelList.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      print(purchasedPackageForOthers.noOfChannels)
        ChannelManagment.instance.getPackage { (packageResult) in
            purchasedPackageForOthers.getPackage = packageResult
            purchasedPackageForOthers.noOfChannels = packageResult?.remainingPackageCount ?? 0
            purchasedPackageForOthers.availableChannel = packageResult?.remainingPackageCount ?? 0
            purchasedPackageForOthers.numberOfPackages = packageResult?.remainingOtherUserPackageCount ?? 0
            print(purchasedPackageForOthers.noOfChannels)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.getChannelList()
        self.tblChannelList.reloadData()
    }
    
    //MARK: -- Methods

    func getChannelList() {
        self.showHUD()
        ChannelManagment.instance.getChannelLists { (channels) in
            self.dismissHUD()
            self.channelList = channels
            self.tblChannelList.reloadData()
        }
    }
    //MARK: -- Actions
    
    @IBAction func dismissBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addChannelBtnClicked(_ sender: Any) {
        if purchasedPackageForOthers.noOfChannels > 0 {
            if let vc = R.storyboard.preRegistration.preRegistrationViewController() {
                vc.noOfChannels = purchasedPackageForOthers.noOfChannels
                vc.remainingPackageCountForOthers = self.remainingPackageCountForOthers
                vc.getPackage = self.getPackage
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            if let vc = R.storyboard.preRegistration.upgradeViewController() {
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}

//MARK: -- TableView Delegate methods

extension ChannelListViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchasedChannels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.channelTableViewCell.identifier) as? ChannelTableViewCell else {
            fatalError("ChannelTableViewCell Not Found")
        }
        cell.user = purchasedChannels[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
        
}
