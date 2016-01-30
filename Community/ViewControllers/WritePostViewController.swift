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
import Toast

class WritePostViewController: UIViewController, UITextViewDelegate {

    var delegate: UpdateFeedWithLatestPostDelegate!
    
    var navBar: UINavigationBar!
    var rightButtonOptions = [String : UIBarButtonItem]()
    
    var communityName: String!
    var communityKey: String!
    var joinedCommunity: JoinedCommunity?
    
    var request: Alamofire.Request?
    
    @IBOutlet var writePostHolderView: UIView!
    
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var titleField: UITextField!
    @IBOutlet var postTextView: SZTextView!
    
    @IBOutlet var leadingUsernameSuperViewConstraint: NSLayoutConstraint!
    @IBOutlet var leadingUsernameAvatarConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        
        titleField.tintColor = UIColor(hexString: "056A85")
        postTextView.tintColor = UIColor(hexString: "056A85")
        
        let realm = try! Realm()
        joinedCommunity = realm.objectForPrimaryKey(JoinedCommunity.self, key: communityKey)
        
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
            let default_avatar_url = Session.get(.AvatarUrl)
            
            if let potential_avatar_url = default_avatar_url {
                avatar_url = potential_avatar_url
            }
        }
        
        if avatar_url != "" {
            
            self.leadingUsernameAvatarConstraint.priority = 999
            self.leadingUsernameSuperViewConstraint.priority = 500
            self.avatar.alpha = 1.0
            
            avatar.setImageWithURL(
                NSURL(string: avatar_url),
                placeholderImage: UIImage(named: "AvatarPlaceHolder"),
                options: SDWebImageOptions.RetryFailed,
                completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in
                    
                    if let _ = error {
                        self.avatar.image = UIImage(named: "AvatarPlaceHolderError")
                    }
                    
                },
                usingActivityIndicatorStyle: .Gray
            )
        } else {
            self.leadingUsernameAvatarConstraint.priority = 500
            self.leadingUsernameSuperViewConstraint.priority = 999
            self.avatar.alpha = 0.0
        }
    }
    
    func setUsername() {
        
        var username = ""
        
        if let community = joinedCommunity {
            username = community.username
        }
        
        if username == "" {
            username = Session.get(.Username)!
        }
        
        usernameLabel.text = username
    }
    
    func setupNavBar() {
        navBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.bounds.width, 64))
        
        navBar.barTintColor = UIColor.whiteColor()
        navBar.translucent = false
        
        navBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.darkGrayColor() ]
        
        self.view.addSubview(navBar)
        
        let backButton = UIBarButtonItem(image: UIImage(named: "Back"), style: .Plain, target: self, action: Selector("cancel"))
        
        backButton.tintColor = UIColor(hexString: "056A85")
        
        let postButton = UIBarButtonItem(image: UIImage(named: "Message"), style: .Plain, target: self, action: Selector("processPost"))
        postButton.tintColor = UIColor(hexString: "056A85")
        postButton.enabled = false
        
        let loadIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 22, 22))
        loadIndicator.stopAnimating()
        loadIndicator.hidesWhenStopped = true
        loadIndicator.activityIndicatorViewStyle = .Gray

        let loadButton = UIBarButtonItem(customView: loadIndicator)
        
        rightButtonOptions["post"] = postButton
        rightButtonOptions["load"] = loadButton
        
        let navigationItem = UINavigationItem()
        navigationItem.rightBarButtonItem = postButton
        navigationItem.leftBarButtonItem = backButton
        
        navigationItem.title = "Write"
        
        navBar.pushNavigationItem(navigationItem, animated: false)
    }

    func processPost() {
        (rightButtonOptions["load"]!.customView as! UIActivityIndicatorView).startAnimating()
        navBar.topItem!.rightBarButtonItem = rightButtonOptions["load"]
        
        let title: String? = (titleField.text!.strip() == "" ? nil : titleField.text!.strip())
        
        request = Alamofire.request(Router.WritePost(community: communityName.strip(), body: postTextView.text.strip(), title: title))
            .responseJSON { request, response, result in
               
                let defaultError = (result.error as? NSError)?.localizedDescription
                
                if ((response == nil || response?.statusCode > 299) && defaultError != nil) {
                    self.view.makeToast(defaultError!, duration: NSTimeInterval(3), position: CSToastPositionCenter)
                } else if let jsonData: AnyObject = result.value {
                    let json = JSON(jsonData)
                    
                    if (json["error"] != nil) {
                        self.view.makeToast(json["error"].stringValue, duration: NSTimeInterval(3), position: CSToastPositionCenter)
                    } else if (json["errors"] == nil) {
                        var jsonPost = json["post"]
                        
                        let post = Post(id: jsonPost["external_id"].stringValue, username: jsonPost["user"]["username"].stringValue, body: jsonPost["body"].stringValue, title: jsonPost["title"].string, repliesCount: jsonPost["replies_count"].intValue, likeCount: jsonPost["likes"].intValue, liked: jsonPost["liked"].boolValue, timeCreated: jsonPost["created_at"].stringValue, avatarUrl: jsonPost["user"]["avatar_url"].string)
                        
                        self.delegate.updateFeedWithLatestPost(post)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        var errorString = ""
                        
                        for var i = 0; i < json["errors"].count; i++ {
                            if (i != 0) { errorString += "\n\n" }
                            
                            errorString += json["errors"][i].string!
                        }
                        
                        self.view.makeToast(errorString, duration: NSTimeInterval(3), position: CSToastPositionCenter)
                    }
                } else {
                    self.view.makeToast("Something went wrong :(", duration: NSTimeInterval(3), position: CSToastPositionCenter)
                }
                
                self.navBar.topItem!.rightBarButtonItem = self.rightButtonOptions["post"]
                (self.rightButtonOptions["load"]!.customView as! UIActivityIndicatorView).stopAnimating()
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
