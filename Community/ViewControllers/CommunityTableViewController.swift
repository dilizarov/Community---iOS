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

class CommunityTableViewController: UITableViewController, UpdateFeedWithLatestPostDelegate, PresentControllerDelegate {

    var delegate: CommunityTableDelegate!

    var verifiedMembership: Bool = false
    var posts = [Post]()
    var cachedHeights = [Int: CGFloat]()

    var emptyOrErrorDescription: String?

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

    var backgroundRefreshed: Bool = false

    @IBAction func handleRefresh(sender: AnyObject) {
        requestPostsAndPopulateFeed(true, page: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setInfiniteScrollVars()
        setupWritePostButton()

        tableView.rowHeight = UITableViewAutomaticDimension
        requestPostsAndPopulateFeed(false, page: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // This if-statement is important to ensure we don't interfere with potential clash in double reloadDatas.
        if !refreshControl!.refreshing {

            if backgroundRefreshed {
                self.tableView.setContentOffset(CGPointZero, animated: false)
                backgroundRefreshed = false
            }

            self.tableView.reloadData()
        }
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
        let customView = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 60))

        let button: UIButton = UIButton(type: .System)
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
        self.emptyOrErrorDescription = nil

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
        if emptyOrErrorDescription != nil {
            return 1
        } else {
            return self.posts.count
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.posts.count > indexPath.row {
            let post = posts[indexPath.row]

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let repliesVC = storyboard.instantiateViewControllerWithIdentifier("RepliesViewController") as! RepliesViewController


            repliesVC.post = post

            self.presentViewController(repliesVC, animated: true, completion: nil)
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if emptyOrErrorDescription != nil {
            let cell = tableView.dequeueReusableCellWithIdentifier("noPosts") as! NoPostsCell

            cell.configureView(emptyOrErrorDescription!)

            cell.layoutIfNeeded()

            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("communityPost", forIndexPath: indexPath) as! PostCell

            if self.posts.count > indexPath.row {
                cell.delegate = self
                cell.configureViews(posts[indexPath.row])
            }

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
            return 200
        }
    }

    func presentController(controller: UIViewController) {
        self.presentViewController(controller, animated: true, completion: nil)
    }

    func performBackgroundFetch(asyncGroup: dispatch_group_t!) {

        dispatch_group_enter(asyncGroup)
        Alamofire.request(Router.GetPosts(community: communityTitle!.strip(), page: nil, infiniteScrollTimeBuffer: nil, verifyMembership: false))
            .responseJSON { request, response, result in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    if let jsonData: AnyObject = result.value {
                        let json = JSON(jsonData)

                        if (json["errors"] == nil && json["error"] == nil) {

                            self.setInfiniteScrollVars()

                            self.posts = []
                            self.cachedHeights.removeAll(keepCapacity: false)

                            if (json["posts"].count < 15) {
                                self.reachedEndOfList = true
                            }

                            for var i = 0; i < json["posts"].count; i++ {
                                var jsonPost = json["posts"][i]

                                let post = Post(id: jsonPost["external_id"].stringValue, username: jsonPost["user"]["username"].stringValue, body: jsonPost["body"].stringValue, title: jsonPost["title"].string, repliesCount: jsonPost["replies_count"].intValue, likeCount: jsonPost["likes"].intValue, liked: jsonPost["liked"].boolValue, timeCreated: jsonPost["created_at"].stringValue, avatarUrl: jsonPost["user"]["avatar_url"].string)

                                if (i == 0) {
                                    self.infiniteScrollTimeBuffer = post.timeCreated.stringFromDate()
                                }

                                self.posts.append(post)
                            }

                            self.backgroundRefreshed = true

                            if self.posts.count == 0 {
                                self.emptyOrErrorDescription = "This community has no posts"
                            } else {
                                self.emptyOrErrorDescription = nil
                            }
                        }
                    }

                    dispatch_group_leave(asyncGroup)
                }
        }
    }

    func requestPostsAndPopulateFeed(refreshing: Bool, page: Int?) {

        self.emptyOrErrorDescription = nil

        if !refreshing && page == nil {
            animateInitialLoad()
        }

        var potentialPage: Int?
        var potentialTimeBuffer: String?

        if (!refreshing) {

            potentialPage = page

            if !infiniteScrollTimeBuffer.isEmpty {
                potentialTimeBuffer = infiniteScrollTimeBuffer
            }

        }

        Alamofire.request(Router.GetPosts(community: communityTitle!.strip(), page: potentialPage, infiniteScrollTimeBuffer: potentialTimeBuffer, verifyMembership: !verifiedMembership))
        .responseJSON { request, response, result in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {

                let defaultError = (result.error as? NSError)?.localizedDescription

                if ((response == nil || response?.statusCode > 299) && defaultError != nil) {
                    self.emptyOrErrorDescription = defaultError
                } else if let jsonData: AnyObject = result.value {
                    let json = JSON(jsonData)

                    if (json["error"] != nil) {
                        self.emptyOrErrorDescription = json["error"].stringValue
                    } else if (json["errors"] == nil) {
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

                            let post = Post(id: jsonPost["external_id"].stringValue, username: jsonPost["user"]["username"].stringValue, body: jsonPost["body"].stringValue, title: jsonPost["title"].string, repliesCount: jsonPost["replies_count"].intValue, likeCount: jsonPost["likes"].intValue, liked: jsonPost["liked"].boolValue, timeCreated: jsonPost["created_at"].stringValue, avatarUrl: jsonPost["user"]["avatar_url"].string)

                            if (i == 0 && (self.infiniteScrollTimeBuffer.isEmpty || refreshing)) {
                                self.infiniteScrollTimeBuffer = post.timeCreated.stringFromDate()
                            }

                            self.posts.append(post)
                        }
                        
                        if self.posts.count == 0 {
                            self.emptyOrErrorDescription = "This community has no posts"
                        }
                        
                        if json["membership"].bool != nil {
                            self.verifiedMembership = true
    
                            self.delegate.declareRelationship(json["relationship"])
                        }
                    } else {
                        self.emptyOrErrorDescription = ""

                        for var i = 0; i < json["errors"].count; i++ {
                            if (i != 0) { self.emptyOrErrorDescription = self.emptyOrErrorDescription! + "\n\n" }
                            self.emptyOrErrorDescription = self.emptyOrErrorDescription! + json["errors"][i].string!
                        }
                    }
                } else {
                    self.emptyOrErrorDescription = "Something went wrong :("
                }
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))

                dispatch_after(delayTime, dispatch_get_main_queue(), {
                    
                    // If infinite scrolling, so loading additional pages, we want to use a toast not replace feed with error message
                    if (page != nil && self.emptyOrErrorDescription != nil) {
                        self.emptyOrErrorDescription = nil
                        self.delegate.spreadToast("Failed to fetch more posts :(")
                    }

                    self.tableView.reloadData()

                    if refreshing {
                        self.currentPage = 2
                    }

                    dispatch_after(delayTime, dispatch_get_main_queue(), {
                        self.refreshControl!.endRefreshing()
                        self.toggleLoadingFooter(false)
                    })

                    self.reachedEndOfCallback = true
                })
            }
        }
    }


    func toggleLoadingFooter(on: Bool) {
        if on {
            let container = UIView(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, 44))

            let loadSpinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
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
            var visibleIndexPaths = self.tableView.indexPathsForVisibleRows as [NSIndexPath]!
            let visibleCount = visibleIndexPaths.count

            //Ensure we don't crash if for some reason the user is scrolling without any active cells.
            if visibleCount == 0 { return }

            // We add one so it plays nicely with posts.count
            let bottomVisiblePost = visibleIndexPaths[visibleCount - 1].row + 1

            if (bottomVisiblePost + infiniteScrollBufferCount >= posts.count) {
                isLoading = true
                reachedEndOfCallback = false
                lastTimeLoading = NSDate()

                toggleLoadingFooter(true)

                requestPostsAndPopulateFeed(false, page: currentPage)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
