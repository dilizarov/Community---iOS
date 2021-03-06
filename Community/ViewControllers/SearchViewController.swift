//
//  SearchController.swift
//  Community
//
//  Created by David Ilizarov on 8/17/15.
//  Copyright (c) 2015 David Ilizarov. All rights reserved.
//

import UIKit
import SDWebImage
import UIActivityIndicator_for_SDWebImage
import UITextField_Shake

class SearchViewController: UIViewController, UITextFieldDelegate, AvatarChangedAlertDelegate {

    // Crappy quick solution to getting stuff across to other VCs.
    var headingToCommunity: String?
    var communityKey: String?
    // Handles propogation for notifications.
    var postId: String?
    
    // Dictates whether or not we have a NSNotification Observer viewing this
    var observingSideViewAppeared: Bool = false
    var observingCommunitySelected: Bool = false
    var observingAvatarChanged: Bool = false
    
    // This view only disappears when we view CommunityViewController. We use this toggle
    // to re-add the leftViewController to drawerController to ensure that it isn't black.
    var viewDisappeared: Bool = false
    var avatarImageError = false
    
    var firstAppearance: Bool = true
    
    @IBOutlet var communityLabel: UILabel!
    @IBOutlet var search: UITextField!
    @IBOutlet var avatar: UIImageView!
    
    var originalFrame: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        search.alpha = 0
        search.delegate = self
        
        search.keyboardDistanceFromTextField = 130
        
        setupAvatar()
        setAvatar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (viewDisappeared) {
            viewDisappeared = false
        }
        
        if (!observingAvatarChanged) {
            observingAvatarChanged = true
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("setAvatar"), name: "avatarChanged", object: nil)
        }
        
        // This handles removing the keyboard if it is up when one wants to view the side view.
        if (!observingSideViewAppeared) {
            observingSideViewAppeared = true
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("resignSearchKeyboard"), name: "sideViewAppeared", object: nil)
        }
        
        // This handles if community was selected in side view
        if (!observingCommunitySelected) {
            observingCommunitySelected = true
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("communitySelected:"), name: "communitySelected", object: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        originalFrame = communityLabel.frame
        communityLabel.center = self.view.center
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstAppearance {
            firstAppearance = false
            UIView.animateWithDuration(0.25, delay: 0, options: [UIViewAnimationOptions.CurveEaseIn, UIViewAnimationOptions.BeginFromCurrentState], animations: {
                
                let deltaY = self.originalFrame.origin.y - self.communityLabel.frame.origin.y
                self.communityLabel.transform = CGAffineTransformMakeTranslation(0, deltaY)
                self.search.alpha = 1
                
                }, completion: nil)
        }
        
        if headingToCommunity != nil {
            search.text = headingToCommunity
            search(headingToCommunity!)
            headingToCommunity = nil
        }
    }
    
    func setupAvatar() {
        avatar.layer.cornerRadius = self.avatar.frame.size.height / 2
        avatar.layer.masksToBounds = true
        avatar.contentMode = .ScaleAspectFit
        avatar.clipsToBounds = true
        
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("avatarPressed"))
        singleTap.numberOfTapsRequired = 1
        avatar.userInteractionEnabled = true
        avatar.addGestureRecognizer(singleTap)
    }
    
    func setAvatar() {
        avatar.sd_cancelCurrentImageLoad()
        
        if let avatar_url = Session.get(.AvatarUrl) {
            
            avatar.setImageWithURL(
                NSURL(string: avatar_url),
                placeholderImage: UIImage(named: "AvatarPlaceHolderGray"),
                options: SDWebImageOptions.RetryFailed,
                completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in
                    
                    if let _ = error {
                        self.avatarImageError = true
                        self.avatar.image = UIImage(named: "AvatarPlaceHolderError")
                    }
                    
                },
                usingActivityIndicatorStyle: .Gray
            )
            
        } else {
            avatar.image = UIImage(named: "AvatarPlaceHolderGray")
        }

    }
    
    func avatarChanged() {
        setAvatar()
    }
    
    func avatarPressed() {
        if avatarImageError {
            avatarImageError = false
            setAvatar()
        }
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        delegate.drawerController?.openDrawerSide(.Left, animated: true, completion: nil)
    }
    
    func resignSearchKeyboard() {
        search.resignFirstResponder()
    }
    
    func communitySelected(notification: NSNotification) {
        if let info = notification.userInfo as? Dictionary<String, String> {
            if let community = info["community"] {
                
                self.postId = info["postId"]
                self.communityKey = info["normalized_name"]
                
                goToCommunityVC(community, animated: false)
                
                (UIApplication.sharedApplication().delegate as! AppDelegate).drawerController?.closeDrawerAnimated(true, completion: nil)
            }
        }
    }

    func search(community: String) {
        // Fake key to best of my ability because... assumes we keep this consistent with server-side. Need better solution.
        communityKey = community.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: "", options: .LiteralSearch, range: nil)
        goToCommunityVC(community, animated: true)
    }
    
    func goToCommunityVC(community: String, animated: Bool) {

        let communityVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CommunityViewController") as! CommunityViewController

        communityVC.communityTitle = community
        communityVC.postId = postId
        communityVC.communityKey = communityKey
        communityVC.delegate = self
        
        communityKey = nil
        postId = nil
        
        self.navigationController?.pushViewController(communityVC, animated: animated)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        let searchString: String = textField.text!.strip()
        
        let length = NSString(string: searchString).length
        
        if length == 0 {
            textField.shake()
        } else if searchString[0] == "&" && length != 1 {
            search(searchString[Range<Int>(start: 1, end: length)].strip())
        } else {
            search(searchString)
        }
        
        return false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewDisappeared = true
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "avatarChanged", object: nil)
        observingAvatarChanged = false
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "sideViewAppeared", object: nil)
        observingSideViewAppeared = false
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "communitySelected", object: nil)
        observingCommunitySelected = false
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "avatarChanged", object: nil)
        observingAvatarChanged = false
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "sideViewAppeared", object: nil)
        observingSideViewAppeared = false
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "communitySelected", object: nil)
        observingCommunitySelected = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

