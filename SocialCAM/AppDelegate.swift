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
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        configureIQKeyboardManager()
        
        configureAppTheme()
        
        ColorCubeStorage.loadToDefault()
       
        #if SOCIALCAMAPP
            print("[FIREBASE] SOCIALCAMAPP mode.")
            if let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
                let options = FirebaseOptions(contentsOfFile: filePath) {
                    FirebaseApp.configure(options: options)
            } else {
                fatalError("GoogleService-Info.plist is missing!")
            }
            StorySettings.storySettings = StorySettings.storySettings.filter({$0.settingsType != .logout})
        #elseif VIRALCAMAPP
            print("[FIREBASE] VIRALCAMAPP mode.")
            if let filePath = Bundle.main.path(forResource: "GoogleService-Info-ViralCam", ofType: "plist"),
                let options = FirebaseOptions(contentsOfFile: filePath) {
                    FirebaseApp.configure(options: options)
            } else {
                fatalError("GoogleService-Info-ViralCam.plist is missing!")
            }
            StorySettings.storySettings.filter({$0.settingsType == .socialLogins}).first?.settings.removeLast()
            StorySettings.storySettings = StorySettings.storySettings.filter({$0.settingsType != .controlcenter})
        #elseif PIC2ARTAPP
            print("[FIREBASE] Pic2Art mode.")
            if let filePath = Bundle.main.path(forResource: "GoogleService-Info-Pic2Art", ofType: "plist"),
                let options = FirebaseOptions(contentsOfFile: filePath) {
                    FirebaseApp.configure(options: options)
            } else {
                fatalError("GoogleService-Info-Pic2Art.plist is missing!")
            }
            StorySettings.storySettings.filter({$0.settingsType == .socialLogins}).first?.settings.removeLast()
            StorySettings.storySettings = StorySettings.storySettings.filter({$0.settingsType != .controlcenter})
        #elseif TIMESPEEDAPP
            print("[FIREBASE] TIMESPEEDAPP mode.")
            if let filePath = Bundle.main.path(forResource: "GoogleService-Info-TimeSpeed", ofType: "plist"),
                let options = FirebaseOptions(contentsOfFile: filePath) {
                FirebaseApp.configure(options: options)
            } else {
                fatalError("GoogleService-Info-TimeSpeed.plist is missing!")
            }
            StorySettings.storySettings.filter({$0.settingsType == .socialLogins}).first?.settings.removeLast()
            StorySettings.storySettings = StorySettings.storySettings.filter({$0.settingsType != .controlcenter})
        #endif
        
        configureGoogleService()
        
        FaceBookManager.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        _ = TwitterManger.shared
        
        _ = BackgroundManager.shared
        
        TiktokShare.shared.setupTiktok(application, didFinishLaunchingWithOptions: launchOptions)
        
        GoogleManager.shared.restorePreviousSignIn()
        
        MSAppCenter.start(Constant.AppCenter.apiKey, withServices: [MSAnalytics.self, MSCrashes.self])
        MSCrashes.hasReceivedMemoryWarningInLastSession()
      
        InternetConnectionAlert.shared.enable = true
        
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
            #if VIRALCAMAPP || PIC2ARTAPP || TIMESPEEDAPP
            rootViewController = R.storyboard.loginViewController.loginNavigation()
            #endif
        }
        #if TIMESPEEDAPP
        Defaults.shared.cameraMode = .basicCamera
        #else
        Defaults.shared.cameraMode = .normal
        #endif
        UIApplication.shared.delegate!.window!!.rootViewController = rootViewController
        configurePayPalMobile()
        IAPManager.shared.startObserving()

        return true
    }
    
    func configurePayPalMobile() {
//        PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction: Constant.PayPalMobile.productionKey,
//                                                               PayPalEnvironmentSandbox: Constant.PayPalMobile.sandboxKey])
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
        } else if let viralcamURL = URL(string: "viralCam://com.simform.viralcam"),
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
                #if VIRALCAMAPP || PIC2ARTAPP || TIMESPEEDAPP
                rootViewController = R.storyboard.loginViewController.loginNavigation()
                #endif
            }
            UIApplication.shared.delegate!.window!!.rootViewController = rootViewController
            return true
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
        return false
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return TiktokShare.shared.application(application, open: url, sourceApplication: nil, annotation: [:])
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        Defaults.shared.postViralCamModel = nil
        IAPManager.shared.stopObserving()
    }
}
