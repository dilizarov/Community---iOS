//
//  Notification.swift
//  Community
//
//  Created by David Ilizarov on 10/11/15.
//  Copyright (c) 2015 David Ilizarov. All rights reserved.
//

import Foundation

class Notification {
    
    var kind: String
    var avatarUrl: String?
    var username: String
    var timeCreated: NSDate
    var timestamp: String
    var community: String
    var normalizedCommunityName: String
    var postId: String
    
    var displayString: NSAttributedString
    
    init(kind: String, username: String, timeCreated: String, community: String, normalizedCommunityName: String, postId: String, avatarUrl: String?) {
        self.kind = kind
        self.username = username
        self.avatarUrl = avatarUrl
        self.timeCreated = timeCreated.toNSDate()
        self.timestamp = NSDate().offsetFrom(self.timeCreated)
        self.community = community
        self.normalizedCommunityName = normalizedCommunityName
        self.postId = postId
        
        var string: String!
        
        if kind == "post_created" {
            string = "\(username) posted in &\(normalizedCommunityName)"
        } else if kind == "post_liked" {
            string = "\(username) liked your post in &\(normalizedCommunityName)"
        } else if kind == "reply_liked" {
            string = "\(username) liked your reply"
        } else {
            string = "\(username) replied to a post in &\(normalizedCommunityName)"
        }
        
        var editableString = NSMutableAttributedString(string: string)
        
        var usernameRange = NSMakeRange(0, NSString(string: username).length)
        var communityRange = NSMakeRange(NSString(string: string).length - NSString(string: normalizedCommunityName).length - 1, NSString(string: normalizedCommunityName).length + 1)
        
        editableString.beginEditing()
        
        var attributes: [NSObject : AnyObject] = [NSFontAttributeName : UIFont.boldSystemFontOfSize(15)]
    
        editableString.addAttributes(attributes, range: usernameRange)
        
        if kind != "reply_liked" {
            editableString.addAttributes(attributes, range: communityRange)
        }
        
        editableString.endEditing()
        
        self.displayString = editableString
    }
    
}