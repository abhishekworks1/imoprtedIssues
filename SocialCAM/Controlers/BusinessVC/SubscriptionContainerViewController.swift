//
//  SubscriptionContainerViewController.swift
//  SocialCAM
//
//  Created by Kunjal Soni on 10/11/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit
import Parchment

class SubscriptionContainerViewController: UIViewController {
    
    // MARK: -
    // MARK: - Outlets

    @IBOutlet weak var containerView: UIView!
    
    // MARK: -
    // MARK: - Variables
    
    private var isViewControllerAdded = false
    private var pagingViewController = PagingViewController()
    private let indicatorWidth: CGFloat = 47
    private let indicatorWidthDividend: CGFloat = isLiteApp ? 2 : 4
    
    // MARK: -
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPagingViewController()
    }
    
    private func setupPagingViewController() {
        guard let freeSubscriptionVc = R.storyboard.subscription.subscriptionsViewController(), let basicSubscriptionVc = R.storyboard.subscription.subscriptionsViewController(), let advancedSubscriptionVc = R.storyboard.subscription.subscriptionsViewController(), let proSubscriptionVc = R.storyboard.subscription.subscriptionsViewController() else { return }
        
        freeSubscriptionVc.subscriptionType = .free
        basicSubscriptionVc.subscriptionType = .basic
        advancedSubscriptionVc.subscriptionType = .advanced
        proSubscriptionVc.subscriptionType = .professional
        if isLiteApp {
            pagingViewController = PagingViewController(viewControllers: [freeSubscriptionVc, basicSubscriptionVc])
        } else {
            pagingViewController = PagingViewController(viewControllers: [freeSubscriptionVc, basicSubscriptionVc, advancedSubscriptionVc, proSubscriptionVc])
        }
        let menuItemWidth = UIScreen.main.bounds.width / indicatorWidthDividend
        pagingViewController.menuItemLabelSpacing = 0
        pagingViewController.menuItemSize = .fixed(width: menuItemWidth, height: 50)
        let indicatorlineWidth = (menuItemWidth - indicatorWidth) / indicatorWidthDividend
        pagingViewController.indicatorOptions = PagingIndicatorOptions.visible(height: 3, zIndex: 5, spacing: UIEdgeInsets(top: 0, left: indicatorlineWidth, bottom: 0, right: indicatorlineWidth), insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        pagingViewController.menuBackgroundColor = .clear
        pagingViewController.indicatorColor = R.color.appPrimaryColor() ?? .blue
        pagingViewController.borderColor = .clear
        pagingViewController.textColor = .black
        pagingViewController.selectedTextColor = .black
        
        addChild(pagingViewController)
        self.containerView.addSubview(pagingViewController.view)
        pagingViewController.didMove(toParent: self)
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pagingViewController.includeSafeAreaInsets = false
        
        NSLayoutConstraint.activate([
            pagingViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pagingViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pagingViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            pagingViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor)
        ])
    }
    
    // MARK: -
    // MARK: - Button Action Methods
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
