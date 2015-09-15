//
//  WritePostViewController.swift
//  
//
//  Created by David Ilizarov on 9/10/15.
//
//

import UIKit
import SZTextView
import HexColors

class WritePostViewController: UIViewController {

    var navBar: UINavigationBar!
    var rightButtonOptions = [String : UIBarButtonItem]()
    
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
        navBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.bounds.width, 64))
        
        navBar.barTintColor = UIColor.whiteColor()
        navBar.translucent = false
        
        navBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.darkGrayColor() ]
        
        self.view.addSubview(navBar)
        
        var backButton = UIBarButtonItem(image: UIImage(named: "Back"), style: .Plain, target: self, action: Selector("cancel"))
        
        backButton.tintColor = UIColor(hexString: "056A85")
        
        var postButton = UIBarButtonItem(image: UIImage(named: "Message"), style: .Plain, target: self, action: Selector("processPost"))
        postButton.tintColor = UIColor(hexString: "056A85")
        
        var loadIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 22, 22))
        loadIndicator.stopAnimating()
        loadIndicator.hidesWhenStopped = true
        loadIndicator.activityIndicatorViewStyle = .Gray

        var loadButton = UIBarButtonItem(customView: loadIndicator)
        
        rightButtonOptions["post"] = postButton
        rightButtonOptions["load"] = loadButton
        
        var navigationItem = UINavigationItem()
        navigationItem.rightBarButtonItem = postButton
        navigationItem.leftBarButtonItem = backButton
        
        navigationItem.title = "Write"
        
        navBar.pushNavigationItem(navigationItem, animated: false)
    }

    func processPost() {
        (rightButtonOptions["load"]!.customView as! UIActivityIndicatorView).startAnimating()
        navBar.topItem!.rightBarButtonItem = rightButtonOptions["load"]
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
