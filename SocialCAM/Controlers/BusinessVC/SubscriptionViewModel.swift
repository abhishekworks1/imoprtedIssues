//
//  SubscriptionViewModel.swift
//  myASMR
//
//  Created by Nilisha Gupta on 07/09/20.
//  Copyright © 2020 Simform Solutions. All rights reserved.
//

import Foundation
import RxSwift

class SubscriptionViewModel {
    
    // MARK: - Variables
    private var validateReceiptDataBlock: ValidateInAppPurchaseCompletionBlock?
    internal var subscriptionPlanData = [Subscription]()
    internal var isSubscriptionPlansFetched = Dynamic(false)
    fileprivate var disposeBag = DisposeBag()
    internal var subscriptionError = Dynamic(String())
    internal var subscriptionResponseMsg = Dynamic((String(), Bool()))
    
    // MARK: - Validate receipt methods
    internal func validateRecieptOverSeverData(param: [String: Any], block: @escaping ValidateInAppPurchaseCompletionBlock) {
        self.validateReceiptDataBlock = block
        self.validateRecieptOverServer(param: param)
    }
    
    func validateRecieptOverServer(param: [String: Any]) {
        ProManagerApi.buySubscription(param: param).request(Result<BuySubscriptionResponseModel>.self).subscribe(onNext: { (response) in
           // if response.status == ResponseType.success {
            if ((response.message ?? "") == "Subscription Purchased."){
                self.subscriptionResponseMsg.value = (response.message ?? "", true)
            } else {
                Defaults.shared.isSubscriptionApiCalled = false
                self.subscriptionResponseMsg.value = (response.message ?? "", false)
            }
        }, onError: { error in
            Defaults.shared.isSubscriptionApiCalled = false
            self.subscriptionError.value = (error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: disposeBag)
    }
    
    // MARK: - IAP products methods
    internal func fetchIAPProducts() {
        PurchaseHelper.shared.setProductIds(ids: self.subscriptionPlanData.map({($0.productId ?? "")}))
        PurchaseHelper.shared.fetchAvailableProducts { }
    }
    
    internal func getPackageList(){
        ProManagerApi.subscriptionList.request(Result<SubscriptionList>.self).subscribe(onNext: { (response) in
            if response.status == ResponseType.success {
                guard let subscriptionsList = response.result?.subscriptions else {
                    self.subscriptionPlanData = []
                    return
                }
                self.subscriptionPlanData = subscriptionsList
                print(self.subscriptionPlanData.toJSON())
                self.isSubscriptionPlansFetched.value = true
                self.fetchIAPProducts()
            } else {
                self.isSubscriptionPlansFetched.value = false
                self.subscriptionError.value = (response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            Defaults.shared.isSubscriptionApiCalled = false
            self.subscriptionError.value = (error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: disposeBag)
    }
    
}
