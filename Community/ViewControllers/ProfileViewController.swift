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

class ProfileViewController: UIViewController, ProfileTableDelegate {
    
    var tableViewController: ProfileTableViewController!
    
    var communities = [JoinedCommunity]()
    
    var initialLoad = true

    //We use a table holder to get past some
    //rounded corner issues that happen when
    //applying rounded corners directly to
    //the table
    @IBOutlet var tableHolder: UIView!
    
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var errorLabel: UILabel!
    
    @IBOutlet var avatarImage: UIImageView!
    
    @IBOutlet var leftButton: UIButton!
    @IBAction func leftButtonPressed(sender: AnyObject) {
        println("Communities")
//        notifs = false
//        communitiesTable.setContentOffset(CGPointZero, animated: false)
//        communitiesTable.reloadData()
    }
    
    @IBOutlet var notifications: UIButton!
    @IBAction func notificationsButtonPressed(sender: AnyObject) {
        println("Notifs")
//        notifs = true
//        communitiesTable.setContentOffset(CGPointZero, animated: false)
//        
//        communitiesTable.reloadData()
    }
    
    @IBOutlet var settings: UIButton!
    @IBAction func settingsPressed(sender: AnyObject) {
        println("Settings")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        giveTableViewRoundedTopCorners()
        setupAvatarImage()
        
        errorLabel.alpha = 0.0
        
        usernameLabel.text = (NSUserDefaults.standardUserDefaults().objectForKey("username") as! String)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        NSNotificationCenter.defaultCenter().postNotificationName("sideViewAppeared", object: self)
    }
    
    func giveTableViewRoundedTopCorners() {
        var maskPath = UIBezierPath(roundedRect: tableHolder.bounds, byRoundingCorners: UIRectCorner.TopLeft | UIRectCorner.TopRight, cornerRadii: CGSizeMake(5.0, 5.0))
        
        var maskLayer = CAShapeLayer()
        maskLayer.frame = tableHolder.bounds
        maskLayer.path = maskPath.CGPath
        
        tableHolder.layer.mask = maskLayer
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
    
    func setAvatarImage() {
        if let avatar_url = NSUserDefaults.standardUserDefaults().objectForKey("avatar_url") as? String {
            
            avatarImage.setImageWithURL(
                NSURL(string: avatar_url),
                placeholderImage: UIImage(named: "AvatarPlaceHolder"),
                options: SDWebImageOptions.RetryFailed,
                completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in
                    if let actualError = error {
                        
                        self.view.makeToast("Could not download profile picture", duration: NSTimeInterval(3), position: CSToastPositionCenter)
                        
                        self.avatarImage.image = self.avatarImage.image?.imageWithRenderingMode(.AlwaysTemplate)
                        
                        self.avatarImage.tintColor = UIColor.redColor()
                        self.avatarImage.layer.borderColor = UIColor.redColor().CGColor
                        self.avatarImage.alpha = 0.4
                    }
                },
                usingActivityIndicatorStyle: .Gray
            )
            
        } else {
            avatarImage.image = UIImage(named: "AvatarPlaceHolder")
        }
        
    }
    
    func avatarImagePressed() {
        if let avatar_url = NSUserDefaults.standardUserDefaults().objectForKey("avatar_url") as? String {
            
            if avatarImage.tintColor == UIColor.redColor() {
                retrySetAvatarImage()
            } else {
                var confirmAlert = UIAlertController(title: "Change Profile Picture", message: "Are you sure you want to change your profile picture?", preferredStyle: .Alert)
                
                var cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                var confirm = UIAlertAction(title: "Change", style: .Default, handler: { alert in
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
    
    func retrySetAvatarImage() {
        self.avatarImage.image = self.avatarImage.image?.imageWithRenderingMode(.AlwaysOriginal)
        self.avatarImage.tintColor = UIColor.whiteColor()
        self.avatarImage.layer.borderColor = UIColor.whiteColor().CGColor
        self.avatarImage.alpha = 1.0
        setAvatarImage()
    }
    
    func handleRefresh() {
        if let avatar_url = NSUserDefaults.standardUserDefaults().objectForKey("avatar_url") as? String {
            if avatarImage.tintColor == UIColor.redColor() { retrySetAvatarImage() }
        }
    }
    
    func failureRequestJoinedCommunities(error: String) {
        self.errorLabel.text = error
        self.errorLabel.alpha = 1
    }
    
    func successRequestJoinedCommunities() {
        self.errorLabel.alpha = 0
    }
    
    func spreadToast(string: String) {
        self.view.makeToast(string, duration: NSTimeInterval(3), position: CSToastPositionCenter)
    }
    
    func chooseNewProfilePic() {
        let pickerController = DKImagePickerController()
        pickerController.didCancelled = {}
        
        pickerController.didCropImage =  { [unowned self] (image: UIImage) in
            
            // Ensure that we're uploading a PNG image no larger than 1000x1000.
            var croppedImage = image.imageByScalingAspectFitSize(CGSizeMake(1000, 1000))
            var pngImageData = UIImagePNGRepresentation(croppedImage)
            
            self.uploadImageData(pngImageData)
        }
        
        pickerController.maxSelectableCount = 1
        pickerController.assetType = .allPhotos
        pickerController.allowMultipleType = false
        
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    func uploadImageData(imageData: NSData) {
        
        MMProgressHUD.sharedHUD().overlayMode = .Linear
        MMProgressHUD.setPresentationStyle(.Balloon)
        MMProgressHUD.show()
        
        var userInfo = NSUserDefaults.standardUserDefaults()
        
        var user_id    = userInfo.objectForKey("user_id") as! String
        var auth_token = userInfo.objectForKey("auth_token") as! String
        
        Alamofire.upload(.POST,
            URLString: "https://infinite-lake-4056.herokuapp.com/api/v1/users/\(user_id)/profile_pic.json?auth_token=\(auth_token)",
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(data: imageData, name: "avatar", fileName: "avatar_img.png", mimeType: "image/png")
            },
            encodingCompletion: { encodingResult in
                
                var delayTime = dispatch_time(DISPATCH_TIME_NOW,
                    Int64(1 * Double(NSEC_PER_SEC)))
                
                dispatch_after(delayTime,
                    dispatch_get_main_queue(), {
                        switch encodingResult {
                        case .Success (let upload, _, _):
                            upload.responseJSON { request, response, data, error in
                                
                                var errorCompletionBlock: (() -> Void) = {
                                    var retryAlert = UIAlertController(title: "Could Not Upload Picture", message: nil, preferredStyle: .Alert)
                                    
                                    var retryAction = UIAlertAction(title: "Retry", style: .Default, handler: { alert in
                                        self.uploadImageData(imageData)
                                    })
                                    
                                    var changePicAction = UIAlertAction(title: "Change Picture", style: .Default, handler: { alert in
                                        self.chooseNewProfilePic()
                                    })
                                    
                                    var cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                                    
                                    retryAlert.addAction(retryAction)
                                    retryAlert.addAction(changePicAction)
                                    retryAlert.addAction(cancelAction)
                                    
                                    self.presentViewController(retryAlert, animated: true, completion: nil)
                                }
                                
                                
                                if let defaultError = error {
                                    MMProgressHUD.sharedHUD().dismissAnimationCompletion = errorCompletionBlock
                                    MMProgressHUD.dismissWithError(
                                        defaultError.localizedDescription.removeEndingPunctuationAndMakeLowerCase(),
                                        afterDelay: NSTimeInterval(3)
                                    )
                                } else if let jsonData: AnyObject = data {
                                    let json = JSON(jsonData)
                                    
                                    if (json["errors"] == nil) {
                                        var avatar_url = json["avatar"]["url"].string
                                        var image = UIImage(data: imageData)
                                        
                                        self.avatarImage.image = image
                                        
                                        userInfo.setObject(avatar_url, forKey: "avatar_url")
                                        SDImageCache.sharedImageCache().storeImage(image, forKey: avatar_url!)
                                        MMProgressHUD.dismissWithSuccess(":)")
                                    } else {
                                        var errorString = ""
                                        
                                        for var i = 0; i < json["errors"].count; i++ {
                                            if (i != 0) { errorString += "\n\n" }
                                            
                                            errorString += json["errors"][i].string!
                                        }
                                        
                                        MMProgressHUD.sharedHUD().dismissAnimationCompletion = errorCompletionBlock
                                        MMProgressHUD.dismissWithError(errorString, afterDelay: NSTimeInterval(3))
                                    }
                                }
                            }
                            
                        case .Failure (let encodingError):
                            //Realistically, I don't expect this to ever trigger, but I guess if the user uses some very weird image format...
                            //But yeah, should never trigger.
                            MMProgressHUD.dismissWithError("Having difficulty with this image :(", afterDelay: NSTimeInterval(3))
                        }
                    }
                )
            }
        )
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
