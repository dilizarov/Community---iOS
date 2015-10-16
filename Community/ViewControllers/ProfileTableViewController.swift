import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

class ProfileTableViewController: UITableViewController, PresentControllerDelegate, LeaveCommunityDelegate {
    
    // The states that this controller has to adhere too can not be thrown into
    // a delegate, which means this is tightly coupled with ProfileViewController
    // but seeing as how this is literally embed in it, it can pass.
    var delegate: ProfileViewController!
    
    var communities = [JoinedCommunity]()
    var notifications = [Notification]()
    
    var settings: [String] {
 
        var settings: [String]
        
        if Session.isMeta() {
            settings = ["Log In", "Create Account"]
        } else {
            settings = ["Log Out"]
        }

        return settings
    }
    
    var triggerRealmReload = false
    
    @IBAction func handleRefresh(sender: AnyObject) {
        delegate.handleRefresh()
        
        if delegate.currentState == .Communities {
            requestJoinedCommunitiesAndPopulateList()
        } else if delegate.currentState == .Notifications {
            requestNotificationsAndPopulateList()
        } else {
            self.refreshControl!.endRefreshing()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setRuntimeTableViewParams()
        beginInitialLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let realm = try! Realm()
        if triggerRealmReload {
            communities = Array(realm.objects(JoinedCommunity
                ).sorted("normalizedName", ascending: true))
            
            if communities.count != 0 && delegate.currentState == .Communities {
                delegate.successRequestJoinedCommunities()
                tableView.reloadData()
            }

            triggerRealmReload = false
        }
    }
    
    func setRuntimeTableViewParams() {
        tableView.tableHeaderView = UIView(frame: CGRectMake(0,0,0,30))
        // This is so that the tableView separator is only under filled cells.
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
    }
    
    func beginInitialLoad() {
        self.refreshControl!.beginRefreshing()
        
        // Handling bug of refresh control not appearing when contentOffset is 0.
        if (self.tableView.contentOffset.y == 0) {
            
            UIView.animateWithDuration(0.25, animations: {
                self.tableView.contentOffset = CGPointMake(0, -self.refreshControl!.frame.size.height)
            })
        }
        
        self.refreshControl!.sendActionsForControlEvents(.ValueChanged)
    }
    
    func presentController(controller: UIViewController) {
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func presentLeaveCommunityController(community: JoinedCommunity, row: Int) {
        
        let nameWithUnite = "&" + community.name.strip().lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: "_")
        
        let confirmLeaveAlert = UIAlertController(title: "Leave \(nameWithUnite)", message: "Are you sure you want to leave?", preferredStyle: .Alert)
        
        let leaveAction = UIAlertAction(title: "Leave", style: .Destructive, handler: {
            (alert: UIAlertAction!) in
            
            self.leaveCommunity(community, row: row)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
        confirmLeaveAlert.addAction(leaveAction)
        confirmLeaveAlert.addAction(cancelAction)
        
        self.presentViewController(confirmLeaveAlert, animated: true, completion: nil)
    }
    
    func performBackgroundFetch(asyncGroup: dispatch_group_t!) {
        
        dispatch_group_enter(asyncGroup)
        Alamofire.request(Router.GetCommunities)
            .responseJSON { request, response, result in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    
                    var storeInRealm = false
                    
                    if let jsonData: AnyObject = result.value {
                        let json = JSON(jsonData)
                        
                        if (json["errors"] == nil && json["error"] == nil) {
                            self.communities = []
                            for var i = 0; i < json["communities"].count; i++ {
                                var jsonCommunity = json["communities"][i]
                                
                                let community = JoinedCommunity()
                                
                                community.name = jsonCommunity["name"].string!
                                community.normalizedName = jsonCommunity["normalized_name"].string!
                                
                                if let username = jsonCommunity["user"]["username"].string {
                                    community.username = username
                                }
                                
                                if let avatar_url = jsonCommunity["avatar_url"].string {
                                    community.avatar_url = avatar_url
                                }
                                
                                self.communities.append(community)
                            }
                            
                            storeInRealm = true
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        if storeInRealm {
                            let realm = try! Realm()
                            try! realm.write {
                                // Delete because we don't need data on
                                // communities one may have left.
                                realm.delete(realm.objects(JoinedCommunity))
                                
                                for community in self.communities {
                                    realm.add(community, update: true)
                                }
                            }
                            
                            self.triggerRealmReload = true
                        }
                        
                        dispatch_group_leave(asyncGroup)
                    }
                }
        }
    }
    
    func requestJoinedCommunitiesAndPopulateList() {
        
        Alamofire.request(Router.GetCommunities)
            .responseJSON { request, response, result in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    let defaultError = (result.error as? NSError)?.localizedDescription
                    
                    self.communities = []
                    var failureString: String?
                    
                    if (defaultError != nil) {
                        failureString = defaultError!.removeEndingPunctuationAndMakeLowerCase()
                    } else if let jsonData: AnyObject = result.value {
                        let json = JSON(jsonData)
                        
                        if (json["error"] != nil) {
                            failureString = json["error"].stringValue
                        } else if (json["errors"] == nil) {
                            for var i = 0; i < json["communities"].count; i++ {
                                var jsonCommunity = json["communities"][i]
                                
                                let community = JoinedCommunity()
                                
                                community.name = jsonCommunity["name"].string!
                                community.normalizedName = jsonCommunity["normalized_name"].string!
                                
                                if let username = jsonCommunity["user"]["username"].string {
                                    community.username = username
                                }
                                
                                if let avatar_url = jsonCommunity["user"]["avatar_url"].string {
                                    community.avatar_url = avatar_url
                                }
                                
                                self.communities.append(community)
                            }
                            
                            if self.communities.count == 0 {
                                failureString = "Communities you join will be located here"
                            }
                        } else {
                            var errorString = ""
                            
                            for var i = 0; i < json["errors"].count; i++ {
                                if (i != 0) { errorString += "\n\n" }
                                
                                errorString += json["errors"][i].string!
                            }
                            
                            failureString = errorString
                        }
                    } else {
                        failureString = "something went wrong :("
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.tableView.reloadData()
                        if let string = failureString {
                            self.delegate.failureRequestJoinedCommunities(string)
                        } else {
                            self.delegate.successRequestJoinedCommunities()
                            let realm = try! Realm()
                            try! realm.write {
                                // Delete because we don't need data on
                                // communities one may have left.
                                realm.delete(realm.objects(JoinedCommunity))
                                
                                for community in self.communities {
                                    realm.add(community, update: true)
                                }
                            }
                        }
                        
                        // We add a delay between ending the refresh and reloading data because otherwise the animation won't
                        // be smooth and from then on, refreshing looks clunky.
                        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
                        
                        dispatch_after(delayTime, dispatch_get_main_queue(), {
                            self.refreshControl!.endRefreshing()
                        })
                    }
                }
        }
    }
    
    func requestNotificationsAndPopulateList() {
        
        Alamofire.request(Router.GetNotifications)
            .responseJSON { request, response, result in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    let defaultError = (result.error as? NSError)?.localizedDescription
                    
                    self.notifications = []
                    var failureString: String?
                    
                    if (defaultError != nil) {
                        failureString = defaultError!.removeEndingPunctuationAndMakeLowerCase()
                    } else if let jsonData: AnyObject = result.value {
                        let json = JSON(jsonData)
                        
                        if (json["error"] != nil) {
                            failureString = json["error"].stringValue
                        } else if (json["errors"] == nil) {
                            
                            for var i = 0; i < json["notifications"].count; i++ {
                                var jsonNotif = json["notifications"][i]
                                
                                let notification = Notification(kind: jsonNotif["kind"].string!,
                                    username: jsonNotif["user"]["username"].string!,
                                    timeCreated: jsonNotif["created_at"].string!,
                                    community: jsonNotif["community"].string!,
                                    normalizedCommunityName: jsonNotif["community_normalized"].string!,
                                    postId: jsonNotif["post_id"].string!,
                                    avatarUrl: jsonNotif["user"]["avatar_url"].string)
                                
                                self.notifications.append(notification)
                            }
                            
                            self.delegate.resetBadge()
                            
                            if self.notifications.count == 0 {
                                failureString = "Notifications can be found here"
                            }
                        } else {
                            var errorString = ""
                            
                            for var i = 0; i < json["errors"].count; i++ {
                                if (i != 0) { errorString += "\n\n" }
                                
                                errorString += json["errors"][i].string!
                            }
                            
                            failureString = errorString
                        }
                    } else {
                        failureString = "something went wrong :("
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                        if let string = failureString {
                            self.delegate.failureRequestNotifications(string)
                        } else {
                            self.delegate.successRequestNotifications()
                        }
                        
                        // We add a delay between ending the refresh and reloading data because otherwise the animation won't
                        // be smooth and from then on, refreshing looks clunky.
                        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
                        
                        dispatch_after(delayTime, dispatch_get_main_queue(), {
                            self.refreshControl!.endRefreshing()
                        })
                    }
                }
        }
    }

    
    func leaveCommunity(community: JoinedCommunity, row: Int) {
        if (community.normalizedName == communities[row].normalizedName) {
            communities.removeAtIndex(row)
        } else {
            communities = communities.filter( { return $0.normalizedName != community.normalizedName } )
        }
        
        tableView.reloadData()
        
        Alamofire.request(Router.LeaveCommunity(community: community.name.strip()))
            .responseJSON { request, response, result in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    if (response?.statusCode > 299 || result.error != nil) {
                        
                        let arraySize = self.communities.count
                        
                        self.communities.insert(community, atIndex: (row > arraySize ? arraySize : row))
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tableView.reloadData()
                            
                            if (response?.statusCode > 299) {
                                self.delegate.spreadToast("something went wrong :(")
                            } else {
                                self.delegate.spreadToast((result.error as? NSError)!.localizedDescription.removeEndingPunctuationAndMakeLowerCase())
                            }
                        }
                    }
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if delegate.currentState == ProfileViewController.State.Communities {
            return communities.count
        } else if delegate.currentState == ProfileViewController.State.Notifications {
            return notifications.count
        } else {
            return settings.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if delegate.currentState == ProfileViewController.State.Communities {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("communityCell") as! CommunityCell
            
            cell.presentControllerDelegate = self
            cell.leaveCommunityDelegate = self
            
            if (communities.count > indexPath.row) {
                cell.configureViews(communities[indexPath.row], row: indexPath.row)
            }
            
            cell.contentView.layer.zPosition = 500
            
            return cell
        } else if delegate.currentState == ProfileViewController.State.Notifications {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("notificationCell") as! NotificationCell
            
            if (notifications.count > indexPath.row) {
                cell.configureViews(notifications[indexPath.row])
            }
            
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("settingCell") as UITableViewCell!
            
            if (settings.count > indexPath.row) {
                (cell.viewWithTag(5) as! UILabel).text = settings[indexPath.row]
            }
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if delegate.currentState == ProfileViewController.State.Communities {
            if (communities.count > indexPath.row) {
                var userInfo = Dictionary<String, String>()
                userInfo["community"] = communities[indexPath.row].name
                userInfo["normalized_name"] = communities[indexPath.row].normalizedName
                
                NSNotificationCenter.defaultCenter().postNotificationName("communitySelected", object: self, userInfo: userInfo)
            }
        } else if delegate.currentState == ProfileViewController.State.Notifications {
            if (notifications.count > indexPath.row) {
                var userInfo = Dictionary<String, String>()
                userInfo["community"] = notifications[indexPath.row].community
                userInfo["normalized_name"] = notifications[indexPath.row].normalizedCommunityName
                userInfo["postId"] = notifications[indexPath.row].postId
                                
                NSNotificationCenter.defaultCenter().postNotificationName("communitySelected", object: self, userInfo: userInfo)
            }
        } else {
            if (settings.count > indexPath.row) {
               
                if settings[indexPath.row] == "Log Out" {
                    
                    
                    let logoutAlert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .Alert)
                    
                    let logoutAction = UIAlertAction(title: "Log Out", style: .Destructive, handler: {
                        (alert: UIAlertAction!) in
                        self.delegate.processLogOut()
                    })
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
                    
                    logoutAlert.addAction(logoutAction)
                    logoutAlert.addAction(cancelAction)
                    
                    self.presentViewController(logoutAlert, animated: true, completion: nil)
                } else if settings[indexPath.row] == "Log In" {
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                        
                    self.presentViewController(loginVC, animated: true, completion: nil)
                    
                } else if settings[indexPath.row] == "Create Account" {
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let registrationVC = storyboard.instantiateViewControllerWithIdentifier("CreateAccountViewController") as! CreateAccountViewController
                    
                    self.presentViewController(registrationVC, animated: true, completion: nil)
                }
            }
        }
    }
}
