//
//  CommunityCell.swift
//  Community
//  Created by David Ilizarov on 8/19/15.
//  Copyright (c) 2015 David Ilizarov. All rights reserved.
//

import UIKit
import MGSwipeTableCell

protocol LeaveCommunityDelegate {
    func presentLeaveCommunityController(name: String, row: Int)
}

class CommunityCell: MGSwipeTableCell {
    
    var name: String!
    var row: Int!
    
    var presentControllerDelegate: PresentControllerDelegate!
    var leaveCommunityDelegate: LeaveCommunityDelegate!
    
    @IBOutlet var communityName: UILabel!
    
    func configureViews(name: NSString, row: Int) {
        self.name = name as! String
        self.row = row
        
        self.communityName.text = self.name
        
        var shareButton = MGSwipeButton(title: "Share", backgroundColor: UIColor.blueColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            
            let nameWithUnite = "&" + self.name
            
            var objectsToShare: [AnyObject] = [nameWithUnite]
            
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.presentControllerDelegate.presentController(activityVC)
            
            return true
        })
        
        var leaveButton = MGSwipeButton(title: "Leave", backgroundColor: UIColor.redColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in

            self.leaveCommunityDelegate.presentLeaveCommunityController(name as String, row: row)
            
            return true
        })
        
        self.rightButtons = [leaveButton, shareButton]
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layoutIfNeeded()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
