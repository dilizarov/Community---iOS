//
//  CommentsViewController.swift
//  
//
//  Created by David Ilizarov on 9/18/15.
//
//

import UIKit
import SDWebImage
import UIActivityIndicator_for_SDWebImage
import Alamofire
import EKKeyboardAvoiding

class CommentsViewController: UIViewController, PHFComposeBarViewDelegate {

    @IBOutlet var containerView: ContainerView!
    
    var composeBarView: PHFComposeBarView {
        var viewBounds = self.view
        var frame = CGRectMake(0, viewBounds.frame.height - PHFComposeBarViewInitialHeight, viewBounds.frame.width, PHFComposeBarViewInitialHeight)
        
        var composeBarView = PHFComposeBarView(frame: frame)
        
        composeBarView.maxLinesCount = 6
        composeBarView.placeholder = "Add a comment..."
        composeBarView.delegate = self
        
        composeBarView.buttonTintColor = UIColor(hexString: "056A85")
        composeBarView.textView.backgroundColor = UIColor.whiteColor()
        
        return composeBarView
    }

    override var inputAccessoryView: UIView {
        return self.containerView.customInputView
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    var post: Post!
    var tableViewController: CommentsTableViewController!
    
    var navBar: UINavigationBar!
    var rightButtonOptions = [String: UIBarButtonItem]()
    
    @IBOutlet var tableHolder: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.containerView.customInputView = self.composeBarView
        
        setupNavBar()
        
        var tapGesture = UITapGestureRecognizer(target: self, action: "keyboardDisappear")
        tapGesture.numberOfTapsRequired = 1
        
        self.containerView.addGestureRecognizer(tapGesture)
    }
    
    func keyboardDisappear() {
        println("hyuk")
        self.containerView.customInputView.resignFirstResponder()
    }
    
    func setupNavBar() {
        navBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.bounds.width, 64))
        
        navBar.barTintColor = UIColor.whiteColor()
        navBar.translucent = false
        
        navBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.darkGrayColor() ]
        
        self.view.addSubview(navBar)
        
        var backButton = UIBarButtonItem(image: UIImage(named: "Back"), style: .Plain, target: self, action: Selector("back"))
        
        backButton.tintColor = UIColor(hexString: "056A85")
        
        var refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: Selector("refresh"))
        
        refreshButton.tintColor = UIColor(hexString: "056A85")
        refreshButton.enabled = true
        
        var loadIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 22, 22))
        loadIndicator.stopAnimating()
        loadIndicator.hidesWhenStopped = true
        loadIndicator.activityIndicatorViewStyle = .Gray
        
        var loadButton = UIBarButtonItem(customView: loadIndicator)
        
        rightButtonOptions["refresh"] = refreshButton
        rightButtonOptions["load"] = loadButton
        
        var navigationItem = UINavigationItem()
        navigationItem.rightBarButtonItem = refreshButton
        navigationItem.leftBarButtonItem = backButton
        
        navigationItem.title = "Comments"
        
        navBar.pushNavigationItem(navigationItem, animated: false)
    }
    
//    func setupAddComment() {
//        var viewBounds = self.view
//        var frame = CGRectMake(0, viewBounds.frame.height - PHFComposeBarViewInitialHeight, viewBounds.frame.width, PHFComposeBarViewInitialHeight)
//            
//        var composeBarView = PHFComposeBarView(frame: frame)
//            
//        composeBarView.maxLinesCount = 6
//        composeBarView.placeholder = "Add a comment..."
//        composeBarView.delegate = self
//            
//        composeBarView.buttonTintColor = UIColor(hexString: "056A85")
//        composeBarView.textView.backgroundColor = UIColor.whiteColor()
//    }
    
    func composeBarViewDidPressButton(composeBarView: PHFComposeBarView!) {
        println("Pressed")
    }
    
    func refresh() {
//        self.tableViewController.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: tableViewController.comments.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: false)
    
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue(), {
            self.tableViewController.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.tableViewController.comments.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
        })

    }
    
    func back() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "commentsEmbedTVC" {
            tableViewController = segue.destinationViewController as! CommentsTableViewController
            
            tableViewController.post = post
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
