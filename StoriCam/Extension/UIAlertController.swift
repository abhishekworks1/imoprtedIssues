//
//  UIAlertController.swift
//  ProManager
//
//  Created by Jasmin Patel on 31/10/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

typealias AlertActionHandler = ((UIAlertAction) -> Void)

extension UIAlertController.Style {
    func controller(title: String?, message: String?, actions: [UIAlertAction]) -> UIAlertController {
        let _controller = UIAlertController(
            title: title,
            message: message,
            preferredStyle: self
        )
        actions.forEach { _controller.addAction($0) }
        return _controller
    }
}
