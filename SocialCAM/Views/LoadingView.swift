//
//  LoadingView.swift
//  LoaderView
//
//  Created by Viraj Patel on 31/07/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

protocol LoadingViewEffect {
    func setup(main: LoadingView)
    func prepareForResize(main: LoadingView)
    func update(at time: TimeInterval)
}

internal class LoadingContainerView: UIView {
    
    internal var loadingView: LoadingView!
    
    deinit {
        print("Deinit \(self.description)")
    }
    
    internal init(loadingView: LoadingView) {
        self.loadingView = loadingView
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.loadingView = LoadingView()
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        if loadingView.shouldDimBackground {
            backgroundColor = loadingView.dimBackgroundColor
        } else {
            backgroundColor = ApplicationSettings.appClearColor
        }
        self.isUserInteractionEnabled = loadingView.isBlocking
        addSubview(loadingView)
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        loadingView.widthAnchor.constraint(equalToConstant: loadingView.sizeInContainer.width).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: loadingView.sizeInContainer.height).isActive = true
    }
    
    internal func free() {
        if let _ = superview { removeFromSuperview() }
        if let loadingView = loadingView { loadingView.removeFromSuperview() }
        loadingView = nil
    }
}

public class LoadingView: UIView {
    
    class func instanceFromNib() -> LoadingView {
        return R.nib.loadingView.firstView(owner: nil) ?? LoadingView(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
    }
    
    @IBInspectable public var speedFactor: CGFloat = 1.0
    @IBInspectable public var mainColor: UIColor = ApplicationSettings.appWhiteColor
    @IBInspectable public var colorVariation: CGFloat = 0.0
    @IBInspectable public var sizeFactor: CGFloat = 1.0
    @IBInspectable public var spreadingFactor: CGFloat = 1.0
    @IBInspectable public var lifeSpanFactor: CGFloat = 1.0
    @IBInspectable public var variantKey: String = ""
   
    var isResized = true
    var loadingText = "Processing Your Quickie" {
        didSet {
            processingYourQuickieLabel.text = loadingText
        }
    }
    @IBOutlet weak var lblTotalCount: UILabel!
    @IBOutlet weak var lblDescriptionText: UILabel!
    @IBOutlet weak var lblCompleted: UILabel!
    @IBOutlet weak var processingYourQuickieLabel: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var tipOfTheDayLabel: UILabel! {
        didSet {
            tipOfTheDayLabel.text = (Defaults.shared.tipOfDay ?? []).randomElement()
        }
    }
    @IBOutlet weak var tipOfTheDayView: UIView!

    @IBOutlet weak var timerLeftLabel: UILabel!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var dayValueLabel: UILabel!
    @IBOutlet weak var hourValueLabel: UILabel!
    @IBOutlet weak var minValueLabel: UILabel!
    @IBOutlet weak var secValueLabel: UILabel!
    @IBOutlet weak var freeModeDayImageView: UIImageView!
    @IBOutlet weak var freeModeHourImageView: UIImageView!
    @IBOutlet weak var freeModeMinImageView: UIImageView!
    @IBOutlet weak var freeModeSecImageView: UIImageView!
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var secLabel: UILabel!
    
    @IBOutlet weak var dayLineView: UIView!
    @IBOutlet weak var hourLineView: UIView!
    @IBOutlet weak var minLineView: UIView!
    @IBOutlet weak var secLineView: UIView!

    public var completedExportTotal: String = "0 / 0"
    
    public var showTotalCount = false {
        didSet {
            lblTotalCount.isHidden = !showTotalCount
            lblTotalCount.text = completedExportTotal
        }
    }
    
    public var shouldCancelShow = false {
        didSet {
            btnCancel.isHidden = shouldCancelShow
        }
    }
    
    public var loadingViewShow = false {
        didSet {
            lblCompleted.isHidden = loadingViewShow
            progressView.isHidden = loadingViewShow
            loadingView.isHidden = !loadingViewShow
        }
    }
    
    public var isExporting = false {
        didSet {
            lblCompleted.text = isExporting ? R.string.localizable.exporting() : R.string.localizable.saving()
        }
    }
    
    public var shouldDescriptionTextShow = false {
        didSet {
            lblDescriptionText.isHidden = !shouldDescriptionTextShow
        }
    }
    
    var containerView: LoadingContainerView?
    public var shouldDimBackground = true
    public var dimBackgroundColor = ApplicationSettings.appBlackColor.withAlphaComponent(0.6)
    public var isBlocking = true
    public var shouldTapToDismiss = false
    public var sizeInContainer: CGSize = CGSize(width: 180, height: 180)
    var isTrialExpire = false
    private var countdownTimer: Timer?

    var cancelClick: ((Bool) -> Void)?
    
    @IBAction func btnCancelClick(_ sender: UIButton) {
        if let handler = cancelClick {
            handler(true)
        }
    }
    
    @IBOutlet weak var progressView: CircularProgressBar! {
        didSet {
            progressView.labelSize = 26
            progressView.labelPercentSize = 26
            progressView.safePercent = 100
        }
    }
    
    weak var advertiseTimer: Timer?
    var currentSelectedImg: Int = 0 // for advertise selected imag
    var imgAdvertisementArray: [UIImage?] = [R.image.ad1(), R.image.ad2(), R.image.ad3() ,R.image.ad4(), R.image.ad5()]
    
    @IBOutlet weak var imgAdvertise: UIImageView!
    @IBOutlet weak var loadingView: FSLoading!
    
    deinit {
        print("Deinit \(self.description)")
        countdownTimer?.invalidate()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
   
    func startAdvertisementTimer() {
        if imgAdvertisementArray.count == 0 {
            imgAdvertise.isHidden = true
        } else {
            imgAdvertise.isHidden = false
        }
        if currentSelectedImg < imgAdvertisementArray.count {
            imgAdvertise.image = imgAdvertisementArray[currentSelectedImg]
        }
        advertiseTimer =  Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { [weak self] (_) in
            guard let `self` = self else {
                return
            }
            self.manageAdvertisement()
        }
        advertiseTimer?.tolerance = 0.1
        
    }
    
    func manageAdvertisement() {
        let nIndex = currentSelectedImg + 1
        if nIndex < imgAdvertisementArray.count {
            currentSelectedImg += 1
        } else {
            currentSelectedImg = 0
        }
        if currentSelectedImg < imgAdvertisementArray.count {
            self.imgAdvertise.image = self.imgAdvertisementArray[self.currentSelectedImg]
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        processingYourQuickieLabel.text = loadingText
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open func setup() {
        
      /*  if isLiteApp {
            if Defaults.shared.isFreeTrial == true {
                //checkForBanners(bannerImg: R.image.specialOfferForLifebanner())
                imgAdvertisementArray = [R.image.joinBusinessCenter()]
            } else if Defaults.shared.isFreeTrial == false {
                if Defaults.shared.appMode != .basic {
                    imgAdvertisementArray = [R.image.upgradeBasicLiteBanner()]
                    //checkForBanners(bannerImg: R.image.upgradeBasicLiteBanner())
                } else {
                    imgAdvertisementArray = [R.image.goToQuickCamBusinessCenter(),R.image.joinBusinessCenter()]
                    //checkForBanners(bannerImg: R.image.fullVersionComingBanner())
                }
            }
        } */
        
        if isLiteApp {
            let subscriptionType = Defaults.shared.subscriptionType
            imgAdvertisementArray = [R.image.upgradeBasicLiteBanner()]
            if Defaults.shared.isFreeTrial == true || subscriptionType?.lowercased() == "trial" {
                imgAdvertisementArray = [R.image.upgradeBasicLiteBanner(),
                                         R.image.upgradeToAdvance(),
                                         R.image.upgradeToPro(),
                                         R.image.gameMode(),
                                         R.image.giftCardBanner(),
                                         R.image.earlyBird()]
            } else {
                if subscriptionType?.lowercased() == "basic" {
                    imgAdvertisementArray = [R.image.upgradeToAdvance(),
                                             R.image.upgradeToPro(),
                                             R.image.gameMode(),
                                             R.image.giftCardBanner(),
                                             R.image.earlyBird()]
                } else if subscriptionType?.lowercased() == "advanced" {
                    imgAdvertisementArray = [ R.image.upgradeToPro(),
                                              R.image.gameMode(),
                                              R.image.giftCardBanner(),
                                              R.image.earlyBird()]
                } else if subscriptionType?.lowercased() == "pro" {
                    imgAdvertisementArray = [R.image.gameMode(),
                                             R.image.giftCardBanner(),
                                             R.image.earlyBird()]
                } else {
                    imgAdvertisementArray = [R.image.upgradeBasicLiteBanner(),
                                             R.image.upgradeToAdvance(),
                                             R.image.upgradeToPro(),
                                             R.image.gameMode(),
                                             R.image.giftCardBanner(),
                                             R.image.earlyBird()]
                }
            }
        }
        imgAdvertisementArray.shuffle()
        getDays()
        tipOfTheDayView.isHidden = !timerView.isHidden
    }
    
    func checkForBanners(bannerImg: UIImage?) {
        if !openApp(appName: R.string.localizable.vidPlay().lowercased()) && !openApp(appName: R.string.localizable.businesscenter()) {
            imgAdvertisementArray = [R.image.installVidplayBanner(), R.image.installBusinesscenterBanner()]
        } else if !openApp(appName: R.string.localizable.vidPlay().lowercased()) {
            imgAdvertisementArray = [R.image.installVidplayBanner()]
        } else if !openApp(appName: R.string.localizable.businesscenter()) {
            imgAdvertisementArray = [R.image.installBusinesscenterBanner()]
        } else {
            imgAdvertisementArray = [R.image.fullVersionComingBanner()]
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    public func showOnKeyWindow(completion: (() -> Void)? = nil) {
        show(on: UIApplication.shared.keyWindow!, completion: completion)
    }
    
    public func show(on view: UIView, completion: (() -> Void)? = nil) {
        progressView.setProgress(to: 0.0, withAnimation: false)
        var targetView = view
        if let view = view as? UIScrollView, let superView = view.superview {
            targetView = superView
        }
        // Remove existing container views
        let containerViews = targetView.subviews.filter { view -> Bool in
            return view is LoadingContainerView
        }
        containerViews.forEach { view in
            if let view = view as? LoadingContainerView { view.free() }
        }
        
        backgroundColor = ApplicationSettings.appClearColor
        sizeInContainer = view.frame.size
        containerView = LoadingContainerView(loadingView: self)
        if let containerView = containerView {
            
            containerView.translatesAutoresizingMaskIntoConstraints = false
            targetView.addSubview(containerView)
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            containerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            containerView.isHidden = true
            
            if shouldTapToDismiss {
                containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hide)))
            }
            showContainerView()
        }
        completion?()
    }
    
    static public func hideFromKeyWindow() {
        hide(from: UIApplication.shared.keyWindow!)
    }
    
    static public func hide(from view: UIView) {
        let containerViews = view.subviews.filter { (view) -> Bool in
            return view is LoadingContainerView
        }
        containerViews.forEach { (view) in
            if let containerView = view as? LoadingContainerView {
                containerView.loadingView.hide()
            }
        }
    }
    
    @objc open func hide() {
        tipOfTheDayLabel.text = (Defaults.shared.tipOfDay ?? []).randomElement()
        isExporting = false
        hideContainerView()
    }
   
    fileprivate func showContainerView() {
        DispatchQueue.runOnMainThread {
            if let containerView = self.containerView {
                containerView.isHidden = false
                containerView.alpha = 0.0
                UIView.animate(withDuration: 0.1) {
                    containerView.alpha = 1.0
                }
            }
        }
    }
    
    fileprivate func hideContainerView() {
        DispatchQueue.runOnMainThread {
            if let containerView = self.containerView {
                UIView.animate(withDuration: 0.1, animations: {
                    containerView.alpha = 0.0
                }, completion: { _ in
                    containerView.free()
                })
            }
        }
    }
    
    func openApp(appName: String) -> Bool {
        let appScheme = "\(appName)://app"
        guard let appUrl = URL(string: appScheme) else {
            return false
        }
        if UIApplication.shared.canOpenURL(appUrl) {
            return true
        } else {
            return false
        }
    }
    
    func hideAdView(_ hide:Bool){
        self.imgAdvertise.isHidden = hide
    }
    
}

extension LoadingView {
    
    func setTimerText(subscriptionStatus: String) {
        timerLeftLabel.isHidden = false
        if subscriptionStatus == SubscriptionTypeForBadge.TRIAL.rawValue {
            timerLeftLabel.text = "Time left in premium free trial"
        } else if subscriptionStatus == SubscriptionTypeForBadge.FREE.rawValue {
            timerLeftLabel.text = "Time since signed up"
        } else if  subscriptionStatus == SubscriptionTypeForBadge.EXPIRE.rawValue {
            timerLeftLabel.text = "Time since your subscription expired"
        } else {
            timerLeftLabel.isHidden = true
        }
    }
    
    func getDays() {
        guard let subscriptionType = Defaults.shared.currentUser?.subscriptionStatus else {
            return
        }
        timerView.isHidden = true
        freeModeDayImageView.isHidden = true
        freeModeMinImageView.isHidden = true
        freeModeSecImageView.isHidden = true
        freeModeHourImageView.isHidden = true
        
       // checkNewTrailPeriodExpire()
        var diffDays = 0
        if let timerStartDate = Defaults.shared.currentUser?.trialSubscriptionStartDateIOS?.isoDateFromString() {
            var timerDate = timerStartDate
            var dateComponent = DateComponents()
            if subscriptionType == "trial" {
                dateComponent.day = 8
            }
            if subscriptionType == "expired" {
                if let timerExpireDate = Defaults.shared.currentUser?.subscriptionEndDate?.isoDateFromString() {
                    timerDate = timerExpireDate
                }
            }
            
            if let futureDate = Calendar.current.date(byAdding: dateComponent, to: timerDate) {
                diffDays = futureDate.days(from: Date())
                
                if subscriptionType == "expired" || subscriptionType == "free" {
                    showUpTimer(timerDate: timerDate)
                } else {
                    showNewTimer(createdDate: timerDate, subscriptionType: subscriptionType)
                }
                setTimerText(subscriptionStatus: subscriptionType)
                self.showWelcomeData(subscriptionType: subscriptionType, daysLeft: diffDays)
            }
        } else {
            
        }
    }
    
    func checkNewTrailPeriodExpire() {
        if let timerDate = Defaults.shared.currentUser?.trialSubscriptionStartDateIOS?.isoDateFromString() {
            var dateComponent = DateComponents()
            dateComponent.day = 7
            if let futureDate = Calendar.current.date(byAdding: dateComponent, to: timerDate) {
                let trailDate = futureDate.timeIntervalSince(Date())
                self.isTrialExpire = trailDate.sign == .minus ? true : false
            }
        }
    }
    
    
    func showUpTimer(timerDate: Date) {
        timerView.isHidden = false
        countdownTimer?.invalidate()
        self.countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            let countdown = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: timerDate, to: Date())
            let days = countdown.day!
            let hours = countdown.hour!
            let minutes = countdown.minute!
            let seconds = countdown.second!
            self.secValueLabel.text = String(format: "%02d", seconds)
            self.minValueLabel.text = String(format: "%02d", minutes)
            self.hourValueLabel.text = String(format: "%02d", hours)
            self.dayValueLabel.text = String(format: "%01d", days)
        }
    }
    
    func showNewTimer(createdDate: Date, subscriptionType: String) {
        countdownTimer?.invalidate()
        timerView.isHidden = false
        var dateComponent = DateComponents()
        dateComponent.day = 7
        if let futureDate = Calendar.current.date(byAdding: dateComponent, to: createdDate) {
            self.countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                let countdown = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: futureDate)
                let days = countdown.day!
                let hours = countdown.hour!
                let minutes = countdown.minute!
                let seconds = countdown.second!
                self.secValueLabel.text = String(format: "%02d", seconds)
                self.minValueLabel.text = String(format: "%02d", minutes)
                self.hourValueLabel.text = String(format: "%02d", hours)
                self.dayValueLabel.text = String(format: "%01d", days)
            }
        }
    }
    
    func showWelcomeData(subscriptionType: String, daysLeft: Int) {
        if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
            var originalSubscriptionType = subscriptionType
            if let paidSubscriptionStatus = Defaults.shared.currentUser!.paidSubscriptionStatus {
                originalSubscriptionType = paidSubscriptionStatus
            }
            if daysLeft == 7 {
                self.setuptimerViewBaseOnDayLeft(days: "\(daysLeft)", subscriptionType: originalSubscriptionType)
            } else if daysLeft == 0 || daysLeft < 0 {
                self.setuptimerViewBaseOnDayLeft(days: "0", subscriptionType: originalSubscriptionType)
            } else if daysLeft == 1 {
                self.setuptimerViewBaseOnDayLeft(days: "1", subscriptionType: originalSubscriptionType)
            } else {
                self.setuptimerViewBaseOnDayLeft(days: "\(daysLeft)", subscriptionType: originalSubscriptionType)
            }
        } else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
            self.setuptimerViewBaseOnDayLeft(days: "0", subscriptionType: subscriptionType)
        } else if subscriptionType == SubscriptionTypeForBadge.EXPIRE.rawValue {
            self.setuptimerViewBaseOnDayLeft(days: "0", subscriptionType: subscriptionType)
        } else if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
            self.setuptimerViewBaseOnDayLeft(days: "\(daysLeft)", subscriptionType: subscriptionType)
            self.subscribersHideTimer(subscriptionType: subscriptionType)
        } else if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
            self.setuptimerViewBaseOnDayLeft(days: "\(daysLeft)", subscriptionType: subscriptionType)
            self.subscribersHideTimer(subscriptionType: subscriptionType)
        } else if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue || subscriptionType == "premium" {
            self.setuptimerViewBaseOnDayLeft(days: "\(daysLeft)", subscriptionType: subscriptionType)
            self.subscribersHideTimer(subscriptionType: subscriptionType)
        }
    }
    
    func subscribersHideTimer(subscriptionType: String) {
        timerView.isHidden = true
    }
    
    func setUpLineIndicatorForSignupDay(lineColor: UIColor) {
        hourLineView.backgroundColor = lineColor
        minLineView.backgroundColor = lineColor
        secLineView.backgroundColor = lineColor
        dayLineView.backgroundColor = lineColor
    }
    
    func setUpTimerViewForSignupDay() {
        timerView.isHidden = false
        freeModeDayImageView.isHidden = true
        freeModeMinImageView.isHidden = true
        freeModeSecImageView.isHidden = true
        freeModeHourImageView.isHidden = true
        dayLineView.isHidden = false
        hourLineView.isHidden = false
        minLineView.isHidden = false
        secLineView.isHidden = false
        dayLabel.isHidden = false
        hourLabel.isHidden = false
        minLabel.isHidden = false
        secLabel.isHidden = false
        dayValueLabel.isHidden = false
        hourValueLabel.isHidden = false
        secValueLabel.isHidden = false
        minValueLabel.isHidden = false
    }
    
    func setImageForDays(days: String, imageName: String) {
        freeModeDayImageView.image = UIImage(named: "\(imageName)\(days)")
        freeModeMinImageView.image = UIImage(named: "\(imageName)\(days)")
        freeModeSecImageView.image = UIImage(named: "\(imageName)\(days)")
        freeModeHourImageView.image = UIImage(named: "\(imageName)\(days)")
    }
    
    func setUpTimerViewForZeroDay() {
        timerView.isHidden = false
        freeModeDayImageView.isHidden = false
        freeModeMinImageView.isHidden = false
        freeModeSecImageView.isHidden = false
        freeModeHourImageView.isHidden = false
        dayLineView.isHidden = true
        hourLineView.isHidden = true
        minLineView.isHidden = true
        secLineView.isHidden = true
        dayLabel.isHidden = true
        hourLabel.isHidden = true
        minLabel.isHidden = true
        secLabel.isHidden = true
        dayValueLabel.isHidden = true
        hourValueLabel.isHidden = true
        secValueLabel.isHidden = true
        minValueLabel.isHidden = true
        
    }
    
    func setUpTimerViewForOtherDay() {
        timerView.isHidden = false
        freeModeDayImageView.isHidden = false
        freeModeMinImageView.isHidden = false
        freeModeSecImageView.isHidden = false
        freeModeHourImageView.isHidden = false
        dayLineView.isHidden = true
        hourLineView.isHidden = true
        minLineView.isHidden = true
        secLineView.isHidden = true
        dayLabel.isHidden = false
        hourLabel.isHidden = false
        minLabel.isHidden = false
        secLabel.isHidden = false
        dayValueLabel.isHidden = false
        hourValueLabel.isHidden = false
        secValueLabel.isHidden = false
        minValueLabel.isHidden = false
    }
    
    func setuptimerViewBaseOnDayLeft(days: String, subscriptionType: String) {
        print("----o \(subscriptionType)")
        if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
            setUpLineIndicatorForSignupDay(lineColor: UIColor(red: 1, green: 0, blue: 0, alpha: 1))
            
            if days == "0" {
                setImageForDays(days: days, imageName: "freeOnboard")
                setUpTimerViewForZeroDay()
            } else if (days == "7") {
                setUpTimerViewForSignupDay()
            }
            else {
                setImageForDays(days: days, imageName: "freeOnboard")
                setUpTimerViewForOtherDay()
            }
            
        } else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
            setImageForDays(days: "1", imageName: "freeOnboard")
            setUpTimerViewForOtherDay()
            //setUpTimerViewForZeroDay()
        } else if subscriptionType == SubscriptionTypeForBadge.EXPIRE.rawValue {
            setImageForDays(days: "1", imageName: "freeOnboard")
            setUpTimerViewForOtherDay()
            //setUpTimerViewForZeroDay()
        } else if subscriptionType == SubscriptionTypeForBadge.BASIC.rawValue {
            setUpLineIndicatorForSignupDay(lineColor: UIColor(red: 0.614, green: 0.465, blue: 0.858, alpha: 1))
            if (days == "7") {
                setUpTimerViewForSignupDay()
            } else {
                setImageForDays(days: days, imageName: "basicOnboard")
                setUpTimerViewForOtherDay()
            }
            
        } else if subscriptionType == SubscriptionTypeForBadge.ADVANCE.rawValue {
            setUpLineIndicatorForSignupDay(lineColor: UIColor(red: 0.212, green: 0.718, blue: 1, alpha: 1))
            if (days == "7") {
                setUpTimerViewForSignupDay()
            } else {
                setImageForDays(days: days, imageName: "advanceOnboard")
                setUpTimerViewForOtherDay()
            }
        } else if subscriptionType == SubscriptionTypeForBadge.PRO.rawValue || subscriptionType == SubscriptionTypeForBadge.PREMIUM.rawValue {
            setUpLineIndicatorForSignupDay(lineColor: UIColor(red: 0.38, green: 0, blue: 1, alpha: 1))
            if (days == "7") {
                setUpTimerViewForSignupDay()
            } else {
                setImageForDays(days: days, imageName: "premiumOnboard")
                setUpTimerViewForOtherDay()
            }
        }
    }
    
}
