//
//  CommunitySettingsViewController.swift
//  
//
//  Created by David Ilizarov on 9/16/15.
//
//

import UIKit
import RealmSwift
import MMProgressHUD
import SDWebImage
import UIActivityIndicator_for_SDWebImage
import Alamofire
import SwiftyJSON

//As it stands, I really don't like the way all the methods here work internally.
//I think there is a lot of bad coding practices and it also is messy.
//Lots of spaghetti but that said, it gets the job done and thats all that matters
//at the moment.

class CommunitySettingsViewController: UIViewController {

    enum State {
        case Default, Community, New
    }
    
    var navBar: UINavigationBar!
    var rightButtonOptions = [String : UIBarButtonItem]()
    
    var communityName: String!
    var joinedCommunity: JoinedCommunity!
    
    var userDefaults: NSUserDefaults!
    
    var communityUsername: String!
    var communityAvatarUrl: String!
    var defaultUsername: String!
    var defaultAvatarUrl: String!
    
    var croppedNewImage: UIImage?
    
    @IBOutlet var defaultSwitch: UISwitch!
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var settingsHolder: UIView!
    @IBOutlet var usernameField: UITextField!
    
    var originalUsername: String!
    var originalAvatarState: State!
    var originalState: State!
    
    var currentAvatarState: State!
    
    var latestCommunityUsername: String!
    var latestCommunityAvatarState: State!
    
    @IBAction func toggleSwitch(sender: AnyObject) {
        usernameField.resignFirstResponder()
        if defaultSwitch.on {
            setDefaultAvatar()
            setDefaultUsername()
        } else {
            setCurrentCommunityAvatar()
            setCurrentCommunityUsername()
        }
        
        determineSaveEnabled()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userDefaults = NSUserDefaults.standardUserDefaults()
        
        let realm = Realm()
        joinedCommunity = realm.objectForPrimaryKey(JoinedCommunity.self, key: communityName)

        settingsHolder.layer.cornerRadius = 5.0
        setupNavBar()
        setupAvatarImage()

        //Store defaults/community-based username
        //and avatar into local variables for ease
        //of reuse and set how everything initially looks
        setupOriginalState()
        
        usernameField.addTarget(self, action: Selector("textFieldDidChange"), forControlEvents: .EditingChanged)
    }
    
    func setupNavBar() {
        navBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.bounds.width, 64))
        
        navBar.barTintColor = UIColor.whiteColor()
        navBar.translucent = false
        
        navBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.darkGrayColor() ]
        
        self.view.addSubview(navBar)
        
        var backButton = UIBarButtonItem(image: UIImage(named: "Back"), style: .Plain, target: self, action: Selector("cancel"))
        
        backButton.tintColor = UIColor(hexString: "056A85")
        
        var saveButton = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: Selector("save"))
        saveButton.tintColor = UIColor(hexString: "056A85")
        saveButton.enabled = false
        
        var loadIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 22, 22))
        loadIndicator.stopAnimating()
        loadIndicator.hidesWhenStopped = true
        loadIndicator.activityIndicatorViewStyle = .Gray
        
        var loadButton = UIBarButtonItem(customView: loadIndicator)
        
        rightButtonOptions["save"] = saveButton
        rightButtonOptions["load"] = loadButton
        
        var navigationItem = UINavigationItem()
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.leftBarButtonItem = backButton
        
        navigationItem.title = communityName
        
        navBar.pushNavigationItem(navigationItem, animated: false)
    }

    func setupAvatarImage() {
        self.avatar.layer.cornerRadius = self.avatar.frame.size.height / 2
        self.avatar.layer.masksToBounds = true
        self.avatar.contentMode = .ScaleAspectFit
        self.avatar.clipsToBounds = true
        
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("avatarImagePressed"))
        singleTap.numberOfTapsRequired = 1
        self.avatar.userInteractionEnabled = true
        self.avatar.addGestureRecognizer(singleTap)
    }
    
    func setupOriginalState() {
        communityUsername = joinedCommunity!.username
        latestCommunityUsername = communityUsername
        communityAvatarUrl = joinedCommunity!.avatar_url
        
        defaultUsername = userDefaults.objectForKey("username") as! String
        var avatarUrl = userDefaults.objectForKey("avatar_url") as? String
        
        if let url = avatarUrl {
            defaultAvatarUrl = url
        } else {
            defaultAvatarUrl = ""
        }
        
        var isDefault = communityAvatarUrl == "" && communityUsername == ""
        
        originalAvatarState = .Default
        
        if communityAvatarUrl == "" {
            communityAvatarUrl = defaultAvatarUrl
            latestCommunityAvatarState = .Default
        } else {
            originalAvatarState = .Community
            latestCommunityAvatarState = .Community
        }
        
        if communityUsername == "" {
            communityUsername = defaultUsername
            latestCommunityUsername = communityUsername
        }
        
        if isDefault {
            originalState = .Default
            setDefaultAvatar()
            setDefaultUsername()
            defaultSwitch.setOn(true, animated: true)
            defaultSwitch.enabled = false
        } else {
            originalState = .Community
            setCurrentCommunityAvatar()
            setCurrentCommunityUsername()
            defaultSwitch.setOn(false, animated: true)
            defaultSwitch.enabled = true
        }
    }
    
    func setDefaultAvatar() {
        if defaultAvatarUrl != "" {
            self.avatar.setImageWithURL(NSURL(string: defaultAvatarUrl),
                placeholderImage: UIImage(named: "AvatarPlaceHolder"),
                options: SDWebImageOptions.RetryFailed,
                completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in
                    
                    self.currentAvatarState = .Default
                    
                    if let actualError = error {
                        self.avatar.image = UIImage(named: "AvatarPlaceHolderError")
                    }
                    
                },
                usingActivityIndicatorStyle: .Gray)
        } else {
            self.avatar.image = UIImage(named: "AvatarPlaceHolderGray")
        }
    }
    
    func setDefaultUsername() {
        usernameField.text = defaultUsername
    }
    
    func setCurrentCommunityAvatar() {
        if let newImage = croppedNewImage {
            self.avatar.image = newImage
            self.currentAvatarState = .New
        } else {
            if communityAvatarUrl != "" {
                self.avatar.setImageWithURL(NSURL(string: communityAvatarUrl),
                    placeholderImage: UIImage(named: "AvatarPlaceHolder"),
                    options: SDWebImageOptions.RetryFailed,
                    completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in
                        
                        self.currentAvatarState = .Community
                        
                        if let actualError = error {
                            self.avatar.image = UIImage(named: "AvatarPlaceHolderError")
                        }
                            
                    },
                    usingActivityIndicatorStyle: .Gray)
            } else {
                self.avatar.image = UIImage(named: "AvatarPlaceHolderGray")
            }
        }
    }
    
    func setCurrentCommunityUsername() {
        usernameField.text = latestCommunityUsername
    }
    
    func avatarImagePressed() {
        let pickerController = DKImagePickerController()
        pickerController.didCancelled = {}
        pickerController.didCropImage = { [unowned self] (image: UIImage) in
            
            self.croppedNewImage = image.imageByScalingAspectFitSize(CGSizeMake(1000, 1000))
            
            self.avatar.image = self.croppedNewImage
            self.latestCommunityAvatarState = .New
            self.currentAvatarState = .New
            
            self.defaultSwitch.setOn(false, animated: true)
            self.defaultSwitch.enabled = true
            
            self.determineSaveEnabled()
        }

        pickerController.maxSelectableCount = 1
        pickerController.assetType = .allPhotos
        pickerController.allowMultipleType = false
        
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    func textFieldDidChange() {
        latestCommunityUsername = usernameField.text.strip()
        
        if (defaultSwitch.on && latestCommunityUsername != defaultUsername) {
            defaultSwitch.setOn(false, animated: true)
            defaultSwitch.enabled = true
        } else if !defaultSwitch.on && latestCommunityUsername == defaultUsername {
            if currentAvatarState == .Default {
                defaultSwitch.setOn(true, animated: true)
            }
            
            if latestCommunityAvatarState == .Default {
                defaultSwitch.enabled = false
            }
            
        }
        
        determineSaveEnabled()
    }
    
    func determineSaveEnabled() {
        
        var saveButton = rightButtonOptions["save"]!
        
        if originalState == .Default && defaultSwitch.on {
            println("a")
            saveButton.enabled = false
        } else if originalState == .Default && !defaultSwitch.on {
            println("b")
            saveButton.enabled = true
        } else if originalState == .Community && defaultSwitch.on {
            println("c")
            saveButton.enabled = true
        } else if originalState == .Community && !defaultSwitch.on {
            println("d")
            if communityUsername == latestCommunityUsername &&
               ((communityAvatarUrl == defaultAvatarUrl && latestCommunityAvatarState == .Default) ||
               (originalAvatarState == .Community && latestCommunityAvatarState == .Community)) {
                saveButton.enabled = false
            } else {
                saveButton.enabled = true
            }
        }
    }
    
    func save() {
        MMProgressHUD.sharedHUD().overlayMode = .Linear
        MMProgressHUD.setPresentationStyle(.Balloon)
        MMProgressHUD.show()
        
        var user_id = userDefaults.objectForKey("user_id") as! String
        var auth_token = userDefaults.objectForKey("auth_token") as! String
        
        var params = [String: AnyObject]()
        params["user_id"] = user_id
        params["auth_token"] = auth_token
        params["community"] = communityName.strip()
        
        var delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        
        if (defaultSwitch.on) {
            params["default"] = true
            Alamofire.request(.PUT, "https://infinite-lake-4056.herokuapp.com/api/v1/communities/update.json", parameters: params, encoding: .JSON)
                .responseJSON { request, response, jsonData, errors in
                    
                    dispatch_after(delayTime, dispatch_get_main_queue(), {
                        var defaultError = errors?.localizedDescription
                        
                        if (defaultError != nil) {
                            MMProgressHUD.dismissWithError(defaultError?.removeEndingPunctuationAndMakeLowerCase(), afterDelay: NSTimeInterval(3))
                        } else if let jsonData: AnyObject = jsonData {
                            let json = JSON(jsonData)
                            
                            if (json["errors"] == nil) {
                                let realm = Realm()
                                var community = realm.objectForPrimaryKey(JoinedCommunity.self, key: self.communityName)
                                
                                realm.write {
                                    community?.avatar_url = ""
                                    community?.username = ""
                                }
                                
                                MMProgressHUD.dismissWithSuccess(":)")
                                var newDelayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
                                
                                dispatch_after(newDelayTime, dispatch_get_main_queue(), {
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                })
                            } else {
                                var errorString = ""
                                
                                for var i = 0; i < json["errors"].count; i++ {
                                    if (i != 0) { errorString += "\n\n" }
                                    errorString += json["errors"][i].string!
                                }
                                
                                MMProgressHUD.dismissWithError(errorString, afterDelay: NSTimeInterval(3))
                            }
                        } else {
                            MMProgressHUD.dismissWithError("Something went wrong :(", afterDelay: NSTimeInterval(3))
                        }

                    })
                }
        } else if croppedNewImage != nil {
            var imageData = UIImagePNGRepresentation(croppedNewImage!)
            
            var url = "https://infinite-lake-4056.herokuapp.com/api/v1/communities/update.json?user_id=\(user_id)&auth_token=\(auth_token)&community=\(communityName.strip())&username=\(latestCommunityUsername.strip())"
            
            Alamofire.upload(.PUT, URLString: url.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!,
                multipartFormData: { multipartFormData in
                    multipartFormData.appendBodyPart(data: imageData, name: "community_avatar", fileName: "community_avatar_img.png", mimeType: "image/png")
                
                },
                encodingCompletion: { encodingResult in
                    
                    dispatch_after(delayTime, dispatch_get_main_queue(), {
                        switch encodingResult {
                        case .Success (let upload, _, _):
                            upload.responseJSON { request, response, data, error in
                                var defaultError = error?.localizedDescription
                                
                                if defaultError != nil {
                                    MMProgressHUD.dismissWithError(defaultError!.removeEndingPunctuationAndMakeLowerCase(), afterDelay: NSTimeInterval(3))
                                } else if let jsonData: AnyObject = data {
                                    let json = JSON(jsonData)
                                    
                                    if json["errors"] == nil {
                                        let realm = Realm()
                                        var community = realm.objectForPrimaryKey(JoinedCommunity.self, key: self.communityName)
                                        
                                        var username = ""
                                        
                                        println("hi")
                                        
                                        if json["community"]["user"]["username"].stringValue != self.defaultUsername {
                                            username = json["community"]["user"]["username"].stringValue
                                        }
                                        
                                        var avatar_url = json["community"]["user"]["avatar_url"].stringValue
                                        
                                        realm.write {
                                            community?.avatar_url = avatar_url
                                            community?.username = username
                                        }
                                        
                                        SDImageCache.sharedImageCache().storeImage(self.croppedNewImage!, forKey: avatar_url)
                                        
                                        MMProgressHUD.dismissWithSuccess(":)")
                                        var newDelayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
                                        
                                        dispatch_after(newDelayTime, dispatch_get_main_queue(), {
                                            self.dismissViewControllerAnimated(true, completion: nil)
                                        })
                                    } else {
                                        var errorString = ""
                                        
                                        for var i = 0; i < json["errors"].count; i++ {
                                            if (i != 0) { errorString += "\n\n" }
                                            errorString += json["errors"][i].string!
                                        }
                                        
                                        MMProgressHUD.dismissWithError(errorString, afterDelay: NSTimeInterval(3))
                                    }
                                } else {
                                    MMProgressHUD.dismissWithError("Something went wrong :(", afterDelay: NSTimeInterval(3))
                                }
                            }
                        case .Failure (let encodingError):
                            MMProgressHUD.dismissWithError("Having difficult with this image :(", afterDelay: NSTimeInterval(3))
                        }
                    })
                }
            )
        } else {
            params["username"] = latestCommunityUsername.strip()
            Alamofire.request(.PUT, "https://infinite-lake-4056.herokuapp.com/api/v1/communities/update.json", parameters: params, encoding: .JSON)
                .responseJSON { request, response, jsonData, errors in
                
                    dispatch_after(delayTime, dispatch_get_main_queue(), {
                        var defaultError = errors?.localizedDescription
                        
                        if (defaultError != nil) {
                            MMProgressHUD.dismissWithError(defaultError?.removeEndingPunctuationAndMakeLowerCase(), afterDelay: NSTimeInterval(3))
                        } else if let jsonData: AnyObject = jsonData {
                            let json = JSON(jsonData)
                            
                            if (json["errors"] == nil) {
                                let realm = Realm()
                                var community = realm.objectForPrimaryKey(JoinedCommunity.self, key: self.communityName)
                                
                                var username = ""
                                
                                if json["community"]["user"]["username"].stringValue != self.defaultUsername {
                                    username = json["community"]["user"]["username"].stringValue
                                }

                                
                                realm.write {
                                    community?.username = username
                                }
                                
                                MMProgressHUD.dismissWithSuccess(":)")
                                var newDelayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
                                
                                dispatch_after(newDelayTime, dispatch_get_main_queue(), {
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                })
                            } else {
                                var errorString = ""
                                
                                for var i = 0; i < json["errors"].count; i++ {
                                    if (i != 0) { errorString += "\n\n" }
                                    errorString += json["errors"][i].string!
                                }
                                
                                MMProgressHUD.dismissWithError(errorString, afterDelay: NSTimeInterval(3))
                            }
                        } else {
                            MMProgressHUD.dismissWithError("Something went wrong :(", afterDelay: NSTimeInterval(3))
                        }
                        
                    })
                }
        }
    }
    
    func cancel() {
        if rightButtonOptions["save"]!.enabled {
            var confirmAlert = UIAlertController(title: "Go Back Without Saving", message: "Are you sure you want to go back without saving?", preferredStyle: .Alert)
            
            var back = UIAlertAction(title: "Back", style: .Default, handler: { alert in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            
            var save = UIAlertAction(title: "Save", style: .Default, handler: { alert in
                self.save()
            })
            
            confirmAlert.addAction(save)
            confirmAlert.addAction(back)
            
            self.presentViewController(confirmAlert, animated: true, completion: nil)
 
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
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
