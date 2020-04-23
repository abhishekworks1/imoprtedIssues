//
//  CartViewController.swift
//  ProManager
//
//  Created by Steffi Pravasi on 25/07/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class CartViewController: UIViewController {
    
    // MARK: -- Outlets
    @IBOutlet var payBtn: UIButton!
    @IBOutlet var totalAmountLbl: UILabel!
    @IBOutlet var cartTableView: UITableView!
    @IBOutlet var activityIndicator: NVActivityIndicatorView! {
        didSet {
            activityIndicator.color = ApplicationSettings.appPrimaryColor
        }
    }
    
    @IBOutlet var deleteBtn: PButton!
    
    // MARK: -- Variables
    var myCart: CartResult?
    var totalAmount: Int = 0
    var listOfExistChannels: [String] = []
    var isClickedOnce: Bool = false
    var channels: [String] = []
    var fromSignup = false

    // MARK: -- View Did Load
    
    override func viewDidLoad() {
        self.tabBarController?.tabBar.isHidden = true
        super.viewDidLoad()
        channels = self.myCart?.individualChannels ?? []
        self.cartTableView.rowHeight = 150
        payBtn.layer.masksToBounds = true
        payBtn.layer.cornerRadius = payBtn.frame.height / 4
        self.cartTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    // MARK: -- Actions
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func ProceedToPaymentBtnClicked(_ sender: Any) {
        if self.channels.count > 0 {
            self.activityIndicator.startAnimating()
            if !self.isClickedOnce {
                self.isClickedOnce = true
                self.checkChannelExist()
            } else {
                print("Too many clicks")
            }
        } else {
            purchasedPackageForOthers.availableChannel = 5 - (myCart?.individualChannels?.count ?? 0)
            UIApplication.showAlert(title: Constant.Application.displayName, message: R.string.localizable.thereAreNoChannelsToDeletePleaseSelectTheChannelsFirst())
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    // MARK: -- Functions
    
    func addPayment() {
        let parentId = Defaults.shared.parentID ?? (Defaults.shared.currentUser?.id ?? "")
        ProManagerApi.addPayment(userId: parentId, channelNames: self.myCart?.individualChannels).request(Result<CartResult>.self).subscribe(onNext: { (response) in
            if response.status == ResponseType.success {
                print(response.toJSON())
                self.activityIndicator.stopAnimating()
                if self.myCart?.individualChannels?.count == 1 {
//                    UIApplication.showAlert(title: Constant.Application.displayName, message: R.string.localizable.congratulationsYourChannelNameHasBeenReserved())
                    self.view.makeToast(R.string.localizable.congratulationsYourChannelNameHasBeenReserved())

                } else {
                    self.view.makeToast(R.string.localizable.congratulationsYourChannelNamesHaveBeenReserved())
//                    UIApplication.showAlert(title: Constant.Application.displayName, message: R.string.localizable.congratulationsYourChannelNamesHaveBeenReserved())
                }
                if self.fromSignup {
                    Utils.appDelegate?.window?.rootViewController = R.storyboard.pageViewController.pageViewController()
                } else {
                    DispatchQueue.main.async {
                        if let vc = self.navigationController?.viewControllers.first(where: { return $0 is ChannelListViewController }) {
                            self.navigationController?.popToViewController(vc, animated: true)
                        } else {
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                }
            }
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
            
        }).disposed(by: (rx.disposeBag))
    }
    
    func checkChannelExist() {
        ProManagerApi.checkChannelExists(channelNames: myCart?.individualChannels ?? []).request(ChannelSuggestionResult.self).subscribe(onNext: { (response) in
            print(response.toJSON())
            if response.status == ResponseType.success {
                self.listOfExistChannels = response.existsChannel ?? []
                if self.listOfExistChannels.count == 0 {
                    self.addPayment()
                }
                
            } else {
                UIApplication.showAlert(title: Constant.Application.displayName, message: response.message ?? "")
                    self.listOfExistChannels = response.existsChannel ?? []
                    print(self.listOfExistChannels.count)
                    self.activityIndicator.stopAnimating()
                    self.cartTableView.reloadData()
                }
            }, onError: { (error) in
                print(error)
            }, onCompleted: {
                
            }).disposed(by: (rx.disposeBag))
    }
    
    func deleteChannel(index: Int) {
        let refreshAlert = UIAlertController(title: Constant.Application.displayName, message: R.string.localizable.areYouSureYouWantToRemoveThisItemFromCart(), preferredStyle: .alert)
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.channels.remove(at: index)
            ChannelManagment.instance.deleteFromCart(channel: self.myCart?.individualChannels![index] ?? "", {(cartResult) in
                self.myCart = cartResult
                if self.channels.count == 0 {
                    self.navigationController?.popViewController(animated: true)
                    UIApplication.showAlert(title: Constant.Application.displayName, message: R.string.localizable.thereAreNoChannelsToDeletePleaseSelectTheChannelsFirst())
                } else {
                    self.cartTableView.reloadData()
                }
            })
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
            refreshAlert .dismiss(animated: true, completion: nil)
        }))
        
        self.present(refreshAlert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: -- TableViewDelegate Methods
extension CartViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = cartTableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.cartTableViewCell.identifier) as? CartTableViewCell else {
                fatalError("CartTableViewCell not found")
            }
        if self.listOfExistChannels.count > 0 {
            for i in 0..<listOfExistChannels.count {
                let a = channels[indexPath.row] 
                let b = self.listOfExistChannels[i]
                if(a.caseInsensitiveCompare(b) == ComparisonResult.orderedSame) {
                    cell.channelPurchasedIndication.isHidden = false
                }
               
            }
        }
        cell.channelNameLbl.text = channels[indexPath.row]
        cell.deleteBtn.tag = indexPath.row
        cell.buttonAction = { sender in
            self.deleteChannel(index: sender.tag)
        }
            return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 52
    }
    
    @available(iOS 11.0, *)
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "") { (action, view, nil) in
           self.deleteChannel(index: indexPath.row)
        }
        edit.backgroundColor = #colorLiteral(red: 0.3215686275, green: 0.5960784314, blue: 0.2470588235, alpha: 1)
        edit.image = R.image.storyDelete()
        let config = UISwipeActionsConfiguration(actions: [edit])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
}
