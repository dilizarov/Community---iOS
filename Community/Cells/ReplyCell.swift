//
//  ReplyCell.swift
//  
//
//  Created by David Ilizarov on 9/18/15.
//
//

import UIKit
import SDWebImage
import UIActivityIndicator_for_SDWebImage
import Alamofire

class ReplyCell: UITableViewCell {

    var reply: Reply!
    var last = false
    
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var username: UILabel!
    @IBOutlet var timestamp: UILabel!
    @IBOutlet var likesCount: UILabel!
    
    @IBOutlet var likeImage: UIImageView!
    
    @IBOutlet var likeClickSpace: UIView!
    @IBOutlet var replyBody: UILabel!
    
    @IBOutlet var leadingUsernameSuperViewConstraint: NSLayoutConstraint!
    @IBOutlet var leadingUsernameAvatarConstraint: NSLayoutConstraint!
    @IBOutlet var leadingReplySuperViewConstraint: NSLayoutConstraint!
    @IBOutlet var leadingReplyAvatarConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layoutIfNeeded()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        var size: CGSize!
        
        if last { size = CGSizeMake(5.0, 5.0) }
        else { size = CGSizeMake(0.0, 0.0) }

        var maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: UIRectCorner.BottomLeft | UIRectCorner.BottomRight, cornerRadii: size)
                
        var maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.CGPath
                
        self.layer.mask = maskLayer
    }
    
    func configureViews(reply: Reply, last: Bool) {
        self.reply = reply
        self.last = last
        
        if let url = reply.avatarUrl {
            showAvatar()
            processAvatarImage(url)
        } else {
            hideAvatar()
        }
        
        self.username.text = reply.username
        self.replyBody.text = reply.body
        self.timestamp.text = reply.timestamp
        self.likesCount.text = reply.likeCount.toThousandsString()
    
        if reply.liked {
            likeImage.image = UIImage(named: "Liked")
        } else {
            likeImage.image = UIImage(named: "Like")
        }
        
        setupLikeGesture()
    }
    
    func processAvatarImage(url: String) {
        self.avatarImage.setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "AvatarPlaceHolder"), options: SDWebImageOptions.RetryFailed, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in
            
            }, usingActivityIndicatorStyle: .Gray)
    }
    
    func setupLikeGesture() {
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("processLike"))
        singleTap.numberOfTapsRequired = 1
        likeClickSpace.addGestureRecognizer(singleTap)
    }
    
    func processLike() {
        toggleLike()
        
        var userInfo = NSUserDefaults.standardUserDefaults()
        
        var params = [String: AnyObject]()
        params["user_id"] = userInfo.objectForKey("user_id") as! String
        params["auth_token"] = userInfo.objectForKey("auth_token") as! String
        
        if !reply.liked { params["dislike"] = true }
        
        Alamofire.request(.GET, "https://infinite-lake-4056.herokuapp.com/api/v1/replies/\(reply.id)/like.json", parameters: params)
            .responseJSON { request, response, jsonData, errors in
                
                if (response?.statusCode > 299 || errors != nil) {
                    if (response?.statusCode > 299) {
                        //something went wrong
                    } else {
                        //localizedDescription
                    }
                    
                    self.toggleLike()
                    // maybe use toast.
                }
        }
    }
    
    func toggleLike() {
        if reply.liked {
            reply.liked = false
            reply.likeCount -= 1
            likeImage.image = UIImage(named: "Like")
        } else {
            reply.liked = true
            reply.likeCount += 1
            likeImage.image = UIImage(named: "Liked")
        }
        
        self.likesCount.text = reply.likeCount.toThousandsString()
    }

    
    func avatarSetup() {
        self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.height / 2
        self.avatarImage.layer.masksToBounds = true
        self.avatarImage.contentMode = .ScaleAspectFit
        self.avatarImage.clipsToBounds = true
    }
    
    func showAvatar() {
        self.leadingReplyAvatarConstraint.priority = 999
        self.leadingReplySuperViewConstraint.priority = 500
        self.leadingUsernameAvatarConstraint.priority = 999
        self.leadingUsernameSuperViewConstraint.priority = 500
        self.avatarImage.alpha = 1.0
        self.layoutIfNeeded()
    }
    
    func hideAvatar() {
        self.leadingReplyAvatarConstraint.priority = 500
        self.leadingReplySuperViewConstraint.priority = 999
        self.leadingUsernameAvatarConstraint.priority = 500
        self.leadingUsernameSuperViewConstraint.priority = 999
        self.avatarImage.alpha = 0.0
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.avatarSetup()
        
        self.replyBody.lineBreakMode = .ByWordWrapping
        self.replyBody.sizeToFit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.avatarImage.sd_cancelCurrentImageLoad()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
