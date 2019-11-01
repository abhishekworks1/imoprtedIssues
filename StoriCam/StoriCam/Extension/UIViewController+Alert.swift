//
//  UIViewController+Alert.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 27/11/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlert(alertMessage : String) ->  Void {
        let alert = UIAlertController(title: Constant.Application.displayName, message: alertMessage, preferredStyle: .alert)
        let ok = UIAlertAction(title: Messages.kOK, style:.default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
}
