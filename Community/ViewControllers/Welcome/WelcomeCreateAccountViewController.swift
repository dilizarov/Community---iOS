//
//  WelcomeCreateAccountViewController.swift
//  
//
//  Created by David Ilizarov on 9/30/15.
//
//

import UIKit
import TextFieldEffects
import IQKeyboardManagerSwift
import MMProgressHUD
import Alamofire
import SwiftyJSON

class WelcomeCreateAccountViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var createAccountButton: UIButton!
    @IBOutlet var usernameField: HoshiTextField!
    @IBOutlet var emailField: HoshiTextField!
    @IBOutlet var passwordField: HoshiTextField!
    @IBOutlet var passwordConfirmField: HoshiTextField!
    
    @IBOutlet var accountCreatedLabel: UILabel!
    
    @IBAction func createAccountAction(sender: AnyObject) {
        MMProgressHUD.sharedHUD().overlayMode = .Linear
        MMProgressHUD.setPresentationStyle(.Balloon)
        MMProgressHUD.show()
        
        Alamofire.request(Router.Register(username: usernameField.text!.strip(), email: emailField.text!.strip(), password: passwordField.text!, transfer: false))
            .responseJSON { request, response, jsonData, errors in
                // We delay by 1 second to keep a very smooth animation.
                var delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                
                dispatch_after(delayTime, dispatch_get_main_queue(), {
                    
                    var defaultError = errors?.localizedDescription
                    
                    if (defaultError != nil) {
                        MMProgressHUD.dismissWithError(defaultError?.removeEndingPunctuationAndMakeLowerCase(), afterDelay: NSTimeInterval(3))
                    } else if let jsonData: AnyObject = jsonData {
                        let json = JSON(jsonData)
                        
                        if (json["errors"] == nil) {
                            self.storeSessionData(json)
                            MMProgressHUD.sharedHUD().dismissAnimationCompletion = {

                                self.resignTextFieldResponders()
                                self.setAccountCreatedView()
                                
                                var descriptionAlert = UIAlertController(title: "Account Created", message: "The username we created for you during the previous step will be used whenever you log out.", preferredStyle: .Alert)
                                
                                var close = UIAlertAction(title: "Close", style: .Default, handler: {
                                    alert in
                                    
                                    self.performSegueWithIdentifier("showShare", sender: self)
                                })
                                
                                descriptionAlert.addAction(close)
                                
                                self.presentViewController(descriptionAlert, animated: true, completion: nil)
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
                        MMProgressHUD.dismissWithError(":(")
                    }
                })
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createAccountButton.enabled = false
        prefillFromRootVC()
        
        usernameField.tintColor = UIColor(hexString: "056A85")
        emailField.tintColor = UIColor(hexString: "056A85")
        passwordField.tintColor = UIColor(hexString: "056A85")
        passwordConfirmField.tintColor = UIColor(hexString: "056A85")
        
        usernameField.keyboardDistanceFromTextField = 76
        emailField.keyboardDistanceFromTextField = 76
        passwordField.keyboardDistanceFromTextField = 76
        passwordConfirmField.keyboardDistanceFromTextField = 130
        
        self.usernameField.delegate = self
        self.emailField.delegate = self
        self.passwordField.delegate = self
        self.passwordConfirmField.delegate = self
        
        self.usernameField.addTarget(self, action: Selector("textFieldDidChange"), forControlEvents: .EditingChanged)
        self.emailField.addTarget(self, action: Selector("textFieldDidChange"), forControlEvents: .EditingChanged)
        self.passwordField.addTarget(self, action: Selector("textFieldDidChange"), forControlEvents: .EditingChanged)
        self.passwordConfirmField.addTarget(self, action: Selector("textFieldDidChange"), forControlEvents: .EditingChanged)
        
        if Session.loggedIn() {
            setAccountCreatedView()
        } else {
            setCreateAccountView()
        }
    }
    
    func setAccountCreatedView() {
        usernameField.alpha = 0
        emailField.alpha = 0
        passwordField.alpha = 0
        passwordConfirmField.alpha = 0
        createAccountButton.alpha = 0
        accountCreatedLabel.alpha = 1
        navigationItem.rightBarButtonItem?.title = "Next"
    }
    
    func setCreateAccountView() {
        accountCreatedLabel.alpha = 0
        usernameField.alpha = 1
        emailField.alpha = 1
        passwordField.alpha = 1
        passwordConfirmField.alpha = 1
        createAccountButton.alpha = 1
        navigationItem.rightBarButtonItem?.title = "Skip"
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == usernameField) {
            emailField.becomeFirstResponder()
        } else if (textField == emailField) {
            passwordField.becomeFirstResponder()
        } else if (textField == passwordField) {
            passwordConfirmField.becomeFirstResponder()
        } else if (textField == passwordConfirmField) {
            if (createAccountButton.enabled) {
                createAccountButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
            }
        }
        
        return true
    }
    
    // We check all fields and if the fields meet the criteria, we activate create account button.
    func textFieldDidChange() {
        
        var usernameChars = usernameField.text!.strip()
        var emailChars    = emailField.text!.strip()
        var passwordChars = passwordField.text!.strip()
        var confirmChars  = passwordConfirmField.text!.strip()
        
        setValsForRootVC(usernameChars, email: emailChars, password: passwordChars)
        
        if (usernameChars.isEmpty || !String.validateEmail(emailChars) || passwordChars.isEmpty || confirmChars.isEmpty || passwordChars != confirmChars) {
            createAccountButton.enabled = false
        } else {
            createAccountButton.enabled = true
        }
    }
    
    func setValsForRootVC(username: String, email: String, password: String) {
        
        let rootVC = self.navigationController!.viewControllers.first as!ImportantDocumentsViewController
        
        rootVC.typedUsername = username
        rootVC.typedEmail = email
        rootVC.typedPassword = password
    }

    
    func prefillFromRootVC() {
        let rootVC = self.navigationController!.viewControllers.first as!ImportantDocumentsViewController
        
        if let username = rootVC.typedUsername {
            if username != "" {
                usernameField.text = username
            }
        }
        
        if let email = rootVC.typedEmail {
            if email != "" {
                emailField.text = email
            }
        }
        
        if let password = rootVC.typedPassword {
            if password != "" {
                passwordField.text = password
            }
        }
    }
    
    func resignTextFieldResponders() {
        usernameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        passwordConfirmField.resignFirstResponder()
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
