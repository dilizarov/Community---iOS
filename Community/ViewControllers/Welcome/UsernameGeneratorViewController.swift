//
//  UsernameGeneratorViewController.swift
//  
//
//  Created by David Ilizarov on 10/1/15.
//
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast

class UsernameGeneratorViewController: UIViewController {
    
    @IBOutlet var generatedUsername: UILabel!
    
    @IBOutlet var requestButton: UIButton!
    @IBAction func requestButtonPressed(sender: AnyObject) {
        if generatedUsername.text == "Something went wrong :(" {
            generateMetaAccount()
        } else {
            requestUsername()
        }
    }
    
    var loadIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        loadIndicator.hidesWhenStopped = true
        loadIndicator.layer.zPosition = 5000
        self.view.addSubview(loadIndicator)
        
       if Session.get(.MetaUsername) == nil {
            generateMetaAccount()
        } else {
            generatedUsername.text = Session.get(.MetaUsername)
            navigationItem.rightBarButtonItem?.enabled = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        loadIndicator.center = self.generatedUsername.center
    }
    
    func generateMetaAccount() {
        requestButton.enabled = false
        generatedUsername.alpha = 0.0
        generatedUsername.textColor = UIColor.darkGrayColor()
        loadIndicator.startAnimating()
        
        Alamofire.request(Router.CreateMetaAccount)
            .responseJSON { request, response, jsonData, errors in

                self.loadIndicator.stopAnimating()
                
                if let jsonData: AnyObject = jsonData {
                    let json = JSON(jsonData)
                    
                    if (json["user"] != nil) {
                        var user = json["user"]
                        
                        Session.createMetaAccount(user["username"].string!,
                            user_id: user["external_id"].string!,
                            auth_token: user["auth_token"].string!,
                            created_at: user["created_at"].string!)
                        
                        self.generatedUsername.text = user["username"].string
                        self.generatedUsername.alpha = 1.0
                        self.requestButton.enabled = true
                        self.requestButton.setTitle("Request another username", forState: .Normal)
                        
                        self.navigationItem.rightBarButtonItem?.enabled = true
                        
                        return
                    }
                }
                
                self.generatedUsername.text = "Something went wrong :("
                self.generatedUsername.textColor = UIColor(hexString: "850800")
                self.generatedUsername.alpha = 1.0
                self.requestButton.enabled = true
                self.requestButton.setTitle("Retry", forState: .Normal)
            }
    }
    
    func requestUsername() {
        requestButton.enabled = false
        generatedUsername.alpha = 0.0
        generatedUsername.textColor = UIColor.darkGrayColor()
        loadIndicator.startAnimating()
        
        var user_id = Session.get(.MetaUserId)

        if user_id == nil {
        
            self.generatedUsername.text = "Something went wrong :("
            self.generatedUsername.textColor = UIColor(hexString: "850800")
            self.generatedUsername.alpha = 1.0
            self.requestButton.enabled = true
            self.requestButton.setTitle("Retry", forState: .Normal)
            
            return
        }
        
        Alamofire.request(Router.ChangeMetaUsername)
            .responseJSON { request, response, jsonData, errors in
                
                self.loadIndicator.stopAnimating()
                
                if let jsonData: AnyObject = jsonData {
                    let json = JSON(jsonData)
                    
                    if (json["user"] != nil) {
                        var user = json["user"]
                        
                        Session.set(user["username"].string!, key: .MetaUsername)
                        
                        self.generatedUsername.text = user["username"].string
                        self.generatedUsername.alpha = 1.0
                        self.requestButton.enabled = true
                        
                        return
                    }
                }
                
                self.view.makeToast("Something went wrong :(", duration: NSTimeInterval(3), position: CSToastPositionCenter)
                self.generatedUsername.alpha = 1.0
                self.requestButton.enabled = true
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
