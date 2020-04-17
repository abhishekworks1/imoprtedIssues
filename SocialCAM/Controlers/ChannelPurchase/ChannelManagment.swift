//
//  ChannelManagment.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 23/08/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import NSObject_Rx

class ChannelManagment : NSObject {
    
    static let instance : ChannelManagment = {
        let ch = ChannelManagment()
        return ch
    }()
    
    var channels : [User] = []
    var noOfChannels : Int = 0
    var cart: CartResult?
    
    
    func getChannelLists(_ channelsBlock:((_ channels:[User])->Void)?) {
        ProManagerApi.getChannelList.request(ResultArray<User>.self).subscribe(onNext: { (response) in
            if response.status == ResponseType.success {
                self.channels = response.result ?? []
                print(self.channels)
                if let ch = channelsBlock {
                   ch(self.channels)
                }
                
            }
        }, onError: { (error) in
            print(error.localizedDescription)
        }, onCompleted: {
            
        }).disposed(by: self.rx.disposeBag)
    }

    func getPackage(_ packageBlock:((_ packageResult:GetPackage?)->Void)?) {
        var packageResponse : GetPackage?
        let parentId = Defaults.shared.parentID ?? (Defaults.shared.currentUser?.id ?? "")
        ProManagerApi.getPackage(parentId: parentId).request(Result<GetPackage>.self).subscribe(onNext: { (response) in
            if response.status == ResponseType.success {
                packageResponse = response.result
                print(response.result?.toJSON() ?? "")
                if let package = packageBlock {
                    package(packageResponse)
                }
            }
        }, onError: { (error) in
            print(error.localizedDescription)
        }, onCompleted: {

        }).disposed(by: (rx.disposeBag))
    }
    
    func deleteFromCart(channel: String,_ cartBlock:((_ cartResult:CartResult?)->Void)?) {
        let parentId = Defaults.shared.parentID ?? (Defaults.shared.currentUser?.id ?? "")
        ProManagerApi.deleteFromCart(userId: parentId , individualChannels: channel, packageName: 0, packageChannels: nil).request(Result<CartResult>.self).subscribe(onNext: { (response) in
            if response.status == ResponseType.success {
                print(response.toJSON())
                self.cart = response.result
                if let ch = cartBlock {
                    ch(self.cart)
                }
            }
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
            
        }).disposed(by: (rx.disposeBag))
    }
    
    func getCart(_ cartBlock:((_ cartResult:CartResult?)->Void)?) {
        let parentId = Defaults.shared.parentID ?? (Defaults.shared.currentUser?.id ?? "")
        ProManagerApi.getCart(parentId: parentId).request(Result<CartResult>.self).subscribe(onNext: { (response) in
            if response.status == ResponseType.success {
                self.cart = response.result
                if let ch = cartBlock {
                    ch(self.cart)
                }
            }
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
            
        }).disposed(by: (rx.disposeBag))
    }
    
    func addPackage(user: String, parentId: String, packageName: String , packageCount: Int, isOwner: Bool, paymentAmount: Int?, paymentResponse: [String : [String : Any]]?, _ successBlock:((_ success:String?)->Void)?) {
        let parentId = Defaults.shared.parentID ?? (Defaults.shared.currentUser?.id ?? "")
        ProManagerApi.addPackage(user: user, parentId: parentId, packageName: packageName , packageCount: packageCount, isOwner: isOwner, paymentAmount: paymentAmount, paymentResponse: paymentResponse).request(Result<CartResult>.self).subscribe(onNext: { (response) in
            if response.status == ResponseType.success {
                print(response.toJSON())
                if let ch = successBlock {
                    ch(response.status)
                }
            }
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
            
        }).disposed(by: (rx.disposeBag))
    }
}
