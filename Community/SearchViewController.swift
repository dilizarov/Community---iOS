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
    
    @IBOutlet var search: UITextField!
    
    @IBOutlet var profileButton: UIButton!
    @IBAction func profileButtonPressed(sender: AnyObject) {
        var segue = "goToLoggedOutProfile"
        
        if (NSUserDefaults.standardUserDefaults().objectForKey("auth_tokenn") != nil) {
            segue = "goToProfile"
        }

        self.performSegueWithIdentifier(segue, sender: self)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let centerViewController = mainStoryboard.instantiateViewControllerWithIdentifier("CommunityViewController") as! UIViewController
        let leftViewController = mainStoryboard.instantiateViewControllerWithIdentifier("LoggedOutProfileViewController") as! UIViewController

        let drawerController = MMDrawerController(centerViewController: centerViewController, leftDrawerViewController: leftViewController)
        
        drawerController?.setMaximumLeftDrawerWidth(330, animated: true, completion: nil)
        drawerController?.openDrawerGestureModeMask = .All
        drawerController?.closeDrawerGestureModeMask = .All
        drawerController.centerHiddenInteractionMode = .None
        drawerController.setDrawerVisualStateBlock(MMDrawerVisualState.parallaxVisualStateBlockWithParallaxFactor(3)!)
        
        presentViewController(drawerController, animated: true, completion: nil)
        
        return false
    }

}

