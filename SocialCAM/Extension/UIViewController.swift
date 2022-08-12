//
//  UIViewController+Alert.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 27/11/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit
import ProgressHUD

extension UINavigationController {
    public func pushViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void)
    {
        pushViewController(viewController, animated: animated)
        
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
    
    func popViewController(animated: Bool, completion: @escaping () -> Void)
    {
        popViewController(animated: animated)
        
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
}

extension UINavigationController {
  func popToViewController(ofClass: AnyClass, animated: Bool = true) {
    if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
      popToViewController(vc, animated: animated)
    }
  }
}

extension UIViewController {
    
    func showAlert(alertMessage: String) {
        let alert = UIAlertController(title: Constant.Application.displayName, message: alertMessage, preferredStyle: .alert)
        let ok = UIAlertAction(title: Messages.kOK, style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .curveEaseIn, animations: {
            view.isHidden = hidden
            
        })
    }
    
    func findViewController<T>(viewcontrollers: [UIViewController], type: T) -> T? {
        for vc in viewcontrollers {
            if vc is T {
                return vc as? T
            }
        }
        return nil
    }
    
    //Previous code
    var activityIndicatorTag: Int { return 999999 }
    
    func startActivityIndicator(
        style: UIActivityIndicatorView.Style = .gray,
        location: CGPoint? = nil) {
        //Set the position - defaults to `center` if no`location`
        //argument is provided
        let loc = location ?? self.view.center
        //Ensure the UI is updated from the main thread
        //in case this method is called from a closure
        DispatchQueue.main.async {
            //Create the activity indicator
            let activityIndicator = UIActivityIndicatorView(style: style)
            //Add the tag so we can find the view in order to remove it later
            
            activityIndicator.tag = self.activityIndicatorTag
            //Set the location
            
            activityIndicator.center = loc
            activityIndicator.hidesWhenStopped = true
            //Start animating and add the view
            
            activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
        }
    }
    
    func stopActivityIndicator() {
        //Again, we need to ensure the UI is updated from the main thread!
        DispatchQueue.main.async {
            //Here we find the `UIActivityIndicatorView` and remove it from the vie
            if let activityIndicator = self.view.subviews.filter({ $0.tag == self.activityIndicatorTag}).first as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }
    }
    
    func showCustomAlert(message: String) {
        guard let customAlertViewController = R.storyboard.calculator.calculatorCustomAlertController() else { return }
        customAlertViewController.message = message
        customAlertViewController.modalPresentationStyle = .overFullScreen
        self.present(customAlertViewController, animated: true, completion: nil)
    }
    
    func showCalculationAlert(message: String, total: String) {
        guard let customAlertViewController = R.storyboard.calculator.calculationAlertViewController() else { return }
        customAlertViewController.message = message
        customAlertViewController.total = total
        customAlertViewController.modalPresentationStyle = .overFullScreen
        self.present(customAlertViewController, animated: true, completion: nil)
    }
    
    func getWebsiteId(completion: @escaping (String) -> ()) {
        if UIApplication.checkInternetConnection() {
            ProManagerApi.getWebsiteData.request(WebsiteDataModel.self).subscribe(onNext: { (response) in
                if let type = response.result?.result?.first(where: { $0.name == WebsiteData.websiteName })?.id {
                    completion(type)
                } else {
                    self.dismissHUD()
                    Utils.customaizeToastMessage(title: R.string.localizable.somethingWentWrongPleaseTryAgainLater(), toastView: self.view)
                }
            }, onError: { error in
                self.showAlert(alertMessage: error.localizedDescription)
                self.dismissHUD()
            }, onCompleted: {
            }).disposed(by: rx.disposeBag)
        } else {
            self.showAlert(alertMessage: R.string.localizable.nointernetconnectioN())
        }
    }
}

class ToastLabel: UILabel {
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top, left: -textInsets.left, bottom: -textInsets.bottom, right: -textInsets.right)

        return textRect.inset(by: invertedInsets)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
}

    
extension UIViewController {
    static let DELAY_SHORT = 1.5
    static let DELAY_LONG = 3.0
    
    func showToast(_ text: String, delay: TimeInterval = DELAY_LONG) {
        let label = ToastLabel()
        label.backgroundColor = UIColor(white: 0, alpha: 0.5)
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.alpha = 0
        label.text = text
        label.clipsToBounds = true
        label.layer.cornerRadius = 20
        label.numberOfLines = 0
        label.textInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let saveArea = view.safeAreaLayoutGuide
        label.centerXAnchor.constraint(equalTo: saveArea.centerXAnchor, constant: 0).isActive = true
        label.leadingAnchor.constraint(greaterThanOrEqualTo: saveArea.leadingAnchor, constant: 15).isActive = true
        label.trailingAnchor.constraint(lessThanOrEqualTo: saveArea.trailingAnchor, constant: -15).isActive = true
        label.bottomAnchor.constraint(equalTo: saveArea.bottomAnchor, constant: -30).isActive = true
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            label.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: delay, options: .curveEaseOut, animations: {
                label.alpha = 0
            }, completion: {_ in
                label.removeFromSuperview()
            })
        })
    }
}
    

