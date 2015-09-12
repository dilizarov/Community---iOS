//
//  PresentControllerDelegate.swift
//  Community
//
//  Created by David Ilizarov on 8/26/15.
//  Copyright (c) 2015 David Ilizarov. All rights reserved.
//

import UIKit

protocol PresentControllerDelegate {
    func presentController(controller: UIViewController)
}

protocol LeaveCommunityDelegate {
    func presentLeaveCommunityController(community: JoinedCommunity, row: Int)
}

@objc protocol ProfileTableDelegate {
    
    optional func handleRefresh()
    optional func beginInitialLoad()
    
    func failureRequestJoinedCommunities(error: String)
    func successRequestJoinedCommunities()
    
    func spreadToast(string: String)
    
}