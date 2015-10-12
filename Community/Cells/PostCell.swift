//
//  PostCell.swift
//  
//
//  Created by David Ilizarov on 9/8/15.
//
//

import UIKit
import SDWebImage
import UIActivityIndicator_for_SDWebImage
import Alamofire

class PostCell: UITableViewCell {

    var post: Post!
    
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var username: UILabel!
    @IBOutlet var timestamp: UILabel!
    @IBOutlet var repliesCount: UILabel!
    @IBOutlet var likesCount: UILabel!
    
    @IBOutlet var likeImage: UIImageView!
    
    @IBOutlet var likeClickSpace: UIView!
    // This acts both as either a title or a body.
    // If a title is given, use title, otherwise body.
    @IBOutlet var postBody: UILabel!
    @IBOutlet var postTitle: UILabel!
    
    @IBOutlet var cardView: UIView!
    
    @IBOutlet var titleUpperConstraint: NSLayoutConstraint!
    @IBOutlet var bodyUpperConstraint: NSLayoutConstraint!
    
    @IBOutlet var leadingUsernameSuperViewConstraint: NSLayoutConstraint!
    @IBOutlet var leadingUsernameAvatarConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layoutIfNeeded()
    }
    
    func configureViews(post: Post) {
        self.post = post
        
        if (post.title == nil) {
            hideTitle()
        } else {
            showTitle()
        }
        
        self.username.text = post.username

        if let title = post.title {
            self.postTitle.text = title
        }
        
        self.postBody.text = post.body
        self.timestamp.text = post.timestamp
        self.likesCount.text = post.likeCount.toThousandsString()
        self.repliesCount.text = post.repliesCount.toThousandsString()
        
        if post.liked {
            likeImage.image = UIImage(named: "Liked")
        } else {
            likeImage.image = UIImage(named: "Like")
        }
        
        if let url = post.avatarUrl {
            showAvatar()
            processAvatarImage(url)
        } else {
            hideAvatar()
        }

        setupLikeGesture()
    }
    
    func setupLikeGesture() {
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("processLike"))
        singleTap.numberOfTapsRequired = 1
        likeClickSpace.addGestureRecognizer(singleTap)
    }
    
    func showAvatar() {
        self.leadingUsernameAvatarConstraint.priority = 999
        self.leadingUsernameSuperViewConstraint.priority = 500
        self.avatarImage.alpha = 1.0
        self.layoutIfNeeded()
    }
    
    func hideAvatar() {
        self.leadingUsernameAvatarConstraint.priority = 500
        self.leadingUsernameSuperViewConstraint.priority = 999
        self.avatarImage.alpha = 0.0
        self.layoutIfNeeded()
    }
    
    func processLike() {
       toggleLike()
        
        Alamofire.request(Router.LikePost(post_id: post.id, dislike: !post.liked))
            .responseJSON { request, response, jsonData, errors in
                
                if (response?.statusCode > 299 || errors != nil) { self.toggleLike() }
            }
    }
    
    func toggleLike() {
        if post.liked {
            post.liked = false
            post.likeCount -= 1
            likeImage.image = UIImage(named: "Like")
        } else {
            post.liked = true
            post.likeCount += 1
            likeImage.image = UIImage(named: "Liked")
        }
        
        self.likesCount.text = post.likeCount.toThousandsString()
    }
    
    func processAvatarImage(url: String) {
        self.avatarImage.setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "AvatarPlaceHolder"), options: SDWebImageOptions.RetryFailed, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in
                
            }, usingActivityIndicatorStyle: .Gray)
    }
    
    func cardSetup() {
        self.cardView.alpha = 1.0
        self.cardView.layer.masksToBounds = false
        self.cardView.layer.cornerRadius = 5.0
    }
    
    func avatarSetup() {
        self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.height / 2
        self.avatarImage.layer.masksToBounds = true
        self.avatarImage.contentMode = .ScaleAspectFit
        self.avatarImage.clipsToBounds = true
    }
    
    func hideTitle() {
        self.bodyUpperConstraint.priority = 999
        self.titleUpperConstraint.priority = 500
        self.postTitle.alpha = 0.0
        self.layoutIfNeeded()
    }
    
    func showTitle() {
        self.titleUpperConstraint.priority = 999
        self.bodyUpperConstraint.priority = 500
        self.postTitle.alpha = 1.0
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.cardSetup()
        self.avatarSetup()
        self.postTitle.lineBreakMode = .ByWordWrapping
        self.postBody.lineBreakMode = .ByWordWrapping
        self.postTitle.sizeToFit()
        self.postBody.sizeToFit()
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
