//
//  LogInViewController.swift
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

class LogInViewController: UIViewController, UITextFieldDelegate {

    enum ViewState {
        case Login, ForgotPassword
    }
    
    var viewState: ViewState?
    
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var passwordLabel: UILabel!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordTextFieldUnderline: UIView!
    
    @IBOutlet var backButton: UIButton!
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet var forgotPasswordButton: UIButton!
    @IBAction func forgetPasswordButtonPressed(sender: AnyObject) {
        
        if (viewState == .Login) {
            viewState = .ForgotPassword

            self.emailTextField.returnKeyType = UIReturnKeyType.Go
            self.emailTextField.resignFirstResponder()
            self.emailTextField.becomeFirstResponder()
            
        forgotPasswordButton.setTitle("Whoops", forState: .Normal)
            logInButton.setTitle("SEND EMAIL", forState: .Normal)
            
            textFieldDidChange()
            
            UIView.animateWithDuration(0.25, animations: {
                
                self.passwordLabel.alpha = 0.0
                self.passwordTextField.alpha = 0.0
                self.passwordTextField.enabled = false
                self.passwordTextFieldUnderline.alpha = 0.0
            })
        } else {
            viewState = .Login
            
            self.emailTextField.returnKeyType = UIReturnKeyType.Next
            self.emailTextField.resignFirstResponder()
            self.emailTextField.becomeFirstResponder()
            forgotPasswordButton.setTitle("Forget?", forState: .Normal)
            logInButton.setTitle("LOG IN", forState: .Normal)
            
            textFieldDidChange()
            
            UIView.animateWithDuration(0.25, animations: {
                self.passwordLabel.alpha = 1.0
                self.passwordTextField.alpha = 1.0
                self.passwordTextField.enabled = true
                self.passwordTextFieldUnderline.alpha = 1.0
            })
        }
        
    }
    
    // Arguably a bad name, because this can change into the Send Email button
    // if one forgets their password.
    @IBOutlet var logInButton: UIButton!
    @IBAction func logInButtonPressed(sender: AnyObject) {
        if (viewState == .Login) {
            processLogin()
        } else {
            processForgotPassword()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewState = .Login
        disableLogInButton()
        
        emailTextField.tintColor = UIColor.whiteColor()
        passwordTextField.tintColor = UIColor.whiteColor()
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        emailTextField.addTarget(self, action: Selector("textFieldDidChange"), forControlEvents: .EditingChanged)
        passwordTextField.addTarget(self, action: Selector("textFieldDidChange"), forControlEvents: .EditingChanged)
        
        
        emailTextField.becomeFirstResponder()
    }
    
    func processLogin() {
        
        MMProgressHUD.sharedHUD().overlayMode = .Linear
        MMProgressHUD.setPresentationStyle(.Balloon)
        MMProgressHUD.show()
        
        var emailText    = emailTextField.text.strip()
        var passwordText = passwordTextField.text.strip()
        
        var params = [String: AnyObject]()
        
        var user = [ "email" : emailText, "password" : passwordText ]
        
        params["user"] = user
        
        Alamofire.request(.POST, "https://infinite-lake-4056.herokuapp.com/api/v1/sessions.json", parameters: params, encoding: .JSON)
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

                                centerViewController.drawerController = drawerController
                                
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
    
    func processForgotPassword() {
        // TODO
        // BUILD THIS
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if (textField == emailTextField) {
            if (viewState == .Login) {
                passwordTextField.becomeFirstResponder()
            } else {
                if (logInButton.enabled) {
                    logInButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                }
            }
        } else if (textField == passwordTextField) {
            if (logInButton.enabled) {
                logInButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
            }
        }
        
        return true
    }

    func textFieldDidChange() {
        
        var emailChars = emailTextField.text.strip()
        var passwordChars = passwordTextField.text.strip()
        
        if (emailChars.isEmpty || !String.validateEmail(emailChars)) {
            disableLogInButton()
        } else {
            if (passwordChars.isEmpty && viewState == .Login) {
                disableLogInButton()
            } else {
                enableLogInButton()
            }
        }
    }
    
    func storeSessionData(jsonData: JSON) {
        var defaults = NSUserDefaults.standardUserDefaults()
        
        var user = jsonData["user"]
        
        defaults.setObject(user["username"].string, forKey: "username")
        defaults.setObject(user["email"].string, forKey: "email")
        defaults.setObject(user["external_id"].string, forKey: "user_id")
        defaults.setObject(user["auth_token"].string, forKey: "auth_token")
        defaults.setObject(user["created_at"].string, forKey: "created_at")
        defaults.setObject(user["avatar_url"].string, forKey: "avatar_url")
        
        defaults.synchronize()
    }
    
    func disableLogInButton() {
        logInButton.enabled = false
        logInButton.alpha = 0.4
    }
    
    func enableLogInButton() {
        logInButton.enabled = true
        logInButton.alpha = 1.0
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
