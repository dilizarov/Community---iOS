//
//  ScrollContainerViewController.swift
//  
//
//  Created by David Ilizarov on 9/7/15.
//
//

import UIKit

class ScrollContainerViewController: UIViewController, UIScrollViewDelegate {

    var topViewController: UIViewController?
    var bottomViewController: UIViewController?
    
    var scrollView: UIScrollView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addChildViewController(topViewController!)
        self.addChildViewController(bottomViewController!)
        topViewController?.didMoveToParentViewController(self)
        bottomViewController?.didMoveToParentViewController(self)

        var wBounds = UIScreen.mainScreen().bounds.width
        var hBounds = UIScreen.mainScreen().bounds.height
        
        
        
//        self.scrollView = UIScrollView()
//        scrollView?.backgroundColor = UIColor.clearColor()
//        scrollView?.frame = (UIApplication.sharedApplication().delegate as! AppDelegate).window!.frame
//        scrollView?.pagingEnabled = true
//        scrollView?.showsHorizontalScrollIndicator = false
//        scrollView?.showsVerticalScrollIndicator = false
//        scrollView?.bounces = false
//        scrollView?.scrollEnabled = false
//        
//        scrollView?.delegate = self
//        self.view.addSubview(self.scrollView!)
//        
//        self.scrollView?.contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height * 2)
//        
//        topViewController!.view.frame = CGRectMake(0, 0, wBounds, hBounds)
//        self.scrollView?.addSubview(self.topViewController!.view)
//        self.scrollView?.bringSubviewToFront(self.topViewController!.view)
//        
//        bottomViewController!.view.frame = CGRectMake(0, hBounds, wBounds, hBounds)
//        self.scrollView?.addSubview(self.bottomViewController!.view)
//        self.scrollView?.bringSubviewToFront(self.bottomViewController!.view)
    }

    func showTop(animated: Bool) {
        topViewController?.beginAppearanceTransition(true, animated: animated)
        bottomViewController?.beginAppearanceTransition(false, animated: animated)
        
        //scrollView?.setContentOffset(CGPoint(x: 0, y: 0), animated: animated)
        
        // We want to trigger ending the animations even if not animated
        if (!animated) {
            scrollViewDidEndScrollingAnimation(self.scrollView!)
        }
    }
    
    func showBottom(animated: Bool) {
        topViewController?.beginAppearanceTransition(false, animated: animated)
        bottomViewController?.beginAppearanceTransition(true, animated: animated)
        //scrollView?.setContentOffset(CGPoint(x: 0, y: self.view.bounds.height), animated: animated)
        
        // We want to trigger ending the animations even if not animated
        if (!animated) {
            scrollViewDidEndScrollingAnimation(self.scrollView!)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        topViewController?.endAppearanceTransition()
        bottomViewController?.endAppearanceTransition()
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
