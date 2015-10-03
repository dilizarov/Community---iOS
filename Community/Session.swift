//
//  Session.swift
//  Community
//
//  Created by David Ilizarov on 10/2/15.
//  Copyright (c) 2015 David Ilizarov. All rights reserved.
//

import Foundation
import KeychainSwift

class Session {
    
    static private var keychain: KeychainSwift {
        return KeychainSwift()
    }
    
    enum Key {
        case Username, Email, UserId, AuthToken, CreatedAt, AvatarUrl, MetaUserId, MetaAuthToken, MetaUsername, AccountUserId
        
        var path: String {
            
            var prefix: String = (!Session.loggedIn() ? "meta_" : "")
            
            switch self {
                case .Username:
                    return prefix + "username"
                case .Email:
                    return prefix + "email"
                case .UserId:
                    return prefix + "user_id"
                case .AuthToken:
                    return prefix + "auth_token"
                case .CreatedAt:
                    return prefix + "created_at"
                case .AvatarUrl:
                    return prefix + "avatar_url"
                case .MetaUserId:
                    return "meta_user_id"
                case .MetaAuthToken:
                    return "meta_auth_token"
                case .MetaUsername:
                    return "meta_username"
                case .AccountUserId:
                    return "user_id"
            }
        }
    }
    
    static func set(value: String, key: Key) {
        keychain.set(value, forKey: key.path)
    }
    
    static func get(key: Key) -> String? {
        return keychain.get(key.path)
    }
    
    static func getAuthToken() -> String? {
        return get(Key.AuthToken)
    }
    
    static func getUserId() -> String? {
        return get(Key.UserId)
    }
    
    static func isMeta() -> Bool {
        return !loggedIn()
    }
    
    static func loggedIn() -> Bool {
        return keychain.get("auth_token") != nil
    }
    
    static func createMetaAccount(username: String, user_id: String, auth_token: String, created_at: String) {
        
        keychain.set(username, forKey: "meta_username")
        keychain.set(user_id, forKey: "meta_user_id")
        keychain.set(auth_token, forKey: "meta_auth_token")
        keychain.set(created_at, forKey: "meta_created_at")
    }
    
    static func login(username: String, email: String, user_id: String, auth_token: String, created_at: String, avatar_url: String?) {
        
        keychain.set(username, forKey: "username")
        keychain.set(email, forKey: "email")
        keychain.set(user_id, forKey: "user_id")
        keychain.set(auth_token, forKey: "auth_token")
        keychain.set(created_at, forKey: "created_at")
        
        if let url = avatar_url {
            keychain.set(url, forKey: "avatar_url")
        }
    }
    
    static func logout() {
        keychain.delete("auth_token")
        keychain.delete("username")
        keychain.delete("email")
        keychain.delete("user_id")
        keychain.delete("created_at")
        keychain.delete("avatar_url")
    }
    
}