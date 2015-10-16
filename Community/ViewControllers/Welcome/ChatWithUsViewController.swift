//
//  ChatWithUsViewController.swift
//  
//
//  Created by David Ilizarov on 9/30/15.
//
//

import UIKit
import MMDrawerController

class ChatWithUsViewController: UIViewController {

    @IBAction func uniteMeaning(sender: AnyObject) {
        let definitionAlert = UIAlertController(title: "& Stands For Unite", message: "&example and &another_one are ways to mark 'example' and 'another one' as communities.", preferredStyle: .Alert)
        
        let confirm = UIAlertAction(title: "Close", style: .Default, handler: nil)
        
        definitionAlert.addAction(confirm)
        
        self.presentViewController(definitionAlert, animated: true, completion: nil)

    }
    
    @IBAction func chatWithUs(sender: AnyObject) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).configureUsualLaunch("Community")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        navigationItem.rightBarButtonItem?.target = self
        navigationItem.rightBarButtonItem?.action = Selector("donePressed")
    }
    
    func donePressed() {
        (UIApplication.sharedApplication().delegate as! AppDelegate).configureUsualLaunch(nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
