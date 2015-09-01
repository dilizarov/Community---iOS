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
import DKImagePickerController
import SDWebImage
import UIActivityIndicator_for_SDWebImage
import MMProgressHUD


class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PresentControllerDelegate, LeaveCommunityDelegate {

    var refreshControl: UIRefreshControl!
    
    var communities = [NSString]()
    var communities2 = [NSString]()
    var notifs = false
    
    //We use a table holder to get past some
    //rounded corner issues that happen when 
    //applying rounded corners directly to
    //the table
    @IBOutlet var tableHolder: UIView!
    @IBOutlet var communitiesTable: UITableView!
    
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var errorLabel: UILabel!
    
    @IBOutlet var avatarImage: UIImageView!

    
    @IBOutlet var leftButton: UIButton!
    @IBAction func leftButtonPressed(sender: AnyObject) {
        notifs = false
        communitiesTable.setContentOffset(CGPointZero, animated: false)
        communitiesTable.reloadData()
    }
    
    @IBOutlet var notifications: UIButton!
    @IBAction func notificationsButtonPressed(sender: AnyObject) {
        
        notifs = true
        communitiesTable.setContentOffset(CGPointZero, animated: false)

        communitiesTable.reloadData()
    }
    
    @IBOutlet var settings: UIButton!
    @IBAction func settingsPressed(sender: AnyObject) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        giveTableViewRoundedTopLeftCorner()
        setRunTimeTableViewParams()
        setupAvatarImage()
        
        errorLabel.alpha = 0.0
        
        setupRefreshControl()
        
        usernameLabel.text = (NSUserDefaults.standardUserDefaults().objectForKey("username") as! String)
        
        //communities2 = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u"]
        startLoading()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        NSNotificationCenter.defaultCenter().postNotificationName("sideViewAppeared", object: self)
    }
    
    func giveTableViewRoundedTopLeftCorner() {
        var maskPath = UIBezierPath(roundedRect: tableHolder.bounds, byRoundingCorners: UIRectCorner.TopLeft, cornerRadii: CGSizeMake(5.0, 5.0))
        
        var maskLayer = CAShapeLayer()
        maskLayer.frame = tableHolder.bounds
        maskLayer.path = maskPath.CGPath
        
        tableHolder.layer.mask = maskLayer
    }
    
    func setRunTimeTableViewParams() {
        communitiesTable.tableHeaderView = UIView(frame: CGRectMake(0, 0, 0, 30))
        communitiesTable.tableFooterView = UIView(frame: CGRectZero)
        communitiesTable.rowHeight = UITableViewAutomaticDimension
        communitiesTable.estimatedRowHeight = 64 // Doesn't have to be accurate, just used 64.
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("handleRefresh"), forControlEvents: .ValueChanged)
        communitiesTable.addSubview(refreshControl)
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
        
        requestJoinedCommunitiesAndPopulateList()
    }
    
    func requestJoinedCommunitiesAndPopulateList() {
        
        var userInfo = NSUserDefaults.standardUserDefaults()
        
        var params = [String : AnyObject]()
        
        params["user_id"] = userInfo.objectForKey("user_id") as! String
        params["auth_token"] = userInfo.objectForKey("auth_token") as! String
        
        Alamofire.request(.GET, "https://infinite-lake-4056.herokuapp.com/api/v1/communities.json", parameters: params)
            .responseJSON { request, response, jsonData, errors in
                
                var defaultError = errors?.localizedDescription
                
                if (defaultError != nil) {
                    self.errorLabel.text = defaultError?.removeEndingPunctuationAndMakeLowerCase()
                    self.errorLabel.alpha = 1
                } else if let jsonData: AnyObject = jsonData {
                    let json = JSON(jsonData)
                    
                    if (json["errors"] == nil) {
                        self.communities = []
                        for var i = 0; i < json["communities"].count; i++ {
                            self.communities.append(json["communities"][i]["name"].string!)
                        }
                        
                        self.errorLabel.alpha = 0
                        self.communitiesTable.reloadData()
                    } else {
                        var errorString = ""
                        
                        for var i = 0; i < json["errors"].count; i++ {
                            if (i != 0) { errorString += "\n\n" }
                            
                            errorString += json["errors"][i].string!
                        }
                        
                        self.errorLabel.text = errorString
                        self.errorLabel.alpha = 1
                    }
                } else {
                    self.errorLabel.text = "something went wrong :("
                    self.errorLabel.alpha = 1
                }
                
                // We add a delay between ending the refresh and reloading data because otherwise the animation won't
                // be smooth and from then on, refreshing looks clunky. This is probably because we hook the refreshControl
                // into our UITableView. I've heard this clunkiness doesn't occur when you are within a UITableViewController
                // But... I'm not down with overkill. This is nice and simple.
                var delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
                
                dispatch_after(delayTime, dispatch_get_main_queue(), {
                    self.refreshControl.endRefreshing()
                })
        }
    }
    
    func startLoading() {
        errorLabel.alpha = 0.0
        self.refreshControl.beginRefreshing()
        refreshControl.sendActionsForControlEvents(.ValueChanged)
    }
    
    // Required as a Delegate. Otherwise, yes, it looks rather redundant
    func presentController(controller: UIViewController) {
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func presentLeaveCommunityController(name: String, row: Int) {
        var nameWithUnite = "&\(name)"
        
        var confirmLeaveAlert = UIAlertController(title: "Leave \(nameWithUnite)", message: "Are you sure you want to leave?", preferredStyle: .Alert)
        
        let leaveAction = UIAlertAction(title: "Leave", style: .Destructive, handler: {
            (alert: UIAlertAction!) in
            
            self.leaveCommunity(name, row: row)
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
        confirmLeaveAlert.addAction(leaveAction)
        confirmLeaveAlert.addAction(cancelAction)
        
        self.presentViewController(confirmLeaveAlert, animated: true, completion: nil)
    }
    
    func leaveCommunity(name: String, row: Int) {
        if (name == communities[row]) {
            communities.removeAtIndex(row)
        } else {
            communities = communities.filter( { return $0 != name } )
        }
        
        communitiesTable.reloadData()

        var userInfo = NSUserDefaults.standardUserDefaults()
        
        var params = [String : AnyObject]()
        
        params["user_id"] = userInfo.objectForKey("user_id") as! String
        params["auth_token"] = userInfo.objectForKey("auth_token") as! String
        
        Alamofire.request(.DELETE, "https://infinite-lake-4056.herokuapp.com/api/v1/communities/\(name).json", parameters: params)
            .responseJSON { request, response, jsonData, errors in
                
                if (response?.statusCode == 404 || errors != nil) {
                    
                    var arraySize = self.communities.count
                    
                    self.communities.insert(name, atIndex: (row > arraySize ? arraySize : row))
                    self.communitiesTable.reloadData()
                    
                    if (response?.statusCode == 404) {
                        self.view.makeToast("something went wrong :(", duration: NSTimeInterval(3), position: CSToastPositionCenter)
                    } else {
                        self.view.makeToast(errors?.localizedDescription.removeEndingPunctuationAndMakeLowerCase(), duration: NSTimeInterval(3), position: CSToastPositionCenter)
                    }
                }
            }
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (notifs) {
            return communities2.count
        } else {
            return communities.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.communitiesTable.dequeueReusableCellWithIdentifier("communityCell") as! CommunityCell
        
        if (notifs) {
            if (self.communities2.count > indexPath.row) {
                cell.configureViews(communities2[indexPath.row], row: indexPath.row)
            }

        } else {
            
            cell.presentControllerDelegate = self
            cell.leaveCommunityDelegate = self
            
            if (self.communities.count > indexPath.row) {
                cell.configureViews(communities[indexPath.row], row: indexPath.row)
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (notifs) {
            println("Touch")
        } else {
            if (self.communities.count > indexPath.row) {
                
                var userInfo = Dictionary<String, String>()
                userInfo["community"] = communities[indexPath.row] as String
    
                NSNotificationCenter.defaultCenter().postNotificationName("communitySelected", object: self, userInfo: userInfo)
            }
        }
    }
}
