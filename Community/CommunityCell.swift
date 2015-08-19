//
//  CommunityCell.swift
//  Community
//
//  Created by David Ilizarov on 8/19/15.
//  Copyright (c) 2015 David Ilizarov. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class CommunityCell: MGSwipeTableCell {
    
    var name: NSString!
    
    @IBOutlet var communityName: UILabel!
    
    func configureViews(name: NSString) {
        self.name = name
        
        self.communityName.text = name as String
        self.rightButtons = [MGSwipeButton(title: "Leave", backgroundColor: UIColor.redColor()), MGSwipeButton(title: "Share", backgroundColor: UIColor.blueColor())]
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
