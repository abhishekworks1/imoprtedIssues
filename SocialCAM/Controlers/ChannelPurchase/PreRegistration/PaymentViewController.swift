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
    var payPalConfig = PayPalConfiguration()
    var sizeOfPackage : Int = 0
    var packageName: String = ""
    var total : NSDecimalNumber = 0.0
    var items : [PayPalItem] = []
    var isPaymentDone : Bool = false
    var noOfChannels : Int = 0
    var isPackageForSelf: Bool = true
    var userId: String = ""
    var environment:String = PayPalEnvironmentSandbox {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    var paymentResponse : [String : [String : Any]] = [:]
    var acceptCreditCards: Bool = true {
        didSet {
            payPalConfig.acceptCreditCards = acceptCreditCards
        }
    }
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
        return
            
        payNowBtn.isEnabled = false
        let item1 = PayPalItem(name: "Chnanels Combo", withQuantity: 1, withPrice: NSDecimalNumber(string: String(price)), withCurrency: "USD", withSku: "Hip-00066")
        items = [item1]
        
        let subtotal = PayPalItem.totalPrice(forItems: items)
        let shipping = NSDecimalNumber(string: "0")
        let tax = NSDecimalNumber(string: "0")
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        total = subtotal.adding(shipping).adding(tax)
        let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "StoriCam", intent: .sale)
        payment.items = items
        payment.paymentDetails = paymentDetails
        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            present(paymentViewController!, animated: true, completion: nil)
        } else {
            print("Payment not processalbe: \(payment)")
        }
    }
    
    // MARK: -- View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        payPalConfig.acceptCreditCards = acceptCreditCards;
        payPalConfig.merchantName = "Simform Solutions"
        payPalConfig.merchantPrivacyPolicyURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full") as URL?
        payPalConfig.merchantUserAgreementURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full") as URL?
        payPalConfig.languageOrLocale = NSLocale.preferredLanguages[0]
        payPalConfig.payPalShippingAddressOption = .payPal;
        PayPalMobile.preconnect(withEnvironment: environment)
        CardIOUtilities.preload()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        PayPalMobile.preconnect(withEnvironment: environment)
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
extension PaymentViewController : PayPalPaymentDelegate {
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        self.activityIndicator.startAnimating()
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            let paymentResultDic = completedPayment.confirmation as NSDictionary
            let dicResponse: AnyObject? = paymentResultDic.object(forKey: "response") as AnyObject?
            let clientResponse : AnyObject? = paymentResultDic.object(forKey: "client") as AnyObject?
           
            self.paymentResponse["nameValuePairs"] = [
                    "response_type" : "payment",
                    "response" : [
                        "nameValuePairs" : [
                            "state" : "approved",
                            "intent" : "sale",
                            "id" : (dicResponse!["id"] as? String)!,
                            "create_time" : (dicResponse!["create_time"] as? String)!
                        ]
                    ],
                    "client" : [
                        "nameValuePairs" : [
                            "product_name" : (clientResponse!["product_name"] as? String)!,
                            "platform" : "iOS",
                            "paypal_sdk_version" : (clientResponse!["paypal_sdk_version"] as? String)!,
                            "environment" : "sandbox"
                        ]]]
          
            self.addPackage()
        })
    }
    
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
