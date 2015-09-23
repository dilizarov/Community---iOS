//
//  CommentsTableViewController.swift
//  
//
//  Created by David Ilizarov on 9/18/15.
//
//

import UIKit
import EKKeyboardAvoiding

class CommentsTableViewController: UITableViewController {
    
    var post: Post!
    
    var atBottom = false
    
    var comments = ["placeholder", "wow", "this", "is", "a", "comment", "for the ages", "YEP YEP YEP YEP AEWPTOMA AWET AWT AMWT LAWT WLT LAWKE GAWL GALW KT", "WETATAWTAWTE AWT AWTAWTAWT'W ,", "WATLQWT QT AE", "waegla gaew gal;kw g wlegka wjgwgwalg we gka fkjwaef akwjef jwaekf kwae fkajwe fjka gke wkag awgja;g ", "wgnkawg akwgl gwa gawl gaj aw fkwa eawjlq rj wreqoiradfa", "k wawlgnaw wefiebf wk kw vka k wkjf wek gkjaw ge g tewr oiqweuroaweurpasf pasfu pfu pup aupurp awu pwetu p uoa uputapwutwout waputpawu tpaweut pwue tpuatpueawpt uawpt uawpetu wtu we tuowu ouut oewutpawut pawuetp aup upasue tuwpghgoah oghao ahohhqtwej la", "wow", "this", "is", "a", "comment", "for the ages", "YEP YEP YEP YEP AEWPTOMA AWET AWT AMWT LAWT WLT LAWKE GAWL GALW KT", "WETATAWTAWTE AWT AWTAWTAWT'W ,", "WATLQWT QT AE", "waegla gaew gal;kw g wlegka wjgwgwalg we gka fkjwaef akwjef jwaekf kwae fkajwe fjka gke wkag awgja;g ", "wgnkawg akwgl gwa gawl gaj aw fkwa eawjlq rj wreqoiradfa", "k wawlgnaw wefiebf wk kw vka k wkjf wek gkjaw ge g tewr oiqweuroaweurpasf pasfu pfu pup aupurp awu pwetu p uoa uputapwutwout waputpawu tpaweut pwue tpuatpueawpt uawpt uawpetu wtu we tuowu ouut oewutpawut pawuetp aup upasue tuwpghgoah oghao ahohhqtwej la", "wow", "this", "is", "a", "comment", "for the ages", "YEP YEP YEP YEP AEWPTOMA AWET AWT AMWT LAWT WLT LAWKE GAWL GALW KT", "WETATAWTAWTE AWT AWTAWTAWT'W ,", "WATLQWT QT AE", "waegla gaew gal;kw g wlegka wjgwgwalg we gka fkjwaef akwjef jwaekf kwae fkajwe fjka gke wkag awgja;g ", "wgnkawg akwgl gwa gawl gaj aw fkwa eawjlq rj wreqoiradfa", "k wawlgnaw wefiebf wk kw vka k wkjf wek gkjaw ge g tewr oiqweuroaweurpasf pasfu pfu pup aupurp awu pwetu p uoa uputapwutwout waputpawu tpaweut pwue tpuatpueawpt uawpt uawpetu wtu we tuowu ouut oewutpawut pawuetp aup upasue tuwpghgoah oghao ahohhqtwej la", "wow", "this", "is", "a", "comment", "for the ages"]
    
    var comments2 = ["placeholder", "wow", "this"]
    
    var cachedHeights = [Int: CGFloat]()
    
    var initialHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var headerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.width, 20))
        headerView.backgroundColor = UIColor.clearColor()
        
        tableView.tableHeaderView = headerView
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.contentSize = tableView.frame.size
        tableView.setKeyboardAvoidingEnabled(true)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "scrollAccordingly:", name: PHFComposeBarViewDidChangeFrameNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "scrollAccordingly:", name: UIKeyboardDidChangeFrameNotification, object: nil)
    }
    
    func scrollAccordingly(notification: NSNotification) {
        
        var animated = false
        
        if let info = notification.userInfo {
            if let keyboardFrame = info[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                animated = keyboardFrame.CGRectValue().height > 100
            }
        }

        if atBottom {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.comments.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: animated)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as! CommentPostCell
        
            cell.configureViews(self.post)
            
            cell.layoutIfNeeded()
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath) as! CommentCell
            
            var last = (indexPath.row == comments.count - 1)
            
            cell.configureViews(comments[indexPath.row], last: last)
            
            cell.setNeedsDisplay()
            cell.layoutIfNeeded()
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        self.cachedHeights[indexPath.row] = cell.frame.size.height
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let height = cachedHeights[indexPath.row] {
            return height
        } else {
            return 113
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        atBottom = scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)
    }
}
