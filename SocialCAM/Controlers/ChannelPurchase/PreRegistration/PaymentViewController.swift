//
//  PaymentViewController.swift
//  ProManager
//
//  Created by Steffi Pravasi on 31/07/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import StoreKit

class PaymentViewController: UIViewController {
    
    // MARK:-- Variables
    var numberOfChannels : Int = 0
    var price : Int = 0
    var sizeOfPackage : Int = 0
    var packageName: String = ""
    var total : NSDecimalNumber = 0.0
    var isPaymentDone : Bool = false
    var noOfChannels : Int = 0
    var isPackageForSelf: Bool = true
    var userId: String = ""
    var paymentResponse : [String : [String : Any]] = [:]
    var paymentMethodArray : [String] = ["In-App Purchase"] // ["Secure Card Payment","Paypal","Bitcoin"]
    var imgArray : [UIImage] = [#imageLiteral(resourceName: "visa"),#imageLiteral(resourceName: "paypal_copy"),#imageLiteral(resourceName: "bitcoin")]
    var packagesForOthers: Int = 0
    var isFromPreRegistration: Bool = false
    var getPackage: GetPackage?
    let parentId = Defaults.shared.parentID ?? (Defaults.shared.currentUser?.id ?? "")
    var products = [SKProduct]()
    var fromSignup = false
    // MARK: -- Outlets
    
    @IBOutlet var activityIndicator: NVActivityIndicatorView! {
        didSet {
            activityIndicator.color = ApplicationSettings.appPrimaryColor
        }
    }
    
    @IBOutlet var checkBtn: CheckButton!
    @IBOutlet var payNowBtn: UIButton!
    @IBOutlet var paymentTableView: UITableView!
    
    // MARK: -- Actions
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func paynowBtnClicked(_ sender: Any) {
        guard IAPManager.shared.canMakePayments(),
            let product = products.first else {
            return
        }
        self.showHUD()
        IAPManager.shared.buy(product: product) { (result) in
            DispatchQueue.main.async {
                self.dismissHUD()
                switch result {
                case .success(_):
                    print("sucess")
                    self.addPackage()
                    break
                case .failure(let error):
                    self.showAlert(alertMessage: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: -- View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        if isFromPreRegistration {
            self.userId = self.parentId
        }
        getProducts()
    }
    
    func getProducts() {
        IAPManager.shared.getProducts { (result) in
            DispatchQueue.main.async {
                switch result {
                    case .success(let products):
                        self.products = products
                    case .failure(let error):
                        self.showAlert(alertMessage: error.localizedDescription)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        payNowBtn.isEnabled = true
    }
    
    // MARK: -- Functions
    
    func go() {
        if isPaymentDone {
            let vc = R.storyboard.preRegistration.preRegistrationViewController()
            vc?.fromSignup = fromSignup
            vc?.isFromUpgrade = true
            vc?.noOfChannels = self.noOfChannels
            self.navigationController?.pushViewController(vc!, animated: true)
            self.activityIndicator.stopAnimating()
        }
    }

}

// MARK: -- TableView Delegate Methods
extension PaymentViewController : UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentMethodArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = paymentTableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.paymentTableViewCell.identifier) as? PaymentTableViewCell else {
            fatalError("PaymentTableViewCell not found")
        }
        cell.checkBtn.isSelected = !(indexPath.row == 0)
        cell.paymentLbl.text = paymentMethodArray[indexPath.row]
        cell.paymentMethodImgVw.image = nil // imgArray[indexPath.row]
        return cell
    }
    
}

// MARK: -- PayPal Delegate Methods
extension PaymentViewController {
    
    func addPackage() {
        ChannelManagment.instance.addPackage(user: self.userId, parentId: self.parentId, packageName: self.packageName, packageCount: self.numberOfChannels, isOwner: self.isPackageForSelf, paymentAmount: self.price, paymentResponse: self.paymentResponse, { (success) in
            ChannelManagment.instance.getPackage { (packageResult) in
                purchasedPackageForOthers.getPackage = packageResult
                purchasedPackageForOthers.noOfChannels = packageResult?.remainingPackageCount ?? 0
                purchasedPackageForOthers.availableChannel = packageResult?.remainingPackageCount ?? 0
                purchasedPackageForOthers.numberOfPackages = packageResult?.remainingOtherUserPackageCount ?? 0
                print(purchasedPackageForOthers.noOfChannels)
                self.isPaymentDone = true
                if self.isPackageForSelf {
                    self.go()
                } else if self.isFromPreRegistration {
                    if let vc = self.navigationController?.viewControllers.first(where: { return $0 is ChannelListViewController }) {
                        self.navigationController?.popToViewController(vc, animated: true)
                    } else {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                } else {
                    if let vc = self.navigationController?.viewControllers.first(where: { return $0 is ChannelListViewController }) {
                        self.navigationController?.popToViewController(vc, animated: true)
                    } else {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
            
            
        })
    }
}
