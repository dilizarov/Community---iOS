//
//  CommunityTableViewController.swift
//  
//
//  Created by David Ilizarov on 9/14/15.
//
//

import UIKit
import Alamofire
import SwiftyJSON

class CommunityTableViewController: UITableViewController, UpdateFeedWithLatestPostDelegate {

    var delegate: CommunityTableDelegate!
    
    var posts = [Post]()
    var cachedHeights = [Int: CGFloat]()
    
    var communityTitle: String?
    
    // Infinite Scroll Solution
    var infiniteScrollBufferCount: Int!
    var reachedEndOfList: Bool!
    var reachedEndOfCallback: Bool!
    var isLoading: Bool!
    var problemsLoading: Bool!
    var preloadPostCount: Int!
    var currentPage: Int!
    var infiniteScrollTimeBuffer: String!
    var lastTimeLoading: NSDate!
    
    @IBAction func handleRefresh(sender: AnyObject) {
        requestPostsAndPopulateFeed(true, page: nil, completionHandler: nil, changingCommunities: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setInfiniteScrollVars()
        setupWritePostButton()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        requestPostsAndPopulateFeed(false, page: nil, completionHandler: nil, changingCommunities: false)

    }
    
    func setInfiniteScrollVars() {
        infiniteScrollBufferCount = 3
        reachedEndOfList = false
        reachedEndOfCallback = false
        isLoading = false
        problemsLoading = false
        preloadPostCount = 0
        currentPage = 2
        infiniteScrollTimeBuffer = ""
    }
    
    func setupWritePostButton() {
        var customView = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 60))
        
        var button: UIButton = UIButton.buttonWithType(.System) as! UIButton
        button.backgroundColor = UIColor.whiteColor()
        button.layer.cornerRadius = 5.0
        button.clipsToBounds = true
        button.frame = CGRectMake(8, 10, 40, 40)
        button.setImage(UIImage(named: "Pencil"), forState: .Normal)
        button.tintColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        
        customView.addSubview(button)
        
        button.addTarget(self, action: Selector("writePost"), forControlEvents: .TouchUpInside)
        
        self.tableView.tableHeaderView = customView
    }
    
    func writePost() {
        delegate.writePost()
    }
    
    func updateFeedWithLatestPost(post: Post) {
        posts.insert(post, atIndex: 0)
        self.tableView.setContentOffset(CGPointZero, animated: true)
        
        tableView.reloadData()
    }
    
    func animateInitialLoad() {
        // The contentOffset pertains to a bug in iOS 7/8 where
        // the refreshControl isn't the tintColor set on it during
        // its first showing.
        self.tableView.contentOffset = CGPointMake(0, -self.refreshControl!.frame.size.height)
        self.refreshControl!.beginRefreshing()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.posts.count > indexPath.row {
            var post = posts[indexPath.row]
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let commentsVC = storyboard.instantiateViewControllerWithIdentifier("CommentsViewController") as! CommentsViewController
         
            
            commentsVC.post = post
            
            self.presentViewController(commentsVC, animated: true, completion: nil)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("communityPost", forIndexPath: indexPath) as! PostCell
        
        if self.posts.count > indexPath.row {
            cell.configureViews(posts[indexPath.row])
        }
        
        cell.layoutIfNeeded()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        self.cachedHeights[indexPath.row] = cell.frame.size.height
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let height = cachedHeights[indexPath.row] {
            return height
        } else {
            return 200
        }
    }
    
    func requestPostsAndPopulateFeed(refreshing: Bool, page: Int?, completionHandler: ((UIBackgroundFetchResult) -> Void)?, changingCommunities: Bool) {
        
        if !refreshing && page == nil {
            animateInitialLoad()
        }
        
        var userInfo = NSUserDefaults.standardUserDefaults()
        
        var params = [String: AnyObject]()
        params["user_id"] = userInfo.objectForKey("user_id") as! String
        params["auth_token"] = userInfo.objectForKey("auth_token") as! String
        params["community"] = communityTitle!
        
        if (!refreshing) {
            if page != nil {
                var unwrappedPage = page!
                params["page"] = unwrappedPage
            }
            
            if (!infiniteScrollTimeBuffer.isEmpty) {
                params["infinite_scroll_time_buffer"] = infiniteScrollTimeBuffer
            }
        }
        
        Alamofire.request(.GET, "https://infinite-lake-4056.herokuapp.com/api/v1/posts.json", parameters: params)
            .responseJSON { request, response, jsonData, errors in
                
                var defaultError = errors?.localizedDescription
                
                if (defaultError != nil) {
                    
                } else if let jsonData: AnyObject = jsonData {
                    let json = JSON(jsonData)
                    println(json)
                    
                    if (json["errors"] == nil) {
                        if (refreshing) {
                            self.posts = []
                            self.cachedHeights.removeAll(keepCapacity: false)
                            self.reachedEndOfList = false
                        }
                        
                        if (json["posts"].count < 15) {
                            self.reachedEndOfList = true
                        }
                        
                        for var i = 0; i < json["posts"].count; i++ {
                            var jsonPost = json["posts"][i]
                            
                            var post = Post(id: jsonPost["external_id"].stringValue, username: jsonPost["user"]["username"].stringValue, body: jsonPost["body"].stringValue, title: jsonPost["title"].string, repliesCount: jsonPost["replies_count"].intValue, likeCount: jsonPost["likes"].intValue, liked: jsonPost["liked"].boolValue, timeCreated: jsonPost["created_at"].stringValue, avatarUrl: jsonPost["user"]["avatar_url"].string)
                            
                            var rand = Int(arc4random_uniform(UInt32(3)))
                            
                            if rand == 1 || (page == nil && i == 1) {
                                if post.title == nil {
                                    post.title = "I weq weerw qwe qewrwlerkwr qlr lqwe r qwer qwler qwelrk wer kwlr lwer qwekrqwer qwr lqwer qlw rwerwerw rqwrqw erq rwqerkqwe rlwqr qwler qler qkw rlqwer qlwer qwler qlw rlekr qwelrkq ewqlwer qelwr qwerqwerqwerqwe :3"
                                }
                            }
                            
                            if (i == 0 && (self.infiniteScrollTimeBuffer.isEmpty || refreshing)) {
                                self.infiniteScrollTimeBuffer = NSDate(timeIntervalSince1970: (post.timeCreated.timeIntervalSince1970 * 1000 + 1)/1000).stringFromDate()
                            }
                            
                            self.posts.append(post)
                        }
                        
                        var delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
                        
                        dispatch_after(delayTime, dispatch_get_main_queue(), {
                            if completionHandler != nil {
                                self.tableView.setContentOffset(CGPointZero, animated: false)
                            } else {
                                self.tableView.reloadData()
                            }
                            
                            // noPostsText
                            if self.posts.count == 0 {
                                
                            } else {
                                
                            }
                            
                            if refreshing {
                                self.currentPage = 2
                            }
                            
                            dispatch_after(delayTime, dispatch_get_main_queue(), {
                                self.refreshControl!.endRefreshing()
                                self.toggleLoadingFooter(false)
                            })
                            
                            self.reachedEndOfCallback = true
                            //self.fetchedOnce = true
                            
                            if completionHandler != nil {
                                completionHandler!(UIBackgroundFetchResult.NewData)
                            }
                        })
                        
                    } else {
                        
                    }
                } else {
                    
                }
        }
    }
    
    
    func toggleLoadingFooter(on: Bool) {
        if on {
            var container = UIView(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, 44))
            
            var loadSpinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
            var frame = loadSpinner.frame
            frame.origin.x = container.frame.size.width * 0.5 - frame.size.width * 0.5
            frame.origin.y = container.frame.size.height * 0.5 - frame.size.height * 0.5
            loadSpinner.frame = frame
            
            container.addSubview(loadSpinner)
            loadSpinner.startAnimating()
            
            self.tableView.tableFooterView = container
        } else {
            self.tableView.tableFooterView = nil
        }
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
    
        if reachedEndOfList! || posts.count < 15 { return }
    
        if posts.count < preloadPostCount {
            preloadPostCount = posts.count
            if (posts.count == 0) { isLoading = true }
        }
    
        if isLoading! && reachedEndOfCallback! {
            isLoading = false
            preloadPostCount = posts.count
            currentPage = currentPage + 1
        }
    
        if problemsLoading! {
            if lastTimeLoading != nil && NSDate().secondsFrom(lastTimeLoading) > 4 {
                isLoading = false
            }
        }
    
        if (!isLoading) {
            var visibleIndexPaths = self.tableView.indexPathsForVisibleRows() as! [NSIndexPath]
            var visibleCount = visibleIndexPaths.count
            
            //Ensure we don't crash if for some reason the user is scrolling without any active cells.
            if visibleCount == 0 { return }
            
            // We add one so it plays nicely with posts.count
            var bottomVisiblePost = visibleIndexPaths[visibleCount - 1].row + 1
    
            if (bottomVisiblePost + infiniteScrollBufferCount >= posts.count) {
                isLoading = true
                reachedEndOfCallback = false
                lastTimeLoading = NSDate()

                toggleLoadingFooter(true)
                
                requestPostsAndPopulateFeed(false, page: currentPage, completionHandler: nil, changingCommunities: false)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
