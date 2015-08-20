//
//  ProfileViewController.swift
//  Community
//
//  Created by David Ilizarov on 8/18/15.
//  Copyright (c) 2015 David Ilizarov. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var communities = [NSString]()
    var communities2 = [NSString]()
    var notifs = false
    
    @IBOutlet var communitiesTable: UITableView!
    
    
    @IBOutlet var leftButton: UIButton!
    @IBAction func leftButtonPressed(sender: AnyObject) {
        notifs = false
        communitiesTable.setContentOffset(CGPointZero, animated: false)
        communitiesTable.reloadData()
    }
    
    @IBOutlet var notifications: UIButton!
    @IBAction func notificationsButtonPressed(sender: AnyObject) {
        notifs = true
        communitiesTable.setContentOffset(CGPointZero, animated: false)

        communitiesTable.reloadData()
    }
    
    @IBOutlet var settings: UIButton!
    @IBAction func settingsPressed(sender: AnyObject) {
        
    }
    
    @IBOutlet var backButton: UIButton!
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        communities = ["Hi", "This is community", "This is another", "omg", "why", "what", "how", "this", "is", "real", "life", "run", "popp"]
        
        communities2 = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u"]
        
        communitiesTable.tableHeaderView = UIView(frame: CGRectMake(0, 0, 0, 30))
        communitiesTable.tableFooterView = UIView(frame: CGRectZero)
        communitiesTable.rowHeight = UITableViewAutomaticDimension
        communitiesTable.estimatedRowHeight = 64 // Doesn't have to be accurate, just used 64.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (notifs) {
            return communities2.count
        } else {
            return communities.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.communitiesTable.dequeueReusableCellWithIdentifier("communityCell") as! CommunityCell
        
        if (notifs) {
            if (self.communities2.count > indexPath.row) {
                cell.configureViews(communities2[indexPath.row])
            }

        } else {
            if (self.communities.count > indexPath.row) {
                cell.configureViews(communities[indexPath.row])
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        return
    }
}
