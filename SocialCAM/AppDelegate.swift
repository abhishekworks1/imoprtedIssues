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
import Fabric
import Crashlytics
import GooglePlaces
import GoogleMaps
import FBSDKCoreKit
import TikTokOpenPlatformSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        configureIQKeyboardManager()
        InternetConnectionAlert.shared.enable = true
        var config = InternetConnectionAlert.Configuration()
        config.kBG_COLOR = ApplicationSettings.appPrimaryColor
        InternetConnectionAlert.shared.config = config
        
        InternetConnectionAlert.shared.internetConnectionHandler = { reachability in
            if reachability.connection != .none {
                StoryDataManager.shared.startUpload()
            }
        }
        
        configureAppTheme()
        
        ColorCubeStorage.loadToDefault()
        FirebaseApp.configure()
        #if DEBUG
        Fabric.sharedSDK().debug = true
        #else
        Fabric.sharedSDK().debug = false
        #endif
        
        configureGoogleService()
        
        var rootViewController: UIViewController? = R.storyboard.loginViewController.loginNavigation()
        if let user = Defaults.shared.currentUser,
            let _ = Defaults.shared.sessionToken,
            let channelId = user.channelId,
            channelId.count > 0 {
            rootViewController = R.storyboard.storyCameraViewController.storyCameraNavigation()
            InternetConnectionAlert.shared.internetConnectionHandler = { reachability in
                if reachability.connection != .none {
                    StoryDataManager.shared.startUpload()
                }
            }
        }
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        TiktokShare.shared.setupTiktok(application, didFinishLaunchingWithOptions: launchOptions)
        
        UIApplication.shared.delegate!.window!!.rootViewController = rootViewController
        
        return true
    }
    
    func configureAppTheme() {
        UISwitch.appearance().onTintColor = ApplicationSettings.appPrimaryColor
        UIProgressView.appearance().tintColor = ApplicationSettings.appPrimaryColor
        UITabBar.appearance().tintColor = ApplicationSettings.appPrimaryColor
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ApplicationSettings.appPrimaryColor], for: .selected)
        UISegmentedControl.appearance().tintColor = ApplicationSettings.appPrimaryColor
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
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if TiktokOpenPlatformApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: UIApplication.OpenURLOptionsKey.sourceApplication.rawValue, annotation: UIApplication.OpenURLOptionsKey.annotation) {
            return true
        }
        return false
    }
   
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if TiktokOpenPlatformApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        } else if ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        return false
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEvents.activateApp()
    }
    
}
