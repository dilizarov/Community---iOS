//
//  LoginViewController.swift
//  
//
//  Created by David Ilizarov on 10/5/15.
//
//

import UIKit
import TextFieldEffects
import Alamofire
import SwiftyJSON
import MMProgressHUD

class LoginViewController: UIViewController, UITextFieldDelegate {

    var navBar: UINavigationBar!

    enum ViewState {
        case Login, ForgotPassword
    }
    
    var viewState: ViewState?
    
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
        setupNavBar()
        
        viewState = .Login
        commandButton.enabled = false
        
        emailField.tintColor = UIColor(hexString: "056A85")
        passwordField.tintColor = UIColor(hexString: "056A85")
        
        self.emailField.delegate = self
        self.passwordField.delegate = self
        
        emailField.addTarget(self, action: "textFieldDidChange", forControlEvents: .EditingChanged)
        passwordField.addTarget(self, action: "textFieldDidChange", forControlEvents: .EditingChanged)
    }
    
    func setupNavBar() {
        navBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.bounds.width, 64))
        
        navBar.barTintColor = UIColor(hexString: "056A85")
        navBar.translucent = true
        
        navBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.whiteColor() ]
        
        self.view.addSubview(navBar)
        
        var backButton = UIBarButtonItem(image: UIImage(named: "Back"), style: .Plain, target: self, action: Selector("back"))
        
        backButton.tintColor = UIColor.whiteColor()
        
        var navigationItem = UINavigationItem()
        navigationItem.leftBarButtonItem = backButton
        
        navigationItem.title = "Log In"
        
        navBar.pushNavigationItem(navigationItem, animated: false)
    }
    
    func processLogin() {
        
        MMProgressHUD.sharedHUD().overlayMode = .Linear
        MMProgressHUD.setPresentationStyle(.Balloon)
        MMProgressHUD.show()
        
        Alamofire.request(Router.Login(email: emailField.text!.strip(), password: passwordField.text!))
            .responseJSON { request, response, jsonData, errors in
                // We delay by 1 second to keep a very smooth animation.
                var delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                
                dispatch_after(delayTime, dispatch_get_main_queue(), {
                    var defaultError = errors?.localizedDescription
                    
                    if (defaultError != nil) {
                        MMProgressHUD.dismissWithError(defaultError?.removeEndingPunctuationAndMakeLowerCase(), afterDelay: NSTimeInterval(3))
                    } else if let jsonData: AnyObject = jsonData {
                        let json = JSON(jsonData)

                        if (json["error"] != nil) {
                            MMProgressHUD.dismissWithError(json["error"].stringValue, afterDelay: NSTimeInterval(3))
                        } else if (json["errors"] == nil) {
                            self.storeSessionData(json)
                            MMProgressHUD.sharedHUD().dismissAnimationCompletion = {
                            
                                self.emailField.resignFirstResponder()
                                self.passwordField.resignFirstResponder()
                                
                                var delegate = UIApplication.sharedApplication().delegate as! AppDelegate
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

    func processForgotPassword() {
        MMProgressHUD.sharedHUD().overlayMode = .Linear
        MMProgressHUD.setPresentationStyle(.Balloon)
        MMProgressHUD.show()
        
        Alamofire.request(Router.ForgotPassword(email: emailField.text!.strip()))
            .responseJSON { request, response, jsonData, errors in
                // We delay by 1 second to keep a very smooth animation.
                var delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                
                dispatch_after(delayTime, dispatch_get_main_queue(), {
                    
                    var defaultError = errors?.localizedDescription
                    
                    if (defaultError != nil) {
                        MMProgressHUD.dismissWithError(defaultError?.removeEndingPunctuationAndMakeLowerCase(), afterDelay: NSTimeInterval(3))
                    } else if response?.statusCode > 299 {
                        var errorString = "Something went wrong :("
                        
                        if let jsonData: AnyObject = jsonData {
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
        var emailChars = emailField.text!.strip()
        var passwordChars = passwordField.text!.strip()
        
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
