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

class SearchViewController: UIViewController, UITextFieldDelegate {

    // Dictates whether or not we have a NSNotification Observer viewing this
    var observingSideViewAppeared: Bool = false
    var observingCommunitySelected: Bool = false
    var observingAvatarChanged: Bool = false
    
    // This view only disappears when we view CommunityViewController. We use this toggle
    // to re-add the leftViewController to drawerController to ensure that it isn't black.
    var viewDisappeared: Bool = false
    var avatarImageError = false
    
    @IBOutlet var search: UITextField!
    @IBOutlet var avatar: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchLook()
        setupAvatar()
        setAvatar()
    }
    
    func setupSearchLook() {
        search.layer.masksToBounds = false
        search.layer.cornerRadius = 8
        search.layer.shadowOffset = CGSizeMake(0, 5)
        search.layer.shadowRadius = 5
        search.layer.shadowOpacity = 0.4
        search.tintColor = UIColor.whiteColor()
        
        search.delegate = self
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
        
        if let avatar_url = NSUserDefaults.standardUserDefaults().objectForKey("avatar_url") as? String {
            
            avatar.setImageWithURL(
                NSURL(string: avatar_url),
                placeholderImage: UIImage(named: "AvatarPlaceHolderGray"),
                options: SDWebImageOptions.RetryFailed,
                completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in
                    if let actualError = error {
                        
                        self.avatarImageError = true
                        self.avatar.image = UIImage(named: "AvatarPlaceHolderError")
                    }
                },
                usingActivityIndicatorStyle: .White
            )
            
        } else {
            avatar.image = UIImage(named: "AvatarPlaceHolderGray")
        }

    }
    
    func avatarPressed() {
        if avatarImageError {
            avatarImageError = false
            setAvatar()
        }
        
        var delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        delegate.drawerController?.openDrawerSide(.Left, animated: true, completion: nil)
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
    
    func resignSearchKeyboard() {
        search.resignFirstResponder()
    }
    
    func communitySelected(notification: NSNotification) {
        if let info = notification.userInfo as? Dictionary<String, String> {
            if let community = info["community"] {
                
                goToCommunityVC(community, animated: false)
                
                (UIApplication.sharedApplication().delegate as! AppDelegate).drawerController?.closeDrawerAnimated(true, completion: nil)
            }
        }
    }

    func search(community: String) {
        goToCommunityVC(community, animated: true)
    }
    
    func goToCommunityVC(community: String, animated: Bool) {

        var communityVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CommunityCopyViewController") as! CommunityViewController
        
        communityVC.communityTitle = community
        
        self.navigationController?.pushViewController(communityVC, animated: animated)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        search(textField.text)
        
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

