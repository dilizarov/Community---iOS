//
//  LogInViewController.swift
//  
//
//  Created by David Ilizarov on 8/19/15.
//
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var passwordLabel: UILabel!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var forgotPasswordButton: UIButton!
    @IBOutlet var logInButton: UIButton!
    
    @IBAction func forgetPasswordButtonPressed(sender: AnyObject) {
    }
    
    @IBAction func logInButtonPressed(sender: AnyObject) {
    }
    
    @IBOutlet var backButton: UIButton!
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.tintColor = UIColor.whiteColor()
        passwordTextField.tintColor = UIColor.whiteColor()
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        emailTextField.becomeFirstResponder()

        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if (textField == emailTextField) {
            passwordTextField.becomeFirstResponder()
        } else if (textField == passwordTextField) {
            //If disabled, nothing, else, press
        }
        
        return true
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
