//
//  InternetConnectionAlert.swift
//  ProManager
//
//  Created by Viraj Patel on 14/05/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

public var topSpace: Int = 0
public typealias InternetConnectionBlock = (_ result: Reachability) -> Void

public class InternetConnectionAlert: NSObject {

    // Configuration
    public struct Configuration {
        var kAlertText = R.string.localizable.nointernetconnectioN()
        var kBgColor: UIColor = ApplicationSettings.appPrimaryColor
        var kFont: UIFont = UIFont.sfuifont
        var kAlertHeight = 15
        var kTextColor = ApplicationSettings.appWhiteColor
        var kAnimationDuration = 0.5
        var kYPostion = topSpace
        public init() { }
    }

    public var config: Configuration = Configuration() {
        didSet {
            lblAlert.text = config.kAlertText
            lblAlert.backgroundColor = config.kBgColor
            lblAlert.font = config.kFont
            lblAlert.textColor = config.kTextColor
            setupAlert()
        }
    }

    static let shared = InternetConnectionAlert()
    var enableDebugging = true
    let reachability = Reachability()!
    let lblAlert = UILabel()
    public var internetConnectionHandler: InternetConnectionBlock?

    override init() {
        super.init()
        if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436 {
            topSpace = 30
        }
    }

    open var enable = false {
        didSet {
            if enable == true {
                setupInternetReachability()
                setupAlert()
                showLog("enable")
            } else {
                showLog("Disable")
            }
        }
    }

    private func stopRechability() {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name.reachabilityChanged,
                                                  object: reachability)
    }

    private func setupInternetReachability() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged), name: Notification.Name.reachabilityChanged, object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            showLog("Unable to start notifier")
        }
    }

    @objc func reachabilityChanged(note: Notification) {
        guard let reachability = note.object as? Reachability else {
            return
        }
        if self.internetConnectionHandler != nil {
            self.internetConnectionHandler!(reachability)
        }
        if reachability.connection != .none {
            if reachability.connection == .wifi {
                self.hideAlert()
                showLog("Reachable via WiFi")
            } else {
                self.hideAlert()
                showLog("Reachable via Cellular")
            }
        } else {
            self.showAlert()
            showLog("Network not reachable")
        }
    }

    private func showAlert() {
        let destinatioRect = CGRect(x: 0, y: config.kYPostion, width: Int(UIScreen.main.bounds.width), height: config.kAlertHeight)
        UIView.animate(withDuration: config.kAnimationDuration, animations: {
            self.lblAlert.frame = destinatioRect
        })
    }

    private func hideAlert() {
        let destinatioRect = CGRect(x: 0, y: config.kYPostion, width: Int(UIScreen.main.bounds.width), height: 0)
        UIView.animate(withDuration: config.kAnimationDuration) {
            self.lblAlert.frame = destinatioRect
        }
    }

    private func setupAlert() {
        lblAlert.frame = CGRect(x: 0, y: config.kYPostion, width: Int(UIScreen.main.bounds.width), height: 0)
        lblAlert.text = config.kAlertText
        lblAlert.backgroundColor = config.kBgColor
        lblAlert.textColor = config.kTextColor
        lblAlert.font = config.kFont
        lblAlert.textAlignment = .center
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let currentWindow = UIApplication.shared.keyWindow {
                self.lblAlert.removeFromSuperview()
                currentWindow.addSubview(self.lblAlert)
            }
        }
    }

    private func showLog(_ logString: String) {
        if enableDebugging {
            print("InternetConnectionAlert: ", logString)
        }
    }
}
