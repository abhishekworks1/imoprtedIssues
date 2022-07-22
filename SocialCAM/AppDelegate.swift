//
//  AppDelegate.swift
//  SocialCAM
//
//  Created by Viraj Patel on 24/10/19.
//  Copyright © 2019 Viraj Patel. All rights reserved.
//

import UIKit
import CoreData
import Tiercel
import IQKeyboardManagerSwift
import Firebase
import FirebaseCrashlytics
import GooglePlaces
import GoogleMaps
import Bagel
import Sentry
import FirebaseMessaging
import UserNotifications
import PostHog

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var isSubscriptionButtonPressed = false
    var isUpdateAppButtonPressed = false
    var imagePath = ""

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.applicationIconBadgeNumber = 0
        configureIQKeyboardManager()
        
        Defaults.shared.showWelcomeScreenLoaderOnAppLaunch = "showWelcomeScreenLoaderOnAppLaunch"
        
        let configuration = PHGPostHogConfiguration(apiKey: Constant.PostHog.key, host: Constant.PostHog.host)
        configuration.captureApplicationLifecycleEvents = true; // Record certain application events automatically!
        configuration.recordScreenViews = true; // Record screen views automatically!
        PHGPostHog.setup(with: configuration)
        //Start Bagel
        if isDebug || isAlpha || isBeta {
            Bagel.start()
        }
        
        Defaults.shared.releaseType = ReleaseType.currentConfiguration()
        
        // Setup Sentry
        SentrySDK.start { options in
            options.dsn = Constant.Sentry.dsn
            options.debug = true // Enabled debug when first installing is always helpful
        }
        
        configureAppTheme()
        
        ColorCubeStorage.loadToDefault()
       
        StorySettings.storySettings = StorySettings.storySettings.filter({$0.settingsType != .subscriptions})
        
        if isSocialCamApp {
            print("[FIREBASE] SOCIALCAMAPP mode.")
            if let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
               let options = FirebaseOptions(contentsOfFile: filePath) {
                FirebaseApp.configure(options: options)
            } else {
                fatalError("GoogleService-Info.plist is missing!")
            }
        } else if isViralCamApp {
            print("[FIREBASE] VIRALCAMAPP mode.")
            if let filePath = Bundle.main.path(forResource: "GoogleService-Info-ViralCam", ofType: "plist"),
               let options = FirebaseOptions(contentsOfFile: filePath) {
                FirebaseApp.configure(options: options)
            } else {
                fatalError("GoogleService-Info-ViralCam.plist is missing!")
            }
            StorySettings.storySettings.filter({$0.settingsType == .socialLogins}).first?.settings.removeLast()
            StorySettings.storySettings = StorySettings.storySettings.filter({$0.settingsType != .controlcenter})
        } else if isSoccerCamApp {
            print("[FIREBASE] SOCCERCAMAPP mode.")
            if let filePath = Bundle.main.path(forResource: "GoogleService-Info-SoccerCam", ofType: "plist"),
               let options = FirebaseOptions(contentsOfFile: filePath) {
                FirebaseApp.configure(options: options)
            } else {
                fatalError("GoogleService-Info-SoccerCam.plist is missing!")
            }
            StorySettings.storySettings.filter({$0.settingsType == .socialLogins}).first?.settings.removeLast()
            StorySettings.storySettings = StorySettings.storySettings.filter({$0.settingsType != .controlcenter})
        } else if isFutbolCamApp {
            print("[FIREBASE] FutbolCam mode.")
            if let filePath = Bundle.main.path(forResource: "GoogleService-Info-FutbolCam", ofType: "plist"),
               let options = FirebaseOptions(contentsOfFile: filePath) {
                FirebaseApp.configure(options: options)
            } else {
                fatalError("GoogleService-Info-FutbolCam.plist is missing!")
            }
            StorySettings.storySettings.filter({$0.settingsType == .socialLogins}).first?.settings.removeLast()
            StorySettings.storySettings = StorySettings.storySettings.filter({$0.settingsType != .controlcenter})
        } else if isQuickCamApp {
            print("[FIREBASE] QuickCam mode.")
            if let filePath = Bundle.main.path(forResource: "GoogleService-Info-QuickCam", ofType: "plist"),
               let options = FirebaseOptions(contentsOfFile: filePath) {
                FirebaseApp.configure(options: options)
            } else {
                fatalError("GoogleService-Info-QuickCam.plist is missing!")
            }
            StorySettings.storySettings.filter({$0.settingsType == .socialLogins}).first?.settings.removeLast()
            StorySettings.storySettings = StorySettings.storySettings.filter({$0.settingsType != .controlcenter})
        } else if isSnapCamApp {
            print("[FIREBASE] SnapCam mode.")
            if let filePath = Bundle.main.path(forResource: "GoogleService-Info-SnapCam", ofType: "plist"),
               let options = FirebaseOptions(contentsOfFile: filePath) {
                FirebaseApp.configure(options: options)
            } else {
                fatalError("GoogleService-Info-FutbolCam.plist is missing!")
            }
            StorySettings.storySettings.filter({$0.settingsType == .socialLogins}).first?.settings.removeLast()
            StorySettings.storySettings = StorySettings.storySettings.filter({$0.settingsType != .controlcenter})
            SubscriptionSettings.storySettings.first?.settings.removeLast()
        } else if isPic2ArtApp {
            print("[FIREBASE] Pic2Art mode.")
            if let filePath = Bundle.main.path(forResource: "GoogleService-Info-Pic2Art", ofType: "plist"),
               let options = FirebaseOptions(contentsOfFile: filePath) {
                FirebaseApp.configure(options: options)
            } else {
                fatalError("GoogleService-Info-Pic2Art.plist is missing!")
            }
            StorySettings.storySettings.filter({$0.settingsType == .socialLogins}).first?.settings.removeLast()
            StorySettings.storySettings = StorySettings.storySettings.filter({$0.settingsType != .controlcenter})
        } else if isBoomiCamApp {
            if let filePath = Bundle.main.path(forResource: "GoogleService-Info-BoomiCam", ofType: "plist"),
               let options = FirebaseOptions(contentsOfFile: filePath) {
                FirebaseApp.configure(options: options)
            } else {
                fatalError("GoogleService-Info-BoomiCam.plist is missing!")
            }
            StorySettings.storySettings.filter({$0.settingsType == .socialLogins}).first?.settings.removeLast()
            StorySettings.storySettings = StorySettings.storySettings.filter({$0.settingsType != .controlcenter})
        } else if isTimeSpeedApp {
            print("[FIREBASE] TIMESPEEDAPP mode.")
            if let filePath = Bundle.main.path(forResource: "GoogleService-Info-TimeSpeed", ofType: "plist"),
               let options = FirebaseOptions(contentsOfFile: filePath) {
                FirebaseApp.configure(options: options)
            } else {
                fatalError("GoogleService-Info-TimeSpeed.plist is missing!")
            }
            StorySettings.storySettings.filter({$0.settingsType == .socialLogins}).first?.settings.removeLast()
            StorySettings.storySettings = StorySettings.storySettings.filter({$0.settingsType != .controlcenter})
        } else if isFastCamApp {
            print("[FIREBASE] FASTCAMAPP mode.")
            if let filePath = Bundle.main.path(forResource: "GoogleService-Info-FastCam", ofType: "plist"),
               let options = FirebaseOptions(contentsOfFile: filePath) {
                FirebaseApp.configure(options: options)
            } else {
                fatalError("GoogleService-Info-FastCam.plist is missing!")
            }
            StorySettings.storySettings.filter({$0.settingsType == .socialLogins}).first?.settings.removeLast()
            StorySettings.storySettings = StorySettings.storySettings.filter({$0.settingsType != .controlcenter})
            SubscriptionSettings.storySettings.first?.settings.removeLast()
        } else if isViralCamLiteApp {
            print("[FIREBASE] VIRALCAMLITEAPP mode.")
            if let filePath = Bundle.main.path(forResource: "GoogleService-Info-ViralCamLite", ofType: "plist"),
               let options = FirebaseOptions(contentsOfFile: filePath) {
                FirebaseApp.configure(options: options)
            } else {
                fatalError("GoogleService-Info-ViralCamLite.plist is missing!")
            }
            StorySettings.storySettings.filter({$0.settingsType == .socialLogins}).first?.settings.removeLast()
            StorySettings.storySettings = StorySettings.storySettings.filter({$0.settingsType != .controlcenter})
        } else if isFastCamLiteApp {
            print("[FIREBASE] FASTCAMLITEAPP mode.")
            if let filePath = Bundle.main.path(forResource: "GoogleService-Info-FastCamLite", ofType: "plist"),
               let options = FirebaseOptions(contentsOfFile: filePath) {
                FirebaseApp.configure(options: options)
            } else {
                fatalError("GoogleService-Info-FastCamLite.plist is missing!")
            }
            StorySettings.storySettings.filter({$0.settingsType == .socialLogins}).first?.settings.removeLast()
            StorySettings.storySettings = StorySettings.storySettings.filter({$0.settingsType != .controlcenter})
        } else if isQuickCamLiteApp || isQuickApp {
            print("[FIREBASE] QUICKCAMLITEAPP mode.")
            if let filePath = Bundle.main.path(forResource: "GoogleService-Info-QuickCam", ofType: "plist"),
               let options = FirebaseOptions(contentsOfFile: filePath) {
                FirebaseApp.configure(options: options)
            } else {
                fatalError("GoogleService-Info-QuickCam.plist is missing!")
            }
            StorySettings.storySettings.filter({$0.settingsType == .socialLogins}).first?.settings.removeLast()
            StorySettings.storySettings = StorySettings.storySettings.filter({$0.settingsType != .controlcenter})
        } else if isSpeedCamApp {
            print("[FIREBASE] SpeedCam mode.")
            if let filePath = Bundle.main.path(forResource: "GoogleService-Info-SpeedCam", ofType: "plist"),
               let options = FirebaseOptions(contentsOfFile: filePath) {
                FirebaseApp.configure(options: options)
            } else {
                fatalError("GoogleService-Info-SpeedCam.plist is missing!")
            }
            StorySettings.storySettings.filter({$0.settingsType == .socialLogins}).first?.settings.removeLast()
            StorySettings.storySettings = StorySettings.storySettings.filter({$0.settingsType != .controlcenter})
            SubscriptionSettings.storySettings.first?.settings.removeLast()
        } else if isSpeedCamLiteApp {
            if let filePath = Bundle.main.path(forResource: "GoogleService-SpeedCamLiteInfo", ofType: "plist"),
               let options = FirebaseOptions(contentsOfFile: filePath) {
                FirebaseApp.configure(options: options)
            } else {
                fatalError("GoogleService-SpeedCamLiteInfo.plist is missing!")
            }
            StorySettings.storySettings.filter({$0.settingsType == .socialLogins}).first?.settings.removeLast()
            StorySettings.storySettings = StorySettings.storySettings.filter({$0.settingsType != .controlcenter})
            SubscriptionSettings.storySettings.first?.settings.removeLast()
        } else if isSnapCamLiteApp {
            if let filePath = Bundle.main.path(forResource: "GoogleService-Info-SnapCamLite", ofType: "plist"),
               let options = FirebaseOptions(contentsOfFile: filePath) {
                FirebaseApp.configure(options: options)
            } else {
                fatalError("GoogleService-Info-SnapCamLite.plist is missing!")
            }
            StorySettings.storySettings.filter({$0.settingsType == .socialLogins}).first?.settings.removeLast()
            StorySettings.storySettings = StorySettings.storySettings.filter({$0.settingsType != .controlcenter})
            SubscriptionSettings.storySettings.first?.settings.removeLast()
        }
        
        configureGoogleService()
        
        FaceBookManager.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        _ = TwitterManger.shared
        
        _ = BackgroundManager.shared
        
        TiktokShare.shared.setupTiktok(application, didFinishLaunchingWithOptions: launchOptions)
        
        GoogleManager.shared.restorePreviousSignIn()
        
       // registerForPushNitification(application)
       // getFCMToken()
        
        InternetConnectionAlert.shared.enable = true
        
        var rootViewController: UIViewController? = R.storyboard.pageViewController.pageViewController()
        
        if let user = Defaults.shared.currentUser,
           let _ = Defaults.shared.sessionToken,
           let channelId = user.channelId,
           user.refferingChannel != nil,
           channelId.count > 0 {
            InternetConnectionAlert.shared.internetConnectionHandler = { reachability in
                if reachability.connection != .none {
                    StoryDataManager.shared.startUpload()
                    PostDataManager.shared.startUpload()
                }
            }
            switch Defaults.shared.onBoardingReferral {
            case OnboardingReferral.MobileDashboard.rawValue:
                if let pageViewController = rootViewController as? PageViewController,
                   let navigationController = pageViewController.pageControllers.first as? UINavigationController,
                   let settingVC = R.storyboard.storyCameraViewController.storySettingsVC() {
                    navigationController.viewControllers.append(settingVC)
                }
                break
            case OnboardingReferral.QuickMenu.rawValue:
                let welcomeNavigationVC = R.storyboard.welcomeOnboarding.welcomeViewController()
                welcomeNavigationVC?.viewControllers.append((R.storyboard.onBoardingView.onBoardingViewController()?.viewControllers.first)!)
                rootViewController = welcomeNavigationVC
                break
            case OnboardingReferral.welcomeScreen.rawValue:
                rootViewController = R.storyboard.welcomeOnboarding.welcomeViewController()
            default: break
            }
        } else {
            rootViewController = R.storyboard.loginViewController.loginNavigation()
        }
        #if TIMESPEEDAPP
        Defaults.shared.cameraMode = .basicCamera
        #elseif FASTCAMAPP
        Defaults.shared.cameraMode = .fastMotion
        #elseif FASTCAMLITEAPP
        Defaults.shared.cameraMode = .promo
        #elseif VIRALCAMLITEAPP
        Defaults.shared.cameraMode = .promo
        #elseif QUICKCAMLITEAPP
        Defaults.shared.cameraMode = .promo
        #else
        Defaults.shared.cameraMode = .promo
        #endif
        //isLiteApp (width: Constant.Application.splashImageSize, height: Constant.Application.splashImageSize)
        let revealingSplashView = RevealingSplashView(iconImage: Constant.Application.appIcon, iconInitialSize: isQuickApp ? CGSize(width: 50, height: 50) : Constant.Application.appIcon.size, backgroundImage: Constant.Application.splashBG)
        revealingSplashView.duration = 2.0
        revealingSplashView.iconColor = UIColor.red
        revealingSplashView.useCustomIconColor = false
        revealingSplashView.animationType = SplashAnimationType.popAndZoomOut
        rootViewController?.view.addSubview(revealingSplashView)
        UIApplication.shared.delegate!.window!!.rootViewController = rootViewController
        revealingSplashView.startAnimation() {
            dLog("Completed SplashView")
        }
        IAPManager.shared.startObserving()
        GoogleManager.shared.restorePreviousSignIn()
        
        FileManager.default.clearTempDirectory()

        //Analytics
        if isQuickCamLiteApp || isQuickApp || isQuickCamApp{
            // `host` is optional if you use PostHog Cloud (app.posthog.com)
            let configuration = PHGPostHogConfiguration(apiKey: Constant.Posthog.APIkey, host: Constant.Posthog.Host)

            configuration.captureApplicationLifecycleEvents = true; // Record certain application events automatically!
            //configuration.recordScreenViews = true; // Record screen views automatically!
            PHGPostHog.setup(with: configuration)
            Defaults.shared.addEventWithName(eventName: Constant.EventName.open_App)
        }
        
        return true
    }
    
    func configureAppTheme() {
        UISwitch.appearance().onTintColor = ApplicationSettings.appPrimaryColor
        UIProgressView.appearance().tintColor = ApplicationSettings.appPrimaryColor
        UITabBar.appearance().tintColor = ApplicationSettings.appPrimaryColor
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ApplicationSettings.appPrimaryColor], for: .selected)
        UISegmentedControl.appearance().tintColor = ApplicationSettings.appPrimaryColor
        UINavigationBar.appearance().tintColor = ApplicationSettings.appSkyBlueColor
    }
    
    func configureGoogleService() {
        GMSServices.provideAPIKey(Constant.GoogleService.serviceKey)
        GMSPlacesClient.provideAPIKey(Constant.GoogleService.placeClientKey)
    }
    
    func configureIQKeyboardManager() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldToolbarUsesTextFieldTintColor = true
        IQKeyboardManager.shared.disabledDistanceHandlingClasses = [DrawViewController.self]
        IQKeyboardManager.shared.disabledToolbarClasses = [DrawViewController.self]
    }
    
    var sessionManager: SessionManager = {
        var configuration = SessionConfiguration()
        configuration.allowsCellularAccess = true
        let manager = SessionManager("default", configuration: configuration, operationQueue: DispatchQueue(label: "com.Tiercel.SessionManager.operationQueue"))
        return manager
    }()
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        
        if sessionManager.identifier == identifier {
            sessionManager.completionHandler = completionHandler
        }
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "SocialCAM")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    open func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
//        print("&&&&&&&&&&&&&&")
//        print(url.query ?? "NO Image Path Found")
          imagePath = url.query ?? ""
//        print("&&&&&&&&&&&&&&")
        
        
        if GoogleManager.shared.handelOpenUrl(app: app, url: url, options: options) {
            return true
        } else if SnapKitManager.shared.application(app, open: url, options: options) {
            return true
        } else if TwitterManger.shared.application(app, open: url, options: options) {
            return true
        } else if TiktokShare.shared.application(app, open: url, sourceApplication: nil, annotation: [:]) {
            return true
        } else if FaceBookManager.shared.application(app, open: url, sourceApplication: nil, annotation: [:]) {
            return true
        }
//        else if WXApi.handleOpen(url, delegate: self) {
//            return true
//        }
        else if let viralcamURL = URL(string: "viralCam://com.simform.viralcam"),
                  viralcamURL == url {
            var rootViewController: UIViewController? = R.storyboard.pageViewController.pageViewController()
            if let user = Defaults.shared.currentUser,
               let _ = Defaults.shared.sessionToken,
               let channelId = user.channelId,
               channelId.count > 0 {
                InternetConnectionAlert.shared.internetConnectionHandler = { reachability in
                    if reachability.connection != .none {
                        StoryDataManager.shared.startUpload()
                        PostDataManager.shared.startUpload()
                    }
                }
            } else {
                rootViewController = R.storyboard.loginViewController.loginNavigation()
            }
            UIApplication.shared.delegate!.window!!.rootViewController = rootViewController
            return true
        } else if let deepLinkURL = URL(string: "\(DeepLinkData.appDeeplinkName.lowercased())://subscription"),
                  deepLinkURL == url {
            if let window = self.window {
                if let pageViewController = window.rootViewController as? PageViewController,
                   let navigationController = pageViewController.pageControllers.first as? UINavigationController {
                    if let subscriptionVC = R.storyboard.subscription.subscriptionContainerViewController() {
                        if let settingVC = R.storyboard.storyCameraViewController.storySettingsVC() {
                            navigationController.viewControllers.append(settingVC)
                        }
                        navigationController.pushViewController(subscriptionVC, animated: true)
                    }
                }
            }
            return true
        } else {
            // Process the URL.
            if let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true) {
                let fragments = components.fragment
                if fragments != nil {
                    components.query = fragments
                    if let url = components.scheme {
                        let redirectUrl = "\(url)\(KeycloakRedirectLink.endUrl)"
                        var code: String?
                        for item in components.queryItems! {
                            if item.name == R.string.localizable.code() {
                                code = item.value
                            }
                        }
                        loginWithKeycloak(code: code ?? "", redirectUrl: redirectUrl)
                    }
                } else {
                    if components.path?.hasSuffix("undefined") != true {
                        let pathComponents = url.pathComponents
                        if pathComponents.count == 6 {
                            Defaults.shared.channelId = pathComponents[3]
                            if pathComponents[4] != "null" {
                                Defaults.shared.sessionToken = pathComponents[4]
                                syncUserModel()
                            } else {
                                self.goToHomeScreen(isRefferencingChannelEmpty: true, isFromOtherApp: true, channelId: Defaults.shared.channelId ?? "", isSessionCodeExist: false)
                            }
                        }
                    } else {
                        let pathComponents = url.pathComponents
                        if pathComponents.count == 6 {
                            Defaults.shared.channelId = pathComponents[3]
                            goToHomeScreen(isRefferencingChannelEmpty: true, isFromOtherApp: true, channelId: Defaults.shared.channelId ?? "")
                        }
                    }
                }
            }
        }
        return false
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let options: [String: AnyObject] = [UIApplication.OpenURLOptionsKey.sourceApplication.rawValue: sourceApplication as AnyObject, UIApplication.OpenURLOptionsKey.annotation.rawValue: annotation as AnyObject]
        if FaceBookManager.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        } else if TwitterManger.shared.application(application, open: url, options: options) {
            return true
        } else if TiktokShare.shared.application(application, open: url, sourceApplication: nil, annotation: [:]) {
            return true
        }
//        else if WXApi.handleOpen(url, delegate: self) {
//            return true
//        }
        return false
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        if TiktokShare.shared.application(application, open: url, sourceApplication: nil, annotation: [:]) {
            return true
        }
//        else if WXApi.handleOpen(url, delegate: self) {
//            return true
//        }
        return false
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        Defaults.shared.postViralCamModel = nil
        IAPManager.shared.stopObserving()
        Defaults.shared.showWelcomeScreenLoaderOnAppLaunch = ""
    }
    
    func loginWithKeycloak(code: String, redirectUrl: String) {
        ProManagerApi.loginWithKeycloak(code: code, redirectUrl: redirectUrl).request(Result<LoginResult>.self).subscribe(onNext: { (response) in
            if response.status == ResponseType.success {
                print("***Login2***\(response)")
                self.goHomeScreen(response)
            }
        }, onError: { error in
        }, onCompleted: {
        }).disposed(by: rx.disposeBag)
    }
    
    func goHomeScreen(_ response: Result<LoginResult>) {
        Defaults.shared.sessionToken = response.sessionToken
        Defaults.shared.currentUser = response.result?.user
//        Defaults.shared.userSubscription = response.result?.userSubscription
        Defaults.shared.isRegistered = response.result?.isRegistered
        Defaults.shared.isPic2ArtShowed = response.result?.isRegistered
        Defaults.shared.isFirstTimePic2ArtRegistered = response.result?.isRegistered
        Defaults.shared.isFirstVideoRegistered = response.result?.isRegistered
        Defaults.shared.isFromSignup = response.result?.isRegistered
        Defaults.shared.userCreatedDate = response.result?.user?.created
        CurrentUser.shared.setActiveUser(response.result?.user)
        Crashlytics.crashlytics().setUserID(CurrentUser.shared.activeUser?.username ?? "")
        CurrentUser.shared.createNewReferrerChannelURL { (_, _) -> Void in }
        let parentId = Defaults.shared.currentUser?.parentId ?? Defaults.shared.currentUser?.id
        Defaults.shared.parentID = parentId
        #if !IS_SHAREPOST && !IS_MEDIASHARE && !IS_VIRALVIDS  && !IS_SOCIALVIDS && !IS_PIC2ARTSHARE
        self.goToHomeScreen(isRefferencingChannelEmpty: response.result?.user?.refferingChannel == nil, isFromOtherApp: false, channelId: response.result?.user?.channelId ?? "")
        #endif
    }
    
    func goToHomeScreen(isRefferencingChannelEmpty: Bool, isFromOtherApp: Bool, channelId: String, isSessionCodeExist: Bool = false) {
        #if PIC2ARTAPP || TIMESPEEDAPP || BOOMICAMAPP
        Utils.appDelegate?.window?.rootViewController = R.storyboard.pageViewController.pageViewController()
        #else
        if isRefferencingChannelEmpty {
            let keycloakURL = "\(websiteUrl)/referral/\(channelId)?redirect_uri=\(redirectUri)"
            goToKeycloakWebview(url: keycloakURL, isSessionCodeExist: isSessionCodeExist)
        } else {
            let cameraNavVC = R.storyboard.storyCameraViewController.storyCameraViewNavigationController()
//            let cameraNavVC = R.storyboard.storyCameraViewController.storySettingsVC()!
            cameraNavVC?.navigationBar.isHidden = true
            Utils.appDelegate?.window?.rootViewController = cameraNavVC
        }
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        #endif
    }
    
    func syncUserModel() {
        ProManagerApi.userSync.request(Result<UserSyncModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            if response.status == ResponseType.success {
                self.goToHomeScreen(isRefferencingChannelEmpty: response.result?.user?.refferingChannel == nil, isFromOtherApp: false, channelId: response.result?.user?.channelId ?? "")
            }
        }, onError: { error in
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
    
    func goToKeycloakWebview(url: String, isSessionCodeExist: Bool) {
        guard let keycloakAuthViewController = R.storyboard.loginViewController.keycloakAuthViewController() else {
            return
        }
        keycloakAuthViewController.urlString = url
        keycloakAuthViewController.isSessionCodeExist = isSessionCodeExist
        Utils.appDelegate?.window?.rootViewController = keycloakAuthViewController
    }
    
    // Push Notification Setup
    func registerForPushNitification(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            Messaging.messaging().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { _, _ in })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
    }
    
    func getFCMToken(completion:  @escaping (Bool) -> ()) {
        Messaging.messaging().token { (token, error) in
            if let error = error {
                debugPrint("ERROR FETCHING FCM TOKEN: \(error)")
                completion(false)
            } else if let token = token {
                Defaults.shared.deviceToken = token
                debugPrint("FCM registration Token: \(token)")
                completion(true)
            }
        }
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        Messaging.messaging().appDidReceiveMessage(userInfo)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            NotificationManager.shared.openNotificationScreen()
        }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .badge, .sound, .list])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        debugPrint("Firebase Registration Token: \(fcmToken)")
    }
    
}
