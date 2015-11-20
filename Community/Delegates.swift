//
//  PresentControllerDelegate.swift
//  Community
//
//  Created by David Ilizarov on 8/26/15.
//  Copyright (c) 2015 David Ilizarov. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol PresentControllerDelegate {
    func presentController(controller: UIViewController)
}

protocol LeaveCommunityDelegate {
    func presentLeaveCommunityController(community: JoinedCommunity, row: Int)
}

protocol UpdateFeedWithLatestPostDelegate {
    
    func updateFeedWithLatestPost(post: Post)
    
}

protocol CommunityTableDelegate {
    
    func writePost()
    func spreadToast(string: String)
    func declareRelationship(relationship: JSON)
}

protocol RepliesTableDelegate {
    
    func startLoading()
    func stopLoading()
    func stopRefreshing()
    func enableReplying()
    func setPost(post: Post)
}