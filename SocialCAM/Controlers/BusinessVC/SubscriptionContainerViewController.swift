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

    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var subscriptionImgV: UIImageView!
    
    @IBOutlet weak var activeFreeView: UIView!
    @IBOutlet weak var viewDetailFreeView: UIView!
    
    @IBOutlet weak var activeBasicView: UIView!
    @IBOutlet weak var viewDetailBasicView: UIView!
    
    @IBOutlet weak var activeAdvancedView: UIView!
    @IBOutlet weak var viewDetailAdvancedView: UIView!
    
    @IBOutlet weak var activeProView: UIView!
    @IBOutlet weak var viewDetailProView: UIView!
    
    
    @IBOutlet weak var lblBadgeFree: UILabel!
    @IBOutlet weak var lblBadgeBasic: UILabel!
    @IBOutlet weak var lblBadgeAdvanced: UILabel!
    @IBOutlet weak var lblBadgePro: UILabel!
    @IBOutlet weak var lbltrialDays: UILabel!
  
    @IBOutlet weak var freeAppleLogoCenterY: NSLayoutConstraint!
    @IBOutlet weak var basicAppleLogoCenterY: NSLayoutConstraint!
    @IBOutlet weak var advancedAppleLogoCenterY: NSLayoutConstraint!
    @IBOutlet weak var premiumAppleLogoCenterY: NSLayoutConstraint!

    // MARK: -
    // MARK: - Variables
    
    private var isViewControllerAdded = false
    private var pagingViewController = PagingViewController()
    private let indicatorWidth: CGFloat = 47
    private let indicatorWidthDividend: CGFloat = isLiteApp ? 2 : 4
    
    // MARK: -Delegate
    public weak var subscriptionDelegate: SubscriptionScreenDelegate?

    //
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupPagingViewController()
//        setupSubscriotion()
        
        viewDetailFreeView.isHidden = false
        viewDetailBasicView.isHidden = false
        viewDetailAdvancedView.isHidden = false
        viewDetailProView.isHidden = false
        
        
        activeFreeView.isHidden = true
        activeBasicView.isHidden = true
        activeAdvancedView.isHidden = true
        activeProView.isHidden = true
        
        
        if (Defaults.shared.subscriptionType?.lowercased() == "basic"){
            viewDetailBasicView.isHidden = true
            activeBasicView.isHidden = false
        }else if(Defaults.shared.subscriptionType?.lowercased() == "advance"){
            viewDetailAdvancedView.isHidden = true
            activeAdvancedView.isHidden = false
        }else if(Defaults.shared.subscriptionType?.lowercased() == "pro"){
            viewDetailProView.isHidden = true
            activeProView.isHidden = false
        }else{
            viewDetailFreeView.isHidden = true
            activeFreeView.isHidden = false
        }
        setSubscriptionBadgeDetails()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
    }
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationBarView.addBottomShadow()
    }
    
    @IBAction func didTapPremiumButton(_ sender: UIButton) {
        guard let subscriptionVc = R.storyboard.subscription.subscriptionsViewController() else { return }
        subscriptionVc.appMode = .professional
        subscriptionVc.subscriptionType = .professional
        navigationController?.pushViewController(subscriptionVc, animated: true)
    }
    
    
    @IBAction func didTapAdvancedButton(_ sender: UIButton) {
        guard let subscriptionVc = R.storyboard.subscription.subscriptionsViewController() else { return }
        subscriptionVc.appMode = .advanced
        subscriptionVc.subscriptionType = .advanced
        navigationController?.pushViewController(subscriptionVc, animated: true)
    }
    
    @IBAction func didTapBasicButton(_ sender: UIButton) {
        guard let subscriptionVc = R.storyboard.subscription.subscriptionsViewController() else { return }
        subscriptionVc.appMode = .basic
        subscriptionVc.subscriptionType = .basic
        navigationController?.pushViewController(subscriptionVc, animated: true)
    }
    
    
    @IBAction func didTapFreeButton(_ sender: UIButton) {
        guard let subscriptionVc = R.storyboard.subscription.subscriptionsViewController() else { return }
        subscriptionVc.appMode = .free
        subscriptionVc.subscriptionType = .free
        navigationController?.pushViewController(subscriptionVc, animated: true)
    }
    
    
    private func setupPagingViewController() {
        guard let freeSubscriptionVc = R.storyboard.subscription.subscriptionsViewController(), let basicSubscriptionVc = R.storyboard.subscription.subscriptionsViewController(), let advancedSubscriptionVc = R.storyboard.subscription.subscriptionsViewController(), let proSubscriptionVc = R.storyboard.subscription.subscriptionsViewController() else { return }
      
        freeSubscriptionVc.subscriptionType = .free
        basicSubscriptionVc.subscriptionType = .basic
        advancedSubscriptionVc.subscriptionType = .advanced
        proSubscriptionVc.subscriptionType = .professional
        if isLiteApp {
            pagingViewController = PagingViewController(viewControllers: [freeSubscriptionVc, basicSubscriptionVc,advancedSubscriptionVc,proSubscriptionVc])
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
    
    func setupSubscriotion(){
        var imgStr = "free-user-icon"
        if Defaults.shared.allowFullAccess ?? false == true{
            imgStr = "trial-user-icon"
        }else if (Defaults.shared.subscriptionType == "trial"){
            if (Defaults.shared.numberOfFreeTrialDays ?? 0 > 0){
                imgStr = "trial-user-icon"
            }else {
                imgStr = "free-user-icon"
            }
        }else if(Defaults.shared.subscriptionType == "basic")
        {
            if(Defaults.shared.isDowngradeSubscription ?? false == true){
                if (Defaults.shared.numberOfFreeTrialDays ?? 0 > 0){
                    imgStr = "active-icon"
                }else {
                    imgStr = "free-user-icon"
                }
            }else{
                imgStr = "active-icon"
            }
        }else{
            imgStr = "free-user-icon"
        }
        subscriptionImgV.image = UIImage.init(named: imgStr)
    }
    private func setSubscriptionBadgeDetails(){
        lblBadgeFree.text = ""
        lblBadgeBasic.text = ""
        lblBadgeAdvanced.text = ""
        lblBadgePro.text = ""
        lbltrialDays.text = ""
        if let badgearray = Defaults.shared.currentUser?.badges {
            for parentbadge in badgearray {
                let badgeCode = parentbadge.badge?.code ?? ""
                let freeTrialDay = parentbadge.meta?.freeTrialDay ?? 0
                let subscriptionType = parentbadge.meta?.subscriptionType ?? ""
                
                // Setup For iOS Badge
                if badgeCode == Badges.SUBSCRIBER_IOS.rawValue
                {
                   if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                       if freeTrialDay > 0{
                           let trialDayText = "You have \(freeTrialDay) days left on your free trial."
                           lbltrialDays.text = trialDayText
                       }
                        lblBadgeFree.text = freeTrialDay > 0 ? "\(freeTrialDay)" : ""
                       
                      // You have 0 days left on your free trial.
                    }else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
                        if freeTrialDay > 0 {
                            lblBadgeFree.text = "\(freeTrialDay)"
                        } else {
                            //iOS shield hide
                            //square badge show
                            lblBadgeFree.text = ""
                        }
                    }
                    if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
                        lblBadgeBasic.text = freeTrialDay == 0 ? "" : "\(freeTrialDay)"
                    }
                    if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
                        lblBadgeAdvanced.text = freeTrialDay == 0 ? "" : "\(freeTrialDay)"
                    }
                    if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue {
                        lblBadgePro.text = freeTrialDay == 0 ? "" : "\(freeTrialDay)"
                    }
                }
                
            }
        }
        freeAppleLogoCenterY.constant = (lblBadgeFree.text ?? "").trim.isEmpty ? 8 : 0
        basicAppleLogoCenterY.constant = (lblBadgeFree.text ?? "").trim.isEmpty ? 8 : 0
        advancedAppleLogoCenterY.constant = (lblBadgeFree.text ?? "").trim.isEmpty ? 8 : 0
        premiumAppleLogoCenterY.constant = (lblBadgeFree.text ?? "").trim.isEmpty ? 8 : 0
    }
    // MARK: -
    // MARK: - Button Action Methods
    
    @IBAction func btnBackTapped(_ sender: Any) {
//        if Defaults.shared.isSubscriptionApiCalled == false {
//            subscriptionDelegate?.backFromSubscription()
            self.navigationController?.popViewController(animated: true)
//        }
    }
}

// MARK: - SubscriptionScreenDelegateDelegate

public protocol SubscriptionScreenDelegate: AnyObject {

    func backFromSubscription()
}

extension UIView {
func addBottomShadow() {
    layer.masksToBounds = false
    layer.shadowRadius = 4
    layer.shadowOpacity = 1
    layer.shadowColor = UIColor.gray.cgColor
    layer.shadowOffset = CGSize(width: 0 , height: 2)
    layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                 y: bounds.maxY - layer.shadowRadius,
                                                 width: bounds.width,
                                                 height: layer.shadowRadius)).cgPath
}
}

enum VerticalLocation: String {
    case bottom
    case top
}

extension UIView {
    func addShadow(location: VerticalLocation, color: UIColor = .black, opacity: Float = 0.5, radius: CGFloat = 5.0) {
        switch location {
        case .bottom:
             addShadow(offset: CGSize(width: 0, height: 3), color: color, opacity: opacity, radius: radius)
        case .top:
            addShadow(offset: CGSize(width: 0, height: -3), color: color, opacity: opacity, radius: radius)
        }
    }

    func addShadow(offset: CGSize, color: UIColor = .darkGray, opacity: Float = 0.5, radius: CGFloat = 5.0) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
}

extension UIView {

    func applyGradient(isVertical: Bool, colorArray: [UIColor]) {
        layer.sublayers?.filter({ $0 is CAGradientLayer }).forEach({ $0.removeFromSuperlayer() })
         
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colorArray.map({ $0.cgColor })
        if isVertical {
            //top to bottom
            gradientLayer.locations = [0.0, 1.0]
        } else {
            //left to right
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        }
        
        backgroundColor = .clear
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }

}
