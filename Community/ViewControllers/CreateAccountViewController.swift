//
//  CreateAccountViewController.swift
//  
//
//  Created by David Ilizarov on 10/5/15.
//
//

import UIKit
import Alamofire
import SwiftyJSON
import MMProgressHUD
import IQKeyboardManagerSwift

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    var navBar: UINavigationBar!
    
    @IBOutlet var usernameField: HoshiTextField!
    @IBOutlet var emailField: HoshiTextField!
    @IBOutlet var passwordField: HoshiTextField!
    @IBOutlet var confirmField: HoshiTextField!
    
    @IBOutlet var createAccountButton: UIButton!
    @IBAction func createAccountButtonPressed(sender: AnyObject) {
        let transferAlert = UIAlertController(title: "Transfer Request", message: "Would you like to transfer over the communities \(Session.get(.MetaUsername)!) joined?", preferredStyle: .Alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { alert in
            self.processRegistration(false)
        })
        
        let transfer = UIAlertAction(title: "Transfer", style: .Default, handler: { alert in
            self.processRegistration(true)
        })
        
        transferAlert.addAction(cancel)
        transferAlert.addAction(transfer)
        
        self.presentViewController(transferAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        
        createAccountButton.enabled = false
        
        usernameField.tintColor = UIColor(hexString: "056A85")
        emailField.tintColor = UIColor(hexString: "056A85")
        passwordField.tintColor = UIColor(hexString: "056A85")
        confirmField.tintColor = UIColor(hexString: "056A85")

        self.usernameField.delegate = self
        self.emailField.delegate = self
        self.passwordField.delegate = self
        self.confirmField.delegate = self
        
        usernameField.addTarget(self, action: Selector("textFieldDidChange"), forControlEvents: .EditingChanged)
        emailField.addTarget(self, action: Selector("textFieldDidChange"), forControlEvents: .EditingChanged)
        passwordField.addTarget(self, action: Selector("textFieldDidChange"), forControlEvents: .EditingChanged)
        confirmField.addTarget(self, action: Selector("textFieldDidChange"), forControlEvents: .EditingChanged)
        
        usernameField.keyboardDistanceFromTextField = 76
        emailField.keyboardDistanceFromTextField = 76
        passwordField.keyboardDistanceFromTextField = 76
        confirmField.keyboardDistanceFromTextField = 130
    }
    
    func setupNavBar() {
        navBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.bounds.width, 64))
        
        navBar.barTintColor = UIColor(hexString: "056A85")
        navBar.translucent = true
        
        navBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.whiteColor() ]
        
        self.view.addSubview(navBar)
        
        let backButton = UIBarButtonItem(image: UIImage(named: "Back"), style: .Plain, target: self, action: Selector("back"))
        backButton.tintColor = UIColor.whiteColor()
        
        let navigationItem = UINavigationItem()
        navigationItem.leftBarButtonItem = backButton
        
        navigationItem.title = "Create Account"
        
        navBar.pushNavigationItem(navigationItem, animated: false)
    }
    
    func processRegistration(transfer: Bool) {
        MMProgressHUD.sharedHUD().overlayMode = .Linear
        MMProgressHUD.setPresentationStyle(.Balloon)
        MMProgressHUD.show()
        
        Alamofire.request(Router.Register(username: usernameField.text!.strip(), email: emailField.text!.strip(), password: passwordField.text!, transfer: transfer))
            .responseJSON { request, response, result in
                // We delay by 1 second to keep a very smooth animation.
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                
                dispatch_after(delayTime, dispatch_get_main_queue(), {
                    
                    let defaultError = (result.error as? NSError)?.localizedDescription
                    
                    if (defaultError != nil) {
                        MMProgressHUD.dismissWithError(defaultError?.removeEndingPunctuationAndMakeLowerCase(), afterDelay: NSTimeInterval(3))
                    } else if let jsonData: AnyObject = result.value {
                        let json = JSON(jsonData)
                        
                        if (json["error"] != nil) {
                            MMProgressHUD.dismissWithError(json["error"].stringValue, afterDelay: NSTimeInterval(3))
                        } else if (json["errors"] == nil) {
                            self.storeSessionData(json)
                            
                            MMProgressHUD.sharedHUD().dismissAnimationCompletion = {
                                
                                self.usernameField.resignFirstResponder()
                                self.emailField.resignFirstResponder()
                                self.passwordField.resignFirstResponder()
                                self.confirmField.resignFirstResponder()
                                
                                let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                delegate.configureUsualLaunch(nil)
                            }
                            
                            
                            MMProgressHUD.dismissWithSuccess(":)")
                        } else {
                            var errorString = ""
                            
                            for var i = 0; i < json["errors"].count; i++ {
                                if (i != 0) { errorString += "\n\n" }
                                
                                errorString += json["errors"][i].string!
                            }
                            
                            MMProgressHUD.dismissWithError(errorString, afterDelay: NSTimeInterval(3))
                        }
                    } else {
                        // Realistically, should never trigger, but should always handle dismissing the HUD.
                        MMProgressHUD.dismissWithError("Something went wrong :(")
                    }
                })
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == usernameField) {
            emailField.becomeFirstResponder()
        } else if (textField == emailField) {
            passwordField.becomeFirstResponder()
        } else if (textField == passwordField) {
            confirmField.becomeFirstResponder()
        } else if (textField == confirmField) {
            if (createAccountButton.enabled) {
                createAccountButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
            }
        }
        
        return true
    }
    
    func textFieldDidChange() {
        let usernameChars = usernameField.text!.strip()
        let emailChars    = emailField.text!.strip()
        let passwordChars = passwordField.text!.strip()
        let confirmChars  = confirmField.text!.strip()
        
        createAccountButton.enabled = !(usernameChars.isEmpty || !String.validateEmail(emailChars) || passwordChars.isEmpty || confirmChars.isEmpty || passwordChars != confirmChars)
    }
    
    func storeSessionData(jsonData: JSON) {
        
        var user = jsonData["user"]
        
        Session.login(user["username"].string!,
            email: user["email"].string!,
            user_id: user["external_id"].string!,
            auth_token: user["auth_token"].string!,
            created_at: user["created_at"].string!,
            avatar_url: nil)
    }
    
    func back() {
        self.dismissViewControllerAnimated(true, completion: nil)
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
