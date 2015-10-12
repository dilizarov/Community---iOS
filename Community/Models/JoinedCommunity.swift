//
//  JoinedCommunity.swift
//  Community
//
//  Created by David Ilizarov on 9/11/15.
//  Copyright (c) 2015 David Ilizarov. All rights reserved.
//

import RealmSwift

class JoinedCommunity: Object {
    dynamic var name = ""
    dynamic var normalizedName = ""
    
    // These represent the Community-specific username
    // and avatar for the user. For simplicity, if "",
    // we assume to use default username and avatar.
    dynamic var username = ""
    dynamic var avatar_url = ""
    
    override static func indexedProperties() -> [String] {
        return ["name", "normalizedName"]
    }
    
    override static func primaryKey() -> String? {
        return "normalizedName"
    }
}
