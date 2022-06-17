//
//  UserSync.swift
//  SocialCAM
//
//  Created by Jasmin Patel on 18/06/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import Foundation
import RxSwift

class UserSync {
    
    static let shared = UserSync()
    let disposeBag = DisposeBag()

    func syncUserModel(completion: @escaping (_ isCompleted: Bool?) -> Void) {
        ProManagerApi.userSync.request(Result<UserSyncModel>.self).subscribe(onNext: { (response) in
            if response.status == ResponseType.success {
                //print("***userSync***\(response)")
                Defaults.shared.currentUser = response.result?.user
                Defaults.shared.numberOfFreeTrialDays = response.result?.diffDays
                Defaults.shared.userCreatedDate = response.result?.user?.created
                Defaults.shared.isDowngradeSubscription = response.result?.userSubscription?.isDowngraded
                Defaults.shared.isFreeTrial = response.result?.user?.isTempSubscription
                Defaults.shared.allowFullAccess = response.result?.userSubscription?.allowFullAccess
                Defaults.shared.subscriptionType = response.result?.userSubscription?.subscriptionType
                Defaults.shared.socialPlatforms = response.result?.user?.socialPlatforms
                Defaults.shared.referredUserCreatedDate = response.result?.user?.refferedBy?.created
                Defaults.shared.publicDisplayName = response.result?.user?.publicDisplayName
                Defaults.shared.emailAddress = response.result?.user?.email
                Defaults.shared.privateDisplayName = response.result?.user?.privateDisplayName
                if let isAllowAffiliate = response.result?.user?.isAllowAffiliate {
                    Defaults.shared.isAffiliateLinkActivated = isAllowAffiliate
                }
                Defaults.shared.referredByData = response.result?.user?.refferedBy
                self.setAppModeBasedOnUserSync()
                completion(true)
            }
        }, onError: { error in
        }, onCompleted: {
        }).disposed(by: self.disposeBag)
    }
    
    func setAppModeBasedOnUserSync(){
        if Defaults.shared.allowFullAccess ?? false == true{
            Defaults.shared.appMode = .professional
        }else if (Defaults.shared.subscriptionType == "trial"){
            if (Defaults.shared.numberOfFreeTrialDays ?? 0 > 0){
                Defaults.shared.appMode = .professional
            }else {
                Defaults.shared.appMode = .free
            }
        }else if(Defaults.shared.subscriptionType == "basic")
        {
            if(Defaults.shared.isDowngradeSubscription ?? false == true){
                if (Defaults.shared.numberOfFreeTrialDays ?? 0 > 0){
                    Defaults.shared.appMode = .basic
                }else {
                    Defaults.shared.appMode = .free
                }
            }else{
                Defaults.shared.appMode = .basic
            }
        }else if(Defaults.shared.subscriptionType == "advance")
        {
            if(Defaults.shared.isDowngradeSubscription ?? false == true){
                if (Defaults.shared.numberOfFreeTrialDays ?? 0 > 0){
                    Defaults.shared.appMode = .advanced
                }else {
                    Defaults.shared.appMode = .free
                }
            }else{
                Defaults.shared.appMode = .advanced
            }
        }else if(Defaults.shared.subscriptionType == "pro")
        {
            if(Defaults.shared.isDowngradeSubscription ?? false == true){
                if (Defaults.shared.numberOfFreeTrialDays ?? 0 > 0){
                    Defaults.shared.appMode = .professional
                }else {
                    Defaults.shared.appMode = .free
                }
            }else{
                Defaults.shared.appMode = .professional
            }
        }else{
            Defaults.shared.appMode = .free
        }
    }
    
}
