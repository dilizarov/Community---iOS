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
        
        var usernameText = strippedString(usernameTextField.text)
        var emailText    = strippedString(emailTextField.text)
        var passwordText = strippedString(passwordTextField.text)
        
        var params = [String: AnyObject]()
        
        var user = [ "username" : usernameText, "email" : emailText, "password" : passwordText]
        
        params["user"] = user
        
        Alamofire.request(.POST, "https://infinite-river-7560.herokuapp.com/api/v1/registrations.json", parameters: params, encoding: .JSON)
            .responseJSON { _, b, jsonData, errors in
                println(b?.statusCode)
                println(jsonData)
                println(errors)
                println("lalalalallala")
                
                if let jsonData: AnyObject = jsonData {
                    let post = JSON(jsonData)
                    println(post)
                }
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
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if (textField == usernameTextField) {
            emailTextField.becomeFirstResponder()
        } else if (textField == emailTextField) {
            passwordTextField.becomeFirstResponder()
        } else if (textField == passwordTextField) {
            confirmTextField.becomeFirstResponder()
        } else if (textField == confirmTextField) {
            
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
    
        var usernameChars = strippedString(usernameTextField.text)
        var emailChars    = strippedString(emailTextField.text)
        var passwordChars = strippedString(passwordTextField.text)
        var confirmChars  = strippedString(confirmTextField.text)
        
        if (usernameChars.isEmpty || !validateEmail(emailChars) || passwordChars.isEmpty || confirmChars.isEmpty || passwordChars != confirmChars) {
            disableCreateAccountButton()
        } else {
            enableCreateAccountButton()
        }
    }
    
    func strippedString(text: String) -> String {
        return text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(candidate)
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
