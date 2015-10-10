//
//  Router.swift
//  Community
//
//  Created by David Ilizarov on 10/2/15.
//  Copyright (c) 2015 David Ilizarov. All rights reserved.
//

import Alamofire

enum Router: URLRequestConvertible {
    static let baseURLString = "https://infinite-lake-4056.herokuapp.com/api/v1"
    
    case Login(email: String, password: String)
    case Register(username: String, email: String, password: String, transfer: Bool)
    case Logout
    case CreateMetaAccount
    case ChangeMetaUsername
    case SendDeviceToken
    case WritePost(community: String, body: String, title: String?)
    case LikePost(post_id: String, dislike: Bool)
    case GetPosts(community: String, page: Int?, infiniteScrollTimeBuffer: String?)
    case WriteReply(post_id: String, body: String)
    case LikeReply(reply_id: String, dislike: Bool)
    case GetReplies(post_id: String, includePost: Bool)
    case GetCommunities
    case VerifyMembership(community: String)
    case JoinCommunity(community: String)
    case LeaveCommunity(community: String)
    case UpdateCommunitySettings(community: String, dfault: Bool, username: String?) //We use dfault because default is reserved
    
    var URLRequest: NSURLRequest {
        
        let result: (method: Alamofire.Method, path: String, parameters: [String: AnyObject]?) = {
            
            var params = [String: AnyObject]()
            
            switch self {
                case .Login(let email, let password):
                    
                    params = [ "user" : ["email" : email, "password" : password ]]
                    return (.POST, "/sessions.json", params)
                
                case .Register(let username, let email, let password, let transfer):
                    
                    params = ["user" : ["username" : username, "email" : email, "password" : password ]]
                    
                    if transfer {
                        params["transfer_auth_token"] = Session.get(.MetaAuthToken)!
                        params["transfer_user_id"] = Session.get(.MetaUserId)!
                    }
                    
                    return (.POST, "/registrations.json", params)
                
                case .Logout:
                
                    return (.POST, "/sessions/logout.json", params)
                
                case .CreateMetaAccount:
                    
                    return (.POST, "/sessions/meta_account.json", params)
                
                case .ChangeMetaUsername:
                    
                    return (.POST, "/users/\(Session.get(.MetaUserId)!)/meta_username.json", params)
                
                case .SendDeviceToken:
                
                    if Session.getDeviceToken() != nil {
                        params = ["device" : ["platform" : "iOS", "token" : Session.getDeviceToken()!]]
                    }
                    
                    return (.POST, "sessions/sync_device.json", params)
                
                case .WritePost(let community, let body, let title):
                    
                    var post : [String: AnyObject] = [ "community" : community, "body" : body]
                    
                    if title != nil { post["title"] = title }
                    
                    params["post"] = post
                    
                    return (.POST, "/posts.json", params)
                
                case .LikePost(let post_id, let dislike):
                    
                    if dislike { params = ["dislike" : true ] }
                    
                    return (.GET, "/posts/\(post_id)/like.json", params)
                
                case .GetPosts(let community, let page, let infiniteScrollTimeBuffer):
                
                    params = ["community" : community]
                    if page != nil { params["page"] = page }
                    if infiniteScrollTimeBuffer != nil { params["infinite_scroll_time_buffer"] = infiniteScrollTimeBuffer }
                
                    return (.GET, "/posts.json", params)
                
                case .WriteReply(let post_id, let body):
                    
                    params = [ "reply" : ["body" : body]]
                    
                    return (.POST, "/posts/\(post_id)/replies.json", params)
                
                case .LikeReply(let reply_id, let dislike):
                    
                    if dislike { params = ["dislike" : true ] }
                    
                    return (.GET, "/replies/\(reply_id)/like.json", params)
                case .GetReplies(let post_id, let includePost):
                
                    if includePost {
                        params["include_post"] = true
                    }
                    
                    return (.GET, "/posts/\(post_id)/replies.json", params)
                
                case .GetCommunities:
                
                    return (.GET, "/communities.json", params)
                
                case VerifyMembership(let community):
                    
                    params = [ "community" : community ]
                    
                    return (.GET, "/communities/show.json", params)
                
                case JoinCommunity(let community):
                
                    params = [ "community" : community]
                    
                    return (.POST, "/communities.json", params)
                
                case LeaveCommunity(let community):
                
                    params = ["community" : community]
                
                    return (.DELETE, "/communities/destroy.json", params)
                
                case UpdateCommunitySettings(let community, let dfault, let username):
                    
                    if dfault {
                        params = [ "default" : true ]
                    } else {
                        if username != nil {
                            params = [ "username" : username! ]
                        }
                        
                        params["community"] = community
                    }
                    
                    return (.PUT, "/communities/update.json", params)
                
            }
        }()
        
        var params = result.parameters!
        
        switch self {
            case .CreateMetaAccount:
                break
            case .Login, .Register:
                if let deviceToken = Session.getDeviceToken() {
                    params["device"] = ["platform" : "iOS", "token" : deviceToken]
                }
            case .ChangeMetaUsername:
                params["auth_token"] = Session.get(.MetaAuthToken)!
            case .SendDeviceToken:
                params["auth_token"] = Session.getAuthToken()!
                params["user_id"] = Session.getUserId()!
                
                if Session.loggedIn() {
                    params["meta_auth_token"] = Session.get(.MetaAuthToken)!
                    params["meta_user_id"] = Session.get(.MetaUserId)!
                }
            default:
                println(Session.get(.AuthToken))
                params["auth_token"] = Session.getAuthToken()!
                params["user_id"] = Session.getUserId()!
        }
        
        let URL = NSURL(string: Router.baseURLString)!
        let URLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(result.path))

        URLRequest.HTTPMethod = result.method.rawValue
        
        let encoding = Alamofire.ParameterEncoding.URL
        
        return encoding.encode(URLRequest, parameters: params).0
    }
}