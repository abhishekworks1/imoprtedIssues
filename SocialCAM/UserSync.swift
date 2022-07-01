//
//  UserSync.swift
//  SocialCAM
//
//  Created by Jasmin Patel on 18/06/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

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
            UserSync.shared.getOnboardingUserFlags { _ in
                
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
    
    func getOnboardingUserFlags(completion: @escaping (_ isCompleted: Bool?) -> Void) {
        let path = API.shared.baseUrlV2 + "user-flags"
        let headerWithToken : HTTPHeaders =  ["Content-Type": "application/json",
                                       "userid": Defaults.shared.currentUser?.id ?? "",
                                       "deviceType": "1",
                                       "x-access-token": Defaults.shared.sessionToken ?? ""]
        let request = AF.request(path, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headerWithToken, interceptor: nil)
        request.responseDecodable(of: OnboardingUserFlagsResponse.self) {(resposnse) in
            Defaults.shared.shouldDisplayQuickStartFirstOptionSelection = resposnse.value?.data?.ios_quickstart_firstoption == nil
            if (resposnse.value?.data?.ios_quickstart_firstoption == "makemoney") {
                Defaults.shared.selectedQuickStartOption = .makeMoney
            }
            self.saveCreateContentSteps(resposnse: resposnse.value)
            self.saveMobileDashboardSteps(resposnse: resposnse.value)
            self.saveMakeMoneySteps(resposnse: resposnse.value)
            completion(true)
        }
    }
    
    func saveCreateContentSteps(resposnse: OnboardingUserFlagsResponse?) {
        var options = [Int]()
        if (resposnse?.data?.ios_createcontent_quickCamCamera ?? false) {
            options.append(QuickStartOption.CreateContentOption.quickCamCamera.rawValue)
        }
        
        if (resposnse?.data?.ios_createcontent_fastSlowRecording ?? false) {
            options.append(QuickStartOption.CreateContentOption.fastSlowEditor.rawValue)
        }
        
        if (resposnse?.data?.ios_createcontent_quickieVideoEditor ?? false) {
            options.append(QuickStartOption.CreateContentOption.quickieVideoEditor.rawValue)
        }
        
        if (resposnse?.data?.ios_createcontent_bitmojis ?? false) {
            options.append(QuickStartOption.CreateContentOption.bitmojis.rawValue)
        }
        
        if (resposnse?.data?.ios_createcontent_pic2Art ?? false) {
            options.append(QuickStartOption.CreateContentOption.pic2Art.rawValue)
        }
        
        if (resposnse?.data?.ios_createcontent_socialMediaSharing ?? false) {
            options.append(QuickStartOption.CreateContentOption.socialMediaSharing.rawValue)
        }
        
        if (resposnse?.data?.ios_createcontent_yourGoal ?? false) {
            options.append(QuickStartOption.CreateContentOption.yourGoal.rawValue)
        }
        
        Defaults.shared.createContentOptions = Array(Set(options))

    }
    
    func saveMobileDashboardSteps(resposnse: OnboardingUserFlagsResponse?) {
        var options = [Int]()
        if (resposnse?.data?.ios_mobiledashboard_notifications ?? false) {
            options.append(QuickStartOption.MobileDashboardOption.notifications.rawValue)
        }
        
        if (resposnse?.data?.ios_mobiledashboard_subscriptions ?? false) {
            options.append(QuickStartOption.MobileDashboardOption.subscriptions.rawValue)
        }
        
        if (resposnse?.data?.ios_mobiledashboard_howItWorks ?? false) {
            options.append(QuickStartOption.MobileDashboardOption.howItWorks.rawValue)
        }
        
        if (resposnse?.data?.ios_mobiledashboard_cameraSettings ?? false) {
            options.append(QuickStartOption.MobileDashboardOption.cameraSettings.rawValue)
        }
        
        if (resposnse?.data?.ios_mobiledashboard_checkForUpdates ?? false) {
            options.append(QuickStartOption.MobileDashboardOption.checkForUpdates.rawValue)
        }
        
        Defaults.shared.mobileDashboardOptions = Array(Set(options))
    }
    
    func saveMakeMoneySteps(resposnse: OnboardingUserFlagsResponse?) {
        var options = [Int]()
        if (resposnse?.data?.ios_makemoney_referralCommissionProgram ?? false) {
            options.append(QuickStartOption.MakeMoneyOption.referralCommissionProgram.rawValue)
        }
        
        if (resposnse?.data?.ios_makemoney_referralWizard ?? false) {
            options.append(QuickStartOption.MakeMoneyOption.referralWizard.rawValue)
        }
        
        if (resposnse?.data?.ios_makemoney_contactManagerTools ?? false) {
            options.append(QuickStartOption.MakeMoneyOption.contactManagerTools.rawValue)
        }
        
        if (resposnse?.data?.ios_makemoney_potentialCalculator ?? false) {
            options.append(QuickStartOption.MakeMoneyOption.potentialCalculator.rawValue)
        }
        
        if (resposnse?.data?.ios_makemoney_fundraising ?? false) {
            options.append(QuickStartOption.MakeMoneyOption.fundraising.rawValue)
        }
        
        if (resposnse?.data?.ios_makemoney_yourGoal ?? false) {
            options.append(QuickStartOption.MakeMoneyOption.yourGoal.rawValue)
        }
        
        Defaults.shared.makeMoneyOptions = Array(Set(options))

    }
    
    func setOnboardingUserFlags() {
        var params = [String : Any]()
        if Defaults.shared.selectedQuickStartOption == .makeMoney {
            params["ios_quickstart_firstoption"] = "makemoney"
        } else {
            params["ios_quickstart_firstoption"] = "createcontent"
        }
        for option in Defaults.shared.makeMoneyOptions {
            if let option = QuickStartOption.MakeMoneyOption.init(rawValue: option) {
                params[option.apiKey] = true
            }
        }
        for option in Defaults.shared.createContentOptions {
            if let option = QuickStartOption.CreateContentOption.init(rawValue: option) {
                params[option.apiKey] = true
            }
        }
        for option in Defaults.shared.mobileDashboardOptions {
            if let option = QuickStartOption.MobileDashboardOption.init(rawValue: option) {
                params[option.apiKey] = true
            }
        }
        print(params)
        let path = API.shared.baseUrlV2 + "user-flags"
        let headerWithToken : HTTPHeaders =  ["Content-Type": "application/json",
                                       "userid": Defaults.shared.currentUser?.id ?? "",
                                       "deviceType": "1",
                                       "x-access-token": Defaults.shared.sessionToken ?? ""]
        let request = AF.request(path, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerWithToken, interceptor: nil)

        request.responseDecodable(of: OnboardingUserFlagsResponse.self) { resposnse in
            Defaults.shared.shouldDisplayQuickStartFirstOptionSelection = resposnse.value?.data?.ios_quickstart_firstoption == nil
            if (resposnse.value?.data?.ios_quickstart_firstoption == "makemoney") {
                Defaults.shared.selectedQuickStartOption = .makeMoney
            }
            self.saveCreateContentSteps(resposnse: resposnse.value)
            self.saveMobileDashboardSteps(resposnse: resposnse.value)
            self.saveMakeMoneySteps(resposnse: resposnse.value)
        }
    }
    
}

class OnboardingUserFlagsResponse: Codable {
    
    var message: String?
    var success: Bool?
    var data: OnboardingUserFlag?
    
    private enum CodingKeys: String, CodingKey {
        case message
        case success
        case data = "data"
    }
    
}

public struct OnboardingUserFlag: Codable {
    
    var id: String?
    var userId: String?
    var ios_quickstart_firstoption: String?
    // Create Content
    var ios_createcontent_quickCamCamera: Bool?
    var ios_createcontent_fastSlowRecording: Bool?
    var ios_createcontent_quickieVideoEditor: Bool?
    var ios_createcontent_pic2Art: Bool?
    var ios_createcontent_bitmojis: Bool?
    var ios_createcontent_socialMediaSharing: Bool?
    var ios_createcontent_yourGoal: Bool?
    // Mobile Dashboard
    var ios_mobiledashboard_notifications: Bool?
    var ios_mobiledashboard_howItWorks: Bool?
    var ios_mobiledashboard_cameraSettings: Bool?
    var ios_mobiledashboard_subscriptions: Bool?
    var ios_mobiledashboard_checkForUpdates: Bool?
    // Make Money
    var ios_makemoney_referralCommissionProgram: Bool?
    var ios_makemoney_referralWizard: Bool?
    var ios_makemoney_contactManagerTools: Bool?
    var ios_makemoney_potentialCalculator: Bool?
    var ios_makemoney_fundraising: Bool?
    var ios_makemoney_yourGoal: Bool?

    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId = "userId"
        case ios_quickstart_firstoption = "ios_quickstart_firstoption"

        case ios_createcontent_quickCamCamera = "ios_createcontent_quickCamCamera"
        case ios_createcontent_fastSlowRecording = "ios_createcontent_fastSlowRecording"
        case ios_createcontent_quickieVideoEditor = "ios_createcontent_quickieVideoEditor"
        case ios_createcontent_pic2Art = "ios_createcontent_pic2Art"
        case ios_createcontent_bitmojis = "ios_createcontent_bitmojis"
        case ios_createcontent_socialMediaSharing = "ios_createcontent_socialMediaSharing"
        case ios_createcontent_yourGoal = "ios_createcontent_yourGoal"
        
        case ios_mobiledashboard_notifications = "ios_mobiledashboard_notifications"
        case ios_mobiledashboard_howItWorks = "ios_mobiledashboard_howItWorks"
        case ios_mobiledashboard_cameraSettings = "ios_mobiledashboard_cameraSettings"
        case ios_mobiledashboard_subscriptions = "ios_mobiledashboard_subscriptions"
        case ios_mobiledashboard_checkForUpdates = "ios_mobiledashboard_checkForUpdates"

        case ios_makemoney_referralCommissionProgram = "ios_makemoney_referralCommissionProgram"
        case ios_makemoney_referralWizard = "ios_makemoney_referralWizard"
        case ios_makemoney_contactManagerTools = "ios_makemoney_contactManagerTools"
        case ios_makemoney_potentialCalculator = "ios_makemoney_potentialCalculator"
        case ios_makemoney_fundraising = "ios_makemoney_fundraising"
        case ios_makemoney_yourGoal = "ios_makemoney_yourGoal"

    }
    
}
