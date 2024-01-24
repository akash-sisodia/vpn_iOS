//
//  AppDelegate.swift
//  CallApp
//
//  Created by Akash Singh Sisodia on 19/06/20.
//  Copyright © 2020 Akash Singh Sisodia. All rights reserved.
//

import UIKit
import Firebase

 
@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var networkReachable = false
    //private let reachability = try! Reachability()
    
    let mainStoryboard: UIStoryboard = {
        return UIStoryboard(name: "Main", bundle: nil)
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIDevice.current.isBatteryMonitoringEnabled = true
FirebaseApp.configure()
        return true
    }
 
    func initialConfiguration() {
        /*
         // Setup Firebase
         FirebaseApp.configure()
         
         // Register device for remote notifications.
         registerForPushNotifications()
         
         // Enable Reachability
         RechabilityHelper.setup()
         
         // Configure IQKeyboardManager
         setupKeyboard()
         
         // Check User Session
         checkUserSession()
         */
    }
    
    /// setting up IQKeyboardManager
    func setupKeyboard() {
        /*
         IQKeyboardManager.shared.enable = true
         IQKeyboardManager.shared.shouldResignOnTouchOutside = true
         IQKeyboardManager.shared.shouldPlayInputClicks = true
         IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
         IQKeyboardManager.shared.enableAutoToolbar = true
         */
    }
    
    /// Validating user's login session
    func checkUserSession() {
        /*
         if LoggedInUser.shared.checkLastUserSession() {
         setupRootViewController()
         } else {
         setUpInitialViewController()
         }
         */
    }
}
