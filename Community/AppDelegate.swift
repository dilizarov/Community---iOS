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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var drawerController: MMDrawerController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        
        configureRealm()
        configureLaunchState()
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        return true
    }

    func configureRealm() {
        
        var optionalUserId = Session.get(.AccountUserId)
        
        var documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        
        var customRealmPath: String
        
        if let userId = optionalUserId {
            customRealmPath = documentsDirectory.stringByAppendingPathComponent("\(userId).realm")
        } else {
            customRealmPath = documentsDirectory.stringByAppendingPathComponent("logged_out.realm")
        }
        
        var config = Realm.Configuration()
        config.path = customRealmPath
        config.schemaVersion = 1
        config.migrationBlock = {
            migration, oldSchemaVersion in
            if (oldSchemaVersion < 1) {                
            }
        }
        
        Realm.Configuration.defaultConfiguration = config
        
        let realm = Realm()
    }
    
    func configureLaunchState() {
        if let has_opened_app_before = Session.get(.MetaAuthToken) {
            configureUsualLaunch(nil)
        } else {
            configureWelcomeLaunch()
        }
    }
    
    func configureUsualLaunch(community: String?) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let searchViewController = mainStoryboard.instantiateViewControllerWithIdentifier("SearchViewController") as! SearchViewController
        
        searchViewController.headingToCommunity = community
        
        let navigationController = UINavigationController(rootViewController: searchViewController)
        navigationController.navigationBarHidden = true
        
        var leftViewIdentifier: String
        
        //TODO
        if (Session.get(.AuthToken) != nil) {
            leftViewIdentifier = "ProfileViewController"
        } else {
            leftViewIdentifier = "LoggedOutProfileViewController"
        }
        
        let leftViewController = mainStoryboard.instantiateViewControllerWithIdentifier(leftViewIdentifier) as! UIViewController
        
        drawerController = MMDrawerController(centerViewController: navigationController, leftDrawerViewController: leftViewController)
        
        drawerController?.setMaximumLeftDrawerWidth(UIScreen.mainScreen().bounds.size.width, animated: true, completion: nil)
        drawerController?.openDrawerGestureModeMask = .All
        drawerController?.closeDrawerGestureModeMask = .All
        drawerController?.centerHiddenInteractionMode = .None
        drawerController?.showsShadow = true
        drawerController?.setDrawerVisualStateBlock(MMDrawerVisualState.parallaxVisualStateBlockWithParallaxFactor(3)!)
        
        
        // This forces the side to layout itself properly.
        drawerController?.bouncePreviewForDrawerSide(.Left, distance: 10, completion: nil)
        
        self.window?.rootViewController = drawerController
        self.window?.makeKeyAndVisible()
    }
    
    func configureWelcomeLaunch() {
        let welcomeStoryboard = UIStoryboard(name: "Welcome", bundle: nil)
        
        let rootVC = welcomeStoryboard.instantiateInitialViewController() as! UIViewController
        
        self.window?.rootViewController = rootVC
        self.window?.makeKeyAndVisible()
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        if Session.getAuthToken() == nil {
            return completionHandler(.NoData)
        }
        
        if let drawer = drawerController {
            let profileVC = drawer.leftDrawerViewController as! ProfileViewController
            let navigationVC = drawer.centerViewController as! UINavigationController
            
            var backgroundGroup = dispatch_group_create()
            
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

