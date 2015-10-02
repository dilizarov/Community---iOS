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
import KeychainSwift
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
        
        let keychain = KeychainSwift()
        if keychain.get("meta_username") == nil {
            generateMetaAccount()
        } else {
            generatedUsername.text = keychain.get("meta_username")
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
        
        Alamofire.request(.POST, "https://infinite-lake-4056.herokuapp.com/api/v1/sessions/meta_account.json", encoding: .JSON)
            .responseJSON { request, response, jsonData, errors in

                self.loadIndicator.stopAnimating()
                
                if let jsonData: AnyObject = jsonData {
                    let json = JSON(jsonData)
                    
                    if (json["user"] != nil) {
                        var user = json["user"]
                        
                        let keychain = KeychainSwift()
                        
                        keychain.set(user["auth_token"].string!, forKey: "meta_auth_token")
                        keychain.set(user["username"].string!, forKey: "meta_username")
                        keychain.set(user["external_id"].string!, forKey: "meta_user_id")
                        keychain.set(user["created_at"].string!, forKey: "meta_created_at")
                        
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
        
        let keychain = KeychainSwift()
        var user_id = keychain.get("meta_user_id")

        if user_id == nil {
        
            self.generatedUsername.text = "Something went wrong :("
            self.generatedUsername.textColor = UIColor(hexString: "850800")
            self.generatedUsername.alpha = 1.0
            self.requestButton.enabled = true
            self.requestButton.setTitle("Retry", forState: .Normal)
            
            return
        }
        
        var params = [String: AnyObject]()
        params["auth_token"] = keychain.get("meta_auth_token")!
        
        Alamofire.request(.POST, "https://infinite-lake-4056.herokuapp.com/api/v1/users/\(user_id!)/meta_username.json", parameters: params, encoding: .JSON)
            .responseJSON { request, response, jsonData, errors in
                
                self.loadIndicator.stopAnimating()
                
                if let jsonData: AnyObject = jsonData {
                    let json = JSON(jsonData)
                    
                    if (json["user"] != nil) {
                        var user = json["user"]
                        
                        let keychain = KeychainSwift()
                        
                        keychain.set(user["username"].string!, forKey: "meta_username")
                        
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
