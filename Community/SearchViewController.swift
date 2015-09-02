//
//  SearchController.swift
//  Community
//
//  Created by David Ilizarov on 8/17/15.
//  Copyright (c) 2015 David Ilizarov. All rights reserved.
//

import UIKit
import MMDrawerController

class SearchViewController: UIViewController, UITextFieldDelegate {

    // Dictates whether or not we have a NSNotification Observer viewing this
    var observingSideViewAppeared: Bool = false
    var observingCommunitySelected: Bool = false
    var observingPresentLogin: Bool = false
    var observingPresentCreateAcc: Bool = false
    
    // This drawerController is used like the navigationController property.
    // Calls upon the MMDrawerController that holds this
    var drawerController: MMDrawerController?
    
    @IBOutlet var search: UITextField!
    
    @IBOutlet var profileButton: UIButton!
    @IBAction func profileButtonPressed(sender: AnyObject) {
        drawerController?.openDrawerSide(.Left, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        search.layer.masksToBounds = false
        search.layer.cornerRadius = 8
        search.layer.shadowOffset = CGSizeMake(0, 5)
        search.layer.shadowRadius = 5
        search.layer.shadowOpacity = 0.4
        search.tintColor = UIColor.whiteColor()
        
       self.search.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // This handles removing the keyboard if it is up when one wants to view the side view.
        if (!observingSideViewAppeared) {
            observingSideViewAppeared = true
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("resignSearchKeyboard"), name: "sideViewAppeared", object: nil)
        }
        
        // This handles if community was selected in side view
        if (!observingCommunitySelected) {
            observingCommunitySelected = true
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("communitySelected:"), name: "communitySelected", object: nil)
        }
    }
    
    func resignSearchKeyboard() {
        search.resignFirstResponder()
    }
    
    func communitySelected(notification: NSNotification) {
        if let info = notification.userInfo as? Dictionary<String, String> {
            if let community = info["community"] {
                drawerController?.closeDrawerAnimated(true, completion: { _ in
                    self.search(community)
                })
            }
        }
    }

    func search(community: String) {
        
        drawerController?.closeDrawerAnimated(true, completion: { _ in
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let centerViewController = mainStoryboard.instantiateViewControllerWithIdentifier("CommunityViewController") as! CommunityViewController
            let leftViewController = self.drawerController?.leftDrawerViewController
            
            let communityDC = MMDrawerController(centerViewController: centerViewController, leftDrawerViewController: leftViewController)
            
            communityDC?.setMaximumLeftDrawerWidth(330, animated: true, completion: nil)
            communityDC?.openDrawerGestureModeMask = .All
            communityDC?.closeDrawerGestureModeMask = .All
            communityDC?.centerHiddenInteractionMode = .None
            communityDC?.setDrawerVisualStateBlock(MMDrawerVisualState.parallaxVisualStateBlockWithParallaxFactor(3)!)
            
            centerViewController.community = community
            centerViewController.drawerController = communityDC
            
            self.presentViewController(communityDC, animated: true, completion: nil)
        })
    
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        search(textField.text)
        
        return false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "sideViewAppeared", object: nil)
        observingSideViewAppeared = false
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "communitySelected", object: nil)
        observingCommunitySelected = false
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "sideViewAppeared", object: nil)
        observingSideViewAppeared = false
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "communitySelected", object: nil)
        observingCommunitySelected = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

