//
//  CommunityViewController.swift
//  Community
//
//  Created by David Ilizarov on 8/18/15.
//  Copyright (c) 2015 David Ilizarov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast
import HexColors
import RealmSwift

class CommunityViewController: UIViewController, CommunityTableDelegate {
    
    var communityTitle: String?
    var communityKey: String?
    // Handles propogation for notifications.
    var postId: String?
    
    var delegate: AvatarChangedAlertDelegate?
    
    var observingCommunitySelected: Bool = false
    var observingAvatarChanged: Bool = false
    
    var tableViewController: CommunityTableViewController!
    
    var navBar: UINavigationBar!
    var leftButtonOptions = [String : UIBarButtonItem]()
    
    // Used to mitigate background fetching first time around
    var fetchedOnce = false
    
    var initiallyLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        
        if #available(iOS 9, *) {
            makeCommunitySearchable()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
     
        // This handles if community was selected in side view
        if (!observingCommunitySelected) {
            observingCommunitySelected = true
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("communitySelected:"), name: "communitySelected", object: nil)
        }

        if (!observingAvatarChanged) {
            observingAvatarChanged = true
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("avatarChanged"), name: "avatarChanged", object: nil)
        }

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        potentiallyHeadToReplies()
    }
    
    @available(iOS 9, *)
    func makeCommunitySearchable() {
        if let key = communityKey {
            let activity = NSUserActivity(activityType: "get.community.Community.searchable")
            activity.title = "&" + key
            activity.keywords = Set(communityTitle!.componentsSeparatedByString(" "))
            // Ultimately, the reason I do this is because I don't know enough about Handoff,
            // its inner-workings and don't know if the app is prepped for that.
            activity.eligibleForHandoff = false
            activity.eligibleForSearch = true
            activity.eligibleForPublicIndexing = true
            userActivity = activity
            userActivity!.becomeCurrent()
        }
    }
    
    func communitySelected(notification: NSNotification) {
        if let info = notification.userInfo as? Dictionary<String, String> {
            if let community = info["community"] {
                
                communityTitle = community
                communityKey = info["normalized_name"]
                
                navBar.topItem?.title = communityTitle
                
                self.leftButtonOptions["join"]!.enabled = false
                navBar.topItem?.leftBarButtonItem = self.leftButtonOptions["join"]
                
                tableViewController.communityTitle = self.communityTitle
                
                tableViewController.emptyOrErrorDescription = nil
                tableViewController.posts = []
                tableViewController.tableView.reloadData()
                tableViewController.verifiedMembership = false
                tableViewController.setInfiniteScrollVars()
                tableViewController.requestPostsAndPopulateFeed(false, page: nil)
                
                if #available(iOS 9, *) {
                    makeCommunitySearchable()
                }
                
                (UIApplication.sharedApplication().delegate as! AppDelegate).drawerController?.closeDrawerAnimated(true, completion: nil)
                
                postId = info["postId"]
                potentiallyHeadToReplies()
            }
        }
    }
    
    func avatarChanged() {
        if let confirmedDelegate = delegate {
            confirmedDelegate.avatarChanged()
        }
    }
    
    func potentiallyHeadToReplies() {
        if postId != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let repliesVC = storyboard.instantiateViewControllerWithIdentifier("RepliesViewController") as! RepliesViewController
            
            repliesVC.postId = postId
            
            postId = nil
            self.presentViewController(repliesVC, animated: true, completion: nil)
            
        }
    }
    
    func setupNavBar() {
        navBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.bounds.width, 64))
        
        navBar.barTintColor = UIColor.whiteColor()
        navBar.translucent = false
        
        navBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.darkGrayColor() ]
        
        self.view.addSubview(navBar)
        
        let settingsButton = UIBarButtonItem(image: UIImage(named: "Settings"), style: .Plain, target: self, action: Selector("goToSettings"))
        settingsButton.tintColor = UIColor(hexString: "056A85")
        
        let joinButton = UIBarButtonItem(title: "Join", style: .Plain, target: self, action: Selector("processJoin"))
        joinButton.tintColor = UIColor(hexString: "056A85")
        joinButton.enabled = false
        
        let loadIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 22, 22))
        loadIndicator.stopAnimating()
        loadIndicator.hidesWhenStopped = true
        loadIndicator.activityIndicatorViewStyle = .Gray
        
        let loadButton = UIBarButtonItem(customView: loadIndicator)
        
        leftButtonOptions["settings"] = settingsButton
        leftButtonOptions["join"] = joinButton
        leftButtonOptions["load"] = loadButton
        
        let searchButton = UIBarButtonItem(image: UIImage(named: "Search"), style: .Plain, target: self, action: Selector("goSearch"))
        searchButton.tintColor = UIColor(hexString: "056A85")
        
        let navigationItem = UINavigationItem()
        navigationItem.rightBarButtonItem = searchButton
        navigationItem.leftBarButtonItem = joinButton
        
        navigationItem.title = communityTitle
        
        navBar.pushNavigationItem(navigationItem, animated: false)
    }
    
    func performBackgroundFetch(asyncGroup: dispatch_group_t!) {
        tableViewController.performBackgroundFetch(asyncGroup)
    }
    
    func declareRelationship(relationship: JSON) {
        if (relationship != nil) {
            let realm = try! Realm()
            
            let community = JoinedCommunity()
            community.name = relationship["name"].stringValue
            community.normalizedName = relationship["normalized_name"].stringValue
            self.communityKey = relationship["normalized_name"].stringValue
            
            if let username = relationship["user"]["username"].string {
                community.username = username
            }
            
            if let avatar_url = relationship["user"]["avatar_url"].string {
                community.avatar_url = avatar_url
            }
            
            try! realm.write {
                realm.add(community, update: true)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.navBar.topItem!.leftBarButtonItem = self.leftButtonOptions["settings"]
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.navBar.topItem!.leftBarButtonItem = self.leftButtonOptions["join"]
                self.leftButtonOptions["join"]!.enabled = true
            })
        }
    }
    
    func goSearch() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func spreadToast(string: String) {
        self.view.makeToast(string, duration: NSTimeInterval(3), position: CSToastPositionCenter)
    }
    
    func processJoin() {
        (leftButtonOptions["load"]!.customView as! UIActivityIndicatorView).startAnimating()
        navBar.topItem!.leftBarButtonItem = leftButtonOptions["load"]
        
        Alamofire.request(Router.JoinCommunity(community: communityTitle!.strip()))
            .responseJSON { request, response, result in
                
                if (response?.statusCode > 299) {
                    self.view.makeToast("Something went wrong :(", duration: NSTimeInterval(3), position: CSToastPositionCenter)
                } else if ((response == nil || response?.statusCode > 299) && result.error != nil) {
                    if (response?.statusCode > 299) {
                        self.view.makeToast("Something went wrong :(", duration: NSTimeInterval(3), position: CSToastPositionCenter)
                    } else {
                        self.view.makeToast((result.error as? NSError)!.localizedDescription, duration: NSTimeInterval(3), position: CSToastPositionCenter)
                    }
                    
                    self.navBar.topItem!.leftBarButtonItem = self.leftButtonOptions["join"]
                } else {
                    self.navBar.topItem!.leftBarButtonItem = self.leftButtonOptions["settings"]
                    
                    var json = JSON(result.value!)["community"]
                    
                    let realm = try! Realm()
                    let community = JoinedCommunity()
                    community.name = json["name"].stringValue
                    community.normalizedName = json["normalized_name"].stringValue
                    self.communityKey = json["normalized_name"].stringValue
                    
                    try! realm.write {
                        realm.add(community, update: true)
                    }
                    
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    let leftVC = appDelegate.drawerController!.leftDrawerViewController as? ProfileViewController
                    
                    if let profileVC = leftVC {
                        profileVC.tableViewController.triggerRealmReload = true
                    }
                }
                
                (self.leftButtonOptions["load"]!.customView as! UIActivityIndicatorView).stopAnimating()
        }
    }
    
    func writePost() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let writePostVC = storyboard.instantiateViewControllerWithIdentifier("WritePostViewController") as! WritePostViewController
        
        writePostVC.communityName = communityTitle
        writePostVC.communityKey = self.communityKey!
        writePostVC.delegate = self.tableViewController
        
        self.presentViewController(writePostVC, animated: true, completion: nil)
    }
    
    func goToSettings() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let settingsVC = storyboard.instantiateViewControllerWithIdentifier("CommunitySettingsViewController") as! CommunitySettingsViewController
        
        settingsVC.communityName = self.communityTitle
        settingsVC.communityKey = self.communityKey
        
        self.presentViewController(settingsVC, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "communityEmbedTVC" {
            tableViewController = segue.destinationViewController as! CommunityTableViewController
            
            tableViewController.communityTitle = self.communityTitle
            tableViewController.delegate = self
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "communitySelected", object: nil)
        observingCommunitySelected = false
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "avatarChanged", object: nil)
        observingAvatarChanged = false
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "communitySelected", object: nil)
        observingCommunitySelected = false
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "avatarChanged", object: nil)
        observingAvatarChanged = false
    }

}