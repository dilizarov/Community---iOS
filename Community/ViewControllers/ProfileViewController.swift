//
//  ProfileViewController.swift
//  Community
//
//  Created by David Ilizarov on 8/18/15.
//  Copyright (c) 2015 David Ilizarov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast
import SDWebImage
import UIActivityIndicator_for_SDWebImage
import MMProgressHUD
import RealmSwift
import Sheriff

class ProfileViewController: UIViewController {
    
    enum State {
        case Communities, Notifications, Settings
    }
    
    var currentState = State.Communities
    
    var tableViewController: ProfileTableViewController!
    
    var initialLoad = true
    
    var communitiesError: String?
    var notificationsError: String?

    @IBOutlet var tableHolder: RoundedView!
    @IBOutlet var viewingCommunities: RoundedView!
    @IBOutlet var viewingNotifications: RoundedView!
    @IBOutlet var viewingSettings: RoundedView!
    
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var errorLabel: UILabel!
    
    @IBOutlet var avatarImage: UIImageView!
    var avatarImageError = false
    
    @IBOutlet var communitiesImage: UIImageView!
    @IBOutlet var notificationsImage: UIImageView!
    @IBOutlet var settingsImage: UIImageView!
    
    lazy var badge: GIBadgeView = {
       var badge = GIBadgeView()
        badge.textColor = UIColor.whiteColor()
        badge.backgroundColor = UIColor.lightGrayColor()
        
        return badge
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupAvatarImage()
        setupRoundedViews()
        setDataViewedTapGestures()
        
        notificationsImage.addSubview(badge)
        
        errorLabel.alpha = 0.0
        usernameLabel.text = Session.get(.Username)!
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.badge.badgeValue = UIApplication.sharedApplication().applicationIconBadgeNumber
        NSNotificationCenter.defaultCenter().postNotificationName("sideViewAppeared", object: self)
    }
    
    func setupAvatarImage() {
        self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.height / 2
        self.avatarImage.layer.masksToBounds = true
        self.avatarImage.layer.borderColor = UIColor.whiteColor().CGColor
        self.avatarImage.layer.borderWidth = 1
        self.avatarImage.contentMode = .ScaleAspectFit
        self.avatarImage.clipsToBounds = true
        
        setAvatarImage()
        
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("avatarImagePressed"))
        singleTap.numberOfTapsRequired = 1
        avatarImage.userInteractionEnabled = true
        avatarImage.addGestureRecognizer(singleTap)
    }
    
    func setupRoundedViews() {
        tableHolder.cornersMask = [.TopRight, .TopLeft]

        var viewingIndicators = [viewingCommunities, viewingNotifications, viewingSettings]
        
        for var i = 0; i < viewingIndicators.count; i++ {
            viewingIndicators[i].cornersMask = [.BottomRight, .BottomLeft]
            
            if i != 0 {
                viewingIndicators[i].alpha = 0.0
            }
        }
    }
    
    func setDataViewedTapGestures() {
        // Apparently every single image needs its own UITapGestureRecognizer.
        // Bleh
        
        let communitiesTap = UITapGestureRecognizer(target: self, action: Selector("communitiesImageTapped"))
        communitiesTap.numberOfTapsRequired = 1

        let notificationsTap = UITapGestureRecognizer(target: self, action: Selector("notificationsImageTapped"))
        notificationsTap.numberOfTapsRequired = 1

        let settingsTap = UITapGestureRecognizer(target: self, action: Selector("settingsImageTapped"))
        settingsTap.numberOfTapsRequired = 1
        
        communitiesImage.userInteractionEnabled = true
        notificationsImage.userInteractionEnabled = true
        settingsImage.userInteractionEnabled = true
        
        communitiesImage.addGestureRecognizer(communitiesTap)
        notificationsImage.addGestureRecognizer(notificationsTap)
        settingsImage.addGestureRecognizer(settingsTap)
    }
    
    func setAvatarImage() {
        if let avatar_url = Session.get(.AvatarUrl) {
            
            avatarImage.setImageWithURL(
                NSURL(string: avatar_url),
                placeholderImage: UIImage(named: "AvatarPlaceHolder"),
                options: SDWebImageOptions.RetryFailed,
                completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in
                    if let _ = error {
                        
                        self.view.makeToast("Could not download profile picture", duration: NSTimeInterval(3), position: CSToastPositionCenter)
                        
                        self.avatarImageError = true
                        self.avatarImage.image = UIImage(named: "AvatarPlaceHolderError")
                        self.avatarImage.layer.borderColor = UIColor.redColor().CGColor
                    }
                },
                usingActivityIndicatorStyle: .White
            )
            
        } else {
            avatarImage.image = UIImage(named: "AvatarPlaceHolder")
        }
    }
    
    func avatarImagePressed() {
        if let _ = Session.get(.AvatarUrl) {
            
            if avatarImageError {
                retrySetAvatarImage()
            } else {
                let confirmAlert = UIAlertController(title: "Change Profile Picture", message: "Are you sure you want to change your profile picture?", preferredStyle: .Alert)
                
                let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                let confirm = UIAlertAction(title: "Change", style: .Default, handler: { alert in
                    self.chooseNewProfilePic()
                })
                
                confirmAlert.addAction(cancel)
                confirmAlert.addAction(confirm)
                
                self.presentViewController(confirmAlert, animated: true, completion: nil)
            }
        } else {
            chooseNewProfilePic()
        }
    }
    
    func communitiesImageTapped() {
        
        if currentState == .Communities { return }
        
        self.viewingNotifications.alpha = 0.0
        self.viewingSettings.alpha = 0.0
        self.viewingCommunities.alpha = 1.0
        
        currentState = .Communities
        self.errorLabel.alpha = 0
        
        tableViewController.tableView.reloadData()
        
        if let error = communitiesError {
            self.errorLabel.text = error
            self.errorLabel.alpha = 1
        }

    }
    
    func notificationsImageTapped() {
        if currentState == .Notifications { return }
        
        self.viewingSettings.alpha = 0.0
        self.viewingCommunities.alpha = 0.0
        self.viewingNotifications.alpha = 1.0

        currentState = .Notifications
        self.errorLabel.alpha = 0
        
        tableViewController.tableView.reloadData()
        
        if let error = notificationsError {
            self.errorLabel.text = error
            self.errorLabel.alpha = 1
        }
        
        if (!self.tableViewController.refreshControl!.refreshing && (self.badge.badgeValue > 0 || (self.tableViewController.notifications.count == 0 && notificationsError == nil))) {
            self.tableViewController.beginInitialLoad()
        }
    }
    
    func settingsImageTapped() {
        if currentState == .Settings { return }
        
        self.viewingCommunities.alpha = 0.0
        self.viewingNotifications.alpha = 0.0
        self.viewingSettings.alpha = 1.0
        
        currentState = .Settings
        
        self.errorLabel.alpha = 0
        
        tableViewController.tableView.reloadData()
    }
    
    func retrySetAvatarImage() {
        self.avatarImage.image = UIImage(named: "AvatarPlaceHolder")
        self.avatarImage.layer.borderColor = UIColor.whiteColor().CGColor
        avatarImageError = false
        setAvatarImage()
    }
    
    func handleRefresh() {
        if let _ = Session.get(.AvatarUrl) {
            if avatarImage.tintColor == UIColor.redColor() { retrySetAvatarImage() }
        }
    }
    
    func failureRequestJoinedCommunities(error: String) {
        self.communitiesError = error
        
        if currentState != .Communities {
            communitiesImageTapped()
        } else {
            self.errorLabel.text = error
            self.errorLabel.alpha = 1
        }
    }
    
    func successRequestJoinedCommunities() {
        self.communitiesError = nil
        self.errorLabel.alpha = 0
    }
    
    func failureRequestNotifications(error: String) {
        self.notificationsError = error
        
        if currentState != .Notifications {
            notificationsImageTapped()
        } else {
            self.errorLabel.text = error
            self.errorLabel.alpha = 1
        }
    }
    
    func successRequestNotifications() {
        self.notificationsError = nil
        self.errorLabel.alpha = 0
    }
    
    func resetBadge() {
        dispatch_async(dispatch_get_main_queue()) {
            self.badge.badgeValue = 0
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        }
    }
    
    func spreadToast(string: String) {
        self.view.makeToast(string, duration: NSTimeInterval(3), position: CSToastPositionCenter)
    }
    
    func chooseNewProfilePic() {
        let pickerController = DKImagePickerController()
        pickerController.didCancelled = {}
        
        pickerController.didCropImage =  { [unowned self] (image: UIImage) in
            
            // Ensure that we're uploading a PNG image no larger than 1000x1000.
            let croppedImage = image.imageByScalingAspectFitSize(CGSizeMake(1000, 1000))
            let pngImageData = UIImagePNGRepresentation(croppedImage)
            
            self.uploadImageData(pngImageData!)
        }
        
        pickerController.maxSelectableCount = 1
        pickerController.assetType = .allPhotos
        pickerController.allowMultipleType = false
        
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    func performBackgroundFetch(asyncGroup: dispatch_group_t!) {
        tableViewController.performBackgroundFetch(asyncGroup)
    }
    
    func uploadImageData(imageData: NSData) {
        
        MMProgressHUD.sharedHUD().overlayMode = .Linear
        MMProgressHUD.setPresentationStyle(.Balloon)
        MMProgressHUD.show()
        
        Alamofire.upload(.POST,
            "https://infinite-lake-4056.herokuapp.com/api/v1/users/\(Session.get(.UserId)!)/profile_pic.json?auth_token=\(Session.get(.AuthToken)!)&api_key=\(Router.apiKey)",
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(data: imageData, name: "avatar", fileName: "avatar_img.png", mimeType: "image/png")
            },
            encodingCompletion: { encodingResult in
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                    Int64(1 * Double(NSEC_PER_SEC)))
                
                dispatch_after(delayTime,
                    dispatch_get_main_queue(), {
                        
                        let errorCompletionBlock: (() -> Void) = {
                            
                            let retryAlert = UIAlertController(title: "Could Not Upload Picture", message: nil, preferredStyle: .Alert)
                            
                            let retryAction = UIAlertAction(title: "Retry", style: .Default, handler: { alert in
                                self.uploadImageData(imageData)
                            })
                            
                            let changePicAction = UIAlertAction(title: "Change Picture", style: .Default, handler: { alert in
                                self.chooseNewProfilePic()
                            })
                            
                            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                            
                            retryAlert.addAction(retryAction)
                            retryAlert.addAction(changePicAction)
                            retryAlert.addAction(cancelAction)
                            
                            self.presentViewController(retryAlert, animated: true, completion: nil)
                        }
                        
                        switch encodingResult {
                        case .Success (let upload, _, _):
                            upload.responseJSON { request, response, result in
                                
                                if let defaultError = (result.error as? NSError) {
                                    MMProgressHUD.sharedHUD().dismissAnimationCompletion = errorCompletionBlock
                                    MMProgressHUD.dismissWithError(
                                        defaultError.localizedDescription.removeEndingPunctuationAndMakeLowerCase(),
                                        afterDelay: NSTimeInterval(3)
                                    )
                                } else if let jsonData: AnyObject = result.value {
                                    let json = JSON(jsonData)
                                    
                                    if (json["error"] != nil) {
                                        MMProgressHUD.sharedHUD().dismissAnimationCompletion = errorCompletionBlock
                                        MMProgressHUD.dismissWithError(json["error"].stringValue, afterDelay: NSTimeInterval(3))
                                    } else if (json["errors"] == nil) {
                                        let avatar_url = json["avatar"]["url"].string
                                        let image = UIImage(data: imageData)
                                        
                                        self.avatarImage.image = image
                                        
                                        Session.set(avatar_url!, key: .AvatarUrl)
                                        
                                        SDImageCache.sharedImageCache().storeImage(image, forKey: avatar_url!)
                                        MMProgressHUD.dismissWithSuccess(":)")
                                        
                                        NSNotificationCenter.defaultCenter().postNotificationName("avatarChanged", object: nil)
                                    } else {
                                        var errorString = ""
                                        
                                        for var i = 0; i < json["errors"].count; i++ {
                                            if (i != 0) { errorString += "\n\n" }
                                            
                                            errorString += json["errors"][i].string!
                                        }
                                        
                                        MMProgressHUD.sharedHUD().dismissAnimationCompletion = errorCompletionBlock
                                        MMProgressHUD.dismissWithError(errorString, afterDelay: NSTimeInterval(3))
                                    }
                                } else {
                                    MMProgressHUD.sharedHUD().dismissAnimationCompletion = errorCompletionBlock
                                    MMProgressHUD.dismissWithError("Something went wrong :(", afterDelay: NSTimeInterval(3))
                                }
                            }
                            
                        case .Failure ( _):
                            //Realistically, I don't expect this to ever trigger, but I guess if the user uses some very weird image format...
                            MMProgressHUD.sharedHUD().dismissAnimationCompletion = errorCompletionBlock
                            MMProgressHUD.dismissWithError("Having difficulty with this image :(", afterDelay: NSTimeInterval(3))
                        }
                    }
                )
            }
        )
    }
    
    func processLogOut() {
        MMProgressHUD.sharedHUD().overlayMode = .Linear
        MMProgressHUD.setPresentationStyle(.Balloon)
        MMProgressHUD.show()
        
        Alamofire.request(Router.Logout)
            .responseJSON { request, response, result in
                // We delay by 1 second to keep a very smooth animation.
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                
                dispatch_after(delayTime, dispatch_get_main_queue(), {
                    let defaultError = (result.error as? NSError)?.localizedDescription
                    
                    if ((response == nil || response?.statusCode > 299) && defaultError != nil) {
                        MMProgressHUD.dismissWithError(defaultError?.removeEndingPunctuationAndMakeLowerCase(), afterDelay: NSTimeInterval(3))
                    } else if let jsonData: AnyObject = result.value {
                        let json = JSON(jsonData)
                        
                        if (json["error"] != nil) {
                            MMProgressHUD.dismissWithError(json["error"].stringValue, afterDelay: NSTimeInterval(3))
                        } else if (json["errors"] != nil) {
                            var errorString = ""
                            
                            for var i = 0; i < json["errors"].count; i++ {
                                if (i != 0) { errorString += "\n\n" }
                                
                                errorString += json["errors"][i].string!
                            }
                            
                            MMProgressHUD.dismissWithError(errorString, afterDelay: NSTimeInterval(3))
                        }
                    } else {
                        Session.logout()
                        MMProgressHUD.sharedHUD().dismissAnimationCompletion = {
                            
                            self.tableViewController.communities = []
                            self.tableViewController.notifications = []
                            self.communitiesImageTapped()
                            self.tableViewController.tableView.setContentOffset(CGPointZero, animated: false)
                            self.setAvatarImage()
                            self.usernameLabel.text = Session.get(.Username)!
                            self.tableViewController.beginInitialLoad()
                            
                            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            delegate.configureRealm()
                            
                            let centerNC = delegate.drawerController!.centerViewController as! UINavigationController
                            
                            centerNC.popToRootViewControllerAnimated(false)
                            (centerNC.topViewController as! SearchViewController).setAvatar()
                        }
                        
                        MMProgressHUD.dismissWithSuccess(":)")
                    }
                })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "profileEmbedTVC" {
            tableViewController = segue.destinationViewController as! ProfileTableViewController
            tableViewController.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
