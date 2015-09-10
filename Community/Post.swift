//
//  Post.swift
//  Community
//
//  Created by David Ilizarov on 9/9/15.
//  Copyright (c) 2015 David Ilizarov. All rights reserved.
//

import Foundation

class Post {
    
    var id: String
    var username: String
    var body: String
    var title: String?
    var repliesCount: Int
    var likeCount: Int
    var liked: Bool
    var timestamp: String
    var timeCreated: NSDate
    var avatarUrl: String?
    
    init(id: String, username: String, body: String, title: String?, repliesCount: Int, likeCount: Int, liked: Bool, timeCreated: String, avatarUrl: String?) {
        self.id = id
        self.username = username
        self.body = body
        self.title = title
        self.repliesCount = repliesCount
        self.likeCount = likeCount
        self.liked = liked
        self.timeCreated = timeCreated.toNSDate()
        self.timestamp = NSDate().offsetFrom(self.timeCreated)
        self.avatarUrl = avatarUrl
    }
    
}