//
//  AppDelegate.swift
//  Community
//
//  Created by David Ilizarov on 8/17/15.
//  Copyright (c) 2015 David Ilizarov. All rights reserved.
//

import UIKit
import MMDrawerController
import RealmSwift
import IQKeyboardManagerSwift
import Alamofire
import BSForegroundNotification

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, BSForegroundNotificationDelegate {

    var window: UIWindow?
    var drawerController: MMDrawerController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        
        IQKeyboardManager.sharedManager().disableInViewControllerClass(RepliesViewController)
        IQKeyboardManager.sharedManager().disableInViewControllerClass(RepliesTableViewController)
        
        var userInfo: Dictionary<NSObject, AnyObject>?
        
        if let options = launchOptions {
            if options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil {
                application.applicationIconBadgeNumber -= 1
                userInfo = options[UIApplicationLaunchOptionsRemoteNotificationKey] as? Dictionary<NSObject, AnyObject>
            }
        }
        
        configureLaunchState(userInfo)
        
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        return true
    }

    func configureRealm() {
        
        let optionalUserId = Session.get(.AccountUserId)
        
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        
        var customRealmPath: String
        
        if let userId = optionalUserId {
            customRealmPath = documentsDirectory.stringByAppendingPathComponent("\(userId).realm")
        } else {
            customRealmPath = documentsDirectory.stringByAppendingPathComponent("logged_out.realm")
        }
        
        var config = Realm.Configuration()
        config.path = customRealmPath
        config.schemaVersion = 3
        config.migrationBlock = {
            migration, oldSchemaVersion in
            if (oldSchemaVersion < 3) {
                migration.enumerate(JoinedCommunity.className()) { oldObject, newObject in
                    migration.delete(newObject!)
                }
            }
        }
        
        Realm.Configuration.defaultConfiguration = config
        
        let _ = try! Realm()
    }
    
    func configureLaunchState(userInfo: Dictionary<NSObject, AnyObject>?) {
        if let _ = Session.get(.MetaAuthToken) {
            configureUsualLaunch(nil, userInfo: userInfo)
        } else {
            configureWelcomeLaunch()
        }
    }
    
    func configureUsualLaunch(community: String?, userInfo: Dictionary<NSObject, AnyObject>? = nil) {
        configureRealm()
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let searchViewController = mainStoryboard.instantiateViewControllerWithIdentifier("SearchViewController") as! SearchViewController
        
        searchViewController.headingToCommunity = community
        
        if userInfo != nil {
            if userInfo!["community"] != nil && userInfo!["post_id"] != nil {
                searchViewController.headingToCommunity = userInfo!["community"] as? String
                searchViewController.postId = userInfo!["post_id"] as? String
            }
        }
        
        let navigationController = UINavigationController(rootViewController: searchViewController)
        navigationController.navigationBarHidden = true
        
        let leftViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        
        leftViewController.badge.badgeValue = UIApplication.sharedApplication().applicationIconBadgeNumber
        
        drawerController = MMDrawerController(centerViewController: navigationController, leftDrawerViewController: leftViewController)
        
        drawerController?.setMaximumLeftDrawerWidth(UIScreen.mainScreen().bounds.size.width, animated: true, completion: nil)
        drawerController?.openDrawerGestureModeMask = .All
        drawerController?.closeDrawerGestureModeMask = .All
        drawerController?.centerHiddenInteractionMode = .None
        drawerController?.showsShadow = true
        drawerController?.setDrawerVisualStateBlock(MMDrawerVisualState.parallaxVisualStateBlockWithParallaxFactor(3)!)
        
        // This forces the side to layout itself properly. Pretty sure this is a library bug.
        drawerController?.bouncePreviewForDrawerSide(.Left, distance: 10, completion: nil)
        
        self.window?.rootViewController = drawerController
        self.window?.makeKeyAndVisible()
        
        
        
        let application = UIApplication.sharedApplication()
        let pushSettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        
        application.registerUserNotificationSettings(pushSettings)
        application.registerForRemoteNotifications()
    }
    
    func configureWelcomeLaunch() {
        let welcomeStoryboard = UIStoryboard(name: "Welcome", bundle: nil)
        
        let rootVC = welcomeStoryboard.instantiateInitialViewController() as UIViewController!
        
        self.window?.rootViewController = rootVC
        self.window?.makeKeyAndVisible()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Would anyone like to explain to me why Apple, a company known for simplicity, decides
        // that we need to do all this work instead of them just giving us an NSString to work with?
        
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for var i = 0; i < deviceToken.length; i++ {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        Session.set(tokenString, key: .DeviceToken)
        Alamofire.request(Router.SendDeviceToken)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        let state = application.applicationState
        
        if state == .Active {
            if let controller = drawerController {
                let currentBadgeNumber = application.applicationIconBadgeNumber
                application.applicationIconBadgeNumber = currentBadgeNumber + 1
                
                (controller.leftDrawerViewController as! ProfileViewController).badge.badgeValue = currentBadgeNumber + 1
            
                let notification = BSForegroundNotification(userInfo: userInfo)
                notification.delegate = self
                notification.presentNotification()
            }
        } else if state == .Inactive {
            application.applicationIconBadgeNumber -= 1
            configureLaunchState(userInfo)
        }
    }
    
    func foregroundRemoteNotificationWasTouched(userInfo: [NSObject : AnyObject]) {
        UIApplication.sharedApplication().applicationIconBadgeNumber -= 1
        configureLaunchState(userInfo)
    }

    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        if Session.getAuthToken() == nil {
            return completionHandler(.NoData)
        }
        
        if let drawer = drawerController {
            let profileVC = drawer.leftDrawerViewController as! ProfileViewController
            let navigationVC = drawer.centerViewController as! UINavigationController
            
            let backgroundGroup = dispatch_group_create()
            
            profileVC.performBackgroundFetch(backgroundGroup)
            
            if let communityVC = navigationVC.visibleViewController as? CommunityViewController {
                communityVC.performBackgroundFetch(backgroundGroup)
            } else if let repliesVC = navigationVC.visibleViewController as? RepliesViewController {
                repliesVC.performBackgroundFetch(backgroundGroup)
            }
            
            dispatch_group_notify(backgroundGroup, dispatch_get_main_queue(), {
                completionHandler(.NewData)
            })
        } else {
            completionHandler(.NoData)
        }
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        if userActivity.activityType == "get.community.Community.searchable" {
            // We need to ensure user has already gone through welcome phase because search is public.
            if let _ = Session.get(.MetaAuthToken) {
                if let communityName = userActivity.title {
                    
                    var community = communityName
                    
                    if communityName.hasPrefix("&") {
                        community = communityName.substringFromIndex(communityName.startIndex.advancedBy(1))
                    }
                    
                    configureUsualLaunch(community)
                }
            }
        } else if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let _ = Session.get(.MetaAuthToken) {
                let webpageURL = userActivity.webpageURL!
                
                if let path = webpageURL.path {
                    if path == "" || path == "/" || path == "/&" {
                        configureUsualLaunch(nil)
                    } else if path.hasPrefix("/&") && NSString(string: path).length > 2 {
                        let community = path.substringFromIndex(path.startIndex.advancedBy(2))
                        configureUsualLaunch(community)
                    } else {
                        UIApplication.sharedApplication().openURL(webpageURL)
                    }
                } else {
                    UIApplication.sharedApplication().openURL(webpageURL)
                }
            }
        }
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

