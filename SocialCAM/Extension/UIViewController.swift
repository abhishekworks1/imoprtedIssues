//
//  UIViewController+Alert.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 27/11/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit
import EasyTipView

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
    
    func getWebsiteId(completion: @escaping (String) -> ()) {
        if UIApplication.checkInternetConnection() {
            self.showHUD()
            ProManagerApi.getWebsiteData.request(WebsiteDataModel.self).subscribe(onNext: { (response) in
                self.dismissHUD()
                if let type = response.result?.result?.first(where: { $0.name == WebsiteData.websiteName })?.id {
                    completion(type)
                }
            }, onError: { error in
                self.showAlert(alertMessage: error.localizedDescription)
            }, onCompleted: {
            }).disposed(by: rx.disposeBag)
        } else {
            self.showAlert(alertMessage: R.string.localizable.nointernetconnectioN())
        }
    }
}
