//
//  CreateAccountViewController.swift
//  
//
//  Created by David Ilizarov on 8/19/15.
//
//

import UIKit
import Alamofire
import SwiftyJSON
import MMProgressHUD
import MMDrawerController

class CreateAccountViewController: UIViewController, UITextFieldDelegate {
        
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var passwordLabel: UILabel!
    @IBOutlet var confirmLabel: UILabel!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmTextField: UITextField!
    
    @IBOutlet var backButton: UIButton!
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet var passwordShowButton: UIButton!
    @IBAction func passwordShowButtonPressed(sender: AnyObject) {
        
        if (passwordTextField.secureTextEntry) {
            passwordTextField.secureTextEntry = false
            passwordShowButton.setTitle("Hide", forState: .Normal)
            
            // Silly solution to resolve what is an iOS bug
            // http://stackoverflow.com/questions/14220187/uitextfield-has-trailing-whitespace-after-securetextentry-toggle
            
            var tmpText = passwordTextField.text
            passwordTextField.text = nil
            passwordTextField.text = tmpText
        } else {
            passwordTextField.secureTextEntry = true
            passwordShowButton.setTitle("Show", forState: .Normal)
        }
    }
    
    @IBOutlet var confirmShowButton: UIButton!
    @IBAction func confirmShowButtonPressed(sender: AnyObject) {
        
        if (confirmTextField.secureTextEntry) {
            confirmTextField.secureTextEntry = false
            confirmShowButton.setTitle("Hide", forState: .Normal)
            
            var tmpText = confirmTextField.text
            confirmTextField.text = nil
            confirmTextField.text = tmpText
        } else {
            confirmTextField.secureTextEntry = true
            confirmShowButton.setTitle("Show", forState: .Normal)
        }
    }
    
    @IBOutlet var createAccountButton: UIButton!
    @IBAction func createAccountButtonPressed(sender: AnyObject) {
        
        MMProgressHUD.sharedHUD().overlayMode = .Linear
        MMProgressHUD.setPresentationStyle(.Balloon)
        MMProgressHUD.show()
        
        Alamofire.request(Router.Register(username: usernameTextField.text.strip(), email: emailTextField.text.strip(), password: passwordTextField.text))
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
                             
                                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                
                                var centerViewController =  mainStoryboard.instantiateViewControllerWithIdentifier("SearchViewController") as! SearchViewController
                                
                                var leftViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ProfileViewController") as! UIViewController
                                
                                let drawerController = MMDrawerController(centerViewController: centerViewController, leftDrawerViewController: leftViewController)
                                
                                drawerController?.setMaximumLeftDrawerWidth(330, animated: true, completion: nil)
                                drawerController?.openDrawerGestureModeMask = .All
                                drawerController?.closeDrawerGestureModeMask = .All
                                drawerController?.centerHiddenInteractionMode = .None
                                
                                // This forces the side to layout itself properly.
                                drawerController?.bouncePreviewForDrawerSide(.Left, distance: 30, completion: nil)
                                
                              //  centerViewController.drawerController = drawerController
                                
                                self.presentViewController(drawerController, animated: true, completion: nil)
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
 
        disableCreateAccountButton()
        
        usernameTextField.tintColor = UIColor.whiteColor()
        emailTextField.tintColor = UIColor.whiteColor()
        passwordTextField.tintColor = UIColor.whiteColor()
        confirmTextField.tintColor = UIColor.whiteColor()
        
        self.usernameTextField.delegate = self
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.confirmTextField.delegate = self
        
        usernameTextField.addTarget(self, action: Selector("textFieldDidChange"), forControlEvents: .EditingChanged)
        emailTextField.addTarget(self, action: Selector("textFieldDidChange"), forControlEvents: .EditingChanged)
        passwordTextField.addTarget(self, action: Selector("textFieldDidChange"), forControlEvents: .EditingChanged)
        confirmTextField.addTarget(self, action: Selector("textFieldDidChange"), forControlEvents: .EditingChanged)

        usernameTextField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if (textField == usernameTextField) {
            emailTextField.becomeFirstResponder()
        } else if (textField == emailTextField) {
            passwordTextField.becomeFirstResponder()
        } else if (textField == passwordTextField) {
            confirmTextField.becomeFirstResponder()
        } else if (textField == confirmTextField) {
            if (createAccountButton.enabled) {
                createAccountButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
            }
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {

        if (textField == passwordTextField || textField == confirmTextField) {
            passwordShowButton.enabled = true
            confirmShowButton.enabled = true
            
            passwordShowButton.alpha = 1.0
            confirmShowButton.alpha = 1.0
        } else {
            passwordShowButton.alpha = 0.0
            confirmShowButton.alpha = 0.0
            
            passwordShowButton.enabled = false
            confirmShowButton.enabled = false
            
            passwordTextField.secureTextEntry = true
            confirmTextField.secureTextEntry = true
            
            passwordShowButton.setTitle("Show", forState: .Normal)
            confirmShowButton.setTitle("Show", forState: .Normal)
        }
    }

    // We check all fields and if the fields meet the criteria, we activate create account button.
    func textFieldDidChange() {
    
        var usernameChars = usernameTextField.text.strip()
        var emailChars    = emailTextField.text.strip()
        var passwordChars = passwordTextField.text.strip()
        var confirmChars  = confirmTextField.text.strip()
        
        if (usernameChars.isEmpty || !String.validateEmail(emailChars) || passwordChars.isEmpty || confirmChars.isEmpty || passwordChars != confirmChars) {
            disableCreateAccountButton()
        } else {
            enableCreateAccountButton()
        }
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
    
    func disableCreateAccountButton() {
        createAccountButton.enabled = false
        createAccountButton.alpha = 0.4
    }
    
    func enableCreateAccountButton() {
        createAccountButton.enabled = true
        createAccountButton.alpha = 1.0
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
