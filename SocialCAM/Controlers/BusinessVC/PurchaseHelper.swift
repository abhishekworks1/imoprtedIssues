//
//  PurchaseHelper.swift
//  myASMR
//
//  Created by Nilisha Gupta on 07/09/20.
//  Copyright © 2020 Simform Solutions. All rights reserved.
//

import Foundation
import StoreKit

/// Validate InApp Purchase Completion Block
typealias ValidateInAppPurchaseCompletionBlock = (Bool, Bool, String?) -> Void

typealias PurchaseCompleteCallBack = (_ isSuccess: Bool?, _ error: NSError?, _ isUserCancelled: Bool) -> Void

var appDelegate: AppDelegate? {
    return UIApplication.shared.delegate as? AppDelegate
}

class PurchaseHelper: NSObject {
    
    // MARK: - Variables
    var productIdentifier: [String] =  []
    var productID = ""
    var productServerID = ""
    var platformType = "ios"
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var isProduction: Bool?
    var fetchProductBlock: (() -> Void)?
    var purchaseCompleteBlock: PurchaseCompleteCallBack?
    var receiptValidationBlock: (() -> Void)?
    public static let shared = PurchaseHelper()
    public var isPaymentSuccessfull = Dynamic(false)
    var objSubscriptionListViewModel: SubscriptionViewModel = SubscriptionViewModel()
    
    // MARK: - Initializers
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        isProduction = Defaults.shared.releaseType == .store
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    // MARK: - Purchase Product Methods
    // Set Product Ids
    func setProductIds(ids: [String]) {
        self.productIdentifier = ids
    }
    
    func fetchAvailableProducts(block: @escaping (() -> Void)) {
        // Put here your IAP Products ID's
        fetchProductBlock = block
        let identifiers = Set(self.productIdentifier)
        productsRequest = SKProductsRequest(productIdentifiers: identifiers)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    // Make purchase of a product
    func canMakePurchases() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func purchaseProduct(product: SKProduct, productid: String, purchaseCompleteCallBack: @escaping PurchaseCompleteCallBack) {
        if self.canMakePurchases() {
            purchaseCompleteBlock = purchaseCompleteCallBack
            productsRequest.delegate = self
            productServerID = productid
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
            productID = product.productIdentifier
        } else {
            purchaseCompleteCallBack(nil, NSError(domain: Constant.IAPError.notMakePurchase, code: 10002, userInfo: nil), false)
        }
    }
    
}

// MARK: - Receipt Validation Methods
extension PurchaseHelper {
    
    func receiptValidation(block: @escaping (() -> Void)) {
        receiptValidationBlock = block
        guard let receiptFileURL = Bundle.main.appStoreReceiptURL else { return }
        do {
            let receiptData = try Data(contentsOf: receiptFileURL)
            let receiptString = receiptData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let mode = isProduction ?? false ? IAPMode.production.getStringValue() : IAPMode.sandbox.getStringValue()
            let data = receiptString
            let requestContents: [String: Any] = [Constant.BuySubscription.receipt: data, Constant.BuySubscription.password: inAppConfig, Constant.BuySubscription.mode: mode, Constant.BuySubscription.subscriptionID: productServerID, Constant.BuySubscription.platformType: platformType]
            validateReceiptFromServer(userInfo: requestContents)
        } catch {
            if let block = self.receiptValidationBlock {
                block()
            }
        }
    }
    
    func validateReceiptFromServer(userInfo: [String: Any]) {
        objSubscriptionListViewModel.validateRecieptOverSeverData(param: userInfo) { [weak self] (isSucess, isExpired, _) in
            guard let vSelf = self else { return }
            if isSucess {
                Defaults.shared.isSubscriptionExpired = isExpired
            } else {
                Defaults.shared.isSubscriptionExpired = true
            }
            if let block = vSelf.purchaseCompleteBlock {
                block(Defaults.shared.isSubscriptionExpired, nil, false)
            }
        }
    }
    
}

// MARK: - SKProductsRequestDelegate
extension PurchaseHelper: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print(response.products)
        print(response.invalidProductIdentifiers)
        if response.products.count > 0 {
            iapProducts = response.products
            if iapProducts.count > 0 {
                let purchasingProduct = response.products[0] as SKProduct
                // Get its price from iTunes Connect
                let numberFormatter = NumberFormatter()
                numberFormatter.formatterBehavior = .behavior10_4
                numberFormatter.numberStyle = .currency
                numberFormatter.locale = purchasingProduct.priceLocale
                if numberFormatter.string(from: purchasingProduct.price) != nil {
                    if let block = self.fetchProductBlock {
                        block()
                    }
                }
            } else {
                if let block = self.fetchProductBlock {
                    block()
                }
            }
        } else {
            if let block = self.fetchProductBlock {
                block()
            }
        }
    }
    
}

// MARK: - SKPaymentTransactionObserver
extension PurchaseHelper: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction: AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(trans)
                    if appDelegate?.isSubscriptionButtonPressed ?? false {
                        self.isPaymentSuccessfull.value = true
                        appDelegate?.isSubscriptionButtonPressed = false
                        receiptValidation {
                            self.isPaymentSuccessfull.value = false
                            if let block = self.purchaseCompleteBlock {
                                block(nil, NSError(domain: Constant.IAPError.purchaseFailed, code: 10002, userInfo: nil), false)
                            }
                        }
                    }
                case .failed:
                    SKPaymentQueue.default().finishTransaction(trans)
                    if trans.error != nil {
                        self.isPaymentSuccessfull.value = false
                        if let block = self.purchaseCompleteBlock {
                            if let error = trans.error {
                                let skError = SKError(_nsError: error as NSError)
                                if skError.code == .paymentCancelled {
                                    block(false, trans.error as NSError?, true)
                                } else {
                                    block(false, trans.error as NSError?, false)
                                }
                            } else {
                                block(false, trans.error as NSError?, false)
                            }
                        }
                    }
                case .restored:
                    SKPaymentQueue.default().finishTransaction(trans)
                    if appDelegate?.isSubscriptionButtonPressed ?? false {
                        self.isPaymentSuccessfull.value = true
                        appDelegate?.isSubscriptionButtonPressed = false
                        receiptValidation {
                            self.isPaymentSuccessfull.value = false
                            if let block = self.purchaseCompleteBlock {
                                block(nil, NSError(domain: Constant.IAPError.purchaseFailed, code: 10002, userInfo: nil), false)
                            }
                        }
                    }
                default: break
                }
            }
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        
    }
    
}
