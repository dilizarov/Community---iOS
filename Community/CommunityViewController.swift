//
//  CommunityViewController.swift
//  Community
//
//  Created by David Ilizarov on 8/18/15.
//  Copyright (c) 2015 David Ilizarov. All rights reserved.
//

import UIKit

class CommunityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var refreshControl: UIRefreshControl!
    
    var communityTitle: String?
    
    var posts = [String]()
    
    
    @IBOutlet var communityFeed: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        
        posts.append("wow")
        posts.append("no")
        posts.append("Michael")
        
        communityFeed.rowHeight = UITableViewAutomaticDimension
        setupRefreshControl()
    
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupNavBar() {
        var navBar: UINavigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.bounds.width, 64))
        
        navBar.barTintColor = UIColor.whiteColor()
        navBar.translucent = false
        
        self.view.addSubview(navBar)
        
        var buttonLeft = UIBarButtonItem(title: "Wow", style: .Plain, target: self, action: Selector("LLLL"))
        buttonLeft.tintColor = UIColor.blueColor()
        
        var buttonRight = UIBarButtonItem(title: "Search", style: .Plain, target: self, action: Selector("goSearch"))
        buttonRight.tintColor = UIColor.blueColor()
        
        var navigationItem = UINavigationItem()
        navigationItem.rightBarButtonItem = buttonRight
        navigationItem.leftBarButtonItem = buttonLeft
        
        navigationItem.title = communityTitle
        
        navBar.pushNavigationItem(navigationItem, animated: false)
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.addTarget(self, action: Selector("handleRefresh"), forControlEvents: .ValueChanged)
        communityFeed.addSubview(refreshControl)
    }
    
    func goSearch() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func handleRefresh() {
        var delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue(), {
            self.refreshControl.endRefreshing()
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.posts.count > indexPath.row {
            println(posts[indexPath.row])
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.communityFeed.dequeueReusableCellWithIdentifier("communityPost") as! PostCell
        
        if self.posts.count > indexPath.row {
            cell.configureViews(posts[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 160
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        println("community disappeared")
    }
    
    deinit {
        println("community deinit")
    }
}