//
//  WelcomeLogInViewController.swift
//  Community
//
//  Created by David Ilizarov on 1/27/16.
//  Copyright © 2016 David Ilizarov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MMProgressHUD

class WelcomeLoginViewController: UIViewController, UITextFieldDelegate {
    
    enum ViewState {
        case Login, ForgotPassword
    }
    
    var viewState: ViewState?
    
    var delegate: ShowLoggedInStateDelegate!
    
    @IBOutlet var emailField: HoshiTextField!
    @IBOutlet var passwordField: HoshiTextField!
    
    @IBOutlet var forgotPasswordButton: UIButton!
    @IBAction func forgotPasswordButtonPressed(sender: AnyObject) {
        if (viewState == .Login) {
            viewState = .ForgotPassword
            
            self.emailField.returnKeyType = UIReturnKeyType.Go
            self.emailField.resignFirstResponder()
            self.passwordField.resignFirstResponder()
            
            forgotPasswordButton.setTitle("Whoops", forState: .Normal)
            commandButton.setTitle("Send Email", forState: .Normal)
            commandButton.setTitle("Send Email", forState: .Disabled)
            
            textFieldDidChange()
            
            UIView.animateWithDuration(0.25, animations: {
                
                self.passwordField.alpha = 0.0
                self.passwordField.enabled = false
            })
        } else {
            viewState = .Login
            
            self.emailField.returnKeyType = UIReturnKeyType.Next
            self.emailField.resignFirstResponder()
            self.passwordField.resignFirstResponder()
            
            forgotPasswordButton.setTitle("Forget?", forState: .Normal)
            commandButton.setTitle("Log In", forState: .Normal)
            commandButton.setTitle("Log In", forState: .Disabled)
            
            textFieldDidChange()
            
            UIView.animateWithDuration(0.25, animations: {
                self.passwordField.alpha = 1.0
                self.passwordField.enabled = true
            })
        }
    }
    
    @IBOutlet var commandButton: UIButton!
    @IBAction func commandButtonPressed(sender: AnyObject) {
        if (viewState == .Login) {
            processLogin()
        } else {
            processForgotPassword()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordField.rightOffset = forgotPasswordButton.bounds.width
       
        viewState = .Login
        commandButton.enabled = false
        
        emailField.tintColor = UIColor(hexString: "056A85")
        passwordField.tintColor = UIColor(hexString: "056A85")
        
        emailField.keyboardDistanceFromTextField = 76
        passwordField.keyboardDistanceFromTextField = 76
        
        self.emailField.delegate = self
        self.passwordField.delegate = self
        
        emailField.addTarget(self, action: "textFieldDidChange", forControlEvents: .EditingChanged)
        passwordField.addTarget(self, action: "textFieldDidChange", forControlEvents: .EditingChanged)
    }
    
    func processLogin() {
        
        MMProgressHUD.sharedHUD().overlayMode = .Linear
        MMProgressHUD.setPresentationStyle(.Balloon)
        MMProgressHUD.show()
                
        Alamofire.request(Router.Login(email: emailField.text!.strip(), password: passwordField.text!))
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
                        } else if (json["errors"] == nil) {
                            self.storeSessionData(json)
                            MMProgressHUD.sharedHUD().dismissAnimationCompletion = {
                                
                                self.emailField.resignFirstResponder()
                                self.passwordField.resignFirstResponder()
                                
                                self.delegate.showLoggedInState()
                                self.navigationController?.popViewControllerAnimated(true)
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
    
    func processForgotPassword() {
        MMProgressHUD.sharedHUD().overlayMode = .Linear
        MMProgressHUD.setPresentationStyle(.Balloon)
        MMProgressHUD.show()
        
        Alamofire.request(Router.ForgotPassword(email: emailField.text!.strip()))
            .responseJSON { request, response, result in
                // We delay by 1 second to keep a very smooth animation.
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                
                dispatch_after(delayTime, dispatch_get_main_queue(), {
                    
                    let defaultError = (result.error as? NSError)?.localizedDescription
                    
                    if ((response == nil || response?.statusCode > 299) && defaultError != nil) {
                        MMProgressHUD.dismissWithError(defaultError?.removeEndingPunctuationAndMakeLowerCase(), afterDelay: NSTimeInterval(3))
                    } else if response?.statusCode > 299 {
                        var errorString = "Something went wrong :("
                        
                        if let jsonData: AnyObject = result.value {
                            let json = JSON(jsonData)
                            
                            if let error = json["error"].string {
                                errorString = error
                            }
                        }
                        
                        MMProgressHUD.dismissWithError(errorString, afterDelay: NSTimeInterval(3))
                    } else {
                        MMProgressHUD.sharedHUD().dismissAnimationCompletion = {
                            self.forgotPasswordButtonPressed(self)
                        }
                        
                        MMProgressHUD.dismissWithSuccess("Email sent")
                    }
                })
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == emailField) {
            if (viewState == .Login) {
                passwordField.becomeFirstResponder()
            } else {
                if (commandButton.enabled) {
                    commandButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                }
            }
        } else if (textField == passwordField) {
            if (commandButton.enabled) {
                commandButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
            }
        }
        
        return true
    }
    
    func textFieldDidChange() {
        let emailChars = emailField.text!.strip()
        let passwordChars = passwordField.text!.strip()
        
        if (emailChars.isEmpty || !String.validateEmail(emailChars)) {
            commandButton.enabled = false
        } else {
            if (passwordChars.isEmpty && viewState == .Login) {
                commandButton.enabled = false
            } else {
                commandButton.enabled = true
            }
        }
    }
    
    func storeSessionData(jsonData: JSON) {
        var user = jsonData["user"]
        
        Session.login(user["username"].string!,
            email: user["email"].string!,
            user_id: user["external_id"].string!,
            auth_token: user["auth_token"].string!,
            created_at: user["created_at"].string!,
            avatar_url: user["avatar_url"].string)
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
