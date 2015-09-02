//
//  CommunityViewController.swift
//  Community
//
//  Created by David Ilizarov on 8/18/15.
//  Copyright (c) 2015 David Ilizarov. All rights reserved.
//

import UIKit
import MMDrawerController

class CommunityViewController: UIViewController {
    
    var community: String!
    var drawerController: MMDrawerController?
    
    @IBAction func searchButtonPressed(sender: AnyObject) {

//        self.delegate.delegate.drawerController?.leftDrawerViewController = self.delegate.delegate.leftViewController
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        println(community)
    }
}