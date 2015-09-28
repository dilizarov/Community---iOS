import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift

class ProfileTableViewController: UITableViewController, PresentControllerDelegate, LeaveCommunityDelegate {
    
    // The states that this controller has to adhere too can not be thrown into
    // a delegate, which means this is tightly coupled with ProfileViewController
    // but seeing as how this is literally embed in it, it can pass.
    var delegate: ProfileViewController!
    
    var communities = [JoinedCommunity]()
    
    var settings = ["Log out"]
    
    var triggerRealmReload = false
    
    @IBAction func handleRefresh(sender: AnyObject) {
        delegate.handleRefresh()
        requestJoinedCommunitiesAndPopulateList()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setRuntimeTableViewParams()
        beginInitialLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let realm = Realm()
        if triggerRealmReload {
            communities = Array(realm.objects(JoinedCommunity
                ).sorted("nameLowercase", ascending: true))
            
            tableView.reloadData()
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
        self.refreshControl!.sendActionsForControlEvents(.ValueChanged)
    }
    
    func presentController(controller: UIViewController) {
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    //TODO
    func presentLeaveCommunityController(community: JoinedCommunity, row: Int) {
        var nameWithUnite = "&\(community.name)"
        
        var confirmLeaveAlert = UIAlertController(title: "Leave \(nameWithUnite)", message: "Are you sure you want to leave?", preferredStyle: .Alert)
        
        let leaveAction = UIAlertAction(title: "Leave", style: .Destructive, handler: {
            (alert: UIAlertAction!) in
            
            self.leaveCommunity(community, row: row)
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
        confirmLeaveAlert.addAction(leaveAction)
        confirmLeaveAlert.addAction(cancelAction)
        
        self.presentViewController(confirmLeaveAlert, animated: true, completion: nil)
    }
    
    func performBackgroundFetch() {
        var userInfo = NSUserDefaults.standardUserDefaults()
        
        var params = [String : AnyObject]()
        
        var user_id = userInfo.objectForKey("user_id") as! String
        
        params["user_id"] = user_id
        params["auth_token"] = userInfo.objectForKey("auth_token") as! String
        
        Alamofire.request(.GET, "https://infinite-lake-4056.herokuapp.com/api/v1/communities.json", parameters: params)
            .responseJSON { request, response, jsonData, errors in
                
                if let jsonData: AnyObject = jsonData {
                    let json = JSON(jsonData)
                    
                    if (json["errors"] == nil) {
                        self.communities = []
                        for var i = 0; i < json["communities"].count; i++ {
                            var jsonCommunity = json["communities"][i]
                            
                            var community = JoinedCommunity()
                            
                            community.name = jsonCommunity["name"].string!
                            
                            if let username = jsonCommunity["user"]["username"].string {
                                community.username = username
                            }
                            
                            if let avatar_url = jsonCommunity["avatar_url"].string {
                                community.avatar_url = avatar_url
                            }
                            
                            self.communities.append(community)
                            
                            //                            var name = community.name
                            //                            var unicode = map(Array(community.name.unicodeScalars)) { NSString(format: "%04X", $0.value) }
                            //
                            //                            println("\(name) \(unicode)")
                        }
                        
                        let realm = Realm()
                        realm.write {
                            // Delete because we don't need data on
                            // communities one may have left.
                            realm.delete(realm.objects(JoinedCommunity))
                            
                            for community in self.communities {
                                realm.add(community, update: true)
                            }
                        }
                        
                        self.triggerRealmReload = true
                    }
                }
        }
    }
    
    func requestJoinedCommunitiesAndPopulateList() {
        
        var userInfo = NSUserDefaults.standardUserDefaults()
        
        var params = [String : AnyObject]()
        
        var user_id = userInfo.objectForKey("user_id") as! String
        
        params["user_id"] = user_id
        params["auth_token"] = userInfo.objectForKey("auth_token") as! String
        
        Alamofire.request(.GET, "https://infinite-lake-4056.herokuapp.com/api/v1/communities.json", parameters: params)
            .responseJSON { request, response, jsonData, errors in
                
                var defaultError = errors?.localizedDescription
                
                if (defaultError != nil) {
                    self.delegate.failureRequestJoinedCommunities(defaultError!.removeEndingPunctuationAndMakeLowerCase())
                } else if let jsonData: AnyObject = jsonData {
                    let json = JSON(jsonData)
                    
                    if (json["errors"] == nil) {
                        self.communities = []
                        for var i = 0; i < json["communities"].count; i++ {
                            var jsonCommunity = json["communities"][i]
                            
                            var community = JoinedCommunity()
                            
                            community.name = jsonCommunity["name"].string!
                            
                            if let username = jsonCommunity["user"]["username"].string {
                                community.username = username
                            }
                            
                            if let avatar_url = jsonCommunity["avatar_url"].string {
                                community.avatar_url = avatar_url
                            }
                            
                            self.communities.append(community)
                            
//                            var name = community.name
//                            var unicode = map(Array(community.name.unicodeScalars)) { NSString(format: "%04X", $0.value) }
//                            
//                            println("\(name) \(unicode)")
                        }
                        
                        let realm = Realm()
                        realm.write {
                            // Delete because we don't need data on
                            // communities one may have left.
                            realm.delete(realm.objects(JoinedCommunity))
                            
                            for community in self.communities {
                                realm.add(community, update: true)
                            }
                        }
                        
                        self.delegate.successRequestJoinedCommunities()
                        self.tableView.reloadData()
                    } else {
                        var errorString = ""
                        
                        for var i = 0; i < json["errors"].count; i++ {
                            if (i != 0) { errorString += "\n\n" }
                            
                            errorString += json["errors"][i].string!
                        }
                        
                        self.delegate.failureRequestJoinedCommunities(errorString)
                    }
                } else {
                    self.delegate.failureRequestJoinedCommunities("something went wrong :(")
                }
                
                // We add a delay between ending the refresh and reloading data because otherwise the animation won't
                // be smooth and from then on, refreshing looks clunky.
                var delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
                
                dispatch_after(delayTime, dispatch_get_main_queue(), {
                    self.refreshControl!.endRefreshing()
                })
        }
    }
    
    func leaveCommunity(community: JoinedCommunity, row: Int) {
        if (community.name == communities[row].name) {
            communities.removeAtIndex(row)
        } else {
            communities = communities.filter( { return $0.name != community.name } )
        }
        
        tableView.reloadData()
        
        var userInfo = NSUserDefaults.standardUserDefaults()
        
        var params = [String : AnyObject]()
        
        params["user_id"] = userInfo.objectForKey("user_id") as! String
        params["auth_token"] = userInfo.objectForKey("auth_token") as! String
        params["community"] = community.name.strip()
        
        Alamofire.request(.DELETE, "https://infinite-lake-4056.herokuapp.com/api/v1/communities.json", parameters: params)
            .responseJSON { request, response, jsonData, errors in
                
                if (response?.statusCode == 404 || errors != nil) {
                    
                    var arraySize = self.communities.count
                    
                    self.communities.insert(community, atIndex: (row > arraySize ? arraySize : row))
                    self.tableView.reloadData()
                    
                    if (response?.statusCode == 404) {
                        self.delegate.spreadToast("something went wrong :(")
                    } else {
                        self.delegate.spreadToast(errors!.localizedDescription.removeEndingPunctuationAndMakeLowerCase())
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
            return communities.count
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
            
            return cell
        //} else if delegate.currentState == ProfileViewController.State.Notifications {
        //    return communities.count
        } else {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("settingCell") as! UITableViewCell
            
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
                
                NSNotificationCenter.defaultCenter().postNotificationName("communitySelected", object: self, userInfo: userInfo)
            }
            //} else if delegate.currentState == ProfileViewController.State.Notifications {
            //    return communities.count
        } else {
            if (settings.count > indexPath.row) {
               
                if settings[indexPath.row] == "Log out" {
                    
                    
                    var logoutAlert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .Alert)
                    
                    let logoutAction = UIAlertAction(title: "Log Out", style: .Destructive, handler: {
                        (alert: UIAlertAction!) in
                        println("logout")
                    })
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
                    
                    logoutAlert.addAction(logoutAction)
                    logoutAlert.addAction(cancelAction)
                    
                    self.presentViewController(logoutAlert, animated: true, completion: nil)
                }
            }
        }
    }
}
