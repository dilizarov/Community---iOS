//
//  CreateAccountViewController.swift
//  
//
//  Created by David Ilizarov on 8/19/15.
//
//

import UIKit

class CreateAccountViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.tintColor = UIColor.whiteColor()
        emailTextField.tintColor = UIColor.whiteColor()
        passwordTextField.tintColor = UIColor.whiteColor()
        confirmTextField.tintColor = UIColor.whiteColor()

        usernameTextField.becomeFirstResponder()
        // Do any additional setup after loading the view.
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
