//
//  Constant.swift
//  SocialCAM
//
//  Created by Viraj Patel on 23/12/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import AVKit

public struct Constant {
    
    struct Value {
        static let maxChannelName = 30
        static let minChannelName = 12
        static let channelName = 11
    }
    
    struct AWS {
        // Client Bucket
        static let poolID = "us-west-2:4918c1f8-d173-4668-8891-d6892a147259"
        static let baseUrl = "https://s3-us-west-2.amazonaws.com/"
        static let NAME = "spinach-cafe"
        static let FOLDER = "main-image"
        static let URL = "http://\(Constant.AWS.NAME).s3.amazonaws.com/"
    }
    
    struct URLs {
        static let cabbage = "https://staging.cabbage.cafe/api/v1/"
        static let faq = "https://www.google.com"
        static let twitter = "https://api.twitter.com/1.1/"
        static let youtube = "https://www.googleapis.com/youtube/v3/"
        #if SOCIALCAMAPP
        static let websiteURL = "https://socialcam.iicc.online"
        #elseif VIRALCAMAPP || VIRALCAMLITEAPP
        static let websiteURL = "https://viralcam.iicc.online"
        #elseif SOCCERCAMAPP
        static let websiteURL = "https://soccercam.iicc.online"
        #elseif FUTBOLCAMAPP
        static let websiteURL = "https://futbolcam.iicc.online"
        #elseif PIC2ARTAPP
        static let websiteURL = "https://pic2art.iicc.online"
        #elseif BOOMICAMAPP
        static let websiteURL = "https://boomicam.iicc.online"
        #elseif TIMESPEEDAPP
        static let websiteURL = "https://timespeed.iicc.online"
        #elseif FASTCAMAPP || FASTCAMLITEAPP
        static let websiteURL = "https://fastcam.iicc.online"
        #elseif QUICKCAMLITEAPP || QUICKAPP
        static let websiteURL = "https://quickcam.iicc.online"
        #elseif SNAPCAMAPP || SNAPCAMLITEAPP
        static let websiteURL = "https://snapcam.iicc.online"
        #elseif SPEEDCAMAPP || SPEEDCAMLITEAPP
        static let websiteURL = "https://speedcam.iicc.online"
        #else
        static let websiteURL = "https://viralcam.iicc.online"
        #endif
        static let socialCamWebsiteURL = "https://socialcam.iicc.online"
        static let pic2ArtWebsiteURL = "https://pic2art.iicc.online"
        static let soccercamWebsiteURL = "http://soccercam.iicc.online"
        static let futbolWebsiteURL = "http://futbolcam.iicc.online"
        static let applicationSurveyURL = "https://docs.google.com/forms/d/e/1FAIpQLSfjHUxhARTecUA39brgD0XunJdnOgJ9QUhfnH-k-yrAk-nUnA/viewform"
    }
    
    struct Application {
        #if VIRALCAMAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "ViralCam"
        static let simformIdentifier: String = "com.simform.viralcam"
        static let proModeCode: String = "viralcam2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/sk1foNLO")
        static let splashBG = UIImage(named: "viralcamSplashBG")!
        static let appIcon = UIImage(named: "viralCamSplashLogo")!
        #elseif SOCCERCAMAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "SoccerCam"
        static let simformIdentifier: String = "com.simform.SoccerCam"
        static let proModeCode: String = "soccercam2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/1dRtt5SV")
        static let splashBG = UIImage(named: "footballCamSplashBG")!
        static let appIcon = UIImage(named: "soccerCamSplashBG")!
        #elseif FUTBOLCAMAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "FutbolCam"
        static let simformIdentifier: String = "com.simform.SoccerCam"
        static let proModeCode: String = "futbolcam2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/1dRtt5SV")
        static let splashBG = UIImage(named: "footballCamSplashBG")!
        static let appIcon = UIImage(named: "futbolCamSplashLogo")!
        #elseif QUICKCAMAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "QuickCam"
        static let simformIdentifier: String = "com.simform.QuickCam"
        static let proModeCode: String = "quickcam2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/1dRtt5SV")
        static let splashBG = UIImage(named: "quickCamSplashBG")!
        static let appIcon = UIImage(named: "quickCamSplashLogo")!
        #elseif SNAPCAMAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "SnapCam"
        static let simformIdentifier: String = "com.simform.SnapCam"
        static let proModeCode: String = "snapcam2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/MTVSBnbC")
        static let splashBG = UIImage(named: "snapCamSplash")!
        static let appIcon = UIImage(named: "snapCamSplashIcon")!
        #elseif SPEEDCAMAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "SpeedCam"
        static let simformIdentifier: String = "com.simform.SpeedCam"
        static let proModeCode: String = "speedcam2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/MTVSBnbC")
        static let splashBG = UIImage(named: "speedCamSplash")!
        static let appIcon = UIImage(named: "speedCamSplashIcon")!
        #elseif PIC2ARTAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "PIC2ART"
        static let simformIdentifier: String = "com.Pic2Art.app"
        static let proModeCode: String = "pic2art2020"
        static let pic2artProModeCode: String = "pic2art2020pro!!"
        static let publicLink = URL(string: "https://testflight.apple.com/join/hshtsh9O")
        static let splashBG = UIImage(named: "Pic2ArtSplash")!
        static let appIcon = UIImage(named: "Pic2ArtSplashIcon")!
        #elseif BOOMICAMAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "BOOMICAM"
        static let simformIdentifier: String = "com.simform.BoomiCam"
        static let proModeCode: String = "boomicam2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/kYCCo1AW")
        static let splashBG = UIImage(named: "boomiCamSplashBG")!
        static let appIcon = UIImage(named: "boomiCamSplashLogo")!
        #elseif TIMESPEEDAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "TIMESPEED"
        static let simformIdentifier: String = "com.simform.timespeed"
        static let proModeCode: String = "timespeed2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/MhCuGbHp")
        static let splashBG = UIImage(named: "timeSpeedSplashBG")!
        static let appIcon = UIImage(named: "timeSpeedSplashLogo")!
        #elseif FASTCAMAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "ViralCam"
        static let simformIdentifier: String = "com.simform.fastCam"
        static let proModeCode: String = "fastcam2020"
        static let publicLink = URL(string: "")
        static let splashBG = UIImage(named: "footballCamSplashBG")!
        static let appIcon = UIImage(named: "ssuTimeSpeed")!
        #elseif SOCIALCAMAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "SocialCam"
        static let simformIdentifier: String = "com.simform.storiCamPro"
        static let proModeCode: String = "socialcam2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/6zE0nt7P")
        static let splashBG = UIImage(named: "socialCamSplashBG")!
        static let appIcon = UIImage(named: "socialCamSplashLogo")!
        #elseif VIRALCAMLITEAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "ViralCam Lite"
        static let simformIdentifier: String = "com.simform.viralcamLite"
        static let proModeCode: String = "viralcamlite2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/6zE0nt7P")
        static let splashBG = UIImage(named: "viralcamSplashBG")!
        static let appIcon = UIImage(named: "viralcamLiteSplash")!
        #elseif FASTCAMLITEAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "FastCam Lite"
        static let simformIdentifier: String = "com.simform.fastCamLite"
        static let proModeCode: String = "fastcamlite2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/6zE0nt7P")
        static let splashBG = UIImage(named: "fastcamLiteSplashBG")!
        static let appIcon = UIImage(named: "fastcamLiteWatermarkLogo")!
        #elseif QUICKCAMLITEAPP || QUICKAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "QuickCam Lite"
        static let simformIdentifier: String = "com.simform.fastCamLite"
        static let proModeCode: String = "quickcamlite2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/6zE0nt7P")
        static let splashBG = UIImage(named: "quickcamLiteLaunchScreenBG")!
        static let appIcon = UIImage(named: "quickcamliteSplashLogo")!
        #elseif SPEEDCAMLITEAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "QuickCam Lite"
        static let simformIdentifier: String = "com.simform.SpeedCamLite"
        static let proModeCode: String = "speedcamlite2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/qlMx1LpF")
        static let splashBG = UIImage(named: "speedCCamSplashBG")!
        static let appIcon = UIImage(named: "speedcamliteSplashLogo")!
        #elseif SNAPCAMLITEAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "SnapCam"
        static let simformIdentifier: String = "com.simform.viralcam"
        static let proModeCode: String = "snapcamlite2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/MTVSBnbC")
        static let splashBG = UIImage(named: "snapCamSplashLite")!
        static let appIcon = UIImage(named: "snapCamSplashIconLite")!
        #elseif RECORDERAPP
        static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Social Screen Recorder"
        static let simformIdentifier: String = "com.socialScreenRecorder.app"
        static let proModeCode: String = "socialscreenrecorder2020"
        static let publicLink = URL(string: "https://testflight.apple.com/join/MTVSBnbC")
        static let splashBG = UIImage(named: "recordeAppSplashBG")!
        static let appIcon = UIImage(named: "recordeAppSplashLogo")!
        #endif
        static let groupIdentifier: String = "group.com.simform.storiCamPro"
        static let recordeGroupIdentifier: String = "group.com.quickCamLite.app"
        static let recorderExtensionIdentifier: String = "com.QuickCamLite.app.QuickCamLiteExtension"
        
        static let pasteboardName: String = "com.Pic2Art.app.CopyFrom"
        static let pasteboardType: String = "com.Pic2Art.app.shareImageData"
        static let pic2artApp: String = "pic2art://com.Pic2Art.app"
        
        static let screenRecodingNotification: String = "ScreenRecodingNotification"
        static let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        static let appBuildNumber: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        
        static let imageIdentifier: String = "www.google.com"
        static let splashImagesFolderName: String = "SplashImages"
        
        static let referralLink = websiteUrl
    }
    
    struct PayPalMobile {
        static let productionKey: String = "AQWNB7gjYT8WwL21H4ZWDvPuK1zgwtO0f0VEQzjKJEGs0aUyNxUEULJzQr9Ni_W-d_igQiVe78CV08-Z"
        static let sandboxKey: String = "AU9oTOQVlZWA0dgy6e8MHb54YiPrMKaYXkl5zyquZ0Tj277I2a1d-uNTmyt0kCs5QkbQSFRwIM_Bz4c3"
    }
    
    struct STKStickersManager {
        static let apiKey: String = "70e36a7b2ca143977e700a83dc03c82e"
        static let userID: String = UUID().uuidString
    }
    
    struct TWTRTwitter {
        #if SOCIALCAMAPP
        static let consumerKey: String = "y39BclEMDbGXVzAaiXv55PGrn"
        static let consumerSecret: String = "o4NcSHnBPaS1jeNW4xjMGg2WTVHm3HUV7WPsCt3b4nRWHa2Kcf"
        #elseif QUICKAPP
        static let consumerKey: String = "9t5rkRUYbvoT5yC0i0jnw9Yln"
        static let consumerSecret: String = "9Zb6sC4pgKDFf1AHQNu6vRhialXF8Q04mBLKlSIg8SFW614slB"
        #else
        static let consumerKey: String = "DJCr4ckk2RhVWckLrw524qcou"
        static let consumerSecret: String = "w20x8fh0Cqgh4iJDYscTMmlzMEalcgouPqHnuRoXb6rdzA7Uzk"
        #endif
    }
    
    struct Instagram {
        #if SOCIALCAMAPP
        static let redirectUrl = "https://storicam-pro.firebaseapp.com/__/auth/handler"
        static let clientId = "2576474045942603"
        static let clientSecret = "65d21fa18fd9e28142f2384e654ee5d3"
        #elseif TIMESPEED
        static let redirectUrl = "https://timespeed-ae42c.firebaseapp.com/__/auth/handler"
        static let clientId = "735709803849520"
        static let clientSecret = "31178bad36620198c990029030b39aa8"
        #elseif PIC2ARTAPP
        static let redirectUrl = "https://pic2art-46a45.firebaseapp.com/__/auth/handler"
        static let clientId = "548440479177267"
        static let clientSecret = "8ce8dcb63d5115475c3167788a4086c7"
        #elseif BOOMICAMAPP
        static let redirectUrl = "https://boomicam-c281f.firebaseapp.com/__/auth/handler"
        static let clientId = "731166734353630"
        static let clientSecret = "18873cdad99dd8dc5f077c52499197cf"
        #elseif FASTCAMAPP
        static let redirectUrl = "https://fastcam-475e3.firebaseapp.com/__/auth/handler"
        static let clientId = "269809577621901"
        static let clientSecret = "249aca0886ce40cb8a816c108aa1a7cd"
        #elseif SOCCERCAMAPP
        static let redirectUrl = "https://soccercam-d15a0.firebaseapp.com/__/auth/handler"
        static let clientId = "361365258591189"
        static let clientSecret = "dd1b754b16bb106217d18e8935b46c8c"
        #elseif FUTBOLCAMAPP
        static let redirectUrl = "https://futbolcam-ddf06.firebaseapp.com/__/auth/handler"
        static let clientId = "1431217550411859"
        static let clientSecret = "39554fc089d5154b5ee77499e549eb65"
        #elseif QUICKCAMAPP || QUICKAPP
        static let redirectUrl = "https://quickcam-fde9d.firebaseapp.com/__/auth/handler"
        static let clientId = "896406730769747"
        static let clientSecret = "47bfa6fac6eef802ab5346f896013a9c"
        #elseif SNAPCAMAPP
        static let redirectUrl = "https://snapcam-1594222751745.firebaseapp.com/__/auth/handler"
        static let clientId = "649595362296150"
        static let clientSecret = "2d0401703d64b6fc1546249cfd1693d9"
        #elseif SPEEDCAMAPP
        static let redirectUrl = "https://speedcam-app.firebaseapp.com/__/auth/handler"
        static let clientId = "657065128572685"
        static let clientSecret = "37fed68dfafabfdd0466300b4919079e"
        #elseif SNAPCAMLITEAPP
        static let redirectUrl = "https://snapcam-lite.firebaseio.com/__/auth/handler"
        static let clientId = "352633045999017"
        static let clientSecret = "0e65fab7a2d2f4457a1896a5baeda993"
        #else
        static let redirectUrl = "https://viralcam-c3c84.firebaseapp.com/__/auth/handler"
        static let clientId = "228138878240656"
        static let clientSecret = "b82cdaa4c3b7755248721767b0318480"
        #endif
        
        static let link = "instagram://library?LocalIdentifier="
        static let authorizeUrl = "https://api.instagram.com/oauth/authorize/"
        
        static let scope = "user_profile,user_media"
        static let basicUrl = "https://api.instagram.com/"
        static let graphUrl = "https://graph.instagram.com/"
        static let baseUrl = "https://www.instagram.com/"
    }
    
    struct AppCenter {
        #if SOCIALCAMAPP
        static let apiKey: String = "b8e186c4-5b4e-45a2-96e5-7904b346ab00"
        #else
        static let apiKey: String = "83e20bd1-613c-481f-86bd-5906c12b95d9"
        #endif
    }
    
    struct GoogleService {
        #if SOCIALCAMAPP
        static let serviceKey: String = "AIzaSyByYKvdBZiTuBogp55PWogJ_NDokbD_8hg"
        static let placeClientKey: String = "AIzaSyBOPskgf7r5ylpQBZv6GMWXcyl1BU5ZTbo"
        #elseif VIRALCAMAPP
        static let serviceKey: String = "AIzaSyBbkguZz4hljlOd-Cs0u5b2GyVUNt7Y1m4"
        static let placeClientKey: String = "AIzaSyBbkguZz4hljlOd-Cs0u5b2GyVUNt7Y1m4"
        #elseif SOCCERCAMAPP
        static let serviceKey: String = "AIzaSyD8EqdyN152SfMvOhB4nUCRk_5aWoP-U1A"
        static let placeClientKey: String = "AIzaSyD8EqdyN152SfMvOhB4nUCRk_5aWoP-U1A"
        #elseif FUTBOLCAMAPP
        static let serviceKey: String = "AIzaSyCF0PBGqnCPVtKFYdYaHv1HYN5X-j4R7U0"
        static let placeClientKey: String = "AIzaSyCF0PBGqnCPVtKFYdYaHv1HYN5X-j4R7U0"
        #elseif QUICKCAMAPP
        static let serviceKey: String = "AIzaSyDb7qoLWUdqXgq2rdEvpxFg95iE8Vh20Pc"
        static let placeClientKey: String = "AIzaSyDb7qoLWUdqXgq2rdEvpxFg95iE8Vh20Pc"
        #elseif QUICKAPP
        static let serviceKey: String = "AIzaSyBAMQXHTLq424mZeMQ02LeUROVP3Cq6Fgo"
        static let placeClientKey: String = "AIzaSyBAMQXHTLq424mZeMQ02LeUROVP3Cq6Fgo"
        #elseif SNAPCAMAPP
        static let serviceKey: String = "AIzaSyD9_sy-klWwfrLTrT4ub-E4fC-iwnzoCG0"
        static let placeClientKey: String = "AIzaSyD9_sy-klWwfrLTrT4ub-E4fC-iwnzoCG0"
        #elseif SPEEDCAMAPP
        static let serviceKey: String = "AIzaSyD9_sy-klWwfrLTrT4ub-E4fC-iwnzoCG0"
        static let placeClientKey: String = "AIzaSyD9_sy-klWwfrLTrT4ub-E4fC-iwnzoCG0"
        #elseif PIC2ARTAPP
        static let serviceKey: String = "AIzaSyAhDvrppyVLvXTAD2fMj1wdBsUgyf1bZpM"
        static let placeClientKey: String = "AIzaSyAhDvrppyVLvXTAD2fMj1wdBsUgyf1bZpM"
        #elseif TIMESPEED
        static let serviceKey: String = "AIzaSyA0GnKcXJS6uFQUm_SASEsCaGgoeJhq2QA"
        static let placeClientKey: String = "AIzaSyBOBVwEf8bMfwCreZS-IBAEqm57A0szOfg"
        #elseif BOOMICAMAPP
        static let serviceKey: String = "AIzaSyBLzWJnjwjKkMwBvoQ0FvXDAXTWd_AmrD4"
        static let placeClientKey: String = "AIzaSyBLzWJnjwjKkMwBvoQ0FvXDAXTWd_AmrD4"
        #elseif FASTCAMAPP
        static let serviceKey: String = "AIzaSyARGjWmJYjfSyK8UAf_dJW4YLqq220hnCM"
        static let placeClientKey: String = "AIzaSyARGjWmJYjfSyK8UAf_dJW4YLqq220hnCM"
        #elseif SNAPCAMLITEAPP
        static let serviceKey: String = "AIzaSyD98DGWLsAPFEn2e0m72ghTKuiMsj2vHII"
        static let placeClientKey: String = "AIzaSyD98DGWLsAPFEn2e0m72ghTKuiMsj2vHII"
        #else
        static let serviceKey: String = "AIzaSyCxjExNbUx2d-DvH8aroRCAhHarFQo1JRA"
        static let placeClientKey: String = "AIzaSyCxjExNbUx2d-DvH8aroRCAhHarFQo1JRA"
        #endif
        static let youtubeScope: String = "https://www.googleapis.com/auth/youtube.force-ssl"
    }
    
    struct OpenWeather {
        static let apiKey: String = "004230507a06e61af439bd7c564e5441"
    }
    
    struct Sentry {
        static let dsn = "https://e7751d4eaf0746dab650503adbb943fa@sentry.io/1548827"
    }
    
    struct BuySubscription {
        static let subscriptionID   = "subscriptionId"
        static let receipt          = "receipt"
        static let password         = "password"
        static let mode             = "mode"
    }
    
    struct IAPError {
        static let notMakePurchase  = "Can not make purchase"
        static let inAppNotFound    = "No In-App Purchases were found"
        static let purchaseFailed   = "purchase failed"
    }
    
    /// IAP product id's
    struct IAPProductIds {
        static let quickCamLiteBasic = "com.QuickCamLite.app.basic"
    }
    
    struct IAPProductServerIds {
        static let quickCamLiteBasic = "1"
    }
    
}
