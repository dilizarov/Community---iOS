//
//  RepliesTableViewController.swift
//  
//
//  Created by David Ilizarov on 9/18/15.
//
//

import UIKit
import Alamofire
import SwiftyJSON

class RepliesTableViewController: UITableViewController {
    
    var post: Post!
    var atBottom = false
    
    var emptyOrErrorDescription: String?
    
    var delegate: RepliesTableDelegate!
    
    // Optional because the first element is a placeholder (nil).
    var replies = [Reply?]()
    
    var cachedHeights = [Int: CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var headerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.width, 20))
        headerView.backgroundColor = UIColor.clearColor()
        
        tableView.tableHeaderView = headerView
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.contentSize = tableView.frame.size
        tableView.setKeyboardAvoidingEnabled(true)
        
        requestRepliesAndPopulateFeed(false)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "scrollTableUp:", name: PHFComposeBarViewDidChangeFrameNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "scrollTableUp:", name: UIKeyboardDidChangeFrameNotification, object: nil)
    }
    
    func scrollTableUp(notification: NSNotification) {
        
        var animated = false
        
        if let info = notification.userInfo {
            if let keyboardFrame = info[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                animated = keyboardFrame.CGRectValue().height > 100
            }
        }

        if atBottom {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.replies.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: animated)
        }
    }
    
    func performBackgroundFetch(asyncGroup: dispatch_group_t!) {
        
        dispatch_group_enter(asyncGroup)
        Alamofire.request(Router.GetReplies(post_id: post.id))
            .responseJSON { request, response, jsonData, errors in
                
                if let jsonData: AnyObject = jsonData {
                    let json = JSON(jsonData)
                    
                    if (json["errors"] == nil) {
                        self.replies = [nil]
                        
                        self.post.repliesCount = json["replies"].count
                        for var i = 0; i < json["replies"].count; i++ {
                            var jsonReply = json["replies"][i]
                            
                            var reply = Reply(id: jsonReply["external_id"].stringValue, username: jsonReply["user"]["username"].stringValue, body: jsonReply["body"].stringValue, likeCount: jsonReply["likes"].intValue, liked: jsonReply["liked"].boolValue, timeCreated: jsonReply["created_at"].stringValue, avatarUrl: jsonReply["user"]["avatar_url"].string)
                            
                            self.replies.append(reply)
                        }
                        
                        if self.replies.count == 1 {
                            self.emptyOrErrorDescription = "No replies"
                        } else {
                            self.emptyOrErrorDescription = nil
                        }
                    }
                } else {
                
                }
                
                dispatch_group_leave(asyncGroup)
        }
    }
    
    func requestRepliesAndPopulateFeed(refreshing: Bool) {
        
        self.emptyOrErrorDescription = nil
        
        if !refreshing {
            delegate.startLoading()
        }
        
        Alamofire.request(Router.GetReplies(post_id: post.id))
            .responseJSON { request, response, jsonData, errors in
                
                var defaultError = errors?.localizedDescription
                
                if defaultError != nil {
                    self.emptyOrErrorDescription = defaultError
                } else if let jsonData: AnyObject = jsonData {
                    let json = JSON(jsonData)
                    
                    if (json["errors"] == nil) {
                        self.replies = [nil]
                        
                        self.post.repliesCount = json["replies"].count
                        for var i = 0; i < json["replies"].count; i++ {
                            var jsonReply = json["replies"][i]
                            
                            var reply = Reply(id: jsonReply["external_id"].stringValue, username: jsonReply["user"]["username"].stringValue, body: jsonReply["body"].stringValue, likeCount: jsonReply["likes"].intValue, liked: jsonReply["liked"].boolValue, timeCreated: jsonReply["created_at"].stringValue, avatarUrl: jsonReply["user"]["avatar_url"].string)
                            
                            self.replies.append(reply)
                        }
                        
                        if self.replies.count == 1 {
                            self.emptyOrErrorDescription = "No replies"
                        }
                    } else {
                        self.emptyOrErrorDescription = ""
                        
                        for var i = 0; i < json["errors"].count; i++ {
                            if (i != 0) { self.emptyOrErrorDescription = self.emptyOrErrorDescription! + "\n\n" }
                            self.emptyOrErrorDescription = self.emptyOrErrorDescription! + json["errors"][i].string!
                        }

                    }
                } else {
                    
                }

                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                    
                    if refreshing {
                        self.delegate.stopRefreshing()
                        if (self.emptyOrErrorDescription == nil) { self.scrollToBottom() }
                    } else {
                        self.delegate.stopLoading()
                    }
                })
            }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: PHFComposeBarViewDidChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidChangeFrameNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: PHFComposeBarViewDidChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidChangeFrameNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if emptyOrErrorDescription != nil {
            return 2
        } else {
            return self.replies.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as! ReplyPostCell
        
            cell.configureViews(self.post)
            
            cell.layoutIfNeeded()
            
            return cell
        } else if emptyOrErrorDescription != nil {
            var cell = tableView.dequeueReusableCellWithIdentifier("noReplies") as! NoRepliesCell
            
            cell.configureView(emptyOrErrorDescription!)
            
            cell.setNeedsDisplay()
            cell.layoutIfNeeded()
            
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("replyCell", forIndexPath: indexPath) as! ReplyCell
            
            var last = (indexPath.row == replies.count - 1)
            
            var reply = replies[indexPath.row]
            
            cell.configureViews(reply!, last: last)
            
            cell.setNeedsDisplay()
            cell.layoutIfNeeded()

            return cell
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        self.cachedHeights[indexPath.row] = cell.frame.size.height
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let height = cachedHeights[indexPath.row] {
            return height
        } else {
            return 113
        }
    }
    
    // This garbage is so hacky but this solution hilariously works to getting the bottom showing. I'm honestly pretty shocked right now 
    // at how infuriating it is to just accurately scroll to the bottom with dynamic cell heights. The cachedHeights
    // doesn't kick in until after the initial scroll. The initial scroll requires our funny scrollViewDidEndScrollingAnimation.
    func scrollToBottom() {
        if !atBottom {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.replies.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
         
            
//      Another hacky solution that doesn't work when have a ton of rows... (over 100). Welp
            
//            let count = self.tableView.numberOfRowsInSection(0)
//            let currentContentOffset = self.tableView.contentOffset;
//            
//            for(var i = 0; i<count; i++){
//                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0), atScrollPosition: .Bottom, animated: false)
//            }
//            
//            let endContentOffset = self.tableView.contentOffset
//            
//            self.tableView.setContentOffset(currentContentOffset, animated: false);
//            self.tableView.setContentOffset(endContentOffset, animated: true)
        }
    }
    
    override func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        if !atBottom {
            self.tableView.setContentOffset(CGPointMake(0, tableView.contentOffset.y + 226), animated: true)
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        atBottom = scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)
    }
}