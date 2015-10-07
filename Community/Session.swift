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
        case Username, Email, UserId, AuthToken, CreatedAt, AvatarUrl,
            MetaUserId, MetaAuthToken, MetaUsername, MetaCreatedAt, MetaAvatarUrl, AccountUsername,
            AccountEmail, AccountUserId, AccountAuthToken, AccountCreatedAt, AccountAvatarUrl,
            DeviceToken
        
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
                case .MetaCreatedAt:
                    return "meta_created_at"
                case .MetaAvatarUrl:
                    return "meta_avatar_url"
                case .AccountUserId:
                    return "user_id"
                case .AccountUsername:
                    return "username"
                case .AccountEmail:
                    return "email"
                case .AccountAuthToken:
                    return "auth_token"
                case .AccountCreatedAt:
                    return "created_at"
                case .AccountAvatarUrl:
                    return "avatar_url"
                case .DeviceToken:
                    return "device_token"
            }
        }
    }
    
    static func set(value: String, key: Key) {
        keychain.delete(key.path)
        keychain.set(value, forKey: key.path, withAccess: .AccessibleAfterFirstUnlock)
    }
    
    static func get(key: Key) -> String? {
        return keychain.get(key.path)
    }
    
    static func getAuthToken() -> String? {
        return get(.AuthToken)
    }
    
    static func getUserId() -> String? {
        return get(.UserId)
    }
    
    static func isMeta() -> Bool {
        return !loggedIn()
    }
    
    static func loggedIn() -> Bool {
        return keychain.get("auth_token") != nil
    }
    
    static func setDeviceToken(value: String) {
        set(value, key: .DeviceToken)
    }
    
    static func getDeviceToken() -> String? {
        return get(.DeviceToken)
    }
    
    static func createMetaAccount(username: String, user_id: String, auth_token: String, created_at: String) {
        
        set(username, key: .MetaUsername)
        set(user_id, key: .MetaUserId)
        set(auth_token, key: .MetaAuthToken)
        set(created_at, key: .MetaCreatedAt)
    }
    
    static func login(username: String, email: String, user_id: String, auth_token: String, created_at: String, avatar_url: String?) {
        
        set(username, key: .AccountUsername)
        set(email, key: .AccountEmail)
        set(user_id, key: .AccountUserId)
        set(auth_token, key: .AccountAuthToken)
        set(created_at, key: .AccountCreatedAt)
        
        if let url = avatar_url {
            set(url, key: .AccountAvatarUrl)
        }
    }
    
    static func logout() {
        keychain.delete(Key.AccountAuthToken.path)
        keychain.delete(Key.AccountUsername.path)
        keychain.delete(Key.AccountEmail.path)
        keychain.delete(Key.AccountUserId.path)
        keychain.delete(Key.AccountCreatedAt.path)
        keychain.delete(Key.AccountAvatarUrl.path)
    }
    
}