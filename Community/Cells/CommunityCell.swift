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
    var normalizedName: String!
    var row: Int!
    
    var presentControllerDelegate: PresentControllerDelegate!
    var leaveCommunityDelegate: LeaveCommunityDelegate!
    
    @IBOutlet var communityName: UILabel!
    
    func configureViews(community: JoinedCommunity, row: Int) {
        self.name = community.name
        self.normalizedName = community.normalizedName
        self.row = row
        
        self.communityName.text = self.name
        
        let shareButton = MGSwipeButton(title: "Share", backgroundColor: UIColor.blueColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            
            let nameWithUnite = "&" + self.normalizedName
            
            let objectsToShare: [AnyObject] = [nameWithUnite]
            
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop]
            
            self.presentControllerDelegate.presentController(activityVC)
            
            return true
        })
        
        let leaveButton = MGSwipeButton(title: "Leave", backgroundColor: UIColor.redColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in

            self.leaveCommunityDelegate.presentLeaveCommunityController(community, row: row)
            
            return true
        })
        
        let optionsButton = MGSwipeButton(title: "Settings", backgroundColor: UIColor.darkGrayColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
            let settingsVC = storyboard.instantiateViewControllerWithIdentifier("CommunitySettingsViewController") as! CommunitySettingsViewController
                
            settingsVC.communityName = self.name
            settingsVC.communityKey = self.normalizedName
            
            self.presentControllerDelegate.presentController(settingsVC)

            return true
        })
        
        self.rightButtons = [leaveButton, shareButton]
        self.leftButtons = [optionsButton]
        
        let leftExpansionSettings = MGSwipeExpansionSettings()
        leftExpansionSettings.fillOnTrigger = true
        leftExpansionSettings.buttonIndex = 0
        
        self.leftExpansion = leftExpansionSettings
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
