//
//  SSViewController.swift
//  SSAppUpdater
//
//  Created by Mansi Vadodariya on 22/10/20.
//  Copyright © 2020 Simform Solutions Pvt Ltd. All rights reserved.
//

import UIKit
import StoreKit

class SSViewController: UIViewController {
    
    var currentWindow: UIWindow!
    var releaseNote: String = ""
    var trackID: Int?
    var appStoreVersion: String = ""
    var isAlreadyUpdated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if SSAppUpdater.shared.isForceUpdate {
            showForceAlert()
        } else {
            if isAlreadyUpdated {
                showAlreadyUpdatedAlert()
            } else {
                showOptionalAlert()
            }
        }
    }
    
    deinit {
        currentWindow = nil
    }
    
    private func showAlreadyUpdatedAlert() {
        let okAction = UIAlertAction(title: R.string.localizable.oK(), style: .default) { (action) in
            DispatchQueue.main.async {
                self.currentWindow = nil
            }
        }
        let alert = UIAlertController.showAlert(title: Bundle.getAppName(), message: R.string.localizable.appHasAlreadyUpdated(), actions: [okAction], preferredStyle: .alert)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    private func showForceAlert() {
        let updateAction = UIAlertAction(title: R.string.localizable.update(), style: .default) { (action) in
            self.launchAppUpdate()
        }
        
        let alert = UIAlertController.showAlert(title: Bundle.getAppName(), message: "\n \(R.string.localizable.aNewVersion()) \(appStoreVersion) \n\n \(releaseNote)", actions: [updateAction], preferredStyle: .alert)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    private func showOptionalAlert() {
        UserDefaults.alertPresentationDate = Date()
        let updateAction = UIAlertAction(title: R.string.localizable.update(), style: .default) { (action) in
            self.launchAppUpdate()
            DispatchQueue.main.async {
                self.currentWindow = nil
            }
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .default) { (action) in
            DispatchQueue.main.async {
                self.currentWindow = nil
            }
        }
        let skipAction = UIAlertAction(title: R.string.localizable.skipThisVersion(), style: .default) { (action) in
            DispatchQueue.main.async {
                UserDefaults.skipVersion = self.appStoreVersion
                self.currentWindow = nil
            }
        }
        var actions: [UIAlertAction] = []
        actions.append(updateAction)
        if SSAppUpdater.shared.skipVersionAllow {
            actions.append(skipAction)
        }
        actions.append(cancelAction)
        let alert = UIAlertController.showAlert(title: Bundle.getAppName(), message: "\n \(R.string.localizable.aNewVersion()) \(appStoreVersion) \n\n \(releaseNote)", actions: actions, preferredStyle: .alert)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    private func launchAppUpdate() {
        guard let appID = self.trackID,
            let url = URL(string: "https://itunes.apple.com/app/id\(appID)") else {
                return
        }
        DispatchQueue.main.async {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}

extension SSViewController: SKStoreProductViewControllerDelegate {
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true) {[weak self] in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                self.currentWindow = nil
            }
        }
        viewController.dismiss(animated: true, completion: nil)
    }
}
