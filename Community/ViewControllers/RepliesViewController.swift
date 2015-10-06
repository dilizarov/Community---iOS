//
//  RepliesViewController.swift
//  
//
//  Created by David Ilizarov on 9/18/15.
//
//

import UIKit
import SDWebImage
import UIActivityIndicator_for_SDWebImage
import Alamofire
import SwiftyJSON
import IQKeyboardManagerSwift
import Toast

class RepliesViewController: UIViewController, PHFComposeBarViewDelegate, RepliesTableDelegate {

    @IBOutlet var containerView: ContainerView!
    
    lazy var loadIndicator: UIActivityIndicatorView = {
        
       var loadIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        loadIndicator.hidesWhenStopped = true
        loadIndicator.center = self.view.center
        
        self.view.addSubview(loadIndicator)
        return loadIndicator
    }()
    
    var request: Alamofire.Request?
    
    lazy var composeBarView: PHFComposeBarView = {
        var viewBounds = self.view
        var frame = CGRectMake(0, viewBounds.frame.height - PHFComposeBarViewInitialHeight, viewBounds.frame.width, PHFComposeBarViewInitialHeight)
        
        var composeBarView = PHFComposeBarView(frame: frame)
        
        composeBarView.maxLinesCount = 6
        composeBarView.placeholder = "Write some text"
        composeBarView.buttonTitle = "Reply"
        composeBarView.delegate = self
        
        composeBarView.buttonTintColor = UIColor(hexString: "056A85")
        composeBarView.textView.tintColor = UIColor(hexString: "056A85")
        composeBarView.textView.backgroundColor = UIColor.whiteColor()
        
        return composeBarView
    }()
    
    override var inputAccessoryView: UIView {
        return self.containerView.customInputView
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    var post: Post!
    var tableViewController: RepliesTableViewController!
    
    var navBar: UINavigationBar!
    var rightButtonOptions = [String: UIBarButtonItem]()
    
    @IBOutlet var tableHolder: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.containerView.customInputView = self.composeBarView
        
        setupNavBar()
        
        var tapGesture = UITapGestureRecognizer(target: self, action: "keyboardDisappear")
        tapGesture.numberOfTapsRequired = 1
        
        self.containerView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // We need to disable the IQKeyboardManager because we use our own implementation on the inputAccessoryView
        IQKeyboardManager.sharedManager().enable = false
        
        if !loadIndicator.isAnimating() && navBar.topItem!.rightBarButtonItem != rightButtonOptions["load"] {
            tableViewController.tableView.reloadData()
        }
    }
    
    func keyboardDisappear() {
        self.containerView.customInputView.resignFirstResponder()
    }
    
    func setupNavBar() {
        navBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.bounds.width, 64))
        
        navBar.barTintColor = UIColor.whiteColor()
        navBar.translucent = false
        
        navBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.darkGrayColor() ]
        
        self.view.addSubview(navBar)
        
        var backButton = UIBarButtonItem(image: UIImage(named: "Back"), style: .Plain, target: self, action: Selector("back"))
        
        backButton.tintColor = UIColor(hexString: "056A85")
        
        var refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: Selector("refresh"))
        
        refreshButton.tintColor = UIColor(hexString: "056A85")
        refreshButton.enabled = true
        
        var loadIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 22, 22))
        loadIndicator.stopAnimating()
        loadIndicator.hidesWhenStopped = true
        loadIndicator.activityIndicatorViewStyle = .Gray
        
        var loadButton = UIBarButtonItem(customView: loadIndicator)
        
        rightButtonOptions["refresh"] = refreshButton
        rightButtonOptions["load"] = loadButton
        
        var navigationItem = UINavigationItem()
        navigationItem.rightBarButtonItem = refreshButton
        navigationItem.leftBarButtonItem = backButton
        
        navigationItem.title = "Replies"
        
        navBar.pushNavigationItem(navigationItem, animated: false)
    }
    
    func composeBarViewDidPressButton(composeBarView: PHFComposeBarView!) {
        
        composeBarView.startLoading();
        
        composeBarView.enabled = false
        
        request = Alamofire.request(Router.WriteReply(post_id: post.id, body: composeBarView.text.strip()))
            .responseJSON { request, response, jsonData, errors in
                
                self.composeBarView.enabled = true
                var defaultError = errors?.localizedDescription
                
                if (defaultError != nil) {
                    self.composeBarView.stopLoading()
                    self.view.makeToast(defaultError!, duration: NSTimeInterval(3), position: CSToastPositionCenter)
                } else if let jsonData: AnyObject = jsonData {
                    let json = JSON(jsonData)
                    
                    if (json["error"] != nil) {
                        self.composeBarView.stopLoading()
                        self.view.makeToast(json["error"].stringValue, duration: NSTimeInterval(3), position: CSToastPositionCenter)
                    } else if (json["errors"] == nil) {
                        var jsonReply = json["reply"]
                        
                        var reply = Reply(id: jsonReply["external_id"].stringValue, username: jsonReply["user"]["username"].stringValue, body: jsonReply["body"].stringValue, likeCount: jsonReply["likes"].intValue, liked: jsonReply["liked"].boolValue, timeCreated: jsonReply["created_at"].stringValue, avatarUrl: jsonReply["user"]["avatar_url"].string)
                        
                        self.post.repliesCount += 1
                        
                        self.tableViewController.replies.append(reply)
                        self.tableViewController.emptyOrErrorDescription = nil
                        self.tableViewController.tableView.reloadData()
                        
                        let delay = 0.2 * Double(NSEC_PER_SEC)
                        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                        
                        dispatch_after(time, dispatch_get_main_queue(), {
                            self.tableViewController.scrollToBottom()
                            self.composeBarView.text = ""
                            self.composeBarView.stopLoading()
                        })
                    } else {
                        var errorString = ""
                        
                        for var i = 0; i < json["errors"].count; i++ {
                            if (i != 0) { errorString += "\n\n" }
                            
                            errorString += json["errors"][i].string!
                        }

                        self.composeBarView.stopLoading()
                        self.view.makeToast(errorString, duration: NSTimeInterval(3), position: CSToastPositionCenter)
                    }
                } else {
                    self.composeBarView.stopLoading()
                    self.view.makeToast("Something went wrong :(", duration: NSTimeInterval(3), position: CSToastPositionCenter)
                }
        }
    }
    
    func performBackgroundFetch(asyncGroup: dispatch_group_t!) {
        tableViewController.performBackgroundFetch(asyncGroup)
    }
    
    func refresh() {
        
        (rightButtonOptions["load"]!.customView as! UIActivityIndicatorView).startAnimating()
        navBar.topItem!.rightBarButtonItem = rightButtonOptions["load"]
        
        self.tableViewController.requestRepliesAndPopulateFeed(true)
    }
    
    func startLoading() {
        tableViewController.tableView.alpha = 0.0
        loadIndicator.startAnimating()
    }
    
    func stopLoading() {
        tableViewController.tableView.alpha = 1.0
        loadIndicator.stopAnimating()
    }
    
    func stopRefreshing() {
        self.navBar.topItem!.rightBarButtonItem = self.rightButtonOptions["refresh"]
        
        (self.rightButtonOptions["load"]!.customView as! UIActivityIndicatorView).stopAnimating()
    }
    
    func back() {
        self.request?.cancel()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "repliesEmbedTVC" {
            tableViewController = segue.destinationViewController as! RepliesTableViewController
            
            tableViewController.post = post
            tableViewController.delegate = self
            
        }
    }
    

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.sharedManager().enable = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
