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
    @IBOutlet var communitiesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        communities = ["Hi", "This is community", "This is another"]
        
        communitiesTable.tableHeaderView = UIView(frame: CGRectMake(0, 0, 0, 30))
        communitiesTable.tableFooterView = UIView(frame: CGRectZero)
        communitiesTable.rowHeight = UITableViewAutomaticDimension
        communitiesTable.estimatedRowHeight = 64 // Doesn't have to be accurate, just used 64.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return communities.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.communitiesTable.dequeueReusableCellWithIdentifier("communityCell") as! CommunityCell
        
        if (self.communities.count > indexPath.row) {
             cell.configureViews(communities[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        return
    }
}
