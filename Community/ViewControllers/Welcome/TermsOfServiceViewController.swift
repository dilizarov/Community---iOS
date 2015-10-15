//
//  TermsOfServiceViewController.swift
//  
//
//  Created by David Ilizarov on 10/15/15.
//
//

import UIKit

class TermsOfServiceViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet var webView: UIWebView!
    
    lazy var requestObj: NSURLRequest = {
        var url = NSBundle.mainBundle().URLForResource("TermsOfService", withExtension: "html")
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
        
        // Sometimes, web views jitter at the beginning due to screen constraints. We give it 0.25 seconds
        // to figure that out invisibly so it looks smooth.
        webView.alpha = 0.0
        webView.loadRequest(requestObj)
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        loadIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        loadIndicator.stopAnimating()
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
