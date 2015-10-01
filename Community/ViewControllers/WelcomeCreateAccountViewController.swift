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

class WelcomeCreateAccountViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var createAccountButton: UIButton!
    @IBOutlet var usernameField: HoshiTextField!
    @IBOutlet var emailField: HoshiTextField!
    @IBOutlet var passwordField: HoshiTextField!
    @IBOutlet var passwordConfirmField: HoshiTextField!
    
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
    
//    func textFieldDidBeginEditing(textField: UITextField) {
//        
//        if (textField == passwordField || textField == passwordConfirmField) {
//            passwordShowButton.enabled = true
//            confirmShowButton.enabled = true
//            
//            passwordShowButton.alpha = 1.0
//            confirmShowButton.alpha = 1.0
//        } else {
//            passwordShowButton.alpha = 0.0
//            confirmShowButton.alpha = 0.0
//            
//            passwordShowButton.enabled = false
//            confirmShowButton.enabled = false
//            
//            passwordField.secureTextEntry = true
//            passwordConfirmField.secureTextEntry = true
//            
//            passwordShowButton.setTitle("Show", forState: .Normal)
//            confirmShowButton.setTitle("Show", forState: .Normal)
//        }
//    }
    
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
