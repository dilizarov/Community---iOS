//
//  WritePostViewController.swift
//  
//
//  Created by David Ilizarov on 9/10/15.
//
//

import UIKit
import SZTextView

class WritePostViewController: UIViewController {

    
    @IBOutlet var writePostHolderView: UIView!
    
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var titleField: UITextField!
    @IBOutlet var postTextView: SZTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        
        self.writePostHolderView.layer.masksToBounds = false
        self.writePostHolderView.layer.cornerRadius = 5.0
        
        self.postTextView.becomeFirstResponder()
    }
    
    func setupNavBar() {
        var navBar: UINavigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.bounds.width, 64))
        
        navBar.barTintColor = UIColor.whiteColor()
        navBar.translucent = false
        
        self.view.addSubview(navBar)
        
        var buttonLeft = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: Selector("cancel"))
        buttonLeft.tintColor = UIColor.blueColor()
        
        var buttonRight = UIBarButtonItem(title: "Search", style: .Plain, target: self, action: Selector("goSearch"))
        buttonRight.tintColor = UIColor.blueColor()
        
        var navigationItem = UINavigationItem()
        navigationItem.rightBarButtonItem = buttonRight
        navigationItem.leftBarButtonItem = buttonLeft
        
        navigationItem.title = "Post"
        
        navBar.pushNavigationItem(navigationItem, animated: false)
    }

    func cancel() {
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
