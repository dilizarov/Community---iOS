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
    
//    var refreshControl: UIRefreshControl!
    var communityTitle: String?
    //var posts = [Post]()
    
    var tableViewController: CommunityTableViewController!
    
    var navBar: UINavigationBar!
    var leftButtonOptions = [String : UIBarButtonItem]()
    
    // Used to mitigate iOS bug with dynamic UITablieViewCell heights and jumpiness
    // when scrolling up
//    var cachedHeights = [Int: CGFloat]()
    
  //  @IBOutlet var communityFeed: UITableView!
    
    // Infinite Scroll Solution
    var infiniteScrollBufferCount: Int!
    var reachedEndOfList: Bool!
    var reachedEndofCallback: Bool!
    var isLoading: Bool!
    var problemsLoading: Bool!
    var preloadPostCount: Int!
    var currentPage: Int!
    var infiniteScrollTimeBuffer: String!
    var lastTimeLoading: NSDate!
    
    // Used to mitigate background fetching first time around
    var fetchedOnce = false
    
    var initiallyLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInfiniteScrollVals()
        setupNavBar()
        verifyJoinOrSettings()
//        setupRefreshControl()
        //setupWritePostButton()
        
        //communityFeed.rowHeight = UITableViewAutomaticDimension
        
      //  requestPostsAndPopulateFeed(false, page: nil, completionHandler: nil, changingCommunities: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //        if (!initiallyLoaded) {
        //            requestPostsAndPopulateFeed(false, page: nil, completionHandler: nil, changingCommunities: false)
        //            initiallyLoaded = true
        //        }
    }
    
    func setInfiniteScrollVals() {
        // Begin fetching 3 posts before the bottom
        infiniteScrollBufferCount = 3
        reachedEndOfList = false
        reachedEndofCallback = false
        isLoading = false
        problemsLoading = false
        preloadPostCount = 0
        //We initialize currentPage to 2 because we load page 1.
        //Infinite scrolling takes over for pages 2+
        currentPage = 2
        infiniteScrollTimeBuffer = ""
    }
    
    func setupNavBar() {
        navBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.bounds.width, 64))
        
        navBar.barTintColor = UIColor.whiteColor()
        navBar.translucent = false
        
        navBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.darkGrayColor() ]
        
        self.view.addSubview(navBar)
        
        var settingsButton = UIBarButtonItem(image: UIImage(named: "Settings"), style: .Plain, target: self, action: Selector("goToSettings"))
        settingsButton.tintColor = UIColor(hexString: "056A85")
        
        var joinButton = UIBarButtonItem(title: "Join", style: .Plain, target: self, action: Selector("processJoin"))
        joinButton.tintColor = UIColor(hexString: "056A85")
        
        var loadIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 22, 22))
        loadIndicator.stopAnimating()
        loadIndicator.hidesWhenStopped = true
        loadIndicator.activityIndicatorViewStyle = .Gray
        
        var loadButton = UIBarButtonItem(customView: loadIndicator)
        
        leftButtonOptions["settings"] = settingsButton
        leftButtonOptions["join"] = joinButton
        leftButtonOptions["load"] = loadButton
        
        var searchButton = UIBarButtonItem(image: UIImage(named: "Search"), style: .Plain, target: self, action: Selector("goSearch"))
        searchButton.tintColor = UIColor(hexString: "056A85")
        
        var navigationItem = UINavigationItem()
        navigationItem.rightBarButtonItem = searchButton
        
        loadIndicator.startAnimating()
        navigationItem.leftBarButtonItem = loadButton
        
        navigationItem.title = communityTitle
        
        navBar.pushNavigationItem(navigationItem, animated: false)
    }
    
    func verifyJoinOrSettings() {
        
        var userInfo = NSUserDefaults.standardUserDefaults()
        
        var params = [String: AnyObject]()
        params["user_id"] = userInfo.objectForKey("user_id") as! String
        params["auth_token"] = userInfo.objectForKey("auth_token") as! String
        params["community"] = communityTitle!
        
        Alamofire.request(.GET, "https://infinite-lake-4056.herokuapp.com/api/v1/communities/show.json", parameters: params)
            .responseJSON { request, response, jsonData, errors in
                if response?.statusCode == 200 {
                    self.navBar.topItem!.leftBarButtonItem = self.leftButtonOptions["settings"]
                    
                    let json = JSON(jsonData!)["community"]
                    let realm = Realm()
                    
                    var community = JoinedCommunity()
                    community.name = json["name"].stringValue
                    
                    if let username = json["user"]["username"].string {
                        community.username = username
                    }
                    
                    if let avatar_url = json["user"]["avatar_url"].string {
                        community.avatar_url = avatar_url
                    }
                    
                    realm.write {
                        realm.add(community, update: true)
                    }
                } else {
                    self.navBar.topItem!.leftBarButtonItem = self.leftButtonOptions["join"]
                }
                
                (self.leftButtonOptions["load"]!.customView as! UIActivityIndicatorView).stopAnimating()
            }
        
    }
    
    func goSearch() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func processJoin() {
        (leftButtonOptions["load"]!.customView as! UIActivityIndicatorView).startAnimating()
        navBar.topItem!.leftBarButtonItem = leftButtonOptions["load"]
        
        var userInfo = NSUserDefaults.standardUserDefaults()
        
        var params = [String: AnyObject]()
        params["user_id"] = userInfo.objectForKey("user_id") as! String
        params["auth_token"] = userInfo.objectForKey("auth_token") as! String
        params["community"] = communityTitle!
        
        Alamofire.request(.POST, "https://infinite-lake-4056.herokuapp.com/api/v1/communities.json", parameters: params)
            .responseJSON { request, response, jsonData, errors in
                
                if (response?.statusCode > 299 || errors != nil) {
                    if (response?.statusCode > 299) {
                        //something went wrong
                    } else {
                        //localizedDescription
                    }
                    
                    self.navBar.topItem!.leftBarButtonItem = self.leftButtonOptions["join"]
                } else {
                    self.navBar.topItem!.leftBarButtonItem = self.leftButtonOptions["settings"]
                    
                    let realm = Realm()
                    var community = JoinedCommunity()
                    community.name = self.communityTitle!
                    
                    realm.write {
                        realm.add(community, update: true)
                    }
                    
                    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    var leftVC = appDelegate.drawerController!.leftDrawerViewController as? ProfileViewController
                    
                    if let profileVC = leftVC {
                        profileVC.tableViewController.triggerRealmReload = true
                    }
                }
                
                (self.leftButtonOptions["load"]!.customView as! UIActivityIndicatorView).stopAnimating()
        }
    }
    
    func writePost() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var writePostVC = storyboard.instantiateViewControllerWithIdentifier("WritePostViewController") as! WritePostViewController
        
        writePostVC.communityName = communityTitle
        writePostVC.delegate = self.tableViewController
        
        self.presentViewController(writePostVC, animated: true, completion: nil)
    }
    
    func goToSettings() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var settingsVC = storyboard.instantiateViewControllerWithIdentifier("CommunitySettingsViewController") as! CommunitySettingsViewController
        
        settingsVC.communityName = communityTitle
        
        self.presentViewController(settingsVC, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "communityEmbedTVC" {
            tableViewController = segue.destinationViewController as! CommunityTableViewController
            
            tableViewController.communityTitle = self.communityTitle
            tableViewController.delegate = self
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        println("community disappeared")
    }
    
    deinit {
        println("community deinit")
    }
}