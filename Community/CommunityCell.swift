//
//  CommunityCell.swift
//  Community
//  Created by David Ilizarov on 8/19/15.
//  Copyright (c) 2015 David Ilizarov. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class CommunityCell: MGSwipeTableCell {
    
    var name: String!
    
    var presentControllerDelegate: PresentControllerDelegate!
    
    @IBOutlet var communityName: UILabel!
    
    func configureViews(name: NSString) {
        self.name = name as! String
        
        self.communityName.text = self.name
        
        var shareButton = MGSwipeButton(title: "Share", backgroundColor: UIColor.blueColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            
            let nameWithUnite = "&" + self.name
            
            var objectsToShare: [AnyObject] = [nameWithUnite]
            
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.presentControllerDelegate.presentController(activityVC)
            
            return true
        })
        
        self.rightButtons = [MGSwipeButton(title: "Leave", backgroundColor: UIColor.redColor()), shareButton]
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
