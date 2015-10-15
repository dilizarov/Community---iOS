//
//  ShareCommunityViewController.swift
//  
//
//  Created by David Ilizarov on 9/29/15.
//
//

import UIKit

class ShareCommunityViewController: UIViewController {

    @IBAction func shareCommunity(sender: AnyObject) {
        let text = "Join me on #Community"
        let url = NSURL(string: "http://get.community")!
        
        var objectsToShare: [AnyObject] = [text, url]
        
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList, UIActivityTypePrint]
        
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
