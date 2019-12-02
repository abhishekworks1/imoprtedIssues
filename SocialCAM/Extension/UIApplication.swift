//
//  UIApplication.swift
//  ProManager
//
//  Created by Viraj Patel on 20/09/19.
//  Copyright © 2019 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import AVKit
import Photos
import SafariServices
import UIKit
import SystemConfiguration

extension UIApplication {
    
    class func showAlert(title: String, message: String) {
        let alert = UIAlertController.Style
            .alert
            .controller(title: title,
                        message: message,
                        actions: ["Ok".alertAction()])
        UIApplication.shared.windows.first!.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    class func connectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags: SCNetworkReachabilityFlags = []
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    @discardableResult
    class func checkInternetConnection()->Bool {
        if !self.connectedToNetwork() {
            return false
        }
        return true
    }
}
