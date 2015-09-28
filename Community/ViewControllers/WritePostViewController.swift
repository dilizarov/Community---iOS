//
//  WritePostViewController.swift
//  
//
//  Created by David Ilizarov on 9/10/15.
//
//

import UIKit
import SZTextView
import HexColors
import SDWebImage
import UIActivityIndicator_for_SDWebImage
import Alamofire
import SwiftyJSON
import RealmSwift

class WritePostViewController: UIViewController, UITextViewDelegate {

    var delegate: UpdateFeedWithLatestPostDelegate!
    
    var navBar: UINavigationBar!
    var rightButtonOptions = [String : UIBarButtonItem]()
    
    var communityName: String!
    var joinedCommunity: JoinedCommunity?
    
    var request: Alamofire.Request?
    
    @IBOutlet var writePostHolderView: UIView!
    
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var titleField: UITextField!
    @IBOutlet var postTextView: SZTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        
        let realm = Realm()
        joinedCommunity = realm.objectForPrimaryKey(JoinedCommunity.self, key: communityName)
        
        setAvatar()
        setUsername()
        
        self.writePostHolderView.layer.masksToBounds = false
        self.writePostHolderView.layer.cornerRadius = 5.0
        
        self.postTextView.delegate = self
        
        self.postTextView.becomeFirstResponder()
    }
    
    func setAvatar() {
        self.avatar.layer.cornerRadius = self.avatar.frame.size.height / 2
        self.avatar.layer.masksToBounds = true
        self.avatar.contentMode = .ScaleAspectFit
        self.avatar.clipsToBounds = true
        
        var avatar_url = ""
        
        if let community = joinedCommunity {
            avatar_url = community.avatar_url
        }
        
        if avatar_url == "" {
            var default_avatar_url = NSUserDefaults.standardUserDefaults().objectForKey("avatar_url") as? String
            
            if let potential_avatar_url = default_avatar_url {
                avatar_url = potential_avatar_url
            }
        }
        
        if avatar_url != "" {
            
            avatar.setImageWithURL(
                NSURL(string: avatar_url),
                placeholderImage: UIImage(named: "AvatarPlaceHolder"),
                options: SDWebImageOptions.RetryFailed,
                completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in
                    if let actualError = error {
                        // Don't do anything.
                    }
                },
                usingActivityIndicatorStyle: .Gray
            )
        }
    }
    
    func setUsername() {
        
        var username = ""
        
        if let community = joinedCommunity {
            username = community.username
        }
        
        if username == "" {
            username = NSUserDefaults.standardUserDefaults().objectForKey("username") as! String
        }
        
        usernameLabel.text = username
    }
    
    func setupNavBar() {
        navBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.bounds.width, 64))
        
        navBar.barTintColor = UIColor.whiteColor()
        navBar.translucent = false
        
        navBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.darkGrayColor() ]
        
        self.view.addSubview(navBar)
        
        var backButton = UIBarButtonItem(image: UIImage(named: "Back"), style: .Plain, target: self, action: Selector("cancel"))
        
        backButton.tintColor = UIColor(hexString: "056A85")
        
        var postButton = UIBarButtonItem(image: UIImage(named: "Message"), style: .Plain, target: self, action: Selector("processPost"))
        postButton.tintColor = UIColor(hexString: "056A85")
        postButton.enabled = false
        
        var loadIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 22, 22))
        loadIndicator.stopAnimating()
        loadIndicator.hidesWhenStopped = true
        loadIndicator.activityIndicatorViewStyle = .Gray

        var loadButton = UIBarButtonItem(customView: loadIndicator)
        
        rightButtonOptions["post"] = postButton
        rightButtonOptions["load"] = loadButton
        
        var navigationItem = UINavigationItem()
        navigationItem.rightBarButtonItem = postButton
        navigationItem.leftBarButtonItem = backButton
        
        navigationItem.title = "Write"
        
        navBar.pushNavigationItem(navigationItem, animated: false)
    }

    func processPost() {
        (rightButtonOptions["load"]!.customView as! UIActivityIndicatorView).startAnimating()
        navBar.topItem!.rightBarButtonItem = rightButtonOptions["load"]
        
        var userInfo = NSUserDefaults.standardUserDefaults()
        
        var params = [String: AnyObject]()
        params["auth_token"] = userInfo.objectForKey("auth_token") as! String
        params["user_id"] = userInfo.objectForKey("user_id") as! String
        
        var post : [String: AnyObject] = [ "body" : postTextView.text.strip(), "community" : communityName.strip()]
        
        if (titleField.text != "") {
            post["title"] = titleField.text.strip()
        }
        
        params["post"] = post
        
        request = Alamofire.request(.POST, "https://infinite-lake-4056.herokuapp.com/api/v1/posts.json", parameters: params, encoding: .JSON)
            .responseJSON { request, response, jsonData, errors in
                var defaultError = errors?.localizedDescription
                
                if (defaultError != nil) {
                
                } else if let jsonData: AnyObject = jsonData {
                    let json = JSON(jsonData)
                                    
                    if (json["errors"] == nil) {
                        var jsonPost = json["post"]
                        
                        var post = Post(id: jsonPost["external_id"].stringValue, username: jsonPost["user"]["username"].stringValue, body: jsonPost["body"].stringValue, title: jsonPost["title"].string, repliesCount: jsonPost["replies_count"].intValue, likeCount: jsonPost["likes"].intValue, liked: jsonPost["liked"].boolValue, timeCreated: jsonPost["created_at"].stringValue, avatarUrl: jsonPost["user"]["avatar_url"].string)
                        
                        self.delegate.updateFeedWithLatestPost(post)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        
                    }
                } else {
                    
                }
            }
    }
    
    func cancel() {
        self.request?.cancel()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textViewDidChange(textView: UITextView) {
        if (NSString(string: textView.text.strip()).length > 0) {
            rightButtonOptions["post"]?.enabled = true
        } else {
            rightButtonOptions["post"]?.enabled = false
        }
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
