//
//  SearchController.swift
//  Community
//
//  Created by David Ilizarov on 8/17/15.
//  Copyright (c) 2015 David Ilizarov. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var search: UITextField!
    
    @IBOutlet var profileButton: UIButton!
    @IBAction func profileButtonPressed(sender: AnyObject) {
        var segue = "goToLoggedOutProfile"
        
        if (NSUserDefaults.standardUserDefaults().objectForKey("auth_token") != nil) {
            segue = "goToProfile"
        }

        self.performSegueWithIdentifier(segue, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       self.search.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        self.performSegueWithIdentifier("goToCommunity", sender: self)
        
        return false
    }

}

