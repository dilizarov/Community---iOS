//
//  ImportantDocumentsViewController.swift
//  
//
//  Created by David Ilizarov on 9/30/15.
//
//

import UIKit

class ImportantDocumentsViewController: UIViewController {
    
    // Since this is the root VC, we store these values here so that when going back and forth
    // between the stack, this persists through instances of our create account VC
    // typedConfirmPassword is purposely left out.
    var typedUsername: String?
    var typedEmail: String?
    var typedPassword: String?
    
    var agreementFlag = false
    
    @IBOutlet var agreementButton: UIButton!
    
    @IBAction func agreementButtonPressed(sender: AnyObject) {
        if agreementFlag {
            navigationItem.rightBarButtonItem?.enabled = false
            agreementButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
            agreementFlag = false
        } else {
            navigationItem.rightBarButtonItem?.enabled = true
            agreementButton.setTitleColor(UIColor(hexString: "056A85"), forState: .Normal)
            agreementFlag = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
