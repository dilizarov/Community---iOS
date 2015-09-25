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
    
    var delegate: RepliesTableDelegate!
    
    // Optional because the first element is a placeholder.
    var replies = [Reply?]()
    
    //var replies = ["placeholder", "wow", "this", "is", "a", "comment", "for the ages", "YEP YEP YEP YEP AEWPTOMA AWET AWT AMWT LAWT WLT LAWKE GAWL GALW KT", "WETATAWTAWTE AWT AWTAWTAWT'W ,", "WATLQWT QT AE", "waegla gaew gal;kw g wlegka wjgwgwalg we gka fkjwaef akwjef jwaekf kwae fkajwe fjka gke wkag awgja;g ", "wgnkawg akwgl gwa gawl gaj aw fkwa eawjlq rj wreqoiradfa", "k wawlgnaw wefiebf wk kw vka k wkjf wek gkjaw ge g tewr oiqweuroaweurpasf pasfu pfu pup aupurp awu pwetu p uoa uputapwutwout waputpawu tpaweut pwue tpuatpueawpt uawpt uawpetu wtu we tuowu ouut oewutpawut pawuetp aup upasue tuwpghgoah oghao ahohhqtwej la", "wow", "this", "is", "a", "comment", "for the ages", "YEP YEP YEP YEP AEWPTOMA AWET AWT AMWT LAWT WLT LAWKE GAWL GALW KT", "WETATAWTAWTE AWT AWTAWTAWT'W ,", "WATLQWT QT AE", "waegla gaew gal;kw g wlegka wjgwgwalg we gka fkjwaef akwjef jwaekf kwae fkajwe fjka gke wkag awgja;g ", "wgnkawg akwgl gwa gawl gaj aw fkwa eawjlq rj wreqoiradfa", "k wawlgnaw wefiebf wk kw vka k wkjf wek gkjaw ge g tewr oiqweuroaweurpasf pasfu pfu pup aupurp awu pwetu p uoa uputapwutwout waputpawu tpaweut pwue tpuatpueawpt uawpt uawpetu wtu we tuowu ouut oewutpawut pawuetp aup upasue tuwpghgoah oghao ahohhqtwej la", "wow", "this", "is", "a", "comment", "for the ages", "YEP YEP YEP YEP AEWPTOMA AWET AWT AMWT LAWT WLT LAWKE GAWL GALW KT", "WETATAWTAWTE AWT AWTAWTAWT'W ,", "WATLQWT QT AE", "waegla gaew gal;kw g wlegka wjgwgwalg we gka fkjwaef akwjef jwaekf kwae fkajwe fjka gke wkag awgja;g ", "wgnkawg akwgl gwa gawl gaj aw fkwa eawjlq rj wreqoiradfa", "k wawlgnaw wefiebf wk kw vka k wkjf wek gkjaw ge g tewr oiqweuroaweurpasf pasfu pfu pup aupurp awu pwetu p uoa uputapwutwout waputpawu tpaweut pwue tpuatpueawpt uawpt uawpetu wtu we tuowu ouut oewutpawut pawuetp aup upasue tuwpghgoah oghao ahohhqtwej la", "wow", "this", "is", "a", "comment", "for the ages"]
    
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
    
    func requestRepliesAndPopulateFeed(refreshing: Bool) {
        
        if !refreshing {
            delegate.startLoading()
        }
        
        var userInfo = NSUserDefaults.standardUserDefaults()
        
        var params = [String: AnyObject]()
        params["user_id"] = userInfo.objectForKey("user_id") as! String
        params["auth_token"] = userInfo.objectForKey("auth_token") as! String
        
        Alamofire.request(.GET, "https://infinite-lake-4056.herokuapp.com/api/v1/posts/\(post.id)/replies.json", parameters: params)
            .responseJSON { request, response, jsonData, errors in
            
                var defaultError = errors?.localizedDescription
                
                if defaultError != nil {
                    
                } else if let jsonData: AnyObject = jsonData {
                    let json = JSON(jsonData)
                    
                    if (json["errors"] == nil) {
                        self.replies = [nil]
                        
                        for var i = 0; i < json["replies"].count; i++ {
                            var jsonReply = json["replies"][i]
                            
                            var reply = Reply(id: jsonReply["external_id"].stringValue, username: jsonReply["user"]["username"].stringValue, body: jsonReply["body"].stringValue, likeCount: jsonReply["likes"].intValue, liked: jsonReply["liked"].boolValue, timeCreated: jsonReply["created_at"].stringValue, avatarUrl: jsonReply["user"]["avatar_url"].string)
                            
                            self.replies.append(reply)
                            self.replies.append(reply)
                            self.replies.append(reply)
                            self.replies.append(reply)
                            self.replies.append(reply)
                            self.replies.append(reply)
                            self.replies.append(reply)
                            self.replies.append(reply)
                        }
                    }
                    

                    dispatch_async(dispatch_get_main_queue(), {
                        if refreshing {
                            self.delegate.stopRefreshing()
                            self.scrollToBottom()
                        } else {
                            self.delegate.stopLoading()
                        }
                        self.tableView.reloadData()
                    })
                }
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
        return self.replies.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as! ReplyPostCell
        
            cell.configureViews(self.post)
            
            cell.layoutIfNeeded()
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("replyCell", forIndexPath: indexPath) as! ReplyCell
            
            var last = (indexPath.row == replies.count - 1)
            
            var reply = replies[indexPath.row]
            
            cell.configureViews(reply!, last: last)
            
            cell.setNeedsDisplay()
            cell.layoutIfNeeded()
            
//            // initial height
//            
//            var replyString = NSString(string: reply!.body)
//            
//            var width: CGFloat
//
//            if let url = reply!.avatarUrl {
//                width = self.tableView.bounds.width - (16 + 12 + 44 + 16)
//            } else {
//                width = self.tableView.bounds.width - (16 + 12)
//            }
//            
//            var font = cell.replyBody.font
//            
//            let constraintRect = CGSizeMake(width, CGFloat.max)
//                
//            let boundingBox = replyString.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
//            
//            println("boundingBox: \(boundingBox)")
//            
//            initialScrollHeights[indexPath.row] = boundingBox.height + 50
            
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
//            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.replies.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
            
            let count = self.tableView.numberOfRowsInSection(0)
            let currentContentOffset = self.tableView.contentOffset;
            
            for(var i = 0; i<count; i++){
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0), atScrollPosition: .Bottom, animated: false)
            }
            
            let endContentOffset = self.tableView.contentOffset
            
            self.tableView.setContentOffset(currentContentOffset, animated: false);
            self.tableView.setContentOffset(endContentOffset, animated: true)
        }
    }
    
//    override func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
//        if !atBottom {
//            self.tableView.setContentOffset(CGPointMake(0, tableView.contentOffset.y + 226), animated: true)
//        }
//    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        atBottom = scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)
    }
}
