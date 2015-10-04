//
//  PrivacyPolicyViewController.swift
//  
//
//  Created by David Ilizarov on 9/29/15.
//
//

import UIKit

class PrivacyPolicyViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet var webView: UIWebView!
    @IBOutlet var retryButton: UIButton!
        
    @IBAction func retryPressed(sender: AnyObject) {
        webView.alpha = 0.0
        retryButton.alpha = 0.0
        loadIndicator.startAnimating()
        webView.loadRequest(requestObj)
    }
    
    lazy var requestObj: NSURLRequest = {
        let url = NSURL(string: "https://www.iubenda.com/privacy-policy/908716")
        return NSURLRequest(URL: url!)
    }()
    
    var loadIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        loadIndicator.center = self.view.center
        loadIndicator.hidesWhenStopped = true
        loadIndicator.layer.zPosition = 5000
        self.view.addSubview(loadIndicator)
        
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.delegate = self
        
        retryButton.alpha = 0.0
        
        // Sometimes, web views jitter at the beginning due to screen constraints. We give it 0.25 seconds
        // to figure that out invisibly so it looks smooth.
        webView.alpha = 0.0
        webView.loadRequest(requestObj)
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        loadIndicator.startAnimating()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        loadIndicator.stopAnimating()
        retryButton.alpha = 1.0
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        loadIndicator.stopAnimating()
        retryButton.alpha = 0.0
        UIView.animateWithDuration(0.25, animations: {
            self.webView.alpha = 1.0
        })
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
